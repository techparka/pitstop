"""Mierzy warstwę graficzną strony startowej i szuka przepełnienia.

Sekcje strony składają się z diagramów: cykl terminu, drzewo plików w telefonie,
siatka rzeczy, których w kodzie nie ma, plakietki licencji i pól formularza.
Tego nie sprawdzisz zdaniem w słowniku, więc narzędzie liczy wszystko w
przeglądarce: ile kroków ma diagram, czy na szerokim ekranie stoi w jednym
rzędzie, a na wąskim jeden pod drugim, ile kolumn ma siatka, czy drzewo ma
wcięcia i pismo o stałej szerokości znaków, czy trzy lokalne kroje się
załadowały i czy nic nie wypycha dokumentu za okno od 280 do 1920 px.

Zwraca 1, gdy któryś warunek nie trzyma, więc nadaje się do bramki przed
wgraniem na GitHub Pages.

Run: python tools/landing/layout.py
"""
from __future__ import annotations

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from browser import launch, served  # narzedzia z tego katalogu
from playwright.sync_api import sync_playwright

SZEROKOSCI = (280, 320, 360, 390, 430, 768, 1024, 1280, 1600, 1920)
BLADY: list[str] = []


def check(nazwa: str, dobrze: bool, opis: str = "") -> None:
    print(("PASS " if dobrze else "FAIL ") + nazwa + ((" | " + opis) if opis else ""))
    if not dobrze:
        BLADY.append(nazwa)


def main() -> int:
    with served() as base, sync_playwright() as pw:
        browser = launch(pw)
        page = browser.new_page(viewport={"width": 1280, "height": 900})
        page.goto(base, wait_until="load")
        page.wait_for_timeout(600)

        cykl = page.evaluate("""() => {
            const kroki = [...document.querySelectorAll('#features .flow__step')];
            return {kroki: kroki.length,
                    rzad: new Set(kroki.map((k) => Math.round(k.getBoundingClientRect().top))).size,
                    strzalki: document.querySelectorAll('#features .flow__arrow').length};
        }""")
        check("diagram cyklu terminu ma trzy kroki i dwie strzałki",
              cykl["kroki"] == 3 and cykl["strzalki"] == 2, str(cykl))
        check("kroki diagramu stoją w jednym rzędzie na 1280 px", cykl["rzad"] == 1, str(cykl["rzad"]))

        bento = page.evaluate("""() => {
            const karty = [...document.querySelectorAll('#features article')];
            const rzedy = new Map();
            karty.forEach((k) => {
                const y = Math.round(k.getBoundingClientRect().top);
                rzedy.set(y, (rzedy.get(y) || 0) + 1);
            });
            return {karty: karty.length, naRzedzie: [...new Set(rzedy.values())]};
        }""")
        check("bento ma co najmniej dwanaście kart", bento["karty"] >= 12, str(bento))
        check("bento układa karty po dwie w rzędzie", 2 in bento["naRzedzie"], str(bento))

        drzewo = page.evaluate("""() => {
            const d = document.querySelector('#data .tree');
            const brak = document.querySelector('#data .nogrid');
            return {gal: d ? d.querySelectorAll('ul').length : 0,
                    wciagi: d ? [...new Set([...d.querySelectorAll('ul')].map((u) => getComputedStyle(u).paddingLeft))] : [],
                    pismo: d ? getComputedStyle(d.querySelector('.mono')).fontFamily.split(',')[0] : '',
                    pola: brak ? brak.children.length : 0,
                    kol: brak ? getComputedStyle(brak).gridTemplateColumns.split(' ').length : 0};
        }""")
        check("drzewo plików ma trzy zagnieżdżone listy z wcięciem",
              drzewo["gal"] >= 3 and drzewo["wciagi"] and drzewo["wciagi"][0] != "0px", str(drzewo))
        check("nazwy plików idą pismem o stałej szerokości znaków", "Mono" in drzewo["pismo"], drzewo["pismo"])
        check("siatka «czego nie ma» ma osiem pól w wielu kolumnach",
              drzewo["pola"] == 8 and drzewo["kol"] >= 2, str(drzewo))

        reszta = page.evaluate("""() => ({
            licencja: document.querySelectorAll('#tech .minis li').length,
            kroki: document.querySelectorAll('#start .steps > li').length,
            plakietki: document.querySelectorAll('#start .steps .minis li').length,
        })""")
        check("licencja ma pięć plakietek", reszta["licencja"] == 5, str(reszta))
        check("start ma trzy kroki z plakietkami pól",
              reszta["kroki"] == 3 and reszta["plakietki"] >= 9, str(reszta))

        kroje = page.evaluate("""async () => {
            await document.fonts.ready;
            return {ladowane: [...new Set([...document.fonts].filter((f) => f.status === 'loaded').map((f) => f.family))],
                    naglowek: getComputedStyle(document.querySelector('h1')).fontFamily.split(',')[0]};
        }""")
        check("załadowane są trzy lokalne kroje", len(kroje["ladowane"]) == 3, str(kroje))
        check("nagłówek idzie Space Groteskiem", "Space Grotesk" in kroje["naglowek"], kroje["naglowek"])

        for szerokosc in SZEROKOSCI:
            page.set_viewport_size({"width": szerokosc, "height": 900})
            page.wait_for_timeout(250)
            wynik = page.evaluate("""() => ({
                dokument: document.documentElement.scrollWidth,
                okno: document.documentElement.clientWidth,
                rzedy: new Set([...document.querySelectorAll('#features .flow__step')]
                    .map((k) => Math.round(k.getBoundingClientRect().top))).size,
            })""")
            check(f"dokument nie przelewa się na {szerokosc} px",
                  wynik["dokument"] <= wynik["okno"], f"dokument {wynik['dokument']} px, okno {wynik['okno']} px")
            if szerokosc <= 430:
                check(f"diagram cyklu układa się w stos na {szerokosc} px", wynik["rzedy"] == 3, str(wynik["rzedy"]))

        browser.close()

    print("\nFAILURES: " + (", ".join(BLADY) if BLADY else "none"))
    return 1 if BLADY else 0


if __name__ == "__main__":
    sys.exit(main())
