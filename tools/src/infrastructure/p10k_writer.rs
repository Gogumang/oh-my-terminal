//! powerlevel10k 설정 생성기. 결과물은 외부 명령을 하나도 쓰지 않는 순수 zsh다.
//!
//! 회사는 iTerm2 프로필로 고른다. 셸이 ITERM_PROFILE로 회사를 알아내므로 여기서는
//! 프로필 이름 → 색·로고 표만 만든다. 폴더 규칙이나 별도 설정 파일은 두지 않는다 —
//! 사용자가 바꾸는 설정은 iTerm2 프로필 하나다.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

use anyhow::{anyhow, Result};

use crate::domain::brand::Brand;
use crate::domain::palette;

const RUNTIME: &str = include_str!("brands_runtime.zsh");

/// 키는 셸이 공백으로 나눠 읽는 표 값에 들어간다. 외부 데이터셋에서 오므로 허용 문자를
/// 좁혀 둔다 — 공백이나 따옴표가 섞이면 칸이 어긋나거나 생성물이 깨진다.
fn validate_key(key: &str) -> Result<()> {
    let allowed = |c: char| c.is_ascii_alphanumeric() || matches!(c, '.' | '-' | '_');
    if key.is_empty() || !key.chars().all(allowed) {
        return Err(anyhow!("회사키 {key:?} 에 쓸 수 없는 문자가 있다 (영숫자와 . - _ 만)"));
    }
    Ok(())
}

/// zsh 작은따옴표 문자열. 회사명에는 작은따옴표가 들어올 수 있다 (McDonald's).
fn shell_quote(text: &str) -> String {
    format!("'{}'", text.replace('\'', r"'\''"))
}

/// `glyphs`: 회사키 → 로고 조각 문자열 (글자 칸마다 한 글자).
pub fn write_prompt(brands: &[Brand], glyphs: &BTreeMap<String, String>,
                    output_root: &Path) -> Result<PathBuf> {
    let mut rows = Vec::new();
    let mut claimed: BTreeMap<String, &str> = BTreeMap::new();

    for brand in brands {
        validate_key(&brand.key)?;
        let profile = brand.profile_name();
        if let Some(other) = claimed.insert(profile.clone(), &brand.key) {
            return Err(anyhow!("{other} 와 {} 의 iTerm2 프로필 이름이 {profile:?} 로 같다 — \
                                셸이 둘을 구분하지 못한다", brand.key));
        }

        let gradient = palette::gradient(brand);
        let muted = palette::blend(gradient.dark_foreground, gradient.end, 0.45);
        // 셸이 공백으로 나눠 읽는다. 로고가 없는 회사는 마지막 칸이 빈다.
        let icon = glyphs.get(&brand.key).cloned().unwrap_or_default();
        let hex = palette::rgb_to_hex;
        rows.push(format!("  {} '{} {} {} {} {} {} {} {icon}'", shell_quote(&profile), brand.key,
                          hex(gradient.start), hex(gradient.end), hex(gradient.dark_foreground),
                          hex(gradient.light_foreground), hex(muted),
                          hex(palette::logo_colour(brand))));
    }

    // 셸 쪽 임계값·가중치를 도메인 상수에서 주입한다. 리터럴로 두면 Rust만 바꿨을 때
    // 검증은 통과하고 화면은 안 읽히는 상태가 조용히 만들어진다.
    let document = RUNTIME
        .replace("__BRAND_PROFILES__", &rows.join("\n"))
        .replace("__LUMA_SWITCH__", &palette::LUMA_SWITCH.to_string())
        .replace("__LUMA_R__", &palette::LUMA_WEIGHTS[0].to_string())
        .replace("__LUMA_G__", &palette::LUMA_WEIGHTS[1].to_string())
        .replace("__LUMA_B__", &palette::LUMA_WEIGHTS[2].to_string());

    let output = output_root.join("brands.zsh");
    std::fs::write(&output, document)?;
    Ok(output)
}

#[cfg(test)]
#[allow(non_snake_case)]   // 테스트 이름은 동작 서술형 한국어를 쓴다
mod tests {
    use super::*;

    fn brand(key: &str, name: &str) -> Brand {
        Brand { key: key.into(), name: name.into(), primary: "#0064FF".into(),
                secondary: "#0064FF".into(), logo: None, verified: None, logo_path: None }
    }

    fn scratch(name: &str) -> PathBuf {
        let directory = std::env::temp_dir()
            .join(format!("oh-my-terminal-{name}-{}", std::process::id()));
        std::fs::create_dir_all(&directory).unwrap();
        directory
    }

