//! README 지원 테마 표에 넣을 프롬프트 그림 (build-themes gallery).
//!
//! 회사 이름만 늘어놓으면 어떤 테마인지 알 수 없어, 각 프로필에서 `~/workspace` 폴더에 있을 때의
//! 경로 세그먼트를 그린다. 칸 색은 셸과 같은 계산(palette::segment_cells), 글자는 브랜드 폰트의
//! 기반인 MesloLGS NF 외곽선, 로고는 폰트에 굽는 것과 같은 캔버스를 쓰므로 화면과 같다.

use std::path::{Path, PathBuf};

use anyhow::{anyhow, Result};
use image::{imageops, Rgba, RgbaImage};
use tiny_skia::{FillRule, Paint, PathBuilder, Pixmap, Rect, Transform};

use crate::domain::brand::Brand;
use crate::domain::palette;
use crate::infrastructure::font_writer::{self, Metrics, CANVAS_PPEM};

/// 그림에 찍을 경로. 모든 회사가 같은 길이여야 표에서 그림 크기가 고르게 맞는다.
pub const SAMPLE_PATH: &str = "~/workspace";
/// 출력 그림의 em 픽셀 수. README에서 절반 크기로 보여 레티나 화면에서 선명하다.
const OUTPUT_EM_PIXELS: f64 = 40.0;
/// README가 그림을 줄여 보여주는 배율.
pub const DISPLAY_SCALE: u32 = 2;
/// 세그먼트 둘레의 터미널 배경 여백 (칸·줄 높이 대비).
const PADDING_CELLS: f64 = 0.5;
const PADDING_LINES: f64 = 0.2;
/// 모서리 반경 (출력 픽셀).
const CORNER_RADIUS: f64 = 8.0;
const TERMINAL_BACKGROUND: [u8; 3] = [0, 0, 0];
/// 팔레트 색 수와 NeuQuant 표본 간격 (1이 모든 픽셀을 보는 최고 품질). 그림이 작아 느리지 않다.
const PALETTE_SIZE: usize = 256;
const QUANTIZER_SAMPLING: i32 = 1;

pub struct Gallery {
    pub images: Vec<PathBuf>,
    /// 모든 그림에 공통인 높이 (출력 픽셀).
    pub height: u32,
}

/// 회사마다 `<directory>/<키>.png`를 만든다. 목록에서 빠진 회사의 옛 그림은 지운다.
pub fn write(base_font: &Path, brands: &[Brand], directory: &Path) -> Result<Gallery> {
    let data = std::fs::read(base_font)?;
    let face = ttf_parser::Face::parse(&data, 0)
        .map_err(|error| anyhow!("기반 폰트를 읽지 못했다 ({}): {error}", base_font.display()))?;
    let metrics = font_writer::metrics_of(base_font)?;
    std::fs::create_dir_all(directory)?;

    let mut images = Vec::new();
    let mut height = 0;
    for brand in brands {
        let logo = brand.logo_path.as_ref().map(image::open).transpose()?.map(|logo| logo.to_rgba8());
        let picture = render(brand, logo.as_ref(), &face, &metrics)?;
        height = picture.height();
        let output = directory.join(format!("{}.png", brand.key));
        save_indexed(&picture, &output)?;
        images.push(output);
    }
    remove_stale(directory, &images)?;
    Ok(Gallery { images, height })
}

/// 256색 팔레트 PNG로 저장한다. 그림은 칸 색 몇십 개와 글자 가장자리 중간색뿐이라 줄여도 눈에
/// 띄지 않고, RGBA로 두면 279장이 4.7MB라 README를 열 때마다 그만큼 받는다.
/// NeuQuant는 난수를 쓰지 않아 같은 입력이면 같은 파일이 나온다 — 다시 만들어도 diff가 없다.
fn save_indexed(picture: &RgbaImage, path: &Path) -> Result<()> {
    let quantizer = color_quant::NeuQuant::new(QUANTIZER_SAMPLING, PALETTE_SIZE, picture.as_raw());
    let map = quantizer.color_map_rgba();
    let palette: Vec<u8> = map.chunks_exact(4).flat_map(|rgba| rgba[..3].to_vec()).collect();
    let alpha: Vec<u8> = map.chunks_exact(4).map(|rgba| rgba[3]).collect();
    let indices: Vec<u8> = picture.pixels().map(|pixel| quantizer.index_of(&pixel.0) as u8).collect();

    let file = std::io::BufWriter::new(std::fs::File::create(path)?);
    let mut encoder = png::Encoder::new(file, picture.width(), picture.height());
    encoder.set_color(png::ColorType::Indexed);
    encoder.set_depth(png::BitDepth::Eight);
    encoder.set_palette(palette);
    encoder.set_trns(alpha);
    encoder.set_compression(png::Compression::High);
    encoder.write_header()?.write_image_data(&indices)?;
    Ok(())
}

