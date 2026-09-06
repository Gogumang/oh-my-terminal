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

pub fn run(root: &Path, base_font: &Path) -> Result<Report> {
    let catalog = YamlBrandCatalog::new(root.join("brands"), root.join("logos"));
    let mut repository = LogoRepository::new(root.join("logos"));

    let mut brands = catalog.load()?;
    // 로고 파일은 상표라 저장소에 커밋하지 않는다 — 없으면 출처에서 받아 재현한다.
    let missing: Vec<Brand> = brands.iter().filter(|b| b.logo_path.is_none()).cloned().collect();
    if !missing.is_empty() {
        for brand in &missing {
            repository.prepare(brand);
        }
        brands = catalog.load()?;
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
        &brands, artifact.as_ref().map(|_| font_writer::POSTSCRIPT), root)?;

    let mut outputs = vec![prompt];
    if let Some(artifact) = &artifact { outputs.push(artifact.path.clone()); }
    outputs.push(profiles);
    Ok(Report { brands: reports, warnings, outputs })
}
