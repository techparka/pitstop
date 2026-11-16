"""Przygotowanie assetów strony prezentacyjnej PitStop.

uruchom:  python tools/landing/make-assets.py
wynik:    docs/screenshots/*.webp, docs/assets/{logo-96,logo-192,logo-mark,favicon,apple-touch}.png,
          docs/assets/fonts/*.woff2 + fonts.css + teksty licencji

Źródła to zrzuty z katalogu `screenshots-demo/` (PNG w katalogu projektu, webp w
publicznym repozytorium) oraz logo `tools/landing/brand/logo.png`. Kroje są podzbierane z pełnych
plików Google Fonts zgromadzonych w innym projekcie; na stronie nie ma żadnego CDN.
"""
from __future__ import annotations

import io
import pathlib
import shutil
import sys

import numpy as np
from fontTools.subset import main as subset_main
from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs"
SHOTS = DOCS / "screenshots"
ASSETS = DOCS / "assets"
SRC_SHOTS = ROOT / "screenshots-demo"
SRC_LOGO = pathlib.Path(__file__).resolve().parent / "brand" / "logo.png"
FONTS_SRC = pathlib.Path("W:/projekty/amica-home/openoven-public/docs/assets/fonts")
# Teksty licencji OFL kopiujemy z gotowych, sprawdzonych kopii w innym projekcie.
FONTS_LIC = pathlib.Path("W:/projekty/skarbio-public/docs/assets/fonts")

# Nazwy zrzutów w repo: jasny-pulpit.png -> pulpit-light.webp
SCREENS = {
    "jasny-pulpit": ("pulpit", "light"),
    "ciemny-pulpit": ("pulpit", "dark"),
    "jasny-historia": ("historia", "light"),
    "ciemny-historia": ("historia", "dark"),
    "jasny-terminy": ("terminy", "light"),
    "ciemny-terminy": ("terminy", "dark"),
}
# 540 px to makieta ok. 270 px CSS, 1080 px to pełny kadr pokazywany w lightboxie.
VARIANTS = {"": 540, "-full": 1080}

FONTS = [
    "Inter-latin.woff2", "Inter-latin-ext.woff2",
    "SpaceGrotesk-latin.woff2", "SpaceGrotesk-latin-ext.woff2",
    "JetBrainsMono-latin.woff2", "JetBrainsMono-latin-ext.woff2",
]
# Znaki, których strona naprawdę używa: ASCII, łacina zachodnia, polskie znaki, typografia.
CHARSET = (
    "U+0020-007E,U+00A0-00FF,U+0104-0107,U+0118-011B,U+0131,U+0139,U+0141-0144,"
    "U+015A-0161,U+0164-0167,U+0179-017E,"
    "U+2013-2014,U+2018-201E,U+2022,U+2026,U+2039-203A,U+20AC,U+2190-2193,U+2212,U+2713"
)
FONTS_CSS = """/* Kroje własne (bez CDN). Podzbiór latin oraz latin-ext z polskimi diakrytykami. */
@font-face{font-family:'Inter';font-style:normal;font-weight:100 900;font-display:swap;
  src:url('./Inter-latin.woff2') format('woff2');
  unicode-range:U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD}
@font-face{font-family:'Inter';font-style:normal;font-weight:100 900;font-display:swap;
  src:url('./Inter-latin-ext.woff2') format('woff2');
  unicode-range:U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C4,U+2113,U+2C60-2C7F}
@font-face{font-family:'Space Grotesk';font-style:normal;font-weight:300 700;font-display:swap;
  src:url('./SpaceGrotesk-latin.woff2') format('woff2');
  unicode-range:U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD}
@font-face{font-family:'Space Grotesk';font-style:normal;font-weight:300 700;font-display:swap;
  src:url('./SpaceGrotesk-latin-ext.woff2') format('woff2');
  unicode-range:U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C4,U+2113,U+2C60-2C7F}
@font-face{font-family:'JetBrains Mono';font-style:normal;font-weight:400 800;font-display:swap;
  src:url('./JetBrainsMono-latin.woff2') format('woff2');
  unicode-range:U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD}
@font-face{font-family:'JetBrains Mono';font-style:normal;font-weight:400 800;font-display:swap;
  src:url('./JetBrainsMono-latin-ext.woff2') format('woff2');
  unicode-range:U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C4,U+2113,U+2C60-2C7F}
"""
LICENSE_FONTS = """# Kroje pisma strony

Strona korzysta z trzech krojów na własnym hostingu, bez żadnego CDN. Każdy plik `.woff2`
to podzbiór oryginalnego kroju Google Fonts: usunięte zostały glify spoza zestawu znaków,
których strona faktycznie używa (łacina zachodnia, polskie diakrytyki, podstawowa typografia).

| Krój | Autor | Licencja | Źródło |
|---|---|---|---|
| Inter | Rasmus Andersson | SIL Open Font License 1.1 | https://rsms.me/inter/ |
| Space Grotesk | Florian Karsten | SIL Open Font License 1.1 | https://fonts.google.com/specimen/Space+Grotesk |
| JetBrains Mono | Philipp Nurullin, Nikolay Avtonomov | SIL Open Font License 1.1 | https://www.jetbrains.com/mono/ |

Wszystkie trzy kroje są publikowane na licencji SIL OFL 1.1, która zezwala na wgrywanie,
modyfikację (w tym podzbieranie znaków) i redystrybucję plików fontu w dokumentach
i stronach. Pełne teksty licencji leżą obok w tym katalogu. Podzbieranie wykonał
`tools/landing/make-assets.py`.
"""


