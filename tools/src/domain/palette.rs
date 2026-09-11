//! 팔레트 계산 — 순수 함수만. 외부 의존이 없어 목 없이 테스트된다.
//!
//! 여기 담긴 규칙은 전부 실제로 깨져서 얻은 것이다:
//!   - ANSI 0~15은 브랜드 색으로 덮지 않는다. red=에러/green=성공 의미가 무너지면 로그를 못 읽는다.
//!   - 그라데이션은 시작색만 검사하면 안 된다. 끝부분에서 글자가 묻힌다.
//!   - 검증은 셸이 실제로 고르는 글자색으로 해야 한다. 두 색의 max를 재면 통과했는데도 안 읽힌다.
//!   - 브랜드 색이 순수 검정이면 터미널 배경과 구분되지 않아 세그먼트가 사라진다.

use crate::domain::brand::Brand;

pub const CONTRAST_ACCENT: f64 = 4.5;

/// 이보다 1.5배 어두운 브랜드색은 검정 터미널 배경과 구분되지 않는다고 본다 (#121212 근처).
const TERMINAL_BACKGROUND_LUMINANCE: f64 = 0.008;

/// 셸(brands.zsh)이 글자색을 전환하는 기준.
///
/// 이 값과 BT.601 가중치는 생성 시 zsh 템플릿에 주입된다(p10k_writer). 예전에는 양쪽에
/// 리터럴로 박아두고 "반드시 같아야 한다"는 주석만 달았는데, 강제하는 것이 없어
/// Rust 상수만 바꾸면 검증은 통과하고 화면은 안 읽히는 상태가 만들어졌다.
pub const LUMA_SWITCH: i32 = 140;

/// 밝기 계산 가중치 (ITU-R BT.601). 셸과 이미지 처리가 같은 값을 써야 한다.
pub const LUMA_WEIGHTS: [i32; 3] = [299, 587, 114];

const GRADIENT_DEPTHS: [f64; 8] = [0.55, 0.45, 0.35, 0.28, 0.22, 0.17, 0.12, 0.08];

/// 중간 톤 브랜드색은 검정으로도 흰색으로도 4.5:1이 안 나온다(토스 #0064FF 등).
/// 그럴 때 배경 명도를 이 폭까지 옮긴다. 색상(hue)과 채도는 보존한다.
const NUDGES: [f64; 11] = [0.0, 0.04, -0.04, 0.08, -0.08, 0.12, -0.12, 0.16, -0.16, 0.20, -0.20];

/// 의미가 보존된 중립 ANSI 팔레트. 브랜드별로 건드리지 않는다.
pub const ANSI: [&str; 16] = [
    "#1C1F24", "#E05561", "#8CC265", "#D18F52", "#4AA5F0", "#C162DE", "#42B3C2", "#D7DAE0",
    "#6B7280", "#FF616E", "#A5E075", "#F0A45D", "#4DC4FF", "#DE73FF", "#4CD1E0", "#F3F4F5"];

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
    (to255(rgb[0]) * LUMA_WEIGHTS[0] + to255(rgb[1]) * LUMA_WEIGHTS[1]
        + to255(rgb[2]) * LUMA_WEIGHTS[2]) / 1000
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

/// 로고 색. 띠 시작색 위에서 검정과 흰색 중 대비가 큰 쪽을 쓴다.
///
/// 로고는 글자 몇 칸 크기로 작게 그려져 글자보다 강한 대비가 필요하다. 예전에는 글자색처럼
/// 브랜드 보조색을 4.5:1까지만 밀었는데, 어두운 띠 위의 회색 로고(삼성·우버)가 얼룩으로만 보였다.
/// iTerm2 GPU 렌더러는 로고를 그 칸의 글자색으로 칠하므로 셸도 로고 칸에 이 색을 쓴다.
pub fn logo_colour(brand: &Brand) -> Rgb {
    let background = gradient(brand).start;
    let (black, white) = ([0.0, 0.0, 0.0], [1.0, 1.0, 1.0]);
    if contrast_ratio(black, background) >= contrast_ratio(white, background) { black } else { white }
}

