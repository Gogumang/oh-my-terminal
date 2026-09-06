"""브랜드 모델 — 이 도구가 다루는 유일한 핵심 개념."""
from dataclasses import dataclass, field


@dataclass(frozen=True)
class Brand:
    """회사 하나의 테마 정의.

    primary/secondary는 브랜드 색이고, paths는 "이 디렉터리에 있으면 이 회사"라는 규칙이다.
    로고는 형태만 쓰는 실루엣과 원본 색을 살리는 컬러 두 종류다 — 색 면에서 글자를 파낸
    로고(배민 앱 아이콘 등)는 실루엣으로 만들면 형태가 사라지기 때문이다.
    """

    key: str
    name: str
    primary: str
    secondary: str
    paths: tuple[str, ...] = ()
    logo_path: str | None = None
    logo_kind: str | None = None      # simpleicons | favicon | github
    logo_url: str | None = None       # 로고를 다시 받을 수 있는 출처
    keeps_original_colour: bool = False
    verified_on: str | None = None

    @property
    def has_logo(self) -> bool:
        return self.logo_path is not None
