# ─────────────────────────────────────────────────────────────────────────────
#  oh-my-terminal — zsh 플러그인 진입점. 이 파일 하나를 source 하면 된다.
#
#    source ~/.zsh/oh-my-terminal/oh-my-terminal.zsh
#
#  플러그인 관리자는 저장소를 받아 source 할 뿐이라, 로고 폰트와 iTerm2 프로필은 여기서 설치한다.
#  저장소 쪽 파일이 더 새로울 때만 복사하므로(설치·git pull 직후 첫 셸에서 한 번) 평소에는 파일
#  시각만 비교하고 외부 명령을 부르지 않는다.
# ─────────────────────────────────────────────────────────────────────────────

() {
  emulate -L zsh
  local root=$1

  # 미리 파싱해 둔 판(.zwc)을 만들어 둔다. source 는 같은 이름의 .zwc 가 더 새로우면 그것을
  # 읽으므로, 31KB 표와 위젯 정의를 셸마다 다시 파싱하지 않는다 (셸 시작에서 약 1ms).
  # 원본이 더 새로우면 zsh 가 .zwc 를 무시하므로, 굽기 전에도 동작은 늘 옳다.
  # 저장소가 읽기 전용이면 조용히 넘어간다 — 있으면 빠르고 없으면 그대로 도는 최적화다.
  # .zwc 가 원본보다 확실히 새로울 때만 그대로 둔다. 같은 초에 쓰였으면 다시 굽는다 —
  # 원본이 1초 안에 바뀐 경우 zsh 는 옛 .zwc 를 그대로 읽어, 새 테마가 조용히 무시된다.
  local script
  for script in $root/brands.zsh $root/autosuggest.zsh; do
    [[ ! -e $script || $script.zwc -nt $script ]] || zcompile -U -- $script 2>/dev/null
  done

  [[ $OSTYPE == darwin* ]] || return 0
  zmodload -F zsh/files b:zf_mkdir b:zf_rm || return 0

  # 로고 폰트. 옛 판을 먼저 지운다 — 폰트 이름에 판 번호가 붙어 있어, 남겨 두면 이름이 다른 두
  # 폰트가 함께 설치된다. 이름이 바뀌므로 실행 중인 iTerm2도 새 폰트를 바로 읽는다.
  local installed=$HOME/Library/Fonts font
  local -a fonts=($root/fonts/*.ttf(N)) stale=()
  for font in $fonts; do
    [[ -e $installed/${font:t} && ! $font -nt $installed/${font:t} ]] || stale+=$font
  done
  if (( $#stale )); then
    zf_mkdir -p $installed
    local -a old=($installed/OhMyTerminalBrand*.ttf(N))
    (( $#old )) && zf_rm -f $old
    command cp $fonts $installed/
  fi

  # iTerm2 프로필. 이 폴더에 넣으면 재시작 없이 바로 반영된다. iTerm2를 한 번도 실행하지 않은
  # 머신에는 폴더를 만들지 않는다.
  local profiles="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  local themes=$root/iterm2/brand-themes.json
  if [[ -f $themes && -d ${profiles:h} ]] &&
     [[ ! -e $profiles/${themes:t} || $themes -nt $profiles/${themes:t} ]]; then
    zf_mkdir -p $profiles
    command cp $themes $profiles/
  fi
} ${${(%):-%x}:A:h}

source ${${(%):-%x}:A:h}/brands.zsh

# 자동 제안은 회사 프로필과 상관없이 모든 대화형 셸에서 켠다. 끄려면 OH_MY_TERMINAL_SUGGEST=0.
source ${${(%):-%x}:A:h}/autosuggest.zsh
