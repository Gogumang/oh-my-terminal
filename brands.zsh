# ─────────────────────────────────────────────────────────────────────────────
#  이 파일은 oh-my-terminal 빌더가 생성한다. 직접 고치지 말고 brands/*.yaml을 고칠 것.
#  순수 zsh다 — python·curl 등 외부 명령에 의존하지 않는다.
#  ~/.p10k.zsh 보다 먼저 source 해도 된다 — p10k 설정은 첫 프롬프트 직전에 넣는다.
#
#  회사는 iTerm2 프로필로 고른다. "<회사> Brand" 프로필로 연 창에서는 어느 폴더에서나 그 회사
#  테마를 입히고, 다른 프로필이면 아무것도 건드리지 않는다.
# ─────────────────────────────────────────────────────────────────────────────

# iTerm2 프로필 이름 → "회사키 시작색 끝색 어두운글자색 밝은글자색 흐린글자색 로고색 로고조각".
# 로고 조각은 글자 칸마다 한 글자다. 로고가 없는 회사는 마지막 칸이 빈다.
typeset -gA _brand_profiles=(
  '104人力銀行 Brand' '104 #FF9100 #E08000 #292929 #292929 #7C5017 #000000 􀀀􀀁􀀂􀀃'
  '17LIVE Brand' '17live #FF7890 #E0697E #292929 #FFFFFF #7B464F #000000 􀀄􀀅􀀆'
  '29CM Brand' '29cm #292929 #121212 #000000 #919191 #080808 #FFFFFF 􀀇􀀈􀀉'
  '3o3 Brand' '3o3 #0C64E6 #052D67 #16181D #EEEFF2 #0F213F #FFFFFF 􀀊􀀋'
  '42dot Brand' '42dot #8A82FB #7F77E7 #16181D #16181D #454378 #000000 􀀌􀀍􀀎'
  '8percent Brand' '8percent #458EF1 #3F82DE #16181D #16181D #294874 #000000 􀀏􀀐􀀑'
  '91APP Brand' '91app #061C3D #030D1B #061C3D #3D83EC #05152E #FFFFFF 􀀒􀀓􀀔􀀕'
  'ABEMA Brand' 'abema #DDAA00 #C29600 #333333 #E6E6E6 #74601C #000000 􀀖􀀗'
  'Ably Brand' 'ably #FF6573 #E05965 #1F1F1F #1F1F1F #76393E #000000 􀀘􀀙􀀚'
  '宏碁 Brand' 'acer #80C343 #649834 #222222 #222222 #40572A #000000 􀀛􀀜􀀝􀀞'
  'Adobe Brand' 'adobe #EB1000 #6A0700 #16181D #FFFFFF #3C1010 #000000 􀀟􀀠􀀡'
  'Airbnb Brand' 'airbnb #FF617D #EB5973 #222222 #222222 #7C3B47 #000000 􀀢􀀣'
  'Airtable Brand' 'airtable #FCB400 #B58200 #181D26 #181D26 #5F4A15 #000000 􀀤􀀥􀀦'
  'AmazingTalker Brand' 'amazingtalker #02CAB9 #019185 #16181D #16181D #0D4F4C #000000 􀀧􀀨'
  'Appier Brand' 'appier #1D2EFF #0D1573 #101130 #C8C9ED #0F134E #FFFFFF 􀀩􀀪'
  'Apple Brand' 'apple #292929 #121212 #1D1D1F #909097 #181819 #FFFFFF 􀀫􀀬'
  'Asana Brand' 'asana #F06A6A #D35D5D #16181D #16181D #6B373A #000000 􀀭􀀮􀀯'
  'Asleep Brand' 'asleep #1668FC #0A2F71 #16181D #F9FAFB #112243 #FFFFFF 􀀰􀀱'
  'Baemin Brand' 'baemin #0CEFD3 #089B89 #222222 #222222 #165950 #000000 􀀲􀀳'
  'Bahamut Brand' 'bahamut #11AAC1 #0E8DA0 #16181D #16181D #124D58 #000000 􀀴􀀵􀀶'
  'Banksalad Brand' 'banksalad #13BD7E #0F9362 #111111 #111111 #104C36 #000000 􀀷􀀸'
  'Barogo Brand' 'barogo #FA5014 #E64A12 #16181D #16181D #742E18 #000000 􀀹􀀺'
  'BBC Brand' 'bbc #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀀻􀀼􀀽􀀾'
  'Beusable Brand' 'beusable #EC0047 #6A0020 #16181D #FFFFFF #3C0D1E #000000 􀀿􀁀'
  'Bigin Brand' 'bigin #0066EB #002E6A #16181D #F1F2F4 #0C223F #FFFFFF 􀁁􀁂􀁃􀁄'
  'Bilibili Brand' 'bilibili #FB7299 #D05F7F #18191C #18191C #6B3849 #000000 􀁅􀁆􀁇'
  'Bithumb Brand' 'bithumb #1C2028 #0D0E12 #FFFFFF #FFFFFF #929394 #FFFFFF 􀁈􀁉'
  'BMW Brand' 'bmw #1C69D4 #0D2F5F #414141 #EEEEEE #29394F #FFFFFF 􀁊􀁋'
  'Brandi Brand' 'brandi #1E1E1E #0D0D0D #16181D #7D869C #121316 #FFFFFF 􀁌􀁍'
  'Buzzvil Brand' 'buzzvil #F55549 #E14E43 #16181D #16181D #72302E #000000 􀁎􀁏􀁐􀁑'
  'Cake Brand' 'cakeresume #13AB67 #0F8550 #000000 #000000 #073C24 #000000 􀁒􀁓'
  'Cal.com Brand' 'cal #192339 #0B101A #242424 #8A8A8A #191B1F #FFFFFF 􀁔􀁕􀁖'
  'CGV Brand' 'cgv #292929 #121212 #121212 #8F8F8F #121212 #FFFFFF 􀁗􀁘􀁙􀁚'
  'Channel Talk Brand' 'channeltalk #242428 #101012 #000000 #8C8C8C #070708 #FFFFFF 􀁛􀁜'
  '中華航空 Brand' 'china-airlines #23569D #102747 #16181D #C8CCD5 #131F30 #FFFFFF 􀁝􀁞􀁟'
  'CJ ONSTYLE Brand' 'cjonstyle #640FAF #2D074F #16181D #AEB3C1 #201033 #FFFFFF 􀁠􀁡'
  'Classting Brand' 'classting #00DCA5 #00CB98 #424242 #424242 #248069 #000000 􀁢􀁣'
  'Claude (Anthropic) Brand' 'claude #CE7152 #BD684B #141413 #141413 #603A2C #000000 􀁤􀁥􀁦'
  'ClickHouse Brand' 'clickhouse #FAFF69 #A3A644 #373737 #DFDFDF #67693D #000000 􀁧􀁨􀁩'
  'Cloudflare Brand' 'cloudflare #F6821F #CC6C1A #1D1F20 #1D1F20 #6C421D #000000 􀁪􀁫􀁬􀁭'
  'Codeit Brand' 'codeit #9933FF #451773 #16181D #F6F7F8 #2B1844 #FFFFFF 􀁮􀁯'
  'Coinbase Brand' 'coinbase #0052FF #002573 #0A0B0D #E4E6EA #06173B #FFFFFF 􀁰􀁱'
  'Coinone Brand' 'coinone #006BD6 #003060 #17181B #F1F1F3 #0D233A #FFFFFF 􀁲􀁳'
  'Composio Brand' 'composio #5054EF #24266C #FFFFFF #FFFFFF #9D9DBD #FFFFFF 􀁴􀁵'
  'Cookpad Brand' 'cookpad #FF9933 #B86E25 #0F0F0F #0F0F0F #5B3A19 #000000 􀁶􀁷􀁸'
  'Coupang Brand' 'coupang #292929 #121212 #000000 #919191 #080808 #FFFFFF 􀁹􀁺'
  'Cursor Brand' 'cursor #26251E #11110D #16181D #828BA0 #141516 #FFFFFF 􀁻􀁼'
  'Cybozu Brand' 'cybozu #139CB7 #1190A8 #16181D #16181D #144E5C #000000 􀁽􀁾􀁿'
  'Databricks Brand' 'databricks #FF4835 #EB4331 #16181D #16181D #762B26 #000000 􀂀􀂁'
  'Dcard Brand' 'dcard #0086FF #0076E0 #000000 #000000 #003565 #000000 􀂂􀂃'
  'Sinsang Market (Dealicious) Brand' 'dealicious #001B52 #000C25 #16181D #7F889E #0C1320 #FFFFFF 􀂄􀂅'
  'Deliveroo Brand' 'deliveroo #00CCBC #009387 #16181D #16181D #0C4F4D #000000 􀂆􀂇'
  'Dell Brand' 'dell #0076CE #00355D #16181D #FCFCFD #0C253A #FFFFFF 􀂈􀂉'
  'Discord Brand' 'discord #5865F2 #282D6D #16181D #FCFCFD #1E2241 #FFFFFF 􀂊􀂋􀂌'
  'DJI Brand' 'dji #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀂍􀂎􀂏􀂐'
  'DMM.com (Turtle) Brand' 'dmm #94BCFF #6B87B8 #16181D #16181D #3C4A63 #000000 􀂑􀂒􀂓'
  'DoorDash Brand' 'doordash #EB1700 #6A0A00 #16181D #FFFFFF #3C1210 #000000 􀂔􀂕􀂖􀂗'
  'Dr.diary Brand' 'drdiary #3EAEFF #3088C7 #16181D #16181D #224A69 #000000 􀂘􀂙􀂚'
  'Dr.Now (닥터나우) Brand' 'drnow #FF8D00 #C76E00 #16181D #16181D #663F10 #000000 􀂛􀂜'
  'Dropbox Brand' 'dropbox #0061FE #002C72 #16181D #F1F2F4 #0C2143 #FFFFFF 􀂝􀂞􀂟'
  'Duolingo Brand' 'duolingo #61E002 #55C502 #414141 #4B4B4B #4A7C25 #000000 􀂠􀂡'
  'EasyWallet Brand' 'easywallet #007BC6 #003759 #16181D #FFFFFF #0C2638 #000000 􀂢􀂣'
  'Elastic UI Brand' 'elastic #0B64DD #052D63 #1D2A3E #E6EBF3 #122B4F #FFFFFF 􀂤􀂥'
  'ElevenLabs Brand' 'elevenlabs #292929 #121212 #000000 #919191 #080808 #FFFFFF 􀂦􀂧'
  'E.SUN Bank Brand' 'esunbank #00A19B #00948F #16181D #16181D #0C5050 #000000 􀂨􀂩􀂪􀂫'
  'Expo Brand' 'expo #292929 #121212 #1C2024 #8593A0 #181A1C #FFFFFF 􀂬􀂭􀂮'
  'Farfetch Brand' 'farfetch #222222 #0F0F0F #16181D #828BA0 #131417 #FFFFFF 􀂯􀂰'
  'Fastcampus Brand' 'fastcampus #EC0332 #6A0116 #16181D #FFFFFF #3C0E1A #000000 􀂱􀂲'
  'Ferrari Brand' 'ferrari #DA291C #62120D #181818 #F8F8F8 #391613 #FFFFFF 􀂳􀂴'
  'Figma Brand' 'figma #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀂵􀂶'
  'Fitpet Brand' 'fitpet #0050FF #002473 #16181D #E2E4E9 #0C1D44 #FFFFFF 􀂷􀂸'
  'Framer Brand' 'framer #0055FF #002673 #FFFFFF #FFFFFF #8C9DC0 #FFFFFF 􀂹􀂺'
  'freee Brand' 'freee #2864F0 #122D6C #16181D #F3F4F6 #142141 #FFFFFF 􀂻􀂼'
  'Frip Brand' 'frip #7A29FA #371270 #16181D #DFE1E7 #251643 #FFFFFF 􀂽􀂾􀂿'
  'Fubon Brand' 'fubon #00A3D5 #008FBC #16181D #16181D #0C4E64 #000000 􀃀􀃁'
  'Fugle Brand' 'fugle #F4AF1C #B07E14 #16181D #16181D #5B4619 #000000 􀃂􀃃'
  'FunNow Brand' 'funnow #FF5537 #EB4E33 #16181D #16181D #763027 #000000 􀃄􀃅'
  '강남언니 Brand' 'gangnamunni #D54300 #601E00 #16181D #FFFFFF #371B10 #000000 􀃆􀃇'
  'Gaudio Lab Brand' 'gaudiolab #00B7FF #008FC7 #16181D #16181D #0C4D69 #000000 􀃈􀃉'
  'Gaudiy Brand' 'gaudiy #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀃊􀃋􀃌􀃍'
  'Genie Music Brand' 'genie #FB5475 #E64D6C #16181D #16181D #743040 #000000 􀃎􀃏'
  'GitHub Brand' 'github #0969DA #042F62 #16181D #EEEFF2 #0E223C #FFFFFF 􀃐􀃑􀃒'
  'GitLab Brand' 'gitlab #1F75CB #0E355B #16181D #FCFCFD #122539 #FFFFFF 􀃓􀃔􀃕'
  'Gogoro Brand' 'gogoro #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀃖􀃗'
  'Google Brand' 'google #1A73E8 #0C3468 #3C4043 #FFFFFF #263A54 #000000 􀃘􀃙'
  'goorm Brand' 'goorm #2A72E5 #133367 #16181D #FFFFFF #15243E #000000 􀃚􀃛􀃜'
  'GOV.UK Brand' 'govuk #1D70B8 #0D3253 #0B0C0C #F0F2F2 #0C1D2C #FFFFFF 􀃝􀃞􀃟'
  'Greencar Brand' 'greencar #00C88C #009C6D #16181D #16181D #0C5341 #000000 􀃠􀃡􀃢'
  'Greenvines Brand' 'greenvines #002D18 #00140B #16181D #858EA3 #0C1615 #FFFFFF 􀃣􀃤􀃥􀃦'
  'Hackle Brand' 'hackle #0065FF #002D73 #16181D #F6F7F8 #0C2244 #FFFFFF 􀃧􀃨'
  'Hahow Brand' 'hahow #00CCB4 #009382 #16181D #16181D #0C4F4A #000000 􀃩􀃪'
  'Hana Bank Brand' 'hana #00A39F #008F8C #16181D #16181D #0C4E4F #000000 􀃫􀃬'
  'Hashicorp Brand' 'hashicorp #1060FF #072B73 #3B3D45 #F2F2F3 #24355A #FFFFFF 􀃭􀃮'
  'Headspace Brand' 'headspace #0061EF #002C6C #16181D #EEEFF2 #0C2140 #FFFFFF 􀃯􀃰'
  'HP Brand' 'hp #0096D6 #008AC5 #16181D #16181D #0C4B69 #000000 􀃱􀃲'
  'HubSpot Brand' 'hubspot #FF5714 #EB5013 #16181D #16181D #763118 #000000 􀃳􀃴'
  'Humanscape Brand' 'humanscape #00ADF7 #0090CD #16181D #16181D #0C4E6C #000000 􀃵􀃶􀃷'
  'Hwahae Brand' 'hwahae #00D5CE #009994 #16181D #16181D #0C5253 #000000 􀃸􀃹'
  'Hyundai Brand' 'hyundai #002C5F #00142B #16181D #8E96A9 #0C1623 #FFFFFF 􀃺􀃻􀃼􀃽'
  'IBM Brand' 'ibm #0F62FE #072C72 #161616 #F4F4F4 #0F2040 #FFFFFF 􀃾􀃿􀄀􀄁'
  'idus (Backpackr) Brand' 'idus #EF7014 #D26312 #16181D #16181D #6B3A18 #000000 􀄂􀄃'
  'IGAWorks Brand' 'igaworks #1A1D23 #0C0D10 #16181D #7D869C #111317 #FFFFFF 􀄄􀄅􀄆'
  'IICOMBINED Brand' 'iicombined #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀄇􀄈'
  'Inflearn Brand' 'inflearn #00C471 #009958 #16181D #16181D #0C5238 #000000 􀄉􀄊'
  'Instacart Brand' 'instacart #108910 #073E07 #16181D #FFFFFF #0F2913 #000000 􀄋􀄌'
  'Intercom Brand' 'intercom #1461FA #092B70 #16181D #F1F2F4 #102142 #FFFFFF 􀄍􀄎'
  'iPASS MONEY Brand' 'ipassmoney #53B232 #459429 #16181D #16181D #2B5023 #000000 􀄏􀄐'
  'JANDI Brand' 'jandi #00C473 #00995A #16181D #16181D #0C5238 #000000 􀄑􀄒􀄓'
  'Kakao Brand' 'kakao #FEE500 #B7A500 #333333 #333333 #6E661C #000000 􀄔􀄕'
  'KakaoBank Brand' 'kakaobank #FFE300 #8C7D00 #000000 #000000 #3F3800 #000000 􀄖􀄗'
  '카카오게임즈 Brand' 'kakaogames #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀄘􀄙􀄚􀄛'
  'Kakao T Brand' 'kakaot #FEE500 #A59500 #191919 #191919 #58510E #000000 􀄜􀄝'
  'Karrot Brand' 'karrot #FF7E36 #E06F30 #212124 #212124 #774429 #000000 􀄞􀄟'
  'Korea Credit Data Brand' 'kcd #2D91FF #2985EB #16181D #16181D #1F497A #000000 􀄠􀄡'
  'Kdan Mobile Brand' 'kdan #00DC87 #009E61 #191919 #191919 #0E5539 #000000 􀄢􀄣'
  'Kia Brand' 'kia #0B2D46 #051420 #16181D #8B93A7 #0E161E #FFFFFF 􀄤􀄥􀄦􀄧'
  'Kraken Brand' 'kraken #5741D9 #271D62 #101114 #D5D7DD #1A1737 #FFFFFF 􀄨􀄩􀄪'
  'KREAM Brand' 'kream #292929 #121212 #222222 #909090 #1B1B1B #FFFFFF 􀄫􀄬􀄭􀄮'
  'Kurly Brand' 'kurly #5F0080 #2B003A #333333 #A1A1A1 #2F1C36 #FFFFFF 􀄯􀄰􀄱􀄲'
  'Kyobo Book Centre Brand' 'kyobobook #5055B1 #242650 #16181D #D6D9E0 #1C1E34 #FFFFFF 􀄳􀄴􀄵'
  'Lablup Brand' 'lablup #28AB6C #23965F #16181D #16181D #1C513B #000000 􀄶􀄷􀄸'
  'Lamborghini Brand' 'lamborghini #FFC000 #B88A00 #202020 #202020 #645012 #000000 􀄹􀄺'
  'LaundryGo Brand' 'laundrygo #0AC290 #089770 #16181D #16181D #105142 #000000 􀄻􀄼'
  'LayerX Brand' 'layerx #534DFF #252373 #16181D #EBECF0 #1D1D44 #FFFFFF 􀄽􀄾􀄿'
  'Lemonbase Brand' 'lemonbase #4695F7 #3D83D9 #16181D #16181D #284872 #000000 􀅀􀅁􀅂'
  'Lezhin Comics Brand' 'lezhin #EB0014 #6A0009 #16181D #FCFCFD #3C0D14 #FFFFFF 􀅃􀅄'
  'LikeLion Brand' 'likelion #FF6D14 #EB6413 #222222 #222222 #7C401B #000000 􀅅􀅆􀅇􀅈'
  'LINE Brand' 'line #06C755 #048F3D #000000 #000000 #02401C #000000 􀅉􀅊􀅋'
  'Linear Brand' 'linear.app #5E6AD2 #2A305E #F7F8F8 #FAFAFA #9B9EB3 #FFFFFF 􀅌􀅍'
  'Loom Brand' 'loom #1868DB #0B2F63 #101214 #EEF0F2 #0E1F37 #FFFFFF 􀅎􀅏'
  'Lunit Brand' 'lunit #1032CF #07165D #16181D #B7BCC8 #0F173A #FFFFFF 􀅐􀅑'
  'Mailchimp Brand' 'mailchimp #FFE01B #A69212 #16181D #16181D #574F18 #000000 􀅒􀅓'
  'Mastercard Brand' 'mastercard #EB001B #6A000C #141413 #FEFEFE #3B0B10 #FFFFFF 􀅔􀅕􀅖􀅗'
  'maum.ai (ex-MindsLab) Brand' 'maum-ai #4262FF #1E2C73 #16181D #F9FAFB #192144 #FFFFFF 􀅘􀅙'
  'Melon Brand' 'melon #00CD3C #00A02F #16181D #16181D #0C5525 #000000 􀅚􀅛'
  'Mercury Brand' 'mercury #5266EB #252E6A #16181D #FCFCFD #1D2240 #FFFFFF 􀅜􀅝'
  'Meta Brand' 'meta #0064E0 #002D65 #16181D #EBECF0 #0C213D #FFFFFF 􀅞􀅟􀅠'
  'Milddang (I Hate Flying Bugs) Brand' 'mildang #00B29D #009482 #16181D #16181D #0C504B #000000 􀅡􀅢'
  'MiniMax Brand' 'minimax #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀅣􀅤􀅥'
  'Mintlify Brand' 'mintlify #0FA682 #0D9272 #16181D #16181D #124F43 #000000 􀅦􀅧'
  'Miro Brand' 'miro #FDE050 #A49234 #16181D #16181D #564F27 #000000 􀅨􀅩'
  'Mistral AI Brand' 'mistral.ai #292929 #121212 #000000 #919191 #080808 #FFFFFF 􀅪􀅫􀅬'
  'MIXI Brand' 'mixi #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀅭􀅮􀅯􀅰'
  'Modusign Brand' 'modusign #FED05F #A5873E #16181D #16181D #564A2C #000000 􀅱􀅲'
  'Moin Brand' 'moin #148CFF #1381EB #16181D #16181D #15477A #000000 􀅳􀅴􀅵􀅶'
  'momo購物網 Brand' 'momoshop #D62872 #601233 #404040 #FAFAFA #4F2B3A #FFFFFF 􀅷􀅸􀅹'
  'Money Forward Brand' 'money-forward #2971E7 #123368 #333333 #FFFFFF #24334B #000000 􀅺􀅻􀅼'
  'MongoDB Brand' 'mongodb #00ED64 #009A41 #16181D #16181D #0C532D #000000 􀅽􀅾'
  'Monzo Brand' 'monzo #FF4F40 #EB493B #16181D #16181D #762E2A #000000 􀅿􀆀􀆁'
  'Moreh Brand' 'moreh #FF5700 #EB5000 #16181D #16181D #763110 #000000 􀆂􀆃􀆄'
  'MOZE Brand' 'moze #FF4A89 #EB447E #16181D #16181D #762C49 #000000 􀆅􀆆􀆇'
  'MUJI Brand' 'muji #7F0019 #39000B #333333 #A8A8A8 #361C21 #FFFFFF 􀆈􀆉􀆊'
  'Musinsa Brand' 'musinsa #292929 #121212 #000000 #919191 #080808 #FFFFFF 􀆋􀆌􀆍'
  'MUSTIT Brand' 'mustit #D00000 #5E0000 #222222 #E6E6E6 #3D1313 #FFFFFF 􀆎􀆏􀆐'
  'マイナビ Brand' 'mynavi #0071BB #003354 #16181D #F1F2F4 #0C2436 #FFFFFF 􀆑􀆒􀆓􀆔'
  'MyRealTrip Brand' 'myrealtrip #2B96ED #288ADA #16181D #16181D #1E4B72 #000000 􀆕􀆖􀆗'
  'Naver Brand' 'naver #03C75A #029B46 #16181D #16181D #0D5330 #000000 􀆘􀆙'
  'Naver Webtoon Brand' 'naverwebtoon #00DC64 #008F41 #000000 #000000 #00401D #000000 􀆚􀆛􀆜'
  'NCSOFT Brand' 'ncsoft #7234E0 #331765 #16181D #D6D9E0 #23183D #FFFFFF 􀆝􀆞􀆟􀆠'
  'Netflix Brand' 'netflix #E50914 #670409 #FFFFFF #FFFFFF #BB8E90 #FFFFFF 􀆡􀆢'
  'Nexon Brand' 'nexon #00DE5A #00A041 #16181D #16181D #0C552D #000000 􀆣􀆤'
  'NHN Brand' 'nhn #212126 #0F0F11 #36363D #878795 #242429 #FFFFFF 􀆥􀆦'
  'Nike Brand' 'nike #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀆧􀆨􀆩􀆪'
  'Nintendo Brand' 'nintendo #E60012 #670008 #16181D #F9FAFB #3B0D14 #FFFFFF 􀆫􀆬􀆭􀆮'
  'NOL Brand' 'nol #3549FF #182173 #F5F6F9 #F5F6F9 #9196BD #FFFFFF 􀆯􀆰􀆱􀆲'
  'Nota AI Brand' 'nota #3264F0 #172D6C #16181D #F3F4F6 #162141 #FFFFFF 􀆳􀆴􀆵􀆶'
  'note Brand' 'note #41C9B4 #2F9182 #16181D #16181D #214E4A #000000 􀆷􀆸'
  'Notion Brand' 'notion #0075DE #003564 #16181D #FFFFFF #0C253D #000000 􀆹􀆺'
  'NVIDIA Brand' 'nvidia #76B900 #5C9000 #16181D #16181D #364E10 #000000 􀆻􀆼􀆽'
  'Olive Young Brand' 'oliveyoung #82DC28 #558F1A #16181D #16181D #324E1C #000000 􀆾􀆿'
  'Ollama Brand' 'ollama #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀇀􀇁'
  'OpenAI Brand' 'openai #10A37F #0F9675 #16181D #16181D #135145 #000000 􀇂􀇃'
  'OpenCode AI Brand' 'opencode.ai #292929 #121212 #201D1D #998F8F #1A1818 #FFFFFF 􀇄􀇅'
  'OPENPOINT Brand' 'openpoint #8081FF #7677EB #16181D #16181D #41437A #000000 􀇆􀇇'
  'PatternFly Brand' 'patternfly #0066CC #002E5C #151515 #E9E9E9 #0C2035 #FFFFFF 􀇈􀇉'
  'Payhere Brand' 'payhere #008CFF #0081EB #16181D #16181D #0C477A #000000 􀇊􀇋􀇌'
  'PayPal Brand' 'paypal #002991 #001241 #16181D #979EB0 #0C162D #FFFFFF 􀇍􀇎'
  'Pega UX Design System Brand' 'pega #1A3A5C #0C1A29 #050505 #A3A3A3 #080E15 #FFFFFF 􀇏􀇐􀇑'
  'PeopleFund Brand' 'peoplefund #FFC32D #A67F1D #16181D #16181D #57461D #000000 􀇒􀇓􀇔'
  'GMO Pepabo (Inhouse) Brand' 'pepabo #1C71BA #0D3354 #16181D #F1F2F4 #122436 #FFFFFF 􀇕􀇖'
  'Perplexity Brand' 'perplexity #20808D #0E3A3F #16181D #FCFCFD #13272D #FFFFFF 􀇗􀇘'
  'Pinkoi Brand' 'pinkoi #FF595A #E04E4F #16181D #16181D #713034 #000000 􀇙􀇚'
  'Pinterest Brand' 'pinterest #E60023 #670010 #16181D #F9FAFB #3B0D17 #FFFFFF 􀇛􀇜'
  'pixiv Brand' 'pixiv #0096FA #0084DC #16181D #16181D #0C4973 #000000 􀇝􀇞'
  'PortOne Brand' 'portone #FC6B2D #DE5E28 #16181D #16181D #703822 #000000 􀇟􀇠'
  'PostHog Brand' 'posthog #1D4AFF #0D2173 #4D4F46 #DFE0DC #303A5A #FFFFFF 􀇡􀇢􀇣􀇤'
  'POSTYPE Brand' 'postype #F56370 #D85763 #16181D #16181D #6D353C #000000 􀇥􀇦􀇧'
  'POZAlabs Brand' 'pozalabs #ABA1FA #857EC3 #16181D #16181D #484668 #000000 􀇨􀇩'
  'Quotabook Brand' 'quotabook #00E8C5 #00D5B5 #4C4C4C #FFFFFF #2A8A7C #000000 􀇪􀇫􀇬'
  'Rakuten Brand' 'rakuten #BF0000 #560000 #16181D #D4D7DE #330D10 #FFFFFF 􀇭􀇮'
  'Raycast Brand' 'raycast #FF6363 #E05757 #16181D #16181D #713437 #000000 􀇯􀇰'
  'Readmoo Brand' 'readmoo #40C8F7 #2E90B2 #16181D #16181D #214E60 #000000 􀇱􀇲􀇳'
  'Rebellions Brand' 'rebellions #52F756 #35A138 #16181D #16181D #245529 #000000 􀇴􀇵'
  'リクルート Brand' 'recruit #0065BD #002D55 #2D3133 #E1E3E4 #192F42 #FFFFFF 􀇶􀇷'
  'Reddit Brand' 'reddit #D63A00 #601A00 #333D42 #FCFCFD #472D24 #FFFFFF 􀇸􀇹'
  'Remember Brand' 'remember #292929 #121212 #222222 #909090 #1B1B1B #FFFFFF 􀇺􀇻'
  'Renault Brand' 'renault #FFCC00 #A68500 #16181D #16181D #574910 #000000 􀇼􀇽'
  'Replicate Brand' 'replicate #FC7676 #D16262 #16181D #16181D #6A393C #000000 􀇾􀇿'
  'Resend Brand' 'resend #3DB9FF #38AAEB #383838 #F0F0F0 #386C89 #000000 􀈀􀈁'
  'Retool Brand' 'retool #3C3C3C #1B1B1B #16181D #9FA6B6 #18191C #FFFFFF 􀈂􀈃'
  'Return Zero Brand' 'returnzero #222222 #0F0F0F #16181D #828BA0 #131417 #FFFFFF 􀈄􀈅'
  'Revolut Brand' 'revolut #006BD7 #003061 #16181D #F1F2F4 #0C233B #FFFFFF 􀈆􀈇'
  'Richart Brand' 'richart #17B6C9 #128E9D #16181D #16181D #144D57 #000000 􀈈􀈉􀈊'
  'Robinhood Brand' 'robinhood #00C805 #009C04 #16181D #16181D #0C5312 #000000 􀈋􀈌'
  'RunwayML Brand' 'runwayml #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀈍􀈎􀈏􀈐'
  'さくらインターネット Brand' 'sakura-internet #FF5577 #EB4E6D #1D1D1D #1D1D1D #7A3341 #000000 􀈑􀈒􀈓'
  'Samsung Brand' 'samsung #292929 #121212 #000000 #919191 #080808 #FFFFFF 􀈔􀈕􀈖􀈗'
  'Sandoll Brand' 'sandoll #EB0600 #6A0200 #16181D #FCFCFD #3C0E10 #FFFFFF 􀈘􀈙􀈚􀈛'
  'Sanity Brand' 'sanity #FF5500 #E04B00 #0B0B0B #0B0B0B #6B2806 #000000 􀈜􀈝􀈞'
  'Sansan Brand' 'sansan #E60012 #670008 #16181D #F9FAFB #3B0D14 #FFFFFF 􀈟􀈠'
  'Saramin Brand' 'saramin #3568ED #182F6B #16181D #F9FAFB #172240 #FFFFFF 􀈡􀈢'
  'Scatter Lab Brand' 'scatterlab #212529 #0F1112 #16181D #828BA0 #131518 #FFFFFF 􀈣􀈤􀈥'
  'Sentry Brand' 'sentry #362D59 #181428 #FFFFFF #FFFFFF #97959E #FFFFFF 􀈦􀈧􀈨'
  'ServiceNow Horizon Brand' 'servicenow #102C40 #07141D #16181D #8890A5 #0F161D #FFFFFF 􀈩􀈪􀈫􀈬'
  'Shift Up Brand' 'shiftup #5EA849 #539440 #16181D #16181D #31502D #000000 􀈭􀈮􀈯􀈰'
  'Shinhan Bank Brand' 'shinhanbank #0046FF #001F73 #16181D #D9DCE2 #0C1B44 #FFFFFF 􀈱􀈲􀈳'
  'SHOPLINE Brand' 'shopline #215EFF #0F2A73 #16181D #F1F2F4 #132044 #FFFFFF 􀈴􀈵'
  'SIONIC AI Brand' 'sionic #0074E1 #003465 #16181D #FFFFFF #0C253D #000000 􀈶􀈷'
  'SK텔레콤 Brand' 'sktelecom #3A46CD #1A205C #1A2232 #C6CFE1 #1A2145 #FFFFFF 􀈸􀈹'
  'Skyscanner Brand' 'skyscanner #0062E3 #002C66 #161616 #EAEAEA #0C203A #FFFFFF 􀈺􀈻􀈼'
  'Slack Brand' 'slack #4A154B #210922 #1D1C1D #969296 #1F141F #FFFFFF 􀈽􀈾'
  'Snapchat Brand' 'snapchat #FFFC00 #8C8B00 #16181D #16181D #4B4C10 #000000 􀈿􀉀􀉁'
  'SOCAR Brand' 'socar #006EEB #00326A #354153 #FBFBFC #1D3A5D #FFFFFF 􀉂􀉃'
  'ソニー Brand' 'sony #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀉄􀉅􀉆􀉇'
  'Soomgo Brand' 'soomgo #693BF2 #2F1B6D #16181D #DFE1E7 #211941 #FFFFFF 􀉈􀉉􀉊'
  'SpaceX Brand' 'spacex #ECECF9 #9999A2 #282877 #F0F0FA #5B5B8A #000000 􀉋􀉌􀉍􀉎'
  'SPEEDA (Uzabase) Brand' 'speeda #E60F3D #67071B #16181D #FCFCFD #3B101C #FFFFFF 􀉏􀉐􀉑'
  'Spindle (CyberAgent Ameba) Brand' 'spindle #298737 #123D19 #16181D #FFFFFF #14291B #000000 􀉒􀉓'
  'Spotify Brand' 'spotify #28E16A #25CF62 #454545 #FFFFFF #378352 #000000 􀉔􀉕'
  'Squarespace Brand' 'squarespace #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀉖􀉗􀉘'
  'SqueezeBits Brand' 'squeezebits #BA5214 #542509 #16181D #F6F7F8 #321E14 #FFFFFF 􀉙􀉚'
  'Starbucks Brand' 'starbucks #00704A #003221 #16181D #DCDFE5 #0C241F #FFFFFF 􀉛􀉜'
  'Starling Bank Brand' 'starling #50FFEB #34A699 #16181D #16181D #245855 #000000 􀉝􀉞'
  'STORES Brand' 'stores #0066FF #002E73 #16181D #F6F7F8 #0C2244 #FFFFFF 􀉟􀉠'
  'Stripe Brand' 'stripe #635BFF #2D2973 #414552 #FCFCFC #383861 #FFFFFF 􀉡􀉢'
  'Studio Brand' 'studio #0072EB #00336A #16181D #FFFFFF #0C243F #000000 􀉣􀉤'
  'Supabase Brand' 'supabase #72E3AD #4A9470 #16181D #16181D #2D5043 #000000 􀉥􀉦'
  'Superhuman Brand' 'superhuman #5840FF #281D73 #16181D #E2E4E9 #1E1A44 #FFFFFF 􀉧􀉨􀉩'
  'SurveyCake Brand' 'surveycake #3DBA90 #309170 #16181D #16181D #224E42 #000000 􀉪􀉫􀉬'
  'Blind Brand' 'teamblind #DA3238 #621619 #16181D #FCFCFD #38171B #FFFFFF 􀉭􀉮'
  'Tesla Brand' 'tesla #3E6AE1 #1C3065 #171A20 #F8F9FA #19243F #FFFFFF 􀉯􀉰'
  'The Verge Brand' 'theverge #5200FF #250073 #16181D #C5C9D3 #1D0D44 #FFFFFF 􀉱􀉲􀉳'
  'TMAP Mobility Brand' 'tmap #0064FF #002D73 #16181D #F6F7F8 #0C2144 #FFFFFF 􀉴􀉵'
  'Together AI Brand' 'together.ai #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀉶􀉷􀉸'
  'Toss Securities Brand' 'toss-securities #589AF8 #4E87DA #1A1F29 #1A1F29 #314E79 #000000 􀉹􀉺􀉻'
  'Toss Brand' 'toss #0064FF #002D73 #191F28 #F5F6F9 #0E254A #FFFFFF 􀉼􀉽􀉾'
  'Toss Bank Brand' 'tossbank #0064FF #002D73 #212529 #F5F6F7 #12294A #FFFFFF 􀉿􀊀􀊁'
  'Trainline Brand' 'trainline #00A88F #00947E #16181D #16181D #0C5049 #000000 􀊂􀊃􀊄'
  'Tumblbug Brand' 'tumblbug #FD5744 #D24838 #000000 #000000 #5E2019 #000000 􀊅􀊆􀊇􀊈'
  'TVING Brand' 'tving #EB0027 #6A0012 #FFFFFF #FFFFFF #BC8C94 #FFFFFF 􀊉􀊊'
  'Twilio Brand' 'twilio #EC112B #6A0813 #16181D #FFFFFF #3C1119 #000000 􀊋􀊌'
  'Twitch Brand' 'twitch #9146FF #411F73 #16181D #FCFCFD #291B44 #FFFFFF 􀊍􀊎'
  'Uber Brand' 'uber #292929 #121212 #000000 #919191 #080808 #FFFFFF 􀊏􀊐􀊑􀊒'
  'Ubie Brand' 'ubie #3959CC #1A285C #16181D #DCDFE5 #181F39 #FFFFFF 􀊓􀊔􀊕'
  'Uniqlo Brand' 'uniqlo #E31219 #66080B #16181D #F9FAFB #3A1115 #FFFFFF 􀊖􀊗'
  'Upstage Brand' 'upstage #5B52FF #292573 #16181D #F1F2F4 #1F1E44 #FFFFFF 􀊘􀊙'
  'U.S. Web Design System Brand' 'uswds #005EA2 #002A49 #1B1B1B #D5D5D5 #0F2230 #FFFFFF 􀊚􀊛􀊜'
  'Vercel Brand' 'vercel #292929 #121212 #171717 #8F8F8F #151515 #FFFFFF 􀊝􀊞􀊟'
  'Vocus Brand' 'vocus #FF485A #EB4253 #16181D #16181D #762B35 #000000 􀊠􀊡􀊢'
  'VoltAgent Brand' 'voltagent #22C55E #1B9A49 #16181D #16181D #185231 #000000 􀊣􀊤'
  'VUNO Brand' 'vuno #40E2DE #2A9390 #16181D #16181D #1F4F51 #000000 􀊥􀊦'
  'Wanted Brand' 'wanted #0066FF #002E73 #16181D #F6F7F8 #0C2244 #FFFFFF 􀊧􀊨􀊩'
  'Wantedly Brand' 'wantedly #21BDDB #1A93AB #16181D #16181D #18505D #000000 􀊪􀊫􀊬'
  'Warp Brand' 'warp #01A4FF #0188D4 #16181D #16181D #0C4A6F #000000 􀊭􀊮􀊯'
  'Watcha Brand' 'watcha #F95680 #E55076 #16181D #16181D #733145 #000000 􀊰􀊱'
  'W Concept Brand' 'wconcept #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀊲􀊳􀊴'
  'Webflow Brand' 'webflow #146EF5 #09316E #16181D #FFFFFF #102342 #FFFFFF 􀊵􀊶􀊷􀊸'
  'Wise Brand' 'wise #9FE870 #679749 #16181D #16181D #3B5131 #000000 􀊹􀊺􀊻'
  'Wisetracker Brand' 'wisetracker #FF8D08 #C76E06 #16181D #16181D #663F13 #000000 􀊼􀊽'
  'Woori Bank Brand' 'wooribank #0067AC #002E4D #000000 #E0E0E0 #001523 #FFFFFF 􀊾􀊿'
  'Workday Brand' 'workday #0057AE #00274E #16181D #CBCED7 #0C1F33 #FFFFFF 􀋀􀋁'
  'xAI Brand' 'x.ai #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀋂􀋃'
  'Xiaohongshu Brand' 'xiaohongshu #FF4D65 #EB475D #16181D #16181D #762D3A #000000 􀋄􀋅􀋆􀋇'
  'Yogiyo Brand' 'yogiyo #E60049 #670021 #16181D #F9FAFB #3B0D1F #FFFFFF 􀋈􀋉􀋊􀋋'
  'Yourator Brand' 'yourator #0063D1 #002D5E #16181D #E5E7EB #0C213A #FFFFFF 􀋌􀋍􀋎'
  'Zapier Brand' 'zapier #FF4F00 #EB4900 #16181D #16181D #762E10 #000000 􀋏􀋐􀋑􀋒'
  'ZEPETO Brand' 'zepeto #5C46FF #291F73 #16181D #E8E9ED #1F1B44 #FFFFFF 􀋓􀋔'
  'Zoom Brand' 'zoom #0B5CFF #052973 #16181D #EEEFF2 #0E2044 #FFFFFF 􀋕􀋖􀋗􀋘'
  'ZOZOTOWN Brand' 'zozotown #292929 #121212 #16181D #8890A5 #141518 #FFFFFF 􀋙􀋚􀋛􀋜'
)

