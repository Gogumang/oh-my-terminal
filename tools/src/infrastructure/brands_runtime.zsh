# ─────────────────────────────────────────────────────────────────────────────
#  이 파일은 oh-my-terminal 빌더가 생성한다. 직접 고치지 말고 brands/*.yaml을 고칠 것.
#  순수 zsh다 — python·curl 등 외부 명령에 의존하지 않는다.
#  ~/.p10k.zsh 보다 먼저 source 해도 된다 — p10k 설정은 첫 프롬프트 직전에 넣는다.
#
#  회사는 iTerm2 프로필로 고른다. "<회사> Brand" 프로필로 연 창에서는 어느 폴더에서나 그 회사
#  테마를 입히고, 다른 프로필이면 아무것도 건드리지 않는다.
# ─────────────────────────────────────────────────────────────────────────────

# iTerm2 프로필 이름 → "회사키 시작색 끝색 어두운글자색 밝은글자색 흐린글자색 로고색 로고조각".
# 로고 조각은 글자 칸마다 한 글자다. 로고가 없는 회사는 마지막 칸이 빈다.
typeset -gA _brand_profiles=(
__BRAND_PROFILES__
)

# iTerm2는 세션을 열 때 프로필 이름을 ITERM_PROFILE에 넣는다. 열린 세션의 프로필을 바꿔도
# 이 값은 그대로라 새 탭·창부터 반영된다.
[[ -n ${ITERM_PROFILE:-} && -n ${_brand_profiles[$ITERM_PROFILE]-} ]] || return 0

autoload -Uz add-zsh-hook

typeset -ga _brand_theme=("${(@s: :)_brand_profiles[$ITERM_PROFILE]}")
typeset -g  _brand_dir_content=""
typeset -gA _brand_gradient_cache=()

