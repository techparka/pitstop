/* PitStop - strona startowa. Bez CDN, bez pakietów, bez śledzenia.
   Motyw i język zapamiętane w localStorage, animowany licznik przy przewijaniu,
   trzy kalkulatory logicznie zgodne z lib/domain/calculations.dart,
   podgląd zrzutów ekranu i podświetlenie aktualnej sekcji w menu.
*/
(() => {
  'use strict';

  const $ = (sel, root) => (root || document).querySelector(sel);
  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));
  const nf = (min, max) => new Intl.NumberFormat('pl-PL', { minimumFractionDigits: min, maximumFractionDigits: max === undefined ? min : max });
  const n2 = nf(2), n1 = nf(1), n0 = nf(0, 0);
  const money = (v) => (Number.isFinite(v) ? n2.format(v) + ' zł' : '-');
  const kmFmt = (v) => (Number.isFinite(v) ? n0.format(v) + ' km' : '-');
  const num = (id) => { const e = document.getElementById(id); const v = parseFloat(String(e.value).replace(',', '.')); return Number.isFinite(v) ? v : 0; };
  const int = (id) => { const e = document.getElementById(id); const v = parseInt(String(e.value).replace(/\D/g, ''), 10); return Number.isFinite(v) ? v : 0; };
  const val = (id) => document.getElementById(id).value;
  const firstNumber = (txt) => { const m = String(txt).match(/[\d\s ]+/); if (!m) return 0; const v = parseInt(m[0].replace(/\D/g, ''), 10); return Number.isFinite(v) ? v : 0; };
  const shortDate = (d, lc) => new Intl.DateTimeFormat(lc === 'en' ? 'en-GB' : 'pl-PL', { day: 'numeric', month: 'short', year: 'numeric' }).format(d).replace(/\./g, '');
  const clamp = (v, lo, hi) => Math.min(Math.max(v, lo), hi);

  /* 1. MOTYW I JĘZYK - muszą zadziałać przed resztą */
  const root = document.documentElement;
  const mqDark = window.matchMedia('(prefers-color-scheme: dark)');
  const themeBtn = $('[data-theme-toggle]');
  const THEME_KEY = 'pitstop.theme';
  const LANG_KEY = 'pitstop.lang';
  const stored = (k) => { try { return localStorage.getItem(k); } catch (e) { return null; } };
  const save = (k, v) => { try { localStorage.setItem(k, v); } catch (e) { /* przeglądarka blokuje localStorage */ } };

  function lang() { return stored(LANG_KEY) === 'en' ? 'en' : 'pl'; }

  /* 2. SŁOWNIKI. Uzupełnienie po angielsku musi być kompletne,
     inaczej przeglądarka pokaże polskie zdanie w zdaniach zmiennych. */
  const PL = {
    'a11y.skip': 'Przejdź do treści',
    'a11y.lang': 'Język strony',
    'a11y.themeAuto': 'Motyw: automatyczny',
    'a11y.themeLight': 'Motyw: jasny',
    'a11y.themeDark': 'Motyw: ciemny',
    'nav.features': 'Funkcje', 'nav.demo': 'Kalkulatory', 'nav.screens': 'Ekran',
    'nav.data': 'Dane', 'nav.tech': 'Kod', 'nav.start': 'Start',

    'hero.overline': 'Historia serwisowa bez arkuszy w chmurze',
    'hero.h1': 'Termin, rachunek i przebieg w jednym miejscu',
    'hero.lead1': 'PitStop trzyma historię serwisową auta w telefonie: terminy z datą albo przebiegiem, rachunki z warsztatu, tankowania i kopie z sumą kontrolną.',
    'hero.lead2': 'Kod na licencji MIT, zero uprawnień do internetu, zero kont.',
    'hero.cta1': 'Pobierz APK', 'hero.cta2': 'Kod na GitHubie',
    'hero.statusA': 'W repozytorium wersja 1.0.0.',
    'hero.statusB': 'Zrzuty ekranu zrobiono w lokalnym buildzie 2.0.0+2, jeszcze nieopublikowanym.',
    'hero.statusLink': 'Czym różni się 2.0',
    'hero.phones.note': 'Zrzut z builda 2.0.0+2 (schemat bazy 3). Ten sam ekran w 1.0 wygląda prościej i nie ma w nim księgi wydatków.',
    'hero.phones.alt1': 'Historia serwisowa w ciemnym motywie',
    'hero.phones.alt2': 'Pulpit aplikacji w jasnym motywie',

    'fact1.label': 'tabel w bazie wersji 2.0', 'fact1.src': 'tables.dart',
'fact2.label': 'linii Dart w wersji 1.0', 'fact2.src': '23 pliki .dart w repozytorium',
    'fact3.label': 'uprawnień do sieci w manifeście', 'fact3.src': 'AndroidManifest.xml',
    'fact4.label': 'licencja, bez opłat i konta', 'fact4.src': 'LICENSE',

    'features.label': 'Co jest w środku',
    'features.h2': 'Funkcje, których używa się co tydzień',
    'features.lead': 'Każda funkcja ma swój ekran i swoje miejsce w bazie. Przy każdej stoi plakietka wersji: 1.0 jest w repozytorium, 2.0 czeka na publikację.',
    'f1.h': 'Auto z numerem VIN, napędem i notatką',
    'f1.p': 'Nazwa, marka, model, rocznik, rejestracja, numer VIN, zdjęcie i aktualny stan licznika. W 2.0 dochodzi napęd (benzyna, diesel, benzyna plus LPG, hybryda, hybryda plug-in, elektryk), data zakupu i notatki techniczne.',
    'f2.h': 'Serwis z fakturą',
    'f2.p': 'Tytuł, data, przebieg, kwota w złotówkach, warsztat i kategoria: wymiana oleju, wymiana opon, przegląd, inne. Do wpisu doklejasz zdjęcie z aparatu albo PDF faktury.',
    'f3.h': 'Części i robocizna osobno',
    'f3.p': 'Rozbicie jest opcjonalne: rozwijasz pole „Części i robocizna” i dopisujesz pozycje z rodzajem (część albo robocizna), nazwą i kwotą. Gdy jest choć jedna pozycja, kwota serwisu bierze się z ich sumy.',
    'f4.h': 'Termin w cyklu, który idzie dalej',
    'f4.p': 'Termin ustawiasz datą, przebiegiem albo jednym i drugim. Gdy oznaczysz go jako wykonany, aplikacja pyta, czy dopisać wpis do historii serwisów, a potem sama tworzy następny termin: datę liczy od dzisiaj, przebieg od ostatniego odczytu licznika.',
    'f4.li1': 'Powtarzanie co X miesięcy i co X kilometrów, w tym samym terminie.',
    'f4.li2': 'Przegapiony termin jest czerwony, bliski bursztynowy: 30 dni albo 1000 km.',
    'f4.li3': 'Szablony: badanie techniczne, OC, AC, wymiana oleju, zmiana opon.',
    'f5.h': 'Powiadomienia na 7 dni, 1 dzień i w dniu terminu',
    'f5.p': 'Alarmy ustawia AlarmManager, budzą telefon rano i po tapnięciu otwierają edycję terminu. Harmonogram wraca po restarcie telefonu, po aktualizacji aplikacji i po zmianie zegara albo strefy czasowej.',
    'f6.h': 'Tankowania liczone dla każdego paliwa osobno',
    'f6.p': 'Benzyna, diesel i LPG mają własną średnią. Wpis z zaznaczonym pełnym bakiem jest punktem pomiarowym, a tankowanie oznaczone jako pominięte przerywa liczenie i zaczyna odcinek od nowa. Ładowanie idzie w kilowatogodzinach.',
    'f7.h': 'Historia wszystkich wpisów w jednym strumieniu',
    'f7.p': 'Serwisy i wpisy z księgi (tankowanie, ładowanie, wydatek, odczyt licznika) wychodzą z jednego zapytania i są ułożone datą. Wpisu szukasz po tytule, opisie i nazwie warsztatu.',
    'f7.li1': 'Filtry: kategoria, auto, zakres dat.',
    'f7.li2': 'Wydatek ma kategorie, także własne: parking, myjnia, opłaty drogowe, ubezpieczenie.',
    'f7.li3': 'Formularz ostrzega, gdy wpis o takim tytule, kwocie i dacie już istnieje.',
    'f8.h': 'Analityka na CustomPainterze',
    'f8.p': 'W 1.0: suma kosztów, średnia na serwis i suma na typ serwisu. W 2.0 dochodzi wybór zakresu (ten miesiąc, ten rok, własny okres, cała historia), słupki miesiąc po miesiącu, wydatki według kategorii, koszt kilometra i zużycie paliwa. Wykresy rysuje CustomPainter, bez pakietu zewnętrznego.',
    'f9.h': 'Kopia ZIP z sumą kontrolną',
    'f9.p': 'Archiwum ma plik data.json z ośmioma tabelami, folder media i manifest.json z sumą SHA-256 każdego pliku. Przed przywróceniem aplikacja sprawdza integralność kopii i najpierw robi kopię stanu, który teraz masz w telefonie.',
    'f10.h': 'CSV w obie strony i raport PDF',
    'f10.p': 'Import dopasowuje kolumny z pliku do dwunastu pól i pokazuje podgląd z numerami wierszy. Błędny wiersz zostaje odrzucony, reszta wchodzi, a powtórne wgranie tego samego pliku nie dodaje wpisów drugi raz. Raport historii to PDF z A4 generowany na telefonie.',
    'f11.h': 'Szkic formularza nie ginie',
    'f11.p': 'Niedokończony serwis, tankowanie czy termin zapisują się razem ze zdjęciem. Otworzysz ten sam formularz za godzinę albo po restarcie aplikacji, zastajesz to, co wpisałeś.',
    'f12.h': 'Bez konta, bez reklam, bez internetu',
    'f12.p': 'Nie ma logowania, klienta chmury ani wskaźników analitycznych w kodzie. AndroidManifest nie pyta o zgodę INTERNET, więc aplikacja nie ma czym wysłać danych. Pyta za to o aparat, zdjęcia i start przy rozruchu telefonu.',
    'f12.li1': 'Eksport idzie przez systemowy wybór miejsca zapisu, bez serwera po drodze.',
    'f12.li2': 'Motyw jasny, ciemny albo systemowy, ustawiany w aplikacji.',
    'f12.li3': 'Licencja MIT: pobierasz, zmieniasz, wydajesz własną wersję.',

    'demo.label': 'Sprawdź na swoich liczbach',
    'demo.h2': 'Trzy kalkulatory z logiką aplikacji',
    'demo.lead': 'Ta strona działa offline, ale policzy tak jak PitStop: progi terminów, zużycie paliwa od pełnego baku i koszt kilometra. Formuły są przepisem z plików lib/domain/calculations.dart i lib/features/garage/garage_shell.dart.',
    'demo.note': 'To kalkulator na potrzeby strony, nie formularz z aplikacji. Dane wpisane tutaj zostają tylko w tej karcie przeglądarki.',
    'demo.tab.rem': 'Terminy', 'demo.tab.use': 'Zużycie', 'demo.tab.cost': 'Koszt kilometra',
    'demo.srcRem': 'Termin liczony datą i przebiegiem, jak na pulpicie aplikacji.',
    'demo.srcUse': 'Dwa pełne tankowania wystarczą; im więcej, tym średnia stabilniejsza.',
    'demo.rem.count': (n) => n === 1 ? '1 termin w telefonie' : (n < 20 ? n + ' terminy w telefonie' : n + ' terminów w telefonie'),

    'rem.car': 'Auto', 'rem.car1': 'Yaris 1.0 benzyna', 'rem.car2': 'e-Up! elektryczny',
    'rem.type': 'Rodzaj terminu',
    'rem.t1': 'Przegląd okresowy', 'rem.t2': 'Wymiana oleju', 'rem.t3': 'Badanie techniczne',
    'rem.t4': 'Ubezpieczenie OC', 'rem.t5': 'Wymiana opon',
    'rem.legend': 'Termin', 'rem.legendnow': 'Stan w telefonie',
    'rem.bydate': 'Data', 'rem.bymile': 'Przebieg',
    'rem.nowkm': 'Ostatni odczyt licznika',
    'rem.now': 'Dzisiaj:', 
    'rem.btn.setNow': 'Ustaw dziś', 'rem.btn.add': 'Dodaj termin', 'rem.btn.reset': 'Przykład',
    'rem.hint': 'Aplikacja dopisuje kolejny termin, gdy zaznaczysz, że termin jest wykonany. Tutaj policzy tylko progi.',
    'rem.foot': 'Czerwone: minęło. Bursztynowe: 30 dni albo 1000 km.',
    'rem.log.empty': 'Brak terminów w telefonie. Dodaj pierwszy.',
    'rem.none': 'Terminy w telefonie',
    'rem.done': 'wykonany',
    'rem.due.today': 'dzisiaj',
    'rem.overdue.day': 'wczoraj', 'rem.overdue.other': (n) => n + ' dni temu',
    'rem.days.one': 'jutro', 'rem.days.few': (n) => 'za ' + n + ' dni', 'rem.days.many': (n) => 'za ' + n + ' dni',
    'rem.km.left': (n) => n + ' km zostało', 'rem.km.after': (n) => n + ' km po terminie',
    'rem.cycle.months': (n) => 'co ' + n + ' mies.', 'rem.cycle.km': (n) => 'co ' + n + ' km', 'rem.cycle.none': 'bez powtarzania',
    'rem.alarm.none': 'bez alarmów w telefonie',
    'rem.alarm.date': 'alarm: 7 dni, 1 dzień, w dniu terminu',
    'rem.alarm.km': 'alarm: 1000 km przed terminem',
    'rem.alarm.both': 'alarm: datą i kilometrami',

    'use.kind': 'Rodzaj wpisu', 'use.fuel': 'Tankowanie (l / 100 km)', 'use.ev': 'Ładowanie (kWh / 100 km)',
    'use.fuelname': 'Paliwo', 'use.legend': 'Wpis z telefonu',
    'use.odo': 'Licznik przy tankowaniu', 'use.qty': 'Ile wlane albo władowane', 'use.costlabel': 'Kwota (opcja)',
    'use.full': 'Pełny bak albo pełne ładowanie', 'use.missed': 'Tankowanie pominięte',
    'use.hint': 'Pominięte tankowanie przerywa odcinek, tak jak w aplikacji. Kwota nie wchodzi do zużycia, tylko do kosztów.',
    'use.btn.add': 'Dodaj wpis', 'use.btn.undo': 'Cofnij', 'use.btn.reset': 'Przykład',
    'use.chips.dist': 'Odczytany dystans', 'use.chips.qty': 'Zużyte paliwo', 'use.chips.qtyEv': 'Zużycie prądu',
    'use.chips.last': 'Pomiar', 'use.chips.cost': 'Koszt trasy', 'use.chips.cost2': 'Koszt na 100',
    'use.foot': 'Aplikacja liczy dystans z odczytów licznika, a nie z przebytych dróg.',
    'use.title.fuel': (fuel) => 'Zużycie ' + fuel.toLowerCase(), 'use.title.ev': 'Zużycie prądu',
    'use.unit.fuel': 'l / 100 km', 'use.unit.ev': 'kWh / 100 km',
    'use.note.km': (n) => n + ' km odczytanego dystansu',
    'use.empty': 'Dwa pełne tankowania do pierwszego wyniku.',
    'use.entry': 'Tankowanie', 'use.entry.ev': 'Ładowanie',
    'use.flag.full': 'pełny', 'use.flag.soft': 'bez pełnego baku', 'use.flag.missed': 'pominięte tankowanie',
    'use.cost.per': (u) => 'koszt / ' + u,
    'use.from.date': (a, b) => a + ' - ' + b,
    'use.from.odo': (a, b) => a + ' - ' + b + ' km',
    'use.skipped.one': (n) => n + ' tankowanie pominięte na tym odcinku',
    'use.skipped.many': (n) => n + ' tankowań pominiętych na tym odcinku',
    'toast.use.added': 'Dodano wpis do listy.', 'toast.use.undo': 'Cofnięto ostatni wpis.',
    'toast.rem.added': 'Termin dodany do listy.',

    'cost.legend': 'Koszt kilometra', 'cost.mileage': 'Przejechane kilometry', 'cost.groups': 'Grupy kosztów',
    'cost.own': 'Tylko moje wpisy z telefonu', 'cost.pred': 'Koszty przewidywane', 'cost.fix': 'Rachunki stałe',
    'cost.predhint': 'Koszty przewidywane i rachunki stałe to pola z analityki w aplikacji. Tutaj podstawiasz własne kwoty.',
    'cost.fixed': 'Rachunki stałe razem (zł)',
    'cost.table.caption': 'Koszty w grupach i ich wpływ na koszt kilometra',
    'cost.col.name': 'Grupa', 'cost.col.sum': 'Suma', 'cost.col.perkm': 'zł / km',
    'cost.row.fuel': 'Paliwo i energia', 'cost.row.serv': 'Serwisy', 'cost.row.parts': 'Części zamienne',
    'cost.row.other': 'Pozostałe wpisy', 'cost.row.pred': 'Koszty przewidywane', 'cost.row.fixed': 'Rachunki stałe',
    'cost.total': 'Koszt kilometra', 'cost.none': 'brak danych',
    'cost.foot': 'W analityce koszt kilometra bierze kilometry z dwóch odczytów licznika, a kwoty sumą z groszy. Wpis ten sam kosztuje raz, nawet jeśli dopiszesz go do serwisu i do wydatków.',
    'sums.all': 'Wszystkie wpisy', 'sums.own': 'Tylko moje wpisy', 'sums.pred': 'Z prognozami',

    'screens.label': 'Ekran po ekranie',
    'screens.h2': 'Trzy zakładki i jeden ekran dodawania',
    'screens.lead': 'Dolna nawigacja ma Pulpit, Historię, Terminy i Garaż. Plusem obok niej dopisujesz auto albo wpis, zależnie od otwartej zakładki. Zrzuty kliknij, żeby zobaczyć pełny ekran.',
    'screens.hint': 'Przewiń listę w bok albo użyj strzałek w podglądzie. Zrzuty pochodzą z builda 2.0.0+2.',
    'shot.btn': 'Ekran', 'shot.zoom': 'powiększ',
    'lb.close': 'Zamknij podgląd', 'lb.prev': 'Poprzedni zrzut', 'lb.next': 'Następny zrzut',
    's1.c': 'Pulpit: na górze wydatki miesiąca',
    's1.p': 'Pod spodem licznik, najbliższe terminy z progami i ostatnie wpisy. W 1.0 ten ekran ma tylko licznik, sumę kosztów i listę trzech terminów.',
    's1.n': 'Pulpit', 's1.alt': 'Pulpit aplikacji: wydatki miesiąca, licznik i najbliższe terminy',
    's2.c': 'Historia z wyszukiwarką i filtrami',
    's2.p': 'Wpisy z księgi i serwisy w jednej liście, filtrowane kategoria, autem i datą. W 1.0 znajdziesz tu wyłącznie serwisy.',
    's2.n': 'Historia', 's2.alt': 'Historia serwisowa z wyszukiwarką i filtrami zakresu dat',
    's3.c': 'Terminy z progiem dni i kilometrów',
    's3.p': 'Aktywne terminy na górze, pod nimi zrobione, obok przycisk powiadomień. W 1.0 termin nie ma cyklu ani alarmów w telefonie.',
    's3.n': 'Terminy', 's3.alt': 'Lista terminów z progami dni i kilometrów',
    's4.n': 'Historia, ciemny motyw', 's4.alt': 'Historia serwisowa w ciemnym motywie',
    's5.n': 'Terminy, jasny motyw', 's5.alt': 'Lista terminów w jasnym motywie',

    'themes.label': 'Motyw',
    'themes.h2': 'Jasny, ciemny i ten systemowy',
    'themes.lead': 'Ten sam widok w dwóch wariantach, bez osobnych arkuszy stylów. Motyw ustawisz w aplikacji, a strona zapamięta twój wybór w tej przeglądarce.',
    'themes.dark': 'Ciemny', 'themes.light': 'Jasny',
    'themes.darkNote': 'Tło #11151C, karty #1D222C. Biały tekst ma 18:1 do tła, kolor wiodący 7:1, więc termin po terminie nadal da się przeczytać.',
    'themes.lightNote': 'Tło #F5F6F8, białe karty, kolor wiodący ściemniony do #BA410C, żeby trzymał 5:1. Ten sam zestaw styli, żadna osobna wersja ekranu.',
    'sw1': 'kolor wiodący', 'sw1r': 'przyciski, aktywna zakładka',
    'sw2': 'termin bliski', 'sw2r': '30 dni albo 1000 km',
    'sw3': 'po terminie', 'sw3r': 'przegapiony serwis',
    'sw4': 'granat tła', 'sw4r': 'tryb ciemny',
    'sw5': 'powierzchnia', 'sw5r': 'karty w trybie ciemnym',
    'sw6': 'tło jasne', 'sw6r': 'kontener aplikacji',

    'data.label': 'Dane i prywatność',
    'data.h2': 'Pliki leżą w telefonie, bez pośredników',
    'data.lead': 'Bazę SQLite tworzy Drift w katalogu aplikacji. Kopię robisz sam, plik CSV zapisujesz tam, gdzie wskażesz, a kopii na chmurze nie ma, bo aplikacja nie ma zgody na internet.',
    'data.privacy': 'Czego w kodzie nie ma', 'data.storage': 'Jak to leży',
    'l1.h': 'Formularz i walidacja',
    'l1.p': 'Kwota z dwoma miejscami po przecinku, data z kalendarza, licznik w kilometrach. Błędne pole dostaje komunikat, a niedokończony formularz zostaje jako szkic.',
    'l2.h': 'Interfejs słucha bazy',
    'l2.p': 'Riverpod trzyma listy, filtry i wybrane auto. Ekrany słuchają strumieni z bazy, więc zapisany wpis wchodzi na listę bez ręcznego odświeżania.',
    'l3.h': 'Repozytorium i transakcje',
    'l3.p': 'Warstwa repozytorium składa serwisy z księgą w jednym zapytaniu i pilnuje spójności: zaznaczenie terminu jako wykonanego to transakcja z dopisaniem wpisu i nowego terminu.',
    'l4.h': 'Plik w telefonie',
    'l4.p': 'car_service.db w katalogu aplikacji, zdjęcia i PDF-y obok. Baza ma włączone klucze obce i trzy indeksy pod listy, a dostęp idzie przez izolatę, więc interfejs nie staje.',
    'n1b': 'konto', 'n1': 'Nie ma rejestracji, logowania ani profilu w chmurze. Pierwsze uruchomienie prosi o dodanie auta.',
    'n2b': 'chmury', 'n2': 'Brak klienta chmury w zależnościach. Kopia ZIP leży w katalogu aplikacji, a co z nią zrobisz, zależy od ciebie.',
    'n3b': 'reklam i analityki', 'n3': 'Zero pakietów reklamowych i wskaźników. Nie ma czego blokować w tej aplikacji.',
    'n4b': 'internetu', 'n4': 'W manifeście nie ma uprawnienia INTERNET. Wyliczenia, kopie i PDF-y dzieją się na telefonie.',
    'n5b': 'lokalizacji', 'n5': 'Brak zgody na GPS. Wpis o warsztacie bierze nazwę z pola, które sam wpiszesz.',
    'n6b': 'OBD i Bluetootha', 'n6': 'Aplikacja nie dzwoni do auta. Stan licznika przepisujesz z deski rozdzielczej.',
    'd1b': 'tabele', 'd1': 'Auto, serwisy, załączniki, pozycje serwisu, terminy, księga, ustawienia, własne kategorie.',
    'd2b': 'kwoty', 'd2': 'Grosze w kolumnach cost_cents i amount_cents. Wpis na 37,72 zł to zapis 3772.',
    'd3b': 'schemat', 'd3': 'Wersja 3. Migracja z jedynki zakłada tabelę terminów, z dwójki dokłada księgę, pozycje serwisu, ustawienia i kwoty w groszach.',
    'd4b': 'termin', 'd4': 'Ten sam wiersz potrafi mieć datę i przebieg, a cykl dopisuje następny wiersz z ustawionym powtarzaniem.',
    'd5b': 'szkic', 'd5': 'Szkic formularza i dołączone do niego pliki lądują w tabeli ustawień, dopóki nie zapiszesz albo nie porzucisz wpisu.',
    'd6b': 'kopia', 'd6': 'data.json z ośmioma tabelami, folder media i manifest z sumą SHA-256 na każdy plik w archiwum.',

    'tech.label': 'Kod i liczby',
    'tech.h2': 'Flutter, Dart, osiem tabel i zero plików konfiguracyjnych na serwerze',
    'tech.lead': 'Repozytorium <code>techparka/pitstop</code> trzyma kod aplikacji i tej strony w katalogu <code>docs/</code>. Poniżej liczby zmierzone 15 listopada 2026 roku, na wersjach z tej strony.',
    't1l': 'ekranów w buildzie 2.0', 't1s': '10 plików, w 1.0 było 7',
    't2l': 'zgłoszeń analityzatora', 't2s': '<code>flutter analyze</code>, 33 s',
    't3l': 'linii Dart w wersji 1.0', 't3s': '23 pliki w <code>lib/</code>',
    't4l': 'tabel w schemacie wersji 3', 't4s': '<code>lib/data/database/tables.dart</code>',
    'tech.build': 'Od repozytorium do APK',
    'tech.buildhint': 'Od Fluttera 3.16 wzwyż, z dodatkami Androida. Czwarty krok generuje kod Drifta do plików <code>.g.dart</code>, bo nie trzymamy ich w repozytorium.',
    'tech.buildnote': 'Build nie potrzebuje kluczy, serwera ani zmiennych środowiskowych. Wersja aplikacji jest w <code>pubspec.yaml</code>, motyw w <code>lib/core/theme/app_theme.dart</code>.',
    'tech.stack': 'Czego użyto',
    'tech.stacknote': 'Bez pakietu do wykresów: słupki i linie rysuje <code>CustomPainter</code>. Bez pakietu PDF: raport powstaje w kodzie Androida na <code>PdfDocument</code>.',
    'lic.h': 'Licencja MIT, bez drobnego druku',
    'lic.p': 'Możesz używać, kopiować, zmieniać, łączyć z własnym kodem, dystrybuować, sprzedawać kopie i zmieniać licencję. Zostaw tylko notkę z licencją i nazwiskiem autora w kopiach, które rozdajesz. Kod jest dany bez żadnych gwarancji, więc za zgubiony termin przeglądowy odpowiadasz sam.',
    'lic.b1': 'Pełna treść licencji', 'lic.b2': 'Wydania z plikiem APK',

    'start.label': 'Pierwsze odpalenie',
    'start.h2': 'Trzy ekrany do pierwszej wpisanej sumy',
    'start.lead': 'Aplikacja startuje na liście aut. Dalej dodajesz auto, potem serwis z ostatniej faktury, a na koniec termin na następną wymianę oleju.',
    'st1.h': 'Auto i licznik',
    'st1.p': 'Nazwa, marka, model, rocznik i rejestracja wystarczą, żeby ruszyć. Licznik możesz przepisać z deski rozdzielczej, a numer VIN, napęd i datę zakupu dopisać później.',
    'st2.h': 'Ostatni serwis',
    'st2.p': 'Data, kilometry, kwota i warsztat. Zdjęcie faktury dołączysz z aparatu albo z galerii, a PDF wrzucisz w tym samym miejscu, co zdjęcie.',
    'st3.h': 'Termin, który wróci sam',
    'st3.p': 'Daj terminowi datę, kilometry albo jedno i drugie, ustaw powtarzanie, a rano dostaniesz znak, że czas. Wykonany termin sam wystawia następny.',
    'note1b': 'Nie ma tego w Google Play.',
    'note1': 'APK pobierasz z Releazów na GitHubie i zezwalasz telefonowi na instalację z tego jednego źródła. Na służbowym telefonie sprawdź przed instalacją rozmiar i sumę pliku z opisu release.',
    'note2b': 'Android 5.0 albo nowszy.',
    'note2': 'Build bierze API 21 w górę i jest sprawdzony na telefonie z Androidem 14. Na tablecie i w przeglądarce nie działa: aplikacja jest na jeden telefon.',
    'note3b': 'Aktualizacja z 1.0 do 2.0.',
    'note3': 'Baza ma numery wersji, więc migracja z dwójki do trójki idzie sama, bez utraty danych. Własne buildy nadpiszą się tylko wtedy, gdy podpis i pakiet <code>com.example.car_service</code> zostaną te same.',
    'faq.h': 'Częste pytania',
    'q1': 'Czy PitStop jest darmowy?',
    'a1': 'Tak. Kod jest na licencji MIT, więc możesz go pobrać, zmienić i wydać własną wersję. Nie ma konta, reklam, abonamentu ani zakupów w aplikacji.',
    'q2': 'Czy aplikacja działa bez internetu?',
    'a2': 'Tak, i to dosłownie: w pliku AndroidManifest.xml nie ma uprawnienia INTERNET, więc aplikacja nie ma czym wysłać danych. W trybie samolotowym działa wszystko, łącznie z PDF-em raportu.',
    'q3': 'Gdzie są zapisane dane?',
    'a3': 'W pliku car_service.db w katalogu aplikacji, razem ze zdjęciami i dokumentami. Kopie to archiwum ZIP z plikiem data.json i folderem media, w katalogu backups obok. Kopie nie są szyfrowane, więc obchodź się z nimi jak z telefonem bez blokady.',
    'q4': 'Czy dane trafią do chmury albo na serwer?',
    'a4': 'Nie. Nie ma konta, klienta chmury ani wskaźników analitycznych. Zrzut z telefonu przenosisz sam, na przykład przez eksport CSV albo plik kopii.',
    'q5': 'Czym wersja z repozytorium różni się od wersji ze zrzutów?',
    'a5': 'W repozytorium jest wersja 1.0.0: historia serwisowa, proste terminy, statystyki i baza na Drift, schemat numer 2. Zrzuty zrobiono w lokalnym buildzie 2.0.0+2 ze schematem numer 3, który dokłada księgę tankowań i wydatków, terminy w cyklu z powiadomieniami, kopie ZIP z SHA-256, import CSV z mapowaniem, raport PDF i rozbicie serwisu na części oraz robociznę. Dwójki jeszcze nie ma na GitHubie.',
    'q6': 'Dlaczego mam instalować APK z GitHuba?',
    'a6': 'Bo aplikacja nie jest w Google Play. W wydaniach na GitHubie leży plik APK, a telefon pozwala go zainstalować, gdy zgodzisz się na to jedno źródło. Przed wrzuceniem na własny telefon sprawdzisz rozmiar i sumę kontrolną z opisu wydania.',
    'q7': 'Po co aplikacji aparat i zdjęcia?',
    'a7': 'Żeby dołączyć zdjęcie licznika, tabliczki znamionowej albo faktury do wpisu. Zdjęcia i PDF-y zostają w pamięci aplikacji, a zgody na internet nie ma, więc nic z nich nie wychodzi z telefonu.',
    'q8': 'W jakim języku jest aplikacja?',
    'a8': 'Tylko po polsku. Nazwy pól i komunikaty są wpisane w kod, a daty oraz kwoty formatuje intl z ustawieniem pl_PL, więc drugi język wymagałby warstwy opisów, której teraz nie ma. Ta strona jest dwujęzyczna, aplikacja na razie nie.',
    'cta.overline': 'Odpalisz w kwadrans',
    'cta.h2': 'Pobierz APK, wrzuć trzy ostatnie rachunki',
    'cta.p': 'Bez konta, bez internetu i bez plików cookie, również na tej stronie. Po instalacji zostaje lista aut; reszta zależy od tego, co sam wpiszesz.',
    'cta.b1': 'Pobierz APK', 'cta.b2': 'Kod na GitHubie', 'cta.b3': 'Zgłoś błąd',
    'footer.about': 'Historia serwisowa auta w telefonie, bez konta i bez internetu. Kod na licencji MIT.',
    'footer.l1': 'Repozytorium', 'footer.l2': 'Wydania z APK', 'footer.l3': 'Zgłoś błąd',
    'footer.h2': 'Licencja',
    'footer.lic': 'Kod na MIT, bez żadnych gwarancji. Fonty: Inter, Space Grotesk i JetBrains Mono na licencji Open Font License.',
    'footer.made': 'Strona postawiona w katalogu <code>docs/</code> repozytorium z kodem, na GitHub Pages. Fonty i zrzuty są serwowane stąd, bez zewnętrznych serwerów i bez plików cookie.'
  };

  const EN = {
    'a11y.skip': 'Skip to content',
    'a11y.lang': 'Page language',
    'a11y.themeAuto': 'Theme: auto',
    'a11y.themeLight': 'Theme: light',
    'a11y.themeDark': 'Theme: dark',
    'nav.features': 'Features', 'nav.demo': 'Calculators', 'nav.screens': 'Screens',
    'nav.data': 'Data', 'nav.tech': 'Code', 'nav.start': 'Start',

    'hero.overline': 'Service history without shared spreadsheets',
    'hero.h1': 'Due dates, receipts and odometer in one place',
    'hero.lead1': 'PitStop keeps your car service history on the phone: due dates by calendar or mileage, workshop bills, refuelling logs and backups with checksums.',
    'hero.lead2': 'MIT licensed code, zero network permissions, zero accounts.',
    'hero.cta1': 'Get the APK', 'hero.cta2': 'Source on GitHub',
    'hero.statusA': 'The repository ships version 1.0.0.',
    'hero.statusB': 'Screenshots come from a local 2.0.0+2 build that is not published yet.',
    'hero.statusLink': 'What changes in 2.0',
    'hero.phones.note': 'Shot from the 2.0.0+2 build (schema 3). The same screen in 1.0 looks simpler and has no expense ledger.',
    'hero.phones.alt1': 'Service history in the dark theme',
    'hero.phones.alt2': 'Dashboard screen in the light theme',

    'fact1.label': 'tables in the 2.0 database', 'fact1.src': 'tables.dart',
'fact2.label': 'lines of Dart in 1.0', 'fact2.src': '23 .dart files in the repo',
    'fact3.label': 'network permissions in the manifest', 'fact3.src': 'AndroidManifest.xml',
    'fact4.label': 'licence, no fees, no account', 'fact4.src': 'LICENSE',

    'features.label': 'What is inside',
    'features.h2': 'Features you touch every week',
    'features.lead': 'Every feature has its own screen and its own place in the database. Each card is tagged with the version it belongs to: 1.0 is in the repo, 2.0 is still a local build.',
    'f1.h': 'A car with a VIN, a drive type and notes',
    'f1.p': 'Name, make, model, year, registration, a 17 character VIN, a photo and the current odometer. Version 2.0 adds the drive type (petrol, diesel, petrol plus LPG, hybrid, plug-in hybrid, electric), purchase date and technical notes.',
    'f2.h': 'A service entry with the invoice',
    'f2.p': 'Title, date, mileage, amount in zloty, workshop and category: oil change, tyre change, inspection, other. Attach a camera photo or the invoice PDF.',
    'f3.h': 'Parts and labour split apart',
    'f3.p': 'The split is optional: an expandable "Części i robocizna" section takes items with a type (part or labour), a name and a cost. Once there is at least one item, the service amount comes from their sum.',
    'f4.h': 'A reminder cycle that rolls on',
    'f4.p': 'Set a reminder by date, by mileage or by both. When you mark it done, the app asks whether to add a service entry and then creates the next reminder: the date counts from today, the mileage from the last odometer reading.',
    'f4.li1': 'Repeat every X months and every X kilometres in the same reminder.',
    'f4.li2': 'Overdue turns red, upcoming turns amber: 30 days or 1000 km.',
    'f4.li3': 'Templates: inspection, third party liability, comprehensive, oil change, tyre change.',
    'f5.h': 'Alerts 7 days, 1 day and on the day',
    'f5.p': 'AlarmManager sets the alarms, wakes the phone in the morning and opens the reminder editor on tap. The schedule survives a phone reboot, an app update and a clock or timezone change.',
    'f6.h': 'Consumption per fuel, not per car',
    'f6.p': 'Petrol, diesel and LPG get their own average. A full tank entry is the measurement point, a skipped fill-up breaks the leg and starts it again. Charging is logged in kilowatt hours.',
    'f7.h': 'Every entry in one history stream',
    'f7.p': 'Services and ledger entries (refuelling, charging, expenses, odometer reads) come out of a single query, sorted by date. Search by title, note or workshop name.',
    'f7.li1': 'Filters: category, car, date range.',
    'f7.li2': 'Expenses have categories, including your own: parking, car wash, tolls, insurance.',
    'f7.li3': 'The form warns when an entry with the same title, amount and date already exists.',
    'f8.h': 'Charts drawn by CustomPainter',
    'f8.p': 'In 1.0: total cost, average per service and totals per service type. In 2.0 a range picker (this month, this year, custom period, whole history), month by month bars, spending by category, cost per kilometre and fuel consumption. CustomPainter draws the charts, no chart package.',
    'f9.h': 'A ZIP backup with checksums',
    'f9.p': 'The archive holds data.json with eight tables, a media folder and manifest.json with a SHA-256 hash per file. Before restoring, the app checks the archive and first backs up the state you have on the phone right now.',
    'f10.h': 'CSV both ways and a PDF report',
    'f10.p': 'Import maps the columns of your file onto twelve fields and shows a preview with row numbers. A broken row is skipped, the rest go in, and loading the same file twice does not duplicate entries. The history report is an A4 PDF generated on the phone.',
    'f11.h': 'A half written form survives',
    'f11.p': 'An unfinished service, refuelling or reminder is stored together with its photo. Open the same form in an hour or after an app restart and your text is still there.',
    'f12.h': 'No account, no ads, no internet',
    'f12.p': 'No login, no cloud client, no analytics in the code. AndroidManifest never asks for the INTERNET permission, so the app has no way to send data. It does ask for the camera, photos and boot completion.',
    'f12.li1': 'Exports go through the system save dialog, no server in between.',
    'f12.li2': 'Light, dark or system theme, picked in the app.',
    'f12.li3': 'MIT licence: download it, change it, ship your own build.',

    'demo.label': 'Try it with your own numbers',
    'demo.h2': 'Three calculators with the app logic',
    'demo.lead': 'This page runs offline but it computes like PitStop: reminder thresholds, consumption measured from a full tank and cost per kilometre. The formulas are copied from lib/domain/calculations.dart and lib/features/garage/garage_shell.dart.',
    'demo.note': 'This is a calculator for the page, not the form from the app. Numbers you type here stay in this browser tab.',
    'demo.tab.rem': 'Reminders', 'demo.tab.use': 'Consumption', 'demo.tab.cost': 'Cost per km',
    'demo.srcRem': 'A reminder counted by date and by mileage, like on the dashboard.',
    'demo.srcUse': 'Two full tanks are enough; the more you add, the steadier the average.',
    'demo.rem.count': (n) => n === 1 ? '1 reminder on the phone' : n + ' reminders on the phone',

    'rem.car': 'Car', 'rem.car1': 'Yaris 1.0 petrol', 'rem.car2': 'e-Up! electric',
    'rem.type': 'Reminder type',
    'rem.t1': 'Periodic inspection', 'rem.t2': 'Oil change', 'rem.t3': 'Technical inspection',
    'rem.t4': 'Liability insurance', 'rem.t5': 'Tyre change',
    'rem.legend': 'Due date', 'rem.legendnow': 'State on the phone',
    'rem.bydate': 'Date', 'rem.bymile': 'Mileage',
    'rem.nowkm': 'Last odometer reading',
    'rem.now': 'Today:',
    'rem.btn.setNow': 'Set today', 'rem.btn.add': 'Add reminder', 'rem.btn.reset': 'Example',
    'rem.hint': 'The app appends the next reminder when you mark one as done. Here it only computes the thresholds.',
    'rem.foot': 'Red: already gone. Amber: 30 days or 1000 km.',
    'rem.log.empty': 'No reminders on the phone. Add the first one.',
    'rem.none': 'Reminders on the phone',
    'rem.done': 'done',
    'rem.due.today': 'today',
    'rem.overdue.day': 'yesterday', 'rem.overdue.other': (n) => n + ' days ago',
    'rem.days.one': 'tomorrow', 'rem.days.few': (n) => 'in ' + n + ' days', 'rem.days.many': (n) => 'in ' + n + ' days',
    'rem.km.left': (n) => n + ' km left', 'rem.km.after': (n) => n + ' km over due',
    'rem.cycle.months': (n) => 'every ' + n + ' months', 'rem.cycle.km': (n) => 'every ' + n + ' km', 'rem.cycle.none': 'no repeat',
    'rem.alarm.none': 'no alarms on the phone',
    'rem.alarm.date': 'alarms: 7 days, 1 day, on the day',
    'rem.alarm.km': 'alarm: 1000 km before due',
    'rem.alarm.both': 'alarms: by date and by mileage',

    'use.kind': 'Entry type', 'use.fuel': 'Refuelling (l / 100 km)', 'use.ev': 'Charging (kWh / 100 km)',
    'use.fuelname': 'Fuel', 'use.legend': 'Entry from the phone',
    'use.odo': 'Odometer at the pump', 'use.qty': 'Amount pumped or charged', 'use.costlabel': 'Amount (optional)',
    'use.full': 'Full tank or full charge', 'use.missed': 'Skipped fill-up',
    'use.hint': 'A skipped fill-up breaks the leg, exactly like in the app. The amount does not enter consumption, only costs.',
    'use.btn.add': 'Add entry', 'use.btn.undo': 'Undo', 'use.btn.reset': 'Example',
    'use.chips.dist': 'Read distance', 'use.chips.qty': 'Fuel used', 'use.chips.qtyEv': 'Energy used',
    'use.chips.last': 'Measurement', 'use.chips.cost': 'Trip cost', 'use.chips.cost2': 'Cost per 100',
    'use.foot': 'The app reads distance from odometer values, not from the road you drove.',
    'use.title.fuel': (fuel) => fuel + ' consumption', 'use.title.ev': 'Energy consumption',
    'use.unit.fuel': 'l / 100 km', 'use.unit.ev': 'kWh / 100 km',
    'use.note.km': (n) => n + ' km of read distance',
    'use.empty': 'Two full tanks to get the first result.',
    'use.entry': 'Refuelling', 'use.entry.ev': 'Charging',
    'use.flag.full': 'full', 'use.flag.soft': 'not full', 'use.flag.missed': 'skipped',
    'use.cost.per': (u) => 'cost / ' + u,
    'use.from.date': (a, b) => a + ' - ' + b,
    'use.from.odo': (a, b) => a + ' - ' + b + ' km',
    'use.skipped.one': (n) => n + ' skipped fill-up on this leg',
    'use.skipped.many': (n) => n + ' skipped fill-ups on this leg',
    'toast.use.added': 'Entry added to the list.', 'toast.use.undo': 'Last entry removed.',
    'toast.rem.added': 'Reminder added to the list.',

    'cost.legend': 'Cost per kilometre', 'cost.mileage': 'Kilometres driven', 'cost.groups': 'Cost groups',
    'cost.own': 'Only my entries from the phone', 'cost.pred': 'Predicted costs', 'cost.fix': 'Fixed bills',
    'cost.predhint': 'Predicted costs and fixed bills are fields from the analytics screen. Here you type your own amounts.',
    'cost.fixed': 'Fixed bills total (PLN)',
    'cost.table.caption': 'Cost groups and their share of the cost per kilometre',
    'cost.col.name': 'Group', 'cost.col.sum': 'Total', 'cost.col.perkm': 'PLN / km',
    'cost.row.fuel': 'Fuel and energy', 'cost.row.serv': 'Services', 'cost.row.parts': 'Spare parts',
    'cost.row.other': 'Other entries', 'cost.row.pred': 'Predicted costs', 'cost.row.fixed': 'Fixed bills',
    'cost.total': 'Cost per kilometre', 'cost.none': 'no data',
    'cost.foot': 'In analytics the cost per kilometre takes kilometres from two odometer readings and sums amounts in gross. The same entry is counted once, even if you add it to a service and to expenses.',
    'sums.all': 'All entries', 'sums.own': 'Only my entries', 'sums.pred': 'With forecasts',

    'screens.label': 'Screen by screen',
    'screens.h2': 'Three tabs and one add screen',
    'screens.lead': 'The bottom bar has Dashboard, History, Reminders and Garage. The plus button beside it adds a car or an entry, depending on the open tab. Click a screenshot to see the full screen.',
    'screens.hint': 'Scroll the list sideways or use the arrows in the viewer. Screenshots come from the 2.0.0+2 build.',
    'shot.btn': 'Screen', 'shot.zoom': 'zoom in',
    'lb.close': 'Close the preview', 'lb.prev': 'Previous screenshot', 'lb.next': 'Next screenshot',
    's1.c': 'Dashboard: month costs on top',
    's1.p': 'Below there is the odometer, upcoming reminders with thresholds and the last entries. In 1.0 this screen only shows the odometer, a cost total and three reminders.',
    's1.n': 'Dashboard', 's1.alt': 'Dashboard screen: month costs, odometer and upcoming reminders',
    's2.c': 'History with search and filters',
    's2.p': 'Ledger entries and services in one list, filtered by category, car and date. In 1.0 you only find services here.',
    's2.n': 'History', 's2.alt': 'Service history with a search box and a date range filter',
    's3.c': 'Reminders with day and mileage thresholds',
    's3.p': 'Active reminders on top, done ones below, a notifications button next to them. In 1.0 a reminder has no cycle and no alarms.',
    's3.n': 'Reminders', 's3.alt': 'Reminder list with day and mileage thresholds',
    's4.n': 'History, dark theme', 's4.alt': 'Service history in the dark theme',
    's5.n': 'Reminders, light theme', 's5.alt': 'Reminder list in the light theme',
    'themes.label': 'Theme',
    'themes.h2': 'Light, dark and the system one',
    'themes.lead': 'The same view in two variants, without separate stylesheets. You pick the theme in the app, this page remembers your choice in this browser.',
    'themes.dark': 'Dark', 'themes.light': 'Light',
    'themes.darkNote': 'Background #11151C, cards #1D222C. White text measures 18:1 against the background and the accent 7:1, so an overdue reminder is still readable.',
    'themes.lightNote': 'Background #F5F6F8, white cards, the accent darkened to #BA410C so it holds 5:1. One stylesheet, no second version of the screen.',
    'sw1': 'accent', 'sw1r': 'buttons, active tab',
    'sw2': 'upcoming', 'sw2r': '30 days or 1000 km',
    'sw3': 'overdue', 'sw3r': 'missed service',
    'sw4': 'background navy', 'sw4r': 'dark mode',
    'sw5': 'surface', 'sw5r': 'cards in dark mode',
    'sw6': 'light background', 'sw6r': 'app container',

    'data.label': 'Data and privacy',
    'data.h2': 'Files sit on the phone, no middlemen',
    'data.lead': 'Drift creates the SQLite database in the app folder. You make the backup yourself and save the CSV wherever you point it. There is no cloud copy, because the app has no internet permission.',
    'data.privacy': 'What the code does not have', 'data.storage': 'How it is stored',
    'l1.h': 'Form and validation',
    'l1.p': 'Amounts with two decimals, dates from a calendar, odometer in kilometres. A wrong field gets a message and an unfinished form stays as a draft.',
    'l2.h': 'The interface listens to the database',
    'l2.p': 'Riverpod holds lists, filters and the selected car. Screens listen to database streams, so a saved entry lands on the list without a manual refresh.',
    'l3.h': 'Repository and transactions',
    'l3.p': 'The repository layer joins services with the ledger in one query and keeps things consistent: marking a reminder done is one transaction that also writes the service entry and the next reminder.',
    'l4.h': 'A file on the phone',
    'l4.p': 'car_service.db in the app folder, photos and PDFs next to it. The database turns on foreign keys and keeps three indexes for the lists, and access runs on an isolate so the UI does not stall.',
    'n1b': 'an account', 'n1': 'No sign-up, no login, no cloud profile. The first launch asks you to add a car.',
    'n2b': 'a cloud client', 'n2': 'No cloud client in the dependencies. The ZIP backup sits in the app folder and only you decide what happens to it.',
    'n3b': 'ads and analytics', 'n3': 'Zero ad packages and zero metrics. There is nothing to block in this app.',
    'n4b': 'the internet', 'n4': 'The manifest has no INTERNET permission. Calculations, backups and PDFs happen on the device.',
    'n5b': 'location', 'n5': 'No GPS permission. A workshop entry stores the name you type yourself.',
    'n6b': 'OBD or Bluetooth', 'n6': 'The app never calls the car. You copy the odometer from the dashboard.',
    'd1b': 'tables', 'd1': 'Vehicle, services, attachments, service items, reminders, ledger, settings, custom categories.',
    'd2b': 'amounts', 'd2': 'Gross stored in cost_cents and amount_cents. An entry of 37.72 PLN is written as 3772.',
    'd3b': 'schema', 'd3': 'Version 3. The migration from 1 creates the reminders table, from 2 it adds the ledger, service items, settings and amounts in gross.',
    'd4b': 'reminder', 'd4': 'One row can hold both a date and a mileage, and the cycle writes the next row with the repeat settings.',
    'd5b': 'draft', 'd5': 'A form draft and its attached files live in the settings table until you save or discard the entry.',
    'd6b': 'backup', 'd6': 'data.json with eight tables, a media folder and a manifest with a SHA-256 hash for every file in the archive.',

    'tech.label': 'Code and numbers',
    'tech.h2': 'Flutter, Dart, eight tables and no server side configuration',
    'tech.lead': 'The <code>techparka/pitstop</code> repository holds the app and this page in the <code>docs/</code> folder. The numbers below were measured on 15 November 2026, on the versions shown on this page.',
    't1l': 'screens in the 2.0 build', 't1s': '10 files, 1.0 had 7',
    't2l': 'analyser findings', 't2s': '<code>flutter analyze</code>, 33 s',
    't3l': 'lines of Dart in 1.0', 't3s': '23 files in <code>lib/</code>',
    't4l': 'tables in schema version 3', 't4s': '<code>lib/data/database/tables.dart</code>',
    'tech.build': 'From repository to APK',
    'tech.buildhint': 'Flutter 3.16 or newer, with the Android toolchain. Step four generates the Drift code into <code>.g.dart</code> files, which are not kept in the repository.',
    'tech.buildnote': 'The build needs no keys, no server and no environment variables. The app version is in <code>pubspec.yaml</code>, the theme in <code>lib/core/theme/app_theme.dart</code>.',
    'tech.stack': 'What is used',
    'tech.stacknote': 'No chart package: CustomPainter draws the bars and lines. No PDF package: the report is built in the Android layer with <code>PdfDocument</code>.',
    'lic.h': 'MIT licence, no small print',
    'lic.p': 'You may use, copy, modify, merge, distribute, sell copies of and sublicense the code. Just keep the licence notice and the author name in copies you hand out. The code comes with no warranty of any kind, so a missed inspection is on you.',
    'lic.b1': 'Full licence text', 'lic.b2': 'Releases with the APK',

    'start.label': 'First launch',
    'start.h2': 'Three screens to your first logged amount',
    'start.lead': 'The app opens on the car list. Then you add a car, then a service from the last invoice, and finally a reminder for the next oil change.',
    'st1.h': 'Car and odometer',
    'st1.p': 'Name, make, model, year and registration are enough to start. You can copy the odometer from the dashboard and add the VIN, powertrain and purchase date later.',
    'st2.h': 'The last service',
    'st2.p': 'Date, kilometres, amount and workshop. Attach the invoice photo from the camera or the gallery, and drop the PDF in the same place as the photo.',
    'st3.h': 'A reminder that comes back',
    'st3.p': 'Give the reminder a date, kilometres or both, set the repeat, and in the morning you get a sign that it is time. A done reminder raises the next one on its own.',
    'note1b': 'Not on Google Play.',
    'note1': 'You take the APK from Releases on GitHub and allow the phone to install from that one source. On a work phone, check the file size and checksum from the release notes first.',
    'note2b': 'Android 5.0 or newer.',
    'note2': 'The build targets API 21 and up and is tested on a phone with Android 14. It does not run on a tablet or in a browser: this app is for one phone.',
    'note3b': 'Updating from 1.0 to 2.0.',
    'note3': 'The database carries version numbers, so the migration from 2 to 3 runs on its own, without losing data. Your own builds overwrite each other only while the signing key and the <code>com.example.car_service</code> package stay the same.',
    'faq.h': 'Frequent questions',
    'q1': 'Is PitStop free?',
    'a1': 'Yes. The code is MIT licensed, so you can download it, change it and ship your own version. There is no account, no ads, no subscription and no in-app purchases.',
    'q2': 'Does the app work offline?',
    'a2': 'It does, literally: AndroidManifest.xml has no INTERNET permission, so the app cannot send data. In airplane mode everything still works, including the PDF report.',
    'q3': 'Where is the data stored?',
    'a3': 'In car_service.db inside the app folder, together with photos and documents. Backups are ZIP archives with data.json and a media folder, in the backups directory next to it. Backups are not encrypted, so keep a copy as carefully as the phone itself.',
    'q4': 'Will my data reach a cloud or a server?',
    'a4': 'No. There is no account, no cloud client and no analytics. You move an export yourself, for example through the CSV export or a backup file.',
    'q5': 'How does the repository version differ from the screenshots?',
    'a5': 'The repository has version 1.0.0: service history, simple reminders, statistics and a Drift database on schema 2. The screenshots come from a local 2.0.0+2 build on schema 3, which adds the fuel and expense ledger, reminders in a cycle with notifications, ZIP backups with SHA-256, CSV import with column mapping, a PDF report and the split of a service into parts and labour. Version 2.0 is not published on GitHub yet.',
    'q6': 'Why install an APK from GitHub?',
    'a6': 'Because the app is not on Google Play. The release page holds the APK file, and Android installs it once you allow that one source. Before putting it on your own phone you can check the file size and checksum listed in the release notes.',
    'q7': 'Why does the app want the camera and photos?',
    'a7': 'To attach a photo of the odometer, the plate or the invoice to an entry. Photos and PDFs stay in the app storage, and without an internet permission nothing leaves the phone.',
    'q8': 'Which languages does the app speak?',
    'a8': 'Polish only. Field names and messages are hardcoded in the Dart files, and intl formats dates and amounts with the pl_PL locale, so a second language needs a translation layer that is not there yet. This page is bilingual, the app is not.',
    'cta.overline': 'Up and running in fifteen minutes',
    'cta.h2': 'Get the APK, add your last three receipts',
    'cta.p': 'No account, no internet, no cookies, and this page follows the same rule. After installation you get the car list; the rest depends on what you type in.',
    'cta.b1': 'Get the APK', 'cta.b2': 'Source on GitHub', 'cta.b3': 'Report a bug',
    'footer.about': 'Car service history on your phone, without an account and without the internet. Code under the MIT licence.',
    'footer.l1': 'Repository', 'footer.l2': 'Releases with the APK', 'footer.l3': 'Report a bug',
    'footer.h2': 'Licence',
    'footer.lic': 'MIT code, no warranty at all. Fonts: Inter, Space Grotesk and JetBrains Mono under the Open Font Licence.',
    'footer.made': 'This page lives in the <code>docs/</code> folder of the code repository and is served by GitHub Pages. Fonts and screenshots are served from here, with no third party servers and no cookies.'
  };

  const DICT = { pl: PL, en: EN };
  const t = (key) => { const v = DICT[lang()][key]; return v === undefined ? (PL[key] !== undefined ? PL[key] : null) : v; };

  /* 3. TŁUMACZENIE, MOTYW, PRZEWIJANIE */
  function applyLang(lc) {
    root.lang = lc;
    $$('[data-i18n]').forEach((el) => {
      const v = t(el.dataset.i18n);
      if (typeof v === 'string') el.innerHTML = v;
    });
    $$('[data-i18n-legend]').forEach((el) => {
      const v = t(el.dataset.i18nLegend);
      const lg = el.querySelector('legend');
      if (lg && typeof v === 'string') lg.textContent = v;
    });
    $$('[data-i18n-label]').forEach((el) => {
      const v = t(el.dataset.i18nLabel);
      if (typeof v === 'string') el.setAttribute('aria-label', v);
    });
    $$('[data-lang]').forEach((b) => b.setAttribute('aria-pressed', String(b.dataset.lang === lc)));
    $$('[data-version]').forEach((el) => { if (el.dataset.version) el.textContent = el.dataset.version; });
    shots.forEach((btn) => { btn.setAttribute('aria-label', tf(btn.dataset.nameKey) + ', ' + tf('shot.zoom')); });
    const y = document.getElementById('year');
    if (y) y.textContent = String(new Date().getFullYear());
    applyTheme(themeBtn.dataset.mode || 'auto');
    renderAll();
  }
  $$('[data-lang]').forEach((b) => b.addEventListener('click', () => { save(LANG_KEY, b.dataset.lang); applyLang(lang()); }));

  const THEME_LABEL = { light: 'a11y.themeLight', dark: 'a11y.themeDark', auto: 'a11y.themeAuto' };
  function applyTheme(mode) {
    const computed = mode === 'auto' ? (mqDark.matches ? 'dark' : 'light') : mode;
    root.dataset.theme = computed;
    const label = t(THEME_LABEL[mode]);
    themeBtn.dataset.mode = mode;
    themeBtn.setAttribute('aria-label', label);
    themeBtn.title = label;
    const txt = $('.theme-toggle__txt');
    if (txt) txt.textContent = label;
    syncShots();
  }
  // Zrzuty w galerii idą za motywem strony: przy ciemnym tle widać ciemne ekrany aplikacji.
  function syncShots() {
    const dark = root.dataset.theme === 'dark';
    $$('img[data-dark]').forEach((img) => {
      const want = dark ? img.dataset.dark : img.dataset.light;
      if (want && img.getAttribute('src') !== want) img.src = want;
    });
    $$('[data-dark-full]').forEach((btn) => {
      btn.dataset.full = dark ? btn.dataset.darkFull : btn.dataset.lightFull;
    });
  }
  function cycleTheme() {
    const next = { light: 'dark', dark: 'auto', auto: 'light' }[themeBtn.dataset.mode || 'auto'];
    if (next === 'auto') { try { localStorage.removeItem(THEME_KEY); } catch (e) { void e; } } else save(THEME_KEY, next);
    applyTheme(next);
  }
  themeBtn.addEventListener('click', cycleTheme);
  mqDark.addEventListener('change', () => { if ((themeBtn.dataset.mode || 'auto') === 'auto') applyTheme('auto'); });

  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)');
  const revealables = $$('[data-count], .reveal');
  if (!('IntersectionObserver' in window) || reduced.matches) {
    revealables.forEach((el) => {
      el.classList.add('is-in');
      if (el.dataset.count !== undefined) el.textContent = Number(el.dataset.count).toLocaleString('pl-PL');
    });
  } else {
    const io = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (!e.isIntersecting) return;
        e.target.classList.add('is-in');
        if (e.target.dataset.count !== undefined) countTo(e.target);
        io.unobserve(e.target);
      });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.2 });
    revealables.forEach((el) => io.observe(el));
  }
  function countTo(el) {
    const target = Number(el.dataset.count);
    if (!Number.isFinite(target)) return;
    const dur = 620, t0 = performance.now();
    const step = (now) => {
      const p = clamp((now - t0) / dur, 0, 1);
      const eased = 1 - Math.pow(1 - p, 3);
      el.textContent = Math.round(target * eased).toLocaleString('pl-PL');
      if (p < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
  }

  const sections = $$('main section[id]');
  const navLinks = $$('.nav__links a');
  if ('IntersectionObserver' in window && sections.length && navLinks.length) {
    const spy = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (!e.isIntersecting) return;
        navLinks.forEach((a) => a.classList.toggle('is-current', a.getAttribute('href') === '#' + e.target.id));
      });
    }, { rootMargin: '-45% 0px -50% 0px' });
    sections.forEach((s) => spy.observe(s));
  }

  /* 4. PODPOWIEDŹ I PODGLĄD ZRZUTÓW */
  const live = document.createElement('p');
  live.className = 'toast';
  live.setAttribute('role', 'status');
  live.setAttribute('aria-live', 'polite');
  document.body.appendChild(live);
  let toastTimer;
  function toast(msg) {
    live.textContent = msg;
    live.classList.add('is-on');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => live.classList.remove('is-on'), 2800);
  }

  const lb = $('#lightbox');
  const lbImg = $('#lb-img');
  const lbName = $('#lb-name');
  const shots = $$('[data-lightbox]');
  let lbIndex = 0;
  function showShot(i) {
    if (!shots.length) return;
    lbIndex = (i + shots.length) % shots.length;
    const btn = shots[lbIndex];
    lbImg.src = btn.dataset.full;
    const nm = t(btn.dataset.nameKey);
    lbName.textContent = typeof nm === 'string' ? nm : '';
    const alt = t(btn.dataset.altKey);
    lbImg.alt = typeof alt === 'string' ? alt : '';
  }
  function openLb(i) {
    showShot(i);
    lb.hidden = false;
    document.body.style.overflow = 'hidden';
    $('#lb-close').focus();
  }
  function closeLb() {
    lb.hidden = true;
    document.body.style.overflow = '';
    if (shots[lbIndex]) shots[lbIndex].focus();
  }
  shots.forEach((btn, i) => btn.addEventListener('click', () => openLb(i)));
  $('#lb-close').addEventListener('click', closeLb);
  $('#lb-prev').addEventListener('click', () => showShot(lbIndex - 1));
  $('#lb-next').addEventListener('click', () => showShot(lbIndex + 1));
  lb.addEventListener('click', (e) => { if (e.target === lb) closeLb(); });
  window.addEventListener('keydown', (e) => {
    if (lb.hidden) return;
    if (e.key === 'Escape') closeLb();
    if (e.key === 'ArrowLeft') showShot(lbIndex - 1);
    if (e.key === 'ArrowRight') showShot(lbIndex + 1);
  });

  /* 5. ZAKŁADKI KALKULATORÓW */
  const tabs = $$('#demo-tabs [role=tab]');
  function selectTab(i, focus) {
    tabs.forEach((tab, j) => {
      const on = i === j;
      tab.setAttribute('aria-selected', String(on));
      tab.tabIndex = on ? 0 : -1;
      const panel = document.getElementById(tab.getAttribute('aria-controls'));
      if (panel) panel.hidden = !on;
      if (on && focus) tab.focus();
    });
  }
  tabs.forEach((tab, i) => {
    tab.addEventListener('click', () => selectTab(i));
    tab.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight' || e.key === 'ArrowLeft') {
        e.preventDefault();
        selectTab((i + (e.key === 'ArrowRight' ? 1 : tabs.length - 1)) % tabs.length, true);
      }
    });
  });
  selectTab(0);

  const chipRow = (k, v) => '<div class="chip"><span class="chip__k">' + k + '</span><span class="chip__v">' + v + '</span></div>';
  const itemRow = (state, title, value, subs, note, done) => {
    let html = '<li class="item' + (done ? ' is-done' : '') + '"' + (state ? ' data-state="' + state + '"' : '') + '>';
    html += '<span class="dot" aria-hidden="true"></span>';
    html += '<div class="item__row"><span class="item__title">' + title + '</span><span class="item__value">' + value + '</span></div>';
    if (subs && subs.length) html += '<div class="item__sub">' + subs.map((s) => '<span>' + s + '</span>').join('') + '</div>';
    if (note) html += '<p class="item__note">' + note + '</p>';
    return html + '</li>';
  };


  const tf = (key, ...args) => { const v = t(key); return typeof v === 'function' ? String(v(...args)) : String(v); };
  const pluralKey = (n, one, few, many) => {
    const a = Math.abs(n), v = a % 100;
    if (a === 1) return one;
    if (v >= 2 && v <= 9 && v % 10 >= 2 && v % 10 <= 4) return few;
    return many;
  };
  const dayMs = 864e5;
  const midnight = (d) => new Date(d.getFullYear(), d.getMonth(), d.getDate());
  const addDays = (d, n) => { const x = new Date(d); x.setDate(x.getDate() + n); return x; };
  const addMonths = (d, n) => {
    const day = d.getDate();
    const x = new Date(d.getFullYear(), d.getMonth() + n, 28);
    x.setDate(Math.min(day, new Date(x.getFullYear(), x.getMonth() + 1, 0).getDate()));
    return x;
  };
  const phraseDays = (n) => {
    if (n === 0) return tf('rem.due.today');
    if (n === 1) return tf('rem.days.one');
    if (n === -1) return tf('rem.overdue.day');
    if (n < 0) return tf(pluralKey(n, 'rem.overdue.other', 'rem.overdue.other', 'rem.overdue.other'), Math.abs(n));
    return tf(pluralKey(n, 'rem.days.one', 'rem.days.few', 'rem.days.many'), n);
  };

  /* 6. KALKULATOR TERMINÓW. Progi i etykiety przepisane z garage_shell.dart:
     0 = po terminie, 1 = bliski (30 dni albo 1000 km), 2 = spokojnie. */
  const isoDay = (d) => [d.getFullYear(), String(d.getMonth() + 1).padStart(2, '0'), String(d.getDate()).padStart(2, '0')].join('-');
  const remDateEl = document.getElementById('rem-date');
  const remSeed = () => { remDateEl.value = isoDay(addDays(midnight(new Date()), 2)); };
  remSeed();

  const REM_CARS = {
    yaris: {
      todayKm: 161800,
      entries: [
        { type: 'Przegląd okresowy', dueInDays: 2, dueKmAhead: 700, everyMonths: 12, everyKm: 15000 },
        { type: 'Wymiana oleju', dueInDays: -24, dueKmAhead: -600, everyMonths: 12 },
        { type: 'Badanie techniczne', dueInDays: -380, done: true, everyMonths: 12 }
      ]
    },
    eup: {
      todayKm: 41250,
      entries: [
        { type: 'Przegląd okresowy', dueKmAhead: 900, everyKm: 20000 },
        { type: 'Ubezpieczenie OC', dueInDays: 45, everyMonths: 12 },
        { type: 'Wymiana opon', dueInDays: 200, everyMonths: 12, everyKm: 20000 }
      ]
    }
  };
  let remCustom = [];

  function remStateOf(r, today, nowKm) {
    const dayDiff = r.due ? Math.round((midnight(r.due) - today) / dayMs) : null;
    const kmLeft = (r.dueKm == null || !Number.isFinite(nowKm)) ? null : r.dueKm - nowKm;
    let state = 2;
    if ((dayDiff != null && dayDiff < 0) || (kmLeft != null && kmLeft <= 0)) state = 0;
    else if ((dayDiff != null && dayDiff <= 30) || (kmLeft != null && kmLeft <= 1000)) state = 1;
    const alarms = (r.due ? 1 : 0) + (r.dueKm != null ? 1 : 0);
    const alarm = alarms === 2 ? 'rem.alarm.both' : (alarms === 1 ? (r.due ? 'rem.alarm.date' : 'rem.alarm.km') : 'rem.alarm.none');
    return { dayDiff: dayDiff, kmLeft: kmLeft, state: state, alarm: alarm };
  }

  function renderRem() {
    const lc = lang();
    const today = midnight(new Date());
    document.getElementById('rem-now').textContent = shortDate(today, lc);
    const car = REM_CARS[document.getElementById('rem-car').value] || REM_CARS.yaris;
    const nowKm = int('rem-nowkm') || car.todayKm;
    const rows = remCustom.concat(car.entries).map((r) => {
      const due = r.due || (r.dueInDays != null ? addDays(today, r.dueInDays) : null);
      const dueKm = r.dueKm != null ? r.dueKm : (r.dueKmAhead != null ? nowKm + r.dueKmAhead : null);
      const model = { due: due, dueKm: dueKm };
      const s = remStateOf(model, today, nowKm);
      const subs = [];
      if (due) subs.push(shortDate(due, lc));
      if (dueKm != null) subs.push(n0.format(dueKm) + ' (' + (s.kmLeft < 0 ? tf('rem.km.after', Math.abs(s.kmLeft)) : tf('rem.km.left', s.kmLeft)) + ')');
      const cycle = [r.everyMonths ? tf('rem.cycle.months', r.everyMonths) : null, r.everyKm ? tf('rem.cycle.km', r.everyKm) : null].filter(Boolean).join(' + ') || tf('rem.cycle.none');
      const value = r.done ? tf('rem.done') : (s.kmLeft != null && s.kmLeft <= 0 ? tf('rem.km.after', Math.abs(s.kmLeft)) : phraseDays(s.dayDiff));
      return itemRow(r.done ? '' : ['over', 'soon', 'calm'][s.state], r.type, value, subs, cycle + ' · ' + tf(s.alarm), r.done);
    });
    const total = remCustom.length + car.entries.length;
    const head = '<li class="item item--head"><span class="item__title">' + tf('rem.none') + '</span><span class="item__value">' + tf('demo.rem.count', total) + '</span></li>';
    document.getElementById('rem-log').innerHTML = total ? head + rows.join('') : itemRow('', tf('rem.log.empty'), '', [], '', false);
    const active = remCustom.concat(car.entries).filter((r) => !r.done).map((r) => remStateOf({ due: r.due || (r.dueInDays != null ? addDays(today, r.dueInDays) : null), dueKm: r.dueKm != null ? r.dueKm : (r.dueKmAhead != null ? nowKm + r.dueKmAhead : null) }, today, nowKm).alarm);
    const srcEl = document.getElementById('demo-src');
    if (srcEl) srcEl.textContent = active.indexOf('rem.alarm.both') >= 0 ? tf('rem.alarm.both') : (active.indexOf('rem.alarm.km') >= 0 ? tf('rem.alarm.km') : tf('demo.srcRem'));
  }

  function readRemForm() {
    const byDate = document.getElementById('rem-bydate').checked;
    const byMile = document.getElementById('rem-bymile').checked;
    const due = byDate && remDateEl.value ? new Date(remDateEl.value + 'T12:00:00') : null;
    const dueKm = byMile && document.getElementById('rem-duekm').value !== '' ? int('rem-duekm') : null;
    if (!due && dueKm == null) { toast(tf('rem.hint')); return false; }
    remCustom.push({ type: document.getElementById('rem-type').value, due: due, dueKm: dueKm });
    toast(tf('toast.rem.added'));
    return true;
  }
  document.getElementById('rem-add').addEventListener('click', () => { if (readRemForm()) renderRem(); });
  document.getElementById('rem-setnow').addEventListener('click', () => { remSeed(); renderRem(); });
  document.getElementById('rem-reset').addEventListener('click', () => { remCustom = []; remSeed(); renderRem(); });
  ['rem-car', 'rem-type', 'rem-date', 'rem-duekm', 'rem-nowkm'].forEach((id) => document.getElementById(id).addEventListener('input', renderRem));
  ['rem-bydate', 'rem-bymile'].forEach((id) => {
    const box = document.getElementById(id);
    const sync = () => {
      document.getElementById('rem-date').disabled = !document.getElementById('rem-bydate').checked;
      document.getElementById('rem-duekm').disabled = !document.getElementById('rem-bymile').checked;
    };
    box.addEventListener('change', () => { sync(); renderRem(); });
    box.addEventListener('change', sync);
    sync();
  });

  /* 7. KALKULATOR ZUŻYCIA. Logika zużycia przepisana z calculations.dart:
     dystans = bieżący licznik - licznik sprzed ostatniego pełnego tankowania,
     paliwo = suma od tego punktu, tankowanie pominięte zeruje odcinek. */
  const USE_SAMPLE = [
    { odo: 161370, qty: 28.5, cost: 178.9, full: true, missed: false, kind: 'fuel', date: new Date('2026-03-12T10:00:00') },
    { odo: 161800, qty: 30.6, cost: 191.3, full: true, missed: false, kind: 'fuel', date: new Date('2026-03-26T10:00:00') },
    { odo: 162183, qty: 28.9, cost: 181.2, full: true, missed: false, kind: 'fuel', date: new Date('2026-04-02T10:00:00') }
  ];
  const USE_SAMPLE_EV = [
    { odo: 40100, qty: 48.2, cost: 62.4, full: true, missed: false, kind: 'ev', date: new Date('2026-02-18T10:00:00') },
    { odo: 40480, qty: 21.6, cost: 28.1, full: true, missed: false, kind: 'ev', date: new Date('2026-03-04T10:00:00') }
  ];
  let useRows = USE_SAMPLE.slice();

  const unitBig = () => tf(val('use-kind') === 'ev' ? 'use.unit.ev' : 'use.unit.fuel');
  function computeUse(rows) {
    let prev = null, acc = null;
    for (const r of rows) {
      if (!prev && r.full && !r.missed) { prev = r; continue; }
      if (!prev) continue;
      if (!acc) acc = { start: prev, end: r, qty: 0, cost: 0, skipped: 0 };
      if (r.missed) { acc.skipped++; continue; }
      acc.qty += r.qty || 0;
      acc.cost += r.cost || 0;
      acc.end = r;
      if (r.full) break;
    }
    return acc || null;
  }
  function renderUse() {
    const lc = lang();
    const isEv = val('use-kind') === 'ev';
    document.getElementById('use-fuel').parentElement.hidden = isEv;
    document.getElementById('use-unit').textContent = isEv ? 'kWh' : 'l';
    document.getElementById('use-unit-big').textContent = unitBig();
    document.getElementById('use-title').textContent = isEv ? tf('use.title.ev') : tf('use.title.fuel', val('use-fuel'));
    const legs = useRows.map((r, i) => ({ r: r, i: i })).filter((o) => o.r.full && !o.r.missed);
    let best = null;
    for (let k = 1; k < legs.length; k++) best = computeUse(useRows.slice(legs[k - 1].i, legs[k].i + 1));
    const out = document.getElementById('use-log');
    if (!useRows.length) {
      document.getElementById('use-value').textContent = '-';
      document.getElementById('use-note').textContent = tf('use.empty');
      document.getElementById('use-chips').innerHTML = '';
      out.innerHTML = itemRow('', tf('use.empty'), '', [], '', false);
      return;
    }
    const rows = useRows.map((r, i) => {
      const flag = r.missed ? tf('use.flag.missed') : (r.full ? tf('use.flag.full') : tf('use.flag.soft'));
      const qty = (r.qty || 0).toLocaleString('pl-PL', { minimumFractionDigits: 1, maximumFractionDigits: 2 }) + (r.kind === 'ev' ? ' kWh' : ' l');
      return itemRow(r.missed ? 'over' : (r.full ? 'calm' : ''), r.kind === 'ev' ? tf('use.entry.ev') : tf('use.entry'), qty + ', ' + flag, [n0.format(r.odo) + ' km', r.cost ? money(r.cost) : ''], '', false);
    });
    out.innerHTML = rows.join('');
    if (!best) {
      document.getElementById('use-value').textContent = '-';
      document.getElementById('use-note').textContent = tf('use.empty');
      document.getElementById('use-chips').innerHTML = chipRow(tf('use.chips.last'), tf('use.empty'));
      return;
    }
    const dist = best.end.odo - best.start.odo;
    const rate = dist > 0 ? best.qty / dist * 100 : NaN;
    const unit = best.end.kind === 'ev' ? 'kWh' : 'l';
    document.getElementById('use-value').textContent = Number.isFinite(rate) ? n1.format(rate) : '-';
    document.getElementById('use-note').textContent = tf('use.note.km', n0.format(dist));
    const chips = [
      chipRow(tf('use.chips.dist'), n0.format(dist) + ' km'),
      chipRow(best.end.kind === 'ev' ? tf('use.chips.qtyEv') : tf('use.chips.qty'), best.qty.toLocaleString('pl-PL', { maximumFractionDigits: 1 }) + ' ' + unit)
    ];
    if (best.start.date || best.end.date) chips.push(chipRow(tf('use.chips.last'), tf('use.from.date', shortDate(best.start.date || new Date(), lc), shortDate(best.end.date || new Date(), lc))));
    else chips.push(chipRow(tf('use.chips.last'), tf('use.from.odo', n0.format(best.start.odo), n0.format(best.end.odo))));
    if (best.cost > 0 && best.qty > 0) {
      chips.push(chipRow(tf('use.chips.cost'), money(best.cost)));
      chips.push(chipRow(tf('use.chips.cost2'), money(best.cost / best.qty * 100) + ' / 100 ' + unit));
    }
    document.getElementById('use-chips').innerHTML = chips.join('');
    if (best.skipped) {
      document.getElementById('use-note').textContent += ' · ' + tf(pluralKey(best.skipped, 'use.skipped.one', 'use.skipped.one', 'use.skipped.many'), best.skipped);
    }
  }
  function readUseForm() {
    const kind = val('use-kind');
    const odo = int('use-odo');
    const qty = num('use-qty');
    if (!odo || !qty) { toast(tf('use.hint')); return false; }
    useRows.push({ odo: odo, qty: qty, cost: num('use-cost'), full: document.getElementById('use-full').checked, missed: document.getElementById('use-missed').checked, kind: kind, date: new Date() });
    useRows.sort((a, b) => a.odo - b.odo);
    toast(tf('toast.use.added'));
    return true;
  }
  document.getElementById('use-add').addEventListener('click', () => { if (readUseForm()) renderUse(); });
  document.getElementById('use-undo').addEventListener('click', () => { useRows.pop(); toast(tf('toast.use.undo')); renderUse(); });
  document.getElementById('use-reset').addEventListener('click', () => { useRows = (val('use-kind') === 'ev' ? USE_SAMPLE_EV : USE_SAMPLE).slice(); renderUse(); });
  document.getElementById('use-kind').addEventListener('change', () => {
    const isEv = val('use-kind') === 'ev';
    document.getElementById('use-missed').checked = false;
    document.getElementById('use-full').checked = true;
    useRows = (isEv ? USE_SAMPLE_EV : USE_SAMPLE).slice();
    renderUse();
  });
  ['use-odo', 'use-qty', 'use-cost'].forEach((id) => document.getElementById(id).addEventListener('input', renderUse));

  /* 8. KALKULATOR KOSZTU KILOMETRA. Kwoty grup liczone w groszach, kilometry
     z dwóch odczytów licznika, jak na ekranie analityki. */
  const COST_ROWS = {
    fuel: { own: 4680.40, pred: 900 },
    serv: { own: 2140.00, pred: 600 },
    parts: { own: 320.00, pred: 250 },
    other: { own: 615.30, pred: 180 }
  };
  const KEYS = ['fuel', 'serv', 'parts', 'other'];
  const box = (id) => document.getElementById(id).checked;
  function renderCost() {
    const km = Math.max(1, int('cost-mileage') || 1);
    const ownOn = box('cost-own'), predOn = box('cost-pred'), fixOn = box('cost-fix');
    const fixed = num('cost-fixed');
    const ownOnly = document.getElementById('cost-pred');
    ownOnly.disabled = ownOn;
    ownOnly.closest('.switch').classList.toggle('is-off', ownOn);
    const usePred = predOn && !ownOn;
    const ownSum = KEYS.reduce((a, k) => a + COST_ROWS[k].own, 0);
    const predSum = KEYS.reduce((a, k) => a + COST_ROWS[k].pred, 0);
    const fixedSum = fixOn ? fixed : 0;
    KEYS.forEach((k) => {
      const shown = COST_ROWS[k].own + (usePred ? COST_ROWS[k].pred : 0);
      const cell = document.querySelector('#cost-table [data-group="' + k + '"]');
      cell.textContent = money(shown);
      document.querySelector('#cost-table [data-perkm="' + k + '"]').textContent = n2.format(shown / km);
    });
    const predCell = document.querySelector('#cost-table [data-group="pred"]');
    predCell.textContent = usePred ? money(predSum) : tf('cost.none');
    document.querySelector('#cost-table [data-perkm="pred"]').textContent = usePred ? n2.format(predSum / km) : '-';
    const fixCell = document.querySelector('#cost-table [data-group="fixed"]');
    fixCell.textContent = fixOn ? money(fixedSum) : tf('cost.none');
    document.querySelector('#cost-table [data-perkm="fixed"]').textContent = fixOn ? n2.format(fixedSum / km) : '-';
    const total = ownSum + (usePred ? predSum : 0) + fixedSum;
    document.getElementById('cost-sum').textContent = money(total);
    document.getElementById('cost-perkm').textContent = n2.format(total / km);
    document.getElementById('cost-all').textContent = money(ownSum + predSum + fixedSum);
    document.getElementById('cost-own-sum').textContent = money(ownSum);
    document.getElementById('cost-pred-sum').textContent = money(ownSum + predSum);
  }
  ['cost-mileage', 'cost-fixed'].forEach((id) => document.getElementById(id).addEventListener('input', renderCost));
  ['cost-own', 'cost-pred', 'cost-fix'].forEach((id) => document.getElementById(id).addEventListener('change', renderCost));

  /* 9. START. */
  function renderAll() {
    document.documentElement.lang = lang();
    renderRem();
    renderUse();
    renderCost();
    const versioned = $$('[data-version]');
    versioned.forEach((el) => { if (el.dataset.version) el.textContent = el.dataset.version; });
  }

  // Uchwyt dla narzedzia QA (tools/landing/qa.py): slowniki tylko dla ?qa
  if (new URLSearchParams(location.search).has('qa')) {
    window.__pitstop = { PL, EN, tf, lang, applyLang };
  }

  applyLang(lang());
  if ('scrollRestoration' in history) history.scrollRestoration = 'manual';
})();
