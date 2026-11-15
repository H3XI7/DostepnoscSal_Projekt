# Plan Rozwoju Projektu (Roadmap & Future Extensions)

Niniejszy dokument przedstawia sugerowane kierunki rozwoju oraz potencjalne zadania dla kolejnego modelu AI lub programisty kontynuującego projekt.

---

## 1. Aktualny Stan Projektu (Wersja 1.2.0) - Zrealizowane

- [x] **Wektorowy plan pięter (Canvas/CustomPainter)**: Geometria Politechniki Rzeszowskiej, Parter i I Piętro.
- [x] **Integracja Garażu z Parterem**: Umieszczenie Garażu podziemnego na dziedzińcu Parteru, wspólne zapytania `/api/rooms?floor=Parter`.
- [x] **Automatyczne skalowanie (Auto-Fit)**: Płynne dopasowanie rzutu do rozdzielczości ekranu (`FittedBox`).
- [x] **Zaawansowane powiększanie (Zoom)**: Zakres oddalania 0.25x - 3.5x oraz przyciski `[-]`, `[⛶]`, `[+]`.
- [x] **Tryb edycji rozkładu sal**: Przeciąganie klocków sal z zapisem współrzędnych `posX`, `posY` do SQLite.
- [x] **Dedykowany tryb TV Kiosk Dashboard**: Równoległe rzuty pięter, zegar czasu rzeczywistego, liczniki sal i ticker.
- [x] **Lokalne wykrywanie serwera (UDP Auto-Discovery)**: Responder na porcie `8082`, eliminujący konieczność wpisywania adresu IP.
- [x] **Wbudowany mechanizm aktualizacji OTA (Android)**: Powiadomienie o nowej wersji, pasek pobierania APK i instalacja w systemie.
- [x] **Niezależne uruchamianie w tle na Windows**: Skrypt wsadowy i kontroler PowerShell bez uśmiercania procesów przy zamknięciu konsoli.
- [x] **Węzeł IoT ESP8266 Wemos D1 mini**: Skaner sieci Wi-Fi i sterowanie dwukolorowymi diodami LED.

---

## 2. Sugerowane Zadania i Rozszerzenia (Next Milestones)

### 2.1. Komunikacja w Czasie Rzeczywistym (WebSockets / SSE)
- **Obecny stan**: Klienci odpytują serwer metodą HTTP polling (co 3 sekundy w trybie TV, co kilka sekund w aplikacji mobilnej).
- **Propozycja**:
  - Zastąpienie części zapytań mechanizmem Server-Sent Events (SSE) lub WebSocketami w `sync_server.py`.
  - Natychmiastowe rozsyłanie zdarzenia `ROOM_STATE_CHANGED` do wszystkich podłączonych ekranów i urządzeń ESP8266 w ułamku sekundy po kliknięciu sali.

### 2.2. Integracja z Planem Zajęć Uczelni (USOS / iCal)
- **Cel**: Automatyczna zmiana statusu sal w oparciu o harmonogram zajęć.
- **Implementacja**:
  - Moduł w `sync_server.py` parsujący pliki `.ics` (iCalendar) lub API planów zajęć.
  - Automatyczne oznaczanie sali jako zajętej w godzinach wykładów/laboratoriów i zwalnianie jej w przerwach.

### 2.3. Autoryzacja i Role Użytkowników
- **Cel**: Ochrona trybu edycji układu sal i zmiany statusów przed przypadkową modyfikacją przez osoby postronne.
- **Implementacja**:
  - Prosty kod PIN lub token JWT dla administratora.
  - Zwykły widok dla gości / studentów (tylko odczyt), panel administracyjny dla prowadzących i organizatorów.

### 2.4. Rozbudowa o Kolejne Piętra i Budynki (Multi-Building Support)
- **Cel**: Obsługa innych budynków kampusu Politechniki Rzeszowskiej (np. Budynek V, Budynek L).
- **Implementacja**:
  - Dodanie tabeli `buildings` w bazie danych SQLite.
  - Możliwość dynamicznego wczytywania geometrii ścian z plików GeoJSON / SVG zamiast twardo zakodowanych ścieżek `Path()`.

### 2.5. Rozbudowa Węzłów IoT (ESP32 z Wyświetlaczem E-Paper)
- **Cel**: Inteligentne tabliczki przydrzwiowe.
- **Implementacja**:
  - Użycie mikrokontrolera ESP32 z małym ekranem e-papierowym (e-Ink 2.9" lub 4.2").
  - Wyświetlanie aktualnej nazwy pokazu, prowadzącego, godziny kolejnych zajęć oraz kodu QR do aplikacji webowej.
