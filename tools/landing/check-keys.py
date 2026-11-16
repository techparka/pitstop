"""Sprawdza, czy słowniki w docs/app.js i atrybuty data-i18n w docs/index.html
mają dokładnie te same klucze, których strona użyje.

Zestawia trzy źródła: klucze w HTML-u (data-i18n oraz warianty -legend, -label,
data-name-key, data-alt-key), wpisy słownika PL i EN, oraz wpisy wyciągane przez
kod kalkulatorów (tf('...')). Klucz bez wpisu to pusty ekran po przełączeniu
języka, klucz bez miejsca w HTML-u to martwy wpis, który tylko rośnie. Narzędzie
nic nie zmienia, tylko mówi; zwraca 1, gdy któraś strona się rozjedzie.

Nie potrzebuje przeglądarki, więc warto je puścić przed sync-html-copy.py.

Run: python tools/landing/check-keys.py
"""
from __future__ import annotations

import pathlib
import re
import sys

DOCS = pathlib.Path(__file__).resolve().parents[2] / "docs"
KONIEC_BLOKU = "\n  };"


def main() -> int:
    html = (DOCS / "index.html").read_text(encoding="utf-8")
    js = (DOCS / "app.js").read_text(encoding="utf-8")

    uzyte = set(re.findall(r'data-i18n(?:-legend|-label)?="([^"]+)"', html))
    uzyte |= set(re.findall(r'data-(?:name|alt)-key="([^"]+)"', html))

    start_pl = js.index("const PL = {")
    start_en = js.index("const EN = {")
    end_pl = js.index(KONIEC_BLOKU, start_pl, start_en)
    end_en = js.index(KONIEC_BLOKU, start_en)
    kod = js[:start_pl] + js[end_pl:start_en] + js[end_en + len(KONIEC_BLOKU):]

    klucz_w = re.compile(r"'([a-zA-Z0-9._]+)':")
    slownik = {"PL": set(klucz_w.findall(js[start_pl:end_pl])),
               "EN": set(klucz_w.findall(js[start_en:end_en]))}

    def zyje(klucz: str) -> bool:
        return klucz in uzyte or f"'{klucz}'" in kod or f'"{klucz}"' in kod

    bledy = 0
    for jezyk, klucze in slownik.items():
        braki = sorted(uzyte - klucze)
        martwe = sorted(k for k in klucze if not zyje(k))
        print(f"słownik {jezyk}: {len(klucze)} kluczy, HTML używa {len(uzyte)}")
        if braki:
            bledy += 1
            print(f"  BRAK wpisu dla: {', '.join(braki)}")
        if martwe:
            bledy += 1
            print(f"  MARTWE wpisy (usunąć): {', '.join(martwe)}")

    rozjazd = sorted(slownik["PL"] ^ slownik["EN"])
    if rozjazd:
        bledy += 1
        print(f"KLUCZE TYLKO W JEDNYM SŁOWNIKU: {', '.join(rozjazd)}")

    if bledy:
        print("słowniki do poprawki; tekst strony płynie ze słownika, nie z HTML")
        return 1
    print("słowniki i HTML zgadzają się co do klucza")
    return 0


if __name__ == "__main__":
    sys.exit(main())
