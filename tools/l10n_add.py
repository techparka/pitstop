#!/usr/bin/env python3
"""Dodaje wpisy do plików ARB PitStopu.

Użycie:
    python tools/l10n_add.py pliki_lub_entries.json [...]

Plik wejściowy to obiekt: klucz -> { "pl": "...", "en": "..." } albo
klucz -> "tekst po polsku" (wtórnie uzupełnimy angielski). Wpisy istniejące o
tej samej wartości nie są nadpisywane, wpisy istniejące o innej wartości to błąd
— dzięki temu narzędzie można uruchamiać wielokrotnie i nie zgubić tłumaczeń.

Kolejność kluczów w ARB jest stabilna: istniejące zostają na swoim miejscu,
nowe są dopisywane na koniec. Klucze z prefiksem "_" (komentarze `@key`) są
dokładane obok swojego wpisu.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ARB = {
    "pl": Path("lib/l10n/app_pl.arb"),
    "en": Path("lib/l10n/app_en.arb"),
}


def load(path: Path) -> dict:
    if not path.exists():
        return {"@@locale": path.stem.split("_")[-1]}
    return json.loads(path.read_text(encoding="utf-8"))


def save(path: Path, data: dict) -> None:
    text = json.dumps(data, ensure_ascii=False, indent=2)
    path.write_text(text + "\n", encoding="utf-8", newline="\n")


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print(__doc__)
        return 2
    incoming: dict[str, dict[str, str]] = {}
    for name in argv[1:]:
        payload = json.loads(Path(name).read_text(encoding="utf-8"))
        for key, value in payload.items():
            if key.startswith("@"):
                continue
            if isinstance(value, str):
                value = {"pl": value}
            if key in incoming and incoming[key].get("pl") != value.get("pl"):
                raise SystemExit(f"{name}: sprzeczny wpis dla klucza {key}")
            merged = incoming.setdefault(key, {})
            merged.update(value)

    added = {lang: [] for lang in ARB}
    for lang, path in ARB.items():
        data = load(path)
        for key, value in incoming.items():
            text = value.get(lang)
            if text is None:
                continue
            if key in data:
                if data[key] != text and lang == "pl":
                    raise SystemExit(
                        f"{path}: klucz {key} już istnieje z inną treścią:\n"
                        f"  stary: {data[key]}\n  nowy: {text}"
                    )
                continue
            data[key] = text
            added[lang].append(key)
            description = value.get("desc") or value.get("@desc")
            if lang == "pl" and description:
                data[f"@{key}"] = {"description": description}
        # przesuwa "@@locale" na początek, reszta zachowuje kolejność wstawiania
        locale = data.pop("@@locale", ARB[lang].stem.split("_")[-1])
        save(path, {"@@locale": locale, **data})

    for lang, keys in added.items():
        print(f"{ARB[lang]}: nowych {len(keys)}")
        for key in keys:
            print(f"  + {key}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