fn remove_stale(directory: &Path, current: &[PathBuf]) -> Result<()> {
    for entry in std::fs::read_dir(directory)? {
        let path = entry?.path();
        if path.extension().is_some_and(|extension| extension == "png") && !current.contains(&path) {
            std::fs::remove_file(path)?;
        }
    }
    Ok(())
}

/// ` 로고 ~/workspace ` 세그먼트와 뒤따르는 powerline 화살표를 검정 배경 위에 그린다.
fn render(brand: &Brand, logo: Option<&RgbaImage>, face: &ttf_parser::Face,
          metrics: &Metrics) -> Result<RgbaImage> {
    let (cell, line) = (metrics.cell_pixels(), metrics.line_pixels());
    let logo_canvas = logo.map(|logo| {
        font_writer::logo_canvas(logo, Some(font_writer::rgb8(palette::logo_colour(brand))), metrics)
    });
    let logo_cells = logo_canvas.as_ref().map_or(0, |canvas| canvas.width() / cell) as usize;
    // 셸과 같은 구성: 왼쪽 여백 한 칸, 로고가 있으면 로고 칸과 그 뒤 한 칸.
    let lead = if logo_cells > 0 { logo_cells + 2 } else { 1 };
    let path: Vec<char> = SAMPLE_PATH.chars().collect();
    let cells = palette::segment_cells(palette::segment_colours(brand), lead, lead + path.len());
    let end = cells.last().map(|last| last.background).unwrap_or(TERMINAL_BACKGROUND);

    let (pad_x, pad_y) = ((cell as f64 * PADDING_CELLS) as u32, (line as f64 * PADDING_LINES) as u32);
    // 세그먼트 칸 + p10k가 끝색으로 칠하는 오른쪽 여백 한 칸 + 화살표 한 칸.
    let width = pad_x * 2 + cell * (cells.len() as u32 + 2);
    let mut pixmap = Pixmap::new(width, line + pad_y * 2).ok_or_else(|| anyhow!("그림 크기가 0이다"))?;
    pixmap.fill(colour(TERMINAL_BACKGROUND));

    let scale = CANVAS_PPEM as f32 / metrics.units_per_em as f32;
    let baseline = pad_y as f32 + metrics.ascender as f32 * scale;
    for (index, cell_colour) in cells.iter().enumerate() {
        let left = pad_x + cell * index as u32;
        fill_rect(&mut pixmap, left, pad_y, cell, line, cell_colour.background)?;
        if let Some(character) = index.checked_sub(lead).and_then(|offset| path.get(offset)) {
            draw_glyph(&mut pixmap, face, *character, left as f32, baseline, scale, cell_colour.foreground);
        }
    }
    let right = pad_x + cell * cells.len() as u32;
    fill_rect(&mut pixmap, right, pad_y, cell, line, end)?;
    draw_arrow(&mut pixmap, (right + cell) as f32, pad_y as f32, cell as f32, line as f32, end);

    // 모든 칸이 불투명하므로 미리 곱한 알파 그대로 옮겨도 색이 같다.
    let mut picture = RgbaImage::from_raw(pixmap.width(), pixmap.height(), pixmap.take())
        .ok_or_else(|| anyhow!("그림 버퍼 크기가 맞지 않는다"))?;
    if let Some(canvas) = &logo_canvas {
        imageops::overlay(&mut picture, canvas, (pad_x + cell) as i64, pad_y as i64);
    }

    let output_scale = OUTPUT_EM_PIXELS / CANVAS_PPEM as f64;
    let resized = imageops::resize(&picture,
                                   (picture.width() as f64 * output_scale).round() as u32,
                                   (picture.height() as f64 * output_scale).round() as u32,
                                   imageops::FilterType::Lanczos3);
    Ok(round_corners(resized, CORNER_RADIUS))
}

fn colour([red, green, blue]: [u8; 3]) -> tiny_skia::Color {
    tiny_skia::Color::from_rgba8(red, green, blue, 255)
}

fn paint(rgb: [u8; 3]) -> Paint<'static> {
    let mut paint = Paint::default();
    paint.set_color(colour(rgb));
    paint.anti_alias = true;
    paint
}

fn fill_rect(pixmap: &mut Pixmap, left: u32, top: u32, width: u32, height: u32, rgb: [u8; 3]) -> Result<()> {
    let rect = Rect::from_xywh(left as f32, top as f32, width as f32, height as f32)
        .ok_or_else(|| anyhow!("칸 크기가 잘못됐다: {width}×{height}"))?;
    pixmap.fill_rect(rect, &paint(rgb), Transform::identity(), None);
    Ok(())
}

