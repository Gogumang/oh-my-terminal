//! powerlevel10k 설정 생성기. 결과물은 외부 명령을 하나도 쓰지 않는 순수 zsh다.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

use anyhow::Result;

use crate::domain::brand::Brand;
use crate::domain::palette;

const RUNTIME: &str = include_str!("brands_runtime.zsh");

pub fn write_prompt(brands: &[Brand], glyphs: &BTreeMap<String, char>,
                    output_root: &Path) -> Result<PathBuf> {
    let mut cases = Vec::new();
    let mut apply_cases = Vec::new();
    let mut classes = Vec::new();
    let mut blocks = Vec::new();

    for brand in brands {
        let class = format!("BRAND_{}", brand.key.to_uppercase());
        for pattern in &brand.paths {
            classes.push(format!("  {:<32} {:<18} ''", format!("'{pattern}'"), class));
            if glyphs.contains_key(&brand.key) {
                let absolute = pattern.replacen("~/", "${HOME}/", 1);
                cases.push(format!("    {absolute}) return ;;"));
            }
        }

        let gradient = palette::gradient(brand);
        let icon = glyphs.get(&brand.key).map(|g| format!("{g} ")).unwrap_or_default();
        for pattern in &brand.paths {
            let absolute = pattern.replacen("~/", "${HOME}/", 1);
            apply_cases.push(format!(
                "    {absolute}) start='{}'; end='{}'; dark='{}'; light='{}'; icon='{icon}' ;;",
                palette::rgb_to_hex(gradient.start), palette::rgb_to_hex(gradient.end),
                palette::rgb_to_hex(gradient.dark_foreground),
                palette::rgb_to_hex(gradient.light_foreground)));
        }
        // 프롬프트는 변수만 참조한다 — $( ) 를 쓰면 서브셸이 생겨 fork가 나고 캐시도 죽는다.
        let content = "${_brand_dir_content}";
        let muted = palette::blend(gradient.dark_foreground, gradient.end, 0.45);

        let mut lines = vec![format!("# {}", brand.name)];
        // DIR_SHOW_WRITABLE=v3면 쓰기불가/없는 경로는 접미사가 붙은 별도 클래스가 된다.
        // 안 채우면 그 경우에만 브랜드 색이 사라진다.
        for suffix in ["", "_NOT_WRITABLE", "_NON_EXISTENT"] {
            let prefix = format!("POWERLEVEL9K_DIR_{class}{suffix}");
            lines.extend([
                format!("typeset -g {prefix}_BACKGROUND='{}'", palette::rgb_to_hex(gradient.end)),
                format!("typeset -g {prefix}_FOREGROUND='{}'",
                        palette::rgb_to_hex(gradient.dark_foreground)),
                format!("typeset -g {prefix}_SHORTENED_FOREGROUND='{}'", palette::rgb_to_hex(muted)),
                format!("typeset -g {prefix}_ANCHOR_FOREGROUND='{}'",
                        palette::rgb_to_hex(gradient.dark_foreground)),
                format!("typeset -g {prefix}_ANCHOR_BOLD=true"),
                format!("typeset -g {prefix}_VISUAL_IDENTIFIER_EXPANSION=''"),
                format!("typeset -g {prefix}_CONTENT_EXPANSION='{content}'"),
            ]);
        }
        blocks.push(lines.join("\n"));
    }

    // 셸 쪽 임계값·가중치를 도메인 상수에서 주입한다. 리터럴로 두면 Rust만 바꿨을 때
    // 검증은 통과하고 화면은 안 읽히는 상태가 조용히 만들어진다.
    let runtime = RUNTIME
        .replace("__BRAND_APPLY_CASES__",
                 &if apply_cases.is_empty() { "    # (브랜드 없음)".to_string() }
                  else { apply_cases.join("\n") })
        .replace("__BRAND_CASES__",
                 &if cases.is_empty() { "    # (로고 없음)".to_string() } else { cases.join("\n") })
        .replace("__LUMA_SWITCH__", &palette::LUMA_SWITCH.to_string())
        .replace("__LUMA_R__", &palette::LUMA_WEIGHTS[0].to_string())
        .replace("__LUMA_G__", &palette::LUMA_WEIGHTS[1].to_string())
        .replace("__LUMA_B__", &palette::LUMA_WEIGHTS[2].to_string());

    let document = format!("{runtime}
typeset -g POWERLEVEL9K_DIR_CLASSES=(
{}
  {:<32} {:<18} ''
)

# DEFAULT 클래스는 값을 정의하지 않는다 — p10k가 기존 POWERLEVEL9K_DIR_* 로 폴백하므로
# 회사 경로 밖에서는 원래 쓰던 프롬프트가 그대로 유지된다.

{}

# os_icon 자리를 커스텀 세그먼트로 바꾼다. os_icon은 p10k가 정적 세그먼트로 캐싱해
# 디렉터리가 바뀌어도 갱신되지 않기 때문이다 (변수 참조로도 안 된다 — 확인함).
#
# 사용자의 배열을 통째로 대입하지 않는다. 예전에는 (custom_brandlogo dir vcs)로 못박아
# 회사 폴더 밖에서도 남의 프롬프트 구성이 이 셋으로 고정됐다. os_icon 항목만 바꿔치기한다.
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  ${{POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]/os_icon/custom_brandlogo}})
typeset -g POWERLEVEL9K_CUSTOM_BRANDLOGO='_brand_logo_segment'
# 색도 사용자의 os_icon 값을 따른다. 하드코딩하면 다른 사람에게 틀린 색이 된다.
typeset -g POWERLEVEL9K_CUSTOM_BRANDLOGO_BACKGROUND=${{POWERLEVEL9K_OS_ICON_BACKGROUND:-7}}
typeset -g POWERLEVEL9K_CUSTOM_BRANDLOGO_FOREGROUND=${{POWERLEVEL9K_OS_ICON_FOREGROUND:-232}}
", classes.join("\n"), "'*'", "DEFAULT", blocks.join("\n\n"));

    let output = output_root.join("brands.zsh");
    std::fs::write(&output, document)?;
    Ok(output)
}
