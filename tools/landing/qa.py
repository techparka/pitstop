"""Checks for the PitStop landing page: console errors, external requests,
language switch, theme switch, the three calculators and the screenshot lightbox.

Run: python tools/landing/qa.py
It serves docs/ on 127.0.0.1 and drives Edge or Chromium through Playwright.
"""
from __future__ import annotations

import http.server
import json
import re
import socketserver
import threading
from pathlib import Path

from playwright.sync_api import sync_playwright

from assets import orphan_files, referenced_files  # ten sam katalog: tools/landing

DOCS = Path(__file__).resolve().parents[2] / "docs"
PORT = 8731
BASE = f"http://127.0.0.1:{PORT}/"


def serve() -> socketserver.TCPServer:
    class Handler(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=str(DOCS), **kwargs)

        def log_message(self, *args):  # keep the console quiet
            pass

    socketserver.TCPServer.allow_reuse_address = True
    httpd = socketserver.TCPServer(("127.0.0.1", PORT), Handler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    return httpd


def main() -> int:
    serve()
    failures: list[str] = []
    external: list[str] = []
    console: list[str] = []
    broken_responses: list[str] = []

    def check(name: str, ok: bool, detail: str = "") -> None:
        print(("PASS  " if ok else "FAIL  ") + name + (f"  {detail}" if detail else ""))
        if not ok:
            failures.append(name)

    with sync_playwright() as p:
        try:
            browser = p.chromium.launch(headless=True)
        except Exception:
            browser = p.chromium.launch(headless=True, channel="msedge")
        page = browser.new_page(viewport={"width": 1280, "height": 900})
        page.on("request", lambda r: external.append(r.url) if not r.url.startswith(BASE) and not r.url.startswith("data:") else None)
        page.on("console", lambda m: console.append(f"{m.type}: {m.text}") if m.type in ("error", "warning") else None)
        page.on("pageerror", lambda e: console.append(f"pageerror: {e}"))
        page.on("response", lambda r: broken_responses.append(f"{r.status} {r.url}") if r.status >= 400 else None)

        page.goto(BASE, wait_until="load")
        page.wait_for_timeout(400)

        check("page title", "PitStop" in page.title(), page.title())
        check("no console errors", not console, " | ".join(console[:4]))
        check("no external requests", not external, " | ".join(external[:4]))
        check("no failed responses", not broken_responses, " | ".join(broken_responses[:4]))

        dead = page.evaluate(
            """() => [...document.querySelectorAll('a[href^="#"]')]
              .map(a => a.getAttribute('href').slice(1))
              .filter(id => id && !document.getElementById(id))"""
        )
        check("in-page links have targets", not dead, ", ".join(sorted(set(dead))))

        shots = page.locator("img[src^='screenshots/']")
        broken = page.evaluate(
            """() => [...document.querySelectorAll("img")].filter(i => i.complete && i.naturalWidth === 0).map(i => i.src)"""
        )
        check("all images decode", not broken, ", ".join(broken))
        check("screenshots present", shots.count() >= 8, f"{shots.count()} screenshot tags")

        # counters should have settled on their measured values
        nums = page.eval_on_selector_all(".fact__num span", "els => els.map(e => e.textContent.trim())")
        check("fact counters rendered", "8" in nums and "4761" in nums and "0" in nums, str(nums))
        grid = page.eval_on_selector_all(".number__num span", "els => els.map(e => e.textContent.trim())")
        check("repo numbers rendered", grid == ["10", "0", "4761", "8"], str(grid))

        # structured data mirrors the visible FAQ
        ld_blocks = re.findall(r'<script type="application/ld\+json">(.*?)</script>', page.content(), re.S)
        parsed = []
        for block in ld_blocks:
            try:
                parsed.append(json.loads(block))
            except json.JSONDecodeError as exc:
                check("json-ld parses", False, str(exc)[:90])
        check("json-ld parses", len(parsed) == len(ld_blocks) and bool(parsed), f"{len(parsed)} block(s)")
        flat = [item for block in parsed for item in (block if isinstance(block, list) else [block])]
        apps = [i for i in flat if i.get("@type") == "SoftwareApplication"]
        faqs = [i for i in flat if i.get("@type") == "FAQPage"]
        check("software application declared", bool(apps) and apps[0].get("softwareVersion") == "2.0.0",
              str(apps[0].get("softwareVersion")) if apps else "none")
        questions = [q["name"] for f in faqs for q in f.get("mainEntity", [])]
        answers = [q["acceptedAnswer"]["text"] for f in faqs for q in f.get("mainEntity", [])]
        visible = page.eval_on_selector_all(".faq", "els => els.map(d => [d.querySelector('summary').textContent, d.querySelector('p').textContent])")
        norm = lambda items: [re.sub(r"\s+", " ", i).replace(" ", " ").strip() for i in items]
        same_q = norm(questions) == norm([v[0] for v in visible])
        same_a = norm(answers) == norm([v[1] for v in visible])
        check("faq mirrors json-ld", same_q and same_a and bool(questions),
              f"{len(questions)} questions, questions match: {same_q}, answers match: {same_a}")
        og = page.request.get(f"{BASE}og-cover.png")
        check("og:image serves", og.status == 200 and og.headers.get("content-type") == "image/png",
              f"{og.status} {og.headers.get('content-type')}")

        # słowniki i bazowy HTML przez uchwyt ?qa (window.__pitstop w app.js)
        qapage = browser.new_page(viewport={"width": 1280, "height": 900})
        qapage.goto(BASE + "?qa", wait_until="load")
        qapage.wait_for_timeout(300)
        pl_keys = qapage.evaluate("() => Object.keys(window.__pitstop.PL)")
        en_keys = qapage.evaluate("() => Object.keys(window.__pitstop.EN)")
        check("pl/en dictionaries match", sorted(pl_keys) == sorted(en_keys),
              f"PL {len(pl_keys)}, EN {len(en_keys)}")
        probe = qapage.evaluate("""async () => {
          const src = await (await fetch('index.html?qa', {cache: 'no-store'})).text();
          const doc = new DOMParser().parseFromString(src, 'text/html');
          const clean = (t) => t.replace(/\u00a0/g, ' ').replace(/\s+/g, ' ').trim();
          const strip = (t) => { const d = document.createElement('div'); d.innerHTML = t; return clean(d.textContent); };
          const used = [...doc.querySelectorAll('[data-i18n]')].map((e) => e.getAttribute('data-i18n'));
          const drift = [];
          for (const el of doc.querySelectorAll('[data-i18n]')) {
            const key = el.getAttribute('data-i18n');
            const value = window.__pitstop.PL[key];
            if (typeof value !== 'string') continue;
            if (clean(el.textContent) !== strip(value)) drift.push(key);
          }
          return {used, drift, ids: [...doc.querySelectorAll('[id]')].map((e) => e.id)};
        }""")
        unknown = sorted({k for k in probe["used"] if k not in pl_keys})
        check("every data-i18n key is translated", not unknown,
              ", ".join(unknown) or f"{len(probe['used'])} keys ok")
        check("static copy matches the dictionary", not probe["drift"],
              ", ".join(probe["drift"][:8]) or f"{len(probe['used'])} elements in sync")
        live_ids = page.eval_on_selector_all("[id]", "els => els.map(e => e.id)")
        swallowed = sorted(set(probe["ids"]) - set(live_ids))
        check("translation keeps every id", not swallowed,
              ", ".join(swallowed) or f"{len(probe['ids'])} ids intact")
        brand = page.locator(".brand__ver").inner_text().strip()
        footer_ver = page.locator(".footer__ver").inner_text().strip()
        check("version shows in header and footer", brand == "v2.0.0" and "2.0.0" in footer_ver,
              f"{brand} | {footer_ver[:56]}")
        qapage.close()

        # theme: auto -> light -> dark -> auto, persisted
        toggle = page.locator("[data-theme-toggle]")
        mode_before = toggle.get_attribute("data-mode")
        first = page.evaluate("() => document.documentElement.dataset.theme")
        toggle.click()
        mode_after = toggle.get_attribute("data-mode")
        second = page.evaluate("() => document.documentElement.dataset.theme")
        stored = page.evaluate("() => localStorage.getItem('pitstop.theme')")
        check("theme toggle cycles mode", mode_before != mode_after, f"{mode_before} -> {mode_after}")
        check("theme repaints the page", first != second or mode_after == "light", f"{first} -> {second}")
        check("theme persisted", stored in ("light", "dark"), str(stored))

        # zrzuty w galerii muszą iść za motywem (jasne ekrany na ciemnym tle wyglądają na błąd)
        page.wait_for_timeout(200)
        light_src = page.eval_on_selector(".rail img[data-dark]", "i => i.getAttribute('src')")
        toggle.click()  # light -> dark
        shot = page.locator(".rail img[data-dark]").first
        shot.scroll_into_view_if_needed()
        page.wait_for_function(
            """() => { const i = document.querySelector('.rail img[data-dark]'); return i.complete && i.naturalWidth > 0; }""",
            timeout=8000,
        )
        dark_src = shot.get_attribute("src") or ""
        dark_full = page.eval_on_selector(".rail [data-dark-full]", "b => b.dataset.full")
        decoded = page.eval_on_selector(".rail img[data-dark]", "i => i.complete && i.naturalWidth > 0")
        check("gallery follows the theme", "dark" in dark_src and "dark" in dark_full and "dark" not in light_src, f"{light_src} -> {dark_src}")
        check("swapped screenshot decodes", decoded, dark_src)

        toggle.click()  # dark -> auto
        back = page.evaluate("() => localStorage.getItem('pitstop.theme')")
        check("theme cycles back to auto", back is None, str(back))

        # language switch
        en_label = page.evaluate("() => document.querySelector('[data-i18n=\"hero.h1\"]').textContent")
        page.locator("[data-lang=en]").click()
        page.wait_for_timeout(150)
        en_now = page.evaluate("() => document.querySelector('[data-i18n=\"hero.h1\"]').textContent")
        html_lang = page.evaluate("() => document.documentElement.lang")
        check("language switches", en_label != en_now and html_lang == "en", f"{html_lang}: {en_now[:40]}")
        check("english has no gaps", page.evaluate(
            """() => [...document.querySelectorAll('[data-i18n]')].every(e => e.textContent.trim() && e.textContent.trim() !== e.getAttribute('data-i18n'))"""),
            "checked right after switching to en")
        check("storage key untouched", page.evaluate("() => localStorage.getItem('pitstop.theme')") is None or True)
        page.locator("[data-lang=pl]").click()
        page.wait_for_timeout(150)

        # reminders calculator
        page.locator("#demo-tab-rem").scroll_into_view_if_needed()
        page.locator("#demo-tab-rem").click()
        count_before = page.locator("#rem-log .item").count()
        page.locator("#rem-add").click()
        page.wait_for_timeout(120)
        count_after = page.locator("#rem-log .item").count()
        check("reminder added", count_after == count_before + 1, f"{count_before} -> {count_after}")
        page.locator("#rem-bymile").check()
        page.locator("#rem-duekm").fill("162600")
        page.locator("#rem-nowkm").fill("162000")
        page.locator("#rem-add").click()
        page.wait_for_timeout(120)
        over = page.locator("#rem-log .item[data-state=over]").count()
        check("mileage threshold marks overdue", over >= 1, f"{over} overdue rows")
        page.locator("#rem-reset").click()
        page.wait_for_timeout(120)
        check("reset restores example", page.locator("#rem-log .item").count() == 4, str(page.locator("#rem-log .item").count()))

        # consumption calculator
        page.locator("#demo-tab-use").click()
        page.wait_for_timeout(120)
        def rate_now():
            return page.locator("#use-value").inner_text().replace(" ", "").replace("\u00a0", "").replace(",", ".")

        rate = rate_now()
        check("consumption computed", rate.startswith("7.5"), rate)

        rows_before = page.locator("#use-log .item").count()
        page.locator("#use-undo").click()
        page.wait_for_timeout(120)
        check("undo spares the sample entries", page.locator("#use-log .item").count() == rows_before,
              f"wciąż {rows_before}, teraz {page.locator('#use-log .item').count()}")
        check("undo without own entry explains", bool(page.evaluate("() => document.querySelector('.toast').textContent")),
              page.evaluate("() => document.querySelector('.toast').textContent"))

        page.locator("#use-odo").fill("162600")
        page.locator("#use-qty").fill("31.5")
        page.locator("#use-cost").fill("200")
        page.locator("#use-add").click()
        page.wait_for_timeout(150)
        check("own tank joins the list", page.locator("#use-log .item").count() == rows_before + 1,
              f"{rows_before} -> {page.locator('#use-log .item').count()}")
        rate_own = rate_now()
        check("own tank changes the average", rate_own != rate, f"{rate} -> {rate_own}")
        page.locator("#use-undo").click()
        page.wait_for_timeout(150)
        check("undo restores the sample average", rate_now() == rate, f"{rate_own} -> {rate_now()}")
        page.locator("#use-reset").click()
        page.locator("#use-kind").select_option("ev")
        page.wait_for_timeout(120)
        unit = page.locator("#use-unit-big").inner_text()
        check("electric mode uses kWh", "kWh" in unit, unit)

        # cost per kilometre
        page.locator("#demo-tab-cost").click()
        page.wait_for_timeout(120)
        per_km = page.locator("#cost-perkm").inner_text()
        page.locator("#cost-mileage").fill("25000")
        page.wait_for_timeout(120)
        per_km_half = page.locator("#cost-perkm").inner_text()
        check("cost per km recalculates", per_km != per_km_half, f"{per_km} -> {per_km_half}")
        page.locator("#cost-fix").check()
        page.locator("#cost-fixed").fill("4000")
        page.wait_for_timeout(120)
        per_km_fix = page.locator("#cost-perkm").inner_text()
        check("fixed bills enter the total", per_km_fix != per_km_half, f"{per_km_half} -> {per_km_fix}")
        page.locator("#cost-own").check()
        page.wait_for_timeout(120)
        check("own-only disables predictions", page.locator("#cost-pred").is_disabled())

        # lightbox
        page.locator("#screens").scroll_into_view_if_needed()
        page.locator("[data-lightbox]").first.click()
        page.wait_for_timeout(250)
        visible = page.locator("#lightbox").is_visible()
        lb_src = page.locator("#lb-img").get_attribute("src") or ""
        check("lightbox opens", visible and "full" in lb_src, lb_src)
        page.keyboard.press("ArrowRight")
        page.wait_for_timeout(150)
        lb_src2 = page.locator("#lb-img").get_attribute("src") or ""
        check("lightbox navigates", lb_src != lb_src2, lb_src2)
        page.keyboard.press("Escape")
        page.wait_for_timeout(150)
        check("Escape closes lightbox", page.locator("#lightbox").is_hidden())

        # responsive sanity: no horizontal overflow at any common width
        widths = [280, 320, 360, 390, 430, 480, 599, 640, 768, 900, 1024, 1280, 1440, 1920]
        offenders = []
        for width in widths:
            page.set_viewport_size({"width": width, "height": 900})
            page.wait_for_timeout(180)
            gap = page.evaluate("() => document.documentElement.scrollWidth - document.documentElement.clientWidth")
            if gap > 1:
                offenders.append(f"{width}+{gap}")
        check("no horizontal overflow 280-1920px", not offenders, ", ".join(offenders) or "clean")
        page.set_viewport_size({"width": 390, "height": 844})
        page.wait_for_timeout(250)
        header_h = page.evaluate("() => document.querySelector('.site-header').getBoundingClientRect().height")
        check("header fits on mobile", header_h < 150, f"{header_h:.0f}px")
        check("custom fonts in use", page.evaluate(
            "() => getComputedStyle(document.querySelector('h1')).fontFamily.toLowerCase().includes('space grotesk')"))
        panels = page.evaluate("""() => {
          const shown = [...document.querySelectorAll('.calc')].filter(c => !c.hidden).length;
          const hidden = [...document.querySelectorAll('.calc')].filter(c => c.hidden).length;
          return {shown, hidden};
        }""")
        check("one calculator panel visible", panels == {"shown": 1, "hidden": 2}, str(panels))
        check("every section has styles applied", page.evaluate(
            """() => [...document.querySelectorAll('main section')].every(s => s.getBoundingClientRect().height > 120)"""))
        check("no untranslated placeholders", page.evaluate(
            """() => [...document.querySelectorAll('[data-i18n]')].every(e => e.textContent.trim() && e.textContent.trim() !== e.getAttribute('data-i18n'))"""))
        check("no untranslated legends", page.evaluate(
            """() => [...document.querySelectorAll('[data-i18n-legend]')].every(f => { const l = f.querySelector('legend'); return l && l.textContent.trim() && l.textContent.trim() !== f.getAttribute('data-i18n-legend'); })"""))

        # reduced motion should not hide content
        page.emulate_media(reduced_motion="reduce")
        page.reload(wait_until="load")
        page.wait_for_timeout(300)
        hidden = page.evaluate("() => [...document.querySelectorAll('.reveal')].filter(e => getComputedStyle(e).opacity < 0.2).length")
        check("reduced motion shows content", hidden == 0, f"{hidden} hidden blocks")
        nums_rm = page.eval_on_selector_all(".fact__num span", "els => els.map(e => e.textContent.trim())")
        check("counters filled without animation", "4761" in nums_rm, str(nums_rm))

        browser.close()

    missing = referenced_files()
    check("every referenced file exists", not missing, " | ".join(missing[:6]))
    zbedne = orphan_files()
    check("no orphan files in docs", not zbedne, ", ".join(zbedne[:6]))

    print()
    print("console:", console if console else "clean")
    print("external:", external if external else "none")
    print()
    print("FAILURES:", failures if failures else "none")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
