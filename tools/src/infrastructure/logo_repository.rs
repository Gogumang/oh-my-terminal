//! 로고를 어디서 가져와 어떻게 다듬을지 아는 어댑터.
//!
//! 우선순위:
//!   1. logos/<key>.color.png  — 사용자가 넣은 원본 컬러 로고 (실루엣이 불가능한 앱 아이콘)
//!   2. logos/<key>.custom.png — 사용자가 넣은 실루엣용 로고
//!   3. 원격 (Simple Icons / 파비콘 / GitHub 아바타)
//! 사용자가 넣은 파일은 절대 덮어쓰지 않는다.

use std::path::{Path, PathBuf};
use std::time::Duration;

use anyhow::{anyhow, Result};
use image::RgbaImage;

use super::logo_shaper as shaper;
use super::rasterizer::rasterize_svg;
use crate::domain::brand::Brand;

pub const LOGO_SIZE: u32 = 512;
const TIMEOUT: Duration = Duration::from_secs(20);
/// 실루엣이 형태를 잃는 구간. 통짜 덩어리이거나 거의 빈 이미지면 알아볼 수 없다.
const USABLE_COVERAGE: (f64, f64) = (0.06, 0.70);

pub struct LogoRepository {
    directory: PathBuf,
    pub notes: Vec<String>,
}

impl LogoRepository {
    pub fn new(directory: impl AsRef<Path>) -> Self {
        Self { directory: directory.as_ref().to_path_buf(), notes: Vec::new() }
    }

    pub fn prepare(&mut self, brand: &Brand) -> Option<PathBuf> {
        let target = self.directory.join(format!("{}.png", brand.key));

        let colour_logo = self.directory.join(format!("{}.color.png", brand.key));
        if colour_logo.exists() {
            if let Ok(image) = image::open(&colour_logo) {
                let cleaned = shaper::clear_corner_background(&image.to_rgba8());
                let _ = shaper::fit(&shaper::crop_to_content(&cleaned), LOGO_SIZE).save(&target);
                return Some(target);
            }
        }

        let custom_logo = self.directory.join(format!("{}.custom.png", brand.key));
        if custom_logo.exists() {
            if let Ok(image) = image::open(&custom_logo) {
                let shape = shaper::to_silhouette(&image.to_rgba8());
                let _ = shaper::fit(&shaper::crop_to_content(&shape), LOGO_SIZE).save(&target);
                return Some(target);
            }
        }

        let source = brand.logo.as_ref()?;
        let image = match self.download(&source.url) {
            Ok(image) => image,
            Err(error) => {                        // 로고는 보조 데이터 — 색은 살린다
                self.notes.push(format!("{}: 내려받기 실패 ({error})", brand.name));
                let _ = std::fs::remove_file(&target);
                return None;
            }
        };

        if source.keep_colour {
            // 색 면에서 글자를 파낸 앱 아이콘은 실루엣으로 만들면 통짜 도형이 된다.
            let cleaned = shaper::clear_corner_background(&image);
            let _ = shaper::fit(&shaper::crop_to_content(&cleaned), LOGO_SIZE).save(&target);
            return Some(target);
        }

        let mut shape = shaper::crop_to_content(&shaper::to_silhouette(&image));
        // Simple Icons는 단색 아이콘용으로 설계돼 점유율이 높아도 형태가 살아있다
        // (네이버의 굵은 N이 80%). 파비콘만 형태 검사·반전 대상이다.
        if source.kind != "simpleicons" {
            if shaper::alpha_coverage(&shape) > USABLE_COVERAGE.1 {
                shape = shaper::invert_alpha(&shape);
            }
            let coverage = shaper::alpha_coverage(&shape);
            if coverage < USABLE_COVERAGE.0 || coverage > USABLE_COVERAGE.1 {
                self.notes.push(format!("{}: 실루엣이 형태를 잃음 (점유율 {:.0}%)",
                                        brand.name, coverage * 100.0));
                let _ = std::fs::remove_file(&target);
                return None;
            }
        }
        let _ = shaper::fit(&shaper::crop_to_content(&shape), LOGO_SIZE).save(&target);
        Some(target)
    }

    fn download(&self, url: &str) -> Result<RgbaImage> {
        let response = ureq::AgentBuilder::new()
            .timeout(TIMEOUT).user_agent("Mozilla/5.0 (oh-my-terminal)").build()
            .get(url).call()?;
        let mut data = Vec::new();
        std::io::Read::read_to_end(&mut response.into_reader(), &mut data)?;
        if data.is_empty() {
            return Err(anyhow!("빈 응답"));
        }
        let head = &data[..data.len().min(400)];
        if head.starts_with(b"<svg") || twoway_contains(head, b"<svg") {
            let rendered = rasterize_svg(&data, LOGO_SIZE)?;
            // resvg 알파는 정확하니 그대로 믿는다. 다만 <rect>로 배경을 꽉 칠한 SVG
            // (무신사 favicon.svg)는 투명 영역이 거의 없다 — 그때만 배경을 걷어낸다.
            return Ok(if shaper::alpha_coverage(&rendered) > 0.95 {
                shaper::strip_uniform_background(&rendered)
            } else {
                rendered
            });
        }
        if twoway_contains(head, b"<html") || twoway_contains(head, b"<!DOCTYPE") {
            return Err(anyhow!("이미지가 아니라 HTML이 왔다 (봇 차단으로 보인다)"));
        }
        let decoded = image::load_from_memory(&data)?.to_rgba8();
        Ok(shaper::strip_uniform_background(&decoded))
    }
}

fn twoway_contains(haystack: &[u8], needle: &[u8]) -> bool {
    haystack.windows(needle.len()).any(|window| window == needle)
}
