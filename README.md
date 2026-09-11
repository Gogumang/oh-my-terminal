# oh-my-terminal

회사 브랜드 색과 로고를 iTerm2 터미널에 입히는 zsh 플러그인입니다. iTerm2에서 회사 프로필을
고르면 어느 폴더에서나 그 회사 테마가 나오고, 명령을 치는 동안에는 히스토리에서 찾은 나머지를
흐리게 제안합니다.

![Kakao Brand — git pu 뒤에 흐리게 붙은 ll이 자동 제안](docs/screenshots/kakao.png)
![Toss Brand](docs/screenshots/toss.png)
![NOL Brand](docs/screenshots/nol.png)

## 왜 만들었나

여러 회사의 프로젝트를 한 컴퓨터에서 오가다 보면 터미널 창이 전부 똑같이 생겨서, 지금 이 창이
어느 회사 작업인지 경로를 읽어야 압니다. 창마다 그 회사의 색과 로고가 보이면 한눈에 구분됩니다.

처음에는 폴더 경로(`~/Desktop/kakao`면 카카오)로 회사를 골랐습니다. 그런데 배경·폰트는 iTerm2
프로필이, 프롬프트는 zsh가 맡다 보니 설정이 둘로 나뉘어 서로 어긋났습니다(카카오 프로필에 토스
프롬프트). 그래서 지금은 **iTerm2 프로필 하나만 고르면** 배경부터 프롬프트까지 같은 회사로 맞춰지게
만들었습니다.

## 기능

### 회사 브랜드 프롬프트

- p10k 경로 세그먼트에 **브랜드 색 그라데이션**과 **회사 로고**를 넣습니다.
- 로고는 이미지가 아니라 폰트 글리프라 글자처럼 선명하게 그려지고, 가로로 긴 워드마크(NOL 등)는
  글자 2~4칸을 씁니다.
- 경로 글자가 어느 구간에서도 읽히도록 **WCAG 대비 4.5:1**을 자동으로 맞춥니다. 대비가 모자라면
  색상은 그대로 두고 명도만 조금 조정합니다.
- 브랜드 프로필이 아닌 창에서는 프롬프트를 전혀 건드리지 않습니다.

### iTerm2 브랜드 프로필

- 회사마다 `<회사> Brand` 프로필이 생깁니다. 커서·탭·선택 영역이 브랜드 색으로 바뀝니다.
- 배경은 macOS 라이트/다크 모드와 상관없이 검정, 글자는 흰색으로 고정해 브랜드 색이 떠 보이지
  않게 합니다.
- ANSI 16색은 바꾸지 않습니다 — 에러는 빨강, 성공은 초록 그대로 읽힙니다.

### 자동 제안

- 명령을 치면 그 글자로 시작하는 가장 최근 히스토리의 나머지가 커서 뒤에 흐리게 나옵니다.
  →(또는 End)로 전체를, Alt+F로 한 단어씩 받아들입니다.
- 회사 프로필과 상관없이 모든 대화형 셸에서 켜집니다.
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)를 분석해 옮겼고, 같은 조건에서
  프롬프트마다 드는 비용을 5.8ms → 0.46ms로 줄였습니다.

### 설치와 업데이트가 가벼움

- Oh My Zsh·zinit·Antigen으로 받거나 `git clone` 후 source 한 줄이면 됩니다.
- 로고 폰트와 iTerm2 프로필은 플러그인이 셸을 열 때 설치하고, 업데이트되면 다음 셸에서 알아서
  갱신합니다. iTerm2 재시작도 필요 없습니다.
- 생성물이 저장소에 커밋돼 있어 Rust·Python 같은 빌드 도구가 필요 없습니다.
- 셸 시작에 드는 시간은 테마 1.7ms, 자동 제안 2.2ms입니다.

## 지원 테마

