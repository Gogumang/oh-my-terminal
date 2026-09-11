//! 로고를 폰트 글리프로 굽는 어댑터.
//!
//! 터미널 프롬프트는 텍스트만 그릴 수 있어 이미지를 못 넣는다. 로고를 사용자 정의 영역(PUA)
//! 코드포인트의 글리프로 만들면 프롬프트에서 글자처럼 출력할 수 있다.
//!
//! 로고 하나는 글자 2~4칸을 차지하고, 칸마다 글리프 하나로 잘라 넣는다. 한 글리프가 옆 칸까지
//! 넘쳐 그리게 하면 터미널이 넘친 부분을 몇 칸까지 그려 줄지에 기대야 한다 — 칸 단위로 자르면
//! 어느 터미널에서나 글자처럼 제자리에 그려진다.
//!
//! 글리프는 비트맵이 아니라 TrueType 외곽선이다. 처음에는 PNG 비트맵(sbix)으로 넣었는데,
//! iTerm2 GPU 렌더러는 레티나 배율을 텍스트 행렬로 주고 Core Text는 비트맵 글리프에 그 배율을
//! 적용하지 않아 로고가 절반 크기로 줄 아래쪽에 붙어 그려졌다. 외곽선은 Nerd Font 아이콘처럼
//! 어떤 행렬에서도 글자와 똑같이 변환된다. 로고는 어차피 한 가지 색 실루엣이라 잃는 것이 없다.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

use anyhow::{anyhow, Result};
use image::{imageops, RgbaImage};
use write_fonts::read::{CollectionRef, FontRef, TableProvider};
use write_fonts::types::Tag;
use write_fonts::FontBuilder;

use super::logo_shaper as shaper;
use crate::domain::brand::Brand;
use crate::domain::palette::Rgb;

pub const FAMILY: &str = "OhMyTerminal Brand";
/// PostScript 이름 앞부분. 뒤에 판 번호가 붙는다.
const POSTSCRIPT_STEM: &str = "OhMyTerminalBrand";
/// 판 번호를 정하려고 먼저 조립할 때 이름 칸에 넣는 자리표시. 판 번호와 길이가 같아야 한다.
const PLACEHOLDER_VERSION: &str = "00000000";
/// 생성물 파일 이름. 판 번호는 폰트 안 이름에만 붙이고 파일 이름은 고정한다.
const FILE_NAME: &str = "OhMyTerminalBrand.ttf";
/// 로고 조각을 둘 코드포인트. 보조 사용자 영역 B(U+100000~)는 Nerd Font를 포함해 어떤 폰트도
/// 쓰지 않는다 — 기본 영역(U+E900~)에 두자 조각 수가 늘면서 Nerd Font 아이콘과 겹쳤다.
const PUA_START: u32 = 0x10_0000;
/// 로고 캔버스 해상도 (em당 픽셀). 외곽선은 이 격자를 따라 만든다.
pub const CANVAS_PPEM: u16 = 128;
/// 레티나 화면에서 13pt 글자의 em 픽셀 수. 획 굵기를 화면 기준으로 판단할 때 쓴다.
pub const SCREEN_EM_PIXELS: f64 = 26.0;
/// 로고 둘레 여백 (캔버스 픽셀). 오른쪽을 더 둬서 뒤따르는 경로 글자와 붙어 보이지 않게 한다.
const MARGIN_Y: u32 = 13;
const MARGIN_LEFT: u32 = 4;
const MARGIN_RIGHT: u32 = 12;
/// 로고 하나가 차지하는 칸 수 범위.
const MIN_CELLS: u32 = 2;
const MAX_CELLS: u32 = 4;
/// 이 알파 이상인 캔버스 픽셀을 로고 안쪽으로 본다.
const INK_ALPHA: u8 = 128;
/// 윤곽을 단순화할 때 허용하는 오차 (캔버스 픽셀). 화면에서는 0.2px 아래라 보이지 않는다.
const SIMPLIFY_TOLERANCE: f64 = 0.7;
/// 조각을 옆 칸 쪽으로 겹쳐 자르는 폭 (캔버스 픽셀, 화면에서 약 0.6px). 칸 경계에서 딱 끊으면
/// 경계 픽셀이 양쪽 조각에서 반씩만 칠해져 흐린 세로줄이 남는다.
const SLICE_OVERLAP: u32 = 3;

pub struct FontArtifact {
    pub path: PathBuf,
    /// iTerm2 프로필이 폰트를 찾는 이름. 폰트 내용이 바뀌면 함께 바뀐다.
    pub postscript: String,
    /// 회사키 → 프롬프트에 찍을 로고 조각 문자열 (칸 수만큼의 글자).
    pub glyphs: BTreeMap<String, String>,
}

/// 기반 폰트의 글자 칸 크기 (폰트 단위).
#[derive(Clone, Copy, Debug)]
pub struct Metrics {
    pub units_per_em: u16,
    pub advance: u16,
    pub ascender: i16,
    pub descender: i16,
}

impl Metrics {
    fn to_pixels(&self, units: i32) -> f64 {
        units as f64 * CANVAS_PPEM as f64 / self.units_per_em as f64
    }

    /// 글자 한 칸 폭 (캔버스 픽셀).
    pub fn cell_pixels(&self) -> u32 {
        self.to_pixels(self.advance as i32).round() as u32
    }

