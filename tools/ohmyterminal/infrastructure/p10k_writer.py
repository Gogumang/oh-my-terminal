"""powerlevel10k 설정 생성기. 결과물은 외부 명령을 하나도 쓰지 않는 순수 zsh다."""
from pathlib import Path

from ..domain import palette

RUNTIME = r"""# ─────────────────────────────────────────────────────────────────────────────
#  이 파일은 tools/build.py가 생성한다. 직접 고치지 말고 brands/*.yaml을 고칠 것.
#  순수 zsh다 — python·curl 등 외부 명령에 의존하지 않는다.
#  ~/.p10k.zsh 를 source 한 '뒤에' 이 파일을 source 해야 한다.
# ─────────────────────────────────────────────────────────────────────────────

typeset -gA _brand_gradient_cache=()

# 터미널은 그라데이션을 모른다 — 글자마다 배경색을 조금씩 바꿔 흉내낸다.
_brand_gradient() {
  local text=$1 start=$2 end=$3 dark_fg=$4 light_fg=$5
  local -i n=${#text} i
  local -i sr=$((16#${start[2,3]})) sg=$((16#${start[4,5]})) sb=$((16#${start[6,7]}))
  local -i er=$((16#${end[2,3]}))   eg=$((16#${end[4,5]}))   eb=$((16#${end[6,7]}))
  local out="" previous_fg=""
  for (( i = 1; i <= n; i++ )); do
    local -F t=$(( n > 1 ? (i - 1.0) / (n - 1.0) : 0 ))
    local -i r=$(( sr + (er - sr) * t )) g=$(( sg + (eg - sg) * t )) b=$(( sb + (eb - sb) * t ))
    # 배경이 어두워지는 지점에서 글자색을 뒤집지 않으면 경로 끝이 안 읽힌다.
    local -i luma=$(( (r * 299 + g * 587 + b * 114) / 1000 ))
    local fg=$(( luma > 140 ? 1 : 2 ))
    fg=${${fg/1/$dark_fg}/2/$light_fg}
    printf -v out '%s%%K{#%02X%02X%02X}' "$out" $r $g $b
    [[ $fg == $previous_fg ]] || { printf -v out '%s%%F{%s}' "$out" "$fg"; previous_fg=$fg }
    out+="${text[i]}"
  done
  print -r -- "$out"
}

# 경로는 P9K_CONTENT에서 받지 않는다. p10k가 두 번째 프롬프트부터 '이미 확장된' 값을
# 그 변수에 담아, 우리가 넣은 %K{...} 위에 색이 또 입혀지는 이중 적용이 일어난다
# (프롬프트에 리터럴 %K{ 가 그대로 찍혔다). $PWD 기반으로 직접 만든다.
_brand_gradient_cached() {
  local text="$1${(%):-%~}"
  local key="$text|$2|$3|$4|$5"
  [[ -n ${_brand_gradient_cache[$key]} ]] || \
    _brand_gradient_cache[$key]=$(_brand_gradient "$text" "$2" "$3" "$4" "$5")
  print -r -- ${_brand_gradient_cache[$key]}
}

# 프롬프트 첫 칸. 회사 폴더 안에서는 비워 칸 자체를 숨기고(로고는 경로 세그먼트가 그린다),
# 밖에서는 원래의 OS 아이콘을 보여준다.
# case 패턴에 ~ 를 쓰면 zsh가 틸드 확장을 해버려 절대 안 맞는다 — $PWD로 비교한다.
_brand_logo_segment() {
  case $PWD in
__BRAND_CASES__
  esac
  print -rn -- $''
}
"""


class PowerlevelWriter:
    def write(self, brands, glyphs, output_root: Path) -> Path:
        cases, blocks, classes = [], [], []

        for brand in brands:
            css_class = f"BRAND_{brand.key.upper()}"
            for pattern in brand.paths:
                classes.append(f"  {pattern!r:<30} {css_class:<18} ''")
                if brand.key in glyphs:
                    absolute = pattern.replace("~/", "${HOME}/", 1)
                    cases.append(f"    {absolute}) return ;;")

            start, end, dark, light, _, _ = palette.gradient(brand)
            icon = f"{glyphs[brand.key]} " if brand.key in glyphs else ""
            content = (f'$(_brand_gradient_cached "{icon}" '
                       f'"{palette.rgb_to_hex(start)}" "{palette.rgb_to_hex(end)}" '
                       f'"{palette.rgb_to_hex(dark)}" "{palette.rgb_to_hex(light)}")')
            muted = palette.blend(dark, end, 0.45)

            lines = [f"# {brand.name}"]
            # DIR_SHOW_WRITABLE=v3면 쓰기불가/없는 경로는 접미사가 붙은 별도 클래스가 된다.
            # 안 채우면 그 경우에만 브랜드 색이 사라진다.
            for suffix in ("", "_NOT_WRITABLE", "_NON_EXISTENT"):
                prefix = f"POWERLEVEL9K_DIR_{css_class}{suffix}"
                lines += [
                    f"typeset -g {prefix}_BACKGROUND='{palette.rgb_to_hex(end)}'",
                    f"typeset -g {prefix}_FOREGROUND='{palette.rgb_to_hex(dark)}'",
                    f"typeset -g {prefix}_SHORTENED_FOREGROUND='{palette.rgb_to_hex(muted)}'",
                    f"typeset -g {prefix}_ANCHOR_FOREGROUND='{palette.rgb_to_hex(dark)}'",
                    f"typeset -g {prefix}_ANCHOR_BOLD=true",
                    f"typeset -g {prefix}_VISUAL_IDENTIFIER_EXPANSION=''",
                    f"typeset -g {prefix}_CONTENT_EXPANSION='{content}'",
                ]
            blocks.append("\n".join(lines))

        runtime = RUNTIME.replace("__BRAND_CASES__",
                                  "\n".join(cases) or "    # (로고 없음)")
        body = "\n\n".join(blocks)
        document = f"""{runtime}
typeset -g POWERLEVEL9K_DIR_CLASSES=(
{chr(10).join(classes)}
  {"'*'":<30} {'DEFAULT':<18} ''
)

# DEFAULT 클래스는 값을 정의하지 않는다 — p10k가 기존 POWERLEVEL9K_DIR_* 로 폴백하므로
# 회사 경로 밖에서는 원래 쓰던 프롬프트가 그대로 유지된다.

{body}

# os_icon을 커스텀 세그먼트로 교체한다. os_icon은 p10k가 정적 세그먼트로 캐싱해서
# 디렉터리가 바뀌어도 갱신되지 않는다 — 커스텀 세그먼트는 매 프롬프트 재실행된다.
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_brandlogo dir vcs)
typeset -g POWERLEVEL9K_CUSTOM_BRANDLOGO='_brand_logo_segment'
typeset -g POWERLEVEL9K_CUSTOM_BRANDLOGO_BACKGROUND=7
typeset -g POWERLEVEL9K_CUSTOM_BRANDLOGO_FOREGROUND=232
"""
        output = output_root / "brands.zsh"
        output.write_text(document)
        return output
