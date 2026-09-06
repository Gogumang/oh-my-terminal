//! 팔레트 계산 — 순수 함수만. 외부 의존이 없어 목 없이 테스트된다.
//!
//! 여기 담긴 규칙은 전부 실제로 깨져서 얻은 것이다:
//!   - ANSI 0~15은 브랜드 색으로 덮지 않는다. red=에러/green=성공 의미가 무너지면 로그를 못 읽는다.
//!   - 그라데이션은 시작색만 검사하면 안 된다. 끝부분에서 글자가 묻힌다.
//!   - 검증은 셸이 실제로 고르는 글자색으로 해야 한다. 두 색의 max를 재면 통과했는데도 안 읽힌다.
//!   - 브랜드 색이 순수 검정이면 터미널 배경과 구분되지 않아 세그먼트가 사라진다.

use crate::domain::brand::Brand;

pub const CONTRAST_BODY: f64 = 7.0;
pub const CONTRAST_ACCENT: f64 = 4.5;

/// 터미널 다크 배경(#121212 근처)의 상대 휘도.
const TERMINAL_BACKGROUND_LUMINANCE: f64 = 0.008;

/// 셸(brands.zsh)이 글자색을 전환하는 기준. 여기 값과 zsh 쪽이 반드시 같아야 한다 —
/// 다르면 "검증은 통과했는데 실제로는 안 읽히는" 상태가 된다.
pub const LUMA_SWITCH: i32 = 140;

const GRADIENT_DEPTHS: [f64; 8] = [0.55, 0.45, 0.35, 0.28, 0.22, 0.17, 0.12, 0.08];

/// 중간 톤 브랜드색은 검정으로도 흰색으로도 4.5:1이 안 나온다(토스 #0064FF 등).
/// 그럴 때 배경 명도를 이 폭까지 옮긴다. 색상(hue)과 채도는 보존한다.
const NUDGES: [f64; 11] = [0.0, 0.04, -0.04, 0.08, -0.08, 0.12, -0.12, 0.16, -0.16, 0.20, -0.20];

/// 의미가 보존된 중립 ANSI 팔레트. 브랜드별로 건드리지 않는다.
pub const ANSI_DARK: [&str; 16] = [
    "#1C1F24", "#E05561", "#8CC265", "#D18F52", "#4AA5F0", "#C162DE", "#42B3C2", "#D7DAE0",
    "#6B7280", "#FF616E", "#A5E075", "#F0A45D", "#4DC4FF", "#DE73FF", "#4CD1E0", "#F3F4F5"];
pub const ANSI_LIGHT: [&str; 16] = [
    "#2E3440", "#C33F49", "#4B801F", "#9A6200", "#1B6FC4", "#8B3FB0", "#0E7A8C", "#4C566A",
    "#6B7280", "#A32B34", "#3A6614", "#7D4E00", "#12579B", "#6E2E8C", "#0A5F6D", "#2E3440"];

pub type Rgb = [f64; 3];

pub fn hex_to_rgb(value: &str) -> Rgb {
    let text = value.trim_start_matches('#');
    let channel = |index: usize| {
        u8::from_str_radix(&text[index..index + 2], 16).unwrap_or(0) as f64 / 255.0
    };
    [channel(0), channel(2), channel(4)]
}

pub fn rgb_to_hex(rgb: Rgb) -> String {
    format!("#{:02X}{:02X}{:02X}",
        (rgb[0].clamp(0.0, 1.0) * 255.0).round() as u8,
        (rgb[1].clamp(0.0, 1.0) * 255.0).round() as u8,
        (rgb[2].clamp(0.0, 1.0) * 255.0).round() as u8)
}

pub fn relative_luminance(rgb: Rgb) -> f64 {
    let linear = |c: f64| if c <= 0.04045 { c / 12.92 } else { ((c + 0.055) / 1.055).powf(2.4) };
    0.2126 * linear(rgb[0]) + 0.7152 * linear(rgb[1]) + 0.0722 * linear(rgb[2])
}

pub fn contrast_ratio(foreground: Rgb, background: Rgb) -> f64 {
    let (a, b) = (relative_luminance(foreground), relative_luminance(background));
    let (lighter, darker) = if a > b { (a, b) } else { (b, a) };
    (lighter + 0.05) / (darker + 0.05)
}