    /// 줄 높이 — 어센더부터 디센더까지 (캔버스 픽셀).
    pub fn line_pixels(&self) -> u32 {
        self.to_pixels(self.ascender as i32 - self.descender as i32).round() as u32
    }
}

/// 외곽선 글리프 하나. `lsb`는 hmtx에 적을 왼쪽 여백(= 외곽선의 xMin)이다.
struct OutlineGlyph {
    record: Vec<u8>,
    lsb: i16,
}

pub fn rgb8(rgb: Rgb) -> [u8; 3] {
    rgb.map(|channel| (channel.clamp(0.0, 1.0) * 255.0).round() as u8)
}

/// 기반 폰트 파일의 칸 크기. 미리보기가 폰트와 같은 캔버스를 그릴 때 쓴다.
pub fn metrics_of(base: &Path) -> Result<Metrics> {
    let data = std::fs::read(base)?;
    read_metrics(&open_font(&data)?)
}

pub fn write_font(base: &Path, brands: &[Brand], output_root: &Path) -> Result<Option<FontArtifact>> {
    let usable: Vec<&Brand> = brands.iter().filter(|b| b.logo_path.is_some()).collect();
    if usable.is_empty() {
        return Ok(None);
    }

    let data = std::fs::read(base)?;
    let metrics = read_metrics(&open_font(&data)?)?;

    // ── 로고 → 칸 조각 → 외곽선 글리프 ───────────────────────────────
    let mut outlines: Vec<OutlineGlyph> = Vec::new();
    let mut largest = (0usize, 0usize);   // 글리프 하나의 최대 (점 수, 윤곽 수)
    let mut glyphs = BTreeMap::new();
    for brand in &usable {
        let logo = image::open(brand.logo_path.as_ref().unwrap())?.to_rgba8();
        let canvas = logo_canvas(&logo, None, &metrics);
        let mut text = String::new();
        for slice in slice_cells(&canvas, metrics.cell_pixels()) {
            let code = PUA_START + outlines.len() as u32;
            text.push(char::from_u32(code).ok_or_else(|| anyhow!("PUA 범위 초과"))?);
            let contours = slice_contours(&slice, &metrics);
            let points = contours.iter().map(Vec::len).sum::<usize>();
            if points > u16::MAX as usize {
                return Err(anyhow!("{}: 로고 조각의 점이 너무 많다 ({points}개)", brand.key));
            }
            largest = (largest.0.max(points), largest.1.max(contours.len()));
            outlines.push(OutlineGlyph { lsb: left_side_bearing(&contours), record: encode_simple_glyph(&contours) });
        }
        glyphs.insert(brand.key.clone(), text);
    }

    // ── 판 번호: 이름 칸만 비워 조립한 바이트로 정한다 ─────────────────────
    // 실행 중인 iTerm2는 한 번 읽은 폰트를 이름으로 붙들고 있다. 같은 이름으로 파일만 바꿔
    // 설치하자 새 로고가 든 폰트를 끝까지 안 읽어 로고 자리가 비었다 (lsof로 보니 이미 지운
    // 옛 파일 두 개를 계속 열고 있었다). 내용이 바뀌면 이름도 바꿔 새 폰트로 읽게 한다.
    // 내용이 같으면 이름도 같아 빌드는 결정적으로 남는다.
    let draft = assemble(open_font(&data)?, &outlines, largest, PLACEHOLDER_VERSION)?;
    let version = content_version(&draft);
    let bytes = assemble(open_font(&data)?, &outlines, largest, &version)?;

    let output = output_root.join("fonts").join(FILE_NAME);
    std::fs::create_dir_all(output.parent().unwrap())?;
    std::fs::write(&output, bytes)?;

    let postscript = postscript_name(&version);
    let codepoints: BTreeMap<&String, Vec<u32>> = glyphs.iter()
        .map(|(key, text)| (key, text.chars().map(|c| c as u32).collect())).collect();
    std::fs::write(output_root.join("fonts/codepoints.json"),
        serde_json::to_string_pretty(&serde_json::json!({
            "family": family_name(&version), "postscript": postscript, "codepoints": codepoints
        }))? + "\n")?;

    Ok(Some(FontArtifact { path: output, postscript, glyphs }))
}

fn postscript_name(version: &str) -> String {
    format!("{POSTSCRIPT_STEM}-{version}")
}

fn family_name(version: &str) -> String {
    format!("{FAMILY} {version}")
}

/// 바이트 내용에서 8자리 16진 판 번호를 만든다 (FNV-1a).
fn content_version(bytes: &[u8]) -> String {
    let mut state: u64 = 0xcbf2_9ce4_8422_2325;
    for byte in bytes {
        state ^= *byte as u64;
        state = state.wrapping_mul(0x0000_0100_0000_01b3);
    }
    format!("{:08X}", (state >> 32) as u32 ^ state as u32)
}

