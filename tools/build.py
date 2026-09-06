#!/usr/bin/env python3
"""빌드 진입점 — 어댑터를 조립해 유스케이스를 실행한다 (interfaces 레이어).

여기서만 구체 어댑터를 안다. 도메인·유스케이스는 포트만 본다.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from ohmyterminal.application.build_themes import BuildThemes
from ohmyterminal.infrastructure.brand_catalog import YamlBrandCatalog
from ohmyterminal.infrastructure.font_writer import SbixFontWriter
from ohmyterminal.infrastructure.iterm2_writer import ITerm2ProfileWriter
from ohmyterminal.infrastructure.logo_repository import LogoRepository
from ohmyterminal.infrastructure.p10k_writer import PowerlevelWriter

ROOT = Path(__file__).parent.parent
BASE_FONT = Path.home() / "Library/Fonts/MesloLGS NF Regular.ttf"


def main():
    if not BASE_FONT.exists():
        sys.exit(f"기반 폰트가 없다: {BASE_FONT}\n"
                 "  p10k 권장 폰트(MesloLGS NF)를 먼저 설치할 것: p10k configure")

    use_case = BuildThemes(
        catalog=YamlBrandCatalog(ROOT / "brands", ROOT / "logos"),
        logo_repository=LogoRepository(ROOT / "logos"),
        font_writer=SbixFontWriter(BASE_FONT),
        prompt_writer=PowerlevelWriter(),
        profile_writer=ITerm2ProfileWriter(),
    )
    report = use_case.run(ROOT)

    for entry in report["brands"]:
        mark = "로고" if entry["logo"] else "  · "
        print(f"  {mark} {entry['name']:<11} 대비 {entry['contrast']:.1f}:1  "
              f"그라데이션 깊이 {entry['depth']:.0%}")
    for warning in report["warnings"]:
        print(f"  ! {warning}", file=sys.stderr)
    print(f"\n생성물 {len(report['outputs'])}개:")
    for path in report["outputs"]:
        print(f"  {path.relative_to(ROOT)}  ({path.stat().st_size:,}B)")


if __name__ == "__main__":
    main()
