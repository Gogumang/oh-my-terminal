# ─────────────────────────────────────────────────────────────────────────────
#  oh-my-terminal 자동 제안 — 명령을 치는 동안 히스토리에서 찾은 나머지를 커서 뒤에 흐리게 보여 준다.
#  →·End로 전부 받아들이고 Alt+F(forward-word)로 한 단어씩 받는다. Enter는 친 것만 실행한다.
#
#  zsh-autosuggestions v0.7.1(https://github.com/zsh-users/zsh-autosuggestions)을 분석해 옮겼다.
#    Copyright (c) 2013 Thiago de Arruda
#    Copyright (c) 2016-2021 Eric Freese
#    MIT License — 전문은 licenses/zsh-autosuggestions.txt
#
#  원본과 다른 점
#  - 위젯을 매 프롬프트마다 전부 다시 감싸지 않는다. 원본은 다른 플러그인이 나중에 감싼 위젯을
#    놓치지 않으려고 프롬프트마다 $(zle -la)를 fork 해 수백 개를 eval 한다(oh-my-zsh + p10k에서
#    프롬프트당 5.8ms). 위젯 표와 위젯 목록 설정이 바뀐 프롬프트에서만 감싸도 결과가 같다(0.46ms).
#  - 빠르게 친(입력이 밀린) 글자가 옛 제안과 우연히 겹쳐도 히스토리에 없는 제안을 만들지 않는다.
#  - macOS에서도 completion 전략이 줄바꿈이 든 버퍼를 제안하고, 동기 모드에서도 completion이 돈다.
#  - 늦게 도착한 비동기 결과가 그사이 바뀐 버퍼로 시작하지 않으면 버린다.
#  - 설정은 OH_MY_TERMINAL_SUGGEST_*, 위젯은 omt-suggest-* 이름을 쓴다. zsh-autosuggestions가 먼저
#    불려 있으면 아무것도 하지 않는다 — 둘이 같은 위젯을 겹쳐 감싸면 제안을 두 번 계산한다.
# ─────────────────────────────────────────────────────────────────────────────

# zle은 대화형 셸에만 있다. OH_MY_TERMINAL_SUGGEST=0 이면 끈다. 두 번 source 해도 한 번만 감싼다.
[[ -o interactive && ${OH_MY_TERMINAL_SUGGEST:-1} != 0 ]] || return 0
(( $+functions[_zsh_autosuggest_start] || $+functions[_omt_suggest_start] )) && return 0
autoload -Uz add-zsh-hook is-at-least
# 입력이 밀려 있는지(KEYS_QUEUED_COUNT) 알 수 있는 5.4부터 쓴다. 모르면 붙여넣기 글자마다 제안을 찾는다.
is-at-least 5.4 || return 0

#── 설정 ──────────────────────────────────────────────────────────────────────
# source 전에 사용자가 정한 값은 덮지 않는다.

# 제안 글자 모양 (region_highlight 형식). 브랜드 프로필의 ANSI 8번은 검정 배경 위 회색이다.
(( $+OH_MY_TERMINAL_SUGGEST_STYLE )) || typeset -g OH_MY_TERMINAL_SUGGEST_STYLE='fg=8'

# 제안을 찾는 방법. 앞에서부터 시도해 처음 나온 제안을 쓴다 — history, match_prev_cmd, completion.
(( $+OH_MY_TERMINAL_SUGGEST_STRATEGY )) || typeset -ga OH_MY_TERMINAL_SUGGEST_STRATEGY=(history)

# 1이면 제안을 자식 프로세스에서 찾는다 — 히스토리가 크거나 completion 전략이어도 입력이 멈추지 않는다.
(( $+OH_MY_TERMINAL_SUGGEST_ASYNC )) || typeset -g OH_MY_TERMINAL_SUGGEST_ASYNC=1

# 그 밖에 비워 둔 설정: OH_MY_TERMINAL_SUGGEST_BUFFER_MAX_SIZE (이보다 긴 버퍼는 찾지 않음),
# OH_MY_TERMINAL_SUGGEST_HISTORY_IGNORE / _COMPLETION_IGNORE (이 패턴에 맞으면 제안하지 않음).

