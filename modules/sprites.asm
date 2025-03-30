//----------------------------------------------------------
// Moduł zarządzania sprite'ami
//----------------------------------------------------------

// Inicjalizacja sprite'ów
init_sprites:
    // Włącz sprite'y 0, 1 i 2
    lda #%00000111
    sta SPRITE_ENABLE
    
    // Ustaw wskaźniki sprite'ów (każdy sprite ma 64 bajty)
    lda #(sprite_data/64)
    sta SPRITE_POINTERS      // Sprite 0
    lda #(sprite_data/64)+1
    sta SPRITE_POINTERS+1    // Sprite 1
    lda #(sprite_data/64)+2
    sta SPRITE_POINTERS+2    // Sprite 2
    
    // Ustaw kolory sprite'ów
    lda #1                  // Biały
    sta $d027                // Kolor sprite'a 0
    lda #7                  // Żółty
    sta $d028                // Kolor sprite'a 1
    lda #14                 // Jasnoniebieski
    sta $d029                // Kolor sprite'a 2
    
    // Ustaw początkowe pozycje sprite'ów
    // Sprite 0 (lewy)
    lda #50
    sta $d000                // X pozycja
    lda #100
    sta $d001                // Y pozycja
    
    // Sprite 1 (środkowy)
    lda #160
    sta $d002                // X pozycja
    lda #100
    sta $d003                // Y pozycja
    
    // Sprite 2 (prawy)
    lda #250
    sta $d004                // X pozycja
    lda #100
    sta $d005                // Y pozycja
    
    // Inicjalizuj zmienne animacji
    lda #0
    sta sprite_anim_counter
    sta sprite_anim_delay
    
    // Włącz rozszerzone kolory dla sprite'ów
    lda #%00000111
    sta $d01c                // Multicolor dla sprite 0, 1, 2
    
    // Ustaw kolory wspólne dla sprite'ów multicolor
    lda #0                   // Czarny
    sta $d025                // Wspólny kolor 1
    lda #5                   // Zielony
    sta $d026                // Wspólny kolor 2
    
    rts

// Aktualizacja sprite'ów podczas przerwania
update_sprites:
    // Przesuń sprite'y po sinusoidzie
    ldx sprite_anim_counter
    
    // Pierwszy sprite - ruch sinusoidalny po X i Y
    lda sine_table, x
    sta $d000                // X pozycja
    lda cosine_table, x
    sta $d001                // Y pozycja
    
    // Drugi sprite - ruch po okręgu w przeciwnym kierunku
    txa
    clc
    adc #85                  // Przesunięcie o 1/3 tablicy
    tax
    lda sine_table, x
    sta $d002                // X pozycja
    lda cosine_table, x
    sta $d003                // Y pozycja
    
    // Trzeci sprite - kolejne przesunięcie
    txa
    clc
    adc #85                  // Przesunięcie o kolejną 1/3 tablicy
    tax
    lda sine_table, x
    sta $d004                // X pozycja
    lda cosine_table, x
    sta $d005                // Y pozycja
    
    // Aktualizacja klatek animacji sprite'ów
    lda sprite_anim_delay
    cmp #5                   // Co 5 ramek animujemy sprite'y
    bne no_sprite_update
    
    // Aktualizuj wskaźniki do sprajtów
    ldx sprite_frame
    inx
    cpx #4                   // 4 klatki animacji
    bne !+
    ldx #0                   // Resetuj do pierwszej klatki
!:  stx sprite_frame
    
    // Aktualizuj wskaźniki na sprite data
    txa
    clc
    adc #(sprite_data/64)
    sta SPRITE_POINTERS      // Sprite 0
    
    txa
    clc
    adc #(sprite_data/64)+4  // Drugi zestaw animacji
    sta SPRITE_POINTERS+1    // Sprite 1
    
    txa
    clc
    adc #(sprite_data/64)+8  // Trzeci zestaw animacji
    sta SPRITE_POINTERS+2    // Sprite 2
    
    lda #0
    sta sprite_anim_delay
    
