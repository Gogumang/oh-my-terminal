//! 내려받은 이미지를 프롬프트 글리프로 쓸 수 있는 형태로 다듬는다.
//!
//! 로고는 두 갈래다:
//!   - 실루엣: 형태(알파)만 남기고 세그먼트 배경에 맞춰 색을 입힌다. 대부분의 로고.
//!   - 원본 컬러: 색 면에서 글자를 파낸 앱 아이콘(배민·쿠팡·NOL). 실루엣으로 만들면
//!     통짜 동그라미/네모가 되어 알아볼 수 없다.
//!
//! iTerm2 GPU 렌더러는 컬러 글리프도 알파만 써서 글자색으로 칠한다. 그래서 색 면 위의 마크는
//! 색 차이를 알파로 옮겨야 보인다 (remove_dominant_colour·cut_minor_colours).

use std::collections::BTreeMap;

use image::{imageops, Rgba, RgbaImage};

const BACKGROUND_TOLERANCE: i32 = 28;
const CORNER_TOLERANCE: i32 = 32;
const FAINT_ALPHA: u8 = 30;
/// 이보다 불투명하면 그림이 아니라 배경 사각형이 깔린 것으로 본다.
const OPAQUE_ENOUGH_TO_BE_BACKGROUND: f64 = 0.95;
/// 채널 최대 차이가 이 안이면 같은 면, 이 밖이면 다른 부분으로 본다. 사이는 알파를 이어 준다.
const SAME_COLOUR: i32 = 24;
const OTHER_COLOUR: i32 = 72;
/// 화면에서 획이 이보다 가늘면 굵힌다 (레티나 픽셀).
const MIN_STROKE_SCREEN_PIXELS: f64 = 2.0;
/// 한쪽으로 넓히는 최대 폭 (이미지 픽셀). 넘치면 글자 워드마크가 뭉개진다.
const MAX_THICKEN: u32 = 5;

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

/// 배경 사각형을 걷어내야 하는 이미지인지 판단한다.
///
/// `strip_uniform_background`는 무조건 지우므로, 알파가 이미 정확한 이미지에 부르면
/// 획이 네 모서리에 닿는 로고(네이버의 굵은 N)를 배경으로 오인해 통째로 지운다.
/// 배경을 <rect>로 꽉 칠한 이미지만 거의 불투명하다는 성질로 구분한다.
pub fn needs_background_strip(image: &RgbaImage) -> bool {
    alpha_coverage(image) > OPAQUE_ENOUGH_TO_BE_BACKGROUND
}

/// 네 모서리가 같은 불투명 색이면 그 색을 배경으로 보고 지운다.
/// 부르기 전에 `needs_background_strip`으로 걸러야 한다.
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

