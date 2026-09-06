#!/usr/bin/env bash
# oh-my-terminal 설치 — 빌드 도구 없이 동작한다. 생성물은 저장소에 커밋돼 있다.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONT_DIR="$HOME/Library/Fonts"
ITERM_PROFILES="$HOME/Library/Application Support/iTerm2/DynamicProfiles"

echo "oh-my-terminal 설치"

# 1) 로고 폰트
if compgen -G "$ROOT/fonts/*.ttf" >/dev/null; then
  mkdir -p "$FONT_DIR"
  cp "$ROOT"/fonts/*.ttf "$FONT_DIR/"
  echo "  폰트    → $FONT_DIR"
fi

# 2) iTerm2 프로필 (폴더에 넣으면 재시작 없이 즉시 반영된다)
if [ -f "$ROOT/iterm2/brand-themes.json" ]; then
  mkdir -p "$ITERM_PROFILES"
  cp "$ROOT/iterm2/brand-themes.json" "$ITERM_PROFILES/"
  echo "  프로필  → $ITERM_PROFILES"
fi

# 3) 프롬프트 — .p10k.zsh 를 source 한 '뒤에' 와야 덮어쓸 수 있다
LINE="[[ ! -f $ROOT/brands.zsh ]] || source $ROOT/brands.zsh"
if grep -qF "$ROOT/brands.zsh" "$HOME/.zshrc" 2>/dev/null; then
  echo "  프롬프트 → 이미 설정됨"
else
  cp "$HOME/.zshrc" "$HOME/.zshrc.backup-$(date +%Y%m%d-%H%M%S)"
  printf '\n# oh-my-terminal — 회사별 프롬프트 테마\n%s\n' "$LINE" >> "$HOME/.zshrc"
  echo "  프롬프트 → ~/.zshrc (백업 생성됨)"
fi

cat <<'DONE'

완료. 새 셸에서 확인:
    exec zsh && cd ~/Desktop/kakao

로고가 네모로 보이면 iTerm2 프로필을 브랜드 프로필로 바꾸세요 (⌘O).
현재 프로필 폰트에 로고 글리프가 없어서입니다.
DONE
