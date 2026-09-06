# ─────────────────────────────────────────────────────────────────────────────
#  이 파일은 oh-my-terminal 빌더가 생성한다. 직접 고치지 말고 brands/*.yaml을 고칠 것.
#  순수 zsh다 — python·curl 등 외부 명령에 의존하지 않는다.
#  ~/.p10k.zsh 를 source 한 '뒤에' 이 파일을 source 해야 한다.
# ─────────────────────────────────────────────────────────────────────────────

autoload -Uz add-zsh-hook

typeset -g  _brand_dir_content=""
typeset -gA _brand_gradient_cache=()

# 터미널은 그라데이션을 모른다 — 글자마다 배경색을 조금씩 바꿔 흉내낸다.
# 결과를 REPLY에 넣는다. 예전에는 호출부가 $( )로 감쌌는데, 그러면 함수가 서브셸에서
# 돌아 캐시에 쓴 값이 부모로 돌아오지 않는다 — 캐시가 한 번도 히트하지 않았고
# 프롬프트를 그릴 때마다 fork + 전체 재계산이었다.
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
    local -i luma=$(( (r * __LUMA_R__ + g * __LUMA_G__ + b * __LUMA_B__) / 1000 ))
    local fg=$(( luma > __LUMA_SWITCH__ ? 1 : 2 ))
    fg=${${fg/1/$dark_fg}/2/$light_fg}
    printf -v out '%s%%K{#%02X%02X%02X}' "$out" $r $g $b
    [[ $fg == $previous_fg ]] || { printf -v out '%s%%F{%s}' "$out" "$fg"; previous_fg=$fg }
    out+="${text[i]}"
  done
  REPLY=$out
}

# 디렉터리가 바뀔 때 한 번만 굽는다. 프롬프트는 변수만 참조하므로 fork가 없다.
# 경로는 p10k의 P9K_CONTENT에서 받지 않는다 — 두 번째 프롬프트부터 '이미 확장된' 값이
# 들어와 우리가 넣은 %K{...} 위에 색이 또 입혀졌다 (프롬프트에 리터럴 %K{ 가 찍혔다).
_brand_apply() {
  local start end dark light icon
  case $PWD in
__BRAND_APPLY_CASES__
    *) _brand_dir_content=""; return ;;
  esac
  local text="${icon}${(%):-%~}"
  local key="$text|$start|$end"
  if [[ -n ${_brand_gradient_cache[$key]} ]]; then
    _brand_dir_content=${_brand_gradient_cache[$key]}
  else
    _brand_gradient "$text" "$start" "$end" "$dark" "$light"
    _brand_dir_content=$REPLY
    _brand_gradient_cache[$key]=$REPLY
  fi
}
add-zsh-hook chpwd _brand_apply
_brand_apply

# 프롬프트 첫 칸. 회사 폴더 안에서는 비워 칸 자체를 숨기고(로고는 경로 세그먼트가 그린다),
# 밖에서는 원래의 OS 아이콘을 보여준다.
# case 패턴에 ~ 를 쓰면 zsh가 틸드 확장을 해버려 절대 안 맞는다 — $PWD로 비교한다.
# 이 세그먼트만은 fork를 피할 수 없다: p10k가 os_icon을 정적으로 캐싱해 변수 참조로는
# 디렉터리 변경이 반영되지 않는다(확인함). 커스텀 세그먼트는 매 프롬프트 재실행된다.
_brand_logo_segment() {
  case $PWD in
__BRAND_CASES__
  esac
  print -rn -- $'\uf179'
}