fn flood_clear(mask: &mut [bool], width: u32, height: u32, start: (u32, u32),
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
        let weights = crate::domain::palette::LUMA_WEIGHTS;
        let luma = (p[0] as i32 * weights[0] + p[1] as i32 * weights[1]
                    + p[2] as i32 * weights[2]) / 1000;
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

/// 불투명 픽셀에서 가장 많은 색. 채널당 5비트로 묶어 세고 그 묶음의 평균색을 돌려준다.
/// 같은 수면 BTreeMap 순서로 정해져 결과가 빌드마다 같다.
fn dominant_colour(image: &RgbaImage) -> Option<[u8; 3]> {
    let mut buckets: BTreeMap<[u8; 3], (u64, [u64; 3])> = BTreeMap::new();
    for pixel in image.pixels().filter(|p| p.0[3] > 200) {
        let [r, g, b, _] = pixel.0;
        let entry = buckets.entry([r >> 3, g >> 3, b >> 3]).or_insert((0, [0; 3]));
        entry.0 += 1;
        for (sum, value) in entry.1.iter_mut().zip([r, g, b]) {
            *sum += value as u64;
        }
    }
    buckets.into_values().max_by_key(|(count, _)| *count)
        .map(|(count, sums)| sums.map(|sum| (sum / count) as u8))
}

/// 0(같은 면) ~ 1(확실히 다른 색). 경계의 안티앨리어싱 픽셀이 계단 없이 이어지게 한다.
fn difference(pixel: &Rgba<u8>, colour: [u8; 3]) -> f64 {
    let distance = (0..3).map(|i| (pixel.0[i] as i32 - colour[i] as i32).abs()).max().unwrap_or(0);
    ((distance - SAME_COLOUR) as f64 / (OTHER_COLOUR - SAME_COLOUR) as f64).clamp(0.0, 1.0)
}

fn scale_alpha(image: &RgbaImage, keep: impl Fn(&Rgba<u8>) -> f64) -> RgbaImage {
    let mut result = image.clone();
    for pixel in result.pixels_mut() {
        let kept = keep(pixel);
        pixel.0[3] = (pixel.0[3] as f64 * kept).round() as u8;
    }
    result
}

/// 색 면 위에 마크를 올린 앱 아이콘에서 면(가장 많은 색)을 지우고 마크만 남긴다.
/// 알파만 쓰는 렌더러에서는 면이 남으면 통짜 사각형이 된다.
pub fn remove_dominant_colour(image: &RgbaImage) -> RgbaImage {
    let Some(face) = dominant_colour(image) else { return image.clone() };
    scale_alpha(image, |pixel| difference(pixel, face))
}

/// 색 면에 글자를 파낸 배지(배민·쿠팡)에서 면만 남기고 다른 색(글자)은 구멍으로 뚫는다.
/// 알파만 쓰면 글자가 면에 묻혀 통짜 원·톱니만 남는다.
pub fn cut_minor_colours(image: &RgbaImage) -> RgbaImage {
    let Some(face) = dominant_colour(image) else { return image.clone() };
    scale_alpha(image, |pixel| 1.0 - difference(pixel, face))
}

/// 알파를 반경만큼 넓힌다. 정사각 창의 최대값은 가로·세로 두 번으로 나눠 구한다.
pub fn dilate(image: &RgbaImage, radius: u32) -> RgbaImage {
    if radius == 0 {
        return image.clone();
    }
    let (width, height) = image.dimensions();
    let reach = radius as i64;
    let pass = |source: &[u8], horizontal: bool| -> Vec<u8> {
        let mut grown = vec![0u8; source.len()];
        for y in 0..height as i64 {
            for x in 0..width as i64 {
                let mut strongest = 0u8;
                for step in -reach..=reach {
                    let (nx, ny) = if horizontal { (x + step, y) } else { (x, y + step) };
                    if nx >= 0 && ny >= 0 && nx < width as i64 && ny < height as i64 {
                        strongest = strongest.max(source[(ny * width as i64 + nx) as usize]);
                    }
                }
                grown[(y * width as i64 + x) as usize] = strongest;
            }
        }
        grown
    };
    let alpha: Vec<u8> = image.pixels().map(|p| p.0[3]).collect();
    let grown = pass(&pass(&alpha, true), false);
    let mut result = image.clone();
    for (pixel, value) in result.pixels_mut().zip(grown) {
        pixel.0[3] = value;
    }
    result
}

/// 획 두께(픽셀)를 어림한다. 가장자리를 한 겹씩 깎아 불투명 픽셀이 절반으로 줄 때까지의
/// 횟수를 센다 — 긴 획은 한 번에 양쪽이 한 겹씩 깎이므로 두께는 그 네 배쯤이다.
pub fn stroke_width(image: &RgbaImage) -> f64 {
    let (width, height) = image.dimensions();
    let mut solid: Vec<bool> = image.pixels().map(|p| p.0[3] > 127).collect();
    let initial = solid.iter().filter(|s| **s).count();
    if initial == 0 {
        return 0.0;
    }
    let w = width as usize;
    for depth in 1..=64 {
        let previous = solid.clone();
        for y in 0..height as usize {
            for x in 0..w {
                let i = y * w + x;
                if !previous[i] { continue; }
                let edge = x == 0 || y == 0 || x + 1 == w || y + 1 == height as usize
                    || !previous[i - 1] || !previous[i + 1] || !previous[i - w] || !previous[i + w];
                if edge { solid[i] = false; }
            }
        }
        if solid.iter().filter(|s| **s).count() * 2 <= initial {
            return depth as f64 * 4.0;
        }
    }
    256.0
}

/// 작게 그렸을 때 획이 너무 가늘면 필요한 만큼만 굵힌다.
/// `pixels_per_screen_pixel`: 이 이미지 몇 픽셀이 화면 한 픽셀인지.
///
/// 가는 로고(나이키 스우시·SpaceX)는 글자 칸 크기에서 1픽셀 아래로 가늘어져 흐릿한 선만
/// 남았다. 굵은 로고까지 굵히면 글자 워드마크가 뭉개지므로 가는 경우에만 굵힌다.
pub fn thicken_thin_strokes(image: &RgbaImage, pixels_per_screen_pixel: f64) -> RgbaImage {
    let on_screen = stroke_width(image) / pixels_per_screen_pixel;
    if on_screen >= MIN_STROKE_SCREEN_PIXELS {
        return image.clone();
    }
    let missing = (MIN_STROKE_SCREEN_PIXELS - on_screen) * pixels_per_screen_pixel;
    dilate(image, ((missing / 2.0).ceil() as u32).min(MAX_THICKEN))
}

#[cfg(test)]
#[allow(non_snake_case)]   // 테스트 이름은 동작 서술형 한국어를 쓴다
mod tests {
    use super::*;

    /// 지정한 좌표만 불투명한 정사각 이미지.
    fn image_with(size: u32, opaque: &dyn Fn(u32, u32) -> bool) -> RgbaImage {
        let mut image = RgbaImage::new(size, size);
        for (x, y, pixel) in image.enumerate_pixels_mut() {
            *pixel = Rgba([255, 255, 255, if opaque(x, y) { 255 } else { 0 }]);
        }
        image
    }

    /// 빨간 면 가운데에 흰 마크가 있는 불투명 16x16 이미지.
    fn badge() -> RgbaImage {
        let mut image = RgbaImage::from_pixel(16, 16, Rgba([230, 30, 40, 255]));
        for x in 6..10 {
            for y in 6..10 {
                image.put_pixel(x, y, Rgba([255, 255, 255, 255]));
            }
        }
        image
    }

    #[test]
    fn 모서리에_닿는_로고는_배경_제거_대상이_아니라고_판단한다() {
        // 네이버의 굵은 N은 획이 네 모서리에 전부 닿는다. 배경 제거를 태우면
        // 로고가 통째로 지워진다 — 이번 프로젝트에서 실제로 겪은 회귀다.
        // 방어선은 strip_uniform_background 안이 아니라 이 판단에 있다.
        let logo = image_with(16, &|x, y| x == y || !(2..=13).contains(&x));
        assert!(alpha_coverage(&logo) < 0.95, "픽스처가 로고답지 않다");
        assert!(!needs_background_strip(&logo), "로고를 배경 제거 대상으로 판단했다");

        // 반대로 배경을 꽉 칠한 이미지는 대상이다.
        let filled = RgbaImage::from_pixel(16, 16, Rgba([0, 0, 0, 255]));
        assert!(needs_background_strip(&filled), "배경 사각형을 못 알아봤다");
    }

    #[test]
    fn 네_모서리가_같은_불투명색이면_배경으로_보고_지운다() {
        let mut image = RgbaImage::from_pixel(16, 16, Rgba([255, 255, 255, 255]));
        for x in 6..10 {
            for y in 6..10 {
                image.put_pixel(x, y, Rgba([0, 0, 0, 255]));
            }
        }
        let stripped = strip_uniform_background(&image);
        assert_eq!(stripped.get_pixel(0, 0).0[3], 0, "흰 배경이 남았다");
        assert_eq!(stripped.get_pixel(7, 7).0[3], 255, "안쪽 마크가 지워졌다");
    }

    #[test]
    fn 반전은_바깥이_아니라_파낸_구멍만_남긴다() {
        // 단순히 알파를 뒤집으면 로고 '바깥'까지 불투명해져 테두리 프레임이 생긴다.
        // 구멍은 '갇혀' 있어야 한다. 바깥과 이어진 틈은 flood fill이 지우는 게 정상이다.
        let disc = image_with(16, &|x, y| {
            let (dx, dy) = (x as i32 - 8, y as i32 - 8);
            let inside_disc = dx * dx + dy * dy < 36;
            let inside_hole = (7..=9).contains(&x) && (7..=9).contains(&y);
            inside_disc && !inside_hole
        });
        let inverted = invert_alpha(&disc);
        assert_eq!(inverted.get_pixel(0, 0).0[3], 0, "바깥이 불투명해져 프레임이 생겼다");
        assert_eq!(inverted.get_pixel(8, 8).0[3], 255, "파낸 구멍이 남지 않았다");
    }

    #[test]
    fn 모서리에서_번진_밝은_배경만_지우고_안쪽_흰_글자는_남긴다() {
        // JPEG 앱 아이콘은 둥근 모서리 바깥이 흰색이다. 흰색을 전부 지우면
        // 로고 안쪽의 흰 글자까지 사라진다 (배민이 그랬다).
        let mut image = RgbaImage::from_pixel(16, 16, Rgba([255, 255, 255, 255]));
        for x in 3..13 {
            for y in 3..13 {
                image.put_pixel(x, y, Rgba([12, 200, 180, 255]));   // 브랜드색 면
            }
        }
        image.put_pixel(8, 8, Rgba([255, 255, 255, 255]));           // 안쪽 흰 글자
        let cleared = clear_corner_background(&image);
        assert_eq!(cleared.get_pixel(0, 0).0[3], 0, "모서리 흰 배경이 남았다");
        assert_eq!(cleared.get_pixel(8, 8).0[3], 255, "안쪽 흰 글자가 지워졌다");
    }

    #[test]
    fn fit은_작은_이미지를_확대한다() {
        // thumbnail처럼 축소만 하면 16x16 파비콘이 캔버스 한가운데 점으로 남는다.
        let tiny = RgbaImage::from_pixel(4, 4, Rgba([255, 255, 255, 255]));
        let fitted = fit(&tiny, 64);
        assert_eq!(fitted.dimensions(), (64, 64));
        assert!(alpha_coverage(&fitted) > 0.9, "확대되지 않았다");
    }

    #[test]
    fn 앱_아이콘은_면_색을_지우고_마크만_남긴다() {
        let mark = remove_dominant_colour(&badge());
        assert_eq!(mark.get_pixel(1, 1).0[3], 0, "면이 남아 통짜 사각형이 된다");
        assert_eq!(mark.get_pixel(8, 8).0[3], 255, "마크가 지워졌다");
    }

    #[test]
    fn 배지는_면을_남기고_파낸_글자를_구멍으로_뚫는다() {
        // 배민·쿠팡은 색 면에 글자가 있어, 알파만 쓰면 글자 없는 통짜 원이 됐다.
        let cut = cut_minor_colours(&badge());
        assert_eq!(cut.get_pixel(1, 1).0[3], 255, "면이 지워졌다");
        assert_eq!(cut.get_pixel(8, 8).0[3], 0, "글자가 구멍으로 뚫리지 않았다");
    }

    #[test]
    fn 가는_획만_굵히고_굵은_도형은_그대로_둔다() {
        // 이미지 5픽셀이 화면 1픽셀이라 치면 2픽셀 굵기 선은 화면에서 0.4픽셀이다.
        let thin = image_with(64, &|_, y| (31..33).contains(&y));
        let thick = image_with(64, &|x, y| (12..52).contains(&x) && (12..52).contains(&y));
        assert!(stroke_width(&thin) < stroke_width(&thick), "두께 어림이 거꾸로다");
        let thickened = thicken_thin_strokes(&thin, 5.0);
        assert!(alpha_coverage(&thickened) > alpha_coverage(&thin) * 2.0, "가는 선을 굵히지 않았다");
        assert!(thicken_thin_strokes(&thick, 5.0) == thick, "굵은 도형까지 굵혔다");
    }
}
