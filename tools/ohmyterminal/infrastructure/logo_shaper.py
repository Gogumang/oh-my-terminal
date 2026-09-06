"""내려받은 이미지를 프롬프트 글리프로 쓸 수 있는 형태로 다듬는다.

로고는 두 갈래로 나뉜다:
  - 실루엣: 형태(알파)만 남기고 세그먼트 배경에 맞춰 색을 입힌다. 대부분의 로고.
  - 원본 컬러: 색 면에서 글자를 파낸 앱 아이콘(배민·쿠팡·NOL). 실루엣으로 만들면
    통짜 동그라미/네모가 되어 알아볼 수 없다.
"""
from PIL import Image, ImageDraw

BACKGROUND_TOLERANCE = 28
CORNER_TOLERANCE = 32
FAINT_ALPHA = 30


def alpha_coverage(image: Image.Image) -> float:
    return sum(1 for pixel in image.getdata() if pixel[3] > FAINT_ALPHA) / (
        image.width * image.height)


def fit(image: Image.Image, size: int) -> Image.Image:
    """비율을 유지하며 정사각형에 꽉 차게 맞춘다 (축소·확대 모두).

    Image.thumbnail은 축소만 해서, 16x16 파비콘이 캔버스 한가운데 점으로 남는다.
    """
    scale = size / max(image.width, image.height)
    resized = image.resize((max(1, round(image.width * scale)), max(1, round(image.height * scale))),
                           Image.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.paste(resized, ((size - resized.width) // 2, (size - resized.height) // 2), resized)
    return canvas


def crop_to_content(image: Image.Image) -> Image.Image:
    """투명 여백을 잘라낸다. 안 자르면 글리프 칸에서 로고가 작아진다."""
    box = image.getchannel("A").point(lambda value: 255 if value > 12 else 0).getbbox()
    return image.crop(box) if box else image


def to_silhouette(image: Image.Image) -> Image.Image:
    """색을 버리고 형태(알파)만 남긴다."""
    silhouette = Image.new("RGBA", image.size, (255, 255, 255, 0))
    silhouette.putalpha(image.getchannel("A"))
    return silhouette


def strip_uniform_background(image: Image.Image) -> Image.Image:
    """네 모서리가 같은 불투명 색이면 그 색을 배경으로 보고 지운다.

    주의: 알파가 이미 정확한 이미지에는 쓰면 안 된다. 로고 획이 네 모서리에 닿으면
    (네이버 N) 로고 자체를 배경으로 오인해 통째로 지운다.
    """
    width, height = image.size
    corners = [image.getpixel(point) for point in
               ((1, 1), (width - 2, 1), (1, height - 2), (width - 2, height - 2))]
    if any(pixel[3] < 200 for pixel in corners) or len({pixel[:3] for pixel in corners}) != 1:
        return image
    background = corners[0][:3]
    pixels = image.load()
    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = pixels[x, y]
            if max(abs(red - background[0]), abs(green - background[1]),
                   abs(blue - background[2])) < BACKGROUND_TOLERANCE:
                pixels[x, y] = (red, green, blue, 0)
    return image


def clear_corner_background(image: Image.Image) -> Image.Image:
    """네 모서리에 '연결된' 배경만 지운다.

    JPEG 앱 아이콘은 알파가 없어 둥근 모서리 바깥이 흰색으로 남는다(배민이 그랬다).
    흰색을 전부 지우면 로고 안쪽 흰 글자까지 사라지므로 flood fill로 모서리에서만 지운다.
    """
    width, height = image.size
    mask = Image.new("L", (width + 2, height + 2), 0)
    mask.paste(image.convert("L").point(lambda v: 255 if v > 255 - CORNER_TOLERANCE else 0), (1, 1))
    for point in ((1, 1), (width, 1), (1, height), (width, height)):
        if mask.getpixel(point) == 255:
            ImageDraw.floodfill(mask, point, 128, thresh=CORNER_TOLERANCE)
    removed = mask.crop((1, 1, width + 1, height + 1)).point(lambda v: 0 if v == 128 else 255)
    result = image.copy()
    result.putalpha(Image.composite(image.getchannel("A"), Image.new("L", image.size, 0), removed))
    return result


def invert_alpha(image: Image.Image) -> Image.Image:
    """파낸 글자만 남긴다.

    단순히 뒤집으면 로고 '바깥'까지 불투명해져 테두리 프레임이 생긴다. 뒤집은 뒤
    가장자리에서 flood fill로 바깥을 지워야 안쪽 구멍 = 실제 글자만 남는다.
    """
    mask = image.getchannel("A").point(lambda value: 255 - value).convert("L")
    width, height = mask.size
    border = [(0, 0), (width - 1, 0), (0, height - 1), (width - 1, height - 1),
              (width // 2, 0), (width // 2, height - 1), (0, height // 2), (width - 1, height // 2)]
    for point in border:
        if mask.getpixel(point) > 128:
            ImageDraw.floodfill(mask, point, 0, thresh=100)
    flipped = Image.new("RGBA", image.size, (255, 255, 255, 0))
    flipped.putalpha(mask)
    return flipped