def find_source(stem: str) -> pathlib.Path:
    for ext in (".png", ".webp"):
        p = SRC_SHOTS / f"{stem}{ext}"
        if p.exists():
            return p
    raise SystemExit(f"brak zrzutu {stem} w {SRC_SHOTS} (png ani webp)")


def webp(src: pathlib.Path, dst: pathlib.Path, width: int, quality: int) -> None:
    im = Image.open(src).convert("RGB")
    if im.width > width:
        im = im.resize((width, round(im.height * width / im.width)), Image.LANCZOS)
    im.save(dst, "WEBP", quality=quality, method=6, exact=True)
    print(f"  {dst.relative_to(DOCS)}  {im.width}x{im.height}  {dst.stat().st_size/1024:.0f} kB")


def png(src: pathlib.Path, dst: pathlib.Path, size: int) -> None:
    im = Image.open(src).convert("RGBA").resize((size, size), Image.LANCZOS)
    im.save(dst, "PNG", optimize=True)
    print(f"  {dst.relative_to(DOCS)}  {size}x{size}  {dst.stat().st_size/1024:.1f} kB")


def transparent_mark(src: pathlib.Path, dst: pathlib.Path, size: int) -> None:
    """Logo ma tło w kolorze tła motywu ciemnego; tu zostaje sam znak z kanałem alfa."""
    im = Image.open(src).convert("RGBA").resize((size, size), Image.LANCZOS)
    bg = im.getpixel((2, 2))
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            d = abs(r - bg[0]) + abs(g - bg[1]) + abs(b - bg[2])
            px[x, y] = (r, g, b, 0 if d < 28 else a)
    im.save(dst, "PNG", optimize=True)
    print(f"  {dst.relative_to(DOCS)}  {size}x{size}  {dst.stat().st_size/1024:.1f} kB (bez tła)")


# --- okładka udostępniana (og:image) ---------------------------------------

OG_SIZE = (1200, 630)
OG_BG = (17, 21, 28)        # #11151C
OG_SURFACE = (29, 34, 44)   # #1D222C
OG_ACCENT = (255, 122, 61)  # #FF7A3D
OG_INK = (245, 246, 248)    # #F5F6F8
OG_MUTED = (176, 186, 201)
OG_FAINT = (139, 149, 166)
OG_LINE = (58, 67, 82)
FONTS_OUT = ASSETS / "fonts"