/// 기반 폰트에 로고 글리프를 붙여 폰트 바이트를 조립한다. 이름에는 판 번호가 들어간다.
/// `largest`: 새 글리프 하나의 최대 (점 수, 윤곽 수) — maxp에 반영한다.
fn assemble(font: FontRef, outlines: &[OutlineGlyph], largest: (usize, usize), version: &str) -> Result<Vec<u8>> {
    let original_glyphs = font.maxp()?.num_glyphs() as u32;
    let added = outlines.len() as u32;
    let total_glyphs = original_glyphs + added;
    if total_glyphs > u16::MAX as u32 {
        return Err(anyhow!("글리프가 너무 많다 ({total_glyphs}개, 최대 65535)"));
    }

    let mut builder = FontBuilder::new();

    // ── cmap: 기존 매핑 + 로고 조각 ────────────────────────────────
    let mut mappings: Vec<(char, write_fonts::types::GlyphId)> = read_mappings(&font)?;
    for index in 0..added {
        let code = char::from_u32(PUA_START + index).ok_or_else(|| anyhow!("PUA 범위 초과"))?;
        mappings.push((code, write_fonts::types::GlyphId::new(original_glyphs + index)));
    }
    let cmap = write_fonts::tables::cmap::Cmap::from_mappings(mappings)?;
    builder.add_table(&cmap)?;

    // ── glyf/loca: 외곽선 글리프를 뒤에 붙인다 ───────────────────────────
    let head = font.head()?;
    let records: Vec<&[u8]> = outlines.iter().map(|outline| outline.record.as_slice()).collect();
    let (glyf, loca) = append_glyphs(table(&font, b"glyf")?, table(&font, b"loca")?,
                                     head.index_to_loc_format() == 1, &records)?;
    builder.add_raw(Tag::new(b"glyf"), glyf);
    builder.add_raw(Tag::new(b"loca"), loca);
    // append_glyphs는 항상 long 형식 loca를 만든다.
    let mut head_raw = table(&font, b"head")?.to_vec();
    head_raw[50..52].copy_from_slice(&1i16.to_be_bytes());
    builder.add_raw(Tag::new(b"head"), head_raw);

    // ── maxp: numGlyphs 갱신, 1.0 형식이면 글리프 하나의 최대 점·윤곽 수도 올린다 ──
    let mut maxp = table(&font, b"maxp")?.to_vec();
    maxp[4..6].copy_from_slice(&(total_glyphs as u16).to_be_bytes());
    if maxp.len() >= 10 && maxp[0..4] == [0, 1, 0, 0] {
        for (offset, least) in [(6usize, largest.0), (8, largest.1)] {
            let current = u16::from_be_bytes([maxp[offset], maxp[offset + 1]]);
            let raised = current.max(least.min(u16::MAX as usize) as u16);
            maxp[offset..offset + 2].copy_from_slice(&raised.to_be_bytes());
        }
    }
    builder.add_raw(Tag::new(b"maxp"), maxp);

    // ── hmtx: numberOfHMetrics 이후 글리프는 leftSideBearing만 갖는다.
    // 새 글리프는 마지막 longHorMetric의 advance(= 글자 한 칸)를 물려받는다.
    // lsb는 글리프마다 외곽선의 xMin을 적어야 한다. 렌더러는 외곽선을 옮겨 xMin을 lsb에 맞추는데,
    // 전부 0을 적자 조각마다 잉크 시작점이 칸 왼쪽 끝으로 끌려와 로고가 칸마다 어긋나 갈라졌다.
    // lsb만 붙이는 확장은 이미 lsb-only 구간이 있을 때만 유효하다. 기반 폰트를
    // 사용자가 바꿔치기할 수 있으므로(비고정폭 폰트) 가정을 검증한다.
    let metrics_count = font.hhea()?.number_of_h_metrics() as u32;
    if metrics_count >= original_glyphs {
        return Err(anyhow!(
            "기반 폰트에 lsb-only 구간이 없다 (numberOfHMetrics={metrics_count}, \
             numGlyphs={original_glyphs}). 고정폭 폰트를 써야 새 글리프의 폭이 보장된다"));
    }
    let mut hmtx = table(&font, b"hmtx")?.to_vec();
    for outline in outlines {
        hmtx.extend_from_slice(&outline.lsb.to_be_bytes());
    }
    builder.add_raw(Tag::new(b"hmtx"), hmtx);

    // ── post: v2는 글리프 이름 배열을 갖는다. 글리프를 추가하면 배열도 늘려야 하는데
    // 우리 글리프에 이름이 필요 없으므로 v3.0(이름 없음, 헤더 32바이트)으로 바꾼다.
    let mut post = table(&font, b"post")?[..32].to_vec();
    post[0..4].copy_from_slice(&0x0003_0000u32.to_be_bytes());
    builder.add_raw(Tag::new(b"post"), post);

    // ── name: 원본 MesloLGS NF와 공존하고, 판마다 다른 폰트로 읽히도록 이름을 바꾼다.
    // nameID 6(PostScript 이름)에는 공백을 못 쓰고, iTerm2가 이 이름으로 폰트를 찾는다.
    builder.add_table(&build_name_table(version))?;

    builder.copy_missing_tables(font);
    Ok(builder.build())
}

