# C64 Demo Intro

Zaawansowane intro na Commodore 64 stworzone w Kick Assembler 5.25.

## Funkcje

* Efekt przewijania tekstu (scroller)
* Animowane sprite'y poruszające się po sinusoidzie
* Niestandardowy zestaw znaków
* Efekty plazmowe
* Raster bar
* Logo i grafika
* Muzyka SID

## Wymagania

* Kick Assembler 5.25 (http://theweb.dk/KickAssembler/)
* Java Runtime Environment
* Emulator C64 (VICE zalecany)

## Kompilacja

```
java -jar KickAss.jar main.asm
```

## Uruchamianie

```
x64 intro.prg
```

## Struktura plików

* `main.asm` - Główny plik źródłowy
* `modules/` - Katalog z modułami
  * `charset.asm` - Obsługa niestandardowego zestawu znaków
  * `sprites.asm` - Obsługa animowanych sprite'ów
  * `graphics.asm` - Efekty graficzne i rysowanie
  * `scroll.asm` - Efekt przewijania tekstu
* `music/` - Katalog z muzyką
  * `music.sid` - Plik muzyczny SID
* `gfx/` - Katalog z grafiką

## Pobieranie muzyki i grafiki

Aby intro działało poprawnie, należy pobrać pliki muzyczne SID. Przykładowe źródła:

* High Voltage SID Collection: https://www.hvsc.c64.org/
* Demusic Archive: https://demusic.org/

## Uwagi

* Należy zastąpić placeholder muzyki (`music/music.sid`) prawdziwym plikiem SID.
* Intro zostało zaprojektowane tak, aby wykorzystać zaawansowane funkcje Kick Assemblera. 