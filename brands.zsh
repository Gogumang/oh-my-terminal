# ─────────────────────────────────────────────────────────────────────────────
#  이 파일은 oh-my-terminal 빌더가 생성한다. 직접 고치지 말고 brands/*.yaml을 고칠 것.
#  순수 zsh다 — python·curl 등 외부 명령에 의존하지 않는다.
#  ~/.p10k.zsh 를 source 한 '뒤에' 이 파일을 source 해야 한다.
# ─────────────────────────────────────────────────────────────────────────────

autoload -Uz add-zsh-hook

typeset -g  _brand_dir_content=""
typeset -gA _brand_gradient_cache=()

# 터미널은 그라데이션을 모른다 — 글자마다 배경색을 조금씩 바꿔 흉내낸다.
# 결과를 REPLY에 넣는다. 예전에는 호출부가 $( )로 감쌌는데, 그러면 함수가 서브셸에서
# 돌아 캐시에 쓴 값이 부모로 돌아오지 않는다 — 캐시가 한 번도 히트하지 않았고
# 프롬프트를 그릴 때마다 fork + 전체 재계산이었다.
_brand_gradient() {
  local text=$1 start=$2 end=$3 dark_fg=$4 light_fg=$5
  local -i n=${#text} i
  local -i sr=$((16#${start[2,3]})) sg=$((16#${start[4,5]})) sb=$((16#${start[6,7]}))
  local -i er=$((16#${end[2,3]}))   eg=$((16#${end[4,5]}))   eb=$((16#${end[6,7]}))
  local out="" previous_fg=""
  for (( i = 1; i <= n; i++ )); do
    local -F t=$(( n > 1 ? (i - 1.0) / (n - 1.0) : 0 ))
    local -i r=$(( sr + (er - sr) * t )) g=$(( sg + (eg - sg) * t )) b=$(( sb + (eb - sb) * t ))
    # 배경이 어두워지는 지점에서 글자색을 뒤집지 않으면 경로 끝이 안 읽힌다.
    local -i luma=$(( (r * 299 + g * 587 + b * 114) / 1000 ))
    local fg=$(( luma > 140 ? 1 : 2 ))
    fg=${${fg/1/$dark_fg}/2/$light_fg}
    printf -v out '%s%%K{#%02X%02X%02X}' "$out" $r $g $b
    [[ $fg == $previous_fg ]] || { printf -v out '%s%%F{%s}' "$out" "$fg"; previous_fg=$fg }
    out+="${text[i]}"
  done
  REPLY=$out
}

# 디렉터리가 바뀔 때 한 번만 굽는다. 프롬프트는 변수만 참조하므로 fork가 없다.
# 경로는 p10k의 P9K_CONTENT에서 받지 않는다 — 두 번째 프롬프트부터 '이미 확장된' 값이
# 들어와 우리가 넣은 %K{...} 위에 색이 또 입혀졌다 (프롬프트에 리터럴 %K{ 가 찍혔다).
_brand_apply() {
  local start end dark light icon
  case $PWD in
    ${HOME}/Desktop/104(|/*)) start='#FF9100'; end='#E08000'; dark='#292929'; light='#292929'; icon=' ' ;;
    ${HOME}/Desktop/17live(|/*)) start='#FF7890'; end='#E0697E'; dark='#292929'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/29cm(|/*)) start='#292929'; end='#121212'; dark='#000000'; light='#919191'; icon=' ' ;;
    ${HOME}/Desktop/3o3(|/*)) start='#0C64E6'; end='#052D67'; dark='#16181D'; light='#EEEFF2'; icon=' ' ;;
    ${HOME}/Desktop/42dot(|/*)) start='#8A82FB'; end='#7F77E7'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/8percent(|/*)) start='#458EF1'; end='#3F82DE'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/91app(|/*)) start='#061C3D'; end='#030D1B'; dark='#061C3D'; light='#3D83EC'; icon=' ' ;;
    ${HOME}/Desktop/abema(|/*)) start='#DDAA00'; end='#C29600'; dark='#333333'; light='#E6E6E6'; icon=' ' ;;
    ${HOME}/Desktop/ably(|/*)) start='#FF6573'; end='#E05965'; dark='#1F1F1F'; light='#1F1F1F'; icon=' ' ;;
    ${HOME}/Desktop/acer(|/*)) start='#80C343'; end='#649834'; dark='#222222'; light='#222222'; icon=' ' ;;
    ${HOME}/Desktop/adobe(|/*)) start='#EB1000'; end='#6A0700'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/airbnb(|/*)) start='#FF617D'; end='#EB5973'; dark='#222222'; light='#222222'; icon=' ' ;;
    ${HOME}/Desktop/airtable(|/*)) start='#FCB400'; end='#B58200'; dark='#181D26'; light='#181D26'; icon=' ' ;;
    ${HOME}/Desktop/amazingtalker(|/*)) start='#02CAB9'; end='#019185'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/appier(|/*)) start='#1D2EFF'; end='#0D1573'; dark='#101130'; light='#C8C9ED'; icon=' ' ;;
    ${HOME}/Desktop/apple(|/*)) start='#292929'; end='#121212'; dark='#1D1D1F'; light='#909097'; icon=' ' ;;
    ${HOME}/Desktop/asana(|/*)) start='#F06A6A'; end='#D35D5D'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/asleep(|/*)) start='#1668FC'; end='#0A2F71'; dark='#16181D'; light='#F9FAFB'; icon=' ' ;;
    ${HOME}/Desktop/baemin(|/*)) start='#0CEFD3'; end='#089B89'; dark='#222222'; light='#222222'; icon=' ' ;;
    ${HOME}/Desktop/bahamut(|/*)) start='#11AAC1'; end='#0E8DA0'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/banksalad(|/*)) start='#13BD7E'; end='#0F9362'; dark='#111111'; light='#111111'; icon=' ' ;;
    ${HOME}/Desktop/barogo(|/*)) start='#FA5014'; end='#E64A12'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/bbc(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/beusable(|/*)) start='#EC0047'; end='#6A0020'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/bigin(|/*)) start='#0066EB'; end='#002E6A'; dark='#16181D'; light='#F1F2F4'; icon=' ' ;;
    ${HOME}/Desktop/bilibili(|/*)) start='#FB7299'; end='#D05F7F'; dark='#18191C'; light='#18191C'; icon=' ' ;;
    ${HOME}/Desktop/bithumb(|/*)) start='#1C2028'; end='#0D0E12'; dark='#FFFFFF'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/bmw(|/*)) start='#1C69D4'; end='#0D2F5F'; dark='#414141'; light='#EEEEEE'; icon=' ' ;;
    ${HOME}/Desktop/brandi(|/*)) start='#1E1E1E'; end='#0D0D0D'; dark='#16181D'; light='#7D869C'; icon=' ' ;;
    ${HOME}/Desktop/buzzvil(|/*)) start='#F55549'; end='#E14E43'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/cakeresume(|/*)) start='#13AB67'; end='#0F8550'; dark='#000000'; light='#000000'; icon=' ' ;;
    ${HOME}/Desktop/cal(|/*)) start='#192339'; end='#0B101A'; dark='#242424'; light='#8A8A8A'; icon=' ' ;;
    ${HOME}/Desktop/cgv(|/*)) start='#292929'; end='#121212'; dark='#121212'; light='#8F8F8F'; icon=' ' ;;
    ${HOME}/Desktop/channeltalk(|/*)) start='#242428'; end='#101012'; dark='#000000'; light='#8C8C8C'; icon=' ' ;;
    ${HOME}/Desktop/china-airlines(|/*)) start='#23569D'; end='#102747'; dark='#16181D'; light='#C8CCD5'; icon=' ' ;;
    ${HOME}/Desktop/cjonstyle(|/*)) start='#640FAF'; end='#2D074F'; dark='#16181D'; light='#AEB3C1'; icon=' ' ;;
    ${HOME}/Desktop/classting(|/*)) start='#00DCA5'; end='#00CB98'; dark='#424242'; light='#424242'; icon=' ' ;;
    ${HOME}/Desktop/claude(|/*)) start='#CE7152'; end='#BD684B'; dark='#141413'; light='#141413'; icon=' ' ;;
    ${HOME}/Desktop/clickhouse(|/*)) start='#FAFF69'; end='#A3A644'; dark='#373737'; light='#DFDFDF'; icon=' ' ;;
    ${HOME}/Desktop/cloudflare(|/*)) start='#F6821F'; end='#CC6C1A'; dark='#1D1F20'; light='#1D1F20'; icon=' ' ;;
    ${HOME}/Desktop/codeit(|/*)) start='#9933FF'; end='#451773'; dark='#16181D'; light='#F6F7F8'; icon=' ' ;;
    ${HOME}/Desktop/coinbase(|/*)) start='#0052FF'; end='#002573'; dark='#0A0B0D'; light='#E4E6EA'; icon=' ' ;;
    ${HOME}/Desktop/coinone(|/*)) start='#006BD6'; end='#003060'; dark='#17181B'; light='#F1F1F3'; icon=' ' ;;
    ${HOME}/Desktop/composio(|/*)) start='#5054EF'; end='#24266C'; dark='#FFFFFF'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/cookpad(|/*)) start='#FF9933'; end='#B86E25'; dark='#0F0F0F'; light='#0F0F0F'; icon=' ' ;;
    ${HOME}/Desktop/coupang(|/*)) start='#292929'; end='#121212'; dark='#000000'; light='#919191'; icon=' ' ;;
    ${HOME}/Desktop/cursor(|/*)) start='#26251E'; end='#11110D'; dark='#16181D'; light='#828BA0'; icon=' ' ;;
    ${HOME}/Desktop/cybozu(|/*)) start='#139CB7'; end='#1190A8'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/databricks(|/*)) start='#FF4835'; end='#EB4331'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/dcard(|/*)) start='#0086FF'; end='#0076E0'; dark='#000000'; light='#000000'; icon=' ' ;;
    ${HOME}/Desktop/dealicious(|/*)) start='#001B52'; end='#000C25'; dark='#16181D'; light='#7F889E'; icon=' ' ;;
    ${HOME}/Desktop/deliveroo(|/*)) start='#00CCBC'; end='#009387'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/dell(|/*)) start='#0076CE'; end='#00355D'; dark='#16181D'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/discord(|/*)) start='#5865F2'; end='#282D6D'; dark='#16181D'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/dji(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/dmm(|/*)) start='#94BCFF'; end='#6B87B8'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/doordash(|/*)) start='#EB1700'; end='#6A0A00'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/drdiary(|/*)) start='#3EAEFF'; end='#3088C7'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/drnow(|/*)) start='#FF8D00'; end='#C76E00'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/dropbox(|/*)) start='#0061FE'; end='#002C72'; dark='#16181D'; light='#F1F2F4'; icon=' ' ;;
    ${HOME}/Desktop/duolingo(|/*)) start='#61E002'; end='#55C502'; dark='#414141'; light='#4B4B4B'; icon=' ' ;;
    ${HOME}/Desktop/easywallet(|/*)) start='#007BC6'; end='#003759'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/elastic(|/*)) start='#0B64DD'; end='#052D63'; dark='#1D2A3E'; light='#E6EBF3'; icon=' ' ;;
    ${HOME}/Desktop/elevenlabs(|/*)) start='#292929'; end='#121212'; dark='#000000'; light='#919191'; icon=' ' ;;
    ${HOME}/Desktop/esunbank(|/*)) start='#00A19B'; end='#00948F'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/expo(|/*)) start='#292929'; end='#121212'; dark='#1C2024'; light='#8593A0'; icon=' ' ;;
    ${HOME}/Desktop/farfetch(|/*)) start='#222222'; end='#0F0F0F'; dark='#16181D'; light='#828BA0'; icon=' ' ;;
    ${HOME}/Desktop/fastcampus(|/*)) start='#EC0332'; end='#6A0116'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/ferrari(|/*)) start='#DA291C'; end='#62120D'; dark='#181818'; light='#F8F8F8'; icon=' ' ;;
    ${HOME}/Desktop/figma(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/fitpet(|/*)) start='#0050FF'; end='#002473'; dark='#16181D'; light='#E2E4E9'; icon=' ' ;;
    ${HOME}/Desktop/framer(|/*)) start='#0055FF'; end='#002673'; dark='#FFFFFF'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/freee(|/*)) start='#2864F0'; end='#122D6C'; dark='#16181D'; light='#F3F4F6'; icon=' ' ;;
    ${HOME}/Desktop/frip(|/*)) start='#7A29FA'; end='#371270'; dark='#16181D'; light='#DFE1E7'; icon=' ' ;;
    ${HOME}/Desktop/fubon(|/*)) start='#00A3D5'; end='#008FBC'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/fugle(|/*)) start='#F4AF1C'; end='#B07E14'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/funnow(|/*)) start='#FF5537'; end='#EB4E33'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/gangnamunni(|/*)) start='#D54300'; end='#601E00'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/gaudiolab(|/*)) start='#00B7FF'; end='#008FC7'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/gaudiy(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/genie(|/*)) start='#FB5475'; end='#E64D6C'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/github(|/*)) start='#0969DA'; end='#042F62'; dark='#16181D'; light='#EEEFF2'; icon=' ' ;;
    ${HOME}/Desktop/gitlab(|/*)) start='#1F75CB'; end='#0E355B'; dark='#16181D'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/gogoro(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/google(|/*)) start='#1A73E8'; end='#0C3468'; dark='#3C4043'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/goorm(|/*)) start='#2A72E5'; end='#133367'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/govuk(|/*)) start='#1D70B8'; end='#0D3253'; dark='#0B0C0C'; light='#F0F2F2'; icon=' ' ;;
    ${HOME}/Desktop/greencar(|/*)) start='#00C88C'; end='#009C6D'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/greenvines(|/*)) start='#002D18'; end='#00140B'; dark='#16181D'; light='#858EA3'; icon=' ' ;;
    ${HOME}/Desktop/hackle(|/*)) start='#0065FF'; end='#002D73'; dark='#16181D'; light='#F6F7F8'; icon=' ' ;;
    ${HOME}/Desktop/hahow(|/*)) start='#00CCB4'; end='#009382'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/hana(|/*)) start='#00A39F'; end='#008F8C'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/hashicorp(|/*)) start='#1060FF'; end='#072B73'; dark='#3B3D45'; light='#F2F2F3'; icon=' ' ;;
    ${HOME}/Desktop/headspace(|/*)) start='#0061EF'; end='#002C6C'; dark='#16181D'; light='#EEEFF2'; icon=' ' ;;
    ${HOME}/Desktop/hp(|/*)) start='#0096D6'; end='#008AC5'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/hubspot(|/*)) start='#FF5714'; end='#EB5013'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/humanscape(|/*)) start='#00ADF7'; end='#0090CD'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/hwahae(|/*)) start='#00D5CE'; end='#009994'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/hyundai(|/*)) start='#002C5F'; end='#00142B'; dark='#16181D'; light='#8E96A9'; icon=' ' ;;
    ${HOME}/Desktop/ibm(|/*)) start='#0F62FE'; end='#072C72'; dark='#161616'; light='#F4F4F4'; icon=' ' ;;
    ${HOME}/Desktop/idus(|/*)) start='#EF7014'; end='#D26312'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/igaworks(|/*)) start='#1A1D23'; end='#0C0D10'; dark='#16181D'; light='#7D869C'; icon=' ' ;;
    ${HOME}/Desktop/iicombined(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/inflearn(|/*)) start='#00C471'; end='#009958'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/instacart(|/*)) start='#108910'; end='#073E07'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/intercom(|/*)) start='#1461FA'; end='#092B70'; dark='#16181D'; light='#F1F2F4'; icon=' ' ;;
    ${HOME}/Desktop/ipassmoney(|/*)) start='#53B232'; end='#459429'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/jandi(|/*)) start='#00C473'; end='#00995A'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/kakao(|/*)) start='#FEE500'; end='#B7A500'; dark='#333333'; light='#333333'; icon=' ' ;;
    ${HOME}/Desktop/kakaobank(|/*)) start='#FFE300'; end='#8C7D00'; dark='#000000'; light='#000000'; icon=' ' ;;
    ${HOME}/Desktop/kakaogames(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/kakaot(|/*)) start='#FEE500'; end='#A59500'; dark='#191919'; light='#191919'; icon=' ' ;;
    ${HOME}/Desktop/karrot(|/*)) start='#FF7E36'; end='#E06F30'; dark='#212124'; light='#212124'; icon=' ' ;;
    ${HOME}/Desktop/kcd(|/*)) start='#2D91FF'; end='#2985EB'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/kdan(|/*)) start='#00DC87'; end='#009E61'; dark='#191919'; light='#191919'; icon=' ' ;;
    ${HOME}/Desktop/kia(|/*)) start='#0B2D46'; end='#051420'; dark='#16181D'; light='#8B93A7'; icon=' ' ;;
    ${HOME}/Desktop/kraken(|/*)) start='#5741D9'; end='#271D62'; dark='#101114'; light='#D5D7DD'; icon=' ' ;;
    ${HOME}/Desktop/kream(|/*)) start='#292929'; end='#121212'; dark='#222222'; light='#909090'; icon=' ' ;;
    ${HOME}/Desktop/kurly(|/*)) start='#5F0080'; end='#2B003A'; dark='#333333'; light='#A1A1A1'; icon=' ' ;;
    ${HOME}/Desktop/kyobobook(|/*)) start='#5055B1'; end='#242650'; dark='#16181D'; light='#D6D9E0'; icon=' ' ;;
    ${HOME}/Desktop/lablup(|/*)) start='#28AB6C'; end='#23965F'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/lamborghini(|/*)) start='#FFC000'; end='#B88A00'; dark='#202020'; light='#202020'; icon=' ' ;;
    ${HOME}/Desktop/laundrygo(|/*)) start='#0AC290'; end='#089770'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/layerx(|/*)) start='#534DFF'; end='#252373'; dark='#16181D'; light='#EBECF0'; icon=' ' ;;
    ${HOME}/Desktop/lemonbase(|/*)) start='#4695F7'; end='#3D83D9'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/lezhin(|/*)) start='#EB0014'; end='#6A0009'; dark='#16181D'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/likelion(|/*)) start='#FF6D14'; end='#EB6413'; dark='#222222'; light='#222222'; icon=' ' ;;
    ${HOME}/Desktop/line(|/*)) start='#06C755'; end='#048F3D'; dark='#000000'; light='#000000'; icon=' ' ;;
    ${HOME}/Desktop/linear.app(|/*)) start='#5E6AD2'; end='#2A305E'; dark='#F7F8F8'; light='#FAFAFA'; icon=' ' ;;
    ${HOME}/Desktop/loom(|/*)) start='#1868DB'; end='#0B2F63'; dark='#101214'; light='#EEF0F2'; icon=' ' ;;
    ${HOME}/Desktop/lunit(|/*)) start='#1032CF'; end='#07165D'; dark='#16181D'; light='#B7BCC8'; icon=' ' ;;
    ${HOME}/Desktop/mailchimp(|/*)) start='#FFE01B'; end='#A69212'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/mastercard(|/*)) start='#EB001B'; end='#6A000C'; dark='#141413'; light='#FEFEFE'; icon=' ' ;;
    ${HOME}/Desktop/maum-ai(|/*)) start='#4262FF'; end='#1E2C73'; dark='#16181D'; light='#F9FAFB'; icon=' ' ;;
    ${HOME}/Desktop/melon(|/*)) start='#00CD3C'; end='#00A02F'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/mercury(|/*)) start='#5266EB'; end='#252E6A'; dark='#16181D'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/meta(|/*)) start='#0064E0'; end='#002D65'; dark='#16181D'; light='#EBECF0'; icon=' ' ;;
    ${HOME}/Desktop/mildang(|/*)) start='#00B29D'; end='#009482'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/minimax(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/mintlify(|/*)) start='#0FA682'; end='#0D9272'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/miro(|/*)) start='#FDE050'; end='#A49234'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/mistral.ai(|/*)) start='#292929'; end='#121212'; dark='#000000'; light='#919191'; icon=' ' ;;
    ${HOME}/Desktop/mixi(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/modusign(|/*)) start='#FED05F'; end='#A5873E'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/moin(|/*)) start='#148CFF'; end='#1381EB'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/momoshop(|/*)) start='#D62872'; end='#601233'; dark='#404040'; light='#FAFAFA'; icon=' ' ;;
    ${HOME}/Desktop/money-forward(|/*)) start='#2971E7'; end='#123368'; dark='#333333'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/mongodb(|/*)) start='#00ED64'; end='#009A41'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/monzo(|/*)) start='#FF4F40'; end='#EB493B'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/moreh(|/*)) start='#FF5700'; end='#EB5000'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/moze(|/*)) start='#FF4A89'; end='#EB447E'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/muji(|/*)) start='#7F0019'; end='#39000B'; dark='#333333'; light='#A8A8A8'; icon=' ' ;;
    ${HOME}/Desktop/musinsa(|/*)) start='#292929'; end='#121212'; dark='#000000'; light='#919191'; icon=' ' ;;
    ${HOME}/Desktop/mustit(|/*)) start='#D00000'; end='#5E0000'; dark='#222222'; light='#E6E6E6'; icon=' ' ;;
    ${HOME}/Desktop/mynavi(|/*)) start='#0071BB'; end='#003354'; dark='#16181D'; light='#F1F2F4'; icon=' ' ;;
    ${HOME}/Desktop/myrealtrip(|/*)) start='#2B96ED'; end='#288ADA'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/naver(|/*)) start='#03C75A'; end='#029B46'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/naverwebtoon(|/*)) start='#00DC64'; end='#008F41'; dark='#000000'; light='#000000'; icon=' ' ;;
    ${HOME}/Desktop/ncsoft(|/*)) start='#7234E0'; end='#331765'; dark='#16181D'; light='#D6D9E0'; icon=' ' ;;
    ${HOME}/Desktop/netflix(|/*)) start='#E50914'; end='#670409'; dark='#FFFFFF'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/nexon(|/*)) start='#00DE5A'; end='#00A041'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/nhn(|/*)) start='#212126'; end='#0F0F11'; dark='#36363D'; light='#878795'; icon=' ' ;;
    ${HOME}/Desktop/nike(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/nintendo(|/*)) start='#E60012'; end='#670008'; dark='#16181D'; light='#F9FAFB'; icon=' ' ;;
    ${HOME}/Desktop/nol(|/*)) start='#3549FF'; end='#182173'; dark='#F5F6F9'; light='#F5F6F9'; icon=' ' ;;
    ${HOME}/Desktop/nota(|/*)) start='#3264F0'; end='#172D6C'; dark='#16181D'; light='#F3F4F6'; icon=' ' ;;
    ${HOME}/Desktop/note(|/*)) start='#41C9B4'; end='#2F9182'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/notion(|/*)) start='#0075DE'; end='#003564'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/nvidia(|/*)) start='#76B900'; end='#5C9000'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/oliveyoung(|/*)) start='#82DC28'; end='#558F1A'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/ollama(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/openai(|/*)) start='#10A37F'; end='#0F9675'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/opencode.ai(|/*)) start='#292929'; end='#121212'; dark='#201D1D'; light='#998F8F'; icon=' ' ;;
    ${HOME}/Desktop/openpoint(|/*)) start='#8081FF'; end='#7677EB'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/patternfly(|/*)) start='#0066CC'; end='#002E5C'; dark='#151515'; light='#E9E9E9'; icon=' ' ;;
    ${HOME}/Desktop/payhere(|/*)) start='#008CFF'; end='#0081EB'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/paypal(|/*)) start='#002991'; end='#001241'; dark='#16181D'; light='#979EB0'; icon=' ' ;;
    ${HOME}/Desktop/pega(|/*)) start='#1A3A5C'; end='#0C1A29'; dark='#050505'; light='#A3A3A3'; icon=' ' ;;
    ${HOME}/Desktop/peoplefund(|/*)) start='#FFC32D'; end='#A67F1D'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/pepabo(|/*)) start='#1C71BA'; end='#0D3354'; dark='#16181D'; light='#F1F2F4'; icon=' ' ;;
    ${HOME}/Desktop/perplexity(|/*)) start='#20808D'; end='#0E3A3F'; dark='#16181D'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/pinkoi(|/*)) start='#FF595A'; end='#E04E4F'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/pinterest(|/*)) start='#E60023'; end='#670010'; dark='#16181D'; light='#F9FAFB'; icon=' ' ;;
    ${HOME}/Desktop/pixiv(|/*)) start='#0096FA'; end='#0084DC'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/portone(|/*)) start='#FC6B2D'; end='#DE5E28'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/posthog(|/*)) start='#1D4AFF'; end='#0D2173'; dark='#4D4F46'; light='#DFE0DC'; icon=' ' ;;
    ${HOME}/Desktop/postype(|/*)) start='#F56370'; end='#D85763'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/pozalabs(|/*)) start='#ABA1FA'; end='#857EC3'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/quotabook(|/*)) start='#00E8C5'; end='#00D5B5'; dark='#4C4C4C'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/rakuten(|/*)) start='#BF0000'; end='#560000'; dark='#16181D'; light='#D4D7DE'; icon=' ' ;;
    ${HOME}/Desktop/raycast(|/*)) start='#FF6363'; end='#E05757'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/readmoo(|/*)) start='#40C8F7'; end='#2E90B2'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/rebellions(|/*)) start='#52F756'; end='#35A138'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/recruit(|/*)) start='#0065BD'; end='#002D55'; dark='#2D3133'; light='#E1E3E4'; icon=' ' ;;
    ${HOME}/Desktop/reddit(|/*)) start='#D63A00'; end='#601A00'; dark='#333D42'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/remember(|/*)) start='#292929'; end='#121212'; dark='#222222'; light='#909090'; icon=' ' ;;
    ${HOME}/Desktop/renault(|/*)) start='#FFCC00'; end='#A68500'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/replicate(|/*)) start='#FC7676'; end='#D16262'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/resend(|/*)) start='#3DB9FF'; end='#38AAEB'; dark='#383838'; light='#F0F0F0'; icon=' ' ;;
    ${HOME}/Desktop/retool(|/*)) start='#3C3C3C'; end='#1B1B1B'; dark='#16181D'; light='#9FA6B6'; icon=' ' ;;
    ${HOME}/Desktop/returnzero(|/*)) start='#222222'; end='#0F0F0F'; dark='#16181D'; light='#828BA0'; icon=' ' ;;
    ${HOME}/Desktop/revolut(|/*)) start='#006BD7'; end='#003061'; dark='#16181D'; light='#F1F2F4'; icon=' ' ;;
    ${HOME}/Desktop/richart(|/*)) start='#17B6C9'; end='#128E9D'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/robinhood(|/*)) start='#00C805'; end='#009C04'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/runwayml(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/sakura-internet(|/*)) start='#FF5577'; end='#EB4E6D'; dark='#1D1D1D'; light='#1D1D1D'; icon=' ' ;;
    ${HOME}/Desktop/samsung(|/*)) start='#292929'; end='#121212'; dark='#000000'; light='#919191'; icon=' ' ;;
    ${HOME}/Desktop/sandoll(|/*)) start='#EB0600'; end='#6A0200'; dark='#16181D'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/sanity(|/*)) start='#FF5500'; end='#E04B00'; dark='#0B0B0B'; light='#0B0B0B'; icon=' ' ;;
    ${HOME}/Desktop/sansan(|/*)) start='#E60012'; end='#670008'; dark='#16181D'; light='#F9FAFB'; icon=' ' ;;
    ${HOME}/Desktop/saramin(|/*)) start='#3568ED'; end='#182F6B'; dark='#16181D'; light='#F9FAFB'; icon=' ' ;;
    ${HOME}/Desktop/scatterlab(|/*)) start='#212529'; end='#0F1112'; dark='#16181D'; light='#828BA0'; icon=' ' ;;
    ${HOME}/Desktop/sentry(|/*)) start='#362D59'; end='#181428'; dark='#FFFFFF'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/servicenow(|/*)) start='#102C40'; end='#07141D'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/shiftup(|/*)) start='#5EA849'; end='#539440'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/shinhanbank(|/*)) start='#0046FF'; end='#001F73'; dark='#16181D'; light='#D9DCE2'; icon=' ' ;;
    ${HOME}/Desktop/shopline(|/*)) start='#215EFF'; end='#0F2A73'; dark='#16181D'; light='#F1F2F4'; icon=' ' ;;
    ${HOME}/Desktop/sionic(|/*)) start='#0074E1'; end='#003465'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/sktelecom(|/*)) start='#3A46CD'; end='#1A205C'; dark='#1A2232'; light='#C6CFE1'; icon=' ' ;;
    ${HOME}/Desktop/skyscanner(|/*)) start='#0062E3'; end='#002C66'; dark='#161616'; light='#EAEAEA'; icon=' ' ;;
    ${HOME}/Desktop/slack(|/*)) start='#4A154B'; end='#210922'; dark='#1D1C1D'; light='#969296'; icon=' ' ;;
    ${HOME}/Desktop/snapchat(|/*)) start='#FFFC00'; end='#8C8B00'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/socar(|/*)) start='#006EEB'; end='#00326A'; dark='#354153'; light='#FBFBFC'; icon=' ' ;;
    ${HOME}/Desktop/sony(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/soomgo(|/*)) start='#693BF2'; end='#2F1B6D'; dark='#16181D'; light='#DFE1E7'; icon=' ' ;;
    ${HOME}/Desktop/spacex(|/*)) start='#ECECF9'; end='#9999A2'; dark='#282877'; light='#F0F0FA'; icon=' ' ;;
    ${HOME}/Desktop/speeda(|/*)) start='#E60F3D'; end='#67071B'; dark='#16181D'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/spindle(|/*)) start='#298737'; end='#123D19'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/spotify(|/*)) start='#28E16A'; end='#25CF62'; dark='#454545'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/squarespace(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/squeezebits(|/*)) start='#BA5214'; end='#542509'; dark='#16181D'; light='#F6F7F8'; icon=' ' ;;
    ${HOME}/Desktop/starbucks(|/*)) start='#00704A'; end='#003221'; dark='#16181D'; light='#DCDFE5'; icon=' ' ;;
    ${HOME}/Desktop/starling(|/*)) start='#50FFEB'; end='#34A699'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/stores(|/*)) start='#0066FF'; end='#002E73'; dark='#16181D'; light='#F6F7F8'; icon=' ' ;;
    ${HOME}/Desktop/stripe(|/*)) start='#635BFF'; end='#2D2973'; dark='#414552'; light='#FCFCFC'; icon=' ' ;;
    ${HOME}/Desktop/studio(|/*)) start='#0072EB'; end='#00336A'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/supabase(|/*)) start='#72E3AD'; end='#4A9470'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/superhuman(|/*)) start='#5840FF'; end='#281D73'; dark='#16181D'; light='#E2E4E9'; icon=' ' ;;
    ${HOME}/Desktop/surveycake(|/*)) start='#3DBA90'; end='#309170'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/teamblind(|/*)) start='#DA3238'; end='#621619'; dark='#16181D'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/tesla(|/*)) start='#3E6AE1'; end='#1C3065'; dark='#171A20'; light='#F8F9FA'; icon=' ' ;;
    ${HOME}/Desktop/theverge(|/*)) start='#5200FF'; end='#250073'; dark='#16181D'; light='#C5C9D3'; icon=' ' ;;
    ${HOME}/Desktop/tmap(|/*)) start='#0064FF'; end='#002D73'; dark='#16181D'; light='#F6F7F8'; icon=' ' ;;
    ${HOME}/Desktop/together.ai(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/toss-securities(|/*)) start='#589AF8'; end='#4E87DA'; dark='#1A1F29'; light='#1A1F29'; icon=' ' ;;
    ${HOME}/Desktop/toss(|/*)) start='#0064FF'; end='#002D73'; dark='#191F28'; light='#F5F6F9'; icon=' ' ;;
    ${HOME}/Desktop/tossbank(|/*)) start='#0064FF'; end='#002D73'; dark='#212529'; light='#F5F6F7'; icon=' ' ;;
    ${HOME}/Desktop/trainline(|/*)) start='#00A88F'; end='#00947E'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/tumblbug(|/*)) start='#FD5744'; end='#D24838'; dark='#000000'; light='#000000'; icon=' ' ;;
    ${HOME}/Desktop/tving(|/*)) start='#EB0027'; end='#6A0012'; dark='#FFFFFF'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/twilio(|/*)) start='#EC112B'; end='#6A0813'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/twitch(|/*)) start='#9146FF'; end='#411F73'; dark='#16181D'; light='#FCFCFD'; icon=' ' ;;
    ${HOME}/Desktop/uber(|/*)) start='#292929'; end='#121212'; dark='#000000'; light='#919191'; icon=' ' ;;
    ${HOME}/Desktop/ubie(|/*)) start='#3959CC'; end='#1A285C'; dark='#16181D'; light='#DCDFE5'; icon=' ' ;;
    ${HOME}/Desktop/uniqlo(|/*)) start='#E31219'; end='#66080B'; dark='#16181D'; light='#F9FAFB'; icon=' ' ;;
    ${HOME}/Desktop/upstage(|/*)) start='#5B52FF'; end='#292573'; dark='#16181D'; light='#F1F2F4'; icon=' ' ;;
    ${HOME}/Desktop/uswds(|/*)) start='#005EA2'; end='#002A49'; dark='#1B1B1B'; light='#D5D5D5'; icon=' ' ;;
    ${HOME}/Desktop/vercel(|/*)) start='#292929'; end='#121212'; dark='#171717'; light='#8F8F8F'; icon=' ' ;;
    ${HOME}/Desktop/vocus(|/*)) start='#FF485A'; end='#EB4253'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/voltagent(|/*)) start='#22C55E'; end='#1B9A49'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/vuno(|/*)) start='#40E2DE'; end='#2A9390'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/wanted(|/*)) start='#0066FF'; end='#002E73'; dark='#16181D'; light='#F6F7F8'; icon=' ' ;;
    ${HOME}/Desktop/wantedly(|/*)) start='#21BDDB'; end='#1A93AB'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/warp(|/*)) start='#01A4FF'; end='#0188D4'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/watcha(|/*)) start='#F95680'; end='#E55076'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/wconcept(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/webflow(|/*)) start='#146EF5'; end='#09316E'; dark='#16181D'; light='#FFFFFF'; icon=' ' ;;
    ${HOME}/Desktop/wise(|/*)) start='#9FE870'; end='#679749'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/wisetracker(|/*)) start='#FF8D08'; end='#C76E06'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/wooribank(|/*)) start='#0067AC'; end='#002E4D'; dark='#000000'; light='#E0E0E0'; icon=' ' ;;
    ${HOME}/Desktop/workday(|/*)) start='#0057AE'; end='#00274E'; dark='#16181D'; light='#CBCED7'; icon=' ' ;;
    ${HOME}/Desktop/x.ai(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    ${HOME}/Desktop/xiaohongshu(|/*)) start='#FF4D65'; end='#EB475D'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/yogiyo(|/*)) start='#E60049'; end='#670021'; dark='#16181D'; light='#F9FAFB'; icon=' ' ;;
    ${HOME}/Desktop/yourator(|/*)) start='#0063D1'; end='#002D5E'; dark='#16181D'; light='#E5E7EB'; icon=' ' ;;
    ${HOME}/Desktop/zapier(|/*)) start='#FF4F00'; end='#EB4900'; dark='#16181D'; light='#16181D'; icon=' ' ;;
    ${HOME}/Desktop/zepeto(|/*)) start='#5C46FF'; end='#291F73'; dark='#16181D'; light='#E8E9ED'; icon=' ' ;;
    ${HOME}/Desktop/zoom(|/*)) start='#0B5CFF'; end='#052973'; dark='#16181D'; light='#EEEFF2'; icon=' ' ;;
    ${HOME}/Desktop/zozotown(|/*)) start='#292929'; end='#121212'; dark='#16181D'; light='#8890A5'; icon=' ' ;;
    *) _brand_dir_content=""; return ;;
  esac
  local text="${icon}${(%):-%~}"
  local key="$text|$start|$end"
  if [[ -n ${_brand_gradient_cache[$key]} ]]; then
    _brand_dir_content=${_brand_gradient_cache[$key]}
  else
    _brand_gradient "$text" "$start" "$end" "$dark" "$light"
    _brand_dir_content=$REPLY
    _brand_gradient_cache[$key]=$REPLY
  fi
}
add-zsh-hook chpwd _brand_apply
_brand_apply

# 프롬프트 첫 칸. 회사 폴더 안에서는 비워 칸 자체를 숨기고(로고는 경로 세그먼트가 그린다),
# 밖에서는 원래의 OS 아이콘을 보여준다.
# case 패턴에 ~ 를 쓰면 zsh가 틸드 확장을 해버려 절대 안 맞는다 — $PWD로 비교한다.
# 이 세그먼트만은 fork를 피할 수 없다: p10k가 os_icon을 정적으로 캐싱해 변수 참조로는
# 디렉터리 변경이 반영되지 않는다(확인함). 커스텀 세그먼트는 매 프롬프트 재실행된다.
_brand_logo_segment() {
  case $PWD in
    ${HOME}/Desktop/104(|/*)) return ;;
    ${HOME}/Desktop/17live(|/*)) return ;;
    ${HOME}/Desktop/29cm(|/*)) return ;;
    ${HOME}/Desktop/3o3(|/*)) return ;;
    ${HOME}/Desktop/42dot(|/*)) return ;;
    ${HOME}/Desktop/8percent(|/*)) return ;;
    ${HOME}/Desktop/91app(|/*)) return ;;
    ${HOME}/Desktop/abema(|/*)) return ;;
    ${HOME}/Desktop/ably(|/*)) return ;;
    ${HOME}/Desktop/acer(|/*)) return ;;
    ${HOME}/Desktop/adobe(|/*)) return ;;
    ${HOME}/Desktop/airbnb(|/*)) return ;;
    ${HOME}/Desktop/airtable(|/*)) return ;;
    ${HOME}/Desktop/amazingtalker(|/*)) return ;;
    ${HOME}/Desktop/appier(|/*)) return ;;
    ${HOME}/Desktop/apple(|/*)) return ;;
    ${HOME}/Desktop/asana(|/*)) return ;;
    ${HOME}/Desktop/asleep(|/*)) return ;;
    ${HOME}/Desktop/baemin(|/*)) return ;;
    ${HOME}/Desktop/bahamut(|/*)) return ;;
    ${HOME}/Desktop/banksalad(|/*)) return ;;
    ${HOME}/Desktop/barogo(|/*)) return ;;
    ${HOME}/Desktop/bbc(|/*)) return ;;
    ${HOME}/Desktop/beusable(|/*)) return ;;
    ${HOME}/Desktop/bigin(|/*)) return ;;
    ${HOME}/Desktop/bilibili(|/*)) return ;;
    ${HOME}/Desktop/bithumb(|/*)) return ;;
    ${HOME}/Desktop/bmw(|/*)) return ;;
    ${HOME}/Desktop/brandi(|/*)) return ;;
    ${HOME}/Desktop/buzzvil(|/*)) return ;;
    ${HOME}/Desktop/cakeresume(|/*)) return ;;
    ${HOME}/Desktop/cal(|/*)) return ;;
    ${HOME}/Desktop/cgv(|/*)) return ;;
    ${HOME}/Desktop/channeltalk(|/*)) return ;;
    ${HOME}/Desktop/china-airlines(|/*)) return ;;
    ${HOME}/Desktop/cjonstyle(|/*)) return ;;
    ${HOME}/Desktop/classting(|/*)) return ;;
    ${HOME}/Desktop/claude(|/*)) return ;;
    ${HOME}/Desktop/clickhouse(|/*)) return ;;
    ${HOME}/Desktop/cloudflare(|/*)) return ;;
    ${HOME}/Desktop/codeit(|/*)) return ;;
    ${HOME}/Desktop/coinbase(|/*)) return ;;
    ${HOME}/Desktop/coinone(|/*)) return ;;
    ${HOME}/Desktop/composio(|/*)) return ;;
    ${HOME}/Desktop/cookpad(|/*)) return ;;
    ${HOME}/Desktop/coupang(|/*)) return ;;
    ${HOME}/Desktop/cursor(|/*)) return ;;
    ${HOME}/Desktop/cybozu(|/*)) return ;;
    ${HOME}/Desktop/databricks(|/*)) return ;;
    ${HOME}/Desktop/dcard(|/*)) return ;;
    ${HOME}/Desktop/dealicious(|/*)) return ;;
    ${HOME}/Desktop/deliveroo(|/*)) return ;;
    ${HOME}/Desktop/dell(|/*)) return ;;
    ${HOME}/Desktop/discord(|/*)) return ;;
    ${HOME}/Desktop/dji(|/*)) return ;;
    ${HOME}/Desktop/dmm(|/*)) return ;;
    ${HOME}/Desktop/doordash(|/*)) return ;;
    ${HOME}/Desktop/drdiary(|/*)) return ;;
    ${HOME}/Desktop/drnow(|/*)) return ;;
    ${HOME}/Desktop/dropbox(|/*)) return ;;
    ${HOME}/Desktop/duolingo(|/*)) return ;;
    ${HOME}/Desktop/easywallet(|/*)) return ;;
    ${HOME}/Desktop/elastic(|/*)) return ;;
    ${HOME}/Desktop/elevenlabs(|/*)) return ;;
    ${HOME}/Desktop/esunbank(|/*)) return ;;
    ${HOME}/Desktop/expo(|/*)) return ;;
    ${HOME}/Desktop/farfetch(|/*)) return ;;
    ${HOME}/Desktop/fastcampus(|/*)) return ;;
    ${HOME}/Desktop/ferrari(|/*)) return ;;
    ${HOME}/Desktop/figma(|/*)) return ;;
    ${HOME}/Desktop/fitpet(|/*)) return ;;
    ${HOME}/Desktop/framer(|/*)) return ;;
    ${HOME}/Desktop/freee(|/*)) return ;;
    ${HOME}/Desktop/frip(|/*)) return ;;
    ${HOME}/Desktop/fubon(|/*)) return ;;
    ${HOME}/Desktop/fugle(|/*)) return ;;
    ${HOME}/Desktop/funnow(|/*)) return ;;
    ${HOME}/Desktop/gangnamunni(|/*)) return ;;
    ${HOME}/Desktop/gaudiolab(|/*)) return ;;
    ${HOME}/Desktop/gaudiy(|/*)) return ;;
    ${HOME}/Desktop/genie(|/*)) return ;;
    ${HOME}/Desktop/github(|/*)) return ;;
    ${HOME}/Desktop/gitlab(|/*)) return ;;
    ${HOME}/Desktop/gogoro(|/*)) return ;;
    ${HOME}/Desktop/google(|/*)) return ;;
    ${HOME}/Desktop/goorm(|/*)) return ;;
    ${HOME}/Desktop/govuk(|/*)) return ;;
    ${HOME}/Desktop/greencar(|/*)) return ;;
    ${HOME}/Desktop/greenvines(|/*)) return ;;
    ${HOME}/Desktop/hackle(|/*)) return ;;
    ${HOME}/Desktop/hahow(|/*)) return ;;
    ${HOME}/Desktop/hana(|/*)) return ;;
    ${HOME}/Desktop/hashicorp(|/*)) return ;;
    ${HOME}/Desktop/headspace(|/*)) return ;;
    ${HOME}/Desktop/hp(|/*)) return ;;
    ${HOME}/Desktop/hubspot(|/*)) return ;;
    ${HOME}/Desktop/humanscape(|/*)) return ;;
    ${HOME}/Desktop/hwahae(|/*)) return ;;
    ${HOME}/Desktop/hyundai(|/*)) return ;;
    ${HOME}/Desktop/ibm(|/*)) return ;;
    ${HOME}/Desktop/idus(|/*)) return ;;
    ${HOME}/Desktop/igaworks(|/*)) return ;;
    ${HOME}/Desktop/iicombined(|/*)) return ;;
    ${HOME}/Desktop/inflearn(|/*)) return ;;
    ${HOME}/Desktop/instacart(|/*)) return ;;
    ${HOME}/Desktop/intercom(|/*)) return ;;
    ${HOME}/Desktop/ipassmoney(|/*)) return ;;
    ${HOME}/Desktop/jandi(|/*)) return ;;
    ${HOME}/Desktop/kakao(|/*)) return ;;
    ${HOME}/Desktop/kakaobank(|/*)) return ;;
    ${HOME}/Desktop/kakaogames(|/*)) return ;;
    ${HOME}/Desktop/kakaot(|/*)) return ;;
    ${HOME}/Desktop/karrot(|/*)) return ;;
    ${HOME}/Desktop/kcd(|/*)) return ;;
    ${HOME}/Desktop/kdan(|/*)) return ;;
    ${HOME}/Desktop/kia(|/*)) return ;;
    ${HOME}/Desktop/kraken(|/*)) return ;;
    ${HOME}/Desktop/kream(|/*)) return ;;
    ${HOME}/Desktop/kurly(|/*)) return ;;
    ${HOME}/Desktop/kyobobook(|/*)) return ;;
    ${HOME}/Desktop/lablup(|/*)) return ;;
    ${HOME}/Desktop/lamborghini(|/*)) return ;;
    ${HOME}/Desktop/laundrygo(|/*)) return ;;
    ${HOME}/Desktop/layerx(|/*)) return ;;
    ${HOME}/Desktop/lemonbase(|/*)) return ;;
    ${HOME}/Desktop/lezhin(|/*)) return ;;
    ${HOME}/Desktop/likelion(|/*)) return ;;
    ${HOME}/Desktop/line(|/*)) return ;;
    ${HOME}/Desktop/linear.app(|/*)) return ;;
    ${HOME}/Desktop/loom(|/*)) return ;;
    ${HOME}/Desktop/lunit(|/*)) return ;;
    ${HOME}/Desktop/mailchimp(|/*)) return ;;
    ${HOME}/Desktop/mastercard(|/*)) return ;;
    ${HOME}/Desktop/maum-ai(|/*)) return ;;
    ${HOME}/Desktop/melon(|/*)) return ;;
    ${HOME}/Desktop/mercury(|/*)) return ;;
    ${HOME}/Desktop/meta(|/*)) return ;;
    ${HOME}/Desktop/mildang(|/*)) return ;;
    ${HOME}/Desktop/minimax(|/*)) return ;;
    ${HOME}/Desktop/mintlify(|/*)) return ;;
    ${HOME}/Desktop/miro(|/*)) return ;;
    ${HOME}/Desktop/mistral.ai(|/*)) return ;;
    ${HOME}/Desktop/mixi(|/*)) return ;;
    ${HOME}/Desktop/modusign(|/*)) return ;;
    ${HOME}/Desktop/moin(|/*)) return ;;
    ${HOME}/Desktop/momoshop(|/*)) return ;;
    ${HOME}/Desktop/money-forward(|/*)) return ;;
    ${HOME}/Desktop/mongodb(|/*)) return ;;
    ${HOME}/Desktop/monzo(|/*)) return ;;
    ${HOME}/Desktop/moreh(|/*)) return ;;
    ${HOME}/Desktop/moze(|/*)) return ;;
    ${HOME}/Desktop/muji(|/*)) return ;;
    ${HOME}/Desktop/musinsa(|/*)) return ;;
    ${HOME}/Desktop/mustit(|/*)) return ;;
    ${HOME}/Desktop/mynavi(|/*)) return ;;
    ${HOME}/Desktop/myrealtrip(|/*)) return ;;
    ${HOME}/Desktop/naver(|/*)) return ;;
    ${HOME}/Desktop/naverwebtoon(|/*)) return ;;
    ${HOME}/Desktop/ncsoft(|/*)) return ;;
    ${HOME}/Desktop/netflix(|/*)) return ;;
    ${HOME}/Desktop/nexon(|/*)) return ;;
    ${HOME}/Desktop/nhn(|/*)) return ;;
    ${HOME}/Desktop/nike(|/*)) return ;;
    ${HOME}/Desktop/nintendo(|/*)) return ;;
    ${HOME}/Desktop/nol(|/*)) return ;;
    ${HOME}/Desktop/nota(|/*)) return ;;
    ${HOME}/Desktop/note(|/*)) return ;;
    ${HOME}/Desktop/notion(|/*)) return ;;
    ${HOME}/Desktop/nvidia(|/*)) return ;;
    ${HOME}/Desktop/oliveyoung(|/*)) return ;;
    ${HOME}/Desktop/ollama(|/*)) return ;;
    ${HOME}/Desktop/openai(|/*)) return ;;
    ${HOME}/Desktop/opencode.ai(|/*)) return ;;
    ${HOME}/Desktop/openpoint(|/*)) return ;;
    ${HOME}/Desktop/patternfly(|/*)) return ;;
    ${HOME}/Desktop/payhere(|/*)) return ;;
    ${HOME}/Desktop/paypal(|/*)) return ;;
    ${HOME}/Desktop/pega(|/*)) return ;;
    ${HOME}/Desktop/peoplefund(|/*)) return ;;
    ${HOME}/Desktop/pepabo(|/*)) return ;;
    ${HOME}/Desktop/perplexity(|/*)) return ;;
    ${HOME}/Desktop/pinkoi(|/*)) return ;;
    ${HOME}/Desktop/pinterest(|/*)) return ;;
    ${HOME}/Desktop/pixiv(|/*)) return ;;
    ${HOME}/Desktop/portone(|/*)) return ;;
    ${HOME}/Desktop/posthog(|/*)) return ;;
    ${HOME}/Desktop/postype(|/*)) return ;;
    ${HOME}/Desktop/pozalabs(|/*)) return ;;
    ${HOME}/Desktop/quotabook(|/*)) return ;;
    ${HOME}/Desktop/rakuten(|/*)) return ;;
    ${HOME}/Desktop/raycast(|/*)) return ;;
    ${HOME}/Desktop/readmoo(|/*)) return ;;
    ${HOME}/Desktop/rebellions(|/*)) return ;;
    ${HOME}/Desktop/recruit(|/*)) return ;;
    ${HOME}/Desktop/reddit(|/*)) return ;;
    ${HOME}/Desktop/remember(|/*)) return ;;
    ${HOME}/Desktop/renault(|/*)) return ;;
    ${HOME}/Desktop/replicate(|/*)) return ;;
    ${HOME}/Desktop/resend(|/*)) return ;;
    ${HOME}/Desktop/retool(|/*)) return ;;
    ${HOME}/Desktop/returnzero(|/*)) return ;;
    ${HOME}/Desktop/revolut(|/*)) return ;;
    ${HOME}/Desktop/richart(|/*)) return ;;
    ${HOME}/Desktop/robinhood(|/*)) return ;;
    ${HOME}/Desktop/runwayml(|/*)) return ;;
    ${HOME}/Desktop/sakura-internet(|/*)) return ;;
    ${HOME}/Desktop/samsung(|/*)) return ;;
    ${HOME}/Desktop/sandoll(|/*)) return ;;
    ${HOME}/Desktop/sanity(|/*)) return ;;
    ${HOME}/Desktop/sansan(|/*)) return ;;
    ${HOME}/Desktop/saramin(|/*)) return ;;
    ${HOME}/Desktop/scatterlab(|/*)) return ;;
    ${HOME}/Desktop/sentry(|/*)) return ;;
    ${HOME}/Desktop/servicenow(|/*)) return ;;
    ${HOME}/Desktop/shiftup(|/*)) return ;;
    ${HOME}/Desktop/shinhanbank(|/*)) return ;;
    ${HOME}/Desktop/shopline(|/*)) return ;;
    ${HOME}/Desktop/sionic(|/*)) return ;;
    ${HOME}/Desktop/sktelecom(|/*)) return ;;
    ${HOME}/Desktop/skyscanner(|/*)) return ;;
    ${HOME}/Desktop/slack(|/*)) return ;;
    ${HOME}/Desktop/snapchat(|/*)) return ;;
    ${HOME}/Desktop/socar(|/*)) return ;;
    ${HOME}/Desktop/sony(|/*)) return ;;
    ${HOME}/Desktop/soomgo(|/*)) return ;;
    ${HOME}/Desktop/spacex(|/*)) return ;;
    ${HOME}/Desktop/speeda(|/*)) return ;;
    ${HOME}/Desktop/spindle(|/*)) return ;;
    ${HOME}/Desktop/spotify(|/*)) return ;;
    ${HOME}/Desktop/squarespace(|/*)) return ;;
    ${HOME}/Desktop/squeezebits(|/*)) return ;;
    ${HOME}/Desktop/starbucks(|/*)) return ;;
    ${HOME}/Desktop/starling(|/*)) return ;;
    ${HOME}/Desktop/stores(|/*)) return ;;
    ${HOME}/Desktop/stripe(|/*)) return ;;
    ${HOME}/Desktop/studio(|/*)) return ;;
    ${HOME}/Desktop/supabase(|/*)) return ;;
    ${HOME}/Desktop/superhuman(|/*)) return ;;
    ${HOME}/Desktop/surveycake(|/*)) return ;;
    ${HOME}/Desktop/teamblind(|/*)) return ;;
    ${HOME}/Desktop/tesla(|/*)) return ;;
    ${HOME}/Desktop/theverge(|/*)) return ;;
    ${HOME}/Desktop/tmap(|/*)) return ;;
    ${HOME}/Desktop/together.ai(|/*)) return ;;
    ${HOME}/Desktop/toss-securities(|/*)) return ;;
    ${HOME}/Desktop/toss(|/*)) return ;;
    ${HOME}/Desktop/tossbank(|/*)) return ;;
    ${HOME}/Desktop/trainline(|/*)) return ;;
    ${HOME}/Desktop/tumblbug(|/*)) return ;;
    ${HOME}/Desktop/tving(|/*)) return ;;
    ${HOME}/Desktop/twilio(|/*)) return ;;
    ${HOME}/Desktop/twitch(|/*)) return ;;
    ${HOME}/Desktop/uber(|/*)) return ;;
    ${HOME}/Desktop/ubie(|/*)) return ;;
    ${HOME}/Desktop/uniqlo(|/*)) return ;;
    ${HOME}/Desktop/upstage(|/*)) return ;;
    ${HOME}/Desktop/uswds(|/*)) return ;;
    ${HOME}/Desktop/vercel(|/*)) return ;;
    ${HOME}/Desktop/vocus(|/*)) return ;;
    ${HOME}/Desktop/voltagent(|/*)) return ;;
    ${HOME}/Desktop/vuno(|/*)) return ;;
    ${HOME}/Desktop/wanted(|/*)) return ;;
    ${HOME}/Desktop/wantedly(|/*)) return ;;
    ${HOME}/Desktop/warp(|/*)) return ;;
    ${HOME}/Desktop/watcha(|/*)) return ;;
    ${HOME}/Desktop/wconcept(|/*)) return ;;
    ${HOME}/Desktop/webflow(|/*)) return ;;
    ${HOME}/Desktop/wise(|/*)) return ;;
    ${HOME}/Desktop/wisetracker(|/*)) return ;;
    ${HOME}/Desktop/wooribank(|/*)) return ;;
    ${HOME}/Desktop/workday(|/*)) return ;;
    ${HOME}/Desktop/x.ai(|/*)) return ;;
    ${HOME}/Desktop/xiaohongshu(|/*)) return ;;
    ${HOME}/Desktop/yogiyo(|/*)) return ;;
    ${HOME}/Desktop/yourator(|/*)) return ;;
    ${HOME}/Desktop/zapier(|/*)) return ;;
    ${HOME}/Desktop/zepeto(|/*)) return ;;
    ${HOME}/Desktop/zoom(|/*)) return ;;
    ${HOME}/Desktop/zozotown(|/*)) return ;;
  esac
  print -rn -- $'\uf179'
}

typeset -g POWERLEVEL9K_DIR_CLASSES=(
  '~/Desktop/104(|/*)'             BRAND_104          ''
  '~/Desktop/17live(|/*)'          BRAND_17LIVE       ''
  '~/Desktop/29cm(|/*)'            BRAND_29CM         ''
  '~/Desktop/3o3(|/*)'             BRAND_3O3          ''
  '~/Desktop/42dot(|/*)'           BRAND_42DOT        ''
  '~/Desktop/8percent(|/*)'        BRAND_8PERCENT     ''
  '~/Desktop/91app(|/*)'           BRAND_91APP        ''
  '~/Desktop/abema(|/*)'           BRAND_ABEMA        ''
  '~/Desktop/ably(|/*)'            BRAND_ABLY         ''
  '~/Desktop/acer(|/*)'            BRAND_ACER         ''
  '~/Desktop/adobe(|/*)'           BRAND_ADOBE        ''
  '~/Desktop/airbnb(|/*)'          BRAND_AIRBNB       ''
  '~/Desktop/airtable(|/*)'        BRAND_AIRTABLE     ''
  '~/Desktop/amazingtalker(|/*)'   BRAND_AMAZINGTALKER ''
  '~/Desktop/appier(|/*)'          BRAND_APPIER       ''
  '~/Desktop/apple(|/*)'           BRAND_APPLE        ''
  '~/Desktop/asana(|/*)'           BRAND_ASANA        ''
  '~/Desktop/asleep(|/*)'          BRAND_ASLEEP       ''
  '~/Desktop/baemin(|/*)'          BRAND_BAEMIN       ''
  '~/Desktop/bahamut(|/*)'         BRAND_BAHAMUT      ''
  '~/Desktop/banksalad(|/*)'       BRAND_BANKSALAD    ''
  '~/Desktop/barogo(|/*)'          BRAND_BAROGO       ''
  '~/Desktop/bbc(|/*)'             BRAND_BBC          ''
  '~/Desktop/beusable(|/*)'        BRAND_BEUSABLE     ''
  '~/Desktop/bigin(|/*)'           BRAND_BIGIN        ''
  '~/Desktop/bilibili(|/*)'        BRAND_BILIBILI     ''
  '~/Desktop/bithumb(|/*)'         BRAND_BITHUMB      ''
  '~/Desktop/bmw(|/*)'             BRAND_BMW          ''
  '~/Desktop/brandi(|/*)'          BRAND_BRANDI       ''
  '~/Desktop/buzzvil(|/*)'         BRAND_BUZZVIL      ''
  '~/Desktop/cakeresume(|/*)'      BRAND_CAKERESUME   ''
  '~/Desktop/cal(|/*)'             BRAND_CAL          ''
  '~/Desktop/cgv(|/*)'             BRAND_CGV          ''
  '~/Desktop/channeltalk(|/*)'     BRAND_CHANNELTALK  ''
  '~/Desktop/china-airlines(|/*)'  BRAND_CHINA-AIRLINES ''
  '~/Desktop/cjonstyle(|/*)'       BRAND_CJONSTYLE    ''
  '~/Desktop/classting(|/*)'       BRAND_CLASSTING    ''
  '~/Desktop/claude(|/*)'          BRAND_CLAUDE       ''
  '~/Desktop/clickhouse(|/*)'      BRAND_CLICKHOUSE   ''
  '~/Desktop/cloudflare(|/*)'      BRAND_CLOUDFLARE   ''
  '~/Desktop/codeit(|/*)'          BRAND_CODEIT       ''
  '~/Desktop/coinbase(|/*)'        BRAND_COINBASE     ''
  '~/Desktop/coinone(|/*)'         BRAND_COINONE      ''
  '~/Desktop/composio(|/*)'        BRAND_COMPOSIO     ''
  '~/Desktop/cookpad(|/*)'         BRAND_COOKPAD      ''
  '~/Desktop/coupang(|/*)'         BRAND_COUPANG      ''
  '~/Desktop/cursor(|/*)'          BRAND_CURSOR       ''
  '~/Desktop/cybozu(|/*)'          BRAND_CYBOZU       ''
  '~/Desktop/databricks(|/*)'      BRAND_DATABRICKS   ''
  '~/Desktop/dcard(|/*)'           BRAND_DCARD        ''
  '~/Desktop/dealicious(|/*)'      BRAND_DEALICIOUS   ''
  '~/Desktop/deliveroo(|/*)'       BRAND_DELIVEROO    ''
  '~/Desktop/dell(|/*)'            BRAND_DELL         ''
  '~/Desktop/discord(|/*)'         BRAND_DISCORD      ''
  '~/Desktop/dji(|/*)'             BRAND_DJI          ''
  '~/Desktop/dmm(|/*)'             BRAND_DMM          ''
  '~/Desktop/doordash(|/*)'        BRAND_DOORDASH     ''
  '~/Desktop/drdiary(|/*)'         BRAND_DRDIARY      ''
  '~/Desktop/drnow(|/*)'           BRAND_DRNOW        ''
  '~/Desktop/dropbox(|/*)'         BRAND_DROPBOX      ''
  '~/Desktop/duolingo(|/*)'        BRAND_DUOLINGO     ''
  '~/Desktop/easywallet(|/*)'      BRAND_EASYWALLET   ''
  '~/Desktop/elastic(|/*)'         BRAND_ELASTIC      ''
  '~/Desktop/elevenlabs(|/*)'      BRAND_ELEVENLABS   ''
  '~/Desktop/esunbank(|/*)'        BRAND_ESUNBANK     ''
  '~/Desktop/expo(|/*)'            BRAND_EXPO         ''
  '~/Desktop/farfetch(|/*)'        BRAND_FARFETCH     ''
  '~/Desktop/fastcampus(|/*)'      BRAND_FASTCAMPUS   ''
  '~/Desktop/ferrari(|/*)'         BRAND_FERRARI      ''
  '~/Desktop/figma(|/*)'           BRAND_FIGMA        ''
  '~/Desktop/fitpet(|/*)'          BRAND_FITPET       ''
  '~/Desktop/framer(|/*)'          BRAND_FRAMER       ''
  '~/Desktop/freee(|/*)'           BRAND_FREEE        ''
  '~/Desktop/frip(|/*)'            BRAND_FRIP         ''
  '~/Desktop/fubon(|/*)'           BRAND_FUBON        ''
  '~/Desktop/fugle(|/*)'           BRAND_FUGLE        ''
  '~/Desktop/funnow(|/*)'          BRAND_FUNNOW       ''
  '~/Desktop/gangnamunni(|/*)'     BRAND_GANGNAMUNNI  ''
  '~/Desktop/gaudiolab(|/*)'       BRAND_GAUDIOLAB    ''
  '~/Desktop/gaudiy(|/*)'          BRAND_GAUDIY       ''
  '~/Desktop/genie(|/*)'           BRAND_GENIE        ''
  '~/Desktop/github(|/*)'          BRAND_GITHUB       ''
  '~/Desktop/gitlab(|/*)'          BRAND_GITLAB       ''
  '~/Desktop/gogoro(|/*)'          BRAND_GOGORO       ''
  '~/Desktop/google(|/*)'          BRAND_GOOGLE       ''
  '~/Desktop/goorm(|/*)'           BRAND_GOORM        ''
  '~/Desktop/govuk(|/*)'           BRAND_GOVUK        ''
  '~/Desktop/greencar(|/*)'        BRAND_GREENCAR     ''
  '~/Desktop/greenvines(|/*)'      BRAND_GREENVINES   ''
  '~/Desktop/hackle(|/*)'          BRAND_HACKLE       ''
  '~/Desktop/hahow(|/*)'           BRAND_HAHOW        ''
  '~/Desktop/hana(|/*)'            BRAND_HANA         ''
  '~/Desktop/hashicorp(|/*)'       BRAND_HASHICORP    ''
  '~/Desktop/headspace(|/*)'       BRAND_HEADSPACE    ''
  '~/Desktop/hp(|/*)'              BRAND_HP           ''
  '~/Desktop/hubspot(|/*)'         BRAND_HUBSPOT      ''
  '~/Desktop/humanscape(|/*)'      BRAND_HUMANSCAPE   ''
  '~/Desktop/hwahae(|/*)'          BRAND_HWAHAE       ''
  '~/Desktop/hyundai(|/*)'         BRAND_HYUNDAI      ''
  '~/Desktop/ibm(|/*)'             BRAND_IBM          ''
  '~/Desktop/idus(|/*)'            BRAND_IDUS         ''
  '~/Desktop/igaworks(|/*)'        BRAND_IGAWORKS     ''
  '~/Desktop/iicombined(|/*)'      BRAND_IICOMBINED   ''
  '~/Desktop/inflearn(|/*)'        BRAND_INFLEARN     ''
  '~/Desktop/instacart(|/*)'       BRAND_INSTACART    ''
  '~/Desktop/intercom(|/*)'        BRAND_INTERCOM     ''
  '~/Desktop/ipassmoney(|/*)'      BRAND_IPASSMONEY   ''
  '~/Desktop/jandi(|/*)'           BRAND_JANDI        ''
  '~/Desktop/kakao(|/*)'           BRAND_KAKAO        ''
  '~/Desktop/kakaobank(|/*)'       BRAND_KAKAOBANK    ''
  '~/Desktop/kakaogames(|/*)'      BRAND_KAKAOGAMES   ''
  '~/Desktop/kakaot(|/*)'          BRAND_KAKAOT       ''
  '~/Desktop/karrot(|/*)'          BRAND_KARROT       ''
  '~/Desktop/kcd(|/*)'             BRAND_KCD          ''
  '~/Desktop/kdan(|/*)'            BRAND_KDAN         ''
  '~/Desktop/kia(|/*)'             BRAND_KIA          ''
  '~/Desktop/kraken(|/*)'          BRAND_KRAKEN       ''
  '~/Desktop/kream(|/*)'           BRAND_KREAM        ''
  '~/Desktop/kurly(|/*)'           BRAND_KURLY        ''
  '~/Desktop/kyobobook(|/*)'       BRAND_KYOBOBOOK    ''
  '~/Desktop/lablup(|/*)'          BRAND_LABLUP       ''
  '~/Desktop/lamborghini(|/*)'     BRAND_LAMBORGHINI  ''
  '~/Desktop/laundrygo(|/*)'       BRAND_LAUNDRYGO    ''
  '~/Desktop/layerx(|/*)'          BRAND_LAYERX       ''
  '~/Desktop/lemonbase(|/*)'       BRAND_LEMONBASE    ''
  '~/Desktop/lezhin(|/*)'          BRAND_LEZHIN       ''
  '~/Desktop/likelion(|/*)'        BRAND_LIKELION     ''
  '~/Desktop/line(|/*)'            BRAND_LINE         ''
  '~/Desktop/linear.app(|/*)'      BRAND_LINEAR.APP   ''
  '~/Desktop/loom(|/*)'            BRAND_LOOM         ''
  '~/Desktop/lunit(|/*)'           BRAND_LUNIT        ''
  '~/Desktop/mailchimp(|/*)'       BRAND_MAILCHIMP    ''
  '~/Desktop/mastercard(|/*)'      BRAND_MASTERCARD   ''
  '~/Desktop/maum-ai(|/*)'         BRAND_MAUM-AI      ''
  '~/Desktop/melon(|/*)'           BRAND_MELON        ''
  '~/Desktop/mercury(|/*)'         BRAND_MERCURY      ''
  '~/Desktop/meta(|/*)'            BRAND_META         ''
  '~/Desktop/mildang(|/*)'         BRAND_MILDANG      ''
  '~/Desktop/minimax(|/*)'         BRAND_MINIMAX      ''
  '~/Desktop/mintlify(|/*)'        BRAND_MINTLIFY     ''
  '~/Desktop/miro(|/*)'            BRAND_MIRO         ''
  '~/Desktop/mistral.ai(|/*)'      BRAND_MISTRAL.AI   ''
  '~/Desktop/mixi(|/*)'            BRAND_MIXI         ''
  '~/Desktop/modusign(|/*)'        BRAND_MODUSIGN     ''
  '~/Desktop/moin(|/*)'            BRAND_MOIN         ''
  '~/Desktop/momoshop(|/*)'        BRAND_MOMOSHOP     ''
  '~/Desktop/money-forward(|/*)'   BRAND_MONEY-FORWARD ''
  '~/Desktop/mongodb(|/*)'         BRAND_MONGODB      ''
  '~/Desktop/monzo(|/*)'           BRAND_MONZO        ''
  '~/Desktop/moreh(|/*)'           BRAND_MOREH        ''
  '~/Desktop/moze(|/*)'            BRAND_MOZE         ''
  '~/Desktop/muji(|/*)'            BRAND_MUJI         ''
  '~/Desktop/musinsa(|/*)'         BRAND_MUSINSA      ''
  '~/Desktop/mustit(|/*)'          BRAND_MUSTIT       ''
  '~/Desktop/mynavi(|/*)'          BRAND_MYNAVI       ''
  '~/Desktop/myrealtrip(|/*)'      BRAND_MYREALTRIP   ''
  '~/Desktop/naver(|/*)'           BRAND_NAVER        ''
  '~/Desktop/naverwebtoon(|/*)'    BRAND_NAVERWEBTOON ''
  '~/Desktop/ncsoft(|/*)'          BRAND_NCSOFT       ''
  '~/Desktop/netflix(|/*)'         BRAND_NETFLIX      ''
  '~/Desktop/nexon(|/*)'           BRAND_NEXON        ''
  '~/Desktop/nhn(|/*)'             BRAND_NHN          ''
  '~/Desktop/nike(|/*)'            BRAND_NIKE         ''
  '~/Desktop/nintendo(|/*)'        BRAND_NINTENDO     ''
  '~/Desktop/nol(|/*)'             BRAND_NOL          ''
  '~/Desktop/nota(|/*)'            BRAND_NOTA         ''
  '~/Desktop/note(|/*)'            BRAND_NOTE         ''
  '~/Desktop/notion(|/*)'          BRAND_NOTION       ''
  '~/Desktop/nvidia(|/*)'          BRAND_NVIDIA       ''
  '~/Desktop/oliveyoung(|/*)'      BRAND_OLIVEYOUNG   ''
  '~/Desktop/ollama(|/*)'          BRAND_OLLAMA       ''
  '~/Desktop/openai(|/*)'          BRAND_OPENAI       ''
  '~/Desktop/opencode.ai(|/*)'     BRAND_OPENCODE.AI  ''
  '~/Desktop/openpoint(|/*)'       BRAND_OPENPOINT    ''
  '~/Desktop/patternfly(|/*)'      BRAND_PATTERNFLY   ''
  '~/Desktop/payhere(|/*)'         BRAND_PAYHERE      ''
  '~/Desktop/paypal(|/*)'          BRAND_PAYPAL       ''
  '~/Desktop/pega(|/*)'            BRAND_PEGA         ''
  '~/Desktop/peoplefund(|/*)'      BRAND_PEOPLEFUND   ''
  '~/Desktop/pepabo(|/*)'          BRAND_PEPABO       ''
  '~/Desktop/perplexity(|/*)'      BRAND_PERPLEXITY   ''
  '~/Desktop/pinkoi(|/*)'          BRAND_PINKOI       ''
  '~/Desktop/pinterest(|/*)'       BRAND_PINTEREST    ''
  '~/Desktop/pixiv(|/*)'           BRAND_PIXIV        ''
  '~/Desktop/portone(|/*)'         BRAND_PORTONE      ''
  '~/Desktop/posthog(|/*)'         BRAND_POSTHOG      ''
  '~/Desktop/postype(|/*)'         BRAND_POSTYPE      ''
  '~/Desktop/pozalabs(|/*)'        BRAND_POZALABS     ''
  '~/Desktop/quotabook(|/*)'       BRAND_QUOTABOOK    ''
  '~/Desktop/rakuten(|/*)'         BRAND_RAKUTEN      ''
  '~/Desktop/raycast(|/*)'         BRAND_RAYCAST      ''
  '~/Desktop/readmoo(|/*)'         BRAND_READMOO      ''
  '~/Desktop/rebellions(|/*)'      BRAND_REBELLIONS   ''
  '~/Desktop/recruit(|/*)'         BRAND_RECRUIT      ''
  '~/Desktop/reddit(|/*)'          BRAND_REDDIT       ''
  '~/Desktop/remember(|/*)'        BRAND_REMEMBER     ''
  '~/Desktop/renault(|/*)'         BRAND_RENAULT      ''
  '~/Desktop/replicate(|/*)'       BRAND_REPLICATE    ''
  '~/Desktop/resend(|/*)'          BRAND_RESEND       ''
  '~/Desktop/retool(|/*)'          BRAND_RETOOL       ''
  '~/Desktop/returnzero(|/*)'      BRAND_RETURNZERO   ''
  '~/Desktop/revolut(|/*)'         BRAND_REVOLUT      ''
  '~/Desktop/richart(|/*)'         BRAND_RICHART      ''
  '~/Desktop/robinhood(|/*)'       BRAND_ROBINHOOD    ''
  '~/Desktop/runwayml(|/*)'        BRAND_RUNWAYML     ''
  '~/Desktop/sakura-internet(|/*)' BRAND_SAKURA-INTERNET ''
  '~/Desktop/samsung(|/*)'         BRAND_SAMSUNG      ''
  '~/Desktop/sandoll(|/*)'         BRAND_SANDOLL      ''
  '~/Desktop/sanity(|/*)'          BRAND_SANITY       ''
  '~/Desktop/sansan(|/*)'          BRAND_SANSAN       ''
  '~/Desktop/saramin(|/*)'         BRAND_SARAMIN      ''
  '~/Desktop/scatterlab(|/*)'      BRAND_SCATTERLAB   ''
  '~/Desktop/sentry(|/*)'          BRAND_SENTRY       ''
  '~/Desktop/servicenow(|/*)'      BRAND_SERVICENOW   ''
  '~/Desktop/shiftup(|/*)'         BRAND_SHIFTUP      ''
  '~/Desktop/shinhanbank(|/*)'     BRAND_SHINHANBANK  ''
  '~/Desktop/shopline(|/*)'        BRAND_SHOPLINE     ''
  '~/Desktop/sionic(|/*)'          BRAND_SIONIC       ''
  '~/Desktop/sktelecom(|/*)'       BRAND_SKTELECOM    ''
  '~/Desktop/skyscanner(|/*)'      BRAND_SKYSCANNER   ''
  '~/Desktop/slack(|/*)'           BRAND_SLACK        ''
  '~/Desktop/snapchat(|/*)'        BRAND_SNAPCHAT     ''
  '~/Desktop/socar(|/*)'           BRAND_SOCAR        ''
  '~/Desktop/sony(|/*)'            BRAND_SONY         ''
  '~/Desktop/soomgo(|/*)'          BRAND_SOOMGO       ''
  '~/Desktop/spacex(|/*)'          BRAND_SPACEX       ''
  '~/Desktop/speeda(|/*)'          BRAND_SPEEDA       ''
  '~/Desktop/spindle(|/*)'         BRAND_SPINDLE      ''
  '~/Desktop/spotify(|/*)'         BRAND_SPOTIFY      ''
  '~/Desktop/squarespace(|/*)'     BRAND_SQUARESPACE  ''
  '~/Desktop/squeezebits(|/*)'     BRAND_SQUEEZEBITS  ''
  '~/Desktop/starbucks(|/*)'       BRAND_STARBUCKS    ''
  '~/Desktop/starling(|/*)'        BRAND_STARLING     ''
  '~/Desktop/stores(|/*)'          BRAND_STORES       ''
  '~/Desktop/stripe(|/*)'          BRAND_STRIPE       ''
  '~/Desktop/studio(|/*)'          BRAND_STUDIO       ''
  '~/Desktop/supabase(|/*)'        BRAND_SUPABASE     ''
  '~/Desktop/superhuman(|/*)'      BRAND_SUPERHUMAN   ''
  '~/Desktop/surveycake(|/*)'      BRAND_SURVEYCAKE   ''
  '~/Desktop/teamblind(|/*)'       BRAND_TEAMBLIND    ''
  '~/Desktop/tesla(|/*)'           BRAND_TESLA        ''
  '~/Desktop/theverge(|/*)'        BRAND_THEVERGE     ''
  '~/Desktop/tmap(|/*)'            BRAND_TMAP         ''
  '~/Desktop/together.ai(|/*)'     BRAND_TOGETHER.AI  ''
  '~/Desktop/toss-securities(|/*)' BRAND_TOSS-SECURITIES ''
  '~/Desktop/toss(|/*)'            BRAND_TOSS         ''
  '~/Desktop/tossbank(|/*)'        BRAND_TOSSBANK     ''
  '~/Desktop/trainline(|/*)'       BRAND_TRAINLINE    ''
  '~/Desktop/tumblbug(|/*)'        BRAND_TUMBLBUG     ''
  '~/Desktop/tving(|/*)'           BRAND_TVING        ''
  '~/Desktop/twilio(|/*)'          BRAND_TWILIO       ''
  '~/Desktop/twitch(|/*)'          BRAND_TWITCH       ''
  '~/Desktop/uber(|/*)'            BRAND_UBER         ''
  '~/Desktop/ubie(|/*)'            BRAND_UBIE         ''
  '~/Desktop/uniqlo(|/*)'          BRAND_UNIQLO       ''
  '~/Desktop/upstage(|/*)'         BRAND_UPSTAGE      ''
  '~/Desktop/uswds(|/*)'           BRAND_USWDS        ''
  '~/Desktop/vercel(|/*)'          BRAND_VERCEL       ''
  '~/Desktop/vocus(|/*)'           BRAND_VOCUS        ''
  '~/Desktop/voltagent(|/*)'       BRAND_VOLTAGENT    ''
  '~/Desktop/vuno(|/*)'            BRAND_VUNO         ''
  '~/Desktop/wanted(|/*)'          BRAND_WANTED       ''
  '~/Desktop/wantedly(|/*)'        BRAND_WANTEDLY     ''
  '~/Desktop/warp(|/*)'            BRAND_WARP         ''
  '~/Desktop/watcha(|/*)'          BRAND_WATCHA       ''
  '~/Desktop/wconcept(|/*)'        BRAND_WCONCEPT     ''
  '~/Desktop/webflow(|/*)'         BRAND_WEBFLOW      ''
  '~/Desktop/wise(|/*)'            BRAND_WISE         ''
  '~/Desktop/wisetracker(|/*)'     BRAND_WISETRACKER  ''
  '~/Desktop/wooribank(|/*)'       BRAND_WOORIBANK    ''
  '~/Desktop/workday(|/*)'         BRAND_WORKDAY      ''
  '~/Desktop/x.ai(|/*)'            BRAND_X.AI         ''
  '~/Desktop/xiaohongshu(|/*)'     BRAND_XIAOHONGSHU  ''
  '~/Desktop/yogiyo(|/*)'          BRAND_YOGIYO       ''
  '~/Desktop/yourator(|/*)'        BRAND_YOURATOR     ''
  '~/Desktop/zapier(|/*)'          BRAND_ZAPIER       ''
  '~/Desktop/zepeto(|/*)'          BRAND_ZEPETO       ''
  '~/Desktop/zoom(|/*)'            BRAND_ZOOM         ''
  '~/Desktop/zozotown(|/*)'        BRAND_ZOZOTOWN     ''
  '*'                              DEFAULT            ''
)

# DEFAULT 클래스는 값을 정의하지 않는다 — p10k가 기존 POWERLEVEL9K_DIR_* 로 폴백하므로
# 회사 경로 밖에서는 원래 쓰던 프롬프트가 그대로 유지된다.

# 104人力銀行
typeset -g POWERLEVEL9K_DIR_BRAND_104_BACKGROUND='#E08000'
typeset -g POWERLEVEL9K_DIR_BRAND_104_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_104_SHORTENED_FOREGROUND='#7C5017'
typeset -g POWERLEVEL9K_DIR_BRAND_104_ANCHOR_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_104_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_104_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_104_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_104_NOT_WRITABLE_BACKGROUND='#E08000'
typeset -g POWERLEVEL9K_DIR_BRAND_104_NOT_WRITABLE_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_104_NOT_WRITABLE_SHORTENED_FOREGROUND='#7C5017'
typeset -g POWERLEVEL9K_DIR_BRAND_104_NOT_WRITABLE_ANCHOR_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_104_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_104_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_104_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_104_NON_EXISTENT_BACKGROUND='#E08000'
typeset -g POWERLEVEL9K_DIR_BRAND_104_NON_EXISTENT_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_104_NON_EXISTENT_SHORTENED_FOREGROUND='#7C5017'
typeset -g POWERLEVEL9K_DIR_BRAND_104_NON_EXISTENT_ANCHOR_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_104_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_104_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_104_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# 17LIVE
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_BACKGROUND='#E0697E'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_SHORTENED_FOREGROUND='#7B464F'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_ANCHOR_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NOT_WRITABLE_BACKGROUND='#E0697E'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NOT_WRITABLE_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NOT_WRITABLE_SHORTENED_FOREGROUND='#7B464F'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NOT_WRITABLE_ANCHOR_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NON_EXISTENT_BACKGROUND='#E0697E'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NON_EXISTENT_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NON_EXISTENT_SHORTENED_FOREGROUND='#7B464F'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NON_EXISTENT_ANCHOR_FOREGROUND='#292929'
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_17LIVE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# 29CM
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NOT_WRITABLE_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NON_EXISTENT_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_29CM_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# 3o3
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_BACKGROUND='#052D67'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_SHORTENED_FOREGROUND='#0F213F'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NOT_WRITABLE_BACKGROUND='#052D67'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NOT_WRITABLE_SHORTENED_FOREGROUND='#0F213F'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NON_EXISTENT_BACKGROUND='#052D67'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NON_EXISTENT_SHORTENED_FOREGROUND='#0F213F'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_3O3_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# 42dot
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_BACKGROUND='#7F77E7'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_SHORTENED_FOREGROUND='#454378'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NOT_WRITABLE_BACKGROUND='#7F77E7'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NOT_WRITABLE_SHORTENED_FOREGROUND='#454378'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NON_EXISTENT_BACKGROUND='#7F77E7'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NON_EXISTENT_SHORTENED_FOREGROUND='#454378'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_42DOT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# 8percent
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_BACKGROUND='#3F82DE'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_SHORTENED_FOREGROUND='#294874'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NOT_WRITABLE_BACKGROUND='#3F82DE'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NOT_WRITABLE_SHORTENED_FOREGROUND='#294874'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NON_EXISTENT_BACKGROUND='#3F82DE'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NON_EXISTENT_SHORTENED_FOREGROUND='#294874'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_8PERCENT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# 91APP
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_BACKGROUND='#030D1B'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_FOREGROUND='#061C3D'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_SHORTENED_FOREGROUND='#05152E'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_ANCHOR_FOREGROUND='#061C3D'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NOT_WRITABLE_BACKGROUND='#030D1B'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NOT_WRITABLE_FOREGROUND='#061C3D'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NOT_WRITABLE_SHORTENED_FOREGROUND='#05152E'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NOT_WRITABLE_ANCHOR_FOREGROUND='#061C3D'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NON_EXISTENT_BACKGROUND='#030D1B'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NON_EXISTENT_FOREGROUND='#061C3D'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NON_EXISTENT_SHORTENED_FOREGROUND='#05152E'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NON_EXISTENT_ANCHOR_FOREGROUND='#061C3D'
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_91APP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# ABEMA
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_BACKGROUND='#C29600'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_SHORTENED_FOREGROUND='#74601C'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NOT_WRITABLE_BACKGROUND='#C29600'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NOT_WRITABLE_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NOT_WRITABLE_SHORTENED_FOREGROUND='#74601C'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NOT_WRITABLE_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NON_EXISTENT_BACKGROUND='#C29600'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NON_EXISTENT_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NON_EXISTENT_SHORTENED_FOREGROUND='#74601C'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NON_EXISTENT_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ABEMA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Ably
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_BACKGROUND='#E05965'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_FOREGROUND='#1F1F1F'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_SHORTENED_FOREGROUND='#76393E'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_ANCHOR_FOREGROUND='#1F1F1F'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NOT_WRITABLE_BACKGROUND='#E05965'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NOT_WRITABLE_FOREGROUND='#1F1F1F'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NOT_WRITABLE_SHORTENED_FOREGROUND='#76393E'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NOT_WRITABLE_ANCHOR_FOREGROUND='#1F1F1F'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NON_EXISTENT_BACKGROUND='#E05965'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NON_EXISTENT_FOREGROUND='#1F1F1F'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NON_EXISTENT_SHORTENED_FOREGROUND='#76393E'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NON_EXISTENT_ANCHOR_FOREGROUND='#1F1F1F'
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ABLY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# 宏碁
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_BACKGROUND='#649834'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_SHORTENED_FOREGROUND='#40572A'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NOT_WRITABLE_BACKGROUND='#649834'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NOT_WRITABLE_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NOT_WRITABLE_SHORTENED_FOREGROUND='#40572A'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NOT_WRITABLE_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NON_EXISTENT_BACKGROUND='#649834'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NON_EXISTENT_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NON_EXISTENT_SHORTENED_FOREGROUND='#40572A'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NON_EXISTENT_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ACER_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Adobe
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_BACKGROUND='#6A0700'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_SHORTENED_FOREGROUND='#3C1010'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NOT_WRITABLE_BACKGROUND='#6A0700'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NOT_WRITABLE_SHORTENED_FOREGROUND='#3C1010'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NON_EXISTENT_BACKGROUND='#6A0700'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NON_EXISTENT_SHORTENED_FOREGROUND='#3C1010'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ADOBE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Airbnb
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_BACKGROUND='#EB5973'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_SHORTENED_FOREGROUND='#7C3B47'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NOT_WRITABLE_BACKGROUND='#EB5973'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NOT_WRITABLE_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NOT_WRITABLE_SHORTENED_FOREGROUND='#7C3B47'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NOT_WRITABLE_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NON_EXISTENT_BACKGROUND='#EB5973'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NON_EXISTENT_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NON_EXISTENT_SHORTENED_FOREGROUND='#7C3B47'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NON_EXISTENT_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_AIRBNB_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Airtable
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_BACKGROUND='#B58200'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_FOREGROUND='#181D26'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_SHORTENED_FOREGROUND='#5F4A15'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_ANCHOR_FOREGROUND='#181D26'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NOT_WRITABLE_BACKGROUND='#B58200'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NOT_WRITABLE_FOREGROUND='#181D26'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NOT_WRITABLE_SHORTENED_FOREGROUND='#5F4A15'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NOT_WRITABLE_ANCHOR_FOREGROUND='#181D26'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NON_EXISTENT_BACKGROUND='#B58200'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NON_EXISTENT_FOREGROUND='#181D26'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NON_EXISTENT_SHORTENED_FOREGROUND='#5F4A15'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NON_EXISTENT_ANCHOR_FOREGROUND='#181D26'
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_AIRTABLE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# AmazingTalker
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_BACKGROUND='#019185'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_SHORTENED_FOREGROUND='#0D4F4C'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NOT_WRITABLE_BACKGROUND='#019185'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NOT_WRITABLE_SHORTENED_FOREGROUND='#0D4F4C'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NON_EXISTENT_BACKGROUND='#019185'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NON_EXISTENT_SHORTENED_FOREGROUND='#0D4F4C'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_AMAZINGTALKER_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Appier
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_BACKGROUND='#0D1573'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_FOREGROUND='#101130'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_SHORTENED_FOREGROUND='#0F134E'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_ANCHOR_FOREGROUND='#101130'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NOT_WRITABLE_BACKGROUND='#0D1573'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NOT_WRITABLE_FOREGROUND='#101130'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NOT_WRITABLE_SHORTENED_FOREGROUND='#0F134E'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NOT_WRITABLE_ANCHOR_FOREGROUND='#101130'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NON_EXISTENT_BACKGROUND='#0D1573'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NON_EXISTENT_FOREGROUND='#101130'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NON_EXISTENT_SHORTENED_FOREGROUND='#0F134E'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NON_EXISTENT_ANCHOR_FOREGROUND='#101130'
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_APPIER_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Apple
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_FOREGROUND='#1D1D1F'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_SHORTENED_FOREGROUND='#181819'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_ANCHOR_FOREGROUND='#1D1D1F'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NOT_WRITABLE_FOREGROUND='#1D1D1F'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NOT_WRITABLE_SHORTENED_FOREGROUND='#181819'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NOT_WRITABLE_ANCHOR_FOREGROUND='#1D1D1F'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NON_EXISTENT_FOREGROUND='#1D1D1F'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NON_EXISTENT_SHORTENED_FOREGROUND='#181819'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NON_EXISTENT_ANCHOR_FOREGROUND='#1D1D1F'
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_APPLE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Asana
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_BACKGROUND='#D35D5D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_SHORTENED_FOREGROUND='#6B373A'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NOT_WRITABLE_BACKGROUND='#D35D5D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NOT_WRITABLE_SHORTENED_FOREGROUND='#6B373A'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NON_EXISTENT_BACKGROUND='#D35D5D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NON_EXISTENT_SHORTENED_FOREGROUND='#6B373A'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ASANA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Asleep
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_BACKGROUND='#0A2F71'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_SHORTENED_FOREGROUND='#112243'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NOT_WRITABLE_BACKGROUND='#0A2F71'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NOT_WRITABLE_SHORTENED_FOREGROUND='#112243'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NON_EXISTENT_BACKGROUND='#0A2F71'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NON_EXISTENT_SHORTENED_FOREGROUND='#112243'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ASLEEP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Baemin
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_BACKGROUND='#089B89'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_SHORTENED_FOREGROUND='#165950'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NOT_WRITABLE_BACKGROUND='#089B89'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NOT_WRITABLE_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NOT_WRITABLE_SHORTENED_FOREGROUND='#165950'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NOT_WRITABLE_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NON_EXISTENT_BACKGROUND='#089B89'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NON_EXISTENT_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NON_EXISTENT_SHORTENED_FOREGROUND='#165950'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NON_EXISTENT_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BAEMIN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Bahamut
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_BACKGROUND='#0E8DA0'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_SHORTENED_FOREGROUND='#124D58'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NOT_WRITABLE_BACKGROUND='#0E8DA0'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NOT_WRITABLE_SHORTENED_FOREGROUND='#124D58'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NON_EXISTENT_BACKGROUND='#0E8DA0'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NON_EXISTENT_SHORTENED_FOREGROUND='#124D58'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BAHAMUT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Banksalad
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_BACKGROUND='#0F9362'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_FOREGROUND='#111111'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_SHORTENED_FOREGROUND='#104C36'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_ANCHOR_FOREGROUND='#111111'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NOT_WRITABLE_BACKGROUND='#0F9362'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NOT_WRITABLE_FOREGROUND='#111111'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NOT_WRITABLE_SHORTENED_FOREGROUND='#104C36'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NOT_WRITABLE_ANCHOR_FOREGROUND='#111111'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NON_EXISTENT_BACKGROUND='#0F9362'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NON_EXISTENT_FOREGROUND='#111111'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NON_EXISTENT_SHORTENED_FOREGROUND='#104C36'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NON_EXISTENT_ANCHOR_FOREGROUND='#111111'
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BANKSALAD_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Barogo
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_BACKGROUND='#E64A12'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_SHORTENED_FOREGROUND='#742E18'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NOT_WRITABLE_BACKGROUND='#E64A12'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NOT_WRITABLE_SHORTENED_FOREGROUND='#742E18'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NON_EXISTENT_BACKGROUND='#E64A12'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NON_EXISTENT_SHORTENED_FOREGROUND='#742E18'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BAROGO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# BBC
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BBC_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Beusable
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_BACKGROUND='#6A0020'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_SHORTENED_FOREGROUND='#3C0D1E'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NOT_WRITABLE_BACKGROUND='#6A0020'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NOT_WRITABLE_SHORTENED_FOREGROUND='#3C0D1E'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NON_EXISTENT_BACKGROUND='#6A0020'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NON_EXISTENT_SHORTENED_FOREGROUND='#3C0D1E'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BEUSABLE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Bigin
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_BACKGROUND='#002E6A'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_SHORTENED_FOREGROUND='#0C223F'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NOT_WRITABLE_BACKGROUND='#002E6A'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C223F'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NON_EXISTENT_BACKGROUND='#002E6A'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NON_EXISTENT_SHORTENED_FOREGROUND='#0C223F'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BIGIN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Bilibili
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_BACKGROUND='#D05F7F'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_FOREGROUND='#18191C'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_SHORTENED_FOREGROUND='#6B3849'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_ANCHOR_FOREGROUND='#18191C'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NOT_WRITABLE_BACKGROUND='#D05F7F'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NOT_WRITABLE_FOREGROUND='#18191C'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NOT_WRITABLE_SHORTENED_FOREGROUND='#6B3849'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NOT_WRITABLE_ANCHOR_FOREGROUND='#18191C'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NON_EXISTENT_BACKGROUND='#D05F7F'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NON_EXISTENT_FOREGROUND='#18191C'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NON_EXISTENT_SHORTENED_FOREGROUND='#6B3849'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NON_EXISTENT_ANCHOR_FOREGROUND='#18191C'
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BILIBILI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Bithumb
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_BACKGROUND='#0D0E12'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_SHORTENED_FOREGROUND='#929394'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NOT_WRITABLE_BACKGROUND='#0D0E12'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NOT_WRITABLE_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NOT_WRITABLE_SHORTENED_FOREGROUND='#929394'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NOT_WRITABLE_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NON_EXISTENT_BACKGROUND='#0D0E12'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NON_EXISTENT_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NON_EXISTENT_SHORTENED_FOREGROUND='#929394'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NON_EXISTENT_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BITHUMB_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# BMW
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_BACKGROUND='#0D2F5F'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_SHORTENED_FOREGROUND='#29394F'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_ANCHOR_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NOT_WRITABLE_BACKGROUND='#0D2F5F'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NOT_WRITABLE_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NOT_WRITABLE_SHORTENED_FOREGROUND='#29394F'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NOT_WRITABLE_ANCHOR_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NON_EXISTENT_BACKGROUND='#0D2F5F'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NON_EXISTENT_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NON_EXISTENT_SHORTENED_FOREGROUND='#29394F'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NON_EXISTENT_ANCHOR_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BMW_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Brandi
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_BACKGROUND='#0D0D0D'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_SHORTENED_FOREGROUND='#121316'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NOT_WRITABLE_BACKGROUND='#0D0D0D'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NOT_WRITABLE_SHORTENED_FOREGROUND='#121316'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NON_EXISTENT_BACKGROUND='#0D0D0D'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NON_EXISTENT_SHORTENED_FOREGROUND='#121316'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BRANDI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Buzzvil
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_BACKGROUND='#E14E43'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_SHORTENED_FOREGROUND='#72302E'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NOT_WRITABLE_BACKGROUND='#E14E43'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NOT_WRITABLE_SHORTENED_FOREGROUND='#72302E'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NON_EXISTENT_BACKGROUND='#E14E43'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NON_EXISTENT_SHORTENED_FOREGROUND='#72302E'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_BUZZVIL_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Cake
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_BACKGROUND='#0F8550'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_SHORTENED_FOREGROUND='#073C24'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NOT_WRITABLE_BACKGROUND='#0F8550'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NOT_WRITABLE_SHORTENED_FOREGROUND='#073C24'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NON_EXISTENT_BACKGROUND='#0F8550'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NON_EXISTENT_SHORTENED_FOREGROUND='#073C24'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CAKERESUME_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Cal.com
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_BACKGROUND='#0B101A'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_FOREGROUND='#242424'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_SHORTENED_FOREGROUND='#191B1F'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_ANCHOR_FOREGROUND='#242424'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NOT_WRITABLE_BACKGROUND='#0B101A'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NOT_WRITABLE_FOREGROUND='#242424'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NOT_WRITABLE_SHORTENED_FOREGROUND='#191B1F'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NOT_WRITABLE_ANCHOR_FOREGROUND='#242424'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NON_EXISTENT_BACKGROUND='#0B101A'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NON_EXISTENT_FOREGROUND='#242424'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NON_EXISTENT_SHORTENED_FOREGROUND='#191B1F'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NON_EXISTENT_ANCHOR_FOREGROUND='#242424'
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CAL_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# CGV
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_FOREGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_SHORTENED_FOREGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_ANCHOR_FOREGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NOT_WRITABLE_FOREGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NOT_WRITABLE_SHORTENED_FOREGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NOT_WRITABLE_ANCHOR_FOREGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NON_EXISTENT_FOREGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NON_EXISTENT_SHORTENED_FOREGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NON_EXISTENT_ANCHOR_FOREGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CGV_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Channel Talk
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_BACKGROUND='#101012'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_SHORTENED_FOREGROUND='#070708'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NOT_WRITABLE_BACKGROUND='#101012'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NOT_WRITABLE_SHORTENED_FOREGROUND='#070708'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NON_EXISTENT_BACKGROUND='#101012'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NON_EXISTENT_SHORTENED_FOREGROUND='#070708'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CHANNELTALK_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# 中華航空
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_BACKGROUND='#102747'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_SHORTENED_FOREGROUND='#131F30'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NOT_WRITABLE_BACKGROUND='#102747'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NOT_WRITABLE_SHORTENED_FOREGROUND='#131F30'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NON_EXISTENT_BACKGROUND='#102747'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NON_EXISTENT_SHORTENED_FOREGROUND='#131F30'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CHINA-AIRLINES_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# CJ ONSTYLE
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_BACKGROUND='#2D074F'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_SHORTENED_FOREGROUND='#201033'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NOT_WRITABLE_BACKGROUND='#2D074F'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NOT_WRITABLE_SHORTENED_FOREGROUND='#201033'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NON_EXISTENT_BACKGROUND='#2D074F'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NON_EXISTENT_SHORTENED_FOREGROUND='#201033'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CJONSTYLE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Classting
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_BACKGROUND='#00CB98'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_FOREGROUND='#424242'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_SHORTENED_FOREGROUND='#248069'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_ANCHOR_FOREGROUND='#424242'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NOT_WRITABLE_BACKGROUND='#00CB98'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NOT_WRITABLE_FOREGROUND='#424242'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NOT_WRITABLE_SHORTENED_FOREGROUND='#248069'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NOT_WRITABLE_ANCHOR_FOREGROUND='#424242'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NON_EXISTENT_BACKGROUND='#00CB98'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NON_EXISTENT_FOREGROUND='#424242'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NON_EXISTENT_SHORTENED_FOREGROUND='#248069'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NON_EXISTENT_ANCHOR_FOREGROUND='#424242'
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLASSTING_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Claude (Anthropic)
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_BACKGROUND='#BD684B'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_SHORTENED_FOREGROUND='#603A2C'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_ANCHOR_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NOT_WRITABLE_BACKGROUND='#BD684B'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NOT_WRITABLE_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NOT_WRITABLE_SHORTENED_FOREGROUND='#603A2C'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NOT_WRITABLE_ANCHOR_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NON_EXISTENT_BACKGROUND='#BD684B'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NON_EXISTENT_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NON_EXISTENT_SHORTENED_FOREGROUND='#603A2C'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NON_EXISTENT_ANCHOR_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLAUDE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# ClickHouse
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_BACKGROUND='#A3A644'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_FOREGROUND='#373737'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_SHORTENED_FOREGROUND='#67693D'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_ANCHOR_FOREGROUND='#373737'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NOT_WRITABLE_BACKGROUND='#A3A644'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NOT_WRITABLE_FOREGROUND='#373737'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NOT_WRITABLE_SHORTENED_FOREGROUND='#67693D'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NOT_WRITABLE_ANCHOR_FOREGROUND='#373737'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NON_EXISTENT_BACKGROUND='#A3A644'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NON_EXISTENT_FOREGROUND='#373737'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NON_EXISTENT_SHORTENED_FOREGROUND='#67693D'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NON_EXISTENT_ANCHOR_FOREGROUND='#373737'
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLICKHOUSE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Cloudflare
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_BACKGROUND='#CC6C1A'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_FOREGROUND='#1D1F20'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_SHORTENED_FOREGROUND='#6C421D'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_ANCHOR_FOREGROUND='#1D1F20'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NOT_WRITABLE_BACKGROUND='#CC6C1A'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NOT_WRITABLE_FOREGROUND='#1D1F20'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NOT_WRITABLE_SHORTENED_FOREGROUND='#6C421D'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NOT_WRITABLE_ANCHOR_FOREGROUND='#1D1F20'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NON_EXISTENT_BACKGROUND='#CC6C1A'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NON_EXISTENT_FOREGROUND='#1D1F20'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NON_EXISTENT_SHORTENED_FOREGROUND='#6C421D'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NON_EXISTENT_ANCHOR_FOREGROUND='#1D1F20'
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CLOUDFLARE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Codeit
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_BACKGROUND='#451773'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_SHORTENED_FOREGROUND='#2B1844'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NOT_WRITABLE_BACKGROUND='#451773'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NOT_WRITABLE_SHORTENED_FOREGROUND='#2B1844'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NON_EXISTENT_BACKGROUND='#451773'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NON_EXISTENT_SHORTENED_FOREGROUND='#2B1844'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CODEIT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Coinbase
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_BACKGROUND='#002573'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_FOREGROUND='#0A0B0D'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_SHORTENED_FOREGROUND='#06173B'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_ANCHOR_FOREGROUND='#0A0B0D'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NOT_WRITABLE_BACKGROUND='#002573'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NOT_WRITABLE_FOREGROUND='#0A0B0D'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NOT_WRITABLE_SHORTENED_FOREGROUND='#06173B'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NOT_WRITABLE_ANCHOR_FOREGROUND='#0A0B0D'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NON_EXISTENT_BACKGROUND='#002573'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NON_EXISTENT_FOREGROUND='#0A0B0D'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NON_EXISTENT_SHORTENED_FOREGROUND='#06173B'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NON_EXISTENT_ANCHOR_FOREGROUND='#0A0B0D'
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COINBASE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Coinone
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_BACKGROUND='#003060'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_FOREGROUND='#17181B'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_SHORTENED_FOREGROUND='#0D233A'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_ANCHOR_FOREGROUND='#17181B'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NOT_WRITABLE_BACKGROUND='#003060'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NOT_WRITABLE_FOREGROUND='#17181B'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NOT_WRITABLE_SHORTENED_FOREGROUND='#0D233A'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NOT_WRITABLE_ANCHOR_FOREGROUND='#17181B'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NON_EXISTENT_BACKGROUND='#003060'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NON_EXISTENT_FOREGROUND='#17181B'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NON_EXISTENT_SHORTENED_FOREGROUND='#0D233A'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NON_EXISTENT_ANCHOR_FOREGROUND='#17181B'
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COINONE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Composio
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_BACKGROUND='#24266C'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_SHORTENED_FOREGROUND='#9D9DBD'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NOT_WRITABLE_BACKGROUND='#24266C'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NOT_WRITABLE_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NOT_WRITABLE_SHORTENED_FOREGROUND='#9D9DBD'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NOT_WRITABLE_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NON_EXISTENT_BACKGROUND='#24266C'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NON_EXISTENT_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NON_EXISTENT_SHORTENED_FOREGROUND='#9D9DBD'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NON_EXISTENT_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COMPOSIO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Cookpad
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_BACKGROUND='#B86E25'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_FOREGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_SHORTENED_FOREGROUND='#5B3A19'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_ANCHOR_FOREGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NOT_WRITABLE_BACKGROUND='#B86E25'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NOT_WRITABLE_FOREGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NOT_WRITABLE_SHORTENED_FOREGROUND='#5B3A19'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NOT_WRITABLE_ANCHOR_FOREGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NON_EXISTENT_BACKGROUND='#B86E25'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NON_EXISTENT_FOREGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NON_EXISTENT_SHORTENED_FOREGROUND='#5B3A19'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NON_EXISTENT_ANCHOR_FOREGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COOKPAD_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Coupang
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NOT_WRITABLE_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NON_EXISTENT_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_COUPANG_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Cursor
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_BACKGROUND='#11110D'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_SHORTENED_FOREGROUND='#141516'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NOT_WRITABLE_BACKGROUND='#11110D'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NOT_WRITABLE_SHORTENED_FOREGROUND='#141516'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NON_EXISTENT_BACKGROUND='#11110D'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NON_EXISTENT_SHORTENED_FOREGROUND='#141516'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CURSOR_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Cybozu
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_BACKGROUND='#1190A8'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_SHORTENED_FOREGROUND='#144E5C'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NOT_WRITABLE_BACKGROUND='#1190A8'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NOT_WRITABLE_SHORTENED_FOREGROUND='#144E5C'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NON_EXISTENT_BACKGROUND='#1190A8'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NON_EXISTENT_SHORTENED_FOREGROUND='#144E5C'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_CYBOZU_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Databricks
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_BACKGROUND='#EB4331'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_SHORTENED_FOREGROUND='#762B26'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NOT_WRITABLE_BACKGROUND='#EB4331'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NOT_WRITABLE_SHORTENED_FOREGROUND='#762B26'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NON_EXISTENT_BACKGROUND='#EB4331'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NON_EXISTENT_SHORTENED_FOREGROUND='#762B26'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DATABRICKS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Dcard
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_BACKGROUND='#0076E0'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_SHORTENED_FOREGROUND='#003565'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NOT_WRITABLE_BACKGROUND='#0076E0'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NOT_WRITABLE_SHORTENED_FOREGROUND='#003565'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NON_EXISTENT_BACKGROUND='#0076E0'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NON_EXISTENT_SHORTENED_FOREGROUND='#003565'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DCARD_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Sinsang Market (Dealicious)
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_BACKGROUND='#000C25'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_SHORTENED_FOREGROUND='#0C1320'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NOT_WRITABLE_BACKGROUND='#000C25'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C1320'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NON_EXISTENT_BACKGROUND='#000C25'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NON_EXISTENT_SHORTENED_FOREGROUND='#0C1320'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DEALICIOUS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Deliveroo
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_BACKGROUND='#009387'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_SHORTENED_FOREGROUND='#0C4F4D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NOT_WRITABLE_BACKGROUND='#009387'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C4F4D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NON_EXISTENT_BACKGROUND='#009387'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NON_EXISTENT_SHORTENED_FOREGROUND='#0C4F4D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DELIVEROO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Dell
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_BACKGROUND='#00355D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_SHORTENED_FOREGROUND='#0C253A'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NOT_WRITABLE_BACKGROUND='#00355D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C253A'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NON_EXISTENT_BACKGROUND='#00355D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NON_EXISTENT_SHORTENED_FOREGROUND='#0C253A'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DELL_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Discord
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_BACKGROUND='#282D6D'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_SHORTENED_FOREGROUND='#1E2241'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NOT_WRITABLE_BACKGROUND='#282D6D'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NOT_WRITABLE_SHORTENED_FOREGROUND='#1E2241'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NON_EXISTENT_BACKGROUND='#282D6D'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NON_EXISTENT_SHORTENED_FOREGROUND='#1E2241'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DISCORD_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# DJI
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DJI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# DMM.com (Turtle)
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_BACKGROUND='#6B87B8'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_SHORTENED_FOREGROUND='#3C4A63'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NOT_WRITABLE_BACKGROUND='#6B87B8'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NOT_WRITABLE_SHORTENED_FOREGROUND='#3C4A63'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NON_EXISTENT_BACKGROUND='#6B87B8'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NON_EXISTENT_SHORTENED_FOREGROUND='#3C4A63'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DMM_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# DoorDash
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_BACKGROUND='#6A0A00'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_SHORTENED_FOREGROUND='#3C1210'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NOT_WRITABLE_BACKGROUND='#6A0A00'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NOT_WRITABLE_SHORTENED_FOREGROUND='#3C1210'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NON_EXISTENT_BACKGROUND='#6A0A00'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NON_EXISTENT_SHORTENED_FOREGROUND='#3C1210'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DOORDASH_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Dr.diary
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_BACKGROUND='#3088C7'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_SHORTENED_FOREGROUND='#224A69'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NOT_WRITABLE_BACKGROUND='#3088C7'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NOT_WRITABLE_SHORTENED_FOREGROUND='#224A69'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NON_EXISTENT_BACKGROUND='#3088C7'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NON_EXISTENT_SHORTENED_FOREGROUND='#224A69'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DRDIARY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Dr.Now (닥터나우)
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_BACKGROUND='#C76E00'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_SHORTENED_FOREGROUND='#663F10'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NOT_WRITABLE_BACKGROUND='#C76E00'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NOT_WRITABLE_SHORTENED_FOREGROUND='#663F10'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NON_EXISTENT_BACKGROUND='#C76E00'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NON_EXISTENT_SHORTENED_FOREGROUND='#663F10'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DRNOW_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Dropbox
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_BACKGROUND='#002C72'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_SHORTENED_FOREGROUND='#0C2143'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NOT_WRITABLE_BACKGROUND='#002C72'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C2143'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NON_EXISTENT_BACKGROUND='#002C72'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NON_EXISTENT_SHORTENED_FOREGROUND='#0C2143'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DROPBOX_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Duolingo
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_BACKGROUND='#55C502'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_SHORTENED_FOREGROUND='#4A7C25'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_ANCHOR_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NOT_WRITABLE_BACKGROUND='#55C502'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NOT_WRITABLE_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NOT_WRITABLE_SHORTENED_FOREGROUND='#4A7C25'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NOT_WRITABLE_ANCHOR_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NON_EXISTENT_BACKGROUND='#55C502'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NON_EXISTENT_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NON_EXISTENT_SHORTENED_FOREGROUND='#4A7C25'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NON_EXISTENT_ANCHOR_FOREGROUND='#414141'
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_DUOLINGO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# EasyWallet
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_BACKGROUND='#003759'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_SHORTENED_FOREGROUND='#0C2638'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NOT_WRITABLE_BACKGROUND='#003759'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C2638'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NON_EXISTENT_BACKGROUND='#003759'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NON_EXISTENT_SHORTENED_FOREGROUND='#0C2638'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_EASYWALLET_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Elastic UI
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_BACKGROUND='#052D63'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_FOREGROUND='#1D2A3E'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_SHORTENED_FOREGROUND='#122B4F'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_ANCHOR_FOREGROUND='#1D2A3E'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NOT_WRITABLE_BACKGROUND='#052D63'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NOT_WRITABLE_FOREGROUND='#1D2A3E'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NOT_WRITABLE_SHORTENED_FOREGROUND='#122B4F'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NOT_WRITABLE_ANCHOR_FOREGROUND='#1D2A3E'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NON_EXISTENT_BACKGROUND='#052D63'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NON_EXISTENT_FOREGROUND='#1D2A3E'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NON_EXISTENT_SHORTENED_FOREGROUND='#122B4F'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NON_EXISTENT_ANCHOR_FOREGROUND='#1D2A3E'
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ELASTIC_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# ElevenLabs
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NOT_WRITABLE_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NON_EXISTENT_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ELEVENLABS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# E.SUN Bank
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_BACKGROUND='#00948F'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_SHORTENED_FOREGROUND='#0C5050'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NOT_WRITABLE_BACKGROUND='#00948F'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C5050'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NON_EXISTENT_BACKGROUND='#00948F'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NON_EXISTENT_SHORTENED_FOREGROUND='#0C5050'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ESUNBANK_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Expo
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_FOREGROUND='#1C2024'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_SHORTENED_FOREGROUND='#181A1C'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_ANCHOR_FOREGROUND='#1C2024'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NOT_WRITABLE_FOREGROUND='#1C2024'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NOT_WRITABLE_SHORTENED_FOREGROUND='#181A1C'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NOT_WRITABLE_ANCHOR_FOREGROUND='#1C2024'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NON_EXISTENT_FOREGROUND='#1C2024'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NON_EXISTENT_SHORTENED_FOREGROUND='#181A1C'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NON_EXISTENT_ANCHOR_FOREGROUND='#1C2024'
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_EXPO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Farfetch
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_BACKGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_SHORTENED_FOREGROUND='#131417'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NOT_WRITABLE_BACKGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NOT_WRITABLE_SHORTENED_FOREGROUND='#131417'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NON_EXISTENT_BACKGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NON_EXISTENT_SHORTENED_FOREGROUND='#131417'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FARFETCH_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Fastcampus
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_BACKGROUND='#6A0116'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_SHORTENED_FOREGROUND='#3C0E1A'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NOT_WRITABLE_BACKGROUND='#6A0116'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NOT_WRITABLE_SHORTENED_FOREGROUND='#3C0E1A'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NON_EXISTENT_BACKGROUND='#6A0116'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NON_EXISTENT_SHORTENED_FOREGROUND='#3C0E1A'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FASTCAMPUS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Ferrari
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_BACKGROUND='#62120D'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_FOREGROUND='#181818'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_SHORTENED_FOREGROUND='#391613'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_ANCHOR_FOREGROUND='#181818'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NOT_WRITABLE_BACKGROUND='#62120D'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NOT_WRITABLE_FOREGROUND='#181818'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NOT_WRITABLE_SHORTENED_FOREGROUND='#391613'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NOT_WRITABLE_ANCHOR_FOREGROUND='#181818'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NON_EXISTENT_BACKGROUND='#62120D'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NON_EXISTENT_FOREGROUND='#181818'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NON_EXISTENT_SHORTENED_FOREGROUND='#391613'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NON_EXISTENT_ANCHOR_FOREGROUND='#181818'
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FERRARI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Figma
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FIGMA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Fitpet
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_BACKGROUND='#002473'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_SHORTENED_FOREGROUND='#0C1D44'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NOT_WRITABLE_BACKGROUND='#002473'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C1D44'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NON_EXISTENT_BACKGROUND='#002473'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NON_EXISTENT_SHORTENED_FOREGROUND='#0C1D44'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FITPET_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Framer
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_BACKGROUND='#002673'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_SHORTENED_FOREGROUND='#8C9DC0'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NOT_WRITABLE_BACKGROUND='#002673'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NOT_WRITABLE_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NOT_WRITABLE_SHORTENED_FOREGROUND='#8C9DC0'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NOT_WRITABLE_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NON_EXISTENT_BACKGROUND='#002673'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NON_EXISTENT_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NON_EXISTENT_SHORTENED_FOREGROUND='#8C9DC0'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NON_EXISTENT_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FRAMER_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# freee
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_BACKGROUND='#122D6C'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_SHORTENED_FOREGROUND='#142141'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NOT_WRITABLE_BACKGROUND='#122D6C'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NOT_WRITABLE_SHORTENED_FOREGROUND='#142141'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NON_EXISTENT_BACKGROUND='#122D6C'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NON_EXISTENT_SHORTENED_FOREGROUND='#142141'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FREEE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Frip
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_BACKGROUND='#371270'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_SHORTENED_FOREGROUND='#251643'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NOT_WRITABLE_BACKGROUND='#371270'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NOT_WRITABLE_SHORTENED_FOREGROUND='#251643'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NON_EXISTENT_BACKGROUND='#371270'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NON_EXISTENT_SHORTENED_FOREGROUND='#251643'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FRIP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Fubon
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_BACKGROUND='#008FBC'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_SHORTENED_FOREGROUND='#0C4E64'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NOT_WRITABLE_BACKGROUND='#008FBC'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C4E64'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NON_EXISTENT_BACKGROUND='#008FBC'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NON_EXISTENT_SHORTENED_FOREGROUND='#0C4E64'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FUBON_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Fugle
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_BACKGROUND='#B07E14'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_SHORTENED_FOREGROUND='#5B4619'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NOT_WRITABLE_BACKGROUND='#B07E14'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NOT_WRITABLE_SHORTENED_FOREGROUND='#5B4619'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NON_EXISTENT_BACKGROUND='#B07E14'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NON_EXISTENT_SHORTENED_FOREGROUND='#5B4619'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FUGLE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# FunNow
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_BACKGROUND='#EB4E33'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_SHORTENED_FOREGROUND='#763027'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NOT_WRITABLE_BACKGROUND='#EB4E33'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NOT_WRITABLE_SHORTENED_FOREGROUND='#763027'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NON_EXISTENT_BACKGROUND='#EB4E33'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NON_EXISTENT_SHORTENED_FOREGROUND='#763027'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_FUNNOW_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# 강남언니
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_BACKGROUND='#601E00'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_SHORTENED_FOREGROUND='#371B10'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NOT_WRITABLE_BACKGROUND='#601E00'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NOT_WRITABLE_SHORTENED_FOREGROUND='#371B10'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NON_EXISTENT_BACKGROUND='#601E00'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NON_EXISTENT_SHORTENED_FOREGROUND='#371B10'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GANGNAMUNNI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Gaudio Lab
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_BACKGROUND='#008FC7'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_SHORTENED_FOREGROUND='#0C4D69'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NOT_WRITABLE_BACKGROUND='#008FC7'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C4D69'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NON_EXISTENT_BACKGROUND='#008FC7'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NON_EXISTENT_SHORTENED_FOREGROUND='#0C4D69'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIOLAB_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Gaudiy
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GAUDIY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Genie Music
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_BACKGROUND='#E64D6C'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_SHORTENED_FOREGROUND='#743040'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NOT_WRITABLE_BACKGROUND='#E64D6C'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NOT_WRITABLE_SHORTENED_FOREGROUND='#743040'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NON_EXISTENT_BACKGROUND='#E64D6C'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NON_EXISTENT_SHORTENED_FOREGROUND='#743040'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GENIE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# GitHub
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_BACKGROUND='#042F62'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_SHORTENED_FOREGROUND='#0E223C'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NOT_WRITABLE_BACKGROUND='#042F62'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NOT_WRITABLE_SHORTENED_FOREGROUND='#0E223C'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NON_EXISTENT_BACKGROUND='#042F62'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NON_EXISTENT_SHORTENED_FOREGROUND='#0E223C'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GITHUB_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# GitLab
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_BACKGROUND='#0E355B'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_SHORTENED_FOREGROUND='#122539'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NOT_WRITABLE_BACKGROUND='#0E355B'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NOT_WRITABLE_SHORTENED_FOREGROUND='#122539'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NON_EXISTENT_BACKGROUND='#0E355B'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NON_EXISTENT_SHORTENED_FOREGROUND='#122539'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GITLAB_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Gogoro
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOGORO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Google
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_BACKGROUND='#0C3468'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_FOREGROUND='#3C4043'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_SHORTENED_FOREGROUND='#263A54'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_ANCHOR_FOREGROUND='#3C4043'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NOT_WRITABLE_BACKGROUND='#0C3468'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NOT_WRITABLE_FOREGROUND='#3C4043'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NOT_WRITABLE_SHORTENED_FOREGROUND='#263A54'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NOT_WRITABLE_ANCHOR_FOREGROUND='#3C4043'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NON_EXISTENT_BACKGROUND='#0C3468'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NON_EXISTENT_FOREGROUND='#3C4043'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NON_EXISTENT_SHORTENED_FOREGROUND='#263A54'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NON_EXISTENT_ANCHOR_FOREGROUND='#3C4043'
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOOGLE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# goorm
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_BACKGROUND='#133367'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_SHORTENED_FOREGROUND='#15243E'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NOT_WRITABLE_BACKGROUND='#133367'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NOT_WRITABLE_SHORTENED_FOREGROUND='#15243E'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NON_EXISTENT_BACKGROUND='#133367'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NON_EXISTENT_SHORTENED_FOREGROUND='#15243E'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOORM_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# GOV.UK
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_BACKGROUND='#0D3253'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_FOREGROUND='#0B0C0C'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_SHORTENED_FOREGROUND='#0C1D2C'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_ANCHOR_FOREGROUND='#0B0C0C'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NOT_WRITABLE_BACKGROUND='#0D3253'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NOT_WRITABLE_FOREGROUND='#0B0C0C'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C1D2C'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NOT_WRITABLE_ANCHOR_FOREGROUND='#0B0C0C'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NON_EXISTENT_BACKGROUND='#0D3253'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NON_EXISTENT_FOREGROUND='#0B0C0C'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NON_EXISTENT_SHORTENED_FOREGROUND='#0C1D2C'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NON_EXISTENT_ANCHOR_FOREGROUND='#0B0C0C'
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GOVUK_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Greencar
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_BACKGROUND='#009C6D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_SHORTENED_FOREGROUND='#0C5341'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NOT_WRITABLE_BACKGROUND='#009C6D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C5341'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NON_EXISTENT_BACKGROUND='#009C6D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NON_EXISTENT_SHORTENED_FOREGROUND='#0C5341'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GREENCAR_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Greenvines
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_BACKGROUND='#00140B'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_SHORTENED_FOREGROUND='#0C1615'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NOT_WRITABLE_BACKGROUND='#00140B'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C1615'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NON_EXISTENT_BACKGROUND='#00140B'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NON_EXISTENT_SHORTENED_FOREGROUND='#0C1615'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_GREENVINES_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Hackle
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_SHORTENED_FOREGROUND='#0C2244'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NOT_WRITABLE_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C2244'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NON_EXISTENT_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NON_EXISTENT_SHORTENED_FOREGROUND='#0C2244'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HACKLE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Hahow
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_BACKGROUND='#009382'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_SHORTENED_FOREGROUND='#0C4F4A'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NOT_WRITABLE_BACKGROUND='#009382'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C4F4A'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NON_EXISTENT_BACKGROUND='#009382'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NON_EXISTENT_SHORTENED_FOREGROUND='#0C4F4A'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HAHOW_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Hana Bank
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_BACKGROUND='#008F8C'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_SHORTENED_FOREGROUND='#0C4E4F'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NOT_WRITABLE_BACKGROUND='#008F8C'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C4E4F'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NON_EXISTENT_BACKGROUND='#008F8C'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NON_EXISTENT_SHORTENED_FOREGROUND='#0C4E4F'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HANA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Hashicorp
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_BACKGROUND='#072B73'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_FOREGROUND='#3B3D45'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_SHORTENED_FOREGROUND='#24355A'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_ANCHOR_FOREGROUND='#3B3D45'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NOT_WRITABLE_BACKGROUND='#072B73'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NOT_WRITABLE_FOREGROUND='#3B3D45'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NOT_WRITABLE_SHORTENED_FOREGROUND='#24355A'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NOT_WRITABLE_ANCHOR_FOREGROUND='#3B3D45'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NON_EXISTENT_BACKGROUND='#072B73'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NON_EXISTENT_FOREGROUND='#3B3D45'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NON_EXISTENT_SHORTENED_FOREGROUND='#24355A'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NON_EXISTENT_ANCHOR_FOREGROUND='#3B3D45'
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HASHICORP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Headspace
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_BACKGROUND='#002C6C'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_SHORTENED_FOREGROUND='#0C2140'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NOT_WRITABLE_BACKGROUND='#002C6C'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C2140'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NON_EXISTENT_BACKGROUND='#002C6C'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NON_EXISTENT_SHORTENED_FOREGROUND='#0C2140'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HEADSPACE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# HP
typeset -g POWERLEVEL9K_DIR_BRAND_HP_BACKGROUND='#008AC5'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_SHORTENED_FOREGROUND='#0C4B69'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NOT_WRITABLE_BACKGROUND='#008AC5'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C4B69'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NON_EXISTENT_BACKGROUND='#008AC5'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NON_EXISTENT_SHORTENED_FOREGROUND='#0C4B69'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# HubSpot
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_BACKGROUND='#EB5013'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_SHORTENED_FOREGROUND='#763118'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NOT_WRITABLE_BACKGROUND='#EB5013'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NOT_WRITABLE_SHORTENED_FOREGROUND='#763118'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NON_EXISTENT_BACKGROUND='#EB5013'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NON_EXISTENT_SHORTENED_FOREGROUND='#763118'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HUBSPOT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Humanscape
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_BACKGROUND='#0090CD'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_SHORTENED_FOREGROUND='#0C4E6C'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NOT_WRITABLE_BACKGROUND='#0090CD'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C4E6C'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NON_EXISTENT_BACKGROUND='#0090CD'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NON_EXISTENT_SHORTENED_FOREGROUND='#0C4E6C'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HUMANSCAPE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Hwahae
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_BACKGROUND='#009994'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_SHORTENED_FOREGROUND='#0C5253'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NOT_WRITABLE_BACKGROUND='#009994'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C5253'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NON_EXISTENT_BACKGROUND='#009994'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NON_EXISTENT_SHORTENED_FOREGROUND='#0C5253'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HWAHAE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Hyundai
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_BACKGROUND='#00142B'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_SHORTENED_FOREGROUND='#0C1623'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NOT_WRITABLE_BACKGROUND='#00142B'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C1623'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NON_EXISTENT_BACKGROUND='#00142B'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NON_EXISTENT_SHORTENED_FOREGROUND='#0C1623'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_HYUNDAI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# IBM
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_BACKGROUND='#072C72'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_SHORTENED_FOREGROUND='#0F2040'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_ANCHOR_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NOT_WRITABLE_BACKGROUND='#072C72'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NOT_WRITABLE_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NOT_WRITABLE_SHORTENED_FOREGROUND='#0F2040'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NOT_WRITABLE_ANCHOR_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NON_EXISTENT_BACKGROUND='#072C72'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NON_EXISTENT_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NON_EXISTENT_SHORTENED_FOREGROUND='#0F2040'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NON_EXISTENT_ANCHOR_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IBM_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# idus (Backpackr)
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_BACKGROUND='#D26312'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_SHORTENED_FOREGROUND='#6B3A18'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NOT_WRITABLE_BACKGROUND='#D26312'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NOT_WRITABLE_SHORTENED_FOREGROUND='#6B3A18'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NON_EXISTENT_BACKGROUND='#D26312'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NON_EXISTENT_SHORTENED_FOREGROUND='#6B3A18'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IDUS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# IGAWorks
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_BACKGROUND='#0C0D10'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_SHORTENED_FOREGROUND='#111317'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NOT_WRITABLE_BACKGROUND='#0C0D10'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NOT_WRITABLE_SHORTENED_FOREGROUND='#111317'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NON_EXISTENT_BACKGROUND='#0C0D10'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NON_EXISTENT_SHORTENED_FOREGROUND='#111317'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IGAWORKS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# IICOMBINED
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IICOMBINED_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Inflearn
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_BACKGROUND='#009958'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_SHORTENED_FOREGROUND='#0C5238'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NOT_WRITABLE_BACKGROUND='#009958'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C5238'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NON_EXISTENT_BACKGROUND='#009958'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NON_EXISTENT_SHORTENED_FOREGROUND='#0C5238'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_INFLEARN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Instacart
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_BACKGROUND='#073E07'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_SHORTENED_FOREGROUND='#0F2913'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NOT_WRITABLE_BACKGROUND='#073E07'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NOT_WRITABLE_SHORTENED_FOREGROUND='#0F2913'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NON_EXISTENT_BACKGROUND='#073E07'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NON_EXISTENT_SHORTENED_FOREGROUND='#0F2913'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_INSTACART_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Intercom
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_BACKGROUND='#092B70'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_SHORTENED_FOREGROUND='#102142'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NOT_WRITABLE_BACKGROUND='#092B70'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NOT_WRITABLE_SHORTENED_FOREGROUND='#102142'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NON_EXISTENT_BACKGROUND='#092B70'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NON_EXISTENT_SHORTENED_FOREGROUND='#102142'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_INTERCOM_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# iPASS MONEY
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_BACKGROUND='#459429'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_SHORTENED_FOREGROUND='#2B5023'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NOT_WRITABLE_BACKGROUND='#459429'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NOT_WRITABLE_SHORTENED_FOREGROUND='#2B5023'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NON_EXISTENT_BACKGROUND='#459429'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NON_EXISTENT_SHORTENED_FOREGROUND='#2B5023'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_IPASSMONEY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# JANDI
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_BACKGROUND='#00995A'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_SHORTENED_FOREGROUND='#0C5238'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NOT_WRITABLE_BACKGROUND='#00995A'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C5238'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NON_EXISTENT_BACKGROUND='#00995A'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NON_EXISTENT_SHORTENED_FOREGROUND='#0C5238'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_JANDI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Kakao
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_BACKGROUND='#B7A500'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_SHORTENED_FOREGROUND='#6E661C'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NOT_WRITABLE_BACKGROUND='#B7A500'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NOT_WRITABLE_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NOT_WRITABLE_SHORTENED_FOREGROUND='#6E661C'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NOT_WRITABLE_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NON_EXISTENT_BACKGROUND='#B7A500'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NON_EXISTENT_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NON_EXISTENT_SHORTENED_FOREGROUND='#6E661C'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NON_EXISTENT_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# KakaoBank
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_BACKGROUND='#8C7D00'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_SHORTENED_FOREGROUND='#3F3800'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NOT_WRITABLE_BACKGROUND='#8C7D00'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NOT_WRITABLE_SHORTENED_FOREGROUND='#3F3800'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NON_EXISTENT_BACKGROUND='#8C7D00'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NON_EXISTENT_SHORTENED_FOREGROUND='#3F3800'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOBANK_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# 카카오게임즈
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOGAMES_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Kakao T
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_BACKGROUND='#A59500'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_SHORTENED_FOREGROUND='#58510E'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_ANCHOR_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NOT_WRITABLE_BACKGROUND='#A59500'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NOT_WRITABLE_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NOT_WRITABLE_SHORTENED_FOREGROUND='#58510E'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NOT_WRITABLE_ANCHOR_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NON_EXISTENT_BACKGROUND='#A59500'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NON_EXISTENT_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NON_EXISTENT_SHORTENED_FOREGROUND='#58510E'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NON_EXISTENT_ANCHOR_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KAKAOT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Karrot
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_BACKGROUND='#E06F30'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_FOREGROUND='#212124'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_SHORTENED_FOREGROUND='#774429'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_ANCHOR_FOREGROUND='#212124'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NOT_WRITABLE_BACKGROUND='#E06F30'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NOT_WRITABLE_FOREGROUND='#212124'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NOT_WRITABLE_SHORTENED_FOREGROUND='#774429'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NOT_WRITABLE_ANCHOR_FOREGROUND='#212124'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NON_EXISTENT_BACKGROUND='#E06F30'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NON_EXISTENT_FOREGROUND='#212124'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NON_EXISTENT_SHORTENED_FOREGROUND='#774429'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NON_EXISTENT_ANCHOR_FOREGROUND='#212124'
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KARROT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Korea Credit Data
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_BACKGROUND='#2985EB'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_SHORTENED_FOREGROUND='#1F497A'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NOT_WRITABLE_BACKGROUND='#2985EB'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NOT_WRITABLE_SHORTENED_FOREGROUND='#1F497A'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NON_EXISTENT_BACKGROUND='#2985EB'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NON_EXISTENT_SHORTENED_FOREGROUND='#1F497A'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KCD_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Kdan Mobile
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_BACKGROUND='#009E61'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_SHORTENED_FOREGROUND='#0E5539'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_ANCHOR_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NOT_WRITABLE_BACKGROUND='#009E61'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NOT_WRITABLE_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NOT_WRITABLE_SHORTENED_FOREGROUND='#0E5539'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NOT_WRITABLE_ANCHOR_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NON_EXISTENT_BACKGROUND='#009E61'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NON_EXISTENT_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NON_EXISTENT_SHORTENED_FOREGROUND='#0E5539'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NON_EXISTENT_ANCHOR_FOREGROUND='#191919'
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KDAN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Kia
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_BACKGROUND='#051420'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_SHORTENED_FOREGROUND='#0E161E'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NOT_WRITABLE_BACKGROUND='#051420'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NOT_WRITABLE_SHORTENED_FOREGROUND='#0E161E'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NON_EXISTENT_BACKGROUND='#051420'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NON_EXISTENT_SHORTENED_FOREGROUND='#0E161E'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KIA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Kraken
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_BACKGROUND='#271D62'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_FOREGROUND='#101114'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_SHORTENED_FOREGROUND='#1A1737'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_ANCHOR_FOREGROUND='#101114'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NOT_WRITABLE_BACKGROUND='#271D62'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NOT_WRITABLE_FOREGROUND='#101114'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NOT_WRITABLE_SHORTENED_FOREGROUND='#1A1737'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NOT_WRITABLE_ANCHOR_FOREGROUND='#101114'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NON_EXISTENT_BACKGROUND='#271D62'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NON_EXISTENT_FOREGROUND='#101114'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NON_EXISTENT_SHORTENED_FOREGROUND='#1A1737'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NON_EXISTENT_ANCHOR_FOREGROUND='#101114'
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KRAKEN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# KREAM
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_SHORTENED_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NOT_WRITABLE_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NOT_WRITABLE_SHORTENED_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NOT_WRITABLE_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NON_EXISTENT_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NON_EXISTENT_SHORTENED_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NON_EXISTENT_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KREAM_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Kurly
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_BACKGROUND='#2B003A'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_SHORTENED_FOREGROUND='#2F1C36'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NOT_WRITABLE_BACKGROUND='#2B003A'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NOT_WRITABLE_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NOT_WRITABLE_SHORTENED_FOREGROUND='#2F1C36'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NOT_WRITABLE_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NON_EXISTENT_BACKGROUND='#2B003A'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NON_EXISTENT_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NON_EXISTENT_SHORTENED_FOREGROUND='#2F1C36'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NON_EXISTENT_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KURLY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Kyobo Book Centre
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_BACKGROUND='#242650'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_SHORTENED_FOREGROUND='#1C1E34'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NOT_WRITABLE_BACKGROUND='#242650'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NOT_WRITABLE_SHORTENED_FOREGROUND='#1C1E34'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NON_EXISTENT_BACKGROUND='#242650'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NON_EXISTENT_SHORTENED_FOREGROUND='#1C1E34'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_KYOBOBOOK_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Lablup
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_BACKGROUND='#23965F'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_SHORTENED_FOREGROUND='#1C513B'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NOT_WRITABLE_BACKGROUND='#23965F'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NOT_WRITABLE_SHORTENED_FOREGROUND='#1C513B'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NON_EXISTENT_BACKGROUND='#23965F'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NON_EXISTENT_SHORTENED_FOREGROUND='#1C513B'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LABLUP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Lamborghini
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_BACKGROUND='#B88A00'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_FOREGROUND='#202020'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_SHORTENED_FOREGROUND='#645012'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_ANCHOR_FOREGROUND='#202020'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NOT_WRITABLE_BACKGROUND='#B88A00'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NOT_WRITABLE_FOREGROUND='#202020'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NOT_WRITABLE_SHORTENED_FOREGROUND='#645012'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NOT_WRITABLE_ANCHOR_FOREGROUND='#202020'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NON_EXISTENT_BACKGROUND='#B88A00'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NON_EXISTENT_FOREGROUND='#202020'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NON_EXISTENT_SHORTENED_FOREGROUND='#645012'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NON_EXISTENT_ANCHOR_FOREGROUND='#202020'
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LAMBORGHINI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# LaundryGo
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_BACKGROUND='#089770'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_SHORTENED_FOREGROUND='#105142'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NOT_WRITABLE_BACKGROUND='#089770'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NOT_WRITABLE_SHORTENED_FOREGROUND='#105142'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NON_EXISTENT_BACKGROUND='#089770'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NON_EXISTENT_SHORTENED_FOREGROUND='#105142'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LAUNDRYGO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# LayerX
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_BACKGROUND='#252373'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_SHORTENED_FOREGROUND='#1D1D44'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NOT_WRITABLE_BACKGROUND='#252373'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NOT_WRITABLE_SHORTENED_FOREGROUND='#1D1D44'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NON_EXISTENT_BACKGROUND='#252373'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NON_EXISTENT_SHORTENED_FOREGROUND='#1D1D44'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LAYERX_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Lemonbase
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_BACKGROUND='#3D83D9'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_SHORTENED_FOREGROUND='#284872'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NOT_WRITABLE_BACKGROUND='#3D83D9'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NOT_WRITABLE_SHORTENED_FOREGROUND='#284872'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NON_EXISTENT_BACKGROUND='#3D83D9'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NON_EXISTENT_SHORTENED_FOREGROUND='#284872'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LEMONBASE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Lezhin Comics
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_BACKGROUND='#6A0009'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_SHORTENED_FOREGROUND='#3C0D14'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NOT_WRITABLE_BACKGROUND='#6A0009'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NOT_WRITABLE_SHORTENED_FOREGROUND='#3C0D14'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NON_EXISTENT_BACKGROUND='#6A0009'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NON_EXISTENT_SHORTENED_FOREGROUND='#3C0D14'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LEZHIN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# LikeLion
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_BACKGROUND='#EB6413'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_SHORTENED_FOREGROUND='#7C401B'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NOT_WRITABLE_BACKGROUND='#EB6413'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NOT_WRITABLE_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NOT_WRITABLE_SHORTENED_FOREGROUND='#7C401B'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NOT_WRITABLE_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NON_EXISTENT_BACKGROUND='#EB6413'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NON_EXISTENT_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NON_EXISTENT_SHORTENED_FOREGROUND='#7C401B'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NON_EXISTENT_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LIKELION_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# LINE
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_BACKGROUND='#048F3D'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_SHORTENED_FOREGROUND='#02401C'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NOT_WRITABLE_BACKGROUND='#048F3D'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NOT_WRITABLE_SHORTENED_FOREGROUND='#02401C'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NON_EXISTENT_BACKGROUND='#048F3D'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NON_EXISTENT_SHORTENED_FOREGROUND='#02401C'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LINE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Linear
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_BACKGROUND='#2A305E'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_FOREGROUND='#F7F8F8'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_SHORTENED_FOREGROUND='#9B9EB3'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_ANCHOR_FOREGROUND='#F7F8F8'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NOT_WRITABLE_BACKGROUND='#2A305E'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NOT_WRITABLE_FOREGROUND='#F7F8F8'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NOT_WRITABLE_SHORTENED_FOREGROUND='#9B9EB3'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NOT_WRITABLE_ANCHOR_FOREGROUND='#F7F8F8'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NON_EXISTENT_BACKGROUND='#2A305E'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NON_EXISTENT_FOREGROUND='#F7F8F8'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NON_EXISTENT_SHORTENED_FOREGROUND='#9B9EB3'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NON_EXISTENT_ANCHOR_FOREGROUND='#F7F8F8'
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LINEAR.APP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Loom
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_BACKGROUND='#0B2F63'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_FOREGROUND='#101214'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_SHORTENED_FOREGROUND='#0E1F37'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_ANCHOR_FOREGROUND='#101214'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NOT_WRITABLE_BACKGROUND='#0B2F63'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NOT_WRITABLE_FOREGROUND='#101214'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NOT_WRITABLE_SHORTENED_FOREGROUND='#0E1F37'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NOT_WRITABLE_ANCHOR_FOREGROUND='#101214'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NON_EXISTENT_BACKGROUND='#0B2F63'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NON_EXISTENT_FOREGROUND='#101214'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NON_EXISTENT_SHORTENED_FOREGROUND='#0E1F37'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NON_EXISTENT_ANCHOR_FOREGROUND='#101214'
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LOOM_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Lunit
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_BACKGROUND='#07165D'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_SHORTENED_FOREGROUND='#0F173A'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NOT_WRITABLE_BACKGROUND='#07165D'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NOT_WRITABLE_SHORTENED_FOREGROUND='#0F173A'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NON_EXISTENT_BACKGROUND='#07165D'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NON_EXISTENT_SHORTENED_FOREGROUND='#0F173A'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_LUNIT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Mailchimp
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_BACKGROUND='#A69212'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_SHORTENED_FOREGROUND='#574F18'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NOT_WRITABLE_BACKGROUND='#A69212'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NOT_WRITABLE_SHORTENED_FOREGROUND='#574F18'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NON_EXISTENT_BACKGROUND='#A69212'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NON_EXISTENT_SHORTENED_FOREGROUND='#574F18'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MAILCHIMP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Mastercard
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_BACKGROUND='#6A000C'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_SHORTENED_FOREGROUND='#3B0B10'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_ANCHOR_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NOT_WRITABLE_BACKGROUND='#6A000C'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NOT_WRITABLE_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NOT_WRITABLE_SHORTENED_FOREGROUND='#3B0B10'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NOT_WRITABLE_ANCHOR_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NON_EXISTENT_BACKGROUND='#6A000C'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NON_EXISTENT_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NON_EXISTENT_SHORTENED_FOREGROUND='#3B0B10'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NON_EXISTENT_ANCHOR_FOREGROUND='#141413'
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MASTERCARD_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# maum.ai (ex-MindsLab)
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_BACKGROUND='#1E2C73'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_SHORTENED_FOREGROUND='#192144'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NOT_WRITABLE_BACKGROUND='#1E2C73'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NOT_WRITABLE_SHORTENED_FOREGROUND='#192144'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NON_EXISTENT_BACKGROUND='#1E2C73'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NON_EXISTENT_SHORTENED_FOREGROUND='#192144'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MAUM-AI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Melon
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_BACKGROUND='#00A02F'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_SHORTENED_FOREGROUND='#0C5525'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NOT_WRITABLE_BACKGROUND='#00A02F'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C5525'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NON_EXISTENT_BACKGROUND='#00A02F'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NON_EXISTENT_SHORTENED_FOREGROUND='#0C5525'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MELON_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Mercury
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_BACKGROUND='#252E6A'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_SHORTENED_FOREGROUND='#1D2240'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NOT_WRITABLE_BACKGROUND='#252E6A'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NOT_WRITABLE_SHORTENED_FOREGROUND='#1D2240'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NON_EXISTENT_BACKGROUND='#252E6A'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NON_EXISTENT_SHORTENED_FOREGROUND='#1D2240'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MERCURY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Meta
typeset -g POWERLEVEL9K_DIR_BRAND_META_BACKGROUND='#002D65'
typeset -g POWERLEVEL9K_DIR_BRAND_META_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_META_SHORTENED_FOREGROUND='#0C213D'
typeset -g POWERLEVEL9K_DIR_BRAND_META_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_META_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_META_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_META_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_META_NOT_WRITABLE_BACKGROUND='#002D65'
typeset -g POWERLEVEL9K_DIR_BRAND_META_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_META_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C213D'
typeset -g POWERLEVEL9K_DIR_BRAND_META_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_META_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_META_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_META_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_META_NON_EXISTENT_BACKGROUND='#002D65'
typeset -g POWERLEVEL9K_DIR_BRAND_META_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_META_NON_EXISTENT_SHORTENED_FOREGROUND='#0C213D'
typeset -g POWERLEVEL9K_DIR_BRAND_META_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_META_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_META_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_META_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Milddang (I Hate Flying Bugs)
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_BACKGROUND='#009482'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_SHORTENED_FOREGROUND='#0C504B'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NOT_WRITABLE_BACKGROUND='#009482'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C504B'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NON_EXISTENT_BACKGROUND='#009482'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NON_EXISTENT_SHORTENED_FOREGROUND='#0C504B'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MILDANG_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# MiniMax
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MINIMAX_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Mintlify
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_BACKGROUND='#0D9272'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_SHORTENED_FOREGROUND='#124F43'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NOT_WRITABLE_BACKGROUND='#0D9272'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NOT_WRITABLE_SHORTENED_FOREGROUND='#124F43'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NON_EXISTENT_BACKGROUND='#0D9272'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NON_EXISTENT_SHORTENED_FOREGROUND='#124F43'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MINTLIFY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Miro
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_BACKGROUND='#A49234'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_SHORTENED_FOREGROUND='#564F27'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NOT_WRITABLE_BACKGROUND='#A49234'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NOT_WRITABLE_SHORTENED_FOREGROUND='#564F27'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NON_EXISTENT_BACKGROUND='#A49234'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NON_EXISTENT_SHORTENED_FOREGROUND='#564F27'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MIRO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Mistral AI
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NOT_WRITABLE_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NON_EXISTENT_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MISTRAL.AI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# MIXI
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MIXI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Modusign
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_BACKGROUND='#A5873E'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_SHORTENED_FOREGROUND='#564A2C'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NOT_WRITABLE_BACKGROUND='#A5873E'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NOT_WRITABLE_SHORTENED_FOREGROUND='#564A2C'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NON_EXISTENT_BACKGROUND='#A5873E'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NON_EXISTENT_SHORTENED_FOREGROUND='#564A2C'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MODUSIGN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Moin
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_BACKGROUND='#1381EB'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_SHORTENED_FOREGROUND='#15477A'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NOT_WRITABLE_BACKGROUND='#1381EB'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NOT_WRITABLE_SHORTENED_FOREGROUND='#15477A'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NON_EXISTENT_BACKGROUND='#1381EB'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NON_EXISTENT_SHORTENED_FOREGROUND='#15477A'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOIN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# momo購物網
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_BACKGROUND='#601233'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_FOREGROUND='#404040'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_SHORTENED_FOREGROUND='#4F2B3A'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_ANCHOR_FOREGROUND='#404040'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NOT_WRITABLE_BACKGROUND='#601233'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NOT_WRITABLE_FOREGROUND='#404040'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NOT_WRITABLE_SHORTENED_FOREGROUND='#4F2B3A'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NOT_WRITABLE_ANCHOR_FOREGROUND='#404040'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NON_EXISTENT_BACKGROUND='#601233'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NON_EXISTENT_FOREGROUND='#404040'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NON_EXISTENT_SHORTENED_FOREGROUND='#4F2B3A'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NON_EXISTENT_ANCHOR_FOREGROUND='#404040'
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOMOSHOP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Money Forward
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_BACKGROUND='#123368'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_SHORTENED_FOREGROUND='#24334B'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NOT_WRITABLE_BACKGROUND='#123368'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NOT_WRITABLE_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NOT_WRITABLE_SHORTENED_FOREGROUND='#24334B'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NOT_WRITABLE_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NON_EXISTENT_BACKGROUND='#123368'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NON_EXISTENT_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NON_EXISTENT_SHORTENED_FOREGROUND='#24334B'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NON_EXISTENT_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MONEY-FORWARD_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# MongoDB
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_BACKGROUND='#009A41'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_SHORTENED_FOREGROUND='#0C532D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NOT_WRITABLE_BACKGROUND='#009A41'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C532D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NON_EXISTENT_BACKGROUND='#009A41'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NON_EXISTENT_SHORTENED_FOREGROUND='#0C532D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MONGODB_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Monzo
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_BACKGROUND='#EB493B'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_SHORTENED_FOREGROUND='#762E2A'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NOT_WRITABLE_BACKGROUND='#EB493B'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NOT_WRITABLE_SHORTENED_FOREGROUND='#762E2A'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NON_EXISTENT_BACKGROUND='#EB493B'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NON_EXISTENT_SHORTENED_FOREGROUND='#762E2A'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MONZO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Moreh
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_BACKGROUND='#EB5000'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_SHORTENED_FOREGROUND='#763110'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NOT_WRITABLE_BACKGROUND='#EB5000'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NOT_WRITABLE_SHORTENED_FOREGROUND='#763110'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NON_EXISTENT_BACKGROUND='#EB5000'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NON_EXISTENT_SHORTENED_FOREGROUND='#763110'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOREH_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# MOZE
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_BACKGROUND='#EB447E'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_SHORTENED_FOREGROUND='#762C49'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NOT_WRITABLE_BACKGROUND='#EB447E'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NOT_WRITABLE_SHORTENED_FOREGROUND='#762C49'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NON_EXISTENT_BACKGROUND='#EB447E'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NON_EXISTENT_SHORTENED_FOREGROUND='#762C49'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MOZE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# MUJI
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_BACKGROUND='#39000B'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_SHORTENED_FOREGROUND='#361C21'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NOT_WRITABLE_BACKGROUND='#39000B'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NOT_WRITABLE_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NOT_WRITABLE_SHORTENED_FOREGROUND='#361C21'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NOT_WRITABLE_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NON_EXISTENT_BACKGROUND='#39000B'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NON_EXISTENT_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NON_EXISTENT_SHORTENED_FOREGROUND='#361C21'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NON_EXISTENT_ANCHOR_FOREGROUND='#333333'
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MUJI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Musinsa
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NOT_WRITABLE_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NON_EXISTENT_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MUSINSA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# MUSTIT
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_BACKGROUND='#5E0000'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_SHORTENED_FOREGROUND='#3D1313'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NOT_WRITABLE_BACKGROUND='#5E0000'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NOT_WRITABLE_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NOT_WRITABLE_SHORTENED_FOREGROUND='#3D1313'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NOT_WRITABLE_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NON_EXISTENT_BACKGROUND='#5E0000'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NON_EXISTENT_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NON_EXISTENT_SHORTENED_FOREGROUND='#3D1313'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NON_EXISTENT_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MUSTIT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# マイナビ
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_BACKGROUND='#003354'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_SHORTENED_FOREGROUND='#0C2436'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NOT_WRITABLE_BACKGROUND='#003354'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C2436'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NON_EXISTENT_BACKGROUND='#003354'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NON_EXISTENT_SHORTENED_FOREGROUND='#0C2436'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MYNAVI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# MyRealTrip
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_BACKGROUND='#288ADA'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_SHORTENED_FOREGROUND='#1E4B72'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NOT_WRITABLE_BACKGROUND='#288ADA'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NOT_WRITABLE_SHORTENED_FOREGROUND='#1E4B72'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NON_EXISTENT_BACKGROUND='#288ADA'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NON_EXISTENT_SHORTENED_FOREGROUND='#1E4B72'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_MYREALTRIP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Naver
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_BACKGROUND='#029B46'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_SHORTENED_FOREGROUND='#0D5330'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NOT_WRITABLE_BACKGROUND='#029B46'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NOT_WRITABLE_SHORTENED_FOREGROUND='#0D5330'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NON_EXISTENT_BACKGROUND='#029B46'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NON_EXISTENT_SHORTENED_FOREGROUND='#0D5330'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NAVER_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Naver Webtoon
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_BACKGROUND='#008F41'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_SHORTENED_FOREGROUND='#00401D'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NOT_WRITABLE_BACKGROUND='#008F41'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NOT_WRITABLE_SHORTENED_FOREGROUND='#00401D'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NON_EXISTENT_BACKGROUND='#008F41'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NON_EXISTENT_SHORTENED_FOREGROUND='#00401D'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NAVERWEBTOON_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# NCSOFT
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_BACKGROUND='#331765'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_SHORTENED_FOREGROUND='#23183D'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NOT_WRITABLE_BACKGROUND='#331765'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NOT_WRITABLE_SHORTENED_FOREGROUND='#23183D'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NON_EXISTENT_BACKGROUND='#331765'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NON_EXISTENT_SHORTENED_FOREGROUND='#23183D'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NCSOFT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Netflix
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_BACKGROUND='#670409'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_SHORTENED_FOREGROUND='#BB8E90'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NOT_WRITABLE_BACKGROUND='#670409'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NOT_WRITABLE_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NOT_WRITABLE_SHORTENED_FOREGROUND='#BB8E90'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NOT_WRITABLE_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NON_EXISTENT_BACKGROUND='#670409'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NON_EXISTENT_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NON_EXISTENT_SHORTENED_FOREGROUND='#BB8E90'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NON_EXISTENT_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NETFLIX_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Nexon
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_BACKGROUND='#00A041'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_SHORTENED_FOREGROUND='#0C552D'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NOT_WRITABLE_BACKGROUND='#00A041'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C552D'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NON_EXISTENT_BACKGROUND='#00A041'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NON_EXISTENT_SHORTENED_FOREGROUND='#0C552D'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NEXON_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# NHN
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_BACKGROUND='#0F0F11'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_FOREGROUND='#36363D'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_SHORTENED_FOREGROUND='#242429'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_ANCHOR_FOREGROUND='#36363D'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NOT_WRITABLE_BACKGROUND='#0F0F11'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NOT_WRITABLE_FOREGROUND='#36363D'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NOT_WRITABLE_SHORTENED_FOREGROUND='#242429'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NOT_WRITABLE_ANCHOR_FOREGROUND='#36363D'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NON_EXISTENT_BACKGROUND='#0F0F11'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NON_EXISTENT_FOREGROUND='#36363D'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NON_EXISTENT_SHORTENED_FOREGROUND='#242429'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NON_EXISTENT_ANCHOR_FOREGROUND='#36363D'
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NHN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Nike
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NIKE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Nintendo
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_BACKGROUND='#670008'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_SHORTENED_FOREGROUND='#3B0D14'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NOT_WRITABLE_BACKGROUND='#670008'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NOT_WRITABLE_SHORTENED_FOREGROUND='#3B0D14'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NON_EXISTENT_BACKGROUND='#670008'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NON_EXISTENT_SHORTENED_FOREGROUND='#3B0D14'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NINTENDO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# NOL
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_BACKGROUND='#182173'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_FOREGROUND='#F5F6F9'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_SHORTENED_FOREGROUND='#9196BD'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_ANCHOR_FOREGROUND='#F5F6F9'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NOT_WRITABLE_BACKGROUND='#182173'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NOT_WRITABLE_FOREGROUND='#F5F6F9'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NOT_WRITABLE_SHORTENED_FOREGROUND='#9196BD'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NOT_WRITABLE_ANCHOR_FOREGROUND='#F5F6F9'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NON_EXISTENT_BACKGROUND='#182173'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NON_EXISTENT_FOREGROUND='#F5F6F9'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NON_EXISTENT_SHORTENED_FOREGROUND='#9196BD'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NON_EXISTENT_ANCHOR_FOREGROUND='#F5F6F9'
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOL_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Nota AI
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_BACKGROUND='#172D6C'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_SHORTENED_FOREGROUND='#162141'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NOT_WRITABLE_BACKGROUND='#172D6C'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NOT_WRITABLE_SHORTENED_FOREGROUND='#162141'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NON_EXISTENT_BACKGROUND='#172D6C'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NON_EXISTENT_SHORTENED_FOREGROUND='#162141'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOTA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# note
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_BACKGROUND='#2F9182'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_SHORTENED_FOREGROUND='#214E4A'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NOT_WRITABLE_BACKGROUND='#2F9182'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NOT_WRITABLE_SHORTENED_FOREGROUND='#214E4A'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NON_EXISTENT_BACKGROUND='#2F9182'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NON_EXISTENT_SHORTENED_FOREGROUND='#214E4A'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOTE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Notion
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_BACKGROUND='#003564'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_SHORTENED_FOREGROUND='#0C253D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NOT_WRITABLE_BACKGROUND='#003564'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C253D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NON_EXISTENT_BACKGROUND='#003564'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NON_EXISTENT_SHORTENED_FOREGROUND='#0C253D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NOTION_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# NVIDIA
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_BACKGROUND='#5C9000'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_SHORTENED_FOREGROUND='#364E10'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NOT_WRITABLE_BACKGROUND='#5C9000'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NOT_WRITABLE_SHORTENED_FOREGROUND='#364E10'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NON_EXISTENT_BACKGROUND='#5C9000'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NON_EXISTENT_SHORTENED_FOREGROUND='#364E10'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_NVIDIA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Olive Young
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_BACKGROUND='#558F1A'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_SHORTENED_FOREGROUND='#324E1C'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NOT_WRITABLE_BACKGROUND='#558F1A'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NOT_WRITABLE_SHORTENED_FOREGROUND='#324E1C'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NON_EXISTENT_BACKGROUND='#558F1A'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NON_EXISTENT_SHORTENED_FOREGROUND='#324E1C'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OLIVEYOUNG_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Ollama
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OLLAMA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# OpenAI
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_BACKGROUND='#0F9675'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_SHORTENED_FOREGROUND='#135145'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NOT_WRITABLE_BACKGROUND='#0F9675'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NOT_WRITABLE_SHORTENED_FOREGROUND='#135145'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NON_EXISTENT_BACKGROUND='#0F9675'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NON_EXISTENT_SHORTENED_FOREGROUND='#135145'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OPENAI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# OpenCode AI
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_FOREGROUND='#201D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_SHORTENED_FOREGROUND='#1A1818'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_ANCHOR_FOREGROUND='#201D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NOT_WRITABLE_FOREGROUND='#201D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NOT_WRITABLE_SHORTENED_FOREGROUND='#1A1818'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NOT_WRITABLE_ANCHOR_FOREGROUND='#201D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NON_EXISTENT_FOREGROUND='#201D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NON_EXISTENT_SHORTENED_FOREGROUND='#1A1818'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NON_EXISTENT_ANCHOR_FOREGROUND='#201D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OPENCODE.AI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# OPENPOINT
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_BACKGROUND='#7677EB'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_SHORTENED_FOREGROUND='#41437A'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NOT_WRITABLE_BACKGROUND='#7677EB'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NOT_WRITABLE_SHORTENED_FOREGROUND='#41437A'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NON_EXISTENT_BACKGROUND='#7677EB'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NON_EXISTENT_SHORTENED_FOREGROUND='#41437A'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_OPENPOINT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# PatternFly
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_BACKGROUND='#002E5C'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_FOREGROUND='#151515'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_SHORTENED_FOREGROUND='#0C2035'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_ANCHOR_FOREGROUND='#151515'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NOT_WRITABLE_BACKGROUND='#002E5C'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NOT_WRITABLE_FOREGROUND='#151515'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C2035'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NOT_WRITABLE_ANCHOR_FOREGROUND='#151515'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NON_EXISTENT_BACKGROUND='#002E5C'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NON_EXISTENT_FOREGROUND='#151515'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NON_EXISTENT_SHORTENED_FOREGROUND='#0C2035'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NON_EXISTENT_ANCHOR_FOREGROUND='#151515'
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PATTERNFLY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Payhere
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_BACKGROUND='#0081EB'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_SHORTENED_FOREGROUND='#0C477A'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NOT_WRITABLE_BACKGROUND='#0081EB'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C477A'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NON_EXISTENT_BACKGROUND='#0081EB'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NON_EXISTENT_SHORTENED_FOREGROUND='#0C477A'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PAYHERE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# PayPal
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_BACKGROUND='#001241'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_SHORTENED_FOREGROUND='#0C162D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NOT_WRITABLE_BACKGROUND='#001241'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C162D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NON_EXISTENT_BACKGROUND='#001241'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NON_EXISTENT_SHORTENED_FOREGROUND='#0C162D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PAYPAL_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Pega UX Design System
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_BACKGROUND='#0C1A29'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_FOREGROUND='#050505'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_SHORTENED_FOREGROUND='#080E15'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_ANCHOR_FOREGROUND='#050505'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NOT_WRITABLE_BACKGROUND='#0C1A29'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NOT_WRITABLE_FOREGROUND='#050505'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NOT_WRITABLE_SHORTENED_FOREGROUND='#080E15'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NOT_WRITABLE_ANCHOR_FOREGROUND='#050505'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NON_EXISTENT_BACKGROUND='#0C1A29'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NON_EXISTENT_FOREGROUND='#050505'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NON_EXISTENT_SHORTENED_FOREGROUND='#080E15'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NON_EXISTENT_ANCHOR_FOREGROUND='#050505'
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PEGA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# PeopleFund
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_BACKGROUND='#A67F1D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_SHORTENED_FOREGROUND='#57461D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NOT_WRITABLE_BACKGROUND='#A67F1D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NOT_WRITABLE_SHORTENED_FOREGROUND='#57461D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NON_EXISTENT_BACKGROUND='#A67F1D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NON_EXISTENT_SHORTENED_FOREGROUND='#57461D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PEOPLEFUND_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# GMO Pepabo (Inhouse)
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_BACKGROUND='#0D3354'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_SHORTENED_FOREGROUND='#122436'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NOT_WRITABLE_BACKGROUND='#0D3354'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NOT_WRITABLE_SHORTENED_FOREGROUND='#122436'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NON_EXISTENT_BACKGROUND='#0D3354'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NON_EXISTENT_SHORTENED_FOREGROUND='#122436'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PEPABO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Perplexity
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_BACKGROUND='#0E3A3F'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_SHORTENED_FOREGROUND='#13272D'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NOT_WRITABLE_BACKGROUND='#0E3A3F'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NOT_WRITABLE_SHORTENED_FOREGROUND='#13272D'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NON_EXISTENT_BACKGROUND='#0E3A3F'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NON_EXISTENT_SHORTENED_FOREGROUND='#13272D'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PERPLEXITY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Pinkoi
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_BACKGROUND='#E04E4F'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_SHORTENED_FOREGROUND='#713034'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NOT_WRITABLE_BACKGROUND='#E04E4F'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NOT_WRITABLE_SHORTENED_FOREGROUND='#713034'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NON_EXISTENT_BACKGROUND='#E04E4F'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NON_EXISTENT_SHORTENED_FOREGROUND='#713034'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PINKOI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Pinterest
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_BACKGROUND='#670010'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_SHORTENED_FOREGROUND='#3B0D17'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NOT_WRITABLE_BACKGROUND='#670010'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NOT_WRITABLE_SHORTENED_FOREGROUND='#3B0D17'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NON_EXISTENT_BACKGROUND='#670010'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NON_EXISTENT_SHORTENED_FOREGROUND='#3B0D17'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PINTEREST_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# pixiv
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_BACKGROUND='#0084DC'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_SHORTENED_FOREGROUND='#0C4973'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NOT_WRITABLE_BACKGROUND='#0084DC'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C4973'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NON_EXISTENT_BACKGROUND='#0084DC'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NON_EXISTENT_SHORTENED_FOREGROUND='#0C4973'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PIXIV_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# PortOne
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_BACKGROUND='#DE5E28'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_SHORTENED_FOREGROUND='#703822'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NOT_WRITABLE_BACKGROUND='#DE5E28'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NOT_WRITABLE_SHORTENED_FOREGROUND='#703822'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NON_EXISTENT_BACKGROUND='#DE5E28'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NON_EXISTENT_SHORTENED_FOREGROUND='#703822'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_PORTONE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# PostHog
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_BACKGROUND='#0D2173'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_FOREGROUND='#4D4F46'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_SHORTENED_FOREGROUND='#303A5A'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_ANCHOR_FOREGROUND='#4D4F46'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NOT_WRITABLE_BACKGROUND='#0D2173'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NOT_WRITABLE_FOREGROUND='#4D4F46'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NOT_WRITABLE_SHORTENED_FOREGROUND='#303A5A'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NOT_WRITABLE_ANCHOR_FOREGROUND='#4D4F46'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NON_EXISTENT_BACKGROUND='#0D2173'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NON_EXISTENT_FOREGROUND='#4D4F46'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NON_EXISTENT_SHORTENED_FOREGROUND='#303A5A'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NON_EXISTENT_ANCHOR_FOREGROUND='#4D4F46'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_POSTHOG_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# POSTYPE
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_BACKGROUND='#D85763'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_SHORTENED_FOREGROUND='#6D353C'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NOT_WRITABLE_BACKGROUND='#D85763'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NOT_WRITABLE_SHORTENED_FOREGROUND='#6D353C'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NON_EXISTENT_BACKGROUND='#D85763'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NON_EXISTENT_SHORTENED_FOREGROUND='#6D353C'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_POSTYPE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# POZAlabs
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_BACKGROUND='#857EC3'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_SHORTENED_FOREGROUND='#484668'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NOT_WRITABLE_BACKGROUND='#857EC3'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NOT_WRITABLE_SHORTENED_FOREGROUND='#484668'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NON_EXISTENT_BACKGROUND='#857EC3'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NON_EXISTENT_SHORTENED_FOREGROUND='#484668'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_POZALABS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Quotabook
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_BACKGROUND='#00D5B5'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_FOREGROUND='#4C4C4C'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_SHORTENED_FOREGROUND='#2A8A7C'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_ANCHOR_FOREGROUND='#4C4C4C'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NOT_WRITABLE_BACKGROUND='#00D5B5'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NOT_WRITABLE_FOREGROUND='#4C4C4C'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NOT_WRITABLE_SHORTENED_FOREGROUND='#2A8A7C'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NOT_WRITABLE_ANCHOR_FOREGROUND='#4C4C4C'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NON_EXISTENT_BACKGROUND='#00D5B5'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NON_EXISTENT_FOREGROUND='#4C4C4C'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NON_EXISTENT_SHORTENED_FOREGROUND='#2A8A7C'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NON_EXISTENT_ANCHOR_FOREGROUND='#4C4C4C'
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_QUOTABOOK_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Rakuten
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_BACKGROUND='#560000'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_SHORTENED_FOREGROUND='#330D10'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NOT_WRITABLE_BACKGROUND='#560000'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NOT_WRITABLE_SHORTENED_FOREGROUND='#330D10'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NON_EXISTENT_BACKGROUND='#560000'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NON_EXISTENT_SHORTENED_FOREGROUND='#330D10'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RAKUTEN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Raycast
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_BACKGROUND='#E05757'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_SHORTENED_FOREGROUND='#713437'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NOT_WRITABLE_BACKGROUND='#E05757'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NOT_WRITABLE_SHORTENED_FOREGROUND='#713437'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NON_EXISTENT_BACKGROUND='#E05757'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NON_EXISTENT_SHORTENED_FOREGROUND='#713437'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RAYCAST_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Readmoo
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_BACKGROUND='#2E90B2'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_SHORTENED_FOREGROUND='#214E60'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NOT_WRITABLE_BACKGROUND='#2E90B2'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NOT_WRITABLE_SHORTENED_FOREGROUND='#214E60'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NON_EXISTENT_BACKGROUND='#2E90B2'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NON_EXISTENT_SHORTENED_FOREGROUND='#214E60'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_READMOO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Rebellions
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_BACKGROUND='#35A138'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_SHORTENED_FOREGROUND='#245529'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NOT_WRITABLE_BACKGROUND='#35A138'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NOT_WRITABLE_SHORTENED_FOREGROUND='#245529'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NON_EXISTENT_BACKGROUND='#35A138'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NON_EXISTENT_SHORTENED_FOREGROUND='#245529'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REBELLIONS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# リクルート
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_BACKGROUND='#002D55'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_FOREGROUND='#2D3133'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_SHORTENED_FOREGROUND='#192F42'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_ANCHOR_FOREGROUND='#2D3133'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NOT_WRITABLE_BACKGROUND='#002D55'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NOT_WRITABLE_FOREGROUND='#2D3133'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NOT_WRITABLE_SHORTENED_FOREGROUND='#192F42'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NOT_WRITABLE_ANCHOR_FOREGROUND='#2D3133'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NON_EXISTENT_BACKGROUND='#002D55'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NON_EXISTENT_FOREGROUND='#2D3133'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NON_EXISTENT_SHORTENED_FOREGROUND='#192F42'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NON_EXISTENT_ANCHOR_FOREGROUND='#2D3133'
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RECRUIT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Reddit
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_BACKGROUND='#601A00'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_FOREGROUND='#333D42'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_SHORTENED_FOREGROUND='#472D24'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_ANCHOR_FOREGROUND='#333D42'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NOT_WRITABLE_BACKGROUND='#601A00'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NOT_WRITABLE_FOREGROUND='#333D42'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NOT_WRITABLE_SHORTENED_FOREGROUND='#472D24'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NOT_WRITABLE_ANCHOR_FOREGROUND='#333D42'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NON_EXISTENT_BACKGROUND='#601A00'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NON_EXISTENT_FOREGROUND='#333D42'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NON_EXISTENT_SHORTENED_FOREGROUND='#472D24'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NON_EXISTENT_ANCHOR_FOREGROUND='#333D42'
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REDDIT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Remember
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_SHORTENED_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NOT_WRITABLE_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NOT_WRITABLE_SHORTENED_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NOT_WRITABLE_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NON_EXISTENT_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NON_EXISTENT_SHORTENED_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NON_EXISTENT_ANCHOR_FOREGROUND='#222222'
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REMEMBER_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Renault
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_BACKGROUND='#A68500'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_SHORTENED_FOREGROUND='#574910'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NOT_WRITABLE_BACKGROUND='#A68500'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NOT_WRITABLE_SHORTENED_FOREGROUND='#574910'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NON_EXISTENT_BACKGROUND='#A68500'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NON_EXISTENT_SHORTENED_FOREGROUND='#574910'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RENAULT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Replicate
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_BACKGROUND='#D16262'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_SHORTENED_FOREGROUND='#6A393C'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NOT_WRITABLE_BACKGROUND='#D16262'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NOT_WRITABLE_SHORTENED_FOREGROUND='#6A393C'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NON_EXISTENT_BACKGROUND='#D16262'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NON_EXISTENT_SHORTENED_FOREGROUND='#6A393C'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REPLICATE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Resend
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_BACKGROUND='#38AAEB'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_FOREGROUND='#383838'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_SHORTENED_FOREGROUND='#386C89'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_ANCHOR_FOREGROUND='#383838'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NOT_WRITABLE_BACKGROUND='#38AAEB'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NOT_WRITABLE_FOREGROUND='#383838'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NOT_WRITABLE_SHORTENED_FOREGROUND='#386C89'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NOT_WRITABLE_ANCHOR_FOREGROUND='#383838'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NON_EXISTENT_BACKGROUND='#38AAEB'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NON_EXISTENT_FOREGROUND='#383838'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NON_EXISTENT_SHORTENED_FOREGROUND='#386C89'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NON_EXISTENT_ANCHOR_FOREGROUND='#383838'
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RESEND_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Retool
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_BACKGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_SHORTENED_FOREGROUND='#18191C'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NOT_WRITABLE_BACKGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NOT_WRITABLE_SHORTENED_FOREGROUND='#18191C'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NON_EXISTENT_BACKGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NON_EXISTENT_SHORTENED_FOREGROUND='#18191C'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RETOOL_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Return Zero
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_BACKGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_SHORTENED_FOREGROUND='#131417'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NOT_WRITABLE_BACKGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NOT_WRITABLE_SHORTENED_FOREGROUND='#131417'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NON_EXISTENT_BACKGROUND='#0F0F0F'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NON_EXISTENT_SHORTENED_FOREGROUND='#131417'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RETURNZERO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Revolut
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_BACKGROUND='#003061'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_SHORTENED_FOREGROUND='#0C233B'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NOT_WRITABLE_BACKGROUND='#003061'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C233B'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NON_EXISTENT_BACKGROUND='#003061'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NON_EXISTENT_SHORTENED_FOREGROUND='#0C233B'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_REVOLUT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Richart
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_BACKGROUND='#128E9D'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_SHORTENED_FOREGROUND='#144D57'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NOT_WRITABLE_BACKGROUND='#128E9D'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NOT_WRITABLE_SHORTENED_FOREGROUND='#144D57'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NON_EXISTENT_BACKGROUND='#128E9D'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NON_EXISTENT_SHORTENED_FOREGROUND='#144D57'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RICHART_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Robinhood
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_BACKGROUND='#009C04'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_SHORTENED_FOREGROUND='#0C5312'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NOT_WRITABLE_BACKGROUND='#009C04'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C5312'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NON_EXISTENT_BACKGROUND='#009C04'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NON_EXISTENT_SHORTENED_FOREGROUND='#0C5312'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ROBINHOOD_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# RunwayML
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_RUNWAYML_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# さくらインターネット
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_BACKGROUND='#EB4E6D'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_FOREGROUND='#1D1D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_SHORTENED_FOREGROUND='#7A3341'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_ANCHOR_FOREGROUND='#1D1D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NOT_WRITABLE_BACKGROUND='#EB4E6D'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NOT_WRITABLE_FOREGROUND='#1D1D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NOT_WRITABLE_SHORTENED_FOREGROUND='#7A3341'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NOT_WRITABLE_ANCHOR_FOREGROUND='#1D1D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NON_EXISTENT_BACKGROUND='#EB4E6D'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NON_EXISTENT_FOREGROUND='#1D1D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NON_EXISTENT_SHORTENED_FOREGROUND='#7A3341'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NON_EXISTENT_ANCHOR_FOREGROUND='#1D1D1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SAKURA-INTERNET_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Samsung
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NOT_WRITABLE_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NON_EXISTENT_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SAMSUNG_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Sandoll
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_BACKGROUND='#6A0200'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_SHORTENED_FOREGROUND='#3C0E10'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NOT_WRITABLE_BACKGROUND='#6A0200'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NOT_WRITABLE_SHORTENED_FOREGROUND='#3C0E10'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NON_EXISTENT_BACKGROUND='#6A0200'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NON_EXISTENT_SHORTENED_FOREGROUND='#3C0E10'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SANDOLL_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Sanity
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_BACKGROUND='#E04B00'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_FOREGROUND='#0B0B0B'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_SHORTENED_FOREGROUND='#6B2806'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_ANCHOR_FOREGROUND='#0B0B0B'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NOT_WRITABLE_BACKGROUND='#E04B00'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NOT_WRITABLE_FOREGROUND='#0B0B0B'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NOT_WRITABLE_SHORTENED_FOREGROUND='#6B2806'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NOT_WRITABLE_ANCHOR_FOREGROUND='#0B0B0B'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NON_EXISTENT_BACKGROUND='#E04B00'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NON_EXISTENT_FOREGROUND='#0B0B0B'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NON_EXISTENT_SHORTENED_FOREGROUND='#6B2806'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NON_EXISTENT_ANCHOR_FOREGROUND='#0B0B0B'
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SANITY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Sansan
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_BACKGROUND='#670008'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_SHORTENED_FOREGROUND='#3B0D14'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NOT_WRITABLE_BACKGROUND='#670008'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NOT_WRITABLE_SHORTENED_FOREGROUND='#3B0D14'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NON_EXISTENT_BACKGROUND='#670008'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NON_EXISTENT_SHORTENED_FOREGROUND='#3B0D14'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SANSAN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Saramin
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_BACKGROUND='#182F6B'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_SHORTENED_FOREGROUND='#172240'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NOT_WRITABLE_BACKGROUND='#182F6B'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NOT_WRITABLE_SHORTENED_FOREGROUND='#172240'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NON_EXISTENT_BACKGROUND='#182F6B'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NON_EXISTENT_SHORTENED_FOREGROUND='#172240'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SARAMIN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Scatter Lab
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_BACKGROUND='#0F1112'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_SHORTENED_FOREGROUND='#131518'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NOT_WRITABLE_BACKGROUND='#0F1112'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NOT_WRITABLE_SHORTENED_FOREGROUND='#131518'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NON_EXISTENT_BACKGROUND='#0F1112'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NON_EXISTENT_SHORTENED_FOREGROUND='#131518'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SCATTERLAB_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Sentry
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_BACKGROUND='#181428'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_SHORTENED_FOREGROUND='#97959E'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NOT_WRITABLE_BACKGROUND='#181428'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NOT_WRITABLE_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NOT_WRITABLE_SHORTENED_FOREGROUND='#97959E'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NOT_WRITABLE_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NON_EXISTENT_BACKGROUND='#181428'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NON_EXISTENT_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NON_EXISTENT_SHORTENED_FOREGROUND='#97959E'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NON_EXISTENT_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SENTRY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# ServiceNow Horizon
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_BACKGROUND='#07141D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_SHORTENED_FOREGROUND='#0F161D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NOT_WRITABLE_BACKGROUND='#07141D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NOT_WRITABLE_SHORTENED_FOREGROUND='#0F161D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NON_EXISTENT_BACKGROUND='#07141D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NON_EXISTENT_SHORTENED_FOREGROUND='#0F161D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SERVICENOW_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Shift Up
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_BACKGROUND='#539440'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_SHORTENED_FOREGROUND='#31502D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NOT_WRITABLE_BACKGROUND='#539440'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NOT_WRITABLE_SHORTENED_FOREGROUND='#31502D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NON_EXISTENT_BACKGROUND='#539440'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NON_EXISTENT_SHORTENED_FOREGROUND='#31502D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SHIFTUP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Shinhan Bank
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_BACKGROUND='#001F73'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_SHORTENED_FOREGROUND='#0C1B44'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NOT_WRITABLE_BACKGROUND='#001F73'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C1B44'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NON_EXISTENT_BACKGROUND='#001F73'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NON_EXISTENT_SHORTENED_FOREGROUND='#0C1B44'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SHINHANBANK_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# SHOPLINE
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_BACKGROUND='#0F2A73'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_SHORTENED_FOREGROUND='#132044'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NOT_WRITABLE_BACKGROUND='#0F2A73'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NOT_WRITABLE_SHORTENED_FOREGROUND='#132044'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NON_EXISTENT_BACKGROUND='#0F2A73'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NON_EXISTENT_SHORTENED_FOREGROUND='#132044'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SHOPLINE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# SIONIC AI
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_BACKGROUND='#003465'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_SHORTENED_FOREGROUND='#0C253D'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NOT_WRITABLE_BACKGROUND='#003465'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C253D'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NON_EXISTENT_BACKGROUND='#003465'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NON_EXISTENT_SHORTENED_FOREGROUND='#0C253D'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SIONIC_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# SK텔레콤
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_BACKGROUND='#1A205C'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_FOREGROUND='#1A2232'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_SHORTENED_FOREGROUND='#1A2145'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_ANCHOR_FOREGROUND='#1A2232'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NOT_WRITABLE_BACKGROUND='#1A205C'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NOT_WRITABLE_FOREGROUND='#1A2232'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NOT_WRITABLE_SHORTENED_FOREGROUND='#1A2145'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NOT_WRITABLE_ANCHOR_FOREGROUND='#1A2232'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NON_EXISTENT_BACKGROUND='#1A205C'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NON_EXISTENT_FOREGROUND='#1A2232'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NON_EXISTENT_SHORTENED_FOREGROUND='#1A2145'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NON_EXISTENT_ANCHOR_FOREGROUND='#1A2232'
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SKTELECOM_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Skyscanner
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_BACKGROUND='#002C66'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_SHORTENED_FOREGROUND='#0C203A'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_ANCHOR_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NOT_WRITABLE_BACKGROUND='#002C66'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NOT_WRITABLE_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C203A'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NOT_WRITABLE_ANCHOR_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NON_EXISTENT_BACKGROUND='#002C66'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NON_EXISTENT_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NON_EXISTENT_SHORTENED_FOREGROUND='#0C203A'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NON_EXISTENT_ANCHOR_FOREGROUND='#161616'
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SKYSCANNER_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Slack
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_BACKGROUND='#210922'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_FOREGROUND='#1D1C1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_SHORTENED_FOREGROUND='#1F141F'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_ANCHOR_FOREGROUND='#1D1C1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NOT_WRITABLE_BACKGROUND='#210922'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NOT_WRITABLE_FOREGROUND='#1D1C1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NOT_WRITABLE_SHORTENED_FOREGROUND='#1F141F'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NOT_WRITABLE_ANCHOR_FOREGROUND='#1D1C1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NON_EXISTENT_BACKGROUND='#210922'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NON_EXISTENT_FOREGROUND='#1D1C1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NON_EXISTENT_SHORTENED_FOREGROUND='#1F141F'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NON_EXISTENT_ANCHOR_FOREGROUND='#1D1C1D'
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SLACK_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Snapchat
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_BACKGROUND='#8C8B00'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_SHORTENED_FOREGROUND='#4B4C10'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NOT_WRITABLE_BACKGROUND='#8C8B00'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NOT_WRITABLE_SHORTENED_FOREGROUND='#4B4C10'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NON_EXISTENT_BACKGROUND='#8C8B00'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NON_EXISTENT_SHORTENED_FOREGROUND='#4B4C10'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SNAPCHAT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# SOCAR
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_BACKGROUND='#00326A'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_FOREGROUND='#354153'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_SHORTENED_FOREGROUND='#1D3A5D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_ANCHOR_FOREGROUND='#354153'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NOT_WRITABLE_BACKGROUND='#00326A'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NOT_WRITABLE_FOREGROUND='#354153'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NOT_WRITABLE_SHORTENED_FOREGROUND='#1D3A5D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NOT_WRITABLE_ANCHOR_FOREGROUND='#354153'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NON_EXISTENT_BACKGROUND='#00326A'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NON_EXISTENT_FOREGROUND='#354153'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NON_EXISTENT_SHORTENED_FOREGROUND='#1D3A5D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NON_EXISTENT_ANCHOR_FOREGROUND='#354153'
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SOCAR_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# ソニー
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SONY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Soomgo
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_BACKGROUND='#2F1B6D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_SHORTENED_FOREGROUND='#211941'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NOT_WRITABLE_BACKGROUND='#2F1B6D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NOT_WRITABLE_SHORTENED_FOREGROUND='#211941'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NON_EXISTENT_BACKGROUND='#2F1B6D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NON_EXISTENT_SHORTENED_FOREGROUND='#211941'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SOOMGO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# SpaceX
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_BACKGROUND='#9999A2'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_FOREGROUND='#282877'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_SHORTENED_FOREGROUND='#5B5B8A'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_ANCHOR_FOREGROUND='#282877'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NOT_WRITABLE_BACKGROUND='#9999A2'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NOT_WRITABLE_FOREGROUND='#282877'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NOT_WRITABLE_SHORTENED_FOREGROUND='#5B5B8A'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NOT_WRITABLE_ANCHOR_FOREGROUND='#282877'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NON_EXISTENT_BACKGROUND='#9999A2'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NON_EXISTENT_FOREGROUND='#282877'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NON_EXISTENT_SHORTENED_FOREGROUND='#5B5B8A'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NON_EXISTENT_ANCHOR_FOREGROUND='#282877'
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPACEX_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# SPEEDA (Uzabase)
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_BACKGROUND='#67071B'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_SHORTENED_FOREGROUND='#3B101C'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NOT_WRITABLE_BACKGROUND='#67071B'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NOT_WRITABLE_SHORTENED_FOREGROUND='#3B101C'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NON_EXISTENT_BACKGROUND='#67071B'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NON_EXISTENT_SHORTENED_FOREGROUND='#3B101C'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPEEDA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Spindle (CyberAgent Ameba)
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_BACKGROUND='#123D19'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_SHORTENED_FOREGROUND='#14291B'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NOT_WRITABLE_BACKGROUND='#123D19'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NOT_WRITABLE_SHORTENED_FOREGROUND='#14291B'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NON_EXISTENT_BACKGROUND='#123D19'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NON_EXISTENT_SHORTENED_FOREGROUND='#14291B'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPINDLE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Spotify
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_BACKGROUND='#25CF62'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_FOREGROUND='#454545'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_SHORTENED_FOREGROUND='#378352'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_ANCHOR_FOREGROUND='#454545'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NOT_WRITABLE_BACKGROUND='#25CF62'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NOT_WRITABLE_FOREGROUND='#454545'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NOT_WRITABLE_SHORTENED_FOREGROUND='#378352'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NOT_WRITABLE_ANCHOR_FOREGROUND='#454545'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NON_EXISTENT_BACKGROUND='#25CF62'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NON_EXISTENT_FOREGROUND='#454545'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NON_EXISTENT_SHORTENED_FOREGROUND='#378352'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NON_EXISTENT_ANCHOR_FOREGROUND='#454545'
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SPOTIFY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Squarespace
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SQUARESPACE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# SqueezeBits
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_BACKGROUND='#542509'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_SHORTENED_FOREGROUND='#321E14'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NOT_WRITABLE_BACKGROUND='#542509'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NOT_WRITABLE_SHORTENED_FOREGROUND='#321E14'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NON_EXISTENT_BACKGROUND='#542509'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NON_EXISTENT_SHORTENED_FOREGROUND='#321E14'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SQUEEZEBITS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Starbucks
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_BACKGROUND='#003221'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_SHORTENED_FOREGROUND='#0C241F'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NOT_WRITABLE_BACKGROUND='#003221'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C241F'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NON_EXISTENT_BACKGROUND='#003221'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NON_EXISTENT_SHORTENED_FOREGROUND='#0C241F'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STARBUCKS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Starling Bank
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_BACKGROUND='#34A699'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_SHORTENED_FOREGROUND='#245855'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NOT_WRITABLE_BACKGROUND='#34A699'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NOT_WRITABLE_SHORTENED_FOREGROUND='#245855'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NON_EXISTENT_BACKGROUND='#34A699'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NON_EXISTENT_SHORTENED_FOREGROUND='#245855'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STARLING_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# STORES
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_BACKGROUND='#002E73'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_SHORTENED_FOREGROUND='#0C2244'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NOT_WRITABLE_BACKGROUND='#002E73'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C2244'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NON_EXISTENT_BACKGROUND='#002E73'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NON_EXISTENT_SHORTENED_FOREGROUND='#0C2244'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STORES_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Stripe
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_BACKGROUND='#2D2973'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_FOREGROUND='#414552'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_SHORTENED_FOREGROUND='#383861'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_ANCHOR_FOREGROUND='#414552'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NOT_WRITABLE_BACKGROUND='#2D2973'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NOT_WRITABLE_FOREGROUND='#414552'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NOT_WRITABLE_SHORTENED_FOREGROUND='#383861'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NOT_WRITABLE_ANCHOR_FOREGROUND='#414552'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NON_EXISTENT_BACKGROUND='#2D2973'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NON_EXISTENT_FOREGROUND='#414552'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NON_EXISTENT_SHORTENED_FOREGROUND='#383861'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NON_EXISTENT_ANCHOR_FOREGROUND='#414552'
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STRIPE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Studio
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_BACKGROUND='#00336A'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_SHORTENED_FOREGROUND='#0C243F'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NOT_WRITABLE_BACKGROUND='#00336A'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C243F'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NON_EXISTENT_BACKGROUND='#00336A'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NON_EXISTENT_SHORTENED_FOREGROUND='#0C243F'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_STUDIO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Supabase
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_BACKGROUND='#4A9470'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_SHORTENED_FOREGROUND='#2D5043'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NOT_WRITABLE_BACKGROUND='#4A9470'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NOT_WRITABLE_SHORTENED_FOREGROUND='#2D5043'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NON_EXISTENT_BACKGROUND='#4A9470'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NON_EXISTENT_SHORTENED_FOREGROUND='#2D5043'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SUPABASE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Superhuman
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_BACKGROUND='#281D73'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_SHORTENED_FOREGROUND='#1E1A44'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NOT_WRITABLE_BACKGROUND='#281D73'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NOT_WRITABLE_SHORTENED_FOREGROUND='#1E1A44'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NON_EXISTENT_BACKGROUND='#281D73'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NON_EXISTENT_SHORTENED_FOREGROUND='#1E1A44'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SUPERHUMAN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# SurveyCake
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_BACKGROUND='#309170'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_SHORTENED_FOREGROUND='#224E42'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NOT_WRITABLE_BACKGROUND='#309170'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NOT_WRITABLE_SHORTENED_FOREGROUND='#224E42'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NON_EXISTENT_BACKGROUND='#309170'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NON_EXISTENT_SHORTENED_FOREGROUND='#224E42'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_SURVEYCAKE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Blind
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_BACKGROUND='#621619'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_SHORTENED_FOREGROUND='#38171B'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NOT_WRITABLE_BACKGROUND='#621619'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NOT_WRITABLE_SHORTENED_FOREGROUND='#38171B'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NON_EXISTENT_BACKGROUND='#621619'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NON_EXISTENT_SHORTENED_FOREGROUND='#38171B'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TEAMBLIND_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Tesla
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_BACKGROUND='#1C3065'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_FOREGROUND='#171A20'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_SHORTENED_FOREGROUND='#19243F'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_ANCHOR_FOREGROUND='#171A20'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NOT_WRITABLE_BACKGROUND='#1C3065'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NOT_WRITABLE_FOREGROUND='#171A20'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NOT_WRITABLE_SHORTENED_FOREGROUND='#19243F'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NOT_WRITABLE_ANCHOR_FOREGROUND='#171A20'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NON_EXISTENT_BACKGROUND='#1C3065'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NON_EXISTENT_FOREGROUND='#171A20'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NON_EXISTENT_SHORTENED_FOREGROUND='#19243F'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NON_EXISTENT_ANCHOR_FOREGROUND='#171A20'
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TESLA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# The Verge
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_BACKGROUND='#250073'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_SHORTENED_FOREGROUND='#1D0D44'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NOT_WRITABLE_BACKGROUND='#250073'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NOT_WRITABLE_SHORTENED_FOREGROUND='#1D0D44'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NON_EXISTENT_BACKGROUND='#250073'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NON_EXISTENT_SHORTENED_FOREGROUND='#1D0D44'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_THEVERGE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# TMAP Mobility
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_SHORTENED_FOREGROUND='#0C2144'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NOT_WRITABLE_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C2144'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NON_EXISTENT_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NON_EXISTENT_SHORTENED_FOREGROUND='#0C2144'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TMAP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Together AI
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOGETHER.AI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Toss Securities
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_BACKGROUND='#4E87DA'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_FOREGROUND='#1A1F29'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_SHORTENED_FOREGROUND='#314E79'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_ANCHOR_FOREGROUND='#1A1F29'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NOT_WRITABLE_BACKGROUND='#4E87DA'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NOT_WRITABLE_FOREGROUND='#1A1F29'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NOT_WRITABLE_SHORTENED_FOREGROUND='#314E79'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NOT_WRITABLE_ANCHOR_FOREGROUND='#1A1F29'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NON_EXISTENT_BACKGROUND='#4E87DA'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NON_EXISTENT_FOREGROUND='#1A1F29'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NON_EXISTENT_SHORTENED_FOREGROUND='#314E79'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NON_EXISTENT_ANCHOR_FOREGROUND='#1A1F29'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS-SECURITIES_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Toss
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_FOREGROUND='#191F28'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_SHORTENED_FOREGROUND='#0E254A'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_ANCHOR_FOREGROUND='#191F28'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NOT_WRITABLE_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NOT_WRITABLE_FOREGROUND='#191F28'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NOT_WRITABLE_SHORTENED_FOREGROUND='#0E254A'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NOT_WRITABLE_ANCHOR_FOREGROUND='#191F28'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NON_EXISTENT_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NON_EXISTENT_FOREGROUND='#191F28'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NON_EXISTENT_SHORTENED_FOREGROUND='#0E254A'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NON_EXISTENT_ANCHOR_FOREGROUND='#191F28'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOSS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Toss Bank
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_FOREGROUND='#212529'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_SHORTENED_FOREGROUND='#12294A'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_ANCHOR_FOREGROUND='#212529'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NOT_WRITABLE_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NOT_WRITABLE_FOREGROUND='#212529'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NOT_WRITABLE_SHORTENED_FOREGROUND='#12294A'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NOT_WRITABLE_ANCHOR_FOREGROUND='#212529'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NON_EXISTENT_BACKGROUND='#002D73'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NON_EXISTENT_FOREGROUND='#212529'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NON_EXISTENT_SHORTENED_FOREGROUND='#12294A'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NON_EXISTENT_ANCHOR_FOREGROUND='#212529'
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TOSSBANK_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Trainline
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_BACKGROUND='#00947E'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_SHORTENED_FOREGROUND='#0C5049'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NOT_WRITABLE_BACKGROUND='#00947E'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C5049'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NON_EXISTENT_BACKGROUND='#00947E'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NON_EXISTENT_SHORTENED_FOREGROUND='#0C5049'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TRAINLINE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Tumblbug
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_BACKGROUND='#D24838'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_SHORTENED_FOREGROUND='#5E2019'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NOT_WRITABLE_BACKGROUND='#D24838'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NOT_WRITABLE_SHORTENED_FOREGROUND='#5E2019'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NON_EXISTENT_BACKGROUND='#D24838'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NON_EXISTENT_SHORTENED_FOREGROUND='#5E2019'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TUMBLBUG_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# TVING
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_BACKGROUND='#6A0012'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_SHORTENED_FOREGROUND='#BC8C94'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NOT_WRITABLE_BACKGROUND='#6A0012'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NOT_WRITABLE_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NOT_WRITABLE_SHORTENED_FOREGROUND='#BC8C94'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NOT_WRITABLE_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NON_EXISTENT_BACKGROUND='#6A0012'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NON_EXISTENT_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NON_EXISTENT_SHORTENED_FOREGROUND='#BC8C94'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NON_EXISTENT_ANCHOR_FOREGROUND='#FFFFFF'
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TVING_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Twilio
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_BACKGROUND='#6A0813'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_SHORTENED_FOREGROUND='#3C1119'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NOT_WRITABLE_BACKGROUND='#6A0813'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NOT_WRITABLE_SHORTENED_FOREGROUND='#3C1119'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NON_EXISTENT_BACKGROUND='#6A0813'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NON_EXISTENT_SHORTENED_FOREGROUND='#3C1119'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TWILIO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Twitch
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_BACKGROUND='#411F73'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_SHORTENED_FOREGROUND='#291B44'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NOT_WRITABLE_BACKGROUND='#411F73'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NOT_WRITABLE_SHORTENED_FOREGROUND='#291B44'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NON_EXISTENT_BACKGROUND='#411F73'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NON_EXISTENT_SHORTENED_FOREGROUND='#291B44'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_TWITCH_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Uber
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NOT_WRITABLE_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NON_EXISTENT_SHORTENED_FOREGROUND='#080808'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UBER_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Ubie
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_BACKGROUND='#1A285C'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_SHORTENED_FOREGROUND='#181F39'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NOT_WRITABLE_BACKGROUND='#1A285C'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NOT_WRITABLE_SHORTENED_FOREGROUND='#181F39'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NON_EXISTENT_BACKGROUND='#1A285C'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NON_EXISTENT_SHORTENED_FOREGROUND='#181F39'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UBIE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Uniqlo
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_BACKGROUND='#66080B'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_SHORTENED_FOREGROUND='#3A1115'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NOT_WRITABLE_BACKGROUND='#66080B'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NOT_WRITABLE_SHORTENED_FOREGROUND='#3A1115'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NON_EXISTENT_BACKGROUND='#66080B'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NON_EXISTENT_SHORTENED_FOREGROUND='#3A1115'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UNIQLO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Upstage
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_BACKGROUND='#292573'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_SHORTENED_FOREGROUND='#1F1E44'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NOT_WRITABLE_BACKGROUND='#292573'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NOT_WRITABLE_SHORTENED_FOREGROUND='#1F1E44'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NON_EXISTENT_BACKGROUND='#292573'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NON_EXISTENT_SHORTENED_FOREGROUND='#1F1E44'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_UPSTAGE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# U.S. Web Design System
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_BACKGROUND='#002A49'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_SHORTENED_FOREGROUND='#0F2230'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_ANCHOR_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NOT_WRITABLE_BACKGROUND='#002A49'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NOT_WRITABLE_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NOT_WRITABLE_SHORTENED_FOREGROUND='#0F2230'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NOT_WRITABLE_ANCHOR_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NON_EXISTENT_BACKGROUND='#002A49'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NON_EXISTENT_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NON_EXISTENT_SHORTENED_FOREGROUND='#0F2230'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NON_EXISTENT_ANCHOR_FOREGROUND='#1B1B1B'
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_USWDS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Vercel
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_FOREGROUND='#171717'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_SHORTENED_FOREGROUND='#151515'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_ANCHOR_FOREGROUND='#171717'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NOT_WRITABLE_FOREGROUND='#171717'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NOT_WRITABLE_SHORTENED_FOREGROUND='#151515'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NOT_WRITABLE_ANCHOR_FOREGROUND='#171717'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NON_EXISTENT_FOREGROUND='#171717'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NON_EXISTENT_SHORTENED_FOREGROUND='#151515'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NON_EXISTENT_ANCHOR_FOREGROUND='#171717'
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VERCEL_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Vocus
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_BACKGROUND='#EB4253'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_SHORTENED_FOREGROUND='#762B35'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NOT_WRITABLE_BACKGROUND='#EB4253'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NOT_WRITABLE_SHORTENED_FOREGROUND='#762B35'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NON_EXISTENT_BACKGROUND='#EB4253'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NON_EXISTENT_SHORTENED_FOREGROUND='#762B35'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VOCUS_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# VoltAgent
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_BACKGROUND='#1B9A49'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_SHORTENED_FOREGROUND='#185231'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NOT_WRITABLE_BACKGROUND='#1B9A49'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NOT_WRITABLE_SHORTENED_FOREGROUND='#185231'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NON_EXISTENT_BACKGROUND='#1B9A49'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NON_EXISTENT_SHORTENED_FOREGROUND='#185231'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VOLTAGENT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# VUNO
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_BACKGROUND='#2A9390'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_SHORTENED_FOREGROUND='#1F4F51'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NOT_WRITABLE_BACKGROUND='#2A9390'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NOT_WRITABLE_SHORTENED_FOREGROUND='#1F4F51'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NON_EXISTENT_BACKGROUND='#2A9390'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NON_EXISTENT_SHORTENED_FOREGROUND='#1F4F51'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_VUNO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Wanted
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_BACKGROUND='#002E73'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_SHORTENED_FOREGROUND='#0C2244'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NOT_WRITABLE_BACKGROUND='#002E73'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C2244'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NON_EXISTENT_BACKGROUND='#002E73'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NON_EXISTENT_SHORTENED_FOREGROUND='#0C2244'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WANTED_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Wantedly
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_BACKGROUND='#1A93AB'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_SHORTENED_FOREGROUND='#18505D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NOT_WRITABLE_BACKGROUND='#1A93AB'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NOT_WRITABLE_SHORTENED_FOREGROUND='#18505D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NON_EXISTENT_BACKGROUND='#1A93AB'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NON_EXISTENT_SHORTENED_FOREGROUND='#18505D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WANTEDLY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Warp
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_BACKGROUND='#0188D4'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_SHORTENED_FOREGROUND='#0C4A6F'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NOT_WRITABLE_BACKGROUND='#0188D4'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C4A6F'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NON_EXISTENT_BACKGROUND='#0188D4'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NON_EXISTENT_SHORTENED_FOREGROUND='#0C4A6F'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WARP_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Watcha
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_BACKGROUND='#E55076'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_SHORTENED_FOREGROUND='#733145'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NOT_WRITABLE_BACKGROUND='#E55076'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NOT_WRITABLE_SHORTENED_FOREGROUND='#733145'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NON_EXISTENT_BACKGROUND='#E55076'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NON_EXISTENT_SHORTENED_FOREGROUND='#733145'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WATCHA_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# W Concept
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WCONCEPT_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Webflow
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_BACKGROUND='#09316E'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_SHORTENED_FOREGROUND='#102342'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NOT_WRITABLE_BACKGROUND='#09316E'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NOT_WRITABLE_SHORTENED_FOREGROUND='#102342'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NON_EXISTENT_BACKGROUND='#09316E'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NON_EXISTENT_SHORTENED_FOREGROUND='#102342'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WEBFLOW_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Wise
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_BACKGROUND='#679749'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_SHORTENED_FOREGROUND='#3B5131'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NOT_WRITABLE_BACKGROUND='#679749'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NOT_WRITABLE_SHORTENED_FOREGROUND='#3B5131'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NON_EXISTENT_BACKGROUND='#679749'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NON_EXISTENT_SHORTENED_FOREGROUND='#3B5131'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WISE_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Wisetracker
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_BACKGROUND='#C76E06'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_SHORTENED_FOREGROUND='#663F13'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NOT_WRITABLE_BACKGROUND='#C76E06'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NOT_WRITABLE_SHORTENED_FOREGROUND='#663F13'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NON_EXISTENT_BACKGROUND='#C76E06'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NON_EXISTENT_SHORTENED_FOREGROUND='#663F13'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WISETRACKER_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Woori Bank
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_BACKGROUND='#002E4D'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_SHORTENED_FOREGROUND='#001523'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NOT_WRITABLE_BACKGROUND='#002E4D'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NOT_WRITABLE_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NOT_WRITABLE_SHORTENED_FOREGROUND='#001523'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NOT_WRITABLE_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NON_EXISTENT_BACKGROUND='#002E4D'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NON_EXISTENT_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NON_EXISTENT_SHORTENED_FOREGROUND='#001523'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NON_EXISTENT_ANCHOR_FOREGROUND='#000000'
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WOORIBANK_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Workday
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_BACKGROUND='#00274E'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_SHORTENED_FOREGROUND='#0C1F33'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NOT_WRITABLE_BACKGROUND='#00274E'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C1F33'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NON_EXISTENT_BACKGROUND='#00274E'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NON_EXISTENT_SHORTENED_FOREGROUND='#0C1F33'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_WORKDAY_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# xAI
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_X.AI_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Xiaohongshu
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_BACKGROUND='#EB475D'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_SHORTENED_FOREGROUND='#762D3A'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NOT_WRITABLE_BACKGROUND='#EB475D'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NOT_WRITABLE_SHORTENED_FOREGROUND='#762D3A'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NON_EXISTENT_BACKGROUND='#EB475D'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NON_EXISTENT_SHORTENED_FOREGROUND='#762D3A'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_XIAOHONGSHU_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Yogiyo
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_BACKGROUND='#670021'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_SHORTENED_FOREGROUND='#3B0D1F'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NOT_WRITABLE_BACKGROUND='#670021'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NOT_WRITABLE_SHORTENED_FOREGROUND='#3B0D1F'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NON_EXISTENT_BACKGROUND='#670021'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NON_EXISTENT_SHORTENED_FOREGROUND='#3B0D1F'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_YOGIYO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Yourator
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_BACKGROUND='#002D5E'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_SHORTENED_FOREGROUND='#0C213A'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NOT_WRITABLE_BACKGROUND='#002D5E'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NOT_WRITABLE_SHORTENED_FOREGROUND='#0C213A'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NON_EXISTENT_BACKGROUND='#002D5E'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NON_EXISTENT_SHORTENED_FOREGROUND='#0C213A'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_YOURATOR_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Zapier
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_BACKGROUND='#EB4900'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_SHORTENED_FOREGROUND='#762E10'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NOT_WRITABLE_BACKGROUND='#EB4900'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NOT_WRITABLE_SHORTENED_FOREGROUND='#762E10'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NON_EXISTENT_BACKGROUND='#EB4900'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NON_EXISTENT_SHORTENED_FOREGROUND='#762E10'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZAPIER_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# ZEPETO
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_BACKGROUND='#291F73'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_SHORTENED_FOREGROUND='#1F1B44'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NOT_WRITABLE_BACKGROUND='#291F73'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NOT_WRITABLE_SHORTENED_FOREGROUND='#1F1B44'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NON_EXISTENT_BACKGROUND='#291F73'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NON_EXISTENT_SHORTENED_FOREGROUND='#1F1B44'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZEPETO_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# Zoom
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_BACKGROUND='#052973'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_SHORTENED_FOREGROUND='#0E2044'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NOT_WRITABLE_BACKGROUND='#052973'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NOT_WRITABLE_SHORTENED_FOREGROUND='#0E2044'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NON_EXISTENT_BACKGROUND='#052973'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NON_EXISTENT_SHORTENED_FOREGROUND='#0E2044'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZOOM_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# ZOZOTOWN
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NOT_WRITABLE_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NOT_WRITABLE_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NOT_WRITABLE_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NOT_WRITABLE_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NOT_WRITABLE_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NOT_WRITABLE_CONTENT_EXPANSION='${_brand_dir_content}'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NON_EXISTENT_BACKGROUND='#121212'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NON_EXISTENT_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NON_EXISTENT_SHORTENED_FOREGROUND='#141518'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NON_EXISTENT_ANCHOR_FOREGROUND='#16181D'
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NON_EXISTENT_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_DIR_BRAND_ZOZOTOWN_NON_EXISTENT_CONTENT_EXPANSION='${_brand_dir_content}'

# os_icon 자리를 커스텀 세그먼트로 바꾼다. os_icon은 p10k가 정적 세그먼트로 캐싱해
# 디렉터리가 바뀌어도 갱신되지 않기 때문이다 (변수 참조로도 안 된다 — 확인함).
#
# 사용자의 배열을 통째로 대입하지 않는다. 예전에는 (custom_brandlogo dir vcs)로 못박아
# 회사 폴더 밖에서도 남의 프롬프트 구성이 이 셋으로 고정됐다. os_icon 항목만 바꿔치기한다.
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  ${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]/os_icon/custom_brandlogo})
typeset -g POWERLEVEL9K_CUSTOM_BRANDLOGO='_brand_logo_segment'
# 색도 사용자의 os_icon 값을 따른다. 하드코딩하면 다른 사람에게 틀린 색이 된다.
typeset -g POWERLEVEL9K_CUSTOM_BRANDLOGO_BACKGROUND=${POWERLEVEL9K_OS_ICON_BACKGROUND:-7}
typeset -g POWERLEVEL9K_CUSTOM_BRANDLOGO_FOREGROUND=${POWERLEVEL9K_OS_ICON_FOREGROUND:-232}
