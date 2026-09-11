//! README 지원 테마 구간 생성기. 표시 주석 사이만 다시 쓰고 나머지 문서는 건드리지 않는다.
//!
//! 회사 목록을 손으로 적으면 회사를 켜고 끌 때마다 README가 뒤처진다. 나라별 묶음·정렬·그림
//! 경로를 brands/*.yaml에서 만들어 목록과 생성물이 늘 같게 한다.

use std::collections::BTreeMap;

use anyhow::{anyhow, Result};

use crate::domain::brand::Brand;

pub const START_MARKER: &str = "<!-- themes:start — build-themes gallery가 만든다. 직접 고치지 말 것 -->";
pub const END_MARKER: &str = "<!-- themes:end -->";

/// 따로 펼쳐 보여줄 나라. 순서가 곧 README 순서다.
const FEATURED_COUNTRIES: [(&str, &str); 4] =
    [("KR", "🇰🇷 한국"), ("US", "🇺🇸 미국"), ("JP", "🇯🇵 일본"), ("TW", "🇹🇼 대만")];
const OTHER_TITLE: &str = "🌍 그 밖의 나라";
/// '그 밖의 나라' 칸에 붙일 나라 이름. 없는 코드는 조용히 빼지 않고 에러로 알린다.
const OTHER_COUNTRIES: [(&str, &str); 5] =
    [("UK", "영국"), ("CN", "중국"), ("DE", "독일"), ("FR", "프랑스"), ("IT", "이탈리아")];
/// 표 한 줄에 넣을 회사 수. GitHub 본문 폭에서 그림이 줄지 않는 최대치다.
const COLUMNS: usize = 3;

/// `image_directory`: README 기준 그림 폴더, `display_height`: README에 보일 그림 높이(CSS 픽셀).
pub fn section(brands: &[Brand], image_directory: &str, display_height: u32) -> Result<String> {
    let mut groups: BTreeMap<usize, Vec<(&Brand, Option<&str>)>> = BTreeMap::new();
    for brand in brands {
        let code = brand.country.as_deref().ok_or_else(|| anyhow!(
            "{}: 나라를 모른다 — brands/{}.yaml에 `country: KR`처럼 적을 것", brand.key, brand.key))?;
        match FEATURED_COUNTRIES.iter().position(|(featured, _)| *featured == code) {
            Some(order) => groups.entry(order).or_default().push((brand, None)),
            None => {
                let (_, label) = OTHER_COUNTRIES.iter().find(|(other, _)| *other == code)
                    .ok_or_else(|| anyhow!("{}: 나라 코드 {code}의 이름이 없다 — \
                        readme_gallery.rs OTHER_COUNTRIES에 추가할 것", brand.key))?;
                groups.entry(FEATURED_COUNTRIES.len()).or_default().push((brand, Some(label)));
            }
        }
    }

    let mut lines = vec![START_MARKER.to_string(), format!("**{}개 회사**를 지원합니다.", brands.len())];
    for (order, mut members) in groups {
        members.sort_by_key(|(brand, _)| brand.name.to_lowercase());
        let title = FEATURED_COUNTRIES.get(order).map_or(OTHER_TITLE, |(_, title)| title);
        lines.push(String::new());
        lines.push(if order == 0 { "<details open>" } else { "<details>" }.to_string());
        lines.push(format!("<summary><b>{title}</b> — {}개</summary>", members.len()));
        lines.push(String::new());
        lines.push("<table>".to_string());
        for row in members.chunks(COLUMNS) {
            lines.push("<tr>".to_string());
            for (brand, country) in row {
                let name = escape(&brand.name);
                let label = country.map_or(name.clone(), |country| format!("{name} <sub>{country}</sub>"));
                lines.push(format!(
                    "<td><img src=\"{image_directory}/{}.png\" height=\"{display_height}\" alt=\"{name} 테마\"><br>{label}</td>",
                    brand.key));
            }
            lines.push("</tr>".to_string());
        }
        lines.push("</table>".to_string());
        lines.push(String::new());
        lines.push("</details>".to_string());
    }
    lines.push(END_MARKER.to_string());
    Ok(lines.join("\n"))
}

/// 표시 주석 사이를 `section`으로 바꾼다. 표시가 없으면 문서 끝에 붙이지 않고 에러를 낸다 —
/// 엉뚱한 곳에 목록이 하나 더 생기는 것보다 멈추는 편이 낫다.
pub fn replace_section(document: &str, section: &str) -> Result<String> {
    let start = document.find(START_MARKER)
        .ok_or_else(|| anyhow!("README에 시작 표시가 없다: {START_MARKER}"))?;
    let end = document[start..].find(END_MARKER)
        .map(|offset| start + offset + END_MARKER.len())
        .ok_or_else(|| anyhow!("README에 끝 표시가 없다: {END_MARKER}"))?;
    Ok(format!("{}{section}{}", &document[..start], &document[end..]))
}