/// 브랜드 프로필의 터미널 배경·글자색. 회사와 macOS 라이트/다크 모드에 상관없이 고정한다.
/// 모드별로 두자 라이트 모드에서 흰 배경이 되어 브랜드 색 프롬프트가 흰 바탕에 떠 보였다.
pub const TERMINAL_BACKGROUND: &str = "#000000";
pub const TERMINAL_FOREGROUND: &str = "#FFFFFF";

pub struct TerminalPalette {
    pub background: Rgb,
    pub foreground: Rgb,
    pub accent: Rgb,
    pub selection: Rgb,
    pub ansi: Vec<Rgb>,
}

/// iTerm2 프로필 팔레트. 배경·글자는 고정하고 커서·링크·탭에만 브랜드 색을 쓴다.
/// ANSI 16색은 중립 팔레트를 그대로 쓴다.
pub fn terminal_palette(brand: &Brand) -> TerminalPalette {
    let background = hex_to_rgb(TERMINAL_BACKGROUND);
    let primary = hex_to_rgb(&brand.primary);
    // 검정 배경에 묻히는 브랜드색(쿠팡 #000000)은 밝혀서 커서·탭이 사라지지 않게 한다.
    let (accent, _) = push_to_contrast(primary, background, CONTRAST_ACCENT, true);
    TerminalPalette {
        background,
        foreground: hex_to_rgb(TERMINAL_FOREGROUND),
        accent,
        // 선택 영역에 액센트를 그대로 쓰면 선택 시 흰 글자가 사라진다.
        selection: with_lightness(primary, 0.22),
        ansi: ANSI.iter().map(|c| hex_to_rgb(c)).collect(),
    }
}

#[cfg(test)]
#[allow(non_snake_case)]   // 테스트 이름은 동작 서술형 한국어를 쓴다
mod tests {
    use super::*;

    fn brand(primary: &str, secondary: &str) -> Brand {
        Brand { key: "t".into(), name: "T".into(), primary: primary.into(),
                secondary: secondary.into(), logo: None, verified: None, logo_path: None }
    }

    #[test]
    fn 헥스_변환은_왕복한다() {
        for value in ["#000000", "#FEE500", "#0064FF", "#FFFFFF"] {
            assert_eq!(rgb_to_hex(hex_to_rgb(value)), value, "왕복 실패: {value}");
        }
    }

    #[test]
    fn 흑백_대비는_WCAG_최대값_21이다() {
        let ratio = contrast_ratio(hex_to_rgb("#FFFFFF"), hex_to_rgb("#000000"));
        assert!((ratio - 21.0).abs() < 0.01, "흑백 대비가 21:1이 아니다: {ratio}");
    }

    #[test]
    fn hls_변환은_왕복한다() {
        for value in ["#FEE500", "#03C75A", "#0064FF", "#808080"] {
            let original = hex_to_rgb(value);
            let (hue, lightness, saturation) = rgb_to_hls(original);
            let restored = hls_to_rgb(hue, lightness, saturation);
            assert_eq!(rgb_to_hex(restored), value, "HLS 왕복 실패: {value}");
        }
    }

    #[test]
    fn push_to_contrast는_달성_실패를_숨기지_않는다() {
        let background = hex_to_rgb("#FFFFFF");
        // 흰 배경에서 더 밝게 밀면 목표에 닿을 수 없다 — 조용히 최대치를 주는 대신
        // false를 함께 돌려줘야 한다. 이걸 숨기면 "대비 보장" 약속이 거짓이 된다.
        let (_, reached) = push_to_contrast(hex_to_rgb("#EEEEEE"), background, 7.0, true);
        assert!(!reached, "달성 실패를 true로 보고했다");

        let (colour, reached) = push_to_contrast(hex_to_rgb("#888888"), background, 7.0, false);
        assert!(reached, "어둡게 밀면 달성 가능한데 실패로 보고했다");
        assert!(contrast_ratio(colour, background) >= 7.0);
    }

