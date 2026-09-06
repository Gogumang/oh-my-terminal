//! 내려받은 이미지를 프롬프트 글리프로 쓸 수 있는 형태로 다듬는다.
//!
//! 로고는 두 갈래다:
//!   - 실루엣: 형태(알파)만 남기고 세그먼트 배경에 맞춰 색을 입힌다. 대부분의 로고.
//!   - 원본 컬러: 색 면에서 글자를 파낸 앱 아이콘(배민·쿠팡·NOL). 실루엣으로 만들면
//!     통짜 동그라미/네모가 되어 알아볼 수 없다.

use image::{imageops, Rgba, RgbaImage};

const BACKGROUND_TOLERANCE: i32 = 28;
const CORNER_TOLERANCE: i32 = 32;
const FAINT_ALPHA: u8 = 30;

pub fn alpha_coverage(image: &RgbaImage) -> f64 {
    let opaque = image.pixels().filter(|p| p.0[3] > FAINT_ALPHA).count();
    opaque as f64 / (image.width() * image.height()) as f64
}

/// 비율을 유지하며 정사각형에 꽉 차게 맞춘다 (축소·확대 모두).
/// 축소만 하면 16x16 파비콘이 캔버스 한가운데 점으로 남는다.
pub fn fit(image: &RgbaImage, size: u32) -> RgbaImage {
    let scale = size as f64 / image.width().max(image.height()) as f64;
    let width = ((image.width() as f64 * scale).round() as u32).max(1);
    let height = ((image.height() as f64 * scale).round() as u32).max(1);
    let resized = imageops::resize(image, width, height, imageops::FilterType::Lanczos3);
    let mut canvas = RgbaImage::new(size, size);
    imageops::overlay(&mut canvas, &resized,
                      ((size - width) / 2) as i64, ((size - height) / 2) as i64);
    canvas
}

/// 투명 여백을 잘라낸다. 안 자르면 글리프 칸에서 로고가 작아진다.
pub fn crop_to_content(image: &RgbaImage) -> RgbaImage {
    let (mut left, mut top) = (image.width(), image.height());
    let (mut right, mut bottom) = (0u32, 0u32);
    let mut found = false;
    for (x, y, pixel) in image.enumerate_pixels() {
        if pixel.0[3] > 12 {
            found = true;
            left = left.min(x); right = right.max(x);
            top = top.min(y); bottom = bottom.max(y);
        }
    }
    if !found { return image.clone(); }
    imageops::crop_imm(image, left, top, right - left + 1, bottom - top + 1).to_image()
}

/// 색을 버리고 형태(알파)만 남긴다.
pub fn to_silhouette(image: &RgbaImage) -> RgbaImage {
    let mut result = RgbaImage::new(image.width(), image.height());
    for (x, y, pixel) in image.enumerate_pixels() {
        result.put_pixel(x, y, Rgba([255, 255, 255, pixel.0[3]]));
    }
    result
}

fn corners(image: &RgbaImage) -> [Rgba<u8>; 4] {
    let (w, h) = (image.width(), image.height());
    [*image.get_pixel(1, 1), *image.get_pixel(w - 2, 1),
     *image.get_pixel(1, h - 2), *image.get_pixel(w - 2, h - 2)]
}

/// 네 모서리가 같은 불투명 색이면 그 색을 배경으로 보고 지운다.
///
/// 주의: 알파가 이미 정확한 이미지에는 쓰면 안 된다. 로고 획이 네 모서리에 닿으면
/// (네이버 N) 로고 자체를 배경으로 오인해 통째로 지운다.
pub fn strip_uniform_background(image: &RgbaImage) -> RgbaImage {
    let marks = corners(image);
    if marks.iter().any(|p| p.0[3] < 200) {
        return image.clone();
    }
    let first = [marks[0].0[0], marks[0].0[1], marks[0].0[2]];
    if marks.iter().any(|p| [p.0[0], p.0[1], p.0[2]] != first) {
        return image.clone();
    }
    let mut result = image.clone();
    for pixel in result.pixels_mut() {
        let distance = (0..3).map(|i| (pixel.0[i] as i32 - first[i] as i32).abs())
            .max().unwrap_or(0);
        if distance < BACKGROUND_TOLERANCE {
            pixel.0[3] = 0;
        }
    }
    result
}