# 제안을 지우는 위젯 — 히스토리를 넘기거나 실행할 때 옛 제안이 남으면 안 된다.
(( $+OH_MY_TERMINAL_SUGGEST_CLEAR_WIDGETS )) || typeset -ga OH_MY_TERMINAL_SUGGEST_CLEAR_WIDGETS=(
  history-search-forward history-search-backward
  history-beginning-search-forward history-beginning-search-backward
  history-beginning-search-forward-end history-beginning-search-backward-end
  history-substring-search-up history-substring-search-down
  up-line-or-beginning-search down-line-or-beginning-search
  up-line-or-history down-line-or-history
  accept-line copy-earlier-word
)

# 커서가 끝에 있을 때 제안 전체를 받아들이는 위젯.
(( $+OH_MY_TERMINAL_SUGGEST_ACCEPT_WIDGETS )) || typeset -ga OH_MY_TERMINAL_SUGGEST_ACCEPT_WIDGETS=(
  forward-char end-of-line vi-forward-char vi-end-of-line vi-add-eol
)

# 제안 전체를 받아들이고 바로 실행하는 위젯 (기본은 없음).
(( $+OH_MY_TERMINAL_SUGGEST_EXECUTE_WIDGETS )) || typeset -ga OH_MY_TERMINAL_SUGGEST_EXECUTE_WIDGETS=()

# 커서가 움직인 만큼만 제안을 받아들이는 위젯.
(( $+OH_MY_TERMINAL_SUGGEST_PARTIAL_ACCEPT_WIDGETS )) || typeset -ga OH_MY_TERMINAL_SUGGEST_PARTIAL_ACCEPT_WIDGETS=(
  forward-word emacs-forward-word
  vi-forward-word vi-forward-word-end vi-forward-blank-word vi-forward-blank-word-end
  vi-find-next-char vi-find-next-char-skip
)

# 감싸지 않는 위젯 (glob 패턴). 여기에 없고 위 목록에도 없는 위젯은 버퍼를 바꿀 수 있다고 보고
# 실행 뒤 제안을 다시 찾는다.
(( $+OH_MY_TERMINAL_SUGGEST_IGNORE_WIDGETS )) || typeset -ga OH_MY_TERMINAL_SUGGEST_IGNORE_WIDGETS=(
  'orig-*' beep run-help set-local-history which-command yank yank-pop 'zle-*'
)

#── 위젯 감싸기 ───────────────────────────────────────────────────────────────

_omt_suggest_incr_bind_count() {
  # 호출한 함수의 local bind_count에 쓴다 (typeset -g는 가장 가까운 바깥 스코프를 가리킨다).
  typeset -gi bind_count=$(( _omt_suggest_bind_counts[$1] + 1 ))
  _omt_suggest_bind_counts[$1]=$bind_count
}

# 위젯 하나를 자동 제안 동작으로 감싼다. 원래 위젯은 omt-suggest-orig-<번호>-<이름>으로 남긴다.
# 번호는 감쌀 때마다 올린다 — 다른 플러그인이 우리 위젯을 다시 감싸고, 우리가 또 감싸도 원래
# 동작 사슬이 끊기지 않는다.
_omt_suggest_bind_widget() {
  typeset -gA _omt_suggest_bind_counts
  local widget=$1 action=$2 prefix=omt-suggest-orig-
  local -i bind_count

  case $widgets[$widget] in
    # 이미 감쌌다 — 동작(action)만 새 설정으로 바꾼다.
    (user:_omt_suggest_(bound|orig)_*)
      bind_count=$(( _omt_suggest_bind_counts[$widget] ))
      ;;
    (user:*)
      _omt_suggest_incr_bind_count $widget
      zle -N -- $prefix$bind_count-$widget ${widgets[$widget]#*:}
      ;;
    (builtin)
      _omt_suggest_incr_bind_count $widget
      eval "_omt_suggest_orig_${(q)widget}() { zle .${(q)widget} }"
      zle -N -- $prefix$bind_count-$widget _omt_suggest_orig_$widget
      ;;
    (completion:*)
      _omt_suggest_incr_bind_count $widget
      eval "zle -C ${(q)prefix}$bind_count-${(q)widget} ${${(s.:.)widgets[$widget]}[2,3]}"
      ;;
  esac

  # 원래 위젯 이름을 인자로 넘긴다. $WIDGET은 믿을 수 없다 — 다른 플러그인이 `zle self-insert`처럼
  # -w 없이 부르면 바깥 위젯 이름이 들어 있다.
  eval "_omt_suggest_bound_${bind_count}_${(q)widget}() {
    _omt_suggest_widget_$action ${(q)prefix}$bind_count-${(q)widget} \"\$@\"
  }"
  zle -N -- $widget _omt_suggest_bound_${bind_count}_$widget
}

