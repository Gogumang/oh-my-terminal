"""iTerm2 Dynamic Profile 생성기.

.itermcolors가 아니라 Dynamic Profile을 쓰는 이유: 색만이 아니라 배경 로고·탭 색·
뱃지·폰트까지 담을 수 있고, 파일을 폴더에 넣기만 하면 iTerm2가 재시작 없이 즉시 반영한다.
삭제하면 그대로 제거된다.
"""
import hashlib
import json
import uuid
from pathlib import Path

from ..domain import palette


def _colour(rgb, alpha=1.0):
    red, green, blue = rgb
    return {"Red Component": red, "Green Component": green, "Blue Component": blue,
            "Color Space": "sRGB", "Alpha Component": alpha}


def _stable_guid(key):
    """GUID는 재빌드 사이에 안정적이어야 한다. 매번 새로 만들면 재빌드마다 새 프로필이
    생겨 사용자의 창 설정과 단축키 연결이 끊긴다."""
    seed = hashlib.sha1(f"oh-my-terminal:{key}".encode()).digest()
    return str(uuid.UUID(bytes=seed[:16], version=5)).upper()


class ITerm2ProfileWriter:
    def write(self, brands, font_postscript, output_root: Path) -> Path:
        profiles = []
        for brand in brands:
            colours = palette.terminal_palette(brand)
            profile = {
                "Guid": _stable_guid(brand.key),
                "Name": f"{brand.name} Brand",
                "Tags": ["Brand", brand.name],
                "Use Separate Colors for Light and Dark Mode": True,
                "Draw Powerline Glyphs": True,
                "Minimum Contrast": 0.0,
                # 여러 회사 창을 동시에 띄웠을 때 탭 색으로 한눈에 구분된다.
                "Use Tab Color": True,
                "Tab Color": _colour(colours["Dark"]["accent"]),
                "Badge Text": brand.name,
                "Badge Max Width": 0.3,
                "Badge Max Height": 0.15,
            }
            if font_postscript:
                # 로고 글리프가 이 폰트에만 있으므로 프로필이 폰트를 직접 지정해야 한다.
                profile["Normal Font"] = f"{font_postscript} 13"
            for mode in ("Dark", "Light"):
                entry = colours[mode]
                profile[f"Background Color ({mode})"] = _colour(entry["background"])
                profile[f"Foreground Color ({mode})"] = _colour(entry["foreground"])
                profile[f"Cursor Color ({mode})"] = _colour(entry["accent"])
                profile[f"Cursor Text Color ({mode})"] = _colour(entry["background"])
                profile[f"Badge Color ({mode})"] = _colour(entry["accent"], alpha=0.45)
                profile[f"Link Color ({mode})"] = _colour(entry["accent"])
                profile[f"Selection Color ({mode})"] = _colour(entry["selection"])
                profile[f"Selected Text Color ({mode})"] = _colour(entry["foreground"])
                for index, colour in enumerate(entry["ansi"]):
                    profile[f"Ansi {index} Color ({mode})"] = _colour(colour)
            if brand.has_logo:
                profile["Background Image Location"] = str(Path(brand.logo_path).resolve())
                profile["Background Image Mode"] = 3      # aspect fit — 로고 비율 유지
                profile["Blend"] = 0.08                   # 워터마크 수준. 넘으면 글자를 먹는다
                profile["Icon"] = 2                       # custom
                profile["Custom Icon Path"] = str(Path(brand.logo_path).resolve())
            profiles.append(profile)

        output = output_root / "iterm2" / "brand-themes.json"
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps({"Profiles": profiles}, indent=2, ensure_ascii=False) + "\n")
        return output
