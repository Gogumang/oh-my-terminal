//! 유스케이스 조립. 어댑터를 함수로 받아 도메인 규칙을 적용한다.

use std::path::{Path, PathBuf};

use anyhow::Result;

use crate::domain::brand::Brand;
use crate::domain::palette;
use crate::infrastructure::{brand_catalog::YamlBrandCatalog, font_writer,
                            iterm2_writer, logo_repository::LogoRepository, p10k_writer};

pub struct BrandReport {
    pub name: String,
    pub has_logo: bool,
    pub contrast: f64,
    pub depth: f64,
}

pub struct Report {
    pub brands: Vec<BrandReport>,
    pub warnings: Vec<String>,
    pub outputs: Vec<PathBuf>,
}

/// 로고를 다시 준비해야 하는지. logos/ 에 없거나, 커밋된 원본(public/logo)이 있으면 준비한다.
///
/// logos/ 는 작업물이다. 복사본이 있다고 그대로 쓰자 public/logo 에서 교체한 로고 43개가
/// 폰트에 하나도 반영되지 않았다 — 생성물이 교체 전과 바이트까지 같았다.
fn needs_prepare(brand: &Brand, committed: &Path) -> bool {
    brand.logo_path.is_none() || committed.join(format!("{}.png", brand.key)).exists()
}

pub fn run(root: &Path, base_font: &Path) -> Result<Report> {
    let catalog = YamlBrandCatalog::new(root.join("brands"), root.join("logos"));
    let committed = root.join("public/logo");
    let mut repository = LogoRepository::new(root.join("logos"), &committed);

    let mut brands = catalog.load()?;
    for brand in brands.iter_mut() {
        if needs_prepare(brand, &committed) {
            brand.logo_path = repository.prepare(brand);
        }
    }

    let artifact = font_writer::write_font(base_font, &brands, root)?;
    let glyphs = artifact.as_ref().map(|a| a.glyphs.clone()).unwrap_or_default();

    let mut warnings = repository.notes.clone();
    let mut reports = Vec::new();
    for brand in &brands {
        let gradient = palette::gradient(brand);
        if gradient.lowest_contrast < palette::CONTRAST_ACCENT {
            warnings.push(format!("{}: 그라데이션 구간 최저 대비 {:.1}:1 (목표 {:.1}:1)",
                brand.name, gradient.lowest_contrast, palette::CONTRAST_ACCENT));
        }
        let (base, lifted) = palette::segment_background(brand);
        if lifted {
            warnings.push(format!("{}: 브랜드색이 터미널 배경과 구분되지 않아 들어올림", brand.name));
        }
        let moved = palette::rgb_to_hex(base) != palette::rgb_to_hex(gradient.start);
        if moved {
            warnings.push(format!("{}: 대비 확보를 위해 세그먼트 배경을 {} → {} 로 미세 조정 (색상 보존)",
                brand.name, palette::rgb_to_hex(base), palette::rgb_to_hex(gradient.start)));
        }
        reports.push(BrandReport {
            name: brand.name.clone(),
            has_logo: glyphs.contains_key(&brand.key),
            contrast: gradient.lowest_contrast,
            depth: gradient.depth,
        });
    }

    let prompt = p10k_writer::write_prompt(&brands, &glyphs, root)?;
    let profiles = iterm2_writer::write_profiles(
        &brands, artifact.as_ref().map(|a| a.postscript.as_str()), root)?;

    let mut outputs = vec![prompt];
    if let Some(artifact) = &artifact { outputs.push(artifact.path.clone()); }
    outputs.push(profiles);
    Ok(Report { brands: reports, warnings, outputs })
}

#[cfg(test)]
#[allow(non_snake_case)]   // 테스트 이름은 동작 서술형 한국어를 쓴다
mod tests {
    use super::*;

    fn brand(key: &str, logo_path: Option<PathBuf>) -> Brand {
        Brand { key: key.into(), name: key.into(), primary: "#0064FF".into(),
                secondary: "#0064FF".into(), logo: None, verified: None, logo_path }
    }

    #[test]
    fn 커밋된_로고가_있으면_작업_폴더에_복사본이_있어도_다시_가져온다() {
        let root = std::env::temp_dir()
            .join(format!("oh-my-terminal-prepare-{}", std::process::id()));
        let committed = root.join("public/logo");
        std::fs::create_dir_all(&committed).unwrap();
        std::fs::write(committed.join("replaced.png"), b"png").unwrap();
        let stale_copy = Some(root.join("logos/replaced.png"));
        let downloaded = Some(root.join("logos/downloaded.png"));

        let decisions = [needs_prepare(&brand("replaced", stale_copy), &committed),
                         needs_prepare(&brand("downloaded", downloaded), &committed),
                         needs_prepare(&brand("missing", None), &committed)];
        let _ = std::fs::remove_dir_all(&root);
        // 커밋된 원본은 늘 새로, 원격에서 받아 둔 작업물은 그대로, 없는 것은 준비한다.
        assert_eq!(decisions, [true, false, true]);
    }
}