def _font(rel: str, size: int, weight: int | None = None) -> ImageFont.FreeTypeFont:
    """PIL nie czyta woff2, więc krój jest rozwijany do TTF w pamięci."""
    font = TTFont(FONTS_OUT / rel)
    font.flavor = None
    buf = io.BytesIO()
    font.save(buf)
    buf.seek(0)
    f = ImageFont.truetype(buf, size)
    if weight is not None:
        try:
            f.set_variation_by_axes([weight])
        except Exception:
            pass
    return f


def _text_width(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, tracking: int = 0) -> int:
    width = draw.textlength(text, font=font)
    return round(width + tracking * max(0, len(text) - 1))


def _draw_tracked(draw, xy, text, font, fill, tracking: int = 0):
    x, y = xy
    for ch in text:
        draw.text((x, y), ch, font=font, fill=fill)
        x += draw.textlength(ch, font=font) + tracking
    return round(x - tracking)


def _rounded(im: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, im.width - 1, im.height - 1], radius, fill=255)
    out = im.convert("RGBA")
    out.putalpha(mask)
    return out


def _phone(src: pathlib.Path, height: int, ratio: float = 0.62, tilt: float = 0.0) -> Image.Image:
    """Zrzut 1080x2400 przycięty od góry, w ramce i lekko przechylony."""
    im = Image.open(src).convert("RGB")
    crop_h = round(im.width / ratio)
    if crop_h > im.height:
        raise SystemExit(f"za wąski stosunek boków: {src}")
    im = im.crop((0, 0, im.width, crop_h)).resize(
        (round(height * ratio), height), Image.LANCZOS)
    pad = max(8, round(height * 0.022))
    frame = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), OG_SURFACE + (255,))
    frame.paste(im, (pad, pad))
    frame = _rounded(frame, round(height * 0.075))
    border = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    ImageDraw.Draw(border).rounded_rectangle(
        [0, 0, frame.width - 1, frame.height - 1], round(height * 0.075), outline=OG_LINE + (255,), width=2)
    frame.alpha_composite(border)
    if tilt:
        frame = frame.rotate(tilt, Image.BICUBIC, expand=True)
    return frame


def og_cover() -> None:
    w, h = OG_SIZE
    canvas = Image.new("RGB", OG_SIZE, OG_BG)

    # ciepły poblask w prawym gornym rogu
    yy, xx = np.mgrid[0:h, 0:w].astype("float32")
    dist = np.sqrt(((xx - w * 0.86) / (w * 0.55)) ** 2 + ((yy - h * 0.12) / (h * 0.95)) ** 2)
    strength = np.clip(1 - dist, 0, 1) ** 2.3 * 120
    glow = np.dstack([np.broadcast_to(np.array(OG_ACCENT, dtype="uint8"), (h, w, 3)),
                      strength.astype("uint8")])
    canvas = Image.alpha_composite(canvas.convert("RGBA"), Image.fromarray(glow, "RGBA"))

    # dwa telefony po prawej
    back = _phone(SHOTS / "terminy-dark-full.webp", round(h * 0.74), tilt=-7)
    canvas.alpha_composite(back, (w - back.width - round(w * 0.115), h - back.height + 40))
    front = _phone(SHOTS / "pulpit-dark-full.webp", round(h * 0.86), tilt=0)
    canvas.alpha_composite(front, (w - front.width - 54, h - front.height + 26))

    draw = ImageDraw.Draw(canvas)
    kicker = _font("JetBrainsMono-latin.woff2", 21, 600)
    display = _font("SpaceGrotesk-latin.woff2", 108, 700)
    body = _font("Inter-latin.woff2", 34, 500)
    mono = _font("JetBrainsMono-latin.woff2", 21, 400)

    x, y = 76, 96
    _draw_tracked(draw, (x, y), "ANDROID · HISTORIA SERWISOWA", kicker, OG_ACCENT, tracking=3)
    draw.text((x - 3, y + 52), "PitStop", font=display, fill=OG_INK)

    copy_lines = ("Terminy, rachunki i tankowania",
                  "w jednym telefonie. Bez konta.")
    text_right = w - front.width - 150
    size = 34
    while max(_text_width(draw, t, _font("Inter-latin.woff2", size, 500)) for t in copy_lines) > text_right - x and size > 24:
        size -= 1
    body = _font("Inter-latin.woff2", size, 500)
    ty = y + 52 + 118
    for line in copy_lines:
        draw.text((x, ty), line, font=body, fill=OG_MUTED)
        ty += round(size * 1.42)

    draw.line([(x, ty + 8), (x + 120, ty + 8)], fill=OG_ACCENT, width=4)
    foot = "1.0 na GitHubie · 2.0 w budowie · 8 tabel lokalnej bazy"
    draw.text((x, ty + 34), foot, font=mono, fill=OG_FAINT)

    out = DOCS / "og-cover.png"
    canvas.convert("RGB").save(out, "PNG", optimize=True)
    print(f"  {out.name}  {w}x{h}  {out.stat().st_size/1024:.0f} kB")


