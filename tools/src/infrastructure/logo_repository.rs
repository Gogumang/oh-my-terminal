//! 로고를 어디서 가져와 어떻게 다듬을지 아는 어댑터.
//!
//! 우선순위:
//!   1. public/logo/<key>.png  — 저장소에 커밋된 완성 로고. 가공 없이 그대로 쓴다.
//!   2. logos/<key>.color.png  — 원본 컬러로 가공할 소스 (실루엣이 불가능한 앱 아이콘)
//!   3. logos/<key>.custom.png — 실루엣으로 가공할 소스
//!   4. 원격 (Simple Icons / 파비콘 / GitHub 아바타)
//!
//! 1번이 있으면 빌드에 네트워크가 필요 없다. 원격 출처는 사라지거나 봇 차단으로 막히고
//! (쿠팡이 그랬다), 파비콘은 해상도가 낮은 경우가 많아 결과가 흔들린다.
//! 사용자가 넣은 파일은 어느 것도 덮어쓰지 않는다.

use std::path::{Path, PathBuf};
use std::time::Duration;

use anyhow::{anyhow, Result};
use image::RgbaImage;

use super::logo_shaper as shaper;
use super::rasterizer::rasterize_svg;
use crate::domain::brand::Brand;

pub const LOGO_SIZE: u32 = 512;
const TIMEOUT: Duration = Duration::from_secs(8);
/// 실루엣이 형태를 잃는 구간. 통짜 덩어리이거나 거의 빈 이미지면 알아볼 수 없다.
const USABLE_COVERAGE: (f64, f64) = (0.06, 0.70);

pub struct LogoRepository {
    directory: PathBuf,
    committed: PathBuf,
    pub notes: Vec<String>,
}

impl LogoRepository {
    pub fn new(directory: impl AsRef<Path>, committed: impl AsRef<Path>) -> Self {
        Self { directory: directory.as_ref().to_path_buf(),
               committed: committed.as_ref().to_path_buf(), notes: Vec::new() }
    }

    pub fn prepare(&mut self, brand: &Brand) -> Option<PathBuf> {
        let target = self.directory.join(format!("{}.png", brand.key));

        // 커밋된 완성 로고가 있으면 그대로 쓴다 — 가공도 네트워크도 없다.
        let committed = self.committed.join(format!("{}.png", brand.key));
        if committed.exists() {
            if let Err(error) = std::fs::copy(&committed, &target) {
                self.notes.push(format!("{}: 커밋된 로고 복사 실패 ({error})", brand.name));
                return None;
            }
            return Some(target);
        }

        let colour_logo = self.directory.join(format!("{}.color.png", brand.key));
        if colour_logo.exists() {
            if let Ok(image) = image::open(&colour_logo) {
                let cleaned = shaper::clear_corner_background(&image.to_rgba8());
                return self.save(shaper::fit(&shaper::crop_to_content(&cleaned), LOGO_SIZE),
                                 &target, &brand.name);
            }
        }

        let custom_logo = self.directory.join(format!("{}.custom.png", brand.key));
        if custom_logo.exists() {
            if let Ok(image) = image::open(&custom_logo) {
                let shape = shaper::to_silhouette(&image.to_rgba8());
                return self.save(shaper::fit(&shaper::crop_to_content(&shape), LOGO_SIZE),
                                 &target, &brand.name);
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
            return self.save(shaper::fit(&shaper::crop_to_content(&cleaned), LOGO_SIZE),
                             &target, &brand.name);
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
        self.save(shaper::fit(&shaper::crop_to_content(&shape), LOGO_SIZE), &target, &brand.name)
    }

    /// 저장 실패를 삼키면 존재하지 않는 경로가 logo_path에 남아, 나중에 폰트 생성이
    /// 빌드 전체를 실패시킨다. 로고는 보조 데이터이므로 여기서 노트로 남기고 없던 일로 한다.
    fn save(&mut self, image: RgbaImage, target: &Path, brand_name: &str) -> Option<PathBuf> {
        match image.save(target) {
            Ok(()) => Some(target.to_path_buf()),
            Err(error) => {
                self.notes.push(format!("{brand_name}: 로고 저장 실패 ({error})"));
                let _ = std::fs::remove_file(target);
                None
            }
        }
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
            return Ok(if shaper::needs_background_strip(&rendered) {
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
