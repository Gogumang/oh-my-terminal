# oh-my-terminal

회사 브랜드 색과 로고를 터미널에 입힙니다. 디렉터리에 따라 프롬프트가 자동으로 바뀝니다.

```
 ~/De/kakao ❯     ← 카카오 폴더: 카카오 옐로 그라데이션 + 카카오톡 로고
 ~/De/naver ❯     ← 네이버 폴더: 네이버 그린 + N 로고
 ~/De/study ❯     ← 회사 폴더 밖: 원래 프롬프트 그대로
```

## 설치

파이썬이 필요 없습니다. 생성물이 저장소에 커밋돼 있습니다.

```sh
git clone https://github.com/Gogumang/oh-my-terminal.git
cd oh-my-terminal
./install.sh
exec zsh
```

전제 조건: **zsh + [powerlevel10k](https://github.com/romkatv/powerlevel10k) + iTerm2**.

## 무엇이 바뀌나

세 계층이 각각 다른 것을 담당합니다. 셸 프롬프트만으로는 절반밖에 못 합니다.

| 계층 | 담당 | 파일 |
|---|---|---|
| iTerm2 프로필 | ANSI 16색, 탭 색, 뱃지, 라이트/다크 | `iterm2/brand-themes.json` |
| zsh 프롬프트 | 경로 세그먼트의 브랜드 그라데이션 | `brands.zsh` |
| 폰트 | 로고 글리프 (PUA 코드포인트) | `fonts/*.ttf` |

`brands.zsh`는 **순수 zsh**입니다 — 외부 명령을 하나도 호출하지 않습니다.

## 회사 추가

`catalog/brands.json`에 **440개 회사**의 브랜드 색과 로고 출처가 들어 있습니다
([oh-my-design](https://github.com/kwakseongjae/oh-my-design), MIT). 원하는 회사만 켜면 됩니다.

```sh
cd tools && cargo build --release && cd ..
tools/target/release/build-themes enable coupang line socar
tools/target/release/build-themes
```

**기반 폰트를 지정하세요.** 로고 글리프는 기존 폰트에 얹히므로, 지금 쓰는 폰트를
그대로 패치해야 한글 등이 유지됩니다:

```sh
OH_MY_TERMINAL_BASE_FONT=~/Library/Fonts/D2Coding-Ver1.3.2-20180524-all.ttc \
  tools/target/release/build-themes
```

빌더는 Rust입니다. `cargo build --release` 하나면 되고 다른 의존성이 없습니다.

`brands/<회사>.yaml`의 `paths`를 고치면 어느 디렉터리에서 그 테마를 쓸지 바꿀 수 있습니다.

## 로고를 직접 넣기

| 파일 | 처리 |
|---|---|
| `logos/<회사>.custom.png` | 형태만 쓰고 브랜드 색으로 자동 착색 |
| `logos/<회사>.color.png` | 원본 색 유지 (모서리 배경은 자동 제거) |

둘 다 임포터가 덮어쓰지 않습니다. 색 면에서 글자를 파낸 앱 아이콘은 실루엣으로 만들면
형태가 사라지므로 `.color.png`를 쓰세요.

## 설계 노트

- **ANSI 0~15은 브랜드 색으로 덮지 않습니다.** `red=에러`, `green=성공` 의미가 무너지면
  로그를 읽을 수 없습니다. 브랜드 색은 배경·커서·탭·뱃지에만 들어갑니다.
- **그라데이션 깊이는 회사마다 다릅니다.** 깊을수록 보기 좋지만 중간 톤에서 글자가 묻히므로,
  전 구간 WCAG 대비(4.5:1)를 만족하는 가장 깊은 값을 자동으로 고릅니다 (당근 12%, 카카오 28%).
- **대비 검증은 셸의 실제 동작과 같은 규칙을 씁니다.** 셸은 배경 밝기가 임계값을 넘으면
  어두운 글자색, 아니면 밝은 글자색 — 한쪽만 씁니다. 검증이 "둘 중 나은 쪽"을 재면
  실제로 쓰이지 않는 색 덕분에 통과해버려, 검증은 녹색인데 화면은 안 읽히게 됩니다.
- **그래도 대비가 안 나오면 배경 명도를 미세 조정합니다.** 색상(hue)은 보존하므로 브랜드
  정체성은 유지되고, 조정된 회사는 빌드 로그에 남습니다. 현재 11개 중 SOCAR 하나뿐입니다
  (`#0078FF` → `#006EEB`).
- **브랜드 색이 순수 검정이면 들어올립니다.** 쿠팡·무신사는 `#000000`이라 터미널 배경과
  구분되지 않아 세그먼트가 통째로 사라집니다.
- **SVG는 resvg로 래스터화합니다.** macOS `qlmanage`는 썸네일 생성기라 알파를 버리고
  흰 배경 위에 평탄화합니다. 그 탓에 배경을 되짚어 추정해야 했고, 획이 네 모서리에 닿는
  로고(네이버 N)에서 추정이 뒤집혀 로고가 반전됐습니다.
- **sbix 테이블은 직접 직렬화합니다.** `write-fonts`의 sbix 타입은 원시 오프셋 배열을
  노출해 어차피 손으로 채워야 하는데, 포맷이 단순해 바이트를 직접 만드는 쪽이 명료합니다.
  기존 폰트에 글리프를 추가하려면 `cmap`·`loca`·`maxp`·`hmtx`·`post`도 함께 손봐야 합니다
  (`post`는 v2의 글리프 이름 배열을 늘리는 대신 이름 없는 v3.0으로 바꿉니다).

## 구조

```
brands.zsh, fonts/, iterm2/   생성물 — 커밋됨. 사용자는 이것만 있으면 됩니다
brands/*.yaml                 켜둔 회사 정의
catalog/brands.json           440개 회사 카탈로그 (언어 중립)
logos/                        로고 원본
tools/                        빌드 (메인테이너 전용, Rust)
  src/domain/                   모델·팔레트 계산 (외부 의존 없음)
  src/application/              유스케이스 조립
  src/infrastructure/           로고 수집·래스터화·폰트/설정 생성
```

도메인은 어떤 레이어에도 의존하지 않고, 어댑터가 포트를 구현합니다.

## 알려진 제약

- **배경 워터마크와 탭 아이콘은 넣지 않습니다.** 두 키가 로고 PNG의 절대경로를 요구하는데
  그 경로는 빌드한 머신에만 존재해, 산출물을 커밋해 배포하는 구조와 맞지 않습니다.
  로고는 프롬프트 글리프로 보여줍니다.
- **회사 폴더 안에서는 p10k의 경로 축약(`truncate_to_unique` 등)이 적용되지 않습니다.**
  프롬프트가 p10k의 축약 결과를 되받으면 색이 이중으로 입혀져 깨지기 때문에 `%~`로
  직접 만듭니다. 깊은 경로에서 프롬프트가 길어질 수 있습니다.
- **iTerm2의 GPU(Metal) 렌더러에서 로고가 단색이 될 수 있습니다.** iTerm2 소스상 컬러 폰트
  판별이 `Apple Color Emoji` 이름 비교로 되어 있어, 커스텀 sbix 폰트는 알파만 남는 경로를
  탈 수 있습니다. 단색으로 보이면 GPU 렌더링을 끄거나 리거처를 켜 레거시 경로를 쓰세요.
  (소스 기반 추론이며 실행 검증은 하지 않았습니다.)

## 라이선스

MIT. 브랜드 색 데이터는 [oh-my-design](https://github.com/kwakseongjae/oh-my-design)(MIT)에서
가져왔습니다. 로고는 각 회사의 상표입니다. `logos/*.png`는 커밋하지 않고 빌드 시 공개 출처
(Simple Icons·파비콘)에서 내려받지만, **생성된 폰트에는 로고 이미지가 글리프로 포함됩니다** —
sbix는 PNG를 그대로 담는 포맷이기 때문입니다.
