# Kroje pisma strony

Strona korzysta z trzech krojów na własnym hostingu, bez żadnego CDN. Każdy plik `.woff2`
to podzbiór oryginalnego kroju Google Fonts: usunięte zostały glify spoza zestawu znaków,
których strona faktycznie używa (łacina zachodnia, polskie diakrytyki, podstawowa typografia).

| Krój | Autor | Licencja | Źródło |
|---|---|---|---|
| Inter | Rasmus Andersson | SIL Open Font License 1.1 | https://rsms.me/inter/ |
| Space Grotesk | Florian Karsten | SIL Open Font License 1.1 | https://fonts.google.com/specimen/Space+Grotesk |
| JetBrains Mono | Philipp Nurullin, Nikolay Avtonomov | SIL Open Font License 1.1 | https://www.jetbrains.com/mono/ |

Wszystkie trzy kroje są publikowane na licencji SIL OFL 1.1, która zezwala na wgrywanie,
modyfikację (w tym podzbieranie znaków) i redystrybucję plików fontu w dokumentach
i stronach. Pełne teksty licencji leżą obok w tym katalogu. Podzbieranie wykonał
`tools/landing/make-assets.py`.
