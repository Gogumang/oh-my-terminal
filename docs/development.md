# 개발

테마를 다시 만들거나 회사·로고를 추가하는 메인테이너용 안내입니다. 왜 이렇게 만들었는지는 [설계 노트](design-notes.md)에 있습니다.

## 무엇이 바뀌나

네 부분이 각각 다른 것을 담당합니다. 셸 프롬프트만으로는 테마의 절반밖에 못 합니다.

| 계층 | 담당 | 파일 |
|---|---|---|
| iTerm2 프로필 | 검정 배경·흰 글자(라이트 모드에서도), ANSI 16색, 커서·탭 색, 로고 폰트 | `iterm2/brand-themes.json` |
| zsh 프롬프트 | 경로 세그먼트의 브랜드 그라데이션과 로고 | `brands.zsh` |
| 폰트 | MesloLGS NF + 로고 외곽선 글리프 (U+100000~ 사용자 영역) | `fonts/OhMyTerminalBrand.ttf` |
| 자동 제안 | 치는 동안 히스토리에서 나머지를 흐리게 제안 | `autosuggest.zsh` |

진입점 `oh-my-terminal.zsh`가 폰트와 프로필을 `~/Library/Fonts`,
`~/Library/Application Support/iTerm2/DynamicProfiles`에 복사하고 `brands.zsh`와 `autosuggest.zsh`를
불러옵니다. `brands.zsh`는 **순수 zsh**입니다 — 외부 명령을 하나도 호출하지 않습니다. 진입점도
파일이 바뀌었을 때만 `cp`를 부릅니다.

## 회사 추가

