#!/usr/bin/env python3
"""oh-my-design(MIT) 데이터셋 → catalog/brands.json

440개 회사의 브랜드 색·로고 출처·메타데이터를 언어 중립 JSON 하나로 모은다.
빌더가 Python이든 Rust든 이 파일만 읽으면 되므로, 구현 언어 결정과 분리된다.

색을 손으로 적지 않는 것이 요점이다 — 이 데이터셋은 각 색의 출처(공식 문서/실측)와
수집일을 기록해 두어 손으로 넣은 값보다 정확하고 갱신도 추적된다.
"""
import json
import pathlib
import re
import sys

CATALOG_VERSION = 1


def frontmatter(text):
    match = re.match(r"^---\n(.*?)\n---", text, re.S)
    return match.group(1) if match else ""


def scalar(block, key, default=None):
    match = re.search(rf'^{key}:\s*"?([^"\n]+)"?\s*$', block, re.M)
    return match.group(1).strip().strip('"') if match else default


def logo_source(block):
    match = re.search(r"^logo:\n((?:  .*\n)+)", block, re.M)
    if not match:
        return None
    body = match.group(1)
    kind = scalar(body, "  type")
    slug = scalar(body, "  slug")
    if not kind or not slug:
        return None
    if kind == "simpleicons":
        return {"kind": kind, "reference": slug,
                "url": f"https://cdn.simpleicons.org/{slug}/000000"}
    if kind == "github":
        return {"kind": kind, "reference": slug,
                "url": f"https://github.com/{slug}.png?size=512"}
    return {"kind": kind, "reference": slug, "url": slug}


def semantic_colours(text):
    """DESIGN.md 본문의 colors: 블록에서 의미색을 모은다."""
    match = re.search(r"^  colors:\n((?:    .*\n)+)", text, re.M)
    if not match:
        return {}
    found = {}
    for line in match.group(1).splitlines():
        pair = re.match(r'^\s+([a-z0-9-]+):\s*"(#[0-9a-fA-F]{3,8})"', line)
        if pair:
            found[pair.group(1)] = pair.group(2).upper()
    return found


def main():
    if len(sys.argv) < 2:
        sys.exit("사용법: build_catalog.py <oh-my-design/design-md 경로>")
    dataset = pathlib.Path(sys.argv[1])
    if not dataset.exists():
        sys.exit(f"데이터셋을 찾을 수 없다: {dataset}")

    entries, skipped = [], []
    for directory in sorted(dataset.iterdir()):
        design = directory / "DESIGN.md"
        if not design.is_dir() and not design.exists():
            continue
        text = design.read_text()
        block = frontmatter(text)
        primary = scalar(block, "primary_color")
        if not primary:              # 핵심 데이터 — 없으면 테마가 성립하지 않는다
            skipped.append(directory.name)
            continue
        colours = semantic_colours(text)
        entries.append({
            "key": directory.name,
            "name": scalar(block, "name", directory.name),
            "country": scalar(block, "country"),
            "category": scalar(block, "category"),
            "homepage": scalar(block, "homepage"),
            "primary": primary.upper(),
            # secondary는 프롬프트 글자색의 씨앗이다. 본문색이 가장 안정적이다.
            "secondary": colours.get("foreground") or colours.get("dark-marketing") or "#16181D",
            "colors": colours,
            "logo": logo_source(block),
            "verified": scalar(block, "verified"),
        })

    catalog = {
        "version": CATALOG_VERSION,
        "source": {
            "name": "oh-my-design",
            "url": "https://github.com/kwakseongjae/oh-my-design",
            "license": "MIT",
        },
        "brands": entries,
    }
    output = pathlib.Path(__file__).parent.parent / "catalog" / "brands.json"
    output.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n")
    print(f"카탈로그 생성: {output}")
    print(f"  회사 {len(entries)}개  (primary_color 없어 제외 {len(skipped)}개)")
    countries = {}
    for entry in entries:
        countries[entry["country"]] = countries.get(entry["country"], 0) + 1
    print("  국가별:", ", ".join(f"{k} {v}" for k, v in
                                sorted(countries.items(), key=lambda x: -x[1])[:6]))
    kinds = {}
    for entry in entries:
        kind = entry["logo"]["kind"] if entry["logo"] else "없음"
        kinds[kind] = kinds.get(kind, 0) + 1
    print("  로고 출처:", ", ".join(f"{k} {v}" for k, v in sorted(kinds.items(), key=lambda x: -x[1])))


if __name__ == "__main__":
    main()