no_sprite_update:
    inc sprite_anim_delay
    
    // Inkrementuj licznik animacji (dla ruchu)
    inc sprite_anim_counter
    
    rts

// Tablica sinusa (64 wartości, zakres 24-104 dla X)
sine_table:
.fill 256, 64 + 40*sin(toRadians(i*360/256))

// Tablica cosinusa (64 wartości, zakres 50-150 dla Y)
cosine_table:
.fill 256, 100 + 50*cos(toRadians(i*360/256))

// Definicje sprite'ów (12 sprite'ów, 4 zestawy animacji po 3 sprite'y)
.segment Sprites "Sprite Data"
sprite_data:

// Pierwszy sprite (logo) - 4 klatki animacji
.byte %00111100,%00111100,%00000000
.byte %01111110,%01111110,%00000000
.byte %11111111,%11111111,%00000000
.byte %11111111,%11111111,%00000000
.byte %11111111,%11111111,%00000000
.byte %11111111,%11111111,%00000000
.byte %01111110,%01111110,%00000000
.byte %00111100,%00111100,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00011000,%00011000,%00000000
.byte %00111100,%00111100,%00000000
.byte %00111100,%00111100,%00000000
.byte %00111100,%00111100,%00000000
.byte %00011000,%00011000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000

// Druga klatka animacji pierwszego sprite'a
.byte %00001100,%00111100,%00000000
.byte %00011110,%01111110,%00000000
.byte %00111111,%11111111,%00000000
.byte %01111111,%11111111,%00000000
.byte %01111111,%11111111,%00000000
.byte %00111111,%11111111,%00000000
.byte %00011110,%01111110,%00000000
.byte %00001100,%00111100,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00011000,%00000000
.byte %00000000,%00111100,%00000000
.byte %00000000,%00111100,%00000000
.byte %00000000,%00111100,%00000000
.byte %00000000,%00011000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000

// Trzecia klatka animacji pierwszego sprite'a
.byte %00111100,%00001100,%00000000
.byte %01111110,%00011110,%00000000
.byte %11111111,%00111111,%00000000
.byte %11111111,%01111111,%00000000
.byte %11111111,%01111111,%00000000
.byte %11111111,%00111111,%00000000
.byte %01111110,%00011110,%00000000
.byte %00111100,%00001100,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00011000,%00000000,%00000000
.byte %00111100,%00000000,%00000000
.byte %00111100,%00000000,%00000000
.byte %00111100,%00000000,%00000000
.byte %00011000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000

// Czwarta klatka animacji pierwszego sprite'a
.byte %00111100,%00111100,%00000000
.byte %01111110,%01111110,%00000000
.byte %11111111,%11111111,%00000000
.byte %11111111,%11111111,%00000000
.byte %11111111,%11111111,%00000000
.byte %11111111,%11111111,%00000000
.byte %01111110,%01111110,%00000000
.byte %00111100,%00111100,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00011000,%00000000
.byte %00000000,%00111100,%00000000
.byte %00000000,%00111100,%00000000
.byte %00000000,%00111100,%00000000
.byte %00000000,%00011000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000

// Drugi sprite - 4 klatki animacji
// (analogiczne definicje dla drugiego zestawu sprite'ów... skrócone dla zwięzłości)
.fill 64*4, $aa   // Placeholder, będzie zastąpiony prawdziwymi danymi

// Trzeci sprite - 4 klatki animacji
// (analogiczne definicje dla trzeciego zestawu sprite'ów... skrócone dla zwięzłości)
.fill 64*4, $55   // Placeholder, będzie zastąpiony prawdziwymi danymi

// Zmienne dla sprite'ów
sprite_anim_counter: .byte 0
sprite_anim_delay: .byte 0
sprite_frame: .byte 0 