`catalog/brands.json`에 **440개 회사**의 브랜드 색과 로고 출처가 들어 있고
([oh-my-design](https://github.com/kwakseongjae/oh-my-design), MIT), 그중 **로고를 확보한
279개가 켜져 있습니다.** 나머지 161개는 출처가 봇 차단이거나 죽어서 로고를 못 받았습니다
(Simple Icons 92/92 전부 성공, GitHub 18/26, 파비콘 168/322).

회사를 더 켜거나 로고를 다시 받으려면:

```sh
cd tools && cargo build --release && cd ..
tools/target/release/build-themes logos          # 카탈로그 로고를 public/logo/ 에 수집
tools/target/release/build-themes enable <회사>...  # brands/ 에 추가
tools/target/release/build-themes                # 테마 생성
tools/target/release/build-themes gallery        # README 지원 테마 표 + docs/themes/ 그림
```

README의 지원 테마 목록은 `gallery`가 `brands/*.yaml`에서 만듭니다 — `<!-- themes:start -->`와
`<!-- themes:end -->` 사이를 손으로 고치지 마세요. 그림은 셸과 같은 색 계산으로 `~/workspace`
프롬프트를 그린 것이고, 나라별 묶음은 yaml의 `country`(카탈로그의 두 글자 코드)를 따릅니다.
카탈로그에 없어 직접 추가한 회사는 `country`를 직접 적어야 하며, 없으면 `gallery`가 멈춥니다.

**기반 폰트는 p10k 권장 폰트인 MesloLGS NF입니다** (`p10k configure`가 설치하는
`~/Library/Fonts/MesloLGS NF Regular.ttf`). 브랜드 프로필은 이 폰트로 바뀌므로, p10k가 쓰는
Nerd Font 아이콘(git 브랜치 등)이 기반 폰트에 있어야 합니다. 다른 폰트를 쓰려면 Nerd Font
버전을 지정하세요:

```sh
OH_MY_TERMINAL_BASE_FONT=~/Library/Fonts/<Nerd Font>.ttf tools/target/release/build-themes
```

빌더는 Rust입니다(1.88 이상). `cargo build --release` 하나면 되고 다른 의존성이 없습니다.
회사마다 하는 일(로고 가공·그림 그리기·내려받기)은 서로 독립이라 코어 수만큼 동시에 돕니다 —
`gallery`가 279장을 5.3초에서 0.6초로 그립니다. 생성물은 실행 순서와 무관하게 늘 같은 바이트라,
다시 빌드해도 `git status`가 비어 있어야 정상입니다(그렇지 않다면 회귀입니다).

## 로고

완성된 로고는 `public/logo/<회사>.png`(512×512, 투명 배경 실루엣)에 커밋되어 있고, 빌더가
이 모양을 따라 폰트 외곽선으로 굽습니다 — **빌드에 네트워크가 필요 없습니다.** 로고는
프롬프트에서 한 가지 색(띠 위에서 대비가 큰 흰색 또는 검정)으로 칠해지므로 **모양만 중요합니다.**

로고를 바꿀 때는 새 출처에서 받아 같은 규칙으로 가공하고, 프롬프트 크기로 확인하세요:

```sh
tools/target/release/build-themes import <회사> <URL> [--icon|--badge]   # public/logo 교체 + yaml에 출처 기록
tools/target/release/build-themes preview <회사>...                     # build/preview/<회사>.png
```

| 원본 모양 | 옵션 | 처리 |
|---|---|---|
| 투명 배경의 마크 (Simple Icons SVG 등) | 없음 | 그대로 실루엣. 통배경이면 모서리부터 걷어냄 |
| 색 면 위에 마크가 있는 앱 아이콘 | `--icon` | 가장 많은 색(면)을 지우고 마크만 남김 |
| 색 면에 글자를 파낸 배지 (배민·쿠팡) | `--badge` | 면을 남기고 글자를 구멍으로 뚫음 |

미리보기는 실제 크기(레티나 13pt), 4배 확대, 원본을 나란히 보여줍니다. 긴 워드마크보다
짧은 심볼(앱 아이콘 마크, 이니셜)이 작게 봐도 잘 보입니다. 출처는 공식·공개 자산
(Simple Icons, App Store 아이콘, 공식 사이트 아이콘, GitHub 조직 아바타)을 씁니다.

## 테스트

```sh
zsh tests/autosuggest.zsh        # 자동 제안 — 실제 zsh를 zpty로 띄워 키를 보냄 (약 40초)
zsh tests/autosuggest.zsh vi     # 이름에 'vi'가 들어간 것만
cd tools && cargo test           # 테마 생성기
```

## 구조

```
oh-my-terminal.zsh            플러그인 진입점 — 폰트·프로필을 설치하고 brands.zsh·autosuggest.zsh를 불러옴
oh-my-terminal.plugin.zsh     플러그인 관리자(zinit·Antigen·Oh My Zsh)가 찾는 이름
autosuggest.zsh               자동 제안 (zsh-autosuggestions를 옮김)
install.sh                    직접 받았을 때 ~/.zshrc 에 source 줄을 넣어 줌
brands.zsh, fonts/, iterm2/   생성물 — 커밋됨. 사용자는 이것만 있으면 됩니다
brands/*.yaml                 켜둔 회사 정의 (로고 출처 포함)
catalog/brands.json           440개 회사 카탈로그 (언어 중립)
public/logo/                  완성된 로고 (커밋됨, 원본)
logos/                        빌드 작업물 (빌더가 만듭니다)
build/preview/                로고 미리보기 (preview 명령)
docs/themes/                  README 지원 테마 그림 (gallery 명령, 커밋됨)
tests/autosuggest.zsh         자동 제안 통합 테스트
licenses/                     옮겨 온 코드의 라이선스 전문
tools/                        빌드 (메인테이너 전용, Rust)
  src/domain/                   모델·팔레트 계산 (외부 의존 없음)
  src/application/              유스케이스 조립
  src/infrastructure/           로고 수집·가공·폰트/설정 생성·미리보기
```

도메인은 어떤 레이어에도 의존하지 않고, 어댑터가 포트를 구현합니다.

## 규모와 비용

279개를 켠 상태의 실측치입니다. 자동 제안 수치는 zsh-autosuggestions v0.7.1과 같은 조건에서 쟀습니다.

| | 값 |
|---|---|
| 셸 시작 — 테마 (폰트·프로필이 최신일 때) | **1.7ms** (브랜드 프로필), 0.9ms (그 외) |
| 셸 시작 — 자동 제안 (`autosuggest.zsh` source) | 2.2ms (zsh-autosuggestions 2.0ms) |
| 프롬프트마다 — 자동 제안 위젯 확인 | **0.46ms** (zsh-autosuggestions 5.8ms) — oh-my-zsh + p10k, 위젯 630개 |
| `brands.zsh` | 31KB |
| 폰트 | 2.6MB (MesloLGS NF + 로고 조각 외곽선 글리프 745개) |
| iTerm2 프로필 | 1.7MB / 279개 |