# iTerm2는 세션을 열 때 프로필 이름을 ITERM_PROFILE에 넣는다. 열린 세션의 프로필을 바꿔도
# 이 값은 그대로라 새 탭·창부터 반영된다.
[[ -n ${ITERM_PROFILE:-} && -n ${_brand_profiles[$ITERM_PROFILE]-} ]] || return 0

autoload -Uz add-zsh-hook

typeset -ga _brand_theme=("${(@s: :)_brand_profiles[$ITERM_PROFILE]}")
typeset -g  _brand_dir_content=""
typeset -gA _brand_gradient_cache=()

# 터미널은 그라데이션을 모른다 — 글자마다 배경색을 조금씩 바꿔 흉내낸다.
# 앞의 lead 글자(왼쪽 여백·로고 조각·로고 뒤 한 칸)는 시작색 한 가지로 칠해 로고 둘레가 띠와
# 이어지게 하고, 그 뒤 경로 글자에만 그라데이션을 입힌다. lead 글자색은 lead_fg — iTerm2 GPU
# 렌더러는 로고를 이 글자색으로 칠하므로 띠 위에서 대비가 가장 큰 색이어야 로고가 또렷하다.
# 결과를 REPLY에 넣는다. 예전에는 호출부가 $( )로 감쌌는데, 그러면 함수가 서브셸에서
# 돌아 캐시에 쓴 값이 부모로 돌아오지 않는다 — 캐시가 한 번도 히트하지 않았고
# 프롬프트를 그릴 때마다 fork + 전체 재계산이었다.
_brand_gradient() {
  local text=$1 start=$2 end=$3 dark_fg=$4 light_fg=$5 lead_fg=$7
  local -i lead=$6 n=${#text} i
  local -i span=$(( n - lead ))
  local -i sr=$((16#${start[2,3]})) sg=$((16#${start[4,5]})) sb=$((16#${start[6,7]}))
  local -i er=$((16#${end[2,3]}))   eg=$((16#${end[4,5]}))   eb=$((16#${end[6,7]}))
  local out="" previous_fg="" fg
  for (( i = 1; i <= n; i++ )); do
    local -F t=0
    (( i > lead && span > 1 )) && t=$(( (i - lead - 1.0) / (span - 1.0) ))
    local -i r=$(( sr + (er - sr) * t )) g=$(( sg + (eg - sg) * t )) b=$(( sb + (eb - sb) * t ))
    if (( i <= lead )); then
      fg=$lead_fg
    else
      # 배경이 어두워지는 지점에서 글자색을 뒤집지 않으면 경로 끝이 안 읽힌다.
      local -i luma=$(( (r * 299 + g * 587 + b * 114) / 1000 ))
      (( luma > 140 )) && fg=$dark_fg || fg=$light_fg
    fi
    printf -v out '%s%%K{#%02X%02X%02X}' "$out" $r $g $b
    [[ $fg == $previous_fg ]] || { printf -v out '%s%%F{%s}' "$out" "$fg"; previous_fg=$fg }
    out+="${text[i]}"
  done
  REPLY=$out
}

# 경로 세그먼트 내용은 디렉터리가 바뀔 때 한 번만 굽는다. 프롬프트는 변수만 참조하므로 fork가 없다.
# 경로는 p10k의 P9K_CONTENT에서 받지 않는다 — 두 번째 프롬프트부터 '이미 확장된' 값이
# 들어와 우리가 넣은 %K{...} 위에 색이 또 입혀졌다 (프롬프트에 리터럴 %K{ 가 찍혔다).
_brand_apply() {
  emulate -L zsh
  local icon=$_brand_theme[8]
  # 왼쪽 여백을 직접 넣는다. p10k의 여백은 세그먼트 배경(끝색)으로 칠해져, 시작색인 로고 칸과
  # 경계가 져 로고 둘레만 밝은 조각처럼 떠 보였다. p10k 쪽 왼쪽 여백은 아래에서 비운다.
  local lead=" ${icon:+$icon }"
  local text="$lead${(%):-%~}"
  if [[ -z ${_brand_gradient_cache[$text]} ]]; then
    _brand_gradient "$text" $_brand_theme[2] $_brand_theme[3] $_brand_theme[4] $_brand_theme[5] \
                    ${#lead} $_brand_theme[7]
    _brand_gradient_cache[$text]=$REPLY
  fi
  _brand_dir_content=${_brand_gradient_cache[$text]}
}
add-zsh-hook chpwd _brand_apply
_brand_apply

# p10k 설정은 첫 프롬프트 직전에 한 번 넣고 훅에서 빠진다. 플러그인 관리자(oh-my-zsh·zinit·antigen)는
# 이 파일을 ~/.p10k.zsh 보다 먼저 source 하는데, .p10k.zsh는 시작하자마자 POWERLEVEL9K_* 를 전부
# 지워서 source 시점에 넣으면 흔적 없이 사라졌다. p10k는 설정을 precmd 맨 끝(_p9k_precmd)에서
# 읽으므로, 그보다 앞에 도는 이 훅이 넣은 값은 .zshrc 어디서 source 했든 똑같이 반영된다.
_brand_p10k() {
  emulate -L zsh
  add-zsh-hook -d precmd _brand_p10k

  # 모든 폴더를 BRAND 클래스 하나로 칠한다. 이 프로필에서는 사용자의 다른 dir 클래스를 쓰지 않는다.
  typeset -ga POWERLEVEL9K_DIR_CLASSES=('*' BRAND '')
  local suffix
  # DIR_SHOW_WRITABLE=v3면 쓰기불가/없는 경로는 접미사가 붙은 별도 클래스가 된다.
  # 안 채우면 그 경우에만 브랜드 색이 사라진다.
  for suffix in '' _NOT_WRITABLE _NON_EXISTENT; do
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_BACKGROUND=$_brand_theme[3]
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_FOREGROUND=$_brand_theme[4]
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_SHORTENED_FOREGROUND=$_brand_theme[6]
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_ANCHOR_FOREGROUND=$_brand_theme[4]
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_ANCHOR_BOLD=true
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_VISUAL_IDENTIFIER_EXPANSION=''
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_CONTENT_EXPANSION='${_brand_dir_content}'
    # 왼쪽 여백은 내용에 시작색으로 직접 넣었다 (위 _brand_apply).
    typeset -g POWERLEVEL9K_DIR_BRAND${suffix}_LEFT_LEFT_WHITESPACE=''
  done

  # 로고가 경로 세그먼트 맨 앞에 나오므로 OS 아이콘 칸은 뺀다 — 같은 자리에 아이콘이 둘일 필요가 없다.
  # 사용자의 배열을 통째로 바꾸지 않고 os_icon만 뺀다.
  if [[ -n $_brand_theme[8] ]]; then
    typeset -ga POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=("${(@)POWERLEVEL9K_LEFT_PROMPT_ELEMENTS:#os_icon}")
  fi
}
# 맨 앞에 건다. p10k를 먼저 불러온 .zshrc에서는 _p9k_precmd가 이미 걸려 있어, add-zsh-hook처럼
# 뒤에 붙이면 p10k가 첫 프롬프트를 이 설정 없이 그렸다.
typeset -ga precmd_functions=(_brand_p10k ${precmd_functions:#_brand_p10k})
