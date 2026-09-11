#!/usr/bin/env bash
# oh-my-terminal 설치 — ~/.zshrc 에 source 한 줄을 넣는다. 플러그인 관리자를 쓰면 필요 없다.
# 빌드 도구 없이 동작한다. 생성물은 저장소에 커밋돼 있다.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENTRY="$ROOT/oh-my-terminal.zsh"
LINE="[[ ! -f $ENTRY ]] || source $ENTRY"
ZSHRC="$HOME/.zshrc"

echo "oh-my-terminal 설치"

# 1) 로고 폰트·iTerm2 프로필 — 진입점이 source 될 때 설치·갱신한다. 새 셸을 기다리지 않고
#    바로 프로필을 고를 수 있게 여기서 한 번 불러 준다.
zsh -fc 'source "$1"' zsh "$ENTRY"
echo "  폰트·프로필 → ~/Library/Fonts, iTerm2 DynamicProfiles"

# 2) 프롬프트
if grep -qF "$ENTRY" "$ZSHRC" 2>/dev/null; then
  echo "  프롬프트 → 이미 설정됨"
else
  [ ! -f "$ZSHRC" ] || cp "$ZSHRC" "$ZSHRC.backup-$(date +%Y%m%d-%H%M%S)"
  if grep -qF "$ROOT/brands.zsh" "$ZSHRC" 2>/dev/null; then
    # 예전 설치가 넣은 brands.zsh 줄을 진입점으로 바꾼다. 그 줄로는 폰트·프로필이 갱신되지 않는다.
    updated="$(awk -v old="$ROOT/brands.zsh" -v new="$LINE" 'index($0, old) { print new; next } { print }' "$ZSHRC")"
    printf '%s\n' "$updated" > "$ZSHRC"
    echo "  프롬프트 → ~/.zshrc 의 brands.zsh 줄을 교체 (백업 생성됨)"
  else
    printf '\n# oh-my-terminal — 회사별 프롬프트 테마\n%s\n' "$LINE" >> "$ZSHRC"
    echo "  프롬프트 → ~/.zshrc (백업 생성됨)"
  fi
fi

cat <<'DONE'

완료. 회사를 고르세요 (iTerm2 재시작은 필요 없습니다):
    iTerm2 → Settings → Profiles → "<회사> Brand" 선택 → Other Actions… → Set as Default
    새 창부터 어느 폴더에서나 그 회사 테마가 나옵니다.
    (한 번만 쓰려면 ⌘O로 그 프로필 창을 여세요)
DONE
