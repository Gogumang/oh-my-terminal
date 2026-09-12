//! oh-my-design(MIT) 데이터셋을 다루는 도구.
//!
//! 440개 회사의 브랜드 색·로고 출처를 언어 중립 JSON 하나로 모은다. 색을 손으로 적지
//! 않는 것이 요점이다 — 이 데이터셋은 각 색의 출처와 수집일을 기록해 두어 손으로 넣은
//! 값보다 정확하고 갱신도 추적된다.

use std::collections::BTreeMap;
use std::path::Path;
use std::sync::atomic::{AtomicUsize, Ordering};

use anyhow::{anyhow, Result};
use rayon::prelude::*;
use serde::{Deserialize, Serialize};

use crate::domain::brand::{Brand, LogoSource};
use crate::infrastructure::logo_repository::LogoRepository;

const CATALOG_VERSION: u32 = 1;

#[derive(Serialize, Deserialize)]
pub struct Entry {
    pub key: String,
    pub name: String,
    pub country: Option<String>,
    pub category: Option<String>,
    pub primary: String,
    pub secondary: String,
    pub colors: BTreeMap<String, String>,
    pub logo: Option<LogoEntry>,
    pub verified: Option<String>,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct LogoEntry {
    pub kind: String,
    pub reference: String,
    pub url: String,
}

#[derive(Serialize, Deserialize)]
pub struct Catalog {
    pub version: u32,
    pub source: BTreeMap<String, String>,
    pub brands: Vec<Entry>,
}

fn frontmatter(text: &str) -> &str {
    text.strip_prefix("---\n")
        .and_then(|rest| rest.split_once("\n---").map(|(head, _)| head))
        .unwrap_or("")
}

fn scalar(block: &str, key: &str) -> Option<String> {
    block.lines().find_map(|line| {
        let rest = line.strip_prefix(key)?.strip_prefix(':')?;
        Some(rest.trim().trim_matches('"').to_string())
    }).filter(|value| !value.is_empty())
}

fn logo_entry(block: &str) -> Option<LogoEntry> {
    let start = block.lines().position(|line| line.starts_with("logo:"))?;
    let body: Vec<&str> = block.lines().skip(start + 1)
        .take_while(|line| line.starts_with("  ")).collect();
    let field = |key: &str| body.iter().find_map(|line| {
        let rest = line.trim().strip_prefix(key)?.strip_prefix(':')?;
        Some(rest.trim().trim_matches('"').to_string())
    });
    let kind = field("type")?;
    let reference = field("slug")?;
    let url = match kind.as_str() {
        "simpleicons" => format!("https://cdn.simpleicons.org/{reference}/000000"),
        "github" => format!("https://github.com/{reference}.png?size=512"),
        _ => reference.clone(),
    };
    Some(LogoEntry { kind, reference, url })
}

fn semantic_colours(text: &str) -> BTreeMap<String, String> {
    let mut found = BTreeMap::new();
    let Some(start) = text.lines().position(|line| line.trim_end() == "  colors:") else {
        return found;
    };
    for line in text.lines().skip(start + 1) {
        if !line.starts_with("    ") { break; }
        if let Some((key, value)) = line.trim().split_once(':') {
            let value = value.trim().trim_matches('"');
            if value.starts_with('#') {
                found.insert(key.to_string(), value.to_uppercase());
            }
        }
    }
    found
}

pub fn build(dataset: &Path, root: &Path) -> Result<()> {
    if !dataset.exists() {
        return Err(anyhow!("데이터셋을 찾을 수 없다: {}", dataset.display()));
    }
    let mut directories: Vec<_> = std::fs::read_dir(dataset)?
        .filter_map(|entry| entry.ok().map(|e| e.path()))
        .filter(|path| path.is_dir()).collect();
    directories.sort();

    let mut entries = Vec::new();
    let mut skipped = 0;
    for directory in directories {
        let design = directory.join("DESIGN.md");
        if !design.exists() { continue; }
        let text = std::fs::read_to_string(&design)?;
        let block = frontmatter(&text);
        let Some(primary) = scalar(block, "primary_color") else {  // 핵심 데이터
            skipped += 1;
            continue;
        };
        let key = directory.file_name().unwrap().to_string_lossy().to_string();
        let colours = semantic_colours(&text);
        entries.push(Entry {
            name: scalar(block, "name").unwrap_or_else(|| key.clone()),
            country: scalar(block, "country"),
            category: scalar(block, "category"),
            primary: primary.to_uppercase(),
            // secondary는 프롬프트 글자색의 씨앗이다. 본문색이 가장 안정적이다.
            secondary: colours.get("foreground").or_else(|| colours.get("dark-marketing"))
                .cloned().unwrap_or_else(|| "#16181D".to_string()),
            colors: colours,
            logo: logo_entry(block),
            verified: scalar(block, "verified"),
            key,
        });
    }

    let catalog = Catalog {
        version: CATALOG_VERSION,
        source: BTreeMap::from([
            ("name".into(), "oh-my-design".into()),
            ("url".into(), "https://github.com/kwakseongjae/oh-my-design".into()),
            ("license".into(), "MIT".into())]),
        brands: entries,
    };
    let output = root.join("catalog/brands.json");
    std::fs::write(&output, serde_json::to_string_pretty(&catalog)? + "\n")?;
    println!("카탈로그 생성: {}", output.display());
    println!("  회사 {}개  (primary_color 없어 제외 {}개)", catalog.brands.len(), skipped);
    Ok(())
}

/// 카탈로그 전체(또는 지정한 회사들)의 로고를 public/logo/ 에 받아 둔다.
///
/// 이렇게 해두면 어느 회사든 `enable` 한 번으로 즉시 켜진다 — 네트워크도, 출처가
/// 막혀 실패할 위험도 없다. 원격 출처는 사라지거나 봇 차단으로 막히기 때문에
/// (쿠팡이 그랬다) 받을 수 있을 때 받아 두는 편이 낫다.
/// 동시에 받을 개수. 한 호스트(cdn.simpleicons.org)에 몰리므로 코어 수만큼 늘리지 않는다 —
/// 시간은 대부분 응답 대기라 이 정도로 충분히 줄고, 상대 서버에 무리도 주지 않는다.
const FETCH_THREADS: usize = 8;

pub fn fetch_logos(root: &Path, only: &[String]) -> Result<()> {
    let catalog: Catalog = serde_json::from_str(
        &std::fs::read_to_string(root.join("catalog/brands.json"))?)?;
    let committed = root.join("public/logo");
    std::fs::create_dir_all(&committed)?;
    let repository = LogoRepository::new(root.join("logos"), &committed);

    let targets: Vec<&Entry> = catalog.brands.iter()
        .filter(|entry| only.is_empty() || only.iter().any(|key| key == &entry.key))
        .collect();
    let total = targets.len();

    // 한 건에 드는 시간은 거의 전부 원격 응답을 기다리는 시간이다 — 순차로 받으면
    // 440개가 그 대기의 합이 된다. 결과는 입력 순서대로 모이므로 보고는 그대로다.
    let pool = rayon::ThreadPoolBuilder::new().num_threads(FETCH_THREADS).build()?;
    let finished = AtomicUsize::new(0);
    let outcomes: Vec<(bool, Option<String>, Vec<String>)> = pool.install(|| {
        targets.par_iter().map(|entry| {
            let target = committed.join(format!("{}.png", entry.key));
            if target.exists() {
                return (true, None, Vec::new());
            }
            let Some(logo) = &entry.logo else { return (false, None, Vec::new()) };
            let brand = Brand {
                key: entry.key.clone(), name: entry.name.clone(), country: entry.country.clone(),
                primary: entry.primary.clone(), secondary: entry.secondary.clone(),
                verified: None, logo_path: None,
                logo: Some(LogoSource { kind: logo.kind.clone(), url: logo.url.clone(),
                                        keep_colour: false }),
            };
            let prepared = repository.prepare(&brand);
            let copied = prepared.path.as_ref()
                .map(|working| std::fs::copy(working, &target)
                    .map_err(|error| format!("{}: 결과 복사 실패 ({error})", entry.name)));

            let count = finished.fetch_add(1, Ordering::Relaxed) + 1;
            if count.is_multiple_of(25) {
                eprintln!("  … {count}/{total}");
            }
            match copied {
                Some(Ok(_)) => (false, Some(entry.key.clone()), prepared.notes),
                Some(Err(note)) => (false, None, vec![note]),
                None => (false, None, prepared.notes),
            }
        }).collect()
    });

    let skipped = outcomes.iter().filter(|(existing, ..)| *existing).count();
    let done = outcomes.iter().filter(|(_, fetched, _)| fetched.is_some()).count();
    let failed = total - skipped - done;
    let notes: Vec<&String> = outcomes.iter().flat_map(|(.., notes)| notes).collect();

    println!("로고 수집 완료: 받음 {done} · 이미 있음 {skipped} · 실패 {failed} (전체 {total})");
    if failed > 0 {
        println!("\n실패 사유:");
        for note in notes.iter().take(40) {
            println!("  {note}");
        }
        if notes.len() > 40 {
            println!("  … 외 {}건", notes.len() - 40);
        }
    }
    Ok(())
}

pub fn enable(keys: &[String], root: &Path) -> Result<()> {
    let catalog: Catalog = serde_json::from_str(
        &std::fs::read_to_string(root.join("catalog/brands.json"))?)?;
    let index: BTreeMap<&str, &Entry> =
        catalog.brands.iter().map(|e| (e.key.as_str(), e)).collect();
    let repository = LogoRepository::new(root.join("logos"), root.join("public/logo"));
    let mut notes = Vec::new();

    for key in keys {
        let Some(entry) = index.get(key.as_str()) else {
            eprintln!("  ! 카탈로그에 없다: {key}");
            continue;
        };
        let brand = Brand {
            key: entry.key.clone(), name: entry.name.clone(), country: entry.country.clone(),
            primary: entry.primary.clone(), secondary: entry.secondary.clone(),
            logo: entry.logo.as_ref().map(|logo| LogoSource {
                kind: logo.kind.clone(), url: logo.url.clone(), keep_colour: false }),
            verified: entry.verified.clone(), logo_path: None,
        };
        let prepared = repository.prepare(&brand);
        notes.extend(prepared.notes);

        // 회사명·URL은 외부 데이터셋에서 온다. format!으로 YAML을 조립하면 따옴표나
        // 콜론이 든 값 하나에 파일이 깨진다 — 직렬화기에 맡겨 그 부류를 없앤다.
        let header = format!(
            "# catalog/brands.json에서 생성. 출처 검증일: {}\n\
             # 직접 고치지 말고 `build-themes enable {}` 을 다시 실행할 것.\n",
            entry.verified.as_deref().unwrap_or("?"), entry.key);
        let document = header + &serde_yaml::to_string(&brand)?;
        std::fs::write(root.join(format!("brands/{}.yaml", entry.key)), document)?;
        println!("  {} {} ({})", if prepared.path.is_some() { "로고" } else { "  · " },
                 entry.name, entry.primary);
    }
    for note in &notes { eprintln!("  ! {note}"); }
    println!("\n다음: build-themes");
    Ok(())
}
