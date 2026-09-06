#!/usr/bin/env python3
"""카탈로그(440개)에서 회사를 골라 brands/에 추가하고 로고를 받아온다.

    tools/enable_brand.py kakao naver toss

카탈로그는 색과 로고 출처만 담는다 — 440개 로고를 전부 폰트에 굽지 않는 이유는
쓰지도 않을 3MB짜리 비트맵을 배포물에 넣게 되기 때문이다. 필요한 회사만 켠다.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from ohmyterminal.domain.brand import Brand
from ohmyterminal.infrastructure.logo_repository import LogoRepository

ROOT = Path(__file__).parent.parent


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    catalog = json.loads((ROOT / "catalog" / "brands.json").read_text())
    index = {entry["key"]: entry for entry in catalog["brands"]}
    repository = LogoRepository(ROOT / "logos")

    for key in sys.argv[1:]:
        entry = index.get(key)
        if not entry:
            print(f"  ! 카탈로그에 없다: {key}", file=sys.stderr)
            continue
        brand = Brand(key=key, name=entry["name"], primary=entry["primary"],
                      secondary=entry["secondary"])
        logo = entry.get("logo") or {}
        path = repository.prepare(brand, logo.get("kind"), logo.get("url"))
        (ROOT / "brands" / f"{key}.yaml").write_text(
            f"# catalog/brands.json에서 생성. 출처 검증일: {entry.get('verified')}\n"
            f"key: {key}\nname: {entry['name']}\n"
            f'primary: "{entry["primary"]}"\nsecondary: "{entry["secondary"]}"\n'
            f'verified: "{entry.get("verified")}"\n'
            f'paths:\n  - "~/Desktop/{key}(|/*)"\n')
        print(f"  {'로고' if path else '  · '} {entry['name']} ({entry['primary']})")

    for note in repository.notes:
        print(f"  ! {note}", file=sys.stderr)
    print("\n다음: tools/build.py 실행")


if __name__ == "__main__":
    main()
