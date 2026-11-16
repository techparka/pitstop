/* PitStop - strona startowa. Bez CDN, bez pakietów, bez śledzenia.
   Motyw i język zapamiętane w localStorage, animowany licznik przy przewijaniu,
   trzy kalkulatory liczone tymi samymi wzorami co w aplikacji (build 2.0),
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
    'f1.p': 'Nazwa, marka, model, rocznik, rejestracja, numer VIN, zdjęcie i stan licznika. W 2.0 dochodzi napęd (benzyna, diesel, benzyna + LPG, hybryda, plug-in, elektryk), data zakupu i notatki.',
    'f2.h': 'Serwis z fakturą',
    'f2.p': 'Tytuł, data, przebieg, kwota w złotówkach, warsztat i kategoria z listy. Do tego zdjęcie z aparatu albo PDF faktury.',
    'f3.h': 'Części i robocizna osobno',
    'f3.p': 'Rozbicie jest opcjonalne: rozwijasz pole „Części i robocizna” i dopisujesz pozycje z rodzajem (część albo robocizna), nazwą i kwotą. Gdy jest choć jedna pozycja, kwota serwisu bierze się z ich sumy.',
    'f4.h': 'Termin w cyklu, który idzie dalej',
    'f5.h': 'Powiadomienia na 7 dni, 1 dzień i w dniu terminu',
    'f5.p': 'Alarmy ustawia AlarmManager i budzi telefon rano. Po tapnięciu wchodzisz w edycję terminu. Harmonogram wraca po restarcie telefonu, po aktualizacji i po zmianie strefy czasowej.',
    'f6.h': 'Tankowania liczone dla każdego paliwa osobno',
    'f6.p': 'Benzyna, diesel i LPG mają własną średnią. Pełny bak otwiera odcinek, a tankowanie oznaczone jako pominięte liczy go od nowa. Ładowanie idzie w kilowatogodzinach.',
    'f7.h': 'Historia wszystkich wpisów w jednym strumieniu',
    'f7.p': 'Serwisy i wpisy z księgi (tankowanie, ładowanie, wydatek, odczyt licznika) wychodzą z jednego zapytania i są ułożone datą.',
    'f8.h': 'Analityka na CustomPainterze',
    'f8.p': 'W 1.0 sumy i średnie. W 2.0 zakres dat, słupki miesiącami, kategorie, koszt kilometra i zużycie paliwa. Rysuje to CustomPainter, bez pakietu zewnętrznego.',
    'f9.h': 'Kopia ZIP z sumą kontrolną',
    'f9.p': 'Archiwum ma data.json z ośmioma tabelami, folder media i manifest.json z sumą SHA-256 każdego pliku. Przed przywróceniem aplikacja sprawdza kopię i najpierw robi kopię tego, co teraz masz.',
    'f10.h': 'CSV w obie strony i raport PDF',
    'f10.p': 'Import dopasowuje kolumny i pokazuje podgląd wierszy. Błędny wiersz odpada, reszta wchodzi, a powtórny import tego samego pliku nic nie dodaje. Raport historii to PDF z A4 generowany na telefonie.',
    'f11.h': 'Szkic formularza nie ginie',
    'f11.p': 'Niedokończony serwis, tankowanie czy termin zapisują się razem ze zdjęciem. Otworzysz ten sam formularz za godzinę albo po restarcie aplikacji, zastajesz to, co wpisałeś.',
    'f12.h': 'Bez konta, bez reklam, bez internetu',
    'f12.p': 'Nie ma logowania, klienta chmury ani wskaźników analitycznych w kodzie. AndroidManifest nie pyta o INTERNET, więc aplikacja nie ma czym wysłać danych.',

    'demo.label': 'Sprawdź na swoich liczbach',
    'demo.h2': 'Trzy kalkulatory z logiką aplikacji',
    'demo.lead': 'Strona działa offline i liczy tymi samymi wzorami co kalkulatory w aplikacji.',
    'demo.note': 'Kalkulator na potrzeby strony, nie formularz z aplikacji. Twoje liczby zostają w tej karcie przeglądarki.',
    'demo.tab.rem': 'Terminy', 'demo.tab.use': 'Zużycie', 'demo.tab.cost': 'Koszt kilometra',
    'demo.srcRem': 'Termin liczony datą i przebiegiem, jak na pulpicie aplikacji.',
    'demo.srcUse': 'Dwa pełne tankowania wystarczą; im więcej, tym średnia stabilniejsza.',
    'demo.rem.count': (n) => n === 1 ? '1 pozycja' : (n < 20 ? n + ' pozycje' : n + ' pozycji'),

    'rem.car': 'Auto', 'rem.car1': 'Yaris 1.0 benzyna', 'rem.car2': 'e-Up! elektryczny',
    'rem.type': 'Rodzaj terminu',
    'rem.t1': 'Przegląd okresowy', 'rem.t2': 'Wymiana oleju', 'rem.t3': 'Badanie techniczne',
    'rem.t4': 'Ubezpieczenie OC', 'rem.t5': 'Wymiana opon',
    'rem.legend': 'Termin', 'rem.legendnow': 'Stan w telefonie',
    'rem.bydate': 'Data', 'rem.bymile': 'Przebieg',
    'rem.nowkm': 'Ostatni odczyt licznika',
    'rem.now': 'Dzisiaj:', 
    'rem.btn.setNow': 'Ustaw dziś', 'rem.btn.add': 'Dodaj termin', 'rem.btn.reset': 'Przykład',
    'rem.hint': 'Aplikacja dopisuje kolejny termin po oznaczeniu wykonanego. Tutaj liczysz tylko progi.',
    'rem.need': 'Zaznacz datę albo przebieg, wtedy policzę progi.',
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
    'use.hint': 'Pominięte tankowanie przerywa odcinek. Kwota idzie do kosztów, nie do zużycia.',
    'use.need': 'Wpisz stan licznika i ilość paliwa, wtedy policzę zużycie.',
    'use.undo.none': 'Nie ma czego cofnąć, na liście są wpisy wzorcowe.',
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
    'use.from.date': (a, b) => a + ' - ' + b,
    'use.from.odo': (a, b) => a + ' - ' + b + ' km',
    'use.skipped.one': (n) => n + ' tankowanie pominięte na tym odcinku',
    'use.skipped.many': (n) => n + ' tankowań pominiętych na tym odcinku',
    'toast.use.added': 'Dodano wpis do listy.', 'toast.use.undo': 'Cofnięto ostatni wpis.',
    'toast.rem.added': 'Termin dodany do listy.',

    'cost.legend': 'Koszt kilometra', 'cost.mileage': 'Przejechane kilometry', 'cost.groups': 'Grupy kosztów',
    'cost.own': 'Tylko moje wpisy z telefonu', 'cost.pred': 'Koszty przewidywane', 'cost.fix': 'Rachunki stałe',
    'cost.predhint': 'Pola z analityki aplikacji, tu podstawiasz własne kwoty.',
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
    'screens.lead': 'Dolna nawigacja ma Pulpit, Historię, Terminy i Garaż, a plusem obok niej dopisujesz auto albo wpis. Zrzuty kliknij, żeby zobaczyć pełny ekran.',
    'screens.hint': 'Przewiń listę w bok albo użyj strzałek w podglądzie. Zrzuty pochodzą z builda 2.0.0+2.',
    'shot.btn': 'Ekran', 'shot.zoom': 'powiększ',
    'lb.close': 'Zamknij podgląd', 'lb.prev': 'Poprzedni zrzut', 'lb.next': 'Następny zrzut',
    's1.c': 'Pulpit: na górze wydatki miesiąca',
    's1.p': 'Pod spodem licznik, najbliższe terminy z progami i ostatnie wpisy. W 1.0 tylko licznik, suma kosztów i trzy terminy.',
    's1.n': 'Pulpit', 's1.alt': 'Pulpit aplikacji: wydatki miesiąca, licznik i najbliższe terminy',
    's2.c': 'Historia z wyszukiwarką i filtrami',
    's2.p': 'Wpisy z księgi i serwisy w jednej liście, filtrowane kategorią, autem i datą. W 1.0 wyłącznie serwisy.',
    's2.n': 'Historia', 's2.alt': 'Historia serwisowa z wyszukiwarką i filtrami zakresu dat',
    's3.c': 'Terminy z progiem dni i kilometrów',
    's3.p': 'Aktywne terminy na górze, pod nimi zrobione, obok przycisk powiadomień. W 1.0 termin nie ma cyklu ani alarmów.',
    's3.n': 'Terminy', 's3.alt': 'Lista terminów z progami dni i kilometrów',
    's4.n': 'Historia, ciemny motyw', 's4.alt': 'Historia serwisowa w ciemnym motywie',
    's5.n': 'Terminy, jasny motyw', 's5.alt': 'Lista terminów w jasnym motywie',

    'themes.label': 'Motyw',
    'themes.h2': 'Jasny, ciemny i ten systemowy',
    'themes.lead': 'Ten sam widok w dwóch wariantach, bez osobnych arkuszy stylów. Motyw ustawisz w aplikacji i na tej stronie.',
    'themes.dark': 'Ciemny', 'themes.light': 'Jasny',
    'themes.darkNote': 'Tło #11151C, karty #1D222C. Biały tekst ma 18:1, kolor wiodący 7:1.',
    'themes.lightNote': 'Tło #F5F6F8, białe karty, kolor wiodący ściemniony do #BA410C, żeby trzymał 5:1.',
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
    'l1.p': 'Kwota z dwoma miejscami po przecinku, data z kalendarza, licznik w kilometrach. Błędne pole dostaje komunikat, a szkic zostaje.',
    'l2.h': 'Interfejs słucha bazy',
    'l2.p': 'Riverpod trzyma listy, filtry i wybrane auto. Ekrany słuchają strumieni z bazy, więc zapisany wpis wchodzi na listę bez odświeżania.',
    'l3.h': 'Repozytorium i transakcje',
    'l3.p': 'Repozytorium składa serwisy z księgą w jednym zapytaniu. Zaznaczenie terminu wykonanym to transakcja: wpis do historii i nowy termin.',
    'l4.h': 'Plik w telefonie',
    'l4.p': 'car_service.db w katalogu aplikacji, zdjęcia i PDF-y obok. Klucze obce włączone, trzy indeksy pod listy, izolata pod interfejsem.',

    'tech.label': 'Kod i liczby',
    'tech.h2': 'Flutter, Dart, osiem tabel i zero plików konfiguracyjnych na serwerze',
    'tech.lead': 'Repozytorium <code>techparka/pitstop</code> trzyma kod aplikacji i tej strony w katalogu <code>docs/</code>. Liczby zmierzone 15 listopada 2026 roku.',
    't1l': 'ekranów w buildzie 2.0', 't1s': '10 plików, w 1.0 było 7',
    't2l': 'zgłoszeń analityzatora', 't2s': '<code>flutter analyze</code>, 33 s',
    't3l': 'linii Dart w wersji 1.0', 't3s': '23 pliki w <code>lib/</code>',
    't4l': 'tabel w schemacie wersji 3', 't4s': '<code>lib/data/database/tables.dart</code>',
    'tech.build': 'Od repozytorium do APK',
    'tech.buildhint': 'Od Fluttera 3.16 wzwyż, z dodatkami Androida. Czwarty krok generuje kody Drifta, bo plików <code>.g.dart</code> nie ma w repozytorium.',
    'tech.stack': 'Czego użyto',
    'tech.stacknote': 'Bez pakietu do wykresów: słupki i linie rysuje <code>CustomPainter</code>. Bez pakietu PDF: raport powstaje w kodzie Androida na <code>PdfDocument</code>.',
    'lic.h': 'Licencja MIT, bez drobnego druku',
    'lic.p': 'Zostaw notkę z licencją i nazwiskiem autora w kopiach, które rozdajesz. Kod jest dany bez żadnych gwarancji, więc za zgubiony termin przeglądowy odpowiadasz sam.',
    'lic.b1': 'Pełna treść licencji', 'lic.b2': 'Wydania z plikiem APK',

    'start.label': 'Pierwsze odpalenie',
    'start.h2': 'Trzy ekrany do pierwszej wpisanej sumy',
    'start.lead': 'Aplikacja startuje na liście aut. Dalej dodajesz auto, potem serwis z ostatniej faktury, a na koniec termin na następną wymianę oleju.',
    'st1.h': 'Auto i licznik',
    'st1.p': 'Nazwa, marka, model, rocznik i rejestracja wystarczą. Licznik przepisujesz z deski, a VIN, napęd i datę zakupu dopiszesz później.',
    'st2.h': 'Ostatni serwis',
    'st2.p': 'Data, kilometry, kwota i warsztat. Zdjęcie faktury dołączysz z aparatu albo z galerii, a PDF w tym samym miejscu.',
    'st3.h': 'Termin, który wróci sam',
    'st3.p': 'Daj terminowi datę, kilometry albo jedno i drugie, ustaw powtarzanie, a rano dostaniesz znak, że czas. Wykonany termin sam wystawia następny.',
    'note1b': 'Nie ma tego w Google Play.',
    'note1': 'APK pobierasz z wydań na GitHubie i zezwalasz telefonowi na instalację z tego jednego źródła. W telefonie służbowym sprawdź przed instalacją rozmiar i sumę kontrolną pliku.',
    'note2b': 'Android 5.0 albo nowszy.',
    'note2': 'Build bierze API 21 w górę i jest sprawdzony na telefonie z Androidem 14. Na tablecie i w przeglądarce nie działa: aplikacja jest na jeden telefon.',
    'note3b': 'Aktualizacja z 1.0 do 2.0.',
    'note3': 'Baza ma numery wersji, więc migracja z dwójki do trójki idzie sama, bez utraty danych. Własne buildy nadpiszą się tylko wtedy, gdy podpis i pakiet <code>com.example.car_service</code> zostaną te same.',
    'faq.h': 'Częste pytania',
    'q1': 'Czy PitStop jest darmowy?',
    'a1': 'Tak. Kod jest na licencji MIT, nie ma konta, reklam, abonamentu ani zakupów w aplikacji.',
    'q2': 'Czy aplikacja działa bez internetu?',
    'a2': 'Tak, dosłownie: w manifeście nie ma uprawnienia INTERNET. Nie ma też konta, chmury ani pakietów analitycznych, więc w trybie samolotowym działa nawet raport PDF.',
    'q3': 'Gdzie są zapisane dane?',
    'a3': 'W pliku car_service.db w katalogu aplikacji, obok zdjęć i PDF-ów. Kopia to ZIP z katalogu backups, bez szyfrowania.',
    'q5': 'Czym wersja z repozytorium różni się od wersji ze zrzutów?',
    'a5': 'W repozytorium jest 1.0.0: historia serwisów, proste terminy, statystyki i baza ze schematem numer 2. Zrzuty zrobiono w buildzie 2.0.0+2 ze schematem 3: księga tankowań i wydatków, terminy w cyklu z alarmami, kopia ZIP, import CSV, raport PDF i części z robocizną. Dwójki jeszcze nie ma na GitHubie.',
    'q7': 'Po co aplikacji aparat i zdjęcia?',
    'a7': 'Żeby do wpisu dołączyć zdjęcie licznika albo faktury. Pliki zostają w pamięci aplikacji, a zgody na internet nie ma.',
    'q8': 'W jakim języku jest aplikacja?',
    'a8': 'Tylko po polsku: nazwy pól są wpisane w kod, a daty i kwoty formatuje intl z ustawieniem pl_PL. Ta strona jest dwujęzyczna, aplikacja na razie nie.',
    'cta.overline': 'Odpalisz w kwadrans',
    'cta.h2': 'Pobierz APK, wrzuć trzy ostatnie rachunki',
    'cta.p': 'Bez konta, bez internetu i bez plików cookie, również na tej stronie. Po instalacji zostaje lista aut; reszta zależy od tego, co sam wpiszesz.',
    'cta.b1': 'Pobierz APK', 'cta.b2': 'Kod na GitHubie', 'cta.b3': 'Zgłoś błąd',
    'footer.about': 'Historia serwisowa auta w telefonie, bez konta i bez internetu. Kod na licencji MIT.',
    'footer.l1': 'Repozytorium', 'footer.l2': 'Wydania z APK', 'footer.l3': 'Zgłoś błąd',
    'footer.h2': 'Licencja',
    'footer.lic': 'Kod na MIT, bez żadnych gwarancji. Fonty: Inter, Space Grotesk i JetBrains Mono na licencji Open Font License.',
    'footer.made': 'Strona postawiona w katalogu <code>docs/</code> repozytorium z kodem, na GitHub Pages. Fonty i zrzuty są serwowane stąd, bez zewnętrznych serwerów i bez plików cookie.',
  // Dodane 2026-11-16, gdy sekcje zastapily diagramy i plakietki.
    'f4.s1': 'Termin',
    'f4.s1d': 'data, kilometry albo jedno i drugie',
    'f4.s2': 'Wykonany',
    'f4.s2d': 'pyta, czy dopisać wpis do historii',
    'f4.s3': 'Nowy termin',
    'f4.s3d': 'data od dzisiaj, kilometry od ostatniego odczytu',
    'f4.c1': 'co X miesięcy i co X kilometrów',
    'f4.c2': 'próg 30 dni albo 1000 km',
    'f4.c3': 'szablony: przegląd, OC, olej, opony',
    'f7.c1': 'szukaj po tytule, opisie i warsztacie',
    'f7.c2': 'filtr kategorii, auta i dat',
    'f7.c3': 'ostrzeżenie, gdy taki wpis już jest',
    'f12.c1': 'pyta o aparat, zdjęcia i start przy rozruchu',
    'f12.c2': 'eksport przez systemowy wybór miejsca',
    'f12.c3': 'motyw jasny, ciemny albo systemowy',
    'lic.c1': 'używaj',
    'lic.c2': 'kopiuj',
    'lic.c3': 'zmieniaj',
    'lic.c4': 'sprzedawaj',
    'lic.c5': 'bez gwarancji',
    'no.1': 'konto',
    'no.2': 'chmura',
    'no.3': 'reklamy',
    'no.4': 'analityka',
    'no.5': 'INTERNET',
    'no.6': 'GPS',
    'no.7': 'OBD',
    'no.8': 'Bluetooth',
    'no.line': 'Wyliczenia, kopie i PDF-y dzieją się na telefonie, a nazwę warsztatu przepisujesz z pola, które sam wypełniłeś.',
    'st1.c1': 'licznik z deski',
    'st1.c2': 'VIN później',
    'st1.c3': 'napęd w 2.0',
    'st2.c1': 'zdjęcie z aparatu',
    'st2.c2': 'PDF z galerii',
    'st2.c3': 'części w 2.0',
    'st3.c1': 'alarm na 7 dni',
    'st3.c2': 'na 1 dzień',
    'st3.c3': 'w dniu terminu',
    'tree.root': 'katalog aplikacji',
    'tree.rootd': 'widzi je tylko PitStop',
    'tree.db': 'osiem tabel, kwoty w groszach',
    'tree.media': 'zdjęcia i PDF-y dopięte do wpisów',
    'tree.back': 'kopie, które robisz sam',
    'tree.zip': 'kopia ręczna, automatyczna zaczyna się od auto',
    'tree.json': 'zawartość ośmiu tabel',
    'tree.media2': 'kopia zdjęć i PDF-ów',
    'tree.man': 'suma SHA-256 każdego pliku',
    'tree.schemad': 'Schemat numer 3. Migracja z dwójki dokłada księgę, pozycje serwisu i kwoty w groszach.',
    'tbl1': 'auta',
    'tbl2': 'serwisy',
    'tbl3': 'załączniki',
    'tbl4': 'terminy',
    'tbl5': 'księga',
    'tbl6': 'pozycje serwisu',
    'tbl7': 'ustawienia',
    'tbl8': 'własne kategorie'
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
    'hero.lead2': 'MIT-licensed code, zero network permissions, zero accounts.',
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
    'f1.p': 'Name, make, model, year, plates, VIN, a photo and the odometer reading. Version 2.0 adds the powertrain (petrol, diesel, petrol + LPG, hybrid, plug-in, electric), the purchase date and notes.',
    'f2.h': 'A service entry with the invoice',
    'f2.p': 'Title, date, mileage, amount in zloty, workshop and a category from the list. Plus a camera photo or an invoice PDF.',
    'f3.h': 'Parts and labour split apart',
    'f3.p': 'The split is optional: an expandable "Części i robocizna" section takes items with a type (part or labour), a name and a cost. Once there is at least one item, the service amount comes from their sum.',
    'f4.h': 'A reminder cycle that rolls on',
    'f5.h': 'Alerts 7 days, 1 day and on the day',
    'f5.p': 'AlarmManager schedules the alerts and wakes the phone in the morning, and a tap opens the reminder editor. The schedule survives a reboot, an app update and a time-zone change.',
    'f6.h': 'Consumption per fuel, not per car',
    'f6.p': 'Petrol, diesel and LPG each keep their own average. A full tank opens the stretch, a skipped fill-up restarts it. Charging counts in kilowatt hours.',
    'f7.h': 'Every entry in one history stream',
    'f7.p': 'Services and ledger rows (fill-ups, charging, expenses, odometer reads) come out of one query, sorted by date.',
    'f8.h': 'Charts drawn by CustomPainter',
    'f8.p': 'Version 1.0 gives totals and averages. Version 2.0 adds a date range, monthly bars, categories, cost per kilometre and fuel use, all drawn by CustomPainter with no chart package.',
    'f9.h': 'A ZIP backup with checksums',
    'f9.p': 'The archive holds data.json with eight tables, a media folder and manifest.json with a SHA-256 per file. Before restoring, the app checks the copy and first backs up the current state.',
    'f10.h': 'CSV both ways and a PDF report',
    'f10.p': 'Import maps the columns and previews the rows. A bad row drops out, the rest land, and importing the same file twice adds nothing. The history report is an A4 PDF built on the phone.',
    'f11.h': 'A half written form survives',
    'f11.p': 'An unfinished service, refuelling or reminder is stored together with its photo. Open the same form in an hour or after an app restart and your text is still there.',
    'f12.h': 'No account, no ads, no internet',
    'f12.p': 'No login, no cloud client, no analytics counters in the code. AndroidManifest never asks for INTERNET, so there is no way to send data out.',

    'demo.label': 'Try it with your own numbers',
    'demo.h2': 'Three calculators with the app logic',
    'demo.lead': 'The page works offline and calculates with the same formulas as the calculators in the app.',
    'demo.note': 'A page calculator, not an app form. Your numbers stay in this browser tab.',
    'demo.tab.rem': 'Reminders', 'demo.tab.use': 'Consumption', 'demo.tab.cost': 'Cost per km',
    'demo.srcRem': 'A reminder counted by date and by mileage, like on the dashboard.',
    'demo.srcUse': 'Two full tanks are enough; the more you add, the steadier the average.',
    'demo.rem.count': (n) => n === 1 ? '1 row' : n + ' rows',

    'rem.car': 'Car', 'rem.car1': 'Yaris 1.0 petrol', 'rem.car2': 'e-Up! electric',
    'rem.type': 'Reminder type',
    'rem.t1': 'Periodic inspection', 'rem.t2': 'Oil change', 'rem.t3': 'Technical inspection',
    'rem.t4': 'Liability insurance', 'rem.t5': 'Tyre change',
    'rem.legend': 'Due date', 'rem.legendnow': 'State on the phone',
    'rem.bydate': 'Date', 'rem.bymile': 'Mileage',
    'rem.nowkm': 'Last odometer reading',
    'rem.now': 'Today:',
    'rem.btn.setNow': 'Set today', 'rem.btn.add': 'Add reminder', 'rem.btn.reset': 'Example',
    'rem.hint': 'The app writes the next due date once you mark one done. Here you only work out the thresholds.',
    'rem.need': 'Tick a date or a mileage, then I can compute the thresholds.',
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
    'use.hint': 'A skipped fill-up ends the stretch. Money goes to costs, never to consumption.',
    'use.need': 'Type an odometer reading and a quantity, then I can work out consumption.',
    'use.undo.none': 'Nothing to undo, the list holds the sample entries.',
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
    'use.from.date': (a, b) => a + ' - ' + b,
    'use.from.odo': (a, b) => a + ' - ' + b + ' km',
    'use.skipped.one': (n) => n + ' skipped fill-up on this leg',
    'use.skipped.many': (n) => n + ' skipped fill-ups on this leg',
    'toast.use.added': 'Entry added to the list.', 'toast.use.undo': 'Last entry removed.',
    'toast.rem.added': 'Reminder added to the list.',

    'cost.legend': 'Cost per kilometre', 'cost.mileage': 'Kilometres driven', 'cost.groups': 'Cost groups',
    'cost.own': 'Only my entries from the phone', 'cost.pred': 'Predicted costs', 'cost.fix': 'Fixed bills',
    'cost.predhint': 'Fields from the app analytics, so plug in your own amounts here.',
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
    'screens.lead': 'Bottom navigation holds Home, History, Reminders and Garage, and the plus beside it adds a car or an entry. Click a screenshot for the full screen.',
    'screens.hint': 'Scroll the list sideways or use the arrows in the viewer. Screenshots come from the 2.0.0+2 build.',
    'shot.btn': 'Screen', 'shot.zoom': 'zoom in',
    'lb.close': 'Close the preview', 'lb.prev': 'Previous screenshot', 'lb.next': 'Next screenshot',
    's1.c': 'Dashboard: month costs on top',
    's1.p': 'Underneath: the odometer, the nearest reminders with thresholds and the latest entries. In 1.0 there is only the odometer, a cost total and three reminders.',
    's1.n': 'Dashboard', 's1.alt': 'Dashboard screen: month costs, odometer and upcoming reminders',
    's2.c': 'History with search and filters',
    's2.p': 'Ledger rows and services in one list, filtered by category, car and date. In 1.0, services only.',
    's2.n': 'History', 's2.alt': 'Service history with a search box and a date range filter',
    's3.c': 'Reminders with day and mileage thresholds',
    's3.p': 'Active reminders on top, finished ones below, a notification button beside them. In 1.0 reminders have no interval or alarms.',
    's3.n': 'Reminders', 's3.alt': 'Reminder list with day and mileage thresholds',
    's4.n': 'History, dark theme', 's4.alt': 'Service history in the dark theme',
    's5.n': 'Reminders, light theme', 's5.alt': 'Reminder list in the light theme',
    'themes.label': 'Theme',
    'themes.h2': 'Light, dark and the system one',
    'themes.lead': 'The same layout in two variants, with no separate stylesheets. Pick the theme in the app and on this page.',
    'themes.dark': 'Dark', 'themes.light': 'Light',
    'themes.darkNote': 'Background #11151C, cards #1D222C. White text reaches 18:1, the accent 7:1.',
    'themes.lightNote': 'Background #F5F6F8, white cards, accent darkened to #BA410C to hold 5:1.',
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
    'l1.p': 'Amounts to two decimals, dates from a calendar, the odometer in kilometres. A bad field shows a message and the draft survives.',
    'l2.h': 'The interface listens to the database',
    'l2.p': 'Riverpod holds the lists, the filters and the selected car. Screens listen to database streams, so a saved entry appears without a refresh.',
    'l3.h': 'Repository and transactions',
    'l3.p': 'The repository joins services with the ledger in a single query. Marking a reminder done is one transaction: a history entry and a new due date.',
    'l4.h': 'A file on the phone',
    'l4.p': 'car_service.db in the app folder, photos and PDFs beside it. Foreign keys on, three indexes for the lists, database work off the UI thread.',

    'tech.label': 'Code and numbers',
    'tech.h2': 'Flutter, Dart, eight tables and no server side configuration',
    'tech.lead': 'The <code>techparka/pitstop</code> repo holds the app and this page in <code>docs/</code>. Numbers measured on 15 November 2026.',
    't1l': 'screens in the 2.0 build', 't1s': '10 files, 1.0 had 7',
    't2l': 'analyser findings', 't2s': '<code>flutter analyze</code>, 33 s',
    't3l': 'lines of Dart in 1.0', 't3s': '23 files in <code>lib/</code>',
    't4l': 'tables in schema version 3', 't4s': '<code>lib/data/database/tables.dart</code>',
    'tech.build': 'From repository to APK',
    'tech.buildhint': 'Flutter 3.16 or newer with Android extras. Step four generates the Drift code, since <code>.g.dart</code> files are not committed.',
    'tech.stack': 'What is used',
    'tech.stacknote': 'No chart package: CustomPainter draws the bars and lines. No PDF package: the report is built in the Android layer with <code>PdfDocument</code>.',
    'lic.h': 'MIT licence, no small print',
    'lic.p': 'Keep the licence note and the author name in copies you hand out. The code comes without any warranty, so a missed inspection date is on you.',
    'lic.b1': 'Full licence text', 'lic.b2': 'Releases with the APK',

    'start.label': 'First launch',
    'start.h2': 'Three screens to your first logged amount',
    'start.lead': 'The app opens on the car list. Then you add a car, then a service from the last invoice, and finally a reminder for the next oil change.',
    'st1.h': 'Car and odometer',
    'st1.p': 'Name, make, model, year and plates are enough to start. Copy the odometer from the dash; the VIN, powertrain and purchase date can wait.',
    'st2.h': 'The last service',
    'st2.p': 'Date, kilometres, amount and workshop. Attach an invoice photo from the camera or the gallery, and a PDF in the same place.',
    'st3.h': 'A reminder that comes back',
    'st3.p': 'Give a reminder a date, a mileage or both, set the repeat, and the phone tells you in the morning. A completed reminder writes the next one.',
    'note1b': 'Not on Google Play.',
    'note1': 'You take the APK from Releases on GitHub and allow the phone to install from that one source. On a work phone, check the file size and checksum from the release notes first.',
    'note2b': 'Android 5.0 or newer.',
    'note2': 'The build targets API 21 and up and is tested on a phone with Android 14. It does not run on a tablet or in a browser: this app is for one phone.',
    'note3b': 'Updating from 1.0 to 2.0.',
    'note3': 'The database carries version numbers, so the migration from 2 to 3 runs on its own, without losing data. Your own builds overwrite each other only while the signing key and the <code>com.example.car_service</code> package stay the same.',
    'faq.h': 'Frequent questions',
    'q1': 'Is PitStop free?',
    'a1': 'Yes. The code is under the MIT licence, with no account, no ads, no subscription and no in-app purchases.',
    'q2': 'Does the app work offline?',
    'a2': 'Quite literally: the manifest never asks for INTERNET. There is no account, cloud sync or analytics SDK either, so the PDF report works in plane mode.',
    'q3': 'Where is the data stored?',
    'a3': 'In car_service.db inside the app folder, next to the photos and PDFs. A copy is a ZIP from the backups folder, unencrypted.',
    'q5': 'How does the repository version differ from the screenshots?',
    'a5': 'The repository holds 1.0.0: service history, plain due dates, stats and schema version 2. The screenshots come from build 2.0.0+2, schema 3: the fuel and expense ledger, reminders with intervals and alarms, ZIP backups, CSV import, the PDF report and parts with labour. 2.0 is not published yet.',
    'q7': 'Why does the app want the camera and photos?',
    'a7': 'To attach a photo of the odometer or the invoice to an entry. The files stay in app storage and there is no internet permission.',
    'q8': 'Which languages does the app speak?',
    'a8': 'Polish only: field labels are hard coded, and intl formats dates and amounts with pl_PL. This page is bilingual, the app is not yet.',
    'cta.overline': 'Up and running in fifteen minutes',
    'cta.h2': 'Get the APK, add your last three receipts',
    'cta.p': 'No account, no internet, no cookies, and this page follows the same rule. After installation you get the car list; the rest depends on what you type in.',
    'cta.b1': 'Get the APK', 'cta.b2': 'Source on GitHub', 'cta.b3': 'Report a bug',
    'footer.about': 'Car service history on your phone, without an account and without the internet. Code under the MIT licence.',
    'footer.l1': 'Repository', 'footer.l2': 'Releases with the APK', 'footer.l3': 'Report a bug',
    'footer.h2': 'Licence',
    'footer.lic': 'MIT code, no warranty at all. Fonts: Inter, Space Grotesk and JetBrains Mono under the Open Font Licence.',
    'footer.made': 'This page lives in the <code>docs/</code> folder of the code repository and is served by GitHub Pages. Fonts and screenshots are served from here, with no third party servers and no cookies.',
  // Dodane 2026-11-16, gdy sekcje zastapily diagramy i plakietki.
    'f4.s1': 'Due date',
    'f4.s1d': 'a date, a mileage, or both',
    'f4.s2': 'Done',
    'f4.s2d': 'asks whether to log the work',
    'f4.s3': 'Next due date',
    'f4.s3d': 'date from today, mileage from the last reading',
    'f4.c1': 'every X months and every X km',
    'f4.c2': '30 day or 1000 km threshold',
    'f4.c3': 'templates: inspection, insurance, oil, tyres',
    'f7.c1': 'search by title, notes and workshop',
    'f7.c2': 'filter by category, car and dates',
    'f7.c3': 'warns when an entry already matches',
    'f12.c1': 'asks for camera, photos and boot start',
    'f12.c2': 'export through the system save dialog',
    'f12.c3': 'light, dark or system theme',
    'lic.c1': 'use it',
    'lic.c2': 'copy it',
    'lic.c3': 'change it',
    'lic.c4': 'sell it',
    'lic.c5': 'no warranty',
    'no.1': 'account',
    'no.2': 'cloud',
    'no.3': 'ads',
    'no.4': 'analytics',
    'no.5': 'INTERNET',
    'no.6': 'GPS',
    'no.7': 'OBD',
    'no.8': 'Bluetooth',
    'no.line': 'Maths, backups and PDFs happen on the phone, and the workshop name comes from a field you fill in.',
    'st1.c1': 'odometer from the dash',
    'st1.c2': 'VIN later',
    'st1.c3': 'powertrain in 2.0',
    'st2.c1': 'photo from the camera',
    'st2.c2': 'PDF from the gallery',
    'st2.c3': 'parts in 2.0',
    'st3.c1': 'alarm at 7 days',
    'st3.c2': 'at 1 day',
    'st3.c3': 'on the day',
    'tree.root': 'app folder',
    'tree.rootd': 'only PitStop can read it',
    'tree.db': 'eight tables, amounts in cents',
    'tree.media': 'photos and PDFs attached to entries',
    'tree.back': 'backups you make yourself',
    'tree.zip': 'manual copy, automatic ones start with auto',
    'tree.json': 'all eight tables',
    'tree.media2': 'copy of photos and PDFs',
    'tree.man': 'SHA-256 for every file',
    'tree.schemad': 'Schema version 3. Migrating from 2 adds the ledger, service items and cent amounts.',
    'tbl1': 'vehicles',
    'tbl2': 'services',
    'tbl3': 'attachments',
    'tbl4': 'due dates',
    'tbl5': 'ledger',
    'tbl6': 'service items',
    'tbl7': 'settings',
    'tbl8': 'own categories'
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
    toastTimer = setTimeout(() => {
      live.classList.remove('is-on');
      live.textContent = '';
    }, 2800);
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
    if (!due && dueKm == null) { toast(tf('rem.need')); return false; }
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
  let useAdded = [];

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
    if (!odo || !qty) { toast(tf('use.need')); return false; }
    const row = { odo: odo, qty: qty, cost: num('use-cost'), full: document.getElementById('use-full').checked, missed: document.getElementById('use-missed').checked, kind: kind, date: new Date() };
    useRows.push(row);
    useAdded.push(row);
    useRows.sort((a, b) => a.odo - b.odo);
    toast(tf('toast.use.added'));
    return true;
  }
  document.getElementById('use-add').addEventListener('click', () => { if (readUseForm()) renderUse(); });
  document.getElementById('use-undo').addEventListener('click', () => {
    const last = useAdded.pop();
    if (!last) { toast(tf('use.undo.none')); return; }
    const i = useRows.indexOf(last);
    if (i >= 0) useRows.splice(i, 1);
    toast(tf('toast.use.undo'));
    renderUse();
  });
  document.getElementById('use-reset').addEventListener('click', () => { useRows = (val('use-kind') === 'ev' ? USE_SAMPLE_EV : USE_SAMPLE).slice(); useAdded = []; renderUse(); });
  document.getElementById('use-kind').addEventListener('change', () => {
    const isEv = val('use-kind') === 'ev';
    document.getElementById('use-missed').checked = false;
    document.getElementById('use-full').checked = true;
    useAdded = [];
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
