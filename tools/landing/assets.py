"""Wylicza pliki strony wskazane w HTML-u i w CSS-ie.

Narzędzie pilnuje, żeby w `docs/` nie zostało nic, czego strona nie używa, ani
odsyłacz do pliku, którego nie ma. Patrzy na `src`, `href`, atrybuty `data-*`
(galeria podmienia zrzuty motywem) oraz na kanoniczne adresy
`https://techparka.github.io/pitstop/` z meta i JSON-LD, więc sprawdza też
`og:image` i zrzuty pokazywane wyszukiwarce.

Run: python tools/landing/assets.py
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

DOCS = Path(__file__).resolve().parents[2] / "docs"
CANONICAL = "https://techparka.github.io/pitstop/"

# sciezki lokalne w kazdym atrybucie: src, href, data-light, data-dark-full, JSON-LD
LOCAL_ASSET = re.compile(r"(?:screenshots|assets)/[^\"')\s]+\.(?:webp|png|jpe?g|woff2|css|js)")
RELATIVE = re.compile(r"(?:src|href)=\"([^\"]+)\"")
EXTERNAL = re.compile(r"^(https?:|mailto:|data:|#|/)")
CSS_URL = re.compile(r"url\(\s*[\"']?([^)\"']+?)[\"']?\s*\)")
# pusty plik jest w porzadku tylko tu (svg-ikony sa w inline <svg>, ikonki svg moga byc puste)
ALLOW_EMPTY = {".svg"}


def referenced_paths() -> set[Path]:
    """Wszystkie sciezki w docs/, o ktorych strona wspomina."""
    html = (DOCS / "index.html").read_text(encoding="utf-8")
    refs: set[Path] = set()

    for value in RELATIVE.findall(html):
        if not EXTERNAL.match(value):
            refs.add((DOCS / value.split("#")[0].split("?")[0]).resolve())
    for name in LOCAL_ASSET.findall(html):
        refs.add((DOCS / name).resolve())
    prefix = re.compile(re.escape(CANONICAL) + r"([^\"']+)")
    for path in prefix.findall(html):
        refs.add((DOCS / path).resolve())

    for css in [DOCS / "styles.css", DOCS / "assets" / "fonts" / "fonts.css"]:
        if not css.exists():
            continue
        for url in CSS_URL.findall(css.read_text(encoding="utf-8")):
            if not EXTERNAL.match(url):
                refs.add((css.parent / url).resolve())
    return refs


def referenced_files() -> list[str]:
    """Zwraca liste opisow problemow: brakujace pliki i pliki o rozmiarze zero."""
    problems: list[str] = []
    refs = referenced_paths()

    for css in [DOCS / "styles.css", DOCS / "assets" / "fonts" / "fonts.css"]:
        if not css.exists():
            problems.append(f"brak {css.relative_to(DOCS)}")

    for path in sorted(refs):
        rel = path.relative_to(DOCS)
        if not path.exists():
            problems.append(f"brak {rel}")
        elif path.suffix.lower() not in ALLOW_EMPTY and path.suffix and path.stat().st_size == 0:
            problems.append(f"pusty {rel}")
    return problems


def orphan_files() -> list[str]:
    """Pliki w docs/, o ktorych strona nie wspomina zadnym odswiezem.

    Chodzi o to, by do repozytorium nie wskakiwaly produkty pomiedzy etapy pracy
    (stare okladki, wersje probejne krojow). index.html i .nojekyll sa wolne, tak
    samo pliki LICENSE i `.md`: licencje krojow musza lezec obok fontow, choc
    zadna strona ich nie wczytuje.
    """
    refs = {str(p.relative_to(DOCS)).replace("\\", "/") for p in referenced_paths()}
    # logo.png: README.md w repozytorium publicznym pokazuje te logo nad naglowkiem
    wolne = {"index.html", ".nojekyll", "logo.png"}
    orphans: list[str] = []
    for path in sorted(DOCS.rglob("*")):
        if not path.is_file():
            continue
        rel = str(path.relative_to(DOCS)).replace("\\", "/")
        if rel in wolne or rel in refs:
            continue
        if path.name.startswith("LICENSE") or path.suffix.lower() == ".md":
            continue
        orphans.append(rel)
    return orphans


def main() -> int:
    problems = referenced_files()
    for line in problems:
        print("UWAGA", line)
    for rel in orphan_files():
        print("ZBEDNY", rel)
    if problems or orphan_files():
        return 1
    print("wszystkie wskazane pliki sa na miejscu, zadnych zbednych")
    return 0


if __name__ == "__main__":
    sys.exit(main())
