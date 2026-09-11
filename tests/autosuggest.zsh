#!/usr/bin/env zsh
# autosuggest.zsh 통합 테스트.
#
#   zsh tests/autosuggest.zsh           # 전부
#   zsh tests/autosuggest.zsh vi        # 이름에 'vi'가 들어간 것만
#
# 실제 대화형 zsh를 zpty로 띄워 키를 보내고, 테스트용 위젯(^Xd)이 BUFFER·POSTDISPLAY·CURSOR·
# region_highlight를 파일에 쓰게 해 비교한다. zsh-autosuggestions의 spec(rspec + tmux)을 옮겼다 —
# zsh 말고 다른 도구는 필요 없다.
emulate -R zsh
zmodload zsh/zpty zsh/zselect zsh/datetime || exit 1

typeset -g ROOT=${0:A:h:h} TMP=${TMPDIR:-/tmp}/omt-suggest-test-$$ FILTER=$1
typeset -g US=$'\x1f' SCREEN= CURRENT= DETAIL=
typeset -gi PASSED=0 FAILED=0 FAILED_NOW=0
typeset -ga FIELDS
mkdir -p $TMP
trap 'zpty -d T 2>/dev/null; rm -rf $TMP' EXIT

typeset -gA KEY=(
  right $'\e[C'  up $'\e[A'  enter $'\r'  esc $'\e'
  ctrl-a $'\x01'  ctrl-b $'\x02'  ctrl-c $'\x03'  ctrl-e $'\x05'  ctrl-h $'\x08'  ctrl-j $'\x0a'
  ctrl-n $'\x0e'  ctrl-u $'\x15'  ctrl-v $'\x16'  ctrl-y $'\x19'  alt-f $'\ef'  alt-y $'\ey'
)

#── 보고 ──────────────────────────────────────────────────────────────────────

finish() {
  [[ -n $CURRENT ]] || return 0
  if (( FAILED_NOW )); then
    FAILED+=1
    print -r -- "  ✗ $CURRENT"
    print -rn -- "$DETAIL"
  else
    PASSED+=1
    print -r -- "  ✓ $CURRENT"
  fi
  CURRENT=
}

# it <이름> && { ... } — 필터에 걸리지 않으면 건너뛴다.
it() {
  finish
  [[ -z $FILTER || $1 == *$FILTER* ]] || return 1
  CURRENT=$1 FAILED_NOW=0 DETAIL=
}

bad() {
  FAILED_NOW=1
  DETAIL+="      $1"$'\n'
}

#── 세션 ──────────────────────────────────────────────────────────────────────

drain() {
  local chunk
  while zpty -rt T chunk 2>/dev/null; do SCREEN+=$chunk; done
}

send() {
  zpty -w -n T "$1"
  zselect -t 3
  drain
}

wait_file() {  # wait_file <파일> [내용] — 3초까지
  local -F end=$(( EPOCHREALTIME + 3 ))
  while (( EPOCHREALTIME < end )); do
    drain
    if [[ -s $1 ]] && [[ -z $2 || "$(<$1)" == "$2" ]]; then
      return 0
    fi
    zselect -t 2
  done
  return 1
}

# session <source 전 코드> <source 뒤 코드> [히스토리 항목...]
# 여러 줄 항목은 줄 끝에 \ 를 붙여 적는다 (히스토리 파일 형식).
session() {
  local before=$1 after=$2
  shift 2
  zpty -d T 2>/dev/null
  SCREEN=
  rm -f $TMP/ready $TMP/ran $TMP/mark $TMP/calls
  : >| $TMP/out
  print -rl -- "$@" >| $TMP/history

  cat >| $TMP/setup.zsh <<EOF
PS1='> '; RPS1=''; KEYTIMEOUT=1
unsetopt prompt_sp prompt_cr
setopt hist_ignore_space
$before
source ${(q)ROOT}/autosuggest.zsh
$after
fc -p ${(q)TMP}/hist 1000 0
fc -R ${(q)TMP}/history
_t_dump() {
  local nl=\$'\n'
  print -r -- "\${BUFFER//\$nl/↵}$US\${POSTDISPLAY//\$nl/↵}$US\$CURSOR$US\${(j:,:)region_highlight}" >> ${(q)TMP}/out
}
zle -N _t_dump
bindkey -M emacs '^Xd' _t_dump; bindkey -M viins '^Xd' _t_dump; bindkey -M vicmd '^Xd' _t_dump
print ok >| ${(q)TMP}/ready
EOF

  zpty T "env -i PATH=${(q)PATH} HOME=${(q)TMP} TERM=xterm-256color LANG=en_US.UTF-8 zsh -f -i"
  send " source ${(q)TMP}/setup.zsh"$'\r'
  wait_file $TMP/ready || bad '세션을 띄우지 못했다'
  # 첫 precmd(위젯 감싸기)가 끝날 때까지
  zselect -t 15
  drain
}

