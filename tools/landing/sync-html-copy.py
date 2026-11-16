"""Wyprowadza bazowy (polski) tekst w docs/index.html ze słownika PL z docs/app.js.

Tłumaczenie i tak nadpisuje treść elementów [data-i18n], ale jeśli bazowy HTML
mija się ze słownikiem, to bez włączonego JS, w podglądzie GitHuba i w tym, co
czytają wyszukiwarki, zostaje starsze zdanie. Narzędzie przepisuje treść
elementów [data-i18n], których wpis w słowniku PL jest tekstem; wpisy liczone
przez funkcje zostają bez zmian.

Dodatkowo mówi, których kluczy nie ma w słownikach, oraz czy słowniki PL i EN
mają te same klucze. Zwraca kod 1, gdy któreś słowo braknie, więc nadaje się do
bramki przed wgraniem strony.

Run: python tools/landing/sync-html-copy.py
"""
from __future__ import annotations

import pathlib
import re
import sys

from browser import keys, launch, served, text_entries  # narzedzia z tego katalogu
from playwright.sync_api import sync_playwright

DOCS = pathlib.Path(__file__).resolve().parents[2] / "docs"
HTML = DOCS / "index.html"

ELEMENT = re.compile(
    r'<(h[1-4]|p|li|b|span|summary|figcaption|button|label|small|strong|dd|dt|a)\b[^>]*?data-i18n="([^"]+)"[^>]*>'
)


def main() -> int:
    html = HTML.read_text(encoding="utf-8")
    with served() as base, sync_playwright() as pw:
        browser = launch(pw)
        page = browser.new_page()
        page.goto(base + "?qa", wait_until="load")
        page.wait_for_timeout(300)
        pl = text_entries(page, "PL")
        en = text_entries(page, "EN")
        all_pl, all_en = keys(page, "PL"), keys(page, "EN")
        browser.close()

    spans = [(m.start(), m.end(), m.group(1), m.group(2)) for m in ELEMENT.finditer(html)]
    changed = 0
    for _start, tag_end, tag, key in reversed(spans):
        value = pl.get(key)
        if value is None:
            continue
        close = html.index(f"</{tag}>", tag_end)
        if html[tag_end:close].strip() == value.strip():
            continue
        html = html[:tag_end] + value + html[close:]
        changed += 1

    if changed:
        HTML.write_text(html, encoding="utf-8", newline="\n")

    used = {k for _s, _e, _t, k in spans}
    missing_pl = sorted(k for k in used if k not in all_pl)
    missing_en = sorted(k for k in used if k not in all_en)
    only_pl = sorted(set(all_pl) - set(all_en))
    only_en = sorted(set(all_en) - set(all_pl))

    print(f"elementy [data-i18n] w HTML: {len(spans)}, przepisane: {changed}")
    print(f"słownik PL: {len(all_pl)} kluczy (tekstowych {len(pl)}), EN: {len(all_en)} (tekstowych {len(en)})")
    print("klucze w HTML bez tłumaczenia PL:", ", ".join(missing_pl) or "brak")
    print("klucze w HTML bez tłumaczenia EN:", ", ".join(missing_en) or "brak")
    print("tylko w PL:", ", ".join(only_pl) or "brak")
    print("tylko w EN:", ", ".join(only_en) or "brak")
    return 1 if (missing_pl or missing_en or only_pl or only_en) else 0


if __name__ == "__main__":
    sys.exit(main())
