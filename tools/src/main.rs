//! 진입점 — 어댑터를 조립해 유스케이스를 실행한다 (interfaces 레이어).
//!
//!   build-themes              테마 생성 (기본)
//!   build-themes catalog <경로>   oh-my-design 데이터셋 → catalog/brands.json
//!   build-themes enable <키>...   카탈로그에서 회사를 골라 brands/ 에 추가

mod application;
mod domain;
mod infrastructure;

mod catalog;

use std::path::{Path, PathBuf};

use anyhow::{anyhow, Result};

/// 저장소 어디서 실행하든 루트를 찾는다 (brands/ 와 catalog/ 가 있는 곳).
/// 못 찾으면 조용히 cwd로 떨어지지 않는다 — 저장소 밖에서 실행했을 때
/// 깊은 곳의 "No such file or directory" 대신 원인을 바로 말해야 한다.
fn project_root() -> Result<PathBuf> {
    let start = std::env::current_dir()?;
    let mut current = start.clone();
    loop {
        if current.join("brands").is_dir() && current.join("catalog").is_dir() {
            return Ok(current);
        }
        match current.parent() {
            Some(parent) => current = parent.to_path_buf(),
            None => return Err(anyhow!(
                "저장소 루트를 못 찾았다 ({}부터 위로 훑음). brands/ 와 catalog/ 가 있는 \
                 디렉터리 안에서 실행할 것", start.display())),
        }
    }
}

/// 로고 글리프를 얹을 기반 폰트.
///
/// 예전에는 MesloLGS NF로 못박아 뒀는데, 브랜드 프로필이 그 폰트를 주 폰트로 지정하므로
/// 한글 폰트(D2Coding 등)를 쓰던 사용자는 회사 폴더에서 한글이 시스템 폴백으로 떨어졌다.
/// 지금 쓰는 폰트를 그대로 패치해야 원래 보던 글자가 유지된다.
///   OH_MY_TERMINAL_BASE_FONT=/path/to/Font.ttf 로 지정
fn base_font() -> Result<PathBuf> {
    if let Ok(configured) = std::env::var("OH_MY_TERMINAL_BASE_FONT") {
        let path = PathBuf::from(configured);
        if !path.exists() {
            return Err(anyhow!("지정한 기반 폰트가 없다: {}", path.display()));
        }
        return Ok(path);
    }
    let fonts = PathBuf::from(std::env::var("HOME")?).join("Library/Fonts");
    let fallback = fonts.join("MesloLGS NF Regular.ttf");
    if fallback.exists() {
        return Ok(fallback);
    }
    Err(anyhow!("기반 폰트를 찾지 못했다. OH_MY_TERMINAL_BASE_FONT 로 지정하거나 \
        p10k 권장 폰트를 설치할 것 (p10k configure)"))
}

fn main() -> Result<()> {
    let arguments: Vec<String> = std::env::args().skip(1).collect();
    let root = project_root()?;

    match arguments.first().map(String::as_str) {
        Some("catalog") => {
            let dataset = arguments.get(1)
                .ok_or_else(|| anyhow!("사용법: build-themes catalog <oh-my-design/design-md 경로>"))?;
            catalog::build(Path::new(dataset), &root)
        }
        Some("enable") => {
            if arguments.len() < 2 {
                return Err(anyhow!("사용법: build-themes enable <회사키>..."));
            }
            catalog::enable(&arguments[1..], &root)
        }
        _ => build(&root),
    }
}

fn build(root: &Path) -> Result<()> {
    let report = application::build_themes::run(root, &base_font()?)?;
    for entry in &report.brands {
        println!("  {} {:<11} 대비 {:.1}:1  그라데이션 깊이 {:.0}%",
                 if entry.has_logo { "로고" } else { "  · " },
                 entry.name, entry.contrast, entry.depth * 100.0);
    }
    for warning in &report.warnings {
        eprintln!("  ! {warning}");
    }
    println!("\n생성물 {}개:", report.outputs.len());
    for path in &report.outputs {
        let size = std::fs::metadata(path).map(|m| m.len()).unwrap_or(0);
        let shown = path.strip_prefix(root).unwrap_or(path);
        println!("  {}  ({size}B)", shown.display());
    }
    Ok(())
}
