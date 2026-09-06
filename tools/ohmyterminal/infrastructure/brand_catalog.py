"""brands/*.yaml → Brand 모델. 와이어 형식(YAML 키)은 이 파일 밖으로 나가지 않는다."""
from pathlib import Path

import yaml

from ..domain.brand import Brand


class YamlBrandCatalog:
    def __init__(self, directory: Path, logo_directory: Path):
        self.directory = directory
        self.logo_directory = logo_directory

    def load(self) -> list[Brand]:
        brands = []
        for path in sorted(self.directory.glob("*.yaml")):
            raw = yaml.safe_load(path.read_text())
            key = raw["key"]
            logo = self.logo_directory / f"{key}.png"
            brands.append(Brand(
                key=key,
                name=raw["name"],
                primary=raw["primary"].upper(),
                secondary=raw["secondary"].upper(),
                paths=tuple(raw.get("paths") or ()),
                logo_path=str(logo) if logo.exists() else None,
                keeps_original_colour=bool((raw.get("logo") or {}).get("keep_colour"))
                or (self.logo_directory / f"{key}.color.png").exists(),
                logo_kind=(raw.get("logo") or {}).get("kind"),
                logo_url=(raw.get("logo") or {}).get("url"),
                verified_on=raw.get("verified"),
            ))
        return brands
