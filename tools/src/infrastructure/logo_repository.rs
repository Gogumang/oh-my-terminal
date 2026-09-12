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
use std::sync::OnceLock;
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
}

/// 로고 하나를 준비한 결과. 실패 사유(노트)를 리포지터리에 쌓지 않고 돌려준다 —
/// 여러 회사를 동시에 준비할 때 공유 가변 상태가 있으면 병렬로 돌릴 수 없고,
/// 노트가 쌓이는 순서도 실행마다 달라진다.
pub struct Prepared {
    pub path: Option<PathBuf>,
    pub notes: Vec<String>,
}

impl Prepared {
    fn done(path: PathBuf) -> Self {
        Self { path: Some(path), notes: Vec::new() }
    }

    fn failed(note: String) -> Self {
        Self { path: None, notes: vec![note] }
    }

    fn nothing() -> Self {
        Self { path: None, notes: Vec::new() }
    }
}

impl LogoRepository {
    pub fn new(directory: impl AsRef<Path>, committed: impl AsRef<Path>) -> Self {
        Self { directory: directory.as_ref().to_path_buf(),
               committed: committed.as_ref().to_path_buf() }
    }

    pub fn prepare(&self, brand: &Brand) -> Prepared {
        // logos/ 는 gitignore 대상이라 새로 받은 저장소에는 없다. 만들지 않으면 커밋된 로고
        // 복사가 전부 실패해, 빌드는 성공하는데 로고 없는 폰트·프롬프트가 조용히 생성된다.
        if let Err(error) = std::fs::create_dir_all(&self.directory) {
            return Prepared::failed(format!("{}: 로고 작업 디렉터리 생성 실패 ({error})", brand.name));
        }
        let target = self.directory.join(format!("{}.png", brand.key));

        // 커밋된 완성 로고가 있으면 그대로 쓴다 — 가공도 네트워크도 없다.
        let committed = self.committed.join(format!("{}.png", brand.key));
        if committed.exists() {
            if let Err(error) = std::fs::copy(&committed, &target) {
                return Prepared::failed(format!("{}: 커밋된 로고 복사 실패 ({error})", brand.name));
            }
            return Prepared::done(target);
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

        let Some(source) = brand.logo.as_ref() else { return Prepared::nothing() };
        let image = match self.download(&source.url) {
            Ok(image) => image,
            Err(error) => {                        // 로고는 보조 데이터 — 색은 살린다
                let _ = std::fs::remove_file(&target);
                return Prepared::failed(format!("{}: 내려받기 실패 ({error})", brand.name));
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
                let _ = std::fs::remove_file(&target);
                return Prepared::failed(format!("{}: 실루엣이 형태를 잃음 (점유율 {:.0}%)",
                                                brand.name, coverage * 100.0));
            }
        }
        self.save(shaper::fit(&shaper::crop_to_content(&shape), LOGO_SIZE), &target, &brand.name)
    }

    /// 저장 실패를 삼키면 존재하지 않는 경로가 logo_path에 남아, 나중에 폰트 생성이
    /// 빌드 전체를 실패시킨다. 로고는 보조 데이터이므로 여기서 노트로 남기고 없던 일로 한다.
    fn save(&self, image: RgbaImage, target: &Path, brand_name: &str) -> Prepared {
        match image.save(target) {
            Ok(()) => Prepared::done(target.to_path_buf()),
            Err(error) => {
                let _ = std::fs::remove_file(target);
                Prepared::failed(format!("{brand_name}: 로고 저장 실패 ({error})"))
            }
        }
    }

    fn download(&self, url: &str) -> Result<RgbaImage> {
        let data = fetch_bytes(url)?;
        let image = decode_image(&data)?;
        if is_svg(&data) {
            // resvg 알파는 정확하니 그대로 믿는다. 다만 <rect>로 배경을 꽉 칠한 SVG
            // (무신사 favicon.svg)는 투명 영역이 거의 없다 — 그때만 배경을 걷어낸다.
            return Ok(if shaper::needs_background_strip(&image) {
                shaper::strip_uniform_background(&image)
            } else {
                image
            });
        }
        Ok(shaper::strip_uniform_background(&image))
    }
}

/// 내려받기용 HTTP 에이전트. 요청마다 새로 만들면 연결과 TLS 악수를 매번 다시 한다 —
/// 로고 수백 개가 같은 호스트(cdn.simpleicons.org)에서 오므로 하나를 공유해 연결을 재사용한다.
/// 에이전트는 내부적으로 스레드 안전하다 (Clone은 같은 연결 풀을 가리킨다).
fn agent() -> &'static ureq::Agent {
    static AGENT: OnceLock<ureq::Agent> = OnceLock::new();
    AGENT.get_or_init(|| ureq::AgentBuilder::new()
        .timeout(TIMEOUT).user_agent("Mozilla/5.0 (oh-my-terminal)").build())
}

/// 원격 파일을 받는다. 봇 차단을 피하려고 브라우저 계열 User-Agent를 쓴다.
pub fn fetch_bytes(url: &str) -> Result<Vec<u8>> {
    let response = agent().get(url).call()?;
    let mut data = Vec::new();
    std::io::Read::read_to_end(&mut response.into_reader(), &mut data)?;
    if data.is_empty() {
        return Err(anyhow!("빈 응답"));
    }
    Ok(data)
}

/// 로고 파일(SVG·PNG·JPEG·ICO)을 RGBA로 푼다. 배경은 건드리지 않는다 —
/// 원본 모양에 맞는 가공은 부르는 쪽이 고른다.
pub fn decode_image(data: &[u8]) -> Result<RgbaImage> {
    if is_svg(data) {
        return rasterize_svg(data, LOGO_SIZE);
    }
    let head = &data[..data.len().min(400)];
    if twoway_contains(head, b"<html") || twoway_contains(head, b"<!DOCTYPE") {
        return Err(anyhow!("이미지가 아니라 HTML이 왔다 (봇 차단으로 보인다)"));
    }
    Ok(image::load_from_memory(data)?.to_rgba8())
}

fn is_svg(data: &[u8]) -> bool {
    let head = &data[..data.len().min(400)];
    head.starts_with(b"<svg") || twoway_contains(head, b"<svg")
}

fn twoway_contains(haystack: &[u8], needle: &[u8]) -> bool {
    haystack.windows(needle.len()).any(|window| window == needle)
}

#[cfg(test)]
#[allow(non_snake_case)]   // 테스트 이름은 동작 서술형 한국어를 쓴다
mod tests {
    use super::*;

    #[test]
    fn 작업_디렉터리가_없어도_커밋된_로고를_가져온다() {
        // 새로 받은 저장소에서 빌드하자 279개 복사가 전부 실패했는데 빌드는 성공해,
        // 폰트 없이 로고 빠진 프롬프트와 프로필이 만들어졌다.
        let root = std::env::temp_dir()
            .join(format!("oh-my-terminal-logos-{}", std::process::id()));
        let committed = root.join("public/logo");
        std::fs::create_dir_all(&committed).unwrap();
        std::fs::write(committed.join("t.png"), b"png").unwrap();

        let repository = LogoRepository::new(root.join("logos"), &committed);
        let brand = Brand { key: "t".into(), name: "T".into(), country: None, primary: "#0064FF".into(),
                            secondary: "#0064FF".into(), logo: None, verified: None,
                            logo_path: None };
        let prepared = repository.prepare(&brand);
        let _ = std::fs::remove_dir_all(&root);

        assert!(prepared.notes.is_empty(), "노트가 남았다: {:?}", prepared.notes);
        assert_eq!(prepared.path, Some(root.join("logos/t.png")));
    }
}