/// 로고를 칸 수에 맞춘 캔버스(칸 폭 × 줄 높이, 캔버스 픽셀)에 그린다. 칸 수는 로고 비율로 정한다.
///
/// 예전에는 모든 로고를 글자 한 칸짜리 정사각형(em)에 넣었다. 가로로 긴 워드마크(NOL·삼성)는
/// 글자 높이가 화면에서 몇 픽셀로 줄어 거의 안 보였다.
pub fn logo_canvas(logo: &RgbaImage, colour: Option<[u8; 3]>, metrics: &Metrics) -> RgbaImage {
    let shape = shaper::crop_to_content(logo);
    let (cell, line) = (metrics.cell_pixels(), metrics.line_pixels());
    let box_height = line.saturating_sub(2 * MARGIN_Y).max(1);
    let cells = cells_for(shape.width() as f64 / shape.height() as f64, cell, box_height);
    let box_width = cells * cell - MARGIN_LEFT - MARGIN_RIGHT;
    let scale = (box_width as f64 / shape.width() as f64).min(box_height as f64 / shape.height() as f64);
    let width = ((shape.width() as f64 * scale).round() as u32).clamp(1, box_width);
    let height = ((shape.height() as f64 * scale).round() as u32).clamp(1, box_height);
    let resized = imageops::resize(&shape, width, height, imageops::FilterType::Lanczos3);
    let mut canvas = RgbaImage::new(cells * cell, line);
    imageops::overlay(&mut canvas, &resized,
                      (MARGIN_LEFT + (box_width - width) / 2) as i64,
                      (MARGIN_Y + (box_height - height) / 2) as i64);
    let canvas = shaper::thicken_thin_strokes(&canvas, CANVAS_PPEM as f64 / SCREEN_EM_PIXELS);
    match colour {
        Some(colour) => shaper::tint(&canvas, colour),
        None => canvas,
    }
}

/// 로고가 줄 높이를 다 쓰려면 몇 칸이 필요한지. 정사각형에 가까우면 2칸, 긴 워드마크는 최대 4칸.
fn cells_for(aspect: f64, cell: u32, box_height: u32) -> u32 {
    let needed = (aspect * box_height as f64 + (MARGIN_LEFT + MARGIN_RIGHT) as f64) / cell as f64;
    (needed.ceil() as u32).clamp(MIN_CELLS, MAX_CELLS)
}

/// 칸 하나 몫의 조각. 옆 칸으로 겹쳐 자른 만큼 `left`(캔버스 픽셀)가 칸 왼쪽 경계보다 앞선다.
struct Slice {
    image: RgbaImage,
    left: u32,
    cell: u32,
}

/// 캔버스를 칸 단위 조각으로 자른다. 칸 경계에서 틈이 보이지 않게 양옆으로 조금씩 겹친다.
fn slice_cells(canvas: &RgbaImage, cell: u32) -> Vec<Slice> {
    (0..canvas.width() / cell)
        .map(|index| {
            let start = (index * cell).saturating_sub(SLICE_OVERLAP);
            let end = ((index + 1) * cell + SLICE_OVERLAP).min(canvas.width());
            Slice {
                image: imageops::crop_imm(canvas, start, 0, end - start, canvas.height()).to_image(),
                left: index * cell - start,
                cell,
            }
        })
        .collect()
}

type Point = (i64, i64);

/// 칸 조각 이미지를 폰트 단위 윤곽들로 바꾼다. 조각의 아래 끝이 디센더, 위 끝이 어센더이고,
/// 칸 왼쪽 경계가 x = 0이다 (겹친 부분은 음수나 advance 너머로 나간다).
fn slice_contours(slice: &Slice, metrics: &Metrics) -> Vec<Vec<(i16, i16)>> {
    let (width, height) = (slice.image.width() as usize, slice.image.height() as usize);
    // y는 위로 증가하게 뒤집어 담는다 — 폰트 좌표와 같은 방향.
    let mask: Vec<bool> = (0..height).rev()
        .flat_map(|row| (0..width).map(move |x| (x, row)))
        .map(|(x, row)| slice.image.get_pixel(x as u32, row as u32).0[3] >= INK_ALPHA)
        .collect();
    let x_scale = metrics.advance as f64 / slice.cell as f64;
    let y_scale = (metrics.ascender as f64 - metrics.descender as f64) / height as f64;
    trace_contours(&mask, width, height).into_iter()
        .map(|contour| {
            let mut points: Vec<(i16, i16)> = Vec::with_capacity(contour.len());
            for (x, y) in contour {
                let point = (((x - slice.left as i64) as f64 * x_scale).round() as i16,
                             (metrics.descender as f64 + y as f64 * y_scale).round() as i16);
                if points.last() != Some(&point) {
                    points.push(point);
                }
            }
            if points.len() > 1 && points.first() == points.last() {
                points.pop();
            }
            points
        })
        .filter(|points| points.len() >= 3)
        .collect()
}

/// hmtx에 적을 왼쪽 여백 — 외곽선의 가장 왼쪽 x. 빈 글리프는 0.
fn left_side_bearing(contours: &[Vec<(i16, i16)>]) -> i16 {
    contours.iter().flatten().map(|point| point.0).min().unwrap_or(0)
}

