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

//----------------------------------------------------------
// Podstawowe zmienne
//----------------------------------------------------------
.var music = LoadSid("music/music.sid")

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
    
    // Inicjalizacja muzyki
    ldx #0          // Utwór numer 0
    ldy #0          // Nie używamy specjalnego adresu
    lda #music.startSong-1
    jsr music.init
    
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
    jsr music.play
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

// Dołączenie poszczególnych modułów
#import "modules/charset.asm"
#import "modules/sprites.asm"
#import "modules/graphics.asm"
#import "modules/scroll.asm"

//----------------------------------------------------------
// Segment muzyki
//----------------------------------------------------------
.segment Music []
*=music.location "Music"
.fill music.size, music.getData(i)

//----------------------------------------------------------
// Segment danych graficznych, zestawu znaków i sprite'ów
//----------------------------------------------------------
.segment GFXData []
.segment Charset []
.segment Sprites [] 