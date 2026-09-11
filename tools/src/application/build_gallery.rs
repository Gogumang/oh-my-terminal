//! README 지원 테마 갱신 유스케이스 — 회사마다 프롬프트 그림을 그리고 README 목록을 다시 쓴다.

use std::path::{Path, PathBuf};

use anyhow::Result;

use crate::infrastructure::{brand_catalog::YamlBrandCatalog, readme_gallery, theme_gallery};

/// README 기준 그림 폴더.
const IMAGE_DIRECTORY: &str = "docs/themes";

pub struct Report {
    pub images: usize,
    pub outputs: Vec<PathBuf>,
}

pub fn run(root: &Path, base_font: &Path) -> Result<Report> {
    // 커밋된 원본 로고를 쓴다 — 폰트에 굽는 캔버스와 같은 입력이다 (preview 명령과 같음).
    let brands = YamlBrandCatalog::new(root.join("brands"), root.join("public/logo")).load()?;
    let gallery = theme_gallery::write(base_font, &brands, &root.join(IMAGE_DIRECTORY))?;

    let display_height = gallery.height / theme_gallery::DISPLAY_SCALE;
    let section = readme_gallery::section(&brands, IMAGE_DIRECTORY, display_height)?;
    let readme = root.join("README.md");
    let updated = readme_gallery::replace_section(&std::fs::read_to_string(&readme)?, &section)?;
    std::fs::write(&readme, updated)?;

    Ok(Report { images: gallery.images.len(), outputs: vec![root.join(IMAGE_DIRECTORY), readme] })
}