/// 채운 칸의 경계를 따라 닫힌 윤곽을 만든다 (mask는 y가 위로 증가하는 행 순서).
///
/// 채운 쪽을 늘 오른쪽에 두고 돌므로 바깥 윤곽은 시계 방향, 구멍은 반시계 방향이 된다 —
/// TrueType이 채울 영역을 가르는 규칙과 같다. 대각선으로만 닿은 꼭짓점에서 어느 쪽으로 이어도
/// 변의 집합이 같아 채워지는 영역은 같다.
fn trace_contours(mask: &[bool], width: usize, height: usize) -> Vec<Vec<Point>> {
    let filled = |x: i64, y: i64| x >= 0 && y >= 0 && (x as usize) < width && (y as usize) < height
        && mask[y as usize * width + x as usize];
    let mut edges: BTreeMap<Point, Vec<Point>> = BTreeMap::new();
    for y in 0..height as i64 {
        for x in 0..width as i64 {
            if !filled(x, y) { continue; }
            if !filled(x, y + 1) { edges.entry((x, y + 1)).or_default().push((x + 1, y + 1)); } // 윗변 →
            if !filled(x + 1, y) { edges.entry((x + 1, y + 1)).or_default().push((x + 1, y)); } // 오른변 ↓
            if !filled(x, y - 1) { edges.entry((x + 1, y)).or_default().push((x, y)); }         // 아랫변 ←
            if !filled(x - 1, y) { edges.entry((x, y)).or_default().push((x, y + 1)); }         // 왼변 ↑
        }
    }
    let mut contours = Vec::new();
    while let Some(&start) = edges.keys().next() {
        let mut contour = vec![start];
        let mut current = start;
        loop {
            let ends = edges.get_mut(&current).expect("들어온 변마다 나가는 변이 있다");
            let next = ends.pop().expect("비어 있는 목록은 지운다");
            if ends.is_empty() {
                edges.remove(&current);
            }
            if next == start {
                break;
            }
            contour.push(next);
            current = next;
        }
        let contour = simplify_closed(&drop_collinear(&contour), SIMPLIFY_TOLERANCE);
        if contour.len() >= 3 {
            contours.push(contour);
        }
    }
    contours
}

/// 한 직선 위에 있는 중간 점을 뺀다 (닫힌 윤곽).
fn drop_collinear(contour: &[Point]) -> Vec<Point> {
    let n = contour.len();
    (0..n).filter(|&i| {
        let (a, b, c) = (contour[(i + n - 1) % n], contour[i], contour[(i + 1) % n]);
        (b.0 - a.0) * (c.1 - b.1) - (b.1 - a.1) * (c.0 - b.0) != 0
    }).map(|i| contour[i]).collect()
}

/// 닫힌 윤곽을 Douglas–Peucker로 단순화한다. 곡선을 따라 생긴 계단 점을 줄인다.
fn simplify_closed(contour: &[Point], tolerance: f64) -> Vec<Point> {
    if contour.len() <= 4 {
        return contour.to_vec();
    }
    // 첫 점에서 가장 먼 점을 기준으로 두 갈래로 나눠 각각 단순화한다.
    let first = contour[0];
    let far = (1..contour.len())
        .max_by_key(|&i| (contour[i].0 - first.0).pow(2) + (contour[i].1 - first.1).pow(2))
        .unwrap();
    let mut forward: Vec<Point> = contour[..=far].to_vec();
    let mut backward: Vec<Point> = contour[far..].to_vec();
    backward.push(first);
    forward = simplify_open(&forward, tolerance);
    backward = simplify_open(&backward, tolerance);
    forward.pop();       // 기준점(far)은 뒤쪽 갈래가 갖는다
    backward.pop();      // 첫 점은 앞쪽 갈래가 갖는다
    forward.extend(backward);
    forward
}

fn simplify_open(points: &[Point], tolerance: f64) -> Vec<Point> {
    if points.len() <= 2 {
        return points.to_vec();
    }
    let (a, b) = (points[0], points[points.len() - 1]);
    let (dx, dy) = ((b.0 - a.0) as f64, (b.1 - a.1) as f64);
    let length = (dx * dx + dy * dy).sqrt();
    let distance = |p: &Point| {
        if length == 0.0 {
            (((p.0 - a.0).pow(2) + (p.1 - a.1).pow(2)) as f64).sqrt()
        } else {
            ((p.0 - a.0) as f64 * dy - (p.1 - a.1) as f64 * dx).abs() / length
        }
    };
    let (index, farthest) = points[1..points.len() - 1].iter().enumerate()
        .map(|(i, p)| (i + 1, distance(p)))
        .fold((0, 0.0), |best, item| if item.1 > best.1 { item } else { best });
    if farthest <= tolerance {
        return vec![a, b];
    }
    let mut left = simplify_open(&points[..=index], tolerance);
    let right = simplify_open(&points[index..], tolerance);
    left.pop();
    left.extend(right);
    left
}

