//! 브랜드 모델 — 이 도구가 다루는 유일한 핵심 개념.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct LogoSource {
    pub kind: String,
    pub url: String,
    /// 색 면에서 글자를 파낸 앱 아이콘은 실루엣으로 만들면 형태가 사라진다.
    #[serde(default, skip_serializing_if = "std::ops::Not::not")]
    pub keep_colour: bool,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct Brand {
    pub key: String,
    pub name: String,
    /// 두 글자 나라 코드 (카탈로그 표기를 따라 영국은 `UK`). README 지원 테마를 나라별로
    /// 묶는 데만 쓴다.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub country: Option<String>,
    pub primary: String,
    pub secondary: String,
    /// 브랜드 색의 출처 검증일. 데이터셋이 갱신됐는지 사람이 판단하는 근거라
    /// 코드가 읽지는 않지만 yaml에는 남긴다.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub verified: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub logo: Option<LogoSource>,
    /// 준비된 로고 PNG 경로. 카탈로그가 채운다.
    #[serde(skip)]
    pub logo_path: Option<std::path::PathBuf>,
}

impl Brand {
    /// iTerm2 프로필 이름. 셸은 세션의 ITERM_PROFILE을 이 이름과 맞춰 회사를 알아낸다.
    pub fn profile_name(&self) -> String {
        format!("{} Brand", self.name)
    }
}