fn flood_clear(mask: &mut Vec<bool>, width: u32, height: u32, start: (u32, u32),
               keep: &dyn Fn(u32, u32) -> bool) {
    let index = |x: u32, y: u32| (y * width + x) as usize;
    if !mask[index(start.0, start.1)] { return; }
    let mut stack = vec![start];
    while let Some((x, y)) = stack.pop() {
        if !mask[index(x, y)] || !keep(x, y) { continue; }
        mask[index(x, y)] = false;
        if x > 0 { stack.push((x - 1, y)); }
        if y > 0 { stack.push((x, y - 1)); }
        if x + 1 < width { stack.push((x + 1, y)); }
        if y + 1 < height { stack.push((x, y + 1)); }
    }
}

/// 네 모서리에 '연결된' 밝은 배경만 지운다.
///
/// JPEG 앱 아이콘은 알파가 없어 둥근 모서리 바깥이 흰색으로 남는다(배민이 그랬다).
/// 흰색을 전부 지우면 로고 안쪽 흰 글자까지 사라지므로 모서리에서만 번져 나가며 지운다.
pub fn clear_corner_background(image: &RgbaImage) -> RgbaImage {
    let (width, height) = (image.width(), image.height());
    let bright = |x: u32, y: u32| {
        let p = image.get_pixel(x, y).0;
        let luma = (p[0] as i32 * 299 + p[1] as i32 * 587 + p[2] as i32 * 114) / 1000;
        luma > 255 - CORNER_TOLERANCE
    };
    let mut mask: Vec<bool> = (0..width * height)
        .map(|i| bright(i % width, i / width)).collect();
    for corner in [(0, 0), (width - 1, 0), (0, height - 1), (width - 1, height - 1)] {
        flood_clear(&mut mask, width, height, corner, &bright);
    }
    let mut result = image.clone();
    for (x, y, pixel) in result.enumerate_pixels_mut() {
        // flood_clear가 지운(=false) 밝은 픽셀만 투명하게 만든다.
        if bright(x, y) && !mask[(y * width + x) as usize] {
            pixel.0[3] = 0;
        }
    }
    result
}

/// 파낸 글자만 남긴다.
///
/// 단순히 뒤집으면 로고 '바깥'까지 불투명해져 테두리 프레임이 생긴다. 뒤집은 뒤
/// 가장자리에서 번져 나가며 바깥을 지워야 안쪽 구멍 = 실제 글자만 남는다.
pub fn invert_alpha(image: &RgbaImage) -> RgbaImage {
    let (width, height) = (image.width(), image.height());
    let opaque = |x: u32, y: u32| 255 - image.get_pixel(x, y).0[3] > 128;
    let mut mask: Vec<bool> = (0..width * height)
        .map(|i| opaque(i % width, i / width)).collect();
    let edges = [(0, 0), (width - 1, 0), (0, height - 1), (width - 1, height - 1),
                 (width / 2, 0), (width / 2, height - 1), (0, height / 2), (width - 1, height / 2)];
    for edge in edges {
        flood_clear(&mut mask, width, height, edge, &opaque);
    }
    let mut result = RgbaImage::new(width, height);
    for (x, y, pixel) in result.enumerate_pixels_mut() {
        let inverted = 255 - image.get_pixel(x, y).0[3];
        let kept = mask[(y * width + x) as usize] || inverted <= 128;
        *pixel = Rgba([255, 255, 255, if kept { inverted } else { 0 }]);
    }
    result
}

/// 실루엣에 색을 입힌다.
pub fn tint(image: &RgbaImage, colour: [u8; 3]) -> RgbaImage {
    let mut result = RgbaImage::new(image.width(), image.height());
    for (x, y, pixel) in image.enumerate_pixels() {
        result.put_pixel(x, y, Rgba([colour[0], colour[1], colour[2], pixel.0[3]]));
    }
    result
}
