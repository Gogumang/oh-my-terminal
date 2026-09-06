//! 로고를 폰트 글리프로 굽는 어댑터.
//!
//! 터미널 프롬프트는 텍스트만 그릴 수 있어 이미지를 못 넣는다. 로고를 사용자 정의 영역(PUA)
//! 코드포인트의 글리프로 만들면 프롬프트에서 한 글자로 출력할 수 있다.
//!
//! 포맷은 sbix — macOS(Core Text)가 지원하는 컬러 비트맵 글리프 포맷이고 Apple Color Emoji가
//! 쓰는 것과 같아 렌더링이 확실하다. OT-SVG는 macOS 지원이 불안정해 쓰지 않는다.
//!
//! write-fonts의 sbix 타입은 원시 오프셋 배열을 노출해 결국 직렬화를 손으로 해야 하므로,
//! 테이블 바이트를 직접 만들어 add_raw 한다. 포맷이 단순해 그쪽이 오히려 명료하다.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

use anyhow::{anyhow, Result};
use image::RgbaImage;
use write_fonts::read::{FontRef, TableProvider};
use write_fonts::types::Tag;
use write_fonts::FontBuilder;

use super::logo_shaper as shaper;
use crate::domain::brand::Brand;
use crate::domain::palette;

pub const FAMILY: &str = "OhMyTerminal Brand";
pub const POSTSCRIPT: &str = "OhMyTerminalBrand-Regular";
const PUA_START: u32 = 0xE900;
/// 비트맵 해상도. 낮으면 고해상도 화면에서 뭉갠다.
const STRIKE_PPEM: u16 = 128;

pub struct FontArtifact {
    pub path: PathBuf,
    pub glyphs: BTreeMap<String, char>,
}