**279개 회사**를 지원합니다. iTerm2 → Settings → Profiles에서 `<회사 이름> Brand`로 찾으면 됩니다
(예: `Kakao Brand`). 브랜드 색은 [oh-my-design](https://github.com/kwakseongjae/oh-my-design) 카탈로그
440개에서 가져왔고, 그중 공식 로고를 확보한 회사만 켜 두었습니다.

<details open>
<summary><b>🇰🇷 한국</b> — 111개</summary>

29CM · 3o3 · 42dot · 8percent · Ably · Asleep · Baemin · Banksalad · Barogo · Beusable · Bigin · Bithumb · Blind · Brandi · Buzzvil · CGV · Channel Talk · CJ ONSTYLE · Classting · Codeit · Coinone · Coupang · Dr.diary · Dr.Now (닥터나우) · Fastcampus · Fitpet · Frip · Gaudio Lab · Genie Music · goorm · Greencar · Hackle · Hana Bank · Humanscape · Hwahae · Hyundai · idus (Backpackr) · IGAWorks · IICOMBINED · Inflearn · JANDI · Kakao · Kakao T · KakaoBank · Karrot · Kia · Korea Credit Data · KREAM · Kurly · Kyobo Book Centre · Lablup · LaundryGo · Lemonbase · Lezhin Comics · LikeLion · Lunit · maum.ai (ex-MindsLab) · Melon · Milddang (I Hate Flying Bugs) · Modusign · Moin · Moreh · Musinsa · MUSTIT · MyRealTrip · Naver · Naver Webtoon · NCSOFT · Nexon · NHN · NOL · Nota AI · Olive Young · Payhere · PeopleFund · PortOne · POSTYPE · POZAlabs · Quotabook · Rebellions · Remember · Return Zero · Samsung · Sandoll · Saramin · Scatter Lab · Shift Up · Shinhan Bank · Sinsang Market (Dealicious) · SIONIC AI · SK텔레콤 · SOCAR · Soomgo · SqueezeBits · TMAP Mobility · Toss · Toss Bank · Toss Securities · Tumblbug · TVING · Upstage · VUNO · W Concept · Wanted · Watcha · Wisetracker · Woori Bank · Yogiyo · ZEPETO · 강남언니 · 카카오게임즈

</details>

<details>
<summary><b>🇺🇸 미국</b> — 91개</summary>

Adobe · Airbnb · Airtable · Apple · Asana · Cal.com · Claude (Anthropic) · ClickHouse · Cloudflare · Coinbase · Composio · Cursor · Databricks · Dell · Discord · DoorDash · Dropbox · Duolingo · Elastic UI · ElevenLabs · Expo · Figma · Framer · GitHub · GitLab · Google · Hashicorp · Headspace · HP · HubSpot · IBM · Instacart · Intercom · Kraken · Linear · Loom · Mailchimp · Mastercard · Mercury · Meta · MiniMax · Mintlify · Miro · MongoDB · Netflix · Nike · Notion · NVIDIA · Ollama · OpenAI · OpenCode AI · PatternFly · PayPal · Pega UX Design System · Perplexity · Pinterest · PostHog · Raycast · Reddit · Replicate · Resend · Retool · Robinhood · RunwayML · Sanity · Sentry · ServiceNow Horizon · Slack · Snapchat · SpaceX · Spotify · Squarespace · Starbucks · Stripe · Supabase · Superhuman · Tesla · The Verge · Together AI · Twilio · Twitch · U.S. Web Design System · Uber · Vercel · VoltAgent · Warp · Webflow · Workday · xAI · Zapier · Zoom

</details>

<details>
<summary><b>🇯🇵 일본</b> — 29개</summary>

ABEMA · Cookpad · Cybozu · DMM.com (Turtle) · freee · Gaudiy · GMO Pepabo (Inhouse) · LayerX · LINE · MIXI · Money Forward · MUJI · Nintendo · note · pixiv · Rakuten · Sansan · SPEEDA (Uzabase) · Spindle (CyberAgent Ameba) · STORES · Studio · Ubie · Uniqlo · Wantedly · ZOZOTOWN · さくらインターネット · ソニー · マイナビ · リクルート

</details>

<details>
<summary><b>🇹🇼 대만</b> — 30개</summary>

104人力銀行 · 17LIVE · 91APP · AmazingTalker · Appier · Bahamut · Cake · Dcard · E.SUN Bank · EasyWallet · Fubon · Fugle · FunNow · Gogoro · Greenvines · Hahow · iPASS MONEY · Kdan Mobile · momo購物網 · MOZE · OPENPOINT · Pinkoi · Readmoo · Richart · SHOPLINE · SurveyCake · Vocus · Yourator · 中華航空 · 宏碁

</details>

<details>
<summary><b>🌍 그 밖의 나라</b> — 18개</summary>

BBC (영국) · Bilibili (중국) · BMW (독일) · Deliveroo (영국) · DJI (중국) · Farfetch (영국) · Ferrari (이탈리아) · GOV.UK (영국) · Lamborghini (이탈리아) · Mistral AI (프랑스) · Monzo (영국) · Renault (프랑스) · Revolut (영국) · Skyscanner (영국) · Starling Bank (영국) · Trainline (영국) · Wise (영국) · Xiaohongshu (중국)

</details>

목록에 없는 회사를 추가하는 방법은 [개발 문서](docs/development.md#회사-추가)에 있습니다.

## 설치

필요한 것: **macOS + iTerm2 + zsh + [powerlevel10k](https://github.com/romkatv/powerlevel10k)**

```sh
git clone https://github.com/Gogumang/oh-my-terminal ~/.zsh/oh-my-terminal
~/.zsh/oh-my-terminal/install.sh
```

1. 새 iTerm2 창을 엽니다.
2. **Settings → Profiles**에서 `<회사> Brand`를 고르고 **Other Actions… → Set as Default**를 누릅니다.
   한 번만 써 보려면 ⌘O로 그 프로필 창을 여세요.

> [!IMPORTANT]
> zsh-autosuggestions를 쓰고 있다면 `~/.zshrc`에서 빼 주세요. 함께 불리면 내장 자동 제안이
> 켜지지 않습니다.

Oh My Zsh·zinit·Antigen으로 설치하는 방법, 자동 제안 설정, 알려진 제약은
[사용 안내](docs/guide.md)에 있습니다.

## 문서

| 문서 | 내용 |
|---|---|
| [사용 안내](docs/guide.md) | 설치 방법별 절차, 업데이트·제거, 자동 제안 설정, 알려진 제약 |
| [개발](docs/development.md) | 회사 추가, 로고 교체, 테스트, 프로젝트 구조, 성능 실측치 |
| [설계 노트](docs/design-notes.md) | 구현하며 부딪힌 문제와 그래서 정한 방식 |

## 라이선스

MIT. 브랜드 색 데이터는 [oh-my-design](https://github.com/kwakseongjae/oh-my-design)(MIT)에서
가져왔습니다. 로고는 각 회사의 상표이며 `public/logo/`에 커밋되어 있고, 생성된 폰트에는 그
모양을 따라 만든 외곽선이 글리프로 들어갑니다. 출처는 각 회사의 공개 자산(Simple Icons·App Store
아이콘·공식 파비콘 등)이며 `brands/*.yaml`에 기록돼 있습니다.

자동 제안(`autosuggest.zsh`)은 [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
(MIT, Copyright (c) 2013 Thiago de Arruda, Copyright (c) 2016-2021 Eric Freese)를 분석해 옮긴
코드입니다. 라이선스 전문은 `licenses/zsh-autosuggestions.txt`에 있습니다.