fn rgb_to_hls(rgb: Rgb) -> (f64, f64, f64) {
    let (r, g, b) = (rgb[0], rgb[1], rgb[2]);
    let max = r.max(g).max(b);
    let min = r.min(g).min(b);
    let lightness = (max + min) / 2.0;
    if (max - min).abs() < f64::EPSILON {
        return (0.0, lightness, 0.0);
    }
    let delta = max - min;
    let saturation = if lightness < 0.5 { delta / (max + min) } else { delta / (2.0 - max - min) };
    let hue = if max == r { ((g - b) / delta).rem_euclid(6.0) }
        else if max == g { (b - r) / delta + 2.0 }
        else { (r - g) / delta + 4.0 };
    (hue / 6.0, lightness, saturation)
}

fn hls_to_rgb(hue: f64, lightness: f64, saturation: f64) -> Rgb {
    if saturation.abs() < f64::EPSILON {
        return [lightness, lightness, lightness];
    }
    let m2 = if lightness <= 0.5 { lightness * (1.0 + saturation) }
        else { lightness + saturation - lightness * saturation };
    let m1 = 2.0 * lightness - m2;
    let channel = |mut t: f64| {
        t = t.rem_euclid(1.0);
        if t < 1.0 / 6.0 { m1 + (m2 - m1) * 6.0 * t }
        else if t < 0.5 { m2 }
        else if t < 2.0 / 3.0 { m1 + (m2 - m1) * (2.0 / 3.0 - t) * 6.0 }
        else { m1 }
    };
    [channel(hue + 1.0 / 3.0), channel(hue), channel(hue - 1.0 / 3.0)]
}

pub fn with_lightness(rgb: Rgb, lightness: f64) -> Rgb {
    let (hue, _, saturation) = rgb_to_hls(rgb);
    hls_to_rgb(hue, lightness, saturation)
}

pub fn blend(rgb: Rgb, other: Rgb, amount: f64) -> Rgb {
    [rgb[0] + (other[0] - rgb[0]) * amount,
     rgb[1] + (other[1] - rgb[1]) * amount,
     rgb[2] + (other[2] - rgb[2]) * amount]
}

/// 색상(hue)은 보존한 채 명도만 밀어 목표 대비에 닿게 한다.
/// 못 닿았는데 조용히 최대치를 주면 '대비를 보장한다'는 약속이 거짓이 되므로 함께 알린다.
pub fn push_to_contrast(rgb: Rgb, background: Rgb, target: f64, lighter: bool) -> (Rgb, bool) {
    let (hue, mut lightness, saturation) = rgb_to_hls(rgb);
    for _ in 0..100 {
        let candidate = hls_to_rgb(hue, lightness, saturation);
        if contrast_ratio(candidate, background) >= target {
            return (candidate, true);
        }
        lightness = if lighter { (lightness + 0.01).min(1.0) } else { (lightness - 0.01).max(0.0) };
    }
    (hls_to_rgb(hue, if lighter { 1.0 } else { 0.0 }, saturation), false)
}

/// 프롬프트 세그먼트의 시작 배경색. 순수 검정 브랜드(쿠팡·무신사)는 터미널 배경과
/// 구분되지 않아 세그먼트가 통째로 안 보이므로 경계가 드러날 만큼만 들어올린다.
pub fn segment_background(brand: &Brand) -> (Rgb, bool) {
    let background = hex_to_rgb(&brand.primary);
    if relative_luminance(background) < TERMINAL_BACKGROUND_LUMINANCE * 1.5 {
        (with_lightness(background, 0.16), true)
    } else {
        (background, false)
    }
}

/// 셸이 쓰는 것과 같은 정수 밝기 계산 (ITU-R BT.601 근사).
fn luma_255(rgb: Rgb) -> i32 {
    let to255 = |c: f64| (c * 255.0).round() as i32;
    (to255(rgb[0]) * 299 + to255(rgb[1]) * 587 + to255(rgb[2]) * 114) / 1000
}

pub struct Gradient {
    pub start: Rgb,
    pub end: Rgb,
    pub dark_foreground: Rgb,
    pub light_foreground: Rgb,
    pub lowest_contrast: f64,
    pub depth: f64,
}