pub fn write_font(base: &Path, brands: &[Brand], output_root: &Path) -> Result<Option<FontArtifact>> {
    let usable: Vec<&Brand> = brands.iter().filter(|b| b.logo_path.is_some()).collect();
    if usable.is_empty() {
        return Ok(None);
    }

    let data = std::fs::read(base)?;
    let font = FontRef::new(&data)?;
    let original_glyphs = font.maxp()?.num_glyphs() as u32;
    let added = usable.len() as u32;
    let total_glyphs = original_glyphs + added;

    let mut builder = FontBuilder::new();

    // ── cmap: 기존 매핑 + PUA 추가 ─────────────────────────────────
    let mut mappings: Vec<(char, write_fonts::types::GlyphId)> = read_mappings(&font)?;
    for (index, _) in usable.iter().enumerate() {
        let code = char::from_u32(PUA_START + index as u32).ok_or_else(|| anyhow!("PUA 범위 초과"))?;
        mappings.push((code, write_fonts::types::GlyphId::new(original_glyphs + index as u32)));
    }
    let cmap = write_fonts::tables::cmap::Cmap::from_mappings(mappings)?;
    builder.add_table(&cmap)?;

    // ── loca: 빈 글리프를 뒤에 붙인다 (길이 0 = 외곽선 없음) ─────────
    // indexToLocFormat=1(long)이라 u32 배열이다. 마지막 오프셋을 그대로 반복하면
    // 새 글리프들은 전부 빈 글리프가 된다 — sbix는 외곽선 없이 비트맵만 쓴다.
    let loca_raw = font.table_data(Tag::new(b"loca"))
        .ok_or_else(|| anyhow!("loca 테이블이 없다"))?.as_bytes().to_vec();
    let long_format = font.head()?.index_to_loc_format() == 1;
    let mut loca = loca_raw.clone();
    if long_format {
        let last = &loca_raw[loca_raw.len() - 4..];
        for _ in 0..added { loca.extend_from_slice(last); }
    } else {
        let last = &loca_raw[loca_raw.len() - 2..];
        for _ in 0..added { loca.extend_from_slice(last); }
    }
    builder.add_raw(Tag::new(b"loca"), loca);

    // ── maxp: numGlyphs 갱신 (오프셋 4, u16 BE) ────────────────────
    let mut maxp = font.table_data(Tag::new(b"maxp"))
        .ok_or_else(|| anyhow!("maxp 테이블이 없다"))?.as_bytes().to_vec();
    maxp[4..6].copy_from_slice(&(total_glyphs as u16).to_be_bytes());
    builder.add_raw(Tag::new(b"maxp"), maxp);

    // ── hmtx: numberOfHMetrics 이후 글리프는 leftSideBearing만 갖는다.
    // 새 글리프는 마지막 longHorMetric의 advance를 물려받으므로(고정폭 폰트라 동일)
    // lsb 0을 개수만큼 덧붙이면 된다.
    let mut hmtx = font.table_data(Tag::new(b"hmtx"))
        .ok_or_else(|| anyhow!("hmtx 테이블이 없다"))?.as_bytes().to_vec();
    for _ in 0..added { hmtx.extend_from_slice(&0i16.to_be_bytes()); }
    builder.add_raw(Tag::new(b"hmtx"), hmtx);

    // ── post: v2는 글리프 이름 배열을 갖는다. 글리프를 추가하면 배열도 늘려야 하는데
    // 우리 글리프에 이름이 필요 없으므로 v3.0(이름 없음, 헤더 32바이트)으로 바꾼다.
    let post_raw = font.table_data(Tag::new(b"post"))
        .ok_or_else(|| anyhow!("post 테이블이 없다"))?.as_bytes().to_vec();
    let mut post = post_raw[..32].to_vec();
    post[0..4].copy_from_slice(&0x0003_0000u32.to_be_bytes());
    builder.add_raw(Tag::new(b"post"), post);

    // ── name: 원본 MesloLGS NF와 공존하도록 이름을 바꾼다.
    // nameID 6(PostScript 이름)에는 공백을 못 쓰고, iTerm2가 이 이름으로 폰트를 찾는다.
    builder.add_table(&build_name_table(&font)?)?;

    // ── sbix ──────────────────────────────────────────────────────
    let mut images = Vec::new();
    for (index, brand) in usable.iter().enumerate() {
        let tint = (!brand.keeps_original_colour()).then(|| palette::logo_tint(brand));
        images.push((original_glyphs + index as u32,
                     render_glyph(brand.logo_path.as_ref().unwrap(), tint)?));
    }
    builder.add_raw(Tag::new(b"sbix"), build_sbix(total_glyphs, &images));

    builder.copy_missing_tables(font);
    let output = output_root.join("fonts").join(format!("{POSTSCRIPT}.ttf"));
    std::fs::create_dir_all(output.parent().unwrap())?;
    std::fs::write(&output, builder.build())?;

    let mut glyphs = BTreeMap::new();
    for (index, brand) in usable.iter().enumerate() {
        glyphs.insert(brand.key.clone(),
                      char::from_u32(PUA_START + index as u32).unwrap());
    }
    let codepoints: BTreeMap<&String, u32> = glyphs.iter().map(|(k, c)| (k, *c as u32)).collect();
    std::fs::write(output_root.join("fonts/codepoints.json"),
        serde_json::to_string_pretty(&serde_json::json!({
            "family": FAMILY, "postscript": POSTSCRIPT, "codepoints": codepoints
        }))? + "\n")?;

    Ok(Some(FontArtifact { path: output, glyphs }))
}

/// cmap 서브테이블(format 4 / 12)을 훑어 코드포인트→글리프 매핑을 모은다.
/// read-fonts에는 전체를 한 번에 주는 API가 없어 서브테이블별로 순회한다.
fn read_mappings(font: &FontRef) -> Result<Vec<(char, write_fonts::types::GlyphId)>> {
    use write_fonts::read::tables::cmap::CmapSubtable;
    let cmap = font.cmap()?;
    let mut seen: BTreeMap<u32, write_fonts::types::GlyphId> = BTreeMap::new();
    for record in cmap.encoding_records() {
        let Ok(subtable) = record.subtable(cmap.offset_data()) else { continue };
        match subtable {
            CmapSubtable::Format4(table) => {
                for (code, glyph) in table.iter() {
                    seen.insert(code, write_fonts::types::GlyphId::new(glyph.to_u32()));
                }
            }
            CmapSubtable::Format12(table) => {
                for (code, glyph) in table.iter() {
                    seen.insert(code, write_fonts::types::GlyphId::new(glyph.to_u32()));
                }
            }
            _ => {}
        }
    }
    Ok(seen.into_iter()
        .filter_map(|(code, glyph)| char::from_u32(code).map(|c| (c, glyph)))
        .collect())
}

