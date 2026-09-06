"""팔레트 계산 — 순수 함수만. 외부 의존이 없어 목 없이 테스트된다.

여기 담긴 규칙은 전부 실제로 깨져서 얻은 것이다:
  - ANSI 0~15은 브랜드 색으로 덮지 않는다. red=에러/green=성공 의미가 무너지면 로그를 못 읽는다.
  - 그라데이션은 시작색만 검사하면 안 된다. 끝부분에서 글자가 묻힌다.
  - 브랜드 색이 순수 검정이면 터미널 배경과 구분되지 않아 세그먼트가 사라진다.
"""
import colorsys

CONTRAST_BODY = 7.0        # 본문 텍스트 (WCAG AAA)
CONTRAST_ACCENT = 4.5      # 액센트·프롬프트 (WCAG AA)

# 터미널 다크 배경(#121212 근처)의 상대 휘도. 브랜드 색이 이보다 어두우면 경계가 사라진다.
TERMINAL_BACKGROUND_LUMINANCE = 0.008

# 의미가 보존된 중립 ANSI 팔레트. 브랜드별로 건드리지 않는다.
ANSI_DARK = ["#1C1F24", "#E05561", "#8CC265", "#D18F52", "#4AA5F0", "#C162DE", "#42B3C2", "#D7DAE0",
             "#6B7280", "#FF616E", "#A5E075", "#F0A45D", "#4DC4FF", "#DE73FF", "#4CD1E0", "#F3F4F5"]
ANSI_LIGHT = ["#2E3440", "#C33F49", "#4B801F", "#9A6200", "#1B6FC4", "#8B3FB0", "#0E7A8C", "#4C566A",
              "#6B7280", "#A32B34", "#3A6614", "#7D4E00", "#12579B", "#6E2E8C", "#0A5F6D", "#2E3440"]

# 그라데이션 깊이 후보. 깊을수록 예쁘지만 중간 톤에서 글자가 묻힌다 — 통과하는 첫 값을 쓴다.
GRADIENT_DEPTHS = (0.55, 0.45, 0.35, 0.28, 0.22, 0.17, 0.12, 0.08)


def hex_to_rgb(value):
    value = value.lstrip("#")
    return tuple(int(value[index:index + 2], 16) / 255 for index in (0, 2, 4))


def rgb_to_hex(rgb):
    return "#" + "".join(f"{round(max(0.0, min(1.0, channel)) * 255):02X}" for channel in rgb)


def relative_luminance(rgb):
    channels = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in rgb]
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


def contrast_ratio(foreground, background):
    lighter, darker = sorted((relative_luminance(foreground), relative_luminance(background)),
                             reverse=True)
    return (lighter + 0.05) / (darker + 0.05)


def with_lightness(rgb, lightness):
    hue, _, saturation = colorsys.rgb_to_hls(*rgb)
    return colorsys.hls_to_rgb(hue, lightness, saturation)


def blend(rgb, other, amount):
    return tuple(a + (b - a) * amount for a, b in zip(rgb, other))


def push_to_contrast(rgb, background, target, direction):
    """색상(hue)은 보존한 채 명도만 밀어 목표 대비에 닿게 한다.

    (색, 목표달성여부)를 함께 돌려준다 — 못 닿았는데 조용히 최대치를 주면
    '대비를 보장한다'는 약속이 거짓이 되므로 호출부가 알아야 한다.
    """
    hue, lightness, saturation = colorsys.rgb_to_hls(*rgb)
    for _ in range(100):
        candidate = colorsys.hls_to_rgb(hue, lightness, saturation)
        if contrast_ratio(candidate, background) >= target:
            return candidate, True
        lightness = (min(1.0, lightness + 0.01) if direction == "lighter"
                     else max(0.0, lightness - 0.01))
    return colorsys.hls_to_rgb(hue, 1.0 if direction == "lighter" else 0.0, saturation), False


def segment_background(brand):
    """프롬프트 세그먼트의 시작 배경색.

    순수 검정 브랜드(쿠팡·무신사)는 터미널 배경과 구분되지 않아 세그먼트가 통째로
    안 보인다. 경계가 드러날 만큼만 들어올린다.
    """
    background = hex_to_rgb(brand.primary)
    if relative_luminance(background) < TERMINAL_BACKGROUND_LUMINANCE * 1.5:
        return with_lightness(background, 0.16), True
    return background, False


def gradient(brand):
    """(시작색, 끝색, 어두운 글자색, 밝은 글자색, 최저대비, 깊이)를 계산한다.

    배경이 그라데이션이므로 전 구간에서 읽혀야 한다. 글자색은 배경 밝기에 따라
    두 색 중 하나로 전환되므로, 각 구간의 '더 나은 쪽' 대비의 최솟값이 실제 최저 대비다.
    """
    background, _ = segment_background(brand)
    seed = hex_to_rgb(brand.secondary)

    for depth in GRADIENT_DEPTHS:
        end = blend(background, (0.0, 0.0, 0.0), depth)
        stops = [blend(background, end, step / 8) for step in range(9)]
        dark, _ = push_to_contrast(seed, stops[0], CONTRAST_ACCENT, "darker")
        light, _ = push_to_contrast(seed, stops[-1], CONTRAST_ACCENT, "lighter")
        lowest = min(max(contrast_ratio(dark, stop), contrast_ratio(light, stop)) for stop in stops)
        if lowest >= CONTRAST_ACCENT:
            return background, end, dark, light, lowest, depth
    return background, end, dark, light, lowest, GRADIENT_DEPTHS[-1]


def logo_tint(brand):
    """로고를 세그먼트 배경 위에서 읽히는 색으로 칠한다.

    프롬프트 글자와 같은 배경을 기준으로 계산해야 둘이 어긋나지 않는다.
    """
    background, _ = segment_background(brand)
    candidates = [push_to_contrast(hex_to_rgb(brand.secondary), background, CONTRAST_ACCENT, way)
                  for way in ("darker", "lighter")]
    colour, reached = max(candidates,
                          key=lambda item: (item[1], contrast_ratio(item[0], background)))
    return tuple(round(channel * 255) for channel in colour), reached


def terminal_palette(brand):
    """iTerm2 프로필용 다크/라이트 팔레트. ANSI 16색은 중립 팔레트를 그대로 쓴다."""
    primary = hex_to_rgb(brand.primary)
    secondary = hex_to_rgb(brand.secondary)
    result = {}
    for mode, lightness, ansi, direction in (("Dark", 0.07, ANSI_DARK, "lighter"),
                                             ("Light", 0.97, ANSI_LIGHT, "darker")):
        background = with_lightness(secondary, lightness)
        foreground, _ = push_to_contrast(with_lightness(secondary, 0.90 if mode == "Dark" else 0.15),
                                         background, CONTRAST_BODY, direction)
        accent, _ = push_to_contrast(primary, background, CONTRAST_ACCENT, direction)
        result[mode] = {
            "background": background, "foreground": foreground, "accent": accent,
            "ansi": [hex_to_rgb(colour) for colour in ansi],
            # 선택 영역에 액센트를 그대로 쓰면 선택 시 글자가 사라진다.
            "selection": with_lightness(primary, 0.22 if mode == "Dark" else 0.85),
        }
    return result