/// 셸은 각 글자 위치에서 배경 밝기를 보고 '한쪽'만 쓴다. 그러므로 어두운 글자색은
/// 자기가 실제로 쓰이는 구간 중 '가장 어두운 배경'에서 읽혀야 하고, 밝은 글자색은
/// 자기 구간 중 '가장 밝은 배경'에서 읽혀야 한다.
fn evaluate(background: Rgb, seed: Rgb, depth: f64) -> Gradient {
    let end = blend(background, [0.0, 0.0, 0.0], depth);
    let stops: Vec<Rgb> = (0..9).map(|step| blend(background, end, step as f64 / 8.0)).collect();
    let bright: Vec<Rgb> = stops.iter().copied().filter(|s| luma_255(*s) > LUMA_SWITCH).collect();
    let dim: Vec<Rgb> = stops.iter().copied().filter(|s| luma_255(*s) <= LUMA_SWITCH).collect();

    let darkest_bright = bright.iter().copied().min_by_key(|s| luma_255(*s));
    let brightest_dim = dim.iter().copied().max_by_key(|s| luma_255(*s));
    let dark = darkest_bright
        .map(|stop| push_to_contrast(seed, stop, CONTRAST_ACCENT, false).0).unwrap_or(seed);
    let light = brightest_dim
        .map(|stop| push_to_contrast(seed, stop, CONTRAST_ACCENT, true).0).unwrap_or(seed);

    let lowest = stops.iter().map(|stop| {
        let chosen = if luma_255(*stop) > LUMA_SWITCH { dark } else { light };
        contrast_ratio(chosen, *stop)
    }).fold(f64::INFINITY, f64::min);

    Gradient { start: background, end, dark_foreground: dark, light_foreground: light,
               lowest_contrast: lowest, depth }
}

/// 깊이를 줄여도 대비가 안 나오면 배경 명도를 조금씩 옮긴다. 색상은 보존하므로
/// 브랜드 정체성은 유지되고, 얼마나 옮겼는지는 빌드 로그에 남는다.
pub fn gradient(brand: &Brand) -> Gradient {
    let (base, _) = segment_background(brand);
    let seed = hex_to_rgb(&brand.secondary);
    let base_lightness = rgb_to_hls(base).1;
    let mut best: Option<Gradient> = None;

    for nudge in NUDGES {
        let background = with_lightness(base, (base_lightness + nudge).clamp(0.05, 0.95));
        for depth in GRADIENT_DEPTHS {
            let candidate = evaluate(background, seed, depth);
            if candidate.lowest_contrast >= CONTRAST_ACCENT {
                return candidate;
            }
            if best.as_ref().is_none_or(|b| candidate.lowest_contrast > b.lowest_contrast) {
                best = Some(candidate);
            }
        }
    }
    best.expect("후보가 최소 하나는 있다")
}

/// 로고를 세그먼트 배경 위에서 읽히는 색으로 칠한다. 프롬프트 글자와 같은 배경을
/// 기준으로 계산해야 둘이 어긋나지 않는다.
pub fn logo_tint(brand: &Brand) -> [u8; 3] {
    let background = gradient(brand).start;
    let seed = hex_to_rgb(&brand.secondary);
    let candidates = [push_to_contrast(seed, background, CONTRAST_ACCENT, false),
                      push_to_contrast(seed, background, CONTRAST_ACCENT, true)];
    let (colour, _) = candidates.into_iter()
        .max_by(|a, b| {
            let key = |item: &(Rgb, bool)| (item.1, contrast_ratio(item.0, background));
            key(a).partial_cmp(&key(b)).unwrap()
        }).unwrap();
    [(colour[0] * 255.0).round() as u8,
     (colour[1] * 255.0).round() as u8,
     (colour[2] * 255.0).round() as u8]
}

pub struct ModePalette {
    pub background: Rgb,
    pub foreground: Rgb,
    pub accent: Rgb,
    pub selection: Rgb,
    pub ansi: Vec<Rgb>,
}

/// iTerm2 프로필용 다크/라이트 팔레트. ANSI 16색은 중립 팔레트를 그대로 쓴다.
pub fn terminal_palette(brand: &Brand) -> (ModePalette, ModePalette) {
    let primary = hex_to_rgb(&brand.primary);
    let secondary = hex_to_rgb(&brand.secondary);
    let build = |lightness: f64, ansi: &[&str; 16], lighter: bool| {
        let background = with_lightness(secondary, lightness);
        let seed = with_lightness(secondary, if lighter { 0.90 } else { 0.15 });
        let (foreground, _) = push_to_contrast(seed, background, CONTRAST_BODY, lighter);
        let (accent, _) = push_to_contrast(primary, background, CONTRAST_ACCENT, lighter);
        ModePalette {
            background, foreground, accent,
            // 선택 영역에 액센트를 그대로 쓰면 선택 시 글자가 사라진다.
            selection: with_lightness(primary, if lighter { 0.22 } else { 0.85 }),
            ansi: ansi.iter().map(|c| hex_to_rgb(c)).collect(),
        }
    };
    (build(0.07, &ANSI_DARK, true), build(0.97, &ANSI_LIGHT, false))
}
