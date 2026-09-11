//! 로고를 새 출처로 교체하는 도구 (build-themes import).
//!
//! 카탈로그 출처가 엉뚱한 이미지(배너·다른 브랜드·흐린 파비콘)이거나, 원본 모양이 알파만 쓰는
//! 렌더러에서 뭉개지는 경우(색 면에 글자를 파낸 배지)에 사람이 출처와 가공 방식을 골라 바꾼다.
//! 결과는 public/logo/<키>.png 에 쓰고, 출처는 brands/<키>.yaml 에 남겨 다시 만들 수 있게 한다.

use std::path::Path;

use anyhow::{anyhow, Result};
use image::RgbaImage;

use crate::domain::brand::{Brand, LogoSource};
use crate::infrastructure::logo_repository::{decode_image, fetch_bytes, LOGO_SIZE};
use crate::infrastructure::logo_shaper as shaper;

/// 원본 모양에 따른 가공 방식.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Mode {
    /// 투명 배경의 마크(기본). 통배경이 깔려 있으면 모서리에서 번져 걷어낸다.
    Mark,
    /// 색 면 위에 마크가 있는 앱 아이콘. 면(가장 많은 색)을 지우고 마크를 남긴다.
    Icon,
    /// 색 면에 글자를 파낸 배지. 면을 남기고 글자를 구멍으로 뚫는다.
    Badge,
}

impl Mode {
    pub fn parse(flag: Option<&str>) -> Result<Mode> {
        match flag {
            None => Ok(Mode::Mark),
            Some("--icon") => Ok(Mode::Icon),
            Some("--badge") => Ok(Mode::Badge),
            Some(other) => Err(anyhow!("모르는 옵션 {other} (--icon 또는 --badge)")),
        }
    }

    fn name(self) -> &'static str {
        match self {
            Mode::Mark => "mark",
            Mode::Icon => "icon",
            Mode::Badge => "badge",
        }
    }
}

/// 원본 이미지를 여백 없는 알파 실루엣(512×512)으로 가공한다.
pub fn shape(image: &RgbaImage, mode: Mode) -> RgbaImage {
    let shaped = match mode {
        Mode::Mark if shaper::needs_background_strip(image) => shaper::clear_corner_background(image),
        Mode::Mark => image.clone(),
        Mode::Icon => shaper::remove_dominant_colour(image),
        Mode::Badge => shaper::cut_minor_colours(image),
    };
    shaper::fit(&shaper::crop_to_content(&shaper::to_silhouette(&shaped)), LOGO_SIZE)
}

pub fn import(key: &str, source: &str, mode: Mode, root: &Path) -> Result<()> {
    let yaml = root.join(format!("brands/{key}.yaml"));
    let text = std::fs::read_to_string(&yaml)
        .map_err(|_| anyhow!("켜진 회사가 아니다: {key} (brands/{key}.yaml 없음)"))?;
    let data = if source.starts_with("http://") || source.starts_with("https://") {
        fetch_bytes(source)?
    } else {
        std::fs::read(source)?
    };
    let logo = shape(&decode_image(&data)?, mode);
    let coverage = shaper::alpha_coverage(&logo);
    if coverage < 0.02 {
        return Err(anyhow!("{key}: 가공 결과가 거의 비었다 (점유율 {:.0}%) — 다른 방식이나 출처를 쓸 것",
                           coverage * 100.0));
    }
    logo.save(root.join(format!("public/logo/{key}.png")))?;

    // 맨 위 주석은 그대로 두고 로고 출처만 바꾼다.
    let header: String = text.lines().take_while(|line| line.starts_with('#'))
        .map(|line| format!("{line}\n")).collect();
    let mut brand: Brand = serde_yaml::from_str(&text)?;
    brand.logo = Some(LogoSource { kind: format!("import-{}", mode.name()), url: source.to_string(),
                                   keep_colour: false });
    std::fs::write(&yaml, header + &serde_yaml::to_string(&brand)?)?;
    println!("{key}: {source} ({}) → public/logo/{key}.png  점유율 {:.0}%", mode.name(), coverage * 100.0);
    Ok(())
}

#[cfg(test)]
#[allow(non_snake_case)]   // 테스트 이름은 동작 서술형 한국어를 쓴다
mod tests {
    use super::*;

    #[test]
    fn 옵션은_세_가지만_받는다() {
        assert_eq!(Mode::parse(None).unwrap(), Mode::Mark);
        assert_eq!(Mode::parse(Some("--icon")).unwrap(), Mode::Icon);
        assert_eq!(Mode::parse(Some("--badge")).unwrap(), Mode::Badge);
        assert!(Mode::parse(Some("--bogus")).is_err());
    }
}
