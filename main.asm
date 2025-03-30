//----------------------------------------------------------
// Intro Commodore 64 - Zrobione w Kick Assembler 5.25
//----------------------------------------------------------

.file [name="intro.prg", segments="Code, Music, GFXData, Charset, Sprites"]
.disk [filename="intro.d64", name="C64 INTRO", id="2023" ]
{
    [name="INTRO", type="prg", segments="Code, Music, GFXData, Charset, Sprites"]
}

//----------------------------------------------------------
// Stałe dla C64
//----------------------------------------------------------
.const SCREEN = $0400
.const COLOR_RAM = $d800
.const BORDER_COLOR = $d020
.const BACKGROUND_COLOR = $d021
.const SPRITE_ENABLE = $d015
.const RASTER_LINE = $d012
.const IRQ_CONTROL = $d01a
.const IRQ_STATUS = $d019
.const SPRITE_POINTERS = SCREEN + $3f8
.const CHARSET_LOCATION = $2000  // Adres zestawu znaków

//----------------------------------------------------------
// Podstawowe zmienne
//----------------------------------------------------------
// Tymczasowo usuwamy LoadSid i tworzymy placeholder
// .var music = LoadSid("music/music.sid")
.const MUSIC_LOCATION = $1000  // Adres w pamięci dla muzyki

//----------------------------------------------------------
// Główny segment kodu
//----------------------------------------------------------
.segment Code []

// Ustawienie adresu startowego na $0801 (standard dla C64)
*=$0801 "Basic Upstart"
.byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00
// Powyższe odpowiada: 10 SYS 2064

// Główny kod programu
*=$0810 "Main Code"
start:
    sei             // Wyłączenie przerwań
    lda #$35        // Wyłączenie ROM i włączenie banku RAM
    sta $01
    
    lda #$00        // Czarny kolor tła i ramki
    sta BACKGROUND_COLOR
    sta BORDER_COLOR
    
    // Inicjalizacja muzyki (placeholder)
    jsr init_music
    
    // Inicjalizacja poszczególnych modułów
    jsr init_charset    // Inicjalizacja zestawu znaków
    jsr init_sprites    // Inicjalizacja sprite'ów
    jsr init_graphics   // Inicjalizacja grafiki
    jsr init_scroll     // Inicjalizacja przewijania tekstu
    
    // Ustawienie przerwania IRQ
    lda #<irq_routine
    sta $0314
    lda #>irq_routine
    sta $0315
    
    lda #$01        // Ustawienie przerwania na linię rasterową
    sta IRQ_CONTROL
    lda #50         // Linia rasterowa dla pierwszego przerwania
    sta RASTER_LINE
    
    cli             // Włączenie przerwań
    
main_loop:
    jmp main_loop   // Nieskończona pętla

// Procedura przerwania
irq_routine:
    // Zapisz rejestry
    pha
    txa
    pha
    tya
    pha
    
    lda IRQ_STATUS
    sta IRQ_STATUS      // Potwierdź przerwanie
    
    // Wykonaj podprogramy w zależności od linii rasterowej
    lda RASTER_LINE
    cmp #50
    beq irq_sprites
    cmp #100
    beq irq_scroll
    cmp #200
    beq irq_music
    jmp irq_end
    
irq_sprites:
    jsr update_sprites
    lda #100
    sta RASTER_LINE
    jmp irq_end
    
irq_scroll:
    jsr update_scroll
    lda #200
    sta RASTER_LINE
    jmp irq_end
    
irq_music:
    jsr play_music
    lda #50
    sta RASTER_LINE
    
irq_end:
    // Przywróć rejestry
    pla
    tay
    pla
    tax
    pla
    rti

// Placeholder dla inicjalizacji muzyki
init_music:
    rts

// Placeholder dla odtwarzania muzyki
play_music:
    // Prosta zmiana koloru ramki dla efektu
    inc BORDER_COLOR
    rts

// Dołączenie poszczególnych modułów
#import "modules/charset.asm"
#import "modules/sprites.asm"
#import "modules/graphics.asm"
#import "modules/scroll.asm"

//----------------------------------------------------------
// Segment muzyki (placeholder)
//----------------------------------------------------------
.segment Music []
*=MUSIC_LOCATION "Music"
// Placeholder dla danych muzyki
.byte $00, $01, $02, $03, $04, $05

//----------------------------------------------------------
// Segment danych graficznych, zestawu znaków i sprite'ów
//----------------------------------------------------------
.segment GFXData "Graphics Data"
// Tutaj możemy umieścić dodatkowe dane graficzne

.segment Charset "Charset Data"
// Dane zestawu znaków animowanych
.byte $00, $01, $02, $03, $04  // Placeholder

.segment Sprites "Sprite Data"
// Dane sprite'ów będą automatycznie dołączone z modułu sprites.asm 