# Narzędzia strony startowej

Strona stoi w `docs/` (index.html, styles.css, app.js, assets/, screenshots/,
og-cover.png) i ma działać bez żadnego CDN: fonty, zrzuty i skrypty idą z tej
samej strony, bez analityki i bez plików cookie.

## Kolejność pracy

| krok | polecenie | co robi |
| --- | --- | --- |
| 1 | `python tools/landing/make-assets.py` | zrzuty z `screenshots-demo/` do webp, logo i favicony, podzbiory krojów do `docs/assets/fonts/`, `fonts.css`, teksty licencji |
| 2 | `python tools/landing/make-assets.py og` | `docs/og-cover.png` (1200x630) z lokalnych krojów i zrzutu 2.0 |
| 3 | edycja `docs/index.html`, `docs/app.js`, `docs/styles.css` | treść i kalkulatory |
| 4 | `python tools/landing/check-keys.py` | porównuje klucze `data-i18n` w HTML-u ze słownikami PL i EN; mówi, czego brakuje i które wpisy już nic nie wyświetla |
| 5 | `python tools/landing/sync-html-copy.py` | przepisuje bazowy (polski) tekst elementów `[data-i18n]` ze słownika PL i sprawdza, czy PL i EN mają te same klucze |
| 6 | `python tools/landing/sync-jsonld.py` | przepisuje FAQPage w JSON-LD tak, by zgadzał się z widocznym FAQ |
| 7 | `python tools/landing/qa.py` | 54 sprawdzenia na żywo: konsola, brak żądań na zewnątrz, motyw, język, trzy kalkulatory, lightbox, brak przelewania się od 280 do 1920 px |
| 8 | `python tools/landing/layout.py` | 26 sprawdzeń warstwy graficznej: diagram cyklu, bento, drzewo plików, siatka «czego nie ma», plakietki, kroje, przepełnienie |
| 9 | `python tools/landing/assets.py` | każdy wskazany w HTML-u plik istnieje w `docs/` i nic w `docs/` nie leży bez powodu (wyjątek: `logo.png` dla `README.md` repozytorium) |
| 10 | `python tools/landing/prose.py [en]` | wypisuje tekst strony do przeczytania jak człowiek |

Kolejność 5 -> 6 -> 7 ma znaczenie: słownik PL w `app.js` jest źródłem prawdy
dla tekstu, bazowy HTML tylko go powtarza, a JSON-LD powtarza widoczne FAQ.

## Skracanie tekstu

Tekst skrócony w `index.html` wraca do poprzedniej długości przy najbliższym
`sync-html-copy.py`, bo narzędzie przepisuje HTML ze słownika. Najpierw zmniejsz
wpis w `PL`, potem daj jego skrót w `EN`, potem uruchom `sync-html-copy.py`.
`check-keys.py` przed resztą mówi, czy któryś klucz nie został po usuniętej
sekcji; takie wpisy trzeba wyrzucić z obu słowników.

## Co trzeba wiedzieć przed zmianą

- Kalkulatory w `app.js` odwzorowują `lib/domain/calculations.dart` i
  `lib/features/garage/garage_shell.dart` (ścieżki lokalnego drzewa 2.0; w
  opublikowanym 1.0 ich nie ma, więc strona ich nie wymienia). Jak zmienia się
  wzór w aplikacji, zmień go też tutaj i sprawdź `qa.py`, który porównuje liczby.
- `app.js` wstawia tłumaczenia przez `innerHTML` do elementów `[data-i18n]`.
  Dlatego żaden element z `id` (np. `#rem-now`) nie może leżeć *wewnątrz*
  tłumaczonego węzła, bo znika przy zmianie języka. `qa.py` pilnuje tego przez
  «translation keeps every id».
- Uchwyt `?qa` w `app.js` (window.__pitstop) istnieje tylko dla narzędzi stąd.
- Liczby na stronie muszą być zmierzone: `flutter analyze`, liczba plików i
  linii w `lib/`, tabela w `lib/data/database/tables.dart`, uprawnienia w
  `android/app/src/main/AndroidManifest.xml`, kontrast liczony ze zrzutu.
- W repozytorium `techparka/pitstop` jest wersja 1.0.0, a zrzuty pochodzą z
  lokalnego builda 2.0.0+2. Strona mówi o tym wprost; nie mieszaj tych wersji w
  jednym zdaniu.
- Testy `flutter test` nie nadają się na liczbę dla strony: pakiet bywa
  czerwony, więc podawaj raczej ekrany, tabele i linie kodu.
- Od 2026-11-16 sekcje częściej rysują niż piszą: diagram cyklu terminu
  (`.flow`), drzewo plików w telefonie (`.tree`), siatka ośmiu rzeczy, których w
  kodzie nie ma (`.nogrid`), plakietki przy licencji i polach formularza
  (`.minis`). Zdania, które kiedyś to opisywały, znikły, więc `qa.py` i
  `prose.py` ich nie widzą, a liczby z diagramów pilnuje `layout.py`.
- Słowo «plik» w drzewie to `<span class="mono">`, bez `data-i18n`: nazwy
  `car_service.db` i `pitstop-*.zip` zostają takie same w obu językach.

## Publikacja

Strona jest serwowana z `docs/` w `techparka/pitstop` przez GitHub Pages
(<https://techparka.github.io/pitstop/>). Katalog `docs/` w tym projekcie to
kopia przed wgraniem; po każdej zmianie 4-10 skopiuj go do klona repozytorium i
wgraj. Runbook z pełną procedurą: `knowledge/runbooks/landing-page-github-pages.md`.