# run <명령> — 프롬프트에서 실행하고 다음 프롬프트까지 기다린다 (앞 공백 → 히스토리에 안 남음).
run() {
  rm -f $TMP/mark
  send " $1; print ok >| ${(q)TMP}/mark"$'\r'
  wait_file $TMP/mark || bad "실행이 끝나지 않았다: $1"
  zselect -t 15
  drain
}

# 마지막 상태를 FIELDS=(BUFFER POSTDISPLAY CURSOR region_highlight)로 받는다.
dump() {
  : >| $TMP/out
  zpty -w -n T $'\x18d'
  local -F end=$(( EPOCHREALTIME + 1 ))
  until [[ -s $TMP/out ]] || (( EPOCHREALTIME > end )); do
    zselect -t 1
    drain
  done
  # 배열을 먼저 만든다 — 스칼라 대입 안에서 ${${(f)...}[-1]}은 줄이 아니라 마지막 글자를 준다.
  local -a lines=("${(@f)$(<$TMP/out)}")
  FIELDS=("${(@ps:$US:)lines[-1]}")
}

matches() {  # matches <BUFFER> [POSTDISPLAY] [CURSOR] — 마지막 dump의 앞 칸들과 같은지
  [[ "${(pj:$US:)FIELDS[1,$#]}" == "${(pj:$US:)@}" ]]
}

describe() {  # 실패 메시지용: 기대와 실제 앞 칸
  REPLY="기대 [${(j:] [:)@}]  실제 [${(j:] [:)FIELDS[1,$#]}]"
}

# check <BUFFER> [POSTDISPLAY] [CURSOR] — 비동기 제안이 올 때까지 2초 기다린다.
check() {
  local -F end=$(( EPOCHREALTIME + 2 ))
  while :; do
    dump
    matches "$@" && return 0
    (( EPOCHREALTIME < end )) || break
    zselect -t 5
  done
  describe "$@"
  bad "$REPLY"
  return 1
}

# stays <BUFFER> [POSTDISPLAY] — 제안이 오지 않아야 하는 경우. 0.6초 기다린 뒤 한 번 본다.
stays() {
  zselect -t 60
  drain
  dump
  matches "$@" && return 0
  describe "$@"
  bad "0.6초 뒤 $REPLY"
  return 1
}

#── history 전략 ──────────────────────────────────────────────────────────────

it 'history: 친 글자로 시작하는 가장 최근 항목을 제안한다' && {
  session '' '' 'ls foo' 'ls bar' 'echo baz'
  send 'ls'
  check 'ls' ' bar'
}

it 'history: HISTORY_IGNORE 패턴에 맞는 항목은 건너뛴다' && {
  session "OH_MY_TERMINAL_SUGGEST_HISTORY_IGNORE='* bar'" '' 'ls foo' 'ls bar' 'echo baz'
  send 'ls'
  check 'ls' ' foo'
}

it 'history: 맞는 항목이 없으면 제안하지 않는다' && {
  session '' '' 'ls foo'
  send 'pw'
  stays 'pw' ''
}