# 터미널은 그라데이션을 모른다 — 글자마다 배경색을 조금씩 바꿔 흉내낸다.
# 앞의 lead 글자(왼쪽 여백·로고 조각·로고 뒤 한 칸)는 시작색 한 가지로 칠해 로고 둘레가 띠와
# 이어지게 하고, 그 뒤 경로 글자에만 그라데이션을 입힌다. lead 글자색은 lead_fg — iTerm2 GPU
# 렌더러는 로고를 이 글자색으로 칠하므로 띠 위에서 대비가 가장 큰 색이어야 로고가 또렷하다.
# 결과를 REPLY에 넣는다. 예전에는 호출부가 $( )로 감쌌는데, 그러면 함수가 서브셸에서
# 돌아 캐시에 쓴 값이 부모로 돌아오지 않는다 — 캐시가 한 번도 히트하지 않았고
# 프롬프트를 그릴 때마다 fork + 전체 재계산이었다.
_brand_gradient() {
  local text=$1 start=$2 end=$3 dark_fg=$4 light_fg=$5 lead_fg=$7
  local -i lead=$6 n=${#text} i
  local -i span=$(( n - lead ))
  local -i sr=$((16#${start[2,3]})) sg=$((16#${start[4,5]})) sb=$((16#${start[6,7]}))
  local -i er=$((16#${end[2,3]}))   eg=$((16#${end[4,5]}))   eb=$((16#${end[6,7]}))
  local out="" previous_fg="" fg
  for (( i = 1; i <= n; i++ )); do
    local -F t=0
    (( i > lead && span > 1 )) && t=$(( (i - lead - 1.0) / (span - 1.0) ))
    local -i r=$(( sr + (er - sr) * t )) g=$(( sg + (eg - sg) * t )) b=$(( sb + (eb - sb) * t ))
    if (( i <= lead )); then
      fg=$lead_fg
    else
      # 배경이 어두워지는 지점에서 글자색을 뒤집지 않으면 경로 끝이 안 읽힌다.
      local -i luma=$(( (r * __LUMA_R__ + g * __LUMA_G__ + b * __LUMA_B__) / 1000 ))
      (( luma > __LUMA_SWITCH__ )) && fg=$dark_fg || fg=$light_fg
    fi
    printf -v out '%s%%K{#%02X%02X%02X}' "$out" $r $g $b
    [[ $fg == $previous_fg ]] || { printf -v out '%s%%F{%s}' "$out" "$fg"; previous_fg=$fg }
    out+="${text[i]}"
  done
  REPLY=$out
}

# 경로 세그먼트 내용은 디렉터리가 바뀔 때 한 번만 굽는다. 프롬프트는 변수만 참조하므로 fork가 없다.
# 경로는 p10k의 P9K_CONTENT에서 받지 않는다 — 두 번째 프롬프트부터 '이미 확장된' 값이
# 들어와 우리가 넣은 %K{...} 위에 색이 또 입혀졌다 (프롬프트에 리터럴 %K{ 가 찍혔다).
_brand_apply() {
  emulate -L zsh
  local icon=$_brand_theme[8]
  # 왼쪽 여백을 직접 넣는다. p10k의 여백은 세그먼트 배경(끝색)으로 칠해져, 시작색인 로고 칸과
  # 경계가 져 로고 둘레만 밝은 조각처럼 떠 보였다. p10k 쪽 왼쪽 여백은 아래에서 비운다.
  local lead=" ${icon:+$icon }"
  local text="$lead${(%):-%~}"
  if [[ -z ${_brand_gradient_cache[$text]} ]]; then
    _brand_gradient "$text" $_brand_theme[2] $_brand_theme[3] $_brand_theme[4] $_brand_theme[5] \
                    ${#lead} $_brand_theme[7]
    _brand_gradient_cache[$text]=$REPLY
  fi
  _brand_dir_content=${_brand_gradient_cache[$text]}
}
add-zsh-hook chpwd _brand_apply
_brand_apply

# p10k 설정은 첫 프롬프트 직전에 한 번 넣고 훅에서 빠진다. 플러그인 관리자(oh-my-zsh·zinit·antigen)는
# 이 파일을 ~/.p10k.zsh 보다 먼저 source 하는데, .p10k.zsh는 시작하자마자 POWERLEVEL9K_* 를 전부
# 지워서 source 시점에 넣으면 흔적 없이 사라졌다. p10k는 설정을 precmd 맨 끝(_p9k_precmd)에서
# 읽으므로, 그보다 앞에 도는 이 훅이 넣은 값은 .zshrc 어디서 source 했든 똑같이 반영된다.
_brand_p10k() {
  emulate -L zsh
  add-zsh-hook -d precmd _brand_p10k

  # 모든 폴더를 BRAND 클래스 하나로 칠한다. 이 프로필에서는 사용자의 다른 dir 클래스를 쓰지 않는다.
  typeset -ga POWERLEVEL9K_DIR_CLASSES=('*' BRAND '')
  local suffix
  # DIR_SHOW_WRITABLE=v3면 쓰기불가/없는 경로는 접미사가 붙은 별도 클래스가 된다.
  # 안 채우면 그 경우에만 브랜드 색이 사라진다.
  for suffix in '' _NOT_WRITABLE _NON_EXISTENT; do
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_BACKGROUND=$_brand_theme[3]
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_FOREGROUND=$_brand_theme[4]
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_SHORTENED_FOREGROUND=$_brand_theme[6]
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_ANCHOR_FOREGROUND=$_brand_theme[4]
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_ANCHOR_BOLD=true
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_VISUAL_IDENTIFIER_EXPANSION=''
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_CONTENT_EXPANSION='${_brand_dir_content}'
    # 왼쪽 여백은 내용에 시작색으로 직접 넣었다 (위 _brand_apply).
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_LEFT_LEFT_WHITESPACE=''
  done

  # 로고가 경로 세그먼트 맨 앞에 나오므로 OS 아이콘 칸은 뺀다 — 같은 자리에 아이콘이 둘일 필요가 없다.
  # 사용자의 배열을 통째로 바꾸지 않고 os_icon만 뺀다.
  if [[ -n $_brand_theme[8] ]]; then
    typeset -ga POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=("${(@)POWERLEVEL9K_LEFT_PROMPT_ELEMENTS:#os_icon}")
  fi
}
# 맨 앞에 건다. p10k를 먼저 불러온 .zshrc에서는 _p9k_precmd가 이미 걸려 있어, add-zsh-hook처럼
# 뒤에 붙이면 p10k가 첫 프롬프트를 이 설정 없이 그렸다.
typeset -ga precmd_functions=(_brand_p10k ${precmd_functions:#_brand_p10k})
