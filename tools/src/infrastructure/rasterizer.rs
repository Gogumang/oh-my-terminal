//! SVG 래스터화 어댑터.
//!
//! resvg를 쓴다. 이전 Python 구현은 macOS `qlmanage`에 셸아웃했는데, Quick Look은
//! 썸네일 생성기라 알파를 버리고 흰 페이지 위에 평탄화한다. 그래서 "배경이 무슨 색이었나"를
//! 되짚어 추정하는 휴리스틱이 필요했고, 로고 획이 네 모서리에 닿는 경우(네이버의 굵은 N)
//! 추정이 뒤집혀 로고가 반전됐다. resvg는 알파를 그대로 보존해 그 문제 자체가 없다.

use anyhow::{anyhow, Result};
use image::RgbaImage;

pub fn rasterize_svg(data: &[u8], size: u32) -> Result<RgbaImage> {
    let options = resvg::usvg::Options::default();
    let tree = resvg::usvg::Tree::from_data(data, &options)?;
    let source = tree.size();
    let scale = size as f32 / source.width().max(source.height());
    let width = (source.width() * scale).ceil().max(1.0) as u32;
    let height = (source.height() * scale).ceil().max(1.0) as u32;

    let mut pixmap = tiny_skia::Pixmap::new(width, height)
        .ok_or_else(|| anyhow!("픽스맵 생성 실패 ({width}x{height})"))?;
    resvg::render(&tree, tiny_skia::Transform::from_scale(scale, scale), &mut pixmap.as_mut());

    // tiny-skia는 프리멀티플라이드 알파를 쓴다 — 그대로 읽으면 반투명 픽셀 색이 어두워진다.
    let mut rgba = RgbaImage::new(width, height);
    for (index, pixel) in pixmap.pixels().iter().enumerate() {
        let demultiplied = pixel.demultiply();
        rgba.put_pixel((index as u32) % width, (index as u32) / width,
                       image::Rgba([demultiplied.red(), demultiplied.green(),
                                    demultiplied.blue(), demultiplied.alpha()]));
    }
    Ok(rgba)
}