    #[test]
    fn 모든_그라데이션_구간에서_셸이_고른_글자색이_읽힌다() {
        // 셸은 배경 밝기로 한쪽 색만 고른다. 두 색의 max를 재면 실제로 쓰이지 않는 색
        // 덕분에 통과해버려, 검증은 녹색인데 화면은 안 읽히는 상태가 된다 (실제 겪은 회귀).
        for (primary, secondary) in [("#FEE500", "#333333"), ("#0064FF", "#191F28"),
                                     ("#0078FF", "#354153"), ("#000000", "#000000")] {
            let subject = brand(primary, secondary);
            let gradient = gradient(&subject);
            for step in 0..=8 {
                let stop = blend(gradient.start, gradient.end, step as f64 / 8.0);
                let chosen = if luma_255(stop) > LUMA_SWITCH {
                    gradient.dark_foreground
                } else {
                    gradient.light_foreground
                };
                let ratio = contrast_ratio(chosen, stop);
                assert!(ratio >= CONTRAST_ACCENT,
                    "{primary} 구간 {step}에서 대비 {ratio:.2}:1 (목표 {CONTRAST_ACCENT})");
            }
        }
    }

    #[test]
    fn 순수_검정_브랜드는_터미널_배경과_구분되게_들어올려진다() {
        let (background, lifted) = segment_background(&brand("#000000", "#000000"));
        assert!(lifted, "순수 검정인데 들어올리지 않았다");
        assert!(relative_luminance(background) > TERMINAL_BACKGROUND_LUMINANCE,
                "들어올렸는데도 터미널 배경보다 어둡다");

        let (_, lifted) = segment_background(&brand("#FEE500", "#333333"));
        assert!(!lifted, "밝은 브랜드색을 불필요하게 건드렸다");
    }

    #[test]
    fn 대비를_위해_배경을_옮겨도_색상은_보존된다() {
        // 토스·SOCAR 같은 중간 톤은 배경을 미세 조정해야 대비가 나온다.
        // 명도만 움직이고 색상(hue)은 유지해야 브랜드 정체성이 남는다.
        let subject = brand("#0078FF", "#354153");
        let original = hex_to_rgb(&subject.primary);
        let adjusted = gradient(&subject).start;
        let hue_difference = (rgb_to_hls(original).0 - rgb_to_hls(adjusted).0).abs();
        assert!(hue_difference < 0.01, "색상이 바뀌었다: {hue_difference}");
    }

    #[test]
    fn 로고는_띠_위에서_검정과_흰색_중_대비가_큰_쪽으로_칠한다() {
        // 보조색을 4.5:1까지만 밀었더니 어두운 띠 위 회색 로고(삼성·우버)가 얼룩으로 보였다.
        assert_eq!(logo_colour(&brand("#FEE500", "#333333")), [0.0, 0.0, 0.0], "노란 띠에는 검정");
        assert_eq!(logo_colour(&brand("#3549FF", "#FFFFFF")), [1.0, 1.0, 1.0], "파란 띠에는 흰색");
        assert_eq!(logo_colour(&brand("#000000", "#000000")), [1.0, 1.0, 1.0], "검정 브랜드에는 흰색");
    }

    #[test]
    fn 검정_배경에_묻히는_브랜드색도_커서와_탭에서_보인다() {
        // 배경을 검정으로 고정하자 쿠팡·무신사(#000000)는 액센트가 배경에 묻힐 수 있다.
        let colours = terminal_palette(&brand("#000000", "#000000"));
        let ratio = contrast_ratio(colours.accent, colours.background);
        assert!(ratio >= CONTRAST_ACCENT, "액센트가 검정 배경에 묻힌다: {ratio:.2}:1");
        assert!(contrast_ratio(colours.foreground, colours.selection) >= CONTRAST_ACCENT,
                "선택 영역에서 흰 글자가 안 읽힌다");
    }
}