/// iTerm2는 powerline 기호를 폰트 대신 직접 그린다 — 칸 높이를 꽉 채운 삼각형이다.
fn draw_arrow(pixmap: &mut Pixmap, left: f32, top: f32, width: f32, height: f32, rgb: [u8; 3]) {
    let mut builder = PathBuilder::new();
    builder.move_to(left, top);
    builder.line_to(left + width, top + height / 2.0);
    builder.line_to(left, top + height);
    builder.close();
    if let Some(path) = builder.finish() {
        pixmap.fill_path(&path, &paint(rgb), FillRule::Winding, Transform::identity(), None);
    }
}

/// 폰트 단위 외곽선을 캔버스 픽셀로 옮긴다 (폰트는 y가 위로, 그림은 아래로 증가).
struct Outline {
    builder: PathBuilder,
    left: f32,
    baseline: f32,
    scale: f32,
}

impl Outline {
    fn point(&self, x: f32, y: f32) -> (f32, f32) {
        (self.left + x * self.scale, self.baseline - y * self.scale)
    }
}

impl ttf_parser::OutlineBuilder for Outline {
    fn move_to(&mut self, x: f32, y: f32) {
        let (x, y) = self.point(x, y);
        self.builder.move_to(x, y);
    }
    fn line_to(&mut self, x: f32, y: f32) {
        let (x, y) = self.point(x, y);
        self.builder.line_to(x, y);
    }
    fn quad_to(&mut self, x1: f32, y1: f32, x: f32, y: f32) {
        let ((x1, y1), (x, y)) = (self.point(x1, y1), self.point(x, y));
        self.builder.quad_to(x1, y1, x, y);
    }
    fn curve_to(&mut self, x1: f32, y1: f32, x2: f32, y2: f32, x: f32, y: f32) {
        let ((x1, y1), (x2, y2), (x, y)) = (self.point(x1, y1), self.point(x2, y2), self.point(x, y));
        self.builder.cubic_to(x1, y1, x2, y2, x, y);
    }
    fn close(&mut self) {
        self.builder.close();
    }
}

fn draw_glyph(pixmap: &mut Pixmap, face: &ttf_parser::Face, character: char, left: f32,
              baseline: f32, scale: f32, rgb: [u8; 3]) {
    let Some(glyph) = face.glyph_index(character) else { return };
    let mut outline = Outline { builder: PathBuilder::new(), left, baseline, scale };
    if face.outline_glyph(glyph, &mut outline).is_none() {
        return;   // 공백처럼 외곽선이 없는 글자
    }
    if let Some(path) = outline.builder.finish() {
        pixmap.fill_path(&path, &paint(rgb), FillRule::Winding, Transform::identity(), None);
    }
}

/// 네 모서리를 둥글게 깎는다. 경계 픽셀은 원까지의 거리로 알파를 줘 계단이 지지 않게 한다.
fn round_corners(mut picture: RgbaImage, radius: f64) -> RgbaImage {
    let (width, height) = (picture.width() as f64, picture.height() as f64);
    for (x, y, pixel) in picture.enumerate_pixels_mut() {
        let (center_x, center_y) = (x as f64 + 0.5, y as f64 + 0.5);
        let dx = (radius - center_x).max(center_x - (width - radius)).max(0.0);
        let dy = (radius - center_y).max(center_y - (height - radius)).max(0.0);
        if dx == 0.0 || dy == 0.0 {
            continue;
        }
        let coverage = (radius + 0.5 - (dx * dx + dy * dy).sqrt()).clamp(0.0, 1.0);
        let Rgba([_, _, _, alpha]) = pixel;
        *alpha = (*alpha as f64 * coverage).round() as u8;
    }
    picture
}

#[cfg(test)]
#[allow(non_snake_case)]   // 테스트 이름은 동작 서술형 한국어를 쓴다
mod tests {
    use super::*;

    #[test]
    fn 모서리만_투명해지고_가운데와_변은_그대로다() {
        let picture = RgbaImage::from_pixel(40, 20, Rgba([0, 0, 0, 255]));

        let rounded = round_corners(picture, 8.0);

        assert_eq!(rounded.get_pixel(0, 0).0[3], 0, "모서리 끝은 투명해야 한다");
        assert_eq!(rounded.get_pixel(39, 19).0[3], 0, "반대쪽 모서리도 투명해야 한다");
        assert_eq!(rounded.get_pixel(20, 0).0[3], 255, "위쪽 변 가운데는 불투명해야 한다");
        assert_eq!(rounded.get_pixel(20, 10).0[3], 255, "가운데는 불투명해야 한다");
    }
}