fn build_name_table(font: &FontRef) -> Result<write_fonts::tables::name::Name> {
    use write_fonts::tables::name::{Name, NameRecord};
    let source = font.name()?;
    let mut records = Vec::new();
    for record in source.name_record() {
        let id = record.name_id().to_u16();
        let replacement = match id {
            1 => Some(FAMILY.to_string()),
            3 => Some(format!("{FAMILY}; generated by oh-my-terminal")),
            4 => Some(format!("{FAMILY} Regular")),
            6 => Some(POSTSCRIPT.to_string()),
            _ => None,
        };
        let text = match replacement {
            Some(text) => text,
            None => record.string(source.string_data())
                .map(|s| s.chars().collect::<String>()).unwrap_or_default(),
        };
        records.push(NameRecord::new(record.platform_id(), record.encoding_id(),
                                     record.language_id(), record.name_id(), text.into()));
    }
    Ok(Name::new(records.into_iter().collect()))
}

/// sbix 테이블 바이트를 만든다. 포맷:
///   header: version(u16) flags(u16) numStrikes(u32) strikeOffsets(u32[])
///   strike: ppem(u16) ppi(u16) glyphDataOffsets(u32[numGlyphs+1]) <records>
///   record: originOffsetX(i16) originOffsetY(i16) graphicType(Tag) data
/// 빈 글리프는 offset[i] == offset[i+1] 로 표현한다.
fn build_sbix(total_glyphs: u32, images: &[(u32, Vec<u8>)]) -> Vec<u8> {
    let by_glyph: BTreeMap<u32, &Vec<u8>> = images.iter().map(|(id, png)| (*id, png)).collect();
    let offsets_bytes = 4 * (total_glyphs as usize + 1);
    let strike_header = 4 + offsets_bytes;

    let mut offsets = Vec::with_capacity(total_glyphs as usize + 1);
    let mut records = Vec::new();
    let mut cursor = strike_header as u32;
    for glyph in 0..total_glyphs {
        offsets.push(cursor);
        if let Some(png) = by_glyph.get(&glyph) {
            // 베이스라인 기준 살짝 내려야 글자와 눈높이가 맞는다.
            let offset_y = -((STRIKE_PPEM as f32 * 0.12) as i16);
            records.extend_from_slice(&0i16.to_be_bytes());
            records.extend_from_slice(&offset_y.to_be_bytes());
            records.extend_from_slice(b"png ");
            records.extend_from_slice(png);
            cursor += 8 + png.len() as u32;
        }
    }
    offsets.push(cursor);

    let mut strike = Vec::with_capacity(strike_header + records.len());
    strike.extend_from_slice(&STRIKE_PPEM.to_be_bytes());
    strike.extend_from_slice(&72u16.to_be_bytes());
    for offset in &offsets { strike.extend_from_slice(&offset.to_be_bytes()); }
    strike.extend_from_slice(&records);

    let header_size = 8 + 4;              // version + flags + numStrikes + 오프셋 1개
    let mut table = Vec::with_capacity(header_size + strike.len());
    table.extend_from_slice(&1u16.to_be_bytes());          // version
    table.extend_from_slice(&1u16.to_be_bytes());          // flags: 비트 0은 항상 1
    table.extend_from_slice(&1u32.to_be_bytes());          // numStrikes
    table.extend_from_slice(&(header_size as u32).to_be_bytes());
    table.extend_from_slice(&strike);
    table
}

fn render_glyph(path: &Path, tint: Option<[u8; 3]>) -> Result<Vec<u8>> {
    let logo = image::open(path)?.to_rgba8();
    let fitted = shaper::fit(&logo, STRIKE_PPEM as u32);
    let coloured: RgbaImage = match tint {
        Some(colour) => shaper::tint(&fitted, colour),
        None => fitted,
    };
    let mut buffer = std::io::Cursor::new(Vec::new());
    coloured.write_to(&mut buffer, image::ImageFormat::Png)?;
    Ok(buffer.into_inner())
}