fn escape(text: &str) -> String {
    text.replace('&', "&amp;").replace('<', "&lt;").replace('>', "&gt;").replace('"', "&quot;")
}

#[cfg(test)]
#[allow(non_snake_case)]   // 테스트 이름은 동작 서술형 한국어를 쓴다
mod tests {
    use super::*;

    fn brand(key: &str, name: &str, country: Option<&str>) -> Brand {
        Brand { key: key.into(), name: name.into(), country: country.map(Into::into),
                primary: "#0064FF".into(), secondary: "#FFFFFF".into(),
                logo: None, verified: None, logo_path: None }
    }

    #[test]
    fn 나라별로_묶고_대소문자_없이_이름순으로_정렬한다() {
        let brands = [brand("toss", "Toss", Some("KR")), brand("xai", "xAI", Some("US")),
                      brand("gangnam", "강남언니", Some("KR")), brand("zoom", "Zoom", Some("US")),
                      brand("ably", "Ably", Some("KR"))];

        let text = section(&brands, "docs/themes", 24).unwrap();

        let order: Vec<usize> = ["ably.png", "toss.png", "gangnam.png", "xai.png", "zoom.png"]
            .iter().map(|image| text.find(image).unwrap_or_else(|| panic!("{image} 없음: {text}"))).collect();
        assert!(order.windows(2).all(|pair| pair[0] < pair[1]), "순서가 틀렸다: {text}");
        assert!(text.contains("<b>🇰🇷 한국</b> — 3개"), "한국 묶음 개수: {text}");
        assert!(text.contains("<b>🇺🇸 미국</b> — 2개"), "미국 묶음 개수: {text}");
        assert!(text.contains("**5개 회사**"), "전체 개수: {text}");
    }

    #[test]
    fn 첫_묶음만_펼치고_세_칸마다_줄을_바꾼다() {
        let brands: Vec<Brand> = (0..4).map(|i| brand(&format!("k{i}"), &format!("K{i}"), Some("KR")))
            .chain([brand("zoom", "Zoom", Some("US"))]).collect();

        let text = section(&brands, "docs/themes", 24).unwrap();

        assert_eq!(text.matches("<details open>").count(), 1, "펼친 묶음 수: {text}");
        assert_eq!(text.matches("<tr>").count(), 3, "한국 4개는 두 줄, 미국 1개는 한 줄: {text}");
    }

    #[test]
    fn 주요_나라가_아니면_그_밖의_나라에_나라_이름을_붙여_넣는다() {
        let brands = [brand("bbc", "BBC", Some("UK")), brand("kakao", "Kakao", Some("KR"))];

        let text = section(&brands, "docs/themes", 24).unwrap();

        assert!(text.contains("<b>🌍 그 밖의 나라</b> — 1개"), "그 밖의 나라 묶음: {text}");
        assert!(text.contains("BBC <sub>영국</sub>"), "나라 이름: {text}");
        assert!(text.find("kakao.png") < text.find("bbc.png"), "그 밖의 나라는 맨 뒤: {text}");
    }

    #[test]
    fn 나라를_모르면_목록에서_빼지_않고_에러를_낸다() {
        let missing = section(&[brand("nol", "NOL", None)], "docs/themes", 24);
        let unknown = section(&[brand("volvo", "Volvo", Some("SE"))], "docs/themes", 24);

        assert!(missing.as_ref().is_err_and(|error| error.to_string().contains("country")),
                "나라 없음: {:?}", missing.map(|_| ()));
        assert!(unknown.as_ref().is_err_and(|error| error.to_string().contains("SE")),
                "모르는 코드: {:?}", unknown.map(|_| ()));
    }

    #[test]
    fn 회사_이름의_HTML_특수문자를_이스케이프한다() {
        let text = section(&[brand("at", "AT&T <\"US\">", Some("US"))], "docs/themes", 24).unwrap();

        assert!(text.contains("AT&amp;T &lt;&quot;US&quot;&gt;"), "이스케이프: {text}");
        assert!(!text.contains("AT&T"), "원문이 남았다: {text}");
    }

    #[test]
    fn 표시_사이만_바꾸고_앞뒤_문서는_그대로_둔다() {
        let document = format!("앞\n{START_MARKER}\n옛 목록\n{END_MARKER}\n뒤\n");
        let replacement = format!("{START_MARKER}\n새 목록\n{END_MARKER}");

        let updated = replace_section(&document, &replacement).unwrap();

        assert_eq!(updated, format!("앞\n{START_MARKER}\n새 목록\n{END_MARKER}\n뒤\n"));
    }

    #[test]
    fn 표시가_없으면_문서에_덧붙이지_않고_에러를_낸다() {
        let result = replace_section("표시 없는 문서", "목록");

        assert!(result.is_err(), "표시가 없는데 성공했다: {result:?}");
    }
}
