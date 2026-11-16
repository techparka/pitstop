"""Przepisuje FAQPage z JSON-LD tak, by słowo w słowo odpowiadało widocznemu FAQ.

Strona tłumaczy treść w JS, dlatego tekst bierze z bazowego (polskiego) HTML-a,
rozłożonego DOMParserem w pustej stronie. Uruchom po każdej zmianie w sekcji FAQ.

Run: python tools/landing/sync-jsonld.py
"""
from __future__ import annotations

import json
import pathlib
import re

from playwright.sync_api import sync_playwright

DOCS = pathlib.Path(__file__).resolve().parents[2] / "docs"
PAGE = DOCS / "index.html"

EXTRACT = """(src) => {
  const doc = new DOMParser().parseFromString(src, 'text/html');
  const clean = (t) => t.replace(/\\u00a0/g, ' ').replace(/\\s+/g, ' ').trim();
  return [...doc.querySelectorAll('.faq')].map((d) => ({
    q: clean(d.querySelector('summary').textContent),
    a: clean(d.querySelector('p').textContent)
  }));
}"""


def main() -> int:
    html = PAGE.read_text(encoding="utf-8")
    blocks = re.findall(r'<script type="application/ld\+json">(.*?)</script>', html, re.S)
    if not blocks:
        raise SystemExit("w HTML nie ma żadnego bloku JSON-LD")

    with sync_playwright() as pw:
        try:
            browser = pw.chromium.launch(headless=True)
        except Exception:
            browser = pw.chromium.launch(headless=True, channel="msedge")
        page = browser.new_page()
        page.goto("about:blank")
        faq_items = page.evaluate(EXTRACT, html)
        browser.close()

    if not faq_items:
        raise SystemExit("nie znaleziono elementów .faq w bazowym HTML")

    faq = {
        "@context": "https://schema.org",
        "@type": "FAQPage",
        "mainEntity": [
            {
                "@type": "Question",
                "name": item["q"],
                "acceptedAnswer": {"@type": "Answer", "text": item["a"]},
            }
            for item in faq_items
        ],
    }

    old = next(b for b in blocks if json.loads(b).get("@type") == "FAQPage")
    html = html.replace(old, json.dumps(faq, ensure_ascii=False, indent=2))
    PAGE.write_text(html, encoding="utf-8", newline="\n")
    print(f"zsynchronizowano {len(faq_items)} pytań FAQ do JSON-LD")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
