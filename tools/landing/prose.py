"""Wypisuje tekst strony (PL albo EN) do przejrzenia prozy.

Run: python tools/landing/prose.py [en]
"""
from __future__ import annotations

import http.server
import pathlib
import socketserver
import sys
import threading

from playwright.sync_api import sync_playwright

DOCS = pathlib.Path(__file__).resolve().parents[2] / "docs"
PORT = 8751
BASE = f"http://127.0.0.1:{PORT}/"

EXPR = """() => {
  const NL = String.fromCharCode(10);
  const sel = 'h1,h2,h3,h4,p,li,summary,figcaption,.fact__label,.fact__src,.number__label,.number__src,.chip__k,.item__note,.datarow__v,.lead,.note,.badge';
  const out = [];
  for (const sec of document.querySelectorAll('header, main section, footer')) {
    const parts = [...sec.querySelectorAll(sel)]
      .map((e) => e.textContent.trim())
      .filter((t) => t && t.length > 2);
    out.push('=== ' + (sec.id || sec.className) + ' ===' + NL + [...new Set(parts)].join(NL));
  }
  return out.join(NL + NL);
}"""


def main() -> int:
    class Handler(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *a, **k):
            super().__init__(*a, directory=str(DOCS), **k)

        def log_message(self, *a):
            pass

    socketserver.TCPServer.allow_reuse_address = True
    httpd = socketserver.TCPServer(("127.0.0.1", PORT), Handler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()

    want = "en" if "en" in sys.argv else "pl"
    with sync_playwright() as pw:
        try:
            browser = pw.chromium.launch(headless=True)
        except Exception:
            browser = pw.chromium.launch(headless=True, channel="msedge")
        page = browser.new_page()
        page.goto(BASE, wait_until="load")
        page.wait_for_timeout(500)
        if want == "en":
            page.locator("[data-lang=en]").click()
            page.wait_for_timeout(300)
        print(page.evaluate(EXPR))
        browser.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
