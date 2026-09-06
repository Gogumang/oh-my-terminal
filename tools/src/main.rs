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

fn project_root() -> PathBuf {
    // 저장소 어디서 실행하든 루트를 찾는다 (brands/ 가 있는 곳).
    let mut current = std::env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
    loop {
        if current.join("brands").is_dir() && current.join("catalog").is_dir() {
            return current;
        }
        match current.parent() {
            Some(parent) => current = parent.to_path_buf(),
            None => return std::env::current_dir().unwrap_or_else(|_| PathBuf::from(".")),
        }
    }
}

fn base_font() -> Result<PathBuf> {
    let path = PathBuf::from(std::env::var("HOME")?).join("Library/Fonts/MesloLGS NF Regular.ttf");
    if !path.exists() {
        return Err(anyhow!("기반 폰트가 없다: {}\n  \
            p10k 권장 폰트(MesloLGS NF)를 먼저 설치할 것: p10k configure", path.display()));
    }
    Ok(path)
}

fn main() -> Result<()> {
    let arguments: Vec<String> = std::env::args().skip(1).collect();
    let root = project_root();

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
