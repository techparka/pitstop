"""Wspólne części narzędzi strony startowej: serwer pod docs i przeglądarka.

Uruchamiaj z katalogu projektu: python tools/landing/<nazwa>.py
"""
from __future__ import annotations

import http.server
import socketserver
import threading
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator

DOCS = Path(__file__).resolve().parents[2] / "docs"
PORT = 8755
BASE = f"http://127.0.0.1:{PORT}/"


class _Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(DOCS), **kwargs)

    def log_message(self, *args):  # ciszej w konsoli
        pass


@contextmanager
def served(port: int = PORT) -> Iterator[str]:
    """Serwuje docs/ znad 127.0.0.1 i zwraca adres bazowy."""
    socketserver.TCPServer.allow_reuse_address = True
    httpd = socketserver.TCPServer(("127.0.0.1", port), _Handler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    try:
        yield f"http://127.0.0.1:{port}/"
    finally:
        httpd.shutdown()
        httpd.server_close()


def launch(pw):
    """Chromium, a gdy go brakuje, zainstalowana w Windows przeglądarka Edge."""
    try:
        return pw.chromium.launch(headless=True)
    except Exception:
        return pw.chromium.launch(headless=True, channel="msedge")


def text_entries(page, name: str) -> dict:
    """Tekstowe wpisy słownika (PL albo EN) bez funkcji liczących formy."""
    return page.evaluate(
        "(n) => Object.fromEntries(Object.entries(window.__pitstop[n]).filter(([, v]) => typeof v === 'string'))",
        name,
    )


def keys(page, name: str) -> list:
    """Wszystkie klucze słownika, także te z funkcjami."""
    return page.evaluate("(n) => Object.keys(window.__pitstop[n])", name)