/// 윤곽들을 TrueType 단순 글리프 레코드로 직렬화한다. 윤곽이 없으면 빈 글리프(길이 0)다.
fn encode_simple_glyph(contours: &[Vec<(i16, i16)>]) -> Vec<u8> {
    if contours.is_empty() {
        return Vec::new();
    }
    const ON_CURVE: u8 = 0x01;
    const X_SHORT: u8 = 0x02;
    const Y_SHORT: u8 = 0x04;
    const X_SAME_OR_POSITIVE: u8 = 0x10;
    const Y_SAME_OR_POSITIVE: u8 = 0x20;

    let points = || contours.iter().flatten();
    let x_min = points().map(|p| p.0).min().unwrap();
    let x_max = points().map(|p| p.0).max().unwrap();
    let y_min = points().map(|p| p.1).min().unwrap();
    let y_max = points().map(|p| p.1).max().unwrap();

    let mut record = Vec::new();
    for value in [contours.len() as i16, x_min, y_min, x_max, y_max] {
        record.extend_from_slice(&value.to_be_bytes());
    }
    let mut end = 0usize;
    for contour in contours {
        end += contour.len();
        record.extend_from_slice(&((end - 1) as u16).to_be_bytes());
    }
    record.extend_from_slice(&0u16.to_be_bytes());          // instructionLength

    let (mut flags, mut xs, mut ys) = (Vec::new(), Vec::new(), Vec::new());
    let mut previous = (0i32, 0i32);
    for &(x, y) in points() {
        let (dx, dy) = (x as i32 - previous.0, y as i32 - previous.1);
        let mut flag = ON_CURVE;
        for (delta, short, same, bytes) in [(dx, X_SHORT, X_SAME_OR_POSITIVE, &mut xs),
                                            (dy, Y_SHORT, Y_SAME_OR_POSITIVE, &mut ys)] {
            if delta == 0 {
                flag |= same;
            } else if delta.abs() < 256 {
                flag |= short | if delta > 0 { same } else { 0 };
                bytes.push(delta.unsigned_abs() as u8);
            } else {
                bytes.extend_from_slice(&(delta as i16).to_be_bytes());
            }
        }
        flags.push(flag);
        previous = (x as i32, y as i32);
    }
    record.extend(flags);
    record.extend(xs);
    record.extend(ys);
    if record.len() % 2 == 1 { record.push(0); }
    record
}

fn open_font(data: &[u8]) -> Result<FontRef<'_>> {
    match CollectionRef::new(data) {
        Ok(collection) => collection.get(0)
            .map_err(|error| anyhow!("폰트 컬렉션의 첫 폰트를 읽지 못했다: {error}")),
        Err(_) => Ok(FontRef::new(data)?),
    }
}

fn table<'a>(font: &FontRef<'a>, tag: &[u8; 4]) -> Result<&'a [u8]> {
    font.table_data(Tag::new(tag)).map(|data| data.as_bytes())
        .ok_or_else(|| anyhow!("{} 테이블이 없다", String::from_utf8_lossy(tag)))
}

fn read_metrics(font: &FontRef) -> Result<Metrics> {
    let hhea = table(font, b"hhea")?;
    let hmtx = table(font, b"hmtx")?;
    let count = u16::from_be_bytes([hhea[34], hhea[35]]).max(1) as usize;
    let last = (count - 1) * 4;
    Ok(Metrics {
        units_per_em: font.head()?.units_per_em(),
        advance: u16::from_be_bytes([hmtx[last], hmtx[last + 1]]),
        ascender: i16::from_be_bytes([hhea[4], hhea[5]]),
        descender: i16::from_be_bytes([hhea[6], hhea[7]]),
    })
}

