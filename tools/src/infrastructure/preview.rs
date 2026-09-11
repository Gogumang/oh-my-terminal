//! 로고가 프롬프트에서 어떻게 보일지 그림으로 뽑는다 (build-themes preview).
//!
//! 폰트에 굽는 것과 같은 캔버스를 띠 색 위에 얹어 레티나 13pt 크기로 줄인다. iTerm2 GPU
//! 렌더러는 로고를 알파만 써서 그 칸의 글자색으로 칠하는데, 셸이 로고 칸에 쓰는 색이
//! 캔버스에 칠한 로고 색과 같으므로 이 그림이 화면과 같다.

use std::path::{Path, PathBuf};

use anyhow::{anyhow, Result};
use image::{imageops, Rgba, RgbaImage};

use crate::domain::brand::Brand;
use crate::domain::palette;
use crate::infrastructure::brand_catalog::YamlBrandCatalog;
use crate::infrastructure::font_writer::{self, Metrics, CANVAS_PPEM, SCREEN_EM_PIXELS};

/// 확대본 배율. 실제 크기 옆에서 뭉개진 곳을 찾기 쉽게 한다.
const ZOOM: u32 = 4;

/// 회사마다 build/preview/<키>.png 를 만들고 경로를 돌려준다.
pub fn write(root: &Path, base_font: &Path, keys: &[String]) -> Result<Vec<PathBuf>> {
    let metrics = font_writer::metrics_of(base_font)?;
    let brands = YamlBrandCatalog::new(root.join("brands"), root.join("public/logo")).load()?;
    let directory = root.join("build/preview");
    std::fs::create_dir_all(&directory)?;
    let mut outputs = Vec::new();
    for key in keys {
        let brand = brands.iter().find(|brand| &brand.key == key)
            .ok_or_else(|| anyhow!("켜진 회사가 아니다: {key}"))?;
        let path = brand.logo_path.as_ref()
            .ok_or_else(|| anyhow!("{key}: public/logo/{key}.png 이 없다"))?;
        let logo = image::open(path)?.to_rgba8();
        let output = directory.join(format!("{key}.png"));
        render(&logo, brand, &metrics).save(&output)?;
        outputs.push(output);
    }
    Ok(outputs)
}

/// 위: 실제 크기 띠 / 아래: 같은 띠 4배 확대 / 오른쪽: 원본 로고(흰 바탕).
fn render(logo: &RgbaImage, brand: &Brand, metrics: &Metrics) -> RgbaImage {
    let colour = font_writer::rgb8(palette::logo_colour(brand));
    let canvas = font_writer::logo_canvas(logo, Some(colour), metrics);
    let band = font_writer::rgb8(palette::gradient(brand).start);
    // 로고 칸 뒤로 경로가 이어질 두 칸도 띠 색으로 둔다.
    let mut line = RgbaImage::from_pixel(canvas.width() + 2 * metrics.cell_pixels(), canvas.height(),
                                         Rgba([band[0], band[1], band[2], 255]));
    imageops::overlay(&mut line, &canvas, 0, 0);

    let scale = SCREEN_EM_PIXELS / CANVAS_PPEM as f64;
    let width = ((line.width() as f64 * scale).round() as u32).max(1);
    let height = ((line.height() as f64 * scale).round() as u32).max(1);
    let screen = imageops::resize(&line, width, height, imageops::FilterType::Lanczos3);
    let zoomed = imageops::resize(&screen, width * ZOOM, height * ZOOM, imageops::FilterType::Nearest);

    let mut original = RgbaImage::from_pixel(160, 160, Rgba([255, 255, 255, 255]));
    imageops::overlay(&mut original, &imageops::resize(logo, 160, 160, imageops::FilterType::Lanczos3), 0, 0);

    let mut sheet = RgbaImage::from_pixel(zoomed.width() + 200, (height + zoomed.height() + 30).max(180),
                                          Rgba([40, 40, 40, 255]));
    imageops::overlay(&mut sheet, &screen, 10, 10);
    imageops::overlay(&mut sheet, &zoomed, 10, (height + 20) as i64);
    imageops::overlay(&mut sheet, &original, (zoomed.width() + 30) as i64, 10);
    sheet
}
