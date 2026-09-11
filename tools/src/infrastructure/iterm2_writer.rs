//! iTerm2 Dynamic Profile 생성기.
//!
//! .itermcolors가 아니라 Dynamic Profile을 쓰는 이유: 색만이 아니라 탭 색·폰트까지 담을 수
//! 있고, 파일을 폴더에 넣기만 하면 iTerm2가 재시작 없이 즉시 반영한다.
//! 프로필은 곧 회사 선택이기도 하다 — 셸이 ITERM_PROFILE로 프롬프트 테마를 고른다.

use std::path::{Path, PathBuf};

use anyhow::Result;
use serde_json::{json, Map, Value};

use crate::domain::brand::Brand;
use crate::domain::palette::{self, Rgb};

fn colour(rgb: Rgb, alpha: f64) -> Value {
    json!({"Red Component": rgb[0], "Green Component": rgb[1], "Blue Component": rgb[2],
           "Color Space": "sRGB", "Alpha Component": alpha})
}

/// GUID는 재빌드 사이에 안정적이어야 한다. 매번 새로 만들면 재빌드마다 새 프로필이
/// 생겨 사용자의 창 설정과 단축키 연결이 끊긴다. 키에서 결정적으로 유도한다.
fn stable_guid(key: &str) -> String {
    let mut state: u64 = 0xcbf2_9ce4_8422_2325;
    for byte in format!("oh-my-terminal:{key}").bytes() {
        state ^= byte as u64;
        state = state.wrapping_mul(0x0000_0100_0000_01b3);
    }
    let mut parts = [0u32; 4];
    for part in parts.iter_mut() {
        state ^= state << 13; state ^= state >> 7; state ^= state << 17;
        *part = (state >> 32) as u32;
    }
    format!("{:08X}-{:04X}-5{:03X}-{:04X}-{:012X}",
            parts[0], parts[1] >> 16, parts[1] & 0xFFF,
            (parts[2] >> 16) | 0x8000, ((parts[2] as u64) << 16) | (parts[3] as u64 >> 16))
}

pub fn write_profiles(brands: &[Brand], font_postscript: Option<&str>,
                      output_root: &Path) -> Result<PathBuf> {
    let mut profiles = Vec::new();
    for brand in brands {
        let colours = palette::terminal_palette(brand);
        let mut profile = Map::new();
        profile.insert("Guid".into(), json!(stable_guid(&brand.key)));
        profile.insert("Name".into(), json!(brand.profile_name()));
        profile.insert("Tags".into(), json!(["Brand", brand.name]));
        // 라이트/다크 모드별 색을 따로 두지 않는다. 따로 두면 macOS가 라이트 모드일 때
        // 배경이 흰색이 되어, 브랜드 색 프롬프트가 흰 바탕에 떠 보였다.
        profile.insert("Use Separate Colors for Light and Dark Mode".into(), json!(false));
        profile.insert("Draw Powerline Glyphs".into(), json!(true));
        profile.insert("Minimum Contrast".into(), json!(0.0));
        // 여러 회사 창을 동시에 띄웠을 때 탭 색으로 한눈에 구분된다.
        profile.insert("Use Tab Color".into(), json!(true));
        profile.insert("Tab Color".into(), colour(colours.accent, 1.0));
        // 뱃지는 넣지 않는다. 회사 이름이 창 오른쪽 위에 반투명하게 크게 찍혀 워터마크처럼
        // 화면을 가렸다.
        if let Some(name) = font_postscript {
            // 로고 글리프가 이 폰트에만 있으므로 프로필이 폰트를 직접 지정해야 한다.
            profile.insert("Normal Font".into(), json!(format!("{name} 13")));
        }
        profile.insert("Background Color".into(), colour(colours.background, 1.0));
        profile.insert("Foreground Color".into(), colour(colours.foreground, 1.0));
        profile.insert("Bold Color".into(), colour(colours.foreground, 1.0));
        profile.insert("Cursor Color".into(), colour(colours.accent, 1.0));
        profile.insert("Cursor Text Color".into(), colour(colours.background, 1.0));
        profile.insert("Link Color".into(), colour(colours.accent, 1.0));
        profile.insert("Selection Color".into(), colour(colours.selection, 1.0));
        profile.insert("Selected Text Color".into(), colour(colours.foreground, 1.0));
        for (index, value) in colours.ansi.iter().enumerate() {
            profile.insert(format!("Ansi {index} Color"), colour(*value, 1.0));
        }
        // 배경 워터마크와 탭 아이콘은 넣지 않는다.
        // 이 두 키는 로고 PNG의 절대경로를 요구하는데, 그 경로는 빌드한 머신에만 존재한다.
        // 산출물을 커밋해 배포하는 구조에서 다른 사람이 clone하면 없는 파일을 가리키게 된다.
        profiles.push(Value::Object(profile));
    }

    let output = output_root.join("iterm2").join("brand-themes.json");
    std::fs::create_dir_all(output.parent().unwrap())?;
    std::fs::write(&output, serde_json::to_string_pretty(&json!({"Profiles": profiles}))? + "\n")?;
    Ok(output)
}

#[cfg(test)]
#[allow(non_snake_case)]   // 테스트 이름은 동작 서술형 한국어를 쓴다
mod tests {
    use super::*;

    #[test]
    fn 브랜드_프로필은_macOS_모드와_상관없이_검정_배경에_흰_글자이고_뱃지가_없다() {
        // macOS 라이트 모드에서 흰 배경이 되고, 회사 이름 뱃지가 워터마크처럼 찍혔다.
        let root = std::env::temp_dir()
            .join(format!("oh-my-terminal-iterm2-{}", std::process::id()));
        let kakao = Brand { key: "kakao".into(), name: "Kakao".into(), country: None, primary: "#FEE500".into(),
                            secondary: "#333333".into(), logo: None, verified: None,
                            logo_path: None };
        let output = write_profiles(&[kakao], None, &root).unwrap();
        let document: Value = serde_json::from_str(&std::fs::read_to_string(&output).unwrap()).unwrap();
        let _ = std::fs::remove_dir_all(&root);

        let profile = &document["Profiles"][0];
        // 셸이 ITERM_PROFILE을 이 이름과 맞춰 회사를 고른다.
        assert_eq!(profile["Name"], json!("Kakao Brand"));
        assert_eq!(profile["Use Separate Colors for Light and Dark Mode"], json!(false));
        assert_eq!(profile["Background Color"], colour(palette::hex_to_rgb("#000000"), 1.0));
        assert_eq!(profile["Foreground Color"], colour(palette::hex_to_rgb("#FFFFFF"), 1.0));
        let keys: Vec<&String> = profile.as_object().unwrap().keys().collect();
        assert!(keys.iter().all(|key| !key.starts_with("Badge") && !key.contains("(Light)")),
                "뱃지나 라이트 모드 전용 색이 남았다: {keys:?}");
    }
}
