"""SVG 래스터화 어댑터.

resvg(Rust)를 쓴다. 이전에는 macOS `qlmanage`에 셸아웃했는데, Quick Look은
썸네일 생성기라 알파를 버리고 흰 페이지 위에 평탄화한다. 그래서 "배경이 무슨 색이었나"를
되짚어 추정하는 휴리스틱이 필요했고, 로고 획이 네 모서리에 닿는 경우(네이버의 굵은 N)
추정이 뒤집혀 로고가 반전됐다. resvg는 알파를 그대로 보존해 그 문제 자체가 없다.
"""
import io

import resvg_py
from PIL import Image


def rasterize_svg(data: bytes, size: int) -> Image.Image:
    png = bytes(resvg_py.svg_to_bytes(svg_string=data.decode("utf-8"), width=size))
    return Image.open(io.BytesIO(png)).convert("RGBA")