def main() -> None:
    if "og" in sys.argv:
        og_cover()
        return

    SHOTS.mkdir(parents=True, exist_ok=True)
    ASSETS.mkdir(parents=True, exist_ok=True)
    (DOCS / ".nojekyll").touch()

    print("zrzuty -> webp:")
    for stem, (name, theme) in SCREENS.items():
        src = find_source(stem)
        for suffix, width in VARIANTS.items():
            webp(src, SHOTS / f"{name}-{theme}{suffix}.webp", width, 82 if suffix else 80)

    print("logo i ikony:")
    if not SRC_LOGO.exists():
        raise SystemExit(f"brak logo: {SRC_LOGO}")
    png(SRC_LOGO, ASSETS / "logo-96.png", 96)
    png(SRC_LOGO, ASSETS / "logo-192.png", 192)
    png(SRC_LOGO, ASSETS / "favicon.png", 48)
    png(SRC_LOGO, ASSETS / "apple-touch-icon.png", 180)
    transparent_mark(SRC_LOGO, ASSETS / "logo-mark.png", 256)

    print("kroje (podzbiór -> woff2):")
    out = ASSETS / "fonts"
    out.mkdir(parents=True, exist_ok=True)
    before = after = 0
    for name in FONTS:
        src = FONTS_SRC / name
        if not src.exists():
            raise SystemExit(f"brak kroju źródłowego: {src}")
        dst = out / name
        subset_main([
            str(src), f"--output-file={dst}", "--flavor=woff2",
            f"--unicodes={CHARSET}", "--layout-features=*", "--ignore-missing-unicodes",
            "--desubroutinize", "--no-hinting", "--name-IDs=1,2,3,4,6", "--recalc-bounds",
        ])
        b, a = src.stat().st_size, dst.stat().st_size
        before, after = before + b, after + a
        if dst.read_bytes()[:3] != b"wOF":
            raise SystemExit(f"{dst} nie jest plikiem woff2")
        print(f"  {dst.relative_to(DOCS)}  {b/1024:.0f} kB -> {a/1024:.1f} kB")
    print(f"  kroje razem: {before/1024:.0f} kB -> {after/1024:.0f} kB")
    (out / "fonts.css").write_text(FONTS_CSS, encoding="utf-8", newline="\n")
    for name in ("Inter", "Space-Grotesk", "JetBrains-Mono"):
        lic = FONTS_LIC / f"LICENSE-{name}.txt"
        if lic.exists():
            shutil.copyfile(lic, out / f"LICENSE-{name}.txt")
        else:
            raise SystemExit(f"brak tekstu licencji: {lic}")
    (out / "LICENSE-fonts.md").write_text(LICENSE_FONTS, encoding="utf-8", newline="\n")

    print("okładka udostępniana:")
    og_cover()

    total = sum(p.stat().st_size for p in DOCS.rglob("*") if p.is_file())
    print(f"\ndocs/ razem: {total/1024/1024:.2f} MB")


if __name__ == "__main__":
    main()