    /// 생성물을 격리된 HOME·ITERM_PROFILE로 source하고 첫 프롬프트처럼 precmd 훅을 한 번 돌린 뒤
    /// 스크립트의 stdout을 돌려준다. `before_source`·`after_source`는 source 앞뒤에 도는 zsh 코드로,
    /// .zshrc에서 p10k와 불러오는 순서를 흉내낸다.
    /// 로고 조각은 여러 바이트 글자라 UTF-8 로캘이 아니면 글자 단위로 못 센다.
    fn run_zsh(home: &Path, brands_zsh: &Path, profile: Option<&str>, before_source: &str,
               after_source: &str, script: &str) -> String {
        let mut command = std::process::Command::new("zsh");
        command.args(["-f", "-c",
                      &format!("POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)\n{before_source}\n\
                                source \"$1\" || exit 1\n{after_source}\n\
                                for hook in $precmd_functions; do $hook; done\n{script}"),
                      "zsh"])
            .arg(brands_zsh)
            .env("HOME", home)
            .env("LANG", "en_US.UTF-8");
        match profile {
            Some(name) => { command.env("ITERM_PROFILE", name); }
            None => { command.env_remove("ITERM_PROFILE"); }
        }
        let result = command.output().expect("zsh를 실행하지 못했다");
        let stderr = String::from_utf8_lossy(&result.stderr);
        assert!(result.status.success() && stderr.is_empty(), "zsh 실패: {stderr}");
        String::from_utf8_lossy(&result.stdout).into_owned()
    }

    #[test]
    fn 브랜드_프로필로_연_창에서만_어느_폴더에서나_그_회사_테마가_나온다() {
        let home = scratch("profile");
        std::fs::create_dir_all(home.join("study/deep")).unwrap();
        // 괄호·작은따옴표가 든 회사명도 프로필 이름으로 찾아야 한다.
        let brands = [brand("claude", "Claude (Anthropic)"), brand("mcd", "McDonald's")];
        let glyphs = BTreeMap::from([("claude".to_string(), "\u{100000}\u{100001}".to_string())]);
        let output = write_prompt(&brands, &glyphs, &home).unwrap();
        let script = r#"
            before=$_brand_dir_content
            cd ~/study/deep
            print -r -- "${_brand_theme[1]:--}|${${(j:,:)POWERLEVEL9K_DIR_CLASSES}:-없음}|$POWERLEVEL9K_LEFT_PROMPT_ELEMENTS|${POWERLEVEL9K_DIR_BRAND_BACKGROUND:+색있음}|${${_brand_dir_content:#$before}:+경로따라바뀜}"
        "#;
        let seen: Vec<String> = [Some("Claude (Anthropic) Brand"), Some("McDonald's Brand"),
                                 Some("Default"), None]
            .into_iter()
            .map(|profile| run_zsh(&home, &output, profile, "", "", script).trim_end().to_string())
            .collect();
        let _ = std::fs::remove_dir_all(&home);
        assert_eq!(seen, [
            // 로고가 경로 앞에 나오므로 OS 아이콘 칸은 빠진다.
            "claude|*,BRAND,|dir vcs|색있음|경로따라바뀜",
            // 로고가 없는 회사는 OS 아이콘 칸을 남긴다.
            "mcd|*,BRAND,|os_icon dir vcs|색있음|경로따라바뀜",
            // 브랜드 프로필이 아니면 사용자 프롬프트를 건드리지 않는다.
            "-|없음|os_icon dir vcs||",
            "-|없음|os_icon dir vcs||",
        ]);
    }

