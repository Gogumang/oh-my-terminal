"""로고를 어디서 가져와 어떻게 다듬을지 아는 어댑터.

우선순위:
  1. logos/<key>.color.png  — 사용자가 넣은 원본 컬러 로고 (실루엣이 불가능한 앱 아이콘)
  2. logos/<key>.custom.png — 사용자가 넣은 실루엣용 로고
  3. 원격 (Simple Icons / 파비콘 / GitHub 아바타)
사용자가 넣은 파일은 절대 덮어쓰지 않는다.
"""
import subprocess
from pathlib import Path

from PIL import Image

from . import logo_shaper as shaper
from .rasterizer import rasterize_svg

LOGO_SIZE = 512
TIMEOUT_SECONDS = 20
# 실루엣이 형태를 잃는 구간. 통짜 덩어리이거나 거의 빈 이미지면 알아볼 수 없다.
USABLE_COVERAGE = (0.06, 0.70)


class LogoRepository:
    def __init__(self, logo_directory: Path):
        self.logo_directory = logo_directory
        self.notes: list[str] = []

    def prepare(self, brand, source_kind=None, source_url=None) -> Path | None:
        target = self.logo_directory / f"{brand.key}.png"

        colour_logo = self.logo_directory / f"{brand.key}.color.png"
        if colour_logo.exists():
            image = shaper.clear_corner_background(Image.open(colour_logo).convert("RGBA"))
            shaper.fit(shaper.crop_to_content(image), LOGO_SIZE).save(target)
            return target

        custom_logo = self.logo_directory / f"{brand.key}.custom.png"
        if custom_logo.exists():
            image = Image.open(custom_logo).convert("RGBA")
            shaper.fit(shaper.crop_to_content(shaper.to_silhouette(image)), LOGO_SIZE).save(target)
            return target

        if not source_url:
            return None
        try:
            image = self._download(source_url)
        except Exception as error:                       # 로고는 보조 데이터 — 색은 살린다
            self.notes.append(f"{brand.name}: 내려받기 실패 ({type(error).__name__})")
            target.unlink(missing_ok=True)
            return None

        if getattr(brand, "keeps_original_colour", False):
            # 색 면에서 글자를 파낸 앱 아이콘은 실루엣으로 만들면 통짜 도형이 된다.
            shaper.fit(shaper.crop_to_content(shaper.clear_corner_background(image)),
                       LOGO_SIZE).save(target)
            return target

        shape = shaper.crop_to_content(shaper.to_silhouette(image))
        # Simple Icons는 단색 아이콘용으로 설계돼 점유율이 높아도 형태가 살아있다
        # (네이버의 굵은 N이 80%). 파비콘만 형태 검사·반전 대상이다.
        trusted = source_kind == "simpleicons"
        if not trusted:
            if shaper.alpha_coverage(shape) > USABLE_COVERAGE[1]:
                shape = shaper.invert_alpha(shape)
            coverage = shaper.alpha_coverage(shape)
            if not USABLE_COVERAGE[0] <= coverage <= USABLE_COVERAGE[1]:
                self.notes.append(f"{brand.name}: 실루엣이 형태를 잃음 (점유율 {coverage:.0%})")
                target.unlink(missing_ok=True)
                return None
        shaper.fit(shaper.crop_to_content(shape), LOGO_SIZE).save(target)
        return target

    def _download(self, url: str) -> Image.Image:
        # python.org 빌드는 시스템 인증서를 안 써서 SSL 검증이 깨진다 — curl로 받는다.
        result = subprocess.run(
            ["curl", "-sL", "--max-time", str(TIMEOUT_SECONDS), "-A", "Mozilla/5.0", url],
            capture_output=True, timeout=TIMEOUT_SECONDS + 5)
        if result.returncode != 0 or not result.stdout:
            raise RuntimeError(f"curl 실패 ({result.returncode})")
        data = result.stdout
        if data[:4] == b"<svg" or b"<svg" in data[:400]:
            rendered = rasterize_svg(data, LOGO_SIZE)
            # resvg 알파는 정확하니 그대로 믿는다. 다만 <rect>로 배경을 꽉 칠한 SVG
            # (무신사 favicon.svg)는 투명 영역이 거의 없다 — 그때만 배경을 걷어낸다.
            if shaper.alpha_coverage(rendered) > 0.95:
                return shaper.strip_uniform_background(rendered)
            return rendered
        import io
        return shaper.strip_uniform_background(Image.open(io.BytesIO(data)).convert("RGBA"))