/// 기존 glyf 뒤에 글리프 레코드들을 붙이고, 새 glyf와 long 형식 loca를 돌려준다.
/// short 형식은 오프셋/2를 u16에 담아 커진 glyf를 못 가리킬 수 있으므로 항상 long으로 쓴다.
fn append_glyphs(glyf: &[u8], loca: &[u8], long_format: bool,
                 records: &[&[u8]]) -> Result<(Vec<u8>, Vec<u8>)> {
    let mut offsets: Vec<u32> = if long_format {
        loca.chunks_exact(4).map(|c| u32::from_be_bytes([c[0], c[1], c[2], c[3]])).collect()
    } else {
        loca.chunks_exact(2).map(|c| u16::from_be_bytes([c[0], c[1]]) as u32 * 2).collect()
    };
    let end = *offsets.last().ok_or_else(|| anyhow!("loca 테이블이 비었다"))? as usize;
    let mut extended = glyf.get(..end)
        .ok_or_else(|| anyhow!("loca가 glyf 끝({})을 넘어선다 ({end})", glyf.len()))?.to_vec();
    for record in records {
        extended.extend_from_slice(record);
        offsets.push(extended.len() as u32);
    }
    let loca = offsets.iter().flat_map(|offset| offset.to_be_bytes()).collect();
    Ok((extended, loca))
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

/// name 테이블을 표준 인코딩(Windows/Unicode BMP)으로 새로 만든다. 이름마다 판 번호가 들어간다.
///
/// 원본 레코드를 옮겨 담으면 폰트에 따라 write-fonts가 모르는 인코딩이 섞여 패닉한다
/// (D2Coding이 그랬다). 폰트가 요구하는 최소 이름만 새로 쓰는 쪽이 안전하다.
fn build_name_table(version: &str) -> write_fonts::tables::name::Name {
    use write_fonts::tables::name::{Name, NameRecord};
    use write_fonts::types::NameId;

    const WINDOWS: u16 = 3;
    const UNICODE_BMP: u16 = 1;
    const ENGLISH_US: u16 = 0x0409;

    let family = family_name(version);
    let entries = [
        (1u16, family.clone()),
        (2, "Regular".to_string()),
        (3, format!("{family}; generated by oh-my-terminal")),
        (4, format!("{family} Regular")),
        (5, "Version 1.000".to_string()),
        (6, postscript_name(version)),
    ];
    Name::new(entries.into_iter()
        .map(|(id, text)| NameRecord::new(WINDOWS, UNICODE_BMP, ENGLISH_US,
                                          NameId::new(id), text.into()))
        .collect())
}

#[cfg(test)]
#[allow(non_snake_case)]   // 테스트 이름은 동작 서술형 한국어를 쓴다
mod tests {
    use super::*;
    use image::Rgba;

    /// MesloLGS NF의 실제 수치.
    const MESLO: Metrics = Metrics { units_per_em: 2048, advance: 1233, ascender: 2001, descender: -583 };

    /// 윤곽의 부호 있는 넓이 (y가 위로 증가). 시계 방향이면 음수.
    fn signed_area(contour: &[Point]) -> i64 {
        let n = contour.len();
        (0..n).map(|i| {
            let (a, b) = (contour[i], contour[(i + 1) % n]);
            a.0 * b.1 - b.0 * a.1
        }).sum::<i64>()
    }

    fn mask_from(rows: &[&str]) -> (Vec<bool>, usize, usize) {
        // 사람이 읽는 순서(위 행부터)로 받아 y가 위로 증가하는 순서로 뒤집는다.
        let (width, height) = (rows[0].len(), rows.len());
        let mask = rows.iter().rev().flat_map(|row| row.chars().map(|c| c == '#')).collect();
        (mask, width, height)
    }

    #[test]
    fn 폰트_이름은_내용이_같으면_같고_바뀌면_달라진다() {
        // 같은 이름으로 파일만 바꿔 설치하자 실행 중인 iTerm2가 옛 폰트를 계속 썼다.
        assert_eq!(content_version(b"logo-a"), content_version(b"logo-a"), "빌드가 결정적이지 않다");
        assert_ne!(content_version(b"logo-a"), content_version(b"logo-b"), "내용이 바뀌었는데 이름이 같다");
        let version = content_version(b"logo-a");
        assert_eq!(version.len(), PLACEHOLDER_VERSION.len(), "자리표시와 길이가 달라 이름 칸 크기가 바뀐다");
        assert_eq!(postscript_name(&version), format!("OhMyTerminalBrand-{version}"));
        assert!(!postscript_name(&version).contains(' '), "PostScript 이름에는 공백을 못 쓴다");
    }

    #[test]
    fn 채운_영역의_바깥_윤곽은_시계_방향이고_구멍은_반시계_방향이다() {
        // TrueType은 방향으로 구멍을 가른다. 방향이 틀리면 로고의 파낸 글자(배민)가 메워진다.
        let (mask, width, height) = mask_from(&[
            ".....",
            ".###.",
            ".#.#.",
            ".###.",
            ".....",
        ]);
        let contours = trace_contours(&mask, width, height);
        assert_eq!(contours.len(), 2, "바깥 윤곽과 구멍 윤곽 두 개여야 한다: {contours:?}");
        let areas: Vec<i64> = contours.iter().map(|c| signed_area(c)).collect();
        assert!(areas.iter().any(|a| *a == -18), "바깥(3×3, 시계 방향)이 없다: {areas:?}");
        assert!(areas.iter().any(|a| *a == 2), "구멍(1×1, 반시계 방향)이 없다: {areas:?}");
        assert!(contours.iter().all(|c| c.len() == 4), "직선 위 중간 점이 남았다: {contours:?}");
    }

    #[test]
    fn 계단진_대각선은_단순화해_점을_줄인다() {
        let rows: Vec<String> = (0..12).map(|y| (0..12).map(|x| if x <= y { '#' } else { '.' }).collect()).collect();
        let rows: Vec<&str> = rows.iter().map(String::as_str).collect();
        let (mask, width, height) = mask_from(&rows);
        let contours = trace_contours(&mask, width, height);
        assert_eq!(contours.len(), 1);
        assert!(contours[0].len() <= 6, "계단 점이 그대로 남았다: {}개", contours[0].len());
    }

    #[test]
    fn 외곽선_글리프는_윤곽과_점을_그대로_담는다() {
        let square = vec![(0i16, -583i16), (0, 2001), (1233, 2001), (1233, -583)];
        let record = encode_simple_glyph(&[square]);
        let word = |offset: usize| i16::from_be_bytes([record[offset], record[offset + 1]]);
        assert_eq!([word(0), word(2), word(4), word(6), word(8)], [1, 0, -583, 1233, 2001],
                   "윤곽 수와 영역");
        assert_eq!(word(10), 3, "마지막 점 번호");
        assert!(encode_simple_glyph(&[]).is_empty(), "빈 조각은 길이 0 글리프여야 한다");
    }

    #[test]
    fn 왼쪽_여백은_조각마다_외곽선의_실제_왼쪽_끝이다() {
        // 렌더러는 외곽선의 xMin을 hmtx의 lsb에 맞춰 옮긴다. 전부 0을 적자 잉크가 칸 중간에서
        // 시작하는 조각은 왼쪽으로 끌려오고, 겹쳐 자른 조각은 오른쪽으로 밀려 로고가 갈라졌다.
        let (cell, line) = (MESLO.cell_pixels(), MESLO.line_pixels());
        let mut canvas = RgbaImage::new(2 * cell, line);
        for y in MARGIN_Y..line - MARGIN_Y {
            for x in 30..2 * cell - 20 {
                canvas.put_pixel(x, y, Rgba([0, 0, 0, 255]));
            }
        }
        let slices = slice_cells(&canvas, cell);
        let first = slice_contours(&slices[0], &MESLO);
        let second = slice_contours(&slices[1], &MESLO);
        assert!(left_side_bearing(&first) > 0, "잉크가 칸 중간에서 시작하는데 lsb가 0 이하다");
        assert!(left_side_bearing(&second) < 0, "겹쳐 자른 조각의 lsb가 음수가 아니다");
        assert_eq!(left_side_bearing(&[]), 0, "빈 조각은 0");
    }

    #[test]
    fn 칸을_가득_채운_로고는_조각이_칸_경계를_넘어_이웃과_겹친다() {
        let (cell, line) = (MESLO.cell_pixels(), MESLO.line_pixels());
        let canvas = RgbaImage::from_pixel(3 * cell, line, Rgba([0, 0, 0, 255]));
        let slices = slice_cells(&canvas, cell);
        assert_eq!(slices.len(), 3);
        let middle = slice_contours(&slices[1], &MESLO);
        assert_eq!(middle.len(), 1);
        let xs: Vec<i16> = middle[0].iter().map(|p| p.0).collect();
        assert!(*xs.iter().min().unwrap() < 0 && *xs.iter().max().unwrap() > MESLO.advance as i16,
                "가운데 조각이 양옆 칸으로 겹치지 않는다: {xs:?}");
        let first = slice_contours(&slices[0], &MESLO);
        assert_eq!(first[0].iter().map(|p| p.0).min(), Some(0), "첫 조각은 캔버스 밖으로 나가면 안 된다");
    }

    #[test]
    fn 로고_조각의_외곽선은_줄_박스_안에_로고가_있는_자리에_놓인다() {
        // 비트맵(sbix)은 iTerm2의 레티나 텍스트 행렬에서 절반 크기로 줄 아래쪽에 붙었다.
        // 외곽선은 폰트 단위 좌표라 캔버스의 위아래 여백이 그대로 줄 박스 안의 위치가 된다.
        let (cell, line) = (MESLO.cell_pixels(), MESLO.line_pixels());
        let mut canvas = RgbaImage::new(2 * cell, line);
        for y in MARGIN_Y..line - MARGIN_Y {
            for x in 10..2 * cell - 10 {
                canvas.put_pixel(x, y, Rgba([0, 0, 0, 255]));
            }
        }
        let contours = slice_contours(&slice_cells(&canvas, cell)[0], &MESLO);
        assert_eq!(contours.len(), 1);
        let ys: Vec<i16> = contours[0].iter().map(|p| p.1).collect();
        let (low, high) = (*ys.iter().min().unwrap() as f64, *ys.iter().max().unwrap() as f64);
        let middle = (MESLO.ascender as f64 + MESLO.descender as f64) / 2.0;
        assert!(((low + high) / 2.0 - middle).abs() < 20.0, "로고가 줄 박스 가운데에 없다: {low}~{high}");
        assert!(low > MESLO.descender as f64 && high < MESLO.ascender as f64, "줄 박스를 벗어났다");
    }

    #[test]
    fn 글리프를_붙이면_loca가_long_형식으로_새_글리프를_가리킨다() {
        // short 형식(오프셋/2): 글리프 0은 0..4, 글리프 1은 빈 글리프
        let glyf = [9u8; 4];
        let short_loca = [0u8, 0, 0, 2, 0, 2];
        let first = vec![7u8; 6];
        let last = vec![5u8; 2];
        let records: Vec<&[u8]> = vec![&first, &[], &last];
        let (extended, loca) = append_glyphs(&glyf, &short_loca, false, &records).unwrap();
        let offsets: Vec<u32> = loca.chunks_exact(4)
            .map(|c| u32::from_be_bytes([c[0], c[1], c[2], c[3]])).collect();
        assert_eq!(offsets, [0, 4, 4, 10, 10, 12]);
        assert_eq!(&extended[4..10], &first[..]);
    }

    #[test]
    fn 긴_워드마크는_칸을_더_써서_줄_높이를_살린다() {
        // NOL처럼 가로로 긴 로고를 한 칸 정사각형에 넣자 글자 높이가 화면에서 10px 남짓이었다.
        let (cell, line) = (MESLO.cell_pixels(), MESLO.line_pixels());
        let square = RgbaImage::from_pixel(100, 100, Rgba([255, 255, 255, 255]));
        let wordmark = RgbaImage::from_pixel(300, 100, Rgba([255, 255, 255, 255]));

        let square_canvas = logo_canvas(&square, Some([0, 0, 0]), &MESLO);
        assert_eq!(square_canvas.dimensions(), (2 * cell, line), "정사각형 로고는 2칸");

        let wordmark_canvas = logo_canvas(&wordmark, Some([0, 0, 0]), &MESLO);
        assert_eq!(wordmark_canvas.width(), MAX_CELLS * cell, "긴 워드마크는 최대 칸 수");
        assert_eq!(slice_cells(&wordmark_canvas, cell).len(), MAX_CELLS as usize);
        let inked_rows = (0..line)
            .filter(|&y| (0..wordmark_canvas.width()).any(|x| wordmark_canvas.get_pixel(x, y).0[3] > 0))
            .count() as u32;
        assert!(inked_rows * 2 > line - 2 * MARGIN_Y, "워드마크가 줄 높이의 절반도 못 쓴다: {inked_rows}px");
    }
}
