"""도메인이 외부에 요구하는 능력. 구현은 infrastructure에 있다.

포트는 '제공자'가 아니라 '능력' 기준으로 나눈다. 예를 들어 로고를 어디서 가져오든
(Simple Icons·파비콘·로컬 파일) 도메인이 필요한 것은 "브랜드의 로고 이미지 파일"
하나뿐이므로 포트도 하나다.
"""
from pathlib import Path
from typing import Protocol


class LogoRepository(Protocol):
    """브랜드 로고를 프롬프트에 쓸 수 있는 PNG 파일로 준비한다.

    로고는 보조 데이터다 — 못 구해도 색과 그라데이션은 성립하므로 None을 돌려준다.
    """

    def prepare(self, brand) -> Path | None: ...


class BrandCatalog(Protocol):
    """브랜드 정의를 읽어온다."""

    def load(self) -> list: ...


class ThemeWriter(Protocol):
    """계산된 테마를 특정 형식으로 내보낸다 (p10k 설정·iTerm2 프로필·폰트 등)."""

    def write(self, brands, output_root: Path) -> Path: ...
