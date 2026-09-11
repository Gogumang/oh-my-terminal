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

그림은 각 회사 프로필에서 `~/workspace` 폴더에 있을 때의 프롬프트입니다. iTerm2 → Settings → Profiles에서
`<회사 이름> Brand`로 찾으면 됩니다 (예: `Kakao Brand`). 브랜드 색은
[oh-my-design](https://github.com/kwakseongjae/oh-my-design) 카탈로그 440개에서 가져왔고, 그중 공식 로고를
확보한 회사만 켜 두었습니다.

<!-- themes:start — build-themes gallery가 만든다. 직접 고치지 말 것 -->
**279개 회사**를 지원합니다.

<details open>
<summary><b>🇰🇷 한국</b> — 111개</summary>

<table>
<tr>
<td><img src="docs/themes/29cm.png" height="35" alt="29CM 테마"><br>29CM</td>
<td><img src="docs/themes/3o3.png" height="35" alt="3o3 테마"><br>3o3</td>
<td><img src="docs/themes/42dot.png" height="35" alt="42dot 테마"><br>42dot</td>
</tr>
<tr>
<td><img src="docs/themes/8percent.png" height="35" alt="8percent 테마"><br>8percent</td>
<td><img src="docs/themes/ably.png" height="35" alt="Ably 테마"><br>Ably</td>
<td><img src="docs/themes/asleep.png" height="35" alt="Asleep 테마"><br>Asleep</td>
</tr>
<tr>
<td><img src="docs/themes/baemin.png" height="35" alt="Baemin 테마"><br>Baemin</td>
<td><img src="docs/themes/banksalad.png" height="35" alt="Banksalad 테마"><br>Banksalad</td>
<td><img src="docs/themes/barogo.png" height="35" alt="Barogo 테마"><br>Barogo</td>
</tr>
<tr>
<td><img src="docs/themes/beusable.png" height="35" alt="Beusable 테마"><br>Beusable</td>
<td><img src="docs/themes/bigin.png" height="35" alt="Bigin 테마"><br>Bigin</td>
<td><img src="docs/themes/bithumb.png" height="35" alt="Bithumb 테마"><br>Bithumb</td>
</tr>
<tr>
<td><img src="docs/themes/teamblind.png" height="35" alt="Blind 테마"><br>Blind</td>
<td><img src="docs/themes/brandi.png" height="35" alt="Brandi 테마"><br>Brandi</td>
<td><img src="docs/themes/buzzvil.png" height="35" alt="Buzzvil 테마"><br>Buzzvil</td>
</tr>
<tr>
<td><img src="docs/themes/cgv.png" height="35" alt="CGV 테마"><br>CGV</td>
<td><img src="docs/themes/channeltalk.png" height="35" alt="Channel Talk 테마"><br>Channel Talk</td>
<td><img src="docs/themes/cjonstyle.png" height="35" alt="CJ ONSTYLE 테마"><br>CJ ONSTYLE</td>
</tr>
<tr>
<td><img src="docs/themes/classting.png" height="35" alt="Classting 테마"><br>Classting</td>
<td><img src="docs/themes/codeit.png" height="35" alt="Codeit 테마"><br>Codeit</td>
<td><img src="docs/themes/coinone.png" height="35" alt="Coinone 테마"><br>Coinone</td>
</tr>
<tr>
<td><img src="docs/themes/coupang.png" height="35" alt="Coupang 테마"><br>Coupang</td>
<td><img src="docs/themes/drdiary.png" height="35" alt="Dr.diary 테마"><br>Dr.diary</td>
<td><img src="docs/themes/drnow.png" height="35" alt="Dr.Now (닥터나우) 테마"><br>Dr.Now (닥터나우)</td>
</tr>
<tr>
<td><img src="docs/themes/fastcampus.png" height="35" alt="Fastcampus 테마"><br>Fastcampus</td>
<td><img src="docs/themes/fitpet.png" height="35" alt="Fitpet 테마"><br>Fitpet</td>
<td><img src="docs/themes/frip.png" height="35" alt="Frip 테마"><br>Frip</td>
</tr>
<tr>
<td><img src="docs/themes/gaudiolab.png" height="35" alt="Gaudio Lab 테마"><br>Gaudio Lab</td>
<td><img src="docs/themes/genie.png" height="35" alt="Genie Music 테마"><br>Genie Music</td>
<td><img src="docs/themes/goorm.png" height="35" alt="goorm 테마"><br>goorm</td>
</tr>
<tr>
<td><img src="docs/themes/greencar.png" height="35" alt="Greencar 테마"><br>Greencar</td>
<td><img src="docs/themes/hackle.png" height="35" alt="Hackle 테마"><br>Hackle</td>
<td><img src="docs/themes/hana.png" height="35" alt="Hana Bank 테마"><br>Hana Bank</td>
</tr>
<tr>
<td><img src="docs/themes/humanscape.png" height="35" alt="Humanscape 테마"><br>Humanscape</td>
<td><img src="docs/themes/hwahae.png" height="35" alt="Hwahae 테마"><br>Hwahae</td>
<td><img src="docs/themes/hyundai.png" height="35" alt="Hyundai 테마"><br>Hyundai</td>
</tr>
<tr>
<td><img src="docs/themes/idus.png" height="35" alt="idus (Backpackr) 테마"><br>idus (Backpackr)</td>
<td><img src="docs/themes/igaworks.png" height="35" alt="IGAWorks 테마"><br>IGAWorks</td>
<td><img src="docs/themes/iicombined.png" height="35" alt="IICOMBINED 테마"><br>IICOMBINED</td>
</tr>
<tr>
<td><img src="docs/themes/inflearn.png" height="35" alt="Inflearn 테마"><br>Inflearn</td>
<td><img src="docs/themes/jandi.png" height="35" alt="JANDI 테마"><br>JANDI</td>
<td><img src="docs/themes/kakao.png" height="35" alt="Kakao 테마"><br>Kakao</td>
</tr>
<tr>
<td><img src="docs/themes/kakaot.png" height="35" alt="Kakao T 테마"><br>Kakao T</td>
<td><img src="docs/themes/kakaobank.png" height="35" alt="KakaoBank 테마"><br>KakaoBank</td>
<td><img src="docs/themes/karrot.png" height="35" alt="Karrot 테마"><br>Karrot</td>
</tr>
<tr>
<td><img src="docs/themes/kia.png" height="35" alt="Kia 테마"><br>Kia</td>
<td><img src="docs/themes/kcd.png" height="35" alt="Korea Credit Data 테마"><br>Korea Credit Data</td>
<td><img src="docs/themes/kream.png" height="35" alt="KREAM 테마"><br>KREAM</td>
</tr>
<tr>
<td><img src="docs/themes/kurly.png" height="35" alt="Kurly 테마"><br>Kurly</td>
<td><img src="docs/themes/kyobobook.png" height="35" alt="Kyobo Book Centre 테마"><br>Kyobo Book Centre</td>
<td><img src="docs/themes/lablup.png" height="35" alt="Lablup 테마"><br>Lablup</td>
</tr>
<tr>
<td><img src="docs/themes/laundrygo.png" height="35" alt="LaundryGo 테마"><br>LaundryGo</td>
<td><img src="docs/themes/lemonbase.png" height="35" alt="Lemonbase 테마"><br>Lemonbase</td>
<td><img src="docs/themes/lezhin.png" height="35" alt="Lezhin Comics 테마"><br>Lezhin Comics</td>
</tr>
<tr>
<td><img src="docs/themes/likelion.png" height="35" alt="LikeLion 테마"><br>LikeLion</td>
<td><img src="docs/themes/lunit.png" height="35" alt="Lunit 테마"><br>Lunit</td>
<td><img src="docs/themes/maum-ai.png" height="35" alt="maum.ai (ex-MindsLab) 테마"><br>maum.ai (ex-MindsLab)</td>
</tr>
<tr>
<td><img src="docs/themes/melon.png" height="35" alt="Melon 테마"><br>Melon</td>
<td><img src="docs/themes/mildang.png" height="35" alt="Milddang (I Hate Flying Bugs) 테마"><br>Milddang (I Hate Flying Bugs)</td>
<td><img src="docs/themes/modusign.png" height="35" alt="Modusign 테마"><br>Modusign</td>
</tr>
<tr>
<td><img src="docs/themes/moin.png" height="35" alt="Moin 테마"><br>Moin</td>
<td><img src="docs/themes/moreh.png" height="35" alt="Moreh 테마"><br>Moreh</td>
<td><img src="docs/themes/musinsa.png" height="35" alt="Musinsa 테마"><br>Musinsa</td>
</tr>
<tr>
<td><img src="docs/themes/mustit.png" height="35" alt="MUSTIT 테마"><br>MUSTIT</td>
<td><img src="docs/themes/myrealtrip.png" height="35" alt="MyRealTrip 테마"><br>MyRealTrip</td>
<td><img src="docs/themes/naver.png" height="35" alt="Naver 테마"><br>Naver</td>
</tr>
<tr>
<td><img src="docs/themes/naverwebtoon.png" height="35" alt="Naver Webtoon 테마"><br>Naver Webtoon</td>
<td><img src="docs/themes/ncsoft.png" height="35" alt="NCSOFT 테마"><br>NCSOFT</td>
<td><img src="docs/themes/nexon.png" height="35" alt="Nexon 테마"><br>Nexon</td>
</tr>
<tr>
<td><img src="docs/themes/nhn.png" height="35" alt="NHN 테마"><br>NHN</td>
<td><img src="docs/themes/nol.png" height="35" alt="NOL 테마"><br>NOL</td>
<td><img src="docs/themes/nota.png" height="35" alt="Nota AI 테마"><br>Nota AI</td>
</tr>
<tr>
<td><img src="docs/themes/oliveyoung.png" height="35" alt="Olive Young 테마"><br>Olive Young</td>
<td><img src="docs/themes/payhere.png" height="35" alt="Payhere 테마"><br>Payhere</td>
<td><img src="docs/themes/peoplefund.png" height="35" alt="PeopleFund 테마"><br>PeopleFund</td>
</tr>
<tr>
<td><img src="docs/themes/portone.png" height="35" alt="PortOne 테마"><br>PortOne</td>
<td><img src="docs/themes/postype.png" height="35" alt="POSTYPE 테마"><br>POSTYPE</td>
<td><img src="docs/themes/pozalabs.png" height="35" alt="POZAlabs 테마"><br>POZAlabs</td>
</tr>
<tr>
<td><img src="docs/themes/quotabook.png" height="35" alt="Quotabook 테마"><br>Quotabook</td>
<td><img src="docs/themes/rebellions.png" height="35" alt="Rebellions 테마"><br>Rebellions</td>
<td><img src="docs/themes/remember.png" height="35" alt="Remember 테마"><br>Remember</td>
</tr>
<tr>
<td><img src="docs/themes/returnzero.png" height="35" alt="Return Zero 테마"><br>Return Zero</td>
<td><img src="docs/themes/samsung.png" height="35" alt="Samsung 테마"><br>Samsung</td>
<td><img src="docs/themes/sandoll.png" height="35" alt="Sandoll 테마"><br>Sandoll</td>
</tr>
<tr>
<td><img src="docs/themes/saramin.png" height="35" alt="Saramin 테마"><br>Saramin</td>
<td><img src="docs/themes/scatterlab.png" height="35" alt="Scatter Lab 테마"><br>Scatter Lab</td>
<td><img src="docs/themes/shiftup.png" height="35" alt="Shift Up 테마"><br>Shift Up</td>
</tr>
<tr>
<td><img src="docs/themes/shinhanbank.png" height="35" alt="Shinhan Bank 테마"><br>Shinhan Bank</td>
<td><img src="docs/themes/dealicious.png" height="35" alt="Sinsang Market (Dealicious) 테마"><br>Sinsang Market (Dealicious)</td>
<td><img src="docs/themes/sionic.png" height="35" alt="SIONIC AI 테마"><br>SIONIC AI</td>
</tr>
<tr>
<td><img src="docs/themes/sktelecom.png" height="35" alt="SK텔레콤 테마"><br>SK텔레콤</td>
<td><img src="docs/themes/socar.png" height="35" alt="SOCAR 테마"><br>SOCAR</td>
<td><img src="docs/themes/soomgo.png" height="35" alt="Soomgo 테마"><br>Soomgo</td>
</tr>
<tr>
<td><img src="docs/themes/squeezebits.png" height="35" alt="SqueezeBits 테마"><br>SqueezeBits</td>
<td><img src="docs/themes/tmap.png" height="35" alt="TMAP Mobility 테마"><br>TMAP Mobility</td>
<td><img src="docs/themes/toss.png" height="35" alt="Toss 테마"><br>Toss</td>
</tr>
<tr>
<td><img src="docs/themes/tossbank.png" height="35" alt="Toss Bank 테마"><br>Toss Bank</td>
<td><img src="docs/themes/toss-securities.png" height="35" alt="Toss Securities 테마"><br>Toss Securities</td>
<td><img src="docs/themes/tumblbug.png" height="35" alt="Tumblbug 테마"><br>Tumblbug</td>
</tr>
<tr>
<td><img src="docs/themes/tving.png" height="35" alt="TVING 테마"><br>TVING</td>
<td><img src="docs/themes/upstage.png" height="35" alt="Upstage 테마"><br>Upstage</td>
<td><img src="docs/themes/vuno.png" height="35" alt="VUNO 테마"><br>VUNO</td>
</tr>
<tr>
<td><img src="docs/themes/wconcept.png" height="35" alt="W Concept 테마"><br>W Concept</td>
<td><img src="docs/themes/wanted.png" height="35" alt="Wanted 테마"><br>Wanted</td>
<td><img src="docs/themes/watcha.png" height="35" alt="Watcha 테마"><br>Watcha</td>
</tr>
<tr>
<td><img src="docs/themes/wisetracker.png" height="35" alt="Wisetracker 테마"><br>Wisetracker</td>
<td><img src="docs/themes/wooribank.png" height="35" alt="Woori Bank 테마"><br>Woori Bank</td>
<td><img src="docs/themes/yogiyo.png" height="35" alt="Yogiyo 테마"><br>Yogiyo</td>
</tr>
<tr>
<td><img src="docs/themes/zepeto.png" height="35" alt="ZEPETO 테마"><br>ZEPETO</td>
<td><img src="docs/themes/gangnamunni.png" height="35" alt="강남언니 테마"><br>강남언니</td>
<td><img src="docs/themes/kakaogames.png" height="35" alt="카카오게임즈 테마"><br>카카오게임즈</td>
</tr>
</table>

</details>

<details>
<summary><b>🇺🇸 미국</b> — 91개</summary>

<table>
<tr>
<td><img src="docs/themes/adobe.png" height="35" alt="Adobe 테마"><br>Adobe</td>
<td><img src="docs/themes/airbnb.png" height="35" alt="Airbnb 테마"><br>Airbnb</td>
<td><img src="docs/themes/airtable.png" height="35" alt="Airtable 테마"><br>Airtable</td>
</tr>
<tr>
<td><img src="docs/themes/apple.png" height="35" alt="Apple 테마"><br>Apple</td>
<td><img src="docs/themes/asana.png" height="35" alt="Asana 테마"><br>Asana</td>
<td><img src="docs/themes/cal.png" height="35" alt="Cal.com 테마"><br>Cal.com</td>
</tr>
<tr>
<td><img src="docs/themes/claude.png" height="35" alt="Claude (Anthropic) 테마"><br>Claude (Anthropic)</td>
<td><img src="docs/themes/clickhouse.png" height="35" alt="ClickHouse 테마"><br>ClickHouse</td>
<td><img src="docs/themes/cloudflare.png" height="35" alt="Cloudflare 테마"><br>Cloudflare</td>
</tr>
<tr>
<td><img src="docs/themes/coinbase.png" height="35" alt="Coinbase 테마"><br>Coinbase</td>
<td><img src="docs/themes/composio.png" height="35" alt="Composio 테마"><br>Composio</td>
<td><img src="docs/themes/cursor.png" height="35" alt="Cursor 테마"><br>Cursor</td>
</tr>
<tr>
<td><img src="docs/themes/databricks.png" height="35" alt="Databricks 테마"><br>Databricks</td>
<td><img src="docs/themes/dell.png" height="35" alt="Dell 테마"><br>Dell</td>
<td><img src="docs/themes/discord.png" height="35" alt="Discord 테마"><br>Discord</td>
</tr>
<tr>
<td><img src="docs/themes/doordash.png" height="35" alt="DoorDash 테마"><br>DoorDash</td>
<td><img src="docs/themes/dropbox.png" height="35" alt="Dropbox 테마"><br>Dropbox</td>
<td><img src="docs/themes/duolingo.png" height="35" alt="Duolingo 테마"><br>Duolingo</td>
</tr>
<tr>
<td><img src="docs/themes/elastic.png" height="35" alt="Elastic UI 테마"><br>Elastic UI</td>
<td><img src="docs/themes/elevenlabs.png" height="35" alt="ElevenLabs 테마"><br>ElevenLabs</td>
<td><img src="docs/themes/expo.png" height="35" alt="Expo 테마"><br>Expo</td>
</tr>
<tr>
<td><img src="docs/themes/figma.png" height="35" alt="Figma 테마"><br>Figma</td>
<td><img src="docs/themes/framer.png" height="35" alt="Framer 테마"><br>Framer</td>
<td><img src="docs/themes/github.png" height="35" alt="GitHub 테마"><br>GitHub</td>
</tr>
<tr>
<td><img src="docs/themes/gitlab.png" height="35" alt="GitLab 테마"><br>GitLab</td>
<td><img src="docs/themes/google.png" height="35" alt="Google 테마"><br>Google</td>
<td><img src="docs/themes/hashicorp.png" height="35" alt="Hashicorp 테마"><br>Hashicorp</td>
</tr>
<tr>
<td><img src="docs/themes/headspace.png" height="35" alt="Headspace 테마"><br>Headspace</td>
<td><img src="docs/themes/hp.png" height="35" alt="HP 테마"><br>HP</td>
<td><img src="docs/themes/hubspot.png" height="35" alt="HubSpot 테마"><br>HubSpot</td>
</tr>
<tr>
<td><img src="docs/themes/ibm.png" height="35" alt="IBM 테마"><br>IBM</td>
<td><img src="docs/themes/instacart.png" height="35" alt="Instacart 테마"><br>Instacart</td>
<td><img src="docs/themes/intercom.png" height="35" alt="Intercom 테마"><br>Intercom</td>
</tr>
<tr>
<td><img src="docs/themes/kraken.png" height="35" alt="Kraken 테마"><br>Kraken</td>
<td><img src="docs/themes/linear.app.png" height="35" alt="Linear 테마"><br>Linear</td>
<td><img src="docs/themes/loom.png" height="35" alt="Loom 테마"><br>Loom</td>
</tr>
<tr>
<td><img src="docs/themes/mailchimp.png" height="35" alt="Mailchimp 테마"><br>Mailchimp</td>
<td><img src="docs/themes/mastercard.png" height="35" alt="Mastercard 테마"><br>Mastercard</td>
<td><img src="docs/themes/mercury.png" height="35" alt="Mercury 테마"><br>Mercury</td>
</tr>
<tr>
<td><img src="docs/themes/meta.png" height="35" alt="Meta 테마"><br>Meta</td>
<td><img src="docs/themes/minimax.png" height="35" alt="MiniMax 테마"><br>MiniMax</td>
<td><img src="docs/themes/mintlify.png" height="35" alt="Mintlify 테마"><br>Mintlify</td>
</tr>
<tr>
<td><img src="docs/themes/miro.png" height="35" alt="Miro 테마"><br>Miro</td>
<td><img src="docs/themes/mongodb.png" height="35" alt="MongoDB 테마"><br>MongoDB</td>
<td><img src="docs/themes/netflix.png" height="35" alt="Netflix 테마"><br>Netflix</td>
</tr>
<tr>
<td><img src="docs/themes/nike.png" height="35" alt="Nike 테마"><br>Nike</td>
<td><img src="docs/themes/notion.png" height="35" alt="Notion 테마"><br>Notion</td>
<td><img src="docs/themes/nvidia.png" height="35" alt="NVIDIA 테마"><br>NVIDIA</td>
</tr>
<tr>
<td><img src="docs/themes/ollama.png" height="35" alt="Ollama 테마"><br>Ollama</td>
<td><img src="docs/themes/openai.png" height="35" alt="OpenAI 테마"><br>OpenAI</td>
<td><img src="docs/themes/opencode.ai.png" height="35" alt="OpenCode AI 테마"><br>OpenCode AI</td>
</tr>
<tr>
<td><img src="docs/themes/patternfly.png" height="35" alt="PatternFly 테마"><br>PatternFly</td>
<td><img src="docs/themes/paypal.png" height="35" alt="PayPal 테마"><br>PayPal</td>
<td><img src="docs/themes/pega.png" height="35" alt="Pega UX Design System 테마"><br>Pega UX Design System</td>
</tr>
<tr>
<td><img src="docs/themes/perplexity.png" height="35" alt="Perplexity 테마"><br>Perplexity</td>
<td><img src="docs/themes/pinterest.png" height="35" alt="Pinterest 테마"><br>Pinterest</td>
<td><img src="docs/themes/posthog.png" height="35" alt="PostHog 테마"><br>PostHog</td>
</tr>
<tr>
<td><img src="docs/themes/raycast.png" height="35" alt="Raycast 테마"><br>Raycast</td>
<td><img src="docs/themes/reddit.png" height="35" alt="Reddit 테마"><br>Reddit</td>
<td><img src="docs/themes/replicate.png" height="35" alt="Replicate 테마"><br>Replicate</td>
</tr>
<tr>
<td><img src="docs/themes/resend.png" height="35" alt="Resend 테마"><br>Resend</td>
<td><img src="docs/themes/retool.png" height="35" alt="Retool 테마"><br>Retool</td>
<td><img src="docs/themes/robinhood.png" height="35" alt="Robinhood 테마"><br>Robinhood</td>
</tr>
<tr>
<td><img src="docs/themes/runwayml.png" height="35" alt="RunwayML 테마"><br>RunwayML</td>
<td><img src="docs/themes/sanity.png" height="35" alt="Sanity 테마"><br>Sanity</td>
<td><img src="docs/themes/sentry.png" height="35" alt="Sentry 테마"><br>Sentry</td>
</tr>
<tr>
<td><img src="docs/themes/servicenow.png" height="35" alt="ServiceNow Horizon 테마"><br>ServiceNow Horizon</td>
<td><img src="docs/themes/slack.png" height="35" alt="Slack 테마"><br>Slack</td>
<td><img src="docs/themes/snapchat.png" height="35" alt="Snapchat 테마"><br>Snapchat</td>
</tr>
<tr>
<td><img src="docs/themes/spacex.png" height="35" alt="SpaceX 테마"><br>SpaceX</td>
<td><img src="docs/themes/spotify.png" height="35" alt="Spotify 테마"><br>Spotify</td>
<td><img src="docs/themes/squarespace.png" height="35" alt="Squarespace 테마"><br>Squarespace</td>
</tr>
<tr>
<td><img src="docs/themes/starbucks.png" height="35" alt="Starbucks 테마"><br>Starbucks</td>
<td><img src="docs/themes/stripe.png" height="35" alt="Stripe 테마"><br>Stripe</td>
<td><img src="docs/themes/supabase.png" height="35" alt="Supabase 테마"><br>Supabase</td>
</tr>
<tr>
<td><img src="docs/themes/superhuman.png" height="35" alt="Superhuman 테마"><br>Superhuman</td>
<td><img src="docs/themes/tesla.png" height="35" alt="Tesla 테마"><br>Tesla</td>
<td><img src="docs/themes/theverge.png" height="35" alt="The Verge 테마"><br>The Verge</td>
</tr>
<tr>
<td><img src="docs/themes/together.ai.png" height="35" alt="Together AI 테마"><br>Together AI</td>
<td><img src="docs/themes/twilio.png" height="35" alt="Twilio 테마"><br>Twilio</td>
<td><img src="docs/themes/twitch.png" height="35" alt="Twitch 테마"><br>Twitch</td>
</tr>
<tr>
<td><img src="docs/themes/uswds.png" height="35" alt="U.S. Web Design System 테마"><br>U.S. Web Design System</td>
<td><img src="docs/themes/uber.png" height="35" alt="Uber 테마"><br>Uber</td>
<td><img src="docs/themes/vercel.png" height="35" alt="Vercel 테마"><br>Vercel</td>
</tr>
<tr>
<td><img src="docs/themes/voltagent.png" height="35" alt="VoltAgent 테마"><br>VoltAgent</td>
<td><img src="docs/themes/warp.png" height="35" alt="Warp 테마"><br>Warp</td>
<td><img src="docs/themes/webflow.png" height="35" alt="Webflow 테마"><br>Webflow</td>
</tr>
<tr>
<td><img src="docs/themes/workday.png" height="35" alt="Workday 테마"><br>Workday</td>
<td><img src="docs/themes/x.ai.png" height="35" alt="xAI 테마"><br>xAI</td>
<td><img src="docs/themes/zapier.png" height="35" alt="Zapier 테마"><br>Zapier</td>
</tr>
<tr>
<td><img src="docs/themes/zoom.png" height="35" alt="Zoom 테마"><br>Zoom</td>
</tr>
</table>

</details>

<details>
<summary><b>🇯🇵 일본</b> — 29개</summary>

<table>
<tr>
<td><img src="docs/themes/abema.png" height="35" alt="ABEMA 테마"><br>ABEMA</td>
<td><img src="docs/themes/cookpad.png" height="35" alt="Cookpad 테마"><br>Cookpad</td>
<td><img src="docs/themes/cybozu.png" height="35" alt="Cybozu 테마"><br>Cybozu</td>
</tr>
<tr>
<td><img src="docs/themes/dmm.png" height="35" alt="DMM.com (Turtle) 테마"><br>DMM.com (Turtle)</td>
<td><img src="docs/themes/freee.png" height="35" alt="freee 테마"><br>freee</td>
<td><img src="docs/themes/gaudiy.png" height="35" alt="Gaudiy 테마"><br>Gaudiy</td>
</tr>
<tr>
<td><img src="docs/themes/pepabo.png" height="35" alt="GMO Pepabo (Inhouse) 테마"><br>GMO Pepabo (Inhouse)</td>
<td><img src="docs/themes/layerx.png" height="35" alt="LayerX 테마"><br>LayerX</td>
<td><img src="docs/themes/line.png" height="35" alt="LINE 테마"><br>LINE</td>
</tr>
<tr>
<td><img src="docs/themes/mixi.png" height="35" alt="MIXI 테마"><br>MIXI</td>
<td><img src="docs/themes/money-forward.png" height="35" alt="Money Forward 테마"><br>Money Forward</td>
<td><img src="docs/themes/muji.png" height="35" alt="MUJI 테마"><br>MUJI</td>
</tr>
<tr>
<td><img src="docs/themes/nintendo.png" height="35" alt="Nintendo 테마"><br>Nintendo</td>
<td><img src="docs/themes/note.png" height="35" alt="note 테마"><br>note</td>
<td><img src="docs/themes/pixiv.png" height="35" alt="pixiv 테마"><br>pixiv</td>
</tr>
<tr>
<td><img src="docs/themes/rakuten.png" height="35" alt="Rakuten 테마"><br>Rakuten</td>
<td><img src="docs/themes/sansan.png" height="35" alt="Sansan 테마"><br>Sansan</td>
<td><img src="docs/themes/speeda.png" height="35" alt="SPEEDA (Uzabase) 테마"><br>SPEEDA (Uzabase)</td>
</tr>
<tr>
<td><img src="docs/themes/spindle.png" height="35" alt="Spindle (CyberAgent Ameba) 테마"><br>Spindle (CyberAgent Ameba)</td>
<td><img src="docs/themes/stores.png" height="35" alt="STORES 테마"><br>STORES</td>
<td><img src="docs/themes/studio.png" height="35" alt="Studio 테마"><br>Studio</td>
</tr>
<tr>
<td><img src="docs/themes/ubie.png" height="35" alt="Ubie 테마"><br>Ubie</td>
<td><img src="docs/themes/uniqlo.png" height="35" alt="Uniqlo 테마"><br>Uniqlo</td>
<td><img src="docs/themes/wantedly.png" height="35" alt="Wantedly 테마"><br>Wantedly</td>
</tr>
<tr>
<td><img src="docs/themes/zozotown.png" height="35" alt="ZOZOTOWN 테마"><br>ZOZOTOWN</td>
<td><img src="docs/themes/sakura-internet.png" height="35" alt="さくらインターネット 테마"><br>さくらインターネット</td>
<td><img src="docs/themes/sony.png" height="35" alt="ソニー 테마"><br>ソニー</td>
</tr>
<tr>
<td><img src="docs/themes/mynavi.png" height="35" alt="マイナビ 테마"><br>マイナビ</td>
<td><img src="docs/themes/recruit.png" height="35" alt="リクルート 테마"><br>リクルート</td>
</tr>
</table>

</details>

<details>
<summary><b>🇹🇼 대만</b> — 30개</summary>

<table>
<tr>
<td><img src="docs/themes/104.png" height="35" alt="104人力銀行 테마"><br>104人力銀行</td>
<td><img src="docs/themes/17live.png" height="35" alt="17LIVE 테마"><br>17LIVE</td>
<td><img src="docs/themes/91app.png" height="35" alt="91APP 테마"><br>91APP</td>
</tr>
<tr>
<td><img src="docs/themes/amazingtalker.png" height="35" alt="AmazingTalker 테마"><br>AmazingTalker</td>
<td><img src="docs/themes/appier.png" height="35" alt="Appier 테마"><br>Appier</td>
<td><img src="docs/themes/bahamut.png" height="35" alt="Bahamut 테마"><br>Bahamut</td>
</tr>
<tr>
<td><img src="docs/themes/cakeresume.png" height="35" alt="Cake 테마"><br>Cake</td>
<td><img src="docs/themes/dcard.png" height="35" alt="Dcard 테마"><br>Dcard</td>
<td><img src="docs/themes/esunbank.png" height="35" alt="E.SUN Bank 테마"><br>E.SUN Bank</td>
</tr>
<tr>
<td><img src="docs/themes/easywallet.png" height="35" alt="EasyWallet 테마"><br>EasyWallet</td>
<td><img src="docs/themes/fubon.png" height="35" alt="Fubon 테마"><br>Fubon</td>
<td><img src="docs/themes/fugle.png" height="35" alt="Fugle 테마"><br>Fugle</td>
</tr>
<tr>
<td><img src="docs/themes/funnow.png" height="35" alt="FunNow 테마"><br>FunNow</td>
<td><img src="docs/themes/gogoro.png" height="35" alt="Gogoro 테마"><br>Gogoro</td>
<td><img src="docs/themes/greenvines.png" height="35" alt="Greenvines 테마"><br>Greenvines</td>
</tr>
<tr>
<td><img src="docs/themes/hahow.png" height="35" alt="Hahow 테마"><br>Hahow</td>
<td><img src="docs/themes/ipassmoney.png" height="35" alt="iPASS MONEY 테마"><br>iPASS MONEY</td>
<td><img src="docs/themes/kdan.png" height="35" alt="Kdan Mobile 테마"><br>Kdan Mobile</td>
</tr>
<tr>
<td><img src="docs/themes/momoshop.png" height="35" alt="momo購物網 테마"><br>momo購物網</td>
<td><img src="docs/themes/moze.png" height="35" alt="MOZE 테마"><br>MOZE</td>
<td><img src="docs/themes/openpoint.png" height="35" alt="OPENPOINT 테마"><br>OPENPOINT</td>
</tr>
<tr>
<td><img src="docs/themes/pinkoi.png" height="35" alt="Pinkoi 테마"><br>Pinkoi</td>
<td><img src="docs/themes/readmoo.png" height="35" alt="Readmoo 테마"><br>Readmoo</td>
<td><img src="docs/themes/richart.png" height="35" alt="Richart 테마"><br>Richart</td>
</tr>
<tr>
<td><img src="docs/themes/shopline.png" height="35" alt="SHOPLINE 테마"><br>SHOPLINE</td>
<td><img src="docs/themes/surveycake.png" height="35" alt="SurveyCake 테마"><br>SurveyCake</td>
<td><img src="docs/themes/vocus.png" height="35" alt="Vocus 테마"><br>Vocus</td>
</tr>
<tr>
<td><img src="docs/themes/yourator.png" height="35" alt="Yourator 테마"><br>Yourator</td>
<td><img src="docs/themes/china-airlines.png" height="35" alt="中華航空 테마"><br>中華航空</td>
<td><img src="docs/themes/acer.png" height="35" alt="宏碁 테마"><br>宏碁</td>
</tr>
</table>

</details>

<details>
<summary><b>🌍 그 밖의 나라</b> — 18개</summary>

<table>
<tr>
<td><img src="docs/themes/bbc.png" height="35" alt="BBC 테마"><br>BBC <sub>영국</sub></td>
<td><img src="docs/themes/bilibili.png" height="35" alt="Bilibili 테마"><br>Bilibili <sub>중국</sub></td>
<td><img src="docs/themes/bmw.png" height="35" alt="BMW 테마"><br>BMW <sub>독일</sub></td>
</tr>
<tr>
<td><img src="docs/themes/deliveroo.png" height="35" alt="Deliveroo 테마"><br>Deliveroo <sub>영국</sub></td>
<td><img src="docs/themes/dji.png" height="35" alt="DJI 테마"><br>DJI <sub>중국</sub></td>
<td><img src="docs/themes/farfetch.png" height="35" alt="Farfetch 테마"><br>Farfetch <sub>영국</sub></td>
</tr>
<tr>
<td><img src="docs/themes/ferrari.png" height="35" alt="Ferrari 테마"><br>Ferrari <sub>이탈리아</sub></td>
<td><img src="docs/themes/govuk.png" height="35" alt="GOV.UK 테마"><br>GOV.UK <sub>영국</sub></td>
<td><img src="docs/themes/lamborghini.png" height="35" alt="Lamborghini 테마"><br>Lamborghini <sub>이탈리아</sub></td>
</tr>
<tr>
<td><img src="docs/themes/mistral.ai.png" height="35" alt="Mistral AI 테마"><br>Mistral AI <sub>프랑스</sub></td>
<td><img src="docs/themes/monzo.png" height="35" alt="Monzo 테마"><br>Monzo <sub>영국</sub></td>
<td><img src="docs/themes/renault.png" height="35" alt="Renault 테마"><br>Renault <sub>프랑스</sub></td>
</tr>
<tr>
<td><img src="docs/themes/revolut.png" height="35" alt="Revolut 테마"><br>Revolut <sub>영국</sub></td>
<td><img src="docs/themes/skyscanner.png" height="35" alt="Skyscanner 테마"><br>Skyscanner <sub>영국</sub></td>
<td><img src="docs/themes/starling.png" height="35" alt="Starling Bank 테마"><br>Starling Bank <sub>영국</sub></td>
</tr>
<tr>
<td><img src="docs/themes/trainline.png" height="35" alt="Trainline 테마"><br>Trainline <sub>영국</sub></td>
<td><img src="docs/themes/wise.png" height="35" alt="Wise 테마"><br>Wise <sub>영국</sub></td>
<td><img src="docs/themes/xiaohongshu.png" height="35" alt="Xiaohongshu 테마"><br>Xiaohongshu <sub>중국</sub></td>
</tr>
</table>

</details>
<!-- themes:end -->

목록에 없는 회사를 추가하는 방법은 [개발 문서](docs/development.md#회사-추가)에 있습니다.

## 설치

필요한 것: **macOS + iTerm2 + zsh + [powerlevel10k](https://github.com/romkatv/powerlevel10k)**

```sh
git clone https://github.com/Gogumang/oh-my-terminal ~/.zsh/oh-my-terminal
~/.zsh/oh-my-terminal/install.sh
```

> [!IMPORTANT]
> zsh-autosuggestions를 쓰고 있다면 `~/.zshrc`에서 빼 주세요. 함께 불리면 내장 자동 제안이
> 켜지지 않습니다.

Oh My Zsh·zinit·Antigen으로 설치하는 방법, 자동 제안 설정, 알려진 제약은
[사용 안내](docs/guide.md)에 있습니다.

## 회사 고르기

**설치만 해서는 화면이 바뀌지 않습니다.** 테마는 iTerm2 프로필을 보고 켜지므로, 쓰려는 회사의
`<회사> Brand` 프로필을 기본 프로필로 정해야 합니다. iTerm2를 재시작할 필요는 없습니다.

1. iTerm2에서 ⌘,를 눌러 **Settings**를 열고 **Profiles** 탭을 누릅니다.
2. 아래 그림 순서대로 기본 프로필을 바꿉니다.
   - ① 검색창에 회사 이름을 입력합니다 (예: `nol`).
   - ② `<회사> Brand` 프로필을 고릅니다.
   - ③ **Other Actions…** → **Set as Default**를 누릅니다. 이름 앞에 ★가 붙으면 기본 프로필입니다.
3. **새 탭**(⌘T)이나 **새 창**(⌘N)을 엽니다. 어느 폴더에서나 그 회사 테마가 나옵니다.

![iTerm2 Settings → Profiles에서 NOL Brand를 검색해 고르고 Other Actions… → Set as Default를 누르는 화면](docs/screenshots/set-default-profile.png)

기본 프로필은 그대로 두고 한 창에서만 써 보려면 ⌘O로 Profiles 창을 열어 그 프로필을 여세요.

### 테마가 안 바뀌면

테마가 안 나오는 창에서 프로필 이름을 확인하세요.

```sh
echo $ITERM_PROFILE
```

- **`Default`처럼 `Brand`로 끝나지 않는 이름이 나오면** 그 창은 브랜드 프로필이 아닙니다. 브랜드
  프로필이 아닌 창에서는 일부러 아무것도 바꾸지 않습니다. 위 ③을 다시 하고 새 탭을 여세요.
- **이미 열려 있던 창은 기본 프로필을 바꿔도 그대로입니다.** 프로필 이름은 창을 열 때 정해지므로
  반드시 새 탭이나 새 창에서 확인하세요.
- **`<회사> Brand`가 나오는데도 테마가 없으면** `~/.zshrc`에 플러그인이 들어갔는지 확인하세요.
  `grep oh-my-terminal ~/.zshrc`에 아무것도 안 나오면 `install.sh`를 다시 실행하세요.

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