_omt_suggest_bind_widgets() {
  emulate -L zsh -o extended_glob
  local widget
  local -a ignore=('.*' '_*' 'omt-suggest-*' $OH_MY_TERMINAL_SUGGEST_IGNORE_WIDGETS)

  # 위젯 목록은 $widgets 키에서 얻는다 — $(zle -la)는 부를 때마다 fork 한다.
  for widget in ${${(k)widgets}:#(${(j:|:)~ignore})}; do
    if (( ${OH_MY_TERMINAL_SUGGEST_CLEAR_WIDGETS[(Ie)$widget]} )); then
      _omt_suggest_bind_widget $widget clear
    elif (( ${OH_MY_TERMINAL_SUGGEST_ACCEPT_WIDGETS[(Ie)$widget]} )); then
      _omt_suggest_bind_widget $widget accept
    elif (( ${OH_MY_TERMINAL_SUGGEST_EXECUTE_WIDGETS[(Ie)$widget]} )); then
      _omt_suggest_bind_widget $widget execute
    elif (( ${OH_MY_TERMINAL_SUGGEST_PARTIAL_ACCEPT_WIDGETS[(Ie)$widget]} )); then
      _omt_suggest_bind_widget $widget partial_accept
    else
      _omt_suggest_bind_widget $widget modify
    fi
  done
}

_omt_suggest_invoke_original_widget() {
  (( $# )) || return 0
  local original=$1
  shift
  if (( ${+widgets[$original]} )); then
    zle $original -- "$@"
  fi
}

#── 강조 ──────────────────────────────────────────────────────────────────────

_omt_suggest_highlight_reset() {
  typeset -g _omt_suggest_last_highlight
  if [[ -n $_omt_suggest_last_highlight ]]; then
    region_highlight=("${(@)region_highlight:#$_omt_suggest_last_highlight}")
    _omt_suggest_last_highlight=
  fi
}

_omt_suggest_highlight_apply() {
  typeset -g _omt_suggest_last_highlight
  if (( $#POSTDISPLAY )); then
    _omt_suggest_last_highlight="$#BUFFER $(( $#BUFFER + $#POSTDISPLAY )) $OH_MY_TERMINAL_SUGGEST_STYLE"
    region_highlight+=("$_omt_suggest_last_highlight")
  else
    _omt_suggest_last_highlight=
  fi
}

#── 위젯 동작 ─────────────────────────────────────────────────────────────────

_omt_suggest_disable() {
  typeset -g _omt_suggest_disabled
  _omt_suggest_clear
}

_omt_suggest_enable() {
  unset _omt_suggest_disabled
  (( $#BUFFER )) && _omt_suggest_fetch
  return 0
}

_omt_suggest_toggle() {
  if (( $+_omt_suggest_disabled )); then
    _omt_suggest_enable
  else
    _omt_suggest_disable
  fi
}

_omt_suggest_clear() {
  # unset 하지 않고 비운다 — POSTDISPLAY는 zle 특수 변수라 unset 하면 다시 못 쓴다.
  POSTDISPLAY=
  _omt_suggest_invoke_original_widget "$@"
}

# 버퍼를 바꿀 수 있는 위젯. 원래 위젯을 돌린 뒤 제안을 다시 찾는다.
_omt_suggest_modify() {
  local -i retval
  local orig_buffer=$BUFFER orig_postdisplay=$POSTDISPLAY

  POSTDISPLAY=
  # 원래 위젯은 사용자 옵션 그대로 돌린다 — emulate는 그 뒤에 한다.
  _omt_suggest_invoke_original_widget "$@"
  retval=$?

  emulate -L zsh

  # 제안을 따라 쳤거나 버퍼가 그대로면 다시 찾지 않고 친 만큼 제안을 줄인다.
  if [[ $BUFFER == "$orig_buffer"* && $orig_postdisplay == "${BUFFER:$#orig_buffer}"* ]]; then
    POSTDISPLAY=${orig_postdisplay:$(( $#BUFFER - $#orig_buffer ))}
    return $retval
  fi

  # 입력이 밀려 있으면(붙여넣기·빠른 입력) 마지막 글자에서 한 번만 찾는다. 원본은 여기서 옛 제안을
  # 되살렸는데, 그 제안은 이미 버퍼와 어긋나 있어 뒤이은 글자가 우연히 겹치면 히스토리에 없는
  # 제안이 만들어졌다 ('ls' 제안 ' bar' 뒤에 'x '를 한 번에 치면 'lsx '에 'bar').
  (( PENDING > 0 || KEYS_QUEUED_COUNT > 0 )) && return $retval
  (( $+_omt_suggest_disabled )) && return $retval
  (( $#BUFFER )) || return $retval
  if [[ -n $OH_MY_TERMINAL_SUGGEST_BUFFER_MAX_SIZE ]] &&
     (( $#BUFFER > OH_MY_TERMINAL_SUGGEST_BUFFER_MAX_SIZE )); then
    return $retval
  fi

  _omt_suggest_fetch
  return $retval
}

_omt_suggest_fetch() {
  if [[ ${OH_MY_TERMINAL_SUGGEST_ASYNC:-1} != 0 ]]; then
    _omt_suggest_async_request "$BUFFER"
  else
    local suggestion
    _omt_suggest_fetch_suggestion "$BUFFER"
    _omt_suggest_suggest "$suggestion"
  fi
}

_omt_suggest_suggest() {
  emulate -L zsh
  local suggestion=$1
  # 비동기 결과는 늦게 올 수 있다. 그사이 버퍼가 바뀌어(입력이 밀려 새로 요청하지 않은 경우 등)
  # 결과가 지금 버퍼로 시작하지 않으면 버린다 — 앞부분을 잘라 붙이면 버퍼와 상관없는 글자가 붙는다.
  if [[ -n $suggestion && $suggestion == "$BUFFER"* ]] && (( $#BUFFER )); then
    POSTDISPLAY=${suggestion:$#BUFFER}
  else
    POSTDISPLAY=
  fi
}

_omt_suggest_accept() {
  local -i retval max_cursor_pos=$#BUFFER

  # vi 명령 모드에서는 커서가 버퍼 끝까지 가지 못한다.
  [[ $KEYMAP == vicmd ]] && max_cursor_pos=$(( max_cursor_pos - 1 ))

  # 커서가 끝이 아니거나 제안이 없으면 원래 위젯만 돌린다 (→가 그냥 커서를 옮기게).
  if (( CURSOR != max_cursor_pos || ! $#POSTDISPLAY )); then
    _omt_suggest_invoke_original_widget "$@"
    return
  fi

  BUFFER=$BUFFER$POSTDISPLAY
  POSTDISPLAY=

  # 원래 위젯을 먼저 돌리고 커서를 옮긴다 — 반대로 하면 위젯이 옮긴 커서를 기준으로 또 움직인다.
  _omt_suggest_invoke_original_widget "$@"
  retval=$?

  if [[ $KEYMAP == vicmd ]]; then
    CURSOR=$(( $#BUFFER - 1 ))
  else
    CURSOR=$#BUFFER
  fi
  return $retval
}

_omt_suggest_execute() {
  BUFFER=$BUFFER$POSTDISPLAY
  POSTDISPLAY=
  # 원래 accept-line을 이름으로 부른다 — 다른 플러그인이 감싼 accept-line 동작도 돌게.
  _omt_suggest_invoke_original_widget accept-line
}

# 제안을 잠시 버퍼에 붙여 원래 위젯이 커서를 옮기게 하고, 커서 뒤는 다시 제안으로 돌린다.
_omt_suggest_partial_accept() {
  local -i retval cursor_loc
  local original_buffer=$BUFFER

  BUFFER=$BUFFER$POSTDISPLAY
  _omt_suggest_invoke_original_widget "$@"
  retval=$?

  cursor_loc=$CURSOR
  [[ $KEYMAP == vicmd ]] && cursor_loc=$(( cursor_loc + 1 ))

  if (( cursor_loc > $#original_buffer )); then
    POSTDISPLAY=${BUFFER[$(( cursor_loc + 1 )),$#BUFFER]}
    BUFFER=${BUFFER[1,$cursor_loc]}
  else
    BUFFER=$original_buffer
  fi
  return $retval
}

# 모든 동작을 같은 틀로 감싼다: 강조를 걷고 → 동작 → 강조를 다시 입히고 → 다시 그린다.
() {
  local action
  for action in clear fetch suggest accept execute enable disable toggle modify partial_accept; do
    eval "_omt_suggest_widget_$action() {
      local -i retval
      _omt_suggest_highlight_reset
      _omt_suggest_$action \"\$@\"
      retval=\$?
      _omt_suggest_highlight_apply
      zle -R
      return \$retval
    }"
  done
  # bindkey로 쓸 수 있는 위젯: omt-suggest-accept, -execute, -clear, -fetch, -enable, -disable, -toggle
  for action in clear fetch suggest accept execute enable disable toggle; do
    zle -N omt-suggest-$action _omt_suggest_widget_$action
  done
}

#── 전략: history ────────────────────────────────────────────────────────────
# 친 글자로 시작하는 가장 최근 히스토리 항목.

_omt_suggest_strategy_history() {
  emulate -L zsh -o extended_glob
  # $history 값을 패턴으로 찾으므로 친 글자 속 glob 문자를 이스케이프한다.
  local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
  local pattern="$prefix*"
  if [[ -n $OH_MY_TERMINAL_SUGGEST_HISTORY_IGNORE ]]; then
    pattern="($pattern)~($OH_MY_TERMINAL_SUGGEST_HISTORY_IGNORE)"
  fi
  # (r)은 최신 항목부터 찾는다.
  typeset -g suggestion="${history[(r)$pattern]}"
}

#── 전략: match_prev_cmd ─────────────────────────────────────────────────────
# history와 같되, 방금 실행한 명령 다음에 쳤던 항목을 먼저 고른다. 히스토리: pwd, ls foo, ls bar, pwd
# 에서 ls를 치면, 방금 실행한 pwd 다음에 쳤던 ls foo를 제안한다. HIST_IGNORE_ALL_DUPS처럼 순서를
# 바꾸는 옵션과는 맞지 않는다.

_omt_suggest_strategy_match_prev_cmd() {
  emulate -L zsh -o extended_glob
  local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
  local pattern="$prefix*"
  if [[ -n $OH_MY_TERMINAL_SUGGEST_HISTORY_IGNORE ]]; then
    pattern="($pattern)~($OH_MY_TERMINAL_SUGGEST_HISTORY_IGNORE)"
  fi

  local -a keys=(${(k)history[(R)$~pattern]})
  local histkey=$keys[1] key
  local prev_cmd=${history[$(( HISTCMD - 1 ))]}

  # 가장 최근 200개만 본다. 비교는 글자 그대로 한다 (따옴표로 감싼 오른쪽은 패턴이 아니다).
  for key in "${(@)keys[1,200]}"; do
    (( key > 1 )) || break
    if [[ ${history[$(( key - 1 ))]} == "$prev_cmd" ]]; then
      histkey=$key
      break
    fi
  done
  typeset -g suggestion="$history[$histkey]"
}

#── 전략: completion ─────────────────────────────────────────────────────────
# 탭 완성이 처음 내놓는 결과. 새 pty에서 vared로 zle을 열어 버퍼를 넣고 탭을 눌러, 완성된 버퍼를
# NUL로 감싸 읽는다. compinit이 필요하다.

typeset -g _omt_suggest_completion_pty=omt_suggest_completion_pty

_omt_suggest_capture_postcompletion() {
  # 목록을 띄우지 말고 첫 결과를 바로 넣는다.
  compstate[insert]=1
  unset 'compstate[list]'
}

_omt_suggest_capture_completion_widget() {
  local -a +h comppostfuncs
  comppostfuncs=(_omt_suggest_capture_postcompletion)

  CURSOR=$#BUFFER

  # .complete-word를 감싼 원래 완성 위젯을 부른다 — 감싼 쪽을 부르면 이 pty 안에서 또 제안을 찾는다.
  zle -- ${(k)widgets[(r)completion:.complete-word:_main_complete]}

  # pty가 줄바꿈을 CR LF로 바꾸지 않게 한다. 원본은 `stty -F /dev/tty`인데 macOS stty에는 -F가 없어
  # (illegal option, -f만 있다) 실패하고, 줄바꿈이 든 버퍼는 제안이 나오지 않았다. 대상 tty를 stdin
  # 으로 넘기면 GNU·BSD stty 모두에서 된다.
  stty -onlcr -ocrnl </dev/tty

  echo -nE - $'\0'$BUFFER$'\0'
}
zle -N omt-suggest-capture-completion _omt_suggest_capture_completion_widget

_omt_suggest_capture_completion() {
  # 접두사와 다른 제안이 나오지 않게 완성 규칙을 좁힌다.
  zstyle ':completion:*' matcher-list ''
  zstyle ':completion:*' path-completion false
  zstyle ':completion:*' max-errors 0 not-numeric
  bindkey '^I' omt-suggest-capture-completion

  zmodload zsh/parameter 2>/dev/null || return

  # vared 안에서도 명령줄처럼 완성되게 한다.
  autoload +X _complete
  functions[_original_complete]=$functions[_complete]
  function _complete() {
    unset 'compstate[vared]'
    _original_complete "$@"
  }

  vared 1
}

_omt_suggest_strategy_completion() {
  emulate -L zsh -o extended_glob
  typeset -g suggestion
  local line REPLY

  whence compdef >/dev/null || return
  zmodload zsh/zpty 2>/dev/null || return
  if [[ -n $OH_MY_TERMINAL_SUGGEST_COMPLETION_IGNORE && $1 == $~OH_MY_TERMINAL_SUGGEST_COMPLETION_IGNORE ]]; then
    return
  fi

  # 위젯 안(동기 모드)에서는 pty 속 자식이 vared를 열 수 없다. 원본의 동기 경로(자식에서 위젯을 부름)를
  # 옮기자 제안이 나오지 않았다. 명령 치환 속 자식에는 zle이 없으므로 비동기 모드와 같은 길로 부른다.
  if zle; then
    suggestion="$(_omt_suggest_strategy_completion "$1"; print -rn -- "$suggestion")"
    return
  fi

  zpty $_omt_suggest_completion_pty _omt_suggest_capture_completion "\$1"
  zpty -w $_omt_suggest_completion_pty $'\t'

  {
    zpty -r $_omt_suggest_completion_pty line '*'$'\0''*'$'\0'
    suggestion=${${(@0)line}[2]}
  } always {
    zpty -d $_omt_suggest_completion_pty
  }
}

#── 제안 찾기 ─────────────────────────────────────────────────────────────────

_omt_suggest_fetch_suggestion() {
  typeset -g suggestion
  local strategy
  # 배열로도, 공백으로 나눈 문자열로도 받는다.
  for strategy in ${=OH_MY_TERMINAL_SUGGEST_STRATEGY}; do
    (( $+functions[_omt_suggest_strategy_$strategy] )) || continue
    _omt_suggest_strategy_$strategy "$1"
    # 친 글자로 시작하지 않는 제안은 버린다 — 전략이 무엇을 돌려주든 화면이 틀어지지 않게.
    [[ $suggestion == "$1"* ]] || suggestion=
    [[ -n $suggestion ]] && break
  done
}

#── 비동기 ────────────────────────────────────────────────────────────────────

_omt_suggest_async_request() {
  zmodload zsh/system 2>/dev/null   # $sysparams
  typeset -g _omt_suggest_async_fd _omt_suggest_child_pid

  # 아직 답이 안 온 요청은 취소한다.
  if [[ -n $_omt_suggest_async_fd ]] && { true <&$_omt_suggest_async_fd } 2>/dev/null; then
    builtin exec {_omt_suggest_async_fd}<&-
    zle -F $_omt_suggest_async_fd
    if [[ -n $_omt_suggest_child_pid ]]; then
      # MONITOR가 켜져 있으면 자식이 새 프로세스 그룹이다 — 전략이 띄운 손자까지 함께 끝낸다.
      if [[ -o MONITOR ]]; then
        kill -TERM -$_omt_suggest_child_pid 2>/dev/null
      else
        kill -TERM $_omt_suggest_child_pid 2>/dev/null
      fi
    fi
  fi

  builtin exec {_omt_suggest_async_fd}< <(
    echo $sysparams[pid]
    local suggestion
    _omt_suggest_fetch_suggestion "$1"
    echo -nE "$suggestion"
  )

  # 5.8 미만에서는 여기서 한 번 fork 하지 않으면 제안 직후 ^C가 먹지 않는다 (zsh-autosuggestions #364).
  is-at-least 5.8 || command true

  read _omt_suggest_child_pid <&$_omt_suggest_async_fd
  zle -F "$_omt_suggest_async_fd" _omt_suggest_async_response
}

# fd를 읽을 수 있게 되면 불린다. $1은 fd, $2는 오류가 있을 때만 들어온다.
_omt_suggest_async_response() {
  emulate -L zsh
  local suggestion

  if [[ -z $2 || $2 == hup ]]; then
    IFS='' read -rd '' -u $1 suggestion
    zle omt-suggest-suggest -- "$suggestion"
    builtin exec {1}<&-
  fi

  # 처리기는 오류가 나도 반드시 뗀다 — 남으면 닫힌 fd로 계속 불린다.
  zle -F "$1"
  _omt_suggest_async_fd=
}

#── 시작 ──────────────────────────────────────────────────────────────────────

# 위젯 표와 위젯 목록 설정을 한 문자열로 모은다. 이것이 그대로면 감쌀 것도 그대로다.
_omt_suggest_signature() {
  emulate -L zsh
  local list
  REPLY=${(pj:\n:)${(@kv)widgets}}
  for list in CLEAR ACCEPT EXECUTE PARTIAL_ACCEPT IGNORE; do
    list=OH_MY_TERMINAL_SUGGEST_${list}_WIDGETS
    REPLY+=$'\x1e'${(pj:\n:)${(P)list}}
  done
}

# 프롬프트마다 불린다. 첫 프롬프트에서는 .zshrc가 끝나 다른 플러그인의 위젯이 다 정의돼 있다.
# 그 뒤로는 다른 플러그인이 위젯을 새로 감쌌거나(p10k는 첫 프롬프트에서 한 번) 사용자가 위젯 목록을
# 바꿨을 때만 다시 감싼다.
_omt_suggest_start() {
  emulate -L zsh
  local REPLY
  _omt_suggest_signature
  [[ $REPLY == "$_omt_suggest_bound_signature" ]] && return
  _omt_suggest_bind_widgets
  _omt_suggest_signature
  typeset -g _omt_suggest_bound_signature=$REPLY
}

add-zsh-hook precmd _omt_suggest_start
