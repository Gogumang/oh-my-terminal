# oh-my-terminal

회사 브랜드 색과 로고를 터미널에 입힙니다. iTerm2에서 회사 프로필을 고르면 어느 폴더에서나
그 회사 테마가 나옵니다. 명령을 치는 동안에는 히스토리에서 찾은 나머지를 흐리게 제안합니다.

```
 [NOL 로고] ~/study ❯ git st​atus   ← NOL Brand 프로필: 브랜드 색 그라데이션 + 로고 + 흐린 자동 제안
 [NOL 로고] /tmp ❯
  ~/study ❯                       ← 다른 프로필: 원래 프롬프트 그대로 (자동 제안은 켜짐)
```

## 설치

전제 조건: **zsh + [powerlevel10k](https://github.com/romkatv/powerlevel10k) + iTerm2**.

[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)처럼 받아서 source 하면 끝인
zsh 플러그인입니다. 로고 폰트와 iTerm2 프로필은 플러그인이 셸을 열 때 설치하고, 업데이트로 파일이
바뀌면 다음 셸에서 다시 복사합니다. 생성물이 저장소에 커밋돼 있어 Rust·Python 같은 빌드 도구는
필요 없습니다 — Rust는 테마를 다시 만들 때([회사 추가](#회사-추가))만 씁니다.

- [Oh My Zsh](#oh-my-zsh)
- [zinit](#zinit)
- [Antigen](#antigen)
- [직접 받기 (git clone)](#직접-받기-git-clone)

`~/.zshrc` 안에서의 순서는 상관없습니다 — `~/.p10k.zsh`보다 먼저 불러와도 됩니다. 자동 제안이
들어 있으므로 **zsh-autosuggestions는 따로 쓰지 마세요** ([자동 제안](#자동-제안)).

### Oh My Zsh

1. `$ZSH_CUSTOM/plugins`(기본 `~/.oh-my-zsh/custom/plugins`)에 받습니다.

    ```sh
    git clone https://github.com/Gogumang/oh-my-terminal ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/oh-my-terminal
    ```

2. `~/.zshrc`의 플러그인 목록에 넣습니다.

    ```sh
    plugins=(
        # 다른 플러그인...
        oh-my-terminal
    )
    ```

3. 새 터미널을 엽니다.

### zinit

1. `~/.zshrc`에 넣습니다.

    ```sh
    zinit light Gogumang/oh-my-terminal
    ```

2. 새 터미널을 엽니다.

### Antigen

1. `~/.zshrc`에 넣습니다.

    ```sh
    antigen bundle Gogumang/oh-my-terminal
    ```

2. 새 터미널을 엽니다.

### 직접 받기 (git clone)

1. 원하는 곳에 받습니다. 여기서는 `~/.zsh/oh-my-terminal`로 가정합니다.

    ```sh
    git clone https://github.com/Gogumang/oh-my-terminal ~/.zsh/oh-my-terminal
    ```

2. `~/.zshrc`에 넣습니다.

    ```sh
    source ~/.zsh/oh-my-terminal/oh-my-terminal.zsh
    ```

3. 새 터미널을 엽니다.

받은 폴더에서 `./install.sh`를 실행하면 2번을 대신 해 주고 폰트·프로필도 바로 설치합니다. 예전
설치가 `~/.zshrc`에 넣은 `brands.zsh` 줄은 이 줄로 바꿉니다 (백업을 남깁니다).

### 업데이트

플러그인을 갱신한 뒤 새 창을 열면 됩니다 — 바뀐 폰트·프로필은 그 셸이 복사합니다.

| 설치 방법 | 갱신 |
|---|---|
| Oh My Zsh, 직접 받기 | `git -C <받은 폴더> pull` (`omz update`는 플러그인을 갱신하지 않습니다) |
| zinit | `zinit update Gogumang/oh-my-terminal` |
| Antigen | `antigen update` |

## 회사 고르기

설정은 iTerm2 프로필 하나입니다. 폴더를 만들거나 명령을 칠 필요가 없고, iTerm2를 재시작할
필요도 없습니다.

1. **iTerm2 → Settings → Profiles**에서 `<회사> Brand` 프로필(예: `NOL Brand`)을 고르고
   **Other Actions… → Set as Default**.
2. 새 창·탭부터 어느 폴더에서나 그 회사 테마가 나옵니다.

- 회사를 바꾸려면 기본 프로필만 다른 `<회사> Brand`로 바꾸면 됩니다.
- 한 창에서만 써 보려면 ⌘O로 그 프로필 창을 여세요.
- 브랜드 프로필이 아닌 창에서는 프롬프트를 전혀 건드리지 않습니다.
- 업데이트해도 열려 있는 iTerm2가 새 폰트를 바로 읽습니다. 이미 열린 창에서는 `exec zsh`로
  셸을 다시 띄우면 새 프롬프트 설정까지 반영됩니다.

## 자동 제안

명령을 치면 그 글자로 시작하는 가장 최근 히스토리 항목의 나머지가 커서 뒤에 흐리게 나옵니다.
[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) v0.7.1을 분석해 옮긴
기능이라 따로 설치할 것이 없고, 회사 프로필과 상관없이 모든 대화형 셸에서 켜집니다.

| 키 | 동작 |
|---|---|
| → / End | 커서가 줄 끝이면 제안 전체를 받아들입니다 |
| Alt+F (`forward-word`) | 다음 단어 앞까지만 받아들입니다 |
| Enter | 친 것만 실행합니다 — 제안은 붙지 않습니다 |

iTerm2에서 Alt 조합을 쓰려면 **Profiles → Keys → Left Option key**를 `Esc+`로 바꾸세요. 기본값에서는
Option+F가 특수 문자(ƒ)를 입력합니다.

### 설정

`~/.zshrc`에서 정합니다. 기본값은 비어 있을 때만 채우므로 불러오기 전후 어디에 적어도 됩니다.

| 변수 | 기본값 | 뜻 |
|---|---|---|
| `OH_MY_TERMINAL_SUGGEST` | `1` | `0`이면 자동 제안을 켜지 않습니다 (불러오기 전에 정할 것) |
| `OH_MY_TERMINAL_SUGGEST_STYLE` | `fg=8` | 제안 글자 모양. `region_highlight` 형식 (예: `fg=#8a8a8a,underline`) |
| `OH_MY_TERMINAL_SUGGEST_STRATEGY` | `(history)` | 제안 찾는 방법. 앞에서부터 시도합니다 — `history`, `match_prev_cmd`, `completion` |
| `OH_MY_TERMINAL_SUGGEST_ASYNC` | `1` | `0`이면 자식 프로세스 없이 입력 중에 바로 찾습니다 |
| `OH_MY_TERMINAL_SUGGEST_BUFFER_MAX_SIZE` | 없음 | 이보다 긴 버퍼는 찾지 않습니다 (긴 붙여넣기 대비로 20 정도) |
| `OH_MY_TERMINAL_SUGGEST_HISTORY_IGNORE` | 없음 | 제안하지 않을 히스토리 패턴 (예: `'cd *'`) |
| `OH_MY_TERMINAL_SUGGEST_COMPLETION_IGNORE` | 없음 | `completion` 전략을 쓰지 않을 버퍼 패턴 (예: `'git *'`) |
| `OH_MY_TERMINAL_SUGGEST_{CLEAR,ACCEPT,EXECUTE,PARTIAL_ACCEPT,IGNORE}_WIDGETS` | `autosuggest.zsh` 참고 | 위젯별 동작. 실행 중에 바꾸면 다음 줄부터 반영됩니다 |

전략:

- `history` — 친 글자로 시작하는 가장 최근 항목.
- `match_prev_cmd` — 같은 조건에서, 방금 실행한 명령 다음에 쳤던 항목을 먼저 고릅니다.
  `HIST_IGNORE_ALL_DUPS`처럼 히스토리 순서를 바꾸는 옵션과는 맞지 않습니다.
- `completion` — 탭 완성이 처음 내놓는 결과. `compinit`이 필요합니다.

`bindkey`로 쓸 수 있는 위젯: `omt-suggest-accept`, `omt-suggest-execute`(받아들이고 실행),
`omt-suggest-clear`, `omt-suggest-fetch`, `omt-suggest-enable`, `omt-suggest-disable`,
`omt-suggest-toggle`.

```sh
bindkey '^ ' omt-suggest-accept     # Ctrl+Space로 받아들이기
```

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
```

**기반 폰트는 p10k 권장 폰트인 MesloLGS NF입니다** (`p10k configure`가 설치하는
`~/Library/Fonts/MesloLGS NF Regular.ttf`). 브랜드 프로필은 이 폰트로 바뀌므로, p10k가 쓰는
Nerd Font 아이콘(git 브랜치 등)이 기반 폰트에 있어야 합니다. 다른 폰트를 쓰려면 Nerd Font
버전을 지정하세요:

```sh
OH_MY_TERMINAL_BASE_FONT=~/Library/Fonts/<Nerd Font>.ttf tools/target/release/build-themes
```

빌더는 Rust입니다. `cargo build --release` 하나면 되고 다른 의존성이 없습니다.

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

## 설계 노트

- **회사는 iTerm2 프로필로 고릅니다.** 배경·폰트는 프로필이, 프롬프트는 셸이 담당하는데
  설정을 따로 두면 둘이 어긋납니다 (카카오 프로필에 토스 프롬프트). 셸은 iTerm2가 세션마다
  넣어 주는 `ITERM_PROFILE`로 회사를 알아내므로, 사용자가 바꾸는 설정은 프로필 하나입니다.
- **폰트와 iTerm2 프로필은 설치 스크립트가 아니라 플러그인이 설치합니다.** 플러그인 관리자는
  저장소를 받아 source 할 뿐 설치 스크립트를 돌려 주지 않습니다. 진입점은 저장소 쪽 파일이
  설치본보다 새로울 때만 복사하므로, 평소 비용은 파일 시각 비교뿐이고 업데이트는 다음 셸에서
  저절로 따라옵니다.
- **p10k 설정은 source 시점이 아니라 첫 프롬프트 직전에 넣습니다.** 플러그인 관리자는 플러그인을
  `~/.p10k.zsh`보다 먼저 source 하는데, `.p10k.zsh`는 시작하자마자 `POWERLEVEL9K_*`를 전부 지워서
  브랜드 설정이 흔적 없이 사라졌습니다. p10k는 설정을 precmd 맨 끝에서 읽으므로, 그보다 앞에
  한 번 돌고 빠지는 precmd 훅에서 넣으면 `.zshrc` 어디서 불러오든 결과가 같습니다.
- **자동 제안은 zsh-autosuggestions를 분석해 옮겼습니다.** 제안은 커서 뒤 `POSTDISPLAY`에 붙이고
  `region_highlight`로 흐리게 칠합니다. 모든 zle 위젯을 지우기(Enter·↑)·받아들이기(→·End)·
  부분 받기(Alt+F)·다시 찾기(그 밖에 버퍼를 바꿀 수 있는 위젯)로 감싸고, 제안은 자식 프로세스에서
  찾아 `zle -F`로 받습니다. 원본의 테스트(rspec + tmux)를 zpty로 옮겨 같은 동작을 확인합니다.
- **위젯은 바뀌었을 때만 다시 감쌉니다.** 원본은 다른 플러그인이 나중에 감싼 위젯을 놓치지 않으려고
  프롬프트마다 `$(zle -la)`를 fork 해 위젯 수백 개를 다시 eval 합니다. 위젯 표와 위젯 목록 설정을
  한 문자열로 비교해 바뀐 프롬프트에서만 감싸도 결과가 같고, oh-my-zsh + p10k(위젯 630개)에서
  프롬프트당 비용이 5.8ms → 0.46ms가 됐습니다.
- **빠르게 친 글자가 옛 제안과 겹쳐도 히스토리에 없는 제안을 만들지 않습니다.** 원본은 입력이 밀린
  동안(붙여넣기·빠른 입력) 옛 제안을 되살려 두는데, 그 제안은 이미 버퍼와 어긋나 있어 뒤이은
  글자가 우연히 겹치면 `ls` 제안 ` bar` 뒤에 `x `를 한 번에 친 버퍼가 `lsx bar`로 보였습니다.
  버퍼와 맞는 경우에만 제안을 남깁니다.
- **completion 전략의 `stty`는 대상 tty를 stdin으로 넘깁니다.** 원본의 `stty -F /dev/tty`는 macOS
  stty에 없는 옵션이라(`illegal option`, `-f`만 있음) 실패했고, 줄바꿈이 든 버퍼는 제안이 나오지
  않았습니다.
- **completion 전략은 동기 모드에서도 자식 셸에서 찾습니다.** 원본의 동기 경로(pty 속 자식이 위젯을
  부름)를 옮기자 제안이 나오지 않았습니다. 명령 치환 속 자식에는 zle이 없어 비동기와 같은 길로
  찾을 수 있습니다.
- **p10k dir 클래스는 `BRAND` 하나입니다.** 세션마다 회사가 하나로 정해지니 279개 회사의
  p10k 변수를 미리 만들어 둘 필요가 없습니다. 고른 회사의 값만 셸 시작 때 채웁니다.
- **로고는 비트맵이 아니라 TrueType 외곽선 글리프입니다.** 처음에는 PNG 비트맵(sbix)으로
  넣었는데, iTerm2 GPU 렌더러는 레티나 배율을 텍스트 행렬로 주고 Core Text는 비트맵 글리프에
  그 배율을 적용하지 않아, 로고가 절반 크기로 줄 아래쪽에 붙어 그려졌습니다. Nerd Font 아이콘이
  멀쩡한 것도 외곽선이기 때문입니다. 빌더는 로고 실루엣의 경계를 따라 윤곽을 만들고(바깥은
  시계 방향, 파낸 구멍은 반시계 방향) 계단진 점을 단순화해 넣습니다.
- **폰트 이름에는 내용에서 만든 판 번호가 붙습니다** (`OhMyTerminalBrand-DD3A194E`). 실행 중인
  iTerm2는 한 번 읽은 폰트를 이름으로 붙들고 있어서, 같은 이름으로 파일만 바꿔 설치하자 이미
  지운 옛 폰트 파일을 계속 열고 로고 자리를 비워 뒀습니다. 이름이 바뀌면 프로필 갱신과 함께
  새 폰트를 바로 읽습니다. 내용이 같으면 판 번호도 같아 빌드는 결정적입니다.
- **로고는 비율에 따라 글자 2~4칸을 쓰고, 칸마다 글리프 하나로 잘라 넣습니다.** 예전에는
  모든 로고를 글자 한 칸짜리 정사각형에 넣어, 가로로 긴 워드마크(NOL·삼성)가 화면에서 10px
  남짓으로 줄어 거의 안 보였습니다. 한 글리프가 옆 칸까지 넘쳐 그리게 하면 터미널이 넘친 부분을
  몇 칸까지 그려 줄지에 기대야 해서, 칸 단위로 자릅니다.
- **조각마다 hmtx의 왼쪽 여백(lsb)에 외곽선의 실제 왼쪽 끝을 적습니다.** 렌더러는 외곽선을 옮겨
  xMin을 lsb에 맞춥니다. 전부 0을 적자 잉크가 칸 중간에서 시작하는 조각은 왼쪽으로 끌려와
  로고가 칸마다 어긋나 갈라졌습니다(`1|04`, `N|OL`). 조각은 옆 칸으로 조금씩 겹쳐 잘라 경계의
  흐린 세로줄도 막습니다.
- **로고 색은 띠 위에서 대비가 큰 흰색 또는 검정입니다.** iTerm2 GPU 렌더러는 글리프를 그 칸의
  글자색으로 칠합니다. 경로와 같은 글자색(대비 4.5:1)을 쓰자 어두운 띠 위 로고가 회색 얼룩으로만
  보였습니다.
- **로고 둘레는 띠 시작색 한 가지로 칠하고, 그라데이션은 경로 글자에만 입힙니다.** p10k가 넣는
  왼쪽 여백은 세그먼트 배경(가장 어두운 끝색)이라, 가장 밝은 시작색인 로고 칸과 경계가 져 로고
  둘레만 밝은 조각처럼 떠 보였습니다. 그래서 p10k의 왼쪽 여백은 비우고 여백을 직접 넣습니다.
- **가는 획은 필요한 만큼만 굵힙니다.** 획 두께를 화면 픽셀로 어림해 2px보다 가늘면 넓힙니다.
  모든 로고를 굵히면 글자 워드마크가 뭉개집니다.
- **로고 글리프는 보조 사용자 영역 B(U+100000~)에 둡니다.** 조각 수가 700개를 넘자 기본 사용자
  영역(U+E900~)에서 Nerd Font 아이콘 387개와 겹쳤습니다. zsh는 이 영역 글자도 한 칸으로 셉니다.
- **`public/logo`가 원본이고 `logos/`는 작업물입니다.** 빌드는 커밋된 로고를 매번 새로 가져옵니다.
  작업 폴더에 복사본이 있다고 그대로 쓰자, 교체한 로고 43개가 폰트에 하나도 반영되지 않았습니다.
- **다운로드는 OS 신뢰 인증서를 씁니다.** TLS를 검사하는 회사망 프록시는 자체 루트 인증서로 다시
  서명하는데, 내장 루트 목록만 믿으면 `UnknownIssuer`로 전부 실패했습니다.
- **기반 폰트는 Nerd Font여야 합니다.** D2Coding으로 만들었더니 한글 모양은 유지됐지만 git
  브랜치 아이콘 같은 p10k 아이콘이 전부 사라졌습니다. 한글은 없어도 시스템 폰트로 표시되지만,
  Nerd Font 아이콘은 대신 그려 줄 폰트가 없습니다.
- **ANSI 0~15은 브랜드 색으로 덮지 않습니다.** `red=에러`, `green=성공` 의미가 무너지면
  로그를 읽을 수 없습니다. 브랜드 색은 커서·탭·선택 영역에만 들어갑니다. 자동 제안의 흐린 글자
  (`fg=8`)도 그래서 검정 배경 위 회색으로 보입니다.
- **터미널 배경과 글자색은 회사·macOS 모드와 상관없이 검정·흰색으로 고정합니다.** 라이트/다크
  모드별로 따로 두자 라이트 모드에서 배경이 흰색이 되어, 브랜드 색 프롬프트가 흰 바탕에 떠
  보였습니다. 회사 이름 뱃지도 창 오른쪽 위에 워터마크처럼 찍혀 화면을 가려서 넣지 않습니다.
- **로고가 있으면 OS 아이콘 칸은 뺍니다.** 로고가 경로 세그먼트 맨 앞에 나오므로 같은 자리에
  아이콘이 둘일 필요가 없습니다.
- **그라데이션 깊이는 회사마다 다릅니다.** 깊을수록 보기 좋지만 중간 톤에서 글자가 묻히므로,
  전 구간 WCAG 대비(4.5:1)를 만족하는 가장 깊은 값을 자동으로 고릅니다 (당근 12%, 카카오 28%).
- **대비 검증은 셸의 실제 동작과 같은 규칙을 씁니다.** 셸은 배경 밝기가 임계값을 넘으면
  어두운 글자색, 아니면 밝은 글자색 — 한쪽만 씁니다. 검증이 "둘 중 나은 쪽"을 재면
  실제로 쓰이지 않는 색 덕분에 통과해버려, 검증은 녹색인데 화면은 안 읽히게 됩니다.
- **그래도 대비가 안 나오면 배경 명도를 미세 조정합니다.** 색상(hue)은 보존하므로 브랜드
  정체성은 유지되고, 조정된 회사는 빌드 로그에 남습니다. 현재 279개 중 46개가 조정됩니다
  (예: SOCAR `#0078FF` → `#006EEB`).
- **브랜드 색이 터미널 배경만큼 어두우면 들어올립니다.** 쿠팡·무신사는 `#000000`이라 터미널
  배경과 구분되지 않아 세그먼트가 통째로 사라집니다. 현재 35개가 해당합니다.
- **SVG는 resvg로 래스터화합니다.** macOS `qlmanage`는 썸네일 생성기라 알파를 버리고
  흰 배경 위에 평탄화합니다. 그 탓에 배경을 되짚어 추정해야 했고, 획이 네 모서리에 닿는
  로고(네이버 N)에서 추정이 뒤집혀 로고가 반전됐습니다.
- **폰트 테이블은 기반 폰트에 직접 덧붙입니다.** 글리프를 추가하려면 `cmap`·`glyf`·`loca`·`maxp`·
  `hmtx`·`post`를 함께 손봐야 합니다 (`post`는 v2의 글리프 이름 배열을 늘리는 대신 이름 없는
  v3.0으로 바꿉니다).

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

## 알려진 제약

- **열린 탭의 프로필을 바꾸면 프롬프트는 그대로입니다.** `ITERM_PROFILE`은 세션을 열 때
  정해지므로, 프로필을 바꾼 뒤에는 새 탭·창을 여세요.
- **`ITERM_PROFILE`이 전달되지 않는 셸에서는 테마가 나오지 않습니다.** 다른 터미널 앱이나
  ssh로 접속한 원격 셸이 그렇습니다. 자동 제안은 그런 셸에서도 켜집니다.
- **zsh-autosuggestions와 함께 쓰지 마세요.** zsh-autosuggestions가 먼저 불리면 oh-my-terminal의
  자동 제안은 켜지지 않습니다.
- **자동 제안은 zsh 5.4 이상에서만 켜집니다.** 입력이 밀려 있는지 알 수 있는 버전부터라, 그 전에는
  붙여넣는 글자마다 제안을 찾게 됩니다. macOS 기본 zsh는 5.9입니다.
- **플러그인을 지워도 설치된 폰트와 프로필은 남습니다.** `~/Library/Fonts/OhMyTerminalBrand.ttf`와
  `~/Library/Application Support/iTerm2/DynamicProfiles/brand-themes.json`을 직접 지우세요.
- **로고는 한 가지 색 실루엣입니다.** 원본의 여러 색은 쓰지 않습니다 — 컬러 비트맵 글리프는
  iTerm2 GPU 렌더러에서 크기와 위치가 틀어지므로 외곽선만 씁니다.
- **작게 봐도 알아볼 마크를 공식 출처에서 못 찾은 로고가 몇 개 있습니다.** 쿠팡(톱니 배지 속
  글자), beusable, gogoro, headspace, kakaogames, openpoint는 여전히 약합니다.
- **브랜드 프로필에서 한글은 시스템 폰트로 표시됩니다.** MesloLGS NF에 한글이 없어서이며,
  p10k 기본 설정(MesloLGS NF)을 쓸 때와 같습니다.
- **배경 워터마크와 탭 아이콘은 넣지 않습니다.** 두 키가 로고 PNG의 절대경로를 요구하는데
  그 경로는 빌드한 머신에만 존재해, 산출물을 커밋해 배포하는 구조와 맞지 않습니다.
  로고는 프롬프트 글리프로 보여줍니다.
- **브랜드 프로필에서는 p10k의 경로 축약(`truncate_to_unique` 등)이 적용되지 않습니다.**
  프롬프트가 p10k의 축약 결과를 되받으면 색이 이중으로 입혀져 깨지기 때문에 `%~`로
  직접 만듭니다. 깊은 경로에서 프롬프트가 길어질 수 있습니다.

## 라이선스

MIT. 브랜드 색 데이터는 [oh-my-design](https://github.com/kwakseongjae/oh-my-design)(MIT)에서
가져왔습니다. 로고는 각 회사의 상표이며 `public/logo/`에 커밋되어 있고, 생성된 폰트에는 그
모양을 따라 만든 외곽선이 글리프로 들어갑니다. 출처는 각 회사의 공개 자산(Simple Icons·App Store
아이콘·공식 파비콘 등)이며 `brands/*.yaml`에 기록돼 있습니다.

자동 제안(`autosuggest.zsh`)은 [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
(MIT, Copyright (c) 2013 Thiago de Arruda, Copyright (c) 2016-2021 Eric Freese)를 분석해 옮긴
코드입니다. 라이선스 전문은 `licenses/zsh-autosuggestions.txt`에 있습니다.