# 친 글자 속 특수 문자는 패턴이 아니라 글자 그대로 찾아야 한다. 미끼 항목이 더 최근이라,
# 특수 문자를 패턴으로 읽으면 미끼가 제안된다.
typeset -a special=(
  '별표'        'echo "hello*' 'echo "hello*"' 'echo "hello."'
  '물음표'      'echo "hello?' 'echo "hello?"' 'echo "hello."'
  '역슬래시'    'echo "hello\' 'echo "hello\nworld"' ''
  '역슬래시 둘' 'echo "\\'     'echo "\\"' ''
  '물결'        'echo ~'       'echo ~/foo' ''
  '괄호'        'echo "$('     'echo "$(ls foo)"' ''
  '대괄호'      'echo "$history[' 'echo "$history[123]"' ''
  '샵'          'echo "#'      'echo "#yolo"' ''
  '캐럿'        'echo "^A'     'echo "^A"' 'echo "^B"'
  '대시'        '-'            '-foo() {}' ''
)
for name typed wanted decoy in "${special[@]}"; do
  it "history: 특수 문자 — $name" && {
    session '' '' "$wanted" ${decoy:#}
    send "$typed"
    check "$typed" "${wanted:$#typed}"
  }
done

it 'history: 대괄호를 끝까지 따라 쳐도 제안이 이어진다' && {
  session '' '' 'echo "$history[123]"'
  send 'echo "$history['
  check 'echo "$history[' '123]"'
  send '123]'
  check 'echo "$history[123]' '"'
}

it 'history: 여러 줄 항목도 제안한다' && {
  session '' '' 'echo "\' '"'
  send 'e'
  check 'e' 'cho "↵"'
}

#── 받아들이기·지우기 ─────────────────────────────────────────────────────────

it '→(forward-char)는 커서가 끝에 있으면 제안 전체를 받아들인다' && {
  session '' '' 'ls foo' 'ls bar'
  send 'ls'
  check 'ls' ' bar'
  send $KEY[right]
  check 'ls bar' '' 6
}

it 'End(end-of-line)도 제안 전체를 받아들인다' && {
  session '' '' 'ls bar'
  send 'ls'
  check 'ls' ' bar'
  send $KEY[ctrl-e]
  check 'ls bar' '' 6
}

it '커서가 끝이 아니면 →는 커서만 옮기고 제안은 남긴다' && {
  session '' '' 'ls bar'
  send 'ls'
  check 'ls' ' bar'
  send $KEY[ctrl-b]
  send $KEY[right]
  check 'ls' ' bar' 2
}

it 'Alt+F(forward-word)는 커서가 움직인 만큼만 받아들인다' && {
  # zsh의 forward-word는 다음 단어의 '처음'으로 간다 (emacs-forward-word는 단어 끝).
  session '' '' 'echo hello world'
  send 'echo'
  check 'echo' ' hello world'
  send $KEY[alt-f]
  check 'echo ' 'hello world' 5
}

it '제안을 따라 치면 다시 찾지 않고 제안을 줄인다' && {
  session "_omt_suggest_strategy_count() { print x >> ${(q)TMP}/calls }" \
          'OH_MY_TERMINAL_SUGGEST_STRATEGY=(count history)' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  local before="$(<$TMP/calls)"
  send 'c'
  send 'h'
  check 'ech' 'o hello'
  [[ "$(<$TMP/calls)" == "$before" ]] || bad '전략을 다시 불렀다'
}

it '지우면(backward-delete-char) 제안을 다시 찾는다' && {
  session '' '' 'ls foo' 'ls bar'
  send 'ls b'
  check 'ls b' 'ar'
  send $KEY[ctrl-h]
  check 'ls ' 'bar'
}

it '빠르게 친 글자가 옛 제안과 우연히 겹쳐도 히스토리에 없는 제안을 만들지 않는다' && {
  session '' '' 'ls bar'
  send 'ls'
  check 'ls' ' bar'
  send 'x '
  stays 'lsx ' ''
}

it 'Enter는 제안을 빼고 친 것만 실행한다' && {
  session '' '' 'print -r -- typed-and-suggested'
  send 'print -r -- typed'
  check 'print -r -- typed' '-and-suggested'
  send $KEY[enter]
  zselect -t 20
  send $KEY[up]
  check 'print -r -- typed' ''
}

it '위 화살표(up-line-or-history)로 꺼낸 항목에는 제안을 붙이지 않는다' && {
  session '' '' 'ls foo' 'ls foobar'
  send $KEY[up]
  send $KEY[up]
  stays 'ls foo' ''
}

it 'omt-suggest-execute는 제안까지 붙여 바로 실행한다' && {
  session '' 'bindkey "^B" omt-suggest-execute' "print -r -- executed >| ${(q)TMP}/ran"
  send 'print -r -- exe'
  check 'print -r -- exe' "cuted >| $TMP/ran"
  send $KEY[ctrl-b]
  wait_file $TMP/ran executed || bad '실행되지 않았다'
}

it 'omt-suggest-clear는 제안만 지운다' && {
  session '' 'bindkey "^B" omt-suggest-clear' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  send $KEY[ctrl-b]
  check 'e' ''
}

#── 켜고 끄기 ─────────────────────────────────────────────────────────────────

it 'omt-suggest-disable 뒤로는 제안하지 않는다' && {
  session '' 'bindkey "^B" omt-suggest-disable' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  send $KEY[ctrl-b]
  check 'e' ''
  send 'c'
  stays 'ec' ''
}

it 'omt-suggest-enable은 버퍼가 있으면 바로 제안을 찾는다' && {
  session '' 'typeset -g _omt_suggest_disabled; bindkey "^B" omt-suggest-enable' 'echo hello'
  send 'e'
  stays 'e' ''
  send $KEY[ctrl-b]
  check 'e' 'cho hello'
}

it 'omt-suggest-enable은 빈 버퍼에서는 찾지 않는다' && {
  session '' 'typeset -g _omt_suggest_disabled; bindkey "^B" omt-suggest-enable' 'echo hello'
  send $KEY[ctrl-b]
  stays '' ''
}

it 'omt-suggest-toggle은 껐다 켠다' && {
  session '' 'bindkey "^B" omt-suggest-toggle' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  send $KEY[ctrl-b]
  check 'e' ''
  send $KEY[ctrl-b]
  check 'e' 'cho hello'
}

it 'omt-suggest-fetch는 꺼져 있어도 제안을 찾는다' && {
  session '' 'typeset -g _omt_suggest_disabled; bindkey "^B" omt-suggest-fetch' 'echo hello'
  send 'e'
  stays 'e' ''
  send $KEY[ctrl-b]
  check 'e' 'cho hello'
}

#── 설정 ──────────────────────────────────────────────────────────────────────

it 'BUFFER_MAX_SIZE보다 긴 버퍼는 찾지 않는다' && {
  session 'OH_MY_TERMINAL_SUGGEST_BUFFER_MAX_SIZE=4' '' 'echo hello'
  send 'echo'
  check 'echo' ' hello'
  send $KEY[ctrl-u]
  send 'echo h'
  stays 'echo h' ''
}

it 'STYLE로 제안 글자 모양을 바꾼다' && {
  session "OH_MY_TERMINAL_SUGGEST_STYLE='fg=red,bold'" '' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  [[ $FIELDS[4] == '1 10 fg=red,bold' ]] || bad "강조가 [$FIELDS[4]]"
}

it '기본 모양은 fg=8 강조 하나다' && {
  session '' '' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  [[ $FIELDS[4] == '1 10 fg=8' ]] || bad "강조가 [$FIELDS[4]]"
}

it 'STRATEGY는 앞 전략이 못 찾으면 다음 전략을 쓴다 (배열)' && {
  session '_omt_suggest_strategy_nothing() { }' 'OH_MY_TERMINAL_SUGGEST_STRATEGY=(nothing history)' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
}

it 'STRATEGY는 공백으로 나눈 문자열도 받는다' && {
  session '_omt_suggest_strategy_nothing() { }' "OH_MY_TERMINAL_SUGGEST_STRATEGY='nothing history'" 'echo hello'
  send 'e'
  check 'e' 'cho hello'
}

it '전략이 친 글자로 시작하지 않는 값을 돌려주면 버리고 다음 전략을 쓴다' && {
  session '_omt_suggest_strategy_bogus() { typeset -g suggestion=zzz }' 'OH_MY_TERMINAL_SUGGEST_STRATEGY=(bogus history)' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
}

it '없는 전략 이름은 건너뛴다' && {
  session '' 'OH_MY_TERMINAL_SUGGEST_STRATEGY=(nope history)' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  [[ $SCREEN != *'not found'* ]] || bad '오류가 찍혔다'
}

it '동기 모드(ASYNC=0)에서도 제안한다' && {
  session 'OH_MY_TERMINAL_SUGGEST_ASYNC=0' '' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
}

#── 위젯 목록 ─────────────────────────────────────────────────────────────────

widget_setup='my-widget() {}; zle -N my-widget; bindkey "^B" my-widget'

it 'ACCEPT_WIDGETS에 넣은 위젯은 제안을 받아들이고 커서를 끝으로 옮긴다' && {
  session "$widget_setup" 'OH_MY_TERMINAL_SUGGEST_ACCEPT_WIDGETS+=(my-widget)' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  send $KEY[ctrl-b]
  check 'echo hello' '' 10
}

it 'CLEAR_WIDGETS에 넣은 위젯은 제안을 지운다' && {
  session "$widget_setup" 'OH_MY_TERMINAL_SUGGEST_CLEAR_WIDGETS+=(my-widget)' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  send $KEY[ctrl-b]
  check 'e' ''
}

it 'EXECUTE_WIDGETS에 넣은 위젯은 제안을 실행한다' && {
  session "$widget_setup" 'OH_MY_TERMINAL_SUGGEST_EXECUTE_WIDGETS+=(my-widget)' "print -r -- hello >| ${(q)TMP}/ran"
  send 'p'
  check 'p' "rint -r -- hello >| $TMP/ran"
  send $KEY[ctrl-b]
  wait_file $TMP/ran hello || bad '실행되지 않았다'
}

it 'IGNORE_WIDGETS에 넣은 위젯은 감싸지 않는다' && {
  session "$widget_setup" 'OH_MY_TERMINAL_SUGGEST_IGNORE_WIDGETS=(my-widget)'
  run "print -r -- \$widgets[my-widget] >| ${(q)TMP}/ran"
  [[ "$(<$TMP/ran)" == 'user:my-widget' ]] || bad "위젯이 [$(<$TMP/ran)]"
}

it 'PARTIAL_ACCEPT_WIDGETS에 넣은 위젯은 움직인 만큼 받아들인다' && {
  session 'my-widget() { zle forward-char }; zle -N my-widget; bindkey "^B" my-widget' \
          'OH_MY_TERMINAL_SUGGEST_PARTIAL_ACCEPT_WIDGETS=(my-widget)' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  send $KEY[ctrl-b]
  check 'ec' 'ho hello' 2
}

it '어느 목록에도 없는 위젯이 버퍼를 바꾸면 제안을 찾는다' && {
  session 'my-widget() { BUFFER=foo }; zle -N my-widget; bindkey "^B" my-widget' '' 'foobar'
  send $KEY[ctrl-b]
  check 'foo' 'bar'
}

it '실행 중에 위젯 목록을 바꾸면 다음 줄부터 반영된다' && {
  session "$widget_setup" '' 'echo hello'
  run 'OH_MY_TERMINAL_SUGGEST_ACCEPT_WIDGETS+=(my-widget)'
  send 'e'
  check 'e' 'cho hello'
  send $KEY[ctrl-b]
  check 'echo hello' '' 10
}

#── 다른 위젯·플러그인과 함께 ─────────────────────────────────────────────────

it 'source 전에 감싼 사용자 위젯도 원래 동작과 함께 돈다' && {
  session '_orig_bdc() { zle .backward-delete-char }; zle -N orig-backward-delete-char _orig_bdc
           bdc-magic() { zle orig-backward-delete-char; BUFFER+=b }; zle -N backward-delete-char bdc-magic' \
          '' 'foobar' 'foodar'
  send 'food'
  check 'food' 'ar'
  send $KEY[ctrl-h]
  check 'foob' 'ar'
}

it 'source 뒤에 다른 플러그인이 감싼 위젯도 원래 동작과 함께 돈다' && {
  session '' '' 'foobar' 'foodar'
  run 'zle -N orig-backward-delete-char ${widgets[backward-delete-char]#*:}; bdc-magic() { zle orig-backward-delete-char; BUFFER+=b }; zle -N backward-delete-char bdc-magic'
  send 'food'
  check 'food' 'ar'
  send $KEY[ctrl-h]
  check 'foob' 'ar'
}

it 'up-line-or-beginning-search로 히스토리를 넘길 수 있다' && {
  session 'autoload -U up-line-or-beginning-search; zle -N up-line-or-beginning-search; bindkey "^[[A" up-line-or-beginning-search' \
          '' 'echo foo' 'echo bar' 'echo baz'
  send $KEY[up]; send $KEY[up]; send $KEY[up]
  check 'echo foo' ''
}

# 아래 두 위젯은 연달아 불렸는지($LASTWIDGET)로 순환한다. 사이에 dump(^Xd)를 부르면 순환이 끊기므로
# 누르는 횟수마다 새 세션에서 끝 상태만 본다.

it 'copy-earlier-word로 앞 단어를 차례로 복사할 수 있다' && {
  local -a wanted=(baz bar foo)
  for times in 1 2 3; do
    session 'autoload -Uz copy-earlier-word; zle -N copy-earlier-word; bindkey "^N" copy-earlier-word' ''
    send 'foo bar baz'
    zselect -t 30
    repeat $times send $KEY[ctrl-n]
    check "foo bar baz$wanted[times]"
  done
}

it 'yank-pop으로 킬 링을 돌 수 있다' && {
  local -a wanted=('echo bar' 'echo foo' 'echo bar')
  for times in 0 1 2; do
    session '' ''
    send 'echo foo'; send $KEY[ctrl-u]
    send 'echo bar'; send $KEY[ctrl-u]
    send $KEY[ctrl-y]
    repeat $times send $KEY[alt-y]
    check "$wanted[times+1]"
  done
}

it 'zle -U로 넣은 글자가 끝나면 제안한다' && {
  session '' 'foo() { zle -U - "echo hello" }; zle -N foo; bindkey "^B" foo' 'echo hello world'
  send $KEY[ctrl-b]
  check 'echo hello' ' world'
}

it '제안을 찾은 직후에도 ^C가 줄을 끝낸다' && {
  session '' '' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  send $KEY[ctrl-c]
  zselect -t 30
  send 'echo'
  check 'echo' ' hello'
}

it '[ 를 함수로 바꿔 둬도 입력이 깨지지 않는다' && {
  session 'function [ { $commands[\[] "$@" }' ''
  send 'asdf'
  check 'asdf' ''
}

it 'GLOB_SUBST가 켜져 있어도 오류를 찍지 않는다' && {
  session '' 'setopt GLOB_SUBST' 'echo hi'
  send '[['
  check '[[' ''
  [[ $SCREEN != *(bad pattern|error|parse)* ]] || bad "오류가 찍혔다: ${(V)SCREEN[-300,-1]}"
}

paste_magic='autoload -Uz bracketed-paste-magic url-quote-magic; zle -N bracketed-paste bracketed-paste-magic; zle -N self-insert url-quote-magic'

it 'bracketed-paste-magic(oh-my-zsh 기본)으로 붙여넣어도 틀린 제안이 남지 않는다' && {
  session "$paste_magic" '' 'echo hello'
  send $'\e[200~'"echo ${(l:60::a:)}"$'\e[201~'
  stays "echo ${(l:60::a:)}" ''
}

it '제안이 떠 있을 때 붙여넣으면 옛 제안을 버린다' && {
  session "$paste_magic" '' 'echo foo'
  send 'echo '
  check 'echo ' 'foo'
  send $'\e[200~bar\e[201~'
  check 'echo bar' ''
  send $KEY[ctrl-a]
  stays 'echo bar' ''
}

it 'zle-line-init을 IGNORE에서 빼면 줄을 시작할 때마다 제안한다' && {
  session '' 'OH_MY_TERMINAL_SUGGEST_IGNORE_WIDGETS=(${(@)OH_MY_TERMINAL_SUGGEST_IGNORE_WIDGETS:#zle-\*} "zle-^line-init")' 'echo foo'
  run 'zle-line-init() { BUFFER=echo }; zle -N zle-line-init'
  check 'echo' ' foo'
}

#── vi 모드 ───────────────────────────────────────────────────────────────────

vi_send() {  # ESC 뒤 글자가 Alt 조합으로 읽히지 않게 KEYTIMEOUT보다 오래 쉰다.
  send $KEY[esc]
  zselect -t 5
  local key
  for key in "$@"; do send $key; done
}

it 'vi: 명령 모드로 나가 커서를 옮겨도 제안이 남는다' && {
  session 'bindkey -v' '' 'foobar foo'
  send 'foo'
  check 'foo' 'bar foo'
  vi_send h
  check 'foo' 'bar foo'
}

it 'vi: e(vi-forward-word-end)는 단어 끝까지 받아들인다' && {
  session 'bindkey -v' '' 'foobar foo'
  send 'foo'
  check 'foo' 'bar foo'
  vi_send e a
  send 'baz'
  check 'foobarbaz'
}

it 'vi: w(vi-forward-word)는 다음 단어 첫 글자까지 받아들인다' && {
  session 'bindkey -v' '' 'foobar foo'
  send 'foo'
  check 'foo' 'bar foo'
  vi_send w a
  send 'az'
  check 'foobar faz'
}

it 'vi: f(vi-find-next-char)는 그 글자까지 받아들인다' && {
  session 'bindkey -v' '' 'foobar foo'
  send 'foo'
  check 'foo' 'bar foo'
  vi_send f o a
  send 'b'
  check 'foobar fob'
}

it 'vi: dl로 마지막 글자를 지울 수 있다' && {
  session 'bindkey -v' ''
  send 'echo foo'
  vi_send d l
  check 'echo fo'
}

it 'vi: A(vi-add-eol)는 제안을 받아들인다' && {
  session 'bindkey -v' '' 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  vi_send A
  check 'echo hello' '' 10
}

#── match_prev_cmd·completion 전략 ───────────────────────────────────────────

it 'match_prev_cmd: 방금 실행한 명령 다음에 쳤던 항목을 먼저 제안한다' && {
  session '' 'OH_MY_TERMINAL_SUGGEST_STRATEGY=match_prev_cmd' 'echo 1' 'ls foo' 'echo 2' 'ls bar' 'echo 1'
  send 'ls'
  check 'ls' ' foo'
}

comp_setup="autoload -Uz compinit && compinit -u -d ${(q)TMP}/zcompdump
_foo() { compadd bar; compadd bat }; _num() { compadd two; compadd three }
compdef _foo baz; compdef _num one"

it 'completion: 탭 완성의 첫 결과를 제안한다' && {
  session "$comp_setup" 'OH_MY_TERMINAL_SUGGEST_STRATEGY=completion'
  send 'baz '
  check 'baz ' 'bar'
}

it 'completion: 동기 모드에서도 제안한다' && {
  session "$comp_setup" 'OH_MY_TERMINAL_SUGGEST_STRATEGY=completion; OH_MY_TERMINAL_SUGGEST_ASYNC=0'
  send 'baz '
  check 'baz ' 'bar'
}

it 'completion: 줄바꿈이 든 버퍼에 캐리지 리턴을 끼우지 않는다' && {
  session "$comp_setup" 'OH_MY_TERMINAL_SUGGEST_STRATEGY=completion'
  send 'baz \'
  send $KEY[ctrl-v]$KEY[ctrl-j]
  check 'baz \↵' 'bar'
}

it 'completion: _complete가 alias여도 제안한다' && {
  session "$comp_setup; alias _complete=_complete" 'OH_MY_TERMINAL_SUGGEST_STRATEGY=completion'
  send 'baz '
  check 'baz ' 'bar'
}

it 'completion: COMPLETION_IGNORE 패턴에 맞는 버퍼는 제안하지 않는다' && {
  session "$comp_setup" "OH_MY_TERMINAL_SUGGEST_STRATEGY=completion; OH_MY_TERMINAL_SUGGEST_COMPLETION_IGNORE='one *'"
  send 'baz '
  check 'baz ' 'bar'
  send $KEY[ctrl-u]
  send 'one t'
  stays 'one t' ''
}

it 'completion: 사용자가 띄워 둔 zpty를 건드리지 않는다' && {
  session 'zmodload zsh/zpty && zpty -b kitty cat' 'OH_MY_TERMINAL_SUGGEST_STRATEGY=completion'
  send 'a'
  send $KEY[ctrl-h]
  run "zpty -t kitty; print -r -- \$? >| ${(q)TMP}/ran"
  [[ "$(<$TMP/ran)" == 0 ]] || bad "zpty -t 결과 [$(<$TMP/ran)]"
}

#── 불러오기 ──────────────────────────────────────────────────────────────────

it '두 번 source 해도 한 번만 감싼다' && {
  session '' "source ${(q)ROOT}/autosuggest.zsh" 'echo hello'
  send 'e'
  check 'e' 'cho hello'
  [[ $FIELDS[4] == '1 10 fg=8' ]] || bad "강조가 [$FIELDS[4]]"
}

it 'OH_MY_TERMINAL_SUGGEST=0 이면 켜지 않는다' && {
  session 'OH_MY_TERMINAL_SUGGEST=0' '' 'echo hello'
  send 'e'
  stays 'e' ''
}

it 'zsh-autosuggestions가 먼저 불려 있으면 아무것도 하지 않는다' && {
  session '_zsh_autosuggest_start() { }' '' 'echo hello'
  send 'e'
  stays 'e' ''
}

it '대화형이 아닌 셸에서는 조용히 돌아간다' && {
  local out="$(zsh -fc "source ${(q)ROOT}/autosuggest.zsh; print -r -- \$+functions[_omt_suggest_start]" 2>&1)"
  [[ $out == 0 ]] || bad "출력 [$out]"
}

finish
print -r -- ""
print -r -- "통과 $PASSED  실패 $FAILED"
(( FAILED == 0 ))
