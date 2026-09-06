"""유스케이스 조립. 포트만 알고 어댑터 구체 타입은 모른다."""
from pathlib import Path

from ..domain import palette


class BuildThemes:
    def __init__(self, catalog, logo_repository, font_writer, prompt_writer, profile_writer):
        self.catalog = catalog
        self.logo_repository = logo_repository
        self.font_writer = font_writer
        self.prompt_writer = prompt_writer
        self.profile_writer = profile_writer

    def run(self, output_root: Path):
        brands = self.catalog.load()
        # 로고 파일은 상표라 저장소에 커밋하지 않는다 — 없으면 출처에서 받아 재현한다.
        missing = [b for b in brands if not b.has_logo and b.logo_url]
        if missing:
            for brand in missing:
                self.logo_repository.prepare(brand, brand.logo_kind, brand.logo_url)
            brands = self.catalog.load()
        report = {"brands": [], "warnings": list(getattr(self.logo_repository, "notes", []))}

        font_path, glyphs = self.font_writer.write(brands, output_root)
        postscript = font_path.stem if font_path else None

        for brand in brands:
            _, _, dark, _, lowest, depth = palette.gradient(brand)
            _, lifted = palette.segment_background(brand)
            if lowest < palette.CONTRAST_ACCENT:
                report["warnings"].append(
                    f"{brand.name}: 그라데이션 구간 최저 대비 {lowest:.1f}:1 "
                    f"(목표 {palette.CONTRAST_ACCENT}:1) — 브랜드 색이 중간 톤이라 한계")
            if lifted:
                report["warnings"].append(
                    f"{brand.name}: 브랜드색이 터미널 배경과 구분되지 않아 들어올림")
            report["brands"].append({
                "name": brand.name, "logo": brand.key in glyphs,
                "contrast": lowest, "depth": depth,
            })

        prompt_path = self.prompt_writer.write(brands, glyphs, output_root)
        profile_path = self.profile_writer.write(brands, postscript, output_root)
        report["outputs"] = [p for p in (prompt_path, font_path, profile_path) if p]
        return report