    #[test]
    fn 로고_둘레는_띠_시작색으로_고르게_칠하고_로고는_대비가_가장_큰_색으로_칠한다() {
        // p10k 왼쪽 여백(끝색)과 로고 칸(시작색)의 경계가 져 로고 둘레만 밝은 조각처럼 떠 보였다.
        // 또 iTerm2 GPU 렌더러는 로고를 그 칸의 글자색으로 칠해, 경로와 같은 회색 글자색을 쓰자
        // 어두운 띠 위 로고(삼성·우버)가 얼룩으로만 보였다.
        let home = scratch("logo-colour");
        let kakao = Brand { key: "kakao".into(), name: "Kakao".into(), primary: "#FEE500".into(),
                            secondary: "#333333".into(), logo: None, verified: None, logo_path: None };
        let start = palette::rgb_to_hex(palette::gradient(&kakao).start);
        let glyphs = BTreeMap::from([("kakao".to_string(), "\u{100000}\u{100001}".to_string())]);
        let output = write_prompt(&[kakao], &glyphs, &home).unwrap();
        let script = "print -r -- \"${+POWERLEVEL9K_DIR_BRAND_LEFT_LEFT_WHITESPACE}${POWERLEVEL9K_DIR_BRAND_LEFT_LEFT_WHITESPACE:-빔}\"
                      print -rn -- $_brand_dir_content";
        let seen = run_zsh(&home, &output, Some("Kakao Brand"), "", "", script);
        let _ = std::fs::remove_dir_all(&home);

        let (whitespace, content) = seen.split_once('\n').unwrap();
        assert_eq!(whitespace, "1빔", "p10k 왼쪽 여백을 비우지 않았다");
        // 여백 · 로고 두 칸 · 로고 뒤 한 칸이 모두 시작색, 글자색은 검정
        let expected = format!("%K{{{start}}}%F{{#000000}} %K{{{start}}}\u{100000}\
                                %K{{{start}}}\u{100001}%K{{{start}}} ");
        assert!(content.starts_with(&expected), "로고 둘레가 시작색으로 고르지 않다: {content}");
        let path = &content[expected.len()..];
        assert!(path.starts_with(&format!("%K{{{start}}}%F{{")) && !path.starts_with(&format!("%K{{{start}}}%F{{#000000}}")),
                "경로가 시작색에서 그라데이션을 시작하지 않거나 로고 색을 이어 썼다: {path}");
    }

    #[test]
    fn 플러그인_관리자가_p10k_설정보다_먼저_source해도_테마가_남는다() {
        // oh-my-zsh·zinit은 플러그인을 ~/.p10k.zsh 보다 먼저 source 하고, .p10k.zsh는 시작하자마자
        // POWERLEVEL9K_* 를 전부 지운다. source 시점에 넣으면 여기서 흔적 없이 사라졌다.
        let home = scratch("plugin-order");
        let glyphs = BTreeMap::from([("claude".to_string(), "\u{100000}".to_string())]);
        let output = write_prompt(&[brand("claude", "Claude (Anthropic)")], &glyphs, &home).unwrap();
        let p10k_config = "unset -m 'POWERLEVEL9K_*'\nPOWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)";
        let script = r#"print -r -- "${(j:,:)POWERLEVEL9K_DIR_CLASSES}|$POWERLEVEL9K_LEFT_PROMPT_ELEMENTS|${POWERLEVEL9K_DIR_BRAND_BACKGROUND:+색있음}|${#precmd_functions}""#;
        let seen = run_zsh(&home, &output, Some("Claude (Anthropic) Brand"), "", p10k_config, script);
        let _ = std::fs::remove_dir_all(&home);
        // 훅은 한 번 설정을 넣고 스스로 빠진다 — 매 프롬프트마다 돌 이유가 없다.
        assert_eq!(seen.trim_end(), "*,BRAND,|dir vcs|색있음|0");
    }

    #[test]
    fn p10k를_먼저_불러온_뒤_source해도_첫_프롬프트부터_테마가_나온다() {
        // 기존 설치는 ~/.p10k.zsh 다음 줄에서 source 한다. 그때는 p10k의 precmd 훅이 이미 걸려 있어,
        // 훅을 뒤에 붙이자 p10k가 첫 프롬프트를 브랜드 설정 없이 그렸다.
        let home = scratch("after-p10k");
        let output = write_prompt(&[brand("claude", "Claude (Anthropic)")], &BTreeMap::new(), &home).unwrap();
        let p10k = r#"_p9k_precmd() { print -r -- "${(j:,:)POWERLEVEL9K_DIR_CLASSES:-없음}" }
                      precmd_functions=(_p9k_precmd)"#;
        let seen = run_zsh(&home, &output, Some("Claude (Anthropic) Brand"), p10k, "", "");
        let _ = std::fs::remove_dir_all(&home);
        assert_eq!(seen.trim_end(), "*,BRAND,", "p10k가 브랜드 설정을 넣기 전에 프롬프트를 그렸다");
    }

    #[test]
    fn 셸을_깨는_회사키와_겹치는_프로필_이름은_생성을_거부한다() {
        let root = scratch("reject");
        let bad_key = write_prompt(&[brand("a'b", "A")], &BTreeMap::new(), &root);
        let same_name = write_prompt(&[brand("a", "Same"), brand("b", "Same")],
                                     &BTreeMap::new(), &root);
        let _ = std::fs::remove_dir_all(&root);
        assert!(bad_key.is_err(), "따옴표가 든 회사키를 받아들였다");
        let error = same_name.expect_err("겹치는 프로필 이름을 받아들였다");
        assert!(error.to_string().contains("Same Brand"), "원인이 메시지에 없다: {error}");
    }
}
