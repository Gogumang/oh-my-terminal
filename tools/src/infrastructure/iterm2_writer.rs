//! iTerm2 Dynamic Profile 생성기.
//!
//! .itermcolors가 아니라 Dynamic Profile을 쓰는 이유: 색만이 아니라 배경 로고·탭 색·
//! 뱃지·폰트까지 담을 수 있고, 파일을 폴더에 넣기만 하면 iTerm2가 재시작 없이 즉시 반영한다.

use std::path::{Path, PathBuf};

use anyhow::Result;
use serde_json::{json, Map, Value};

use crate::domain::brand::Brand;
use crate::domain::palette::{self, ModePalette, Rgb};

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

fn mode_entries(profile: &mut Map<String, Value>, mode: &str, entry: &ModePalette) {
    profile.insert(format!("Background Color ({mode})"), colour(entry.background, 1.0));
    profile.insert(format!("Foreground Color ({mode})"), colour(entry.foreground, 1.0));
    profile.insert(format!("Cursor Color ({mode})"), colour(entry.accent, 1.0));
    profile.insert(format!("Cursor Text Color ({mode})"), colour(entry.background, 1.0));
    profile.insert(format!("Badge Color ({mode})"), colour(entry.accent, 0.45));
    profile.insert(format!("Link Color ({mode})"), colour(entry.accent, 1.0));
    profile.insert(format!("Selection Color ({mode})"), colour(entry.selection, 1.0));
    profile.insert(format!("Selected Text Color ({mode})"), colour(entry.foreground, 1.0));
    for (index, value) in entry.ansi.iter().enumerate() {
        profile.insert(format!("Ansi {index} Color ({mode})"), colour(*value, 1.0));
    }
}

pub fn write_profiles(brands: &[Brand], font_postscript: Option<&str>,
                      output_root: &Path) -> Result<PathBuf> {
    let mut profiles = Vec::new();
    for brand in brands {
        let (dark, light) = palette::terminal_palette(brand);
        let mut profile = Map::new();
        profile.insert("Guid".into(), json!(stable_guid(&brand.key)));
        profile.insert("Name".into(), json!(format!("{} Brand", brand.name)));
        profile.insert("Tags".into(), json!(["Brand", brand.name]));
        profile.insert("Use Separate Colors for Light and Dark Mode".into(), json!(true));
        profile.insert("Draw Powerline Glyphs".into(), json!(true));
        profile.insert("Minimum Contrast".into(), json!(0.0));
        // 여러 회사 창을 동시에 띄웠을 때 탭 색으로 한눈에 구분된다.
        profile.insert("Use Tab Color".into(), json!(true));
        profile.insert("Tab Color".into(), colour(dark.accent, 1.0));
        profile.insert("Badge Text".into(), json!(brand.name));
        profile.insert("Badge Max Width".into(), json!(0.3));
        profile.insert("Badge Max Height".into(), json!(0.15));
        if let Some(name) = font_postscript {
            // 로고 글리프가 이 폰트에만 있으므로 프로필이 폰트를 직접 지정해야 한다.
            profile.insert("Normal Font".into(), json!(format!("{name} 13")));
        }
        mode_entries(&mut profile, "Dark", &dark);
        mode_entries(&mut profile, "Light", &light);
        if let Some(path) = &brand.logo_path {
            let absolute = std::fs::canonicalize(path)?.to_string_lossy().to_string();
            profile.insert("Background Image Location".into(), json!(absolute));
            profile.insert("Background Image Mode".into(), json!(3));  // aspect fit
            profile.insert("Blend".into(), json!(0.08));               // 워터마크 수준
            profile.insert("Icon".into(), json!(2));                   // custom
            profile.insert("Custom Icon Path".into(), json!(absolute));
        }
        profiles.push(Value::Object(profile));
    }

    let output = output_root.join("iterm2").join("brand-themes.json");
    std::fs::create_dir_all(output.parent().unwrap())?;
    std::fs::write(&output, serde_json::to_string_pretty(&json!({"Profiles": profiles}))? + "\n")?;
    Ok(output)
}
