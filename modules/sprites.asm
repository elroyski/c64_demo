//----------------------------------------------------------
// Moduł zarządzania sprite'ami
//----------------------------------------------------------
.importonce // Zapewnia, że plik będzie zaimportowany tylko raz

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

// Tablica sinusa (256 wartości, zakres 24-104 dla X)
sine_table:
// Ręczna implementacja zamiast .fill z funkcjami trygonometrycznymi
.byte 64, 67, 71, 74, 77, 81, 84, 87, 90, 93, 96, 99, 101, 104
.byte 104, 104, 104, 104, 104, 104, 104, 104, 104, 104, 104, 104
.byte 101, 99, 96, 93, 90, 87, 84, 81, 77, 74, 71, 67, 64, 61, 57
.byte 54, 51, 47, 44, 41, 38, 35, 32, 29, 27, 24, 24, 24, 24, 24
.byte 24, 24, 24, 24, 24, 24, 24, 24, 27, 29, 32, 35, 38, 41, 44
.byte 47, 51, 54, 57, 61, 64, 67, 71, 74, 77, 81, 84, 87, 90, 93
.byte 96, 99, 101, 104, 104, 104, 104, 104, 104, 104, 104, 104
.byte 104, 104, 104, 104, 101, 99, 96, 93, 90, 87, 84, 81, 77, 74
.byte 71, 67, 64, 61, 57, 54, 51, 47, 44, 41, 38, 35, 32, 29, 27
.byte 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 27, 29
.byte 32, 35, 38, 41, 44, 47, 51, 54, 57, 61, 64, 67, 71, 74, 77
.byte 81, 84, 87, 90, 93, 96, 99, 101, 104, 104, 104, 104, 104
.byte 104, 104, 104, 104, 104, 104, 104, 104, 101, 99, 96, 93, 90
.byte 87, 84, 81, 77, 74, 71, 67, 64, 61, 57, 54, 51, 47, 44, 41
.byte 38, 35, 32, 29, 27, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24
.byte 24, 24, 24, 27, 29, 32, 35, 38, 41, 44, 47, 51, 54, 57, 61

// Tablica cosinusa (256 wartości, zakres 50-150 dla Y)
cosine_table:
// Ręczna implementacja zamiast .fill z funkcjami trygonometrycznymi
.byte 100, 103, 107, 110, 113, 117, 120, 123, 126, 129, 132, 135
.byte 137, 140, 143, 146, 148, 150, 150, 150, 150, 150, 150, 150
.byte 150, 150, 148, 146, 143, 140, 137, 135, 132, 129, 126, 123
.byte 120, 117, 113, 110, 107, 103, 100, 97, 93, 90, 87, 83, 80
.byte 77, 74, 71, 68, 65, 63, 60, 57, 54, 52, 50, 50, 50, 50, 50
.byte 50, 50, 50, 50, 52, 54, 57, 60, 63, 65, 68, 71, 74, 77, 80
.byte 83, 87, 90, 93, 97, 100, 103, 107, 110, 113, 117, 120, 123
.byte 126, 129, 132, 135, 137, 140, 143, 146, 148, 150, 150, 150
.byte 150, 150, 150, 150, 150, 150, 148, 146, 143, 140, 137, 135
.byte 132, 129, 126, 123, 120, 117, 113, 110, 107, 103, 100, 97
.byte 93, 90, 87, 83, 80, 77, 74, 71, 68, 65, 63, 60, 57, 54, 52
.byte 50, 50, 50, 50, 50, 50, 50, 50, 50, 52, 54, 57, 60, 63, 65
.byte 68, 71, 74, 77, 80, 83, 87, 90, 93, 97, 100, 103, 107, 110
.byte 113, 117, 120, 123, 126, 129, 132, 135, 137, 140, 143, 146
.byte 148, 150, 150, 150, 150, 150, 150, 150, 150, 150, 148, 146
.byte 143, 140, 137, 135, 132, 129, 126, 123, 120, 117, 113, 110
.byte 107, 103, 100, 97, 93, 90, 87, 83, 80, 77, 74, 71, 68, 65
.byte 63, 60, 57, 54, 52, 50, 50, 50, 50, 50, 50, 50, 50, 50, 52

// Definicje sprite'ów (12 sprite'ów, 4 zestawy animacji po 3 sprite'y)
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

// Drugi sprite - 4 klatki animacji - placeholder
.byte $aa,$aa,$aa, $aa,$aa,$aa, $aa,$aa,$aa
.byte $aa,$aa,$aa, $aa,$aa,$aa, $aa,$aa,$aa
.byte $aa,$aa,$aa, $aa,$aa,$aa, $aa,$aa,$aa
.byte $aa,$aa,$aa, $aa,$aa,$aa, $aa,$aa,$aa
.byte $aa,$aa,$aa, $aa,$aa,$aa, $aa,$aa,$aa
.byte $aa,$aa,$aa, $aa,$aa,$aa, $aa,$aa,$aa
.byte $aa,$aa,$aa, $aa,$aa,$aa, $aa,$aa,$aa

// Trzeci sprite - 4 klatki animacji - placeholder
.byte $55,$55,$55, $55,$55,$55, $55,$55,$55
.byte $55,$55,$55, $55,$55,$55, $55,$55,$55
.byte $55,$55,$55, $55,$55,$55, $55,$55,$55
.byte $55,$55,$55, $55,$55,$55, $55,$55,$55
.byte $55,$55,$55, $55,$55,$55, $55,$55,$55
.byte $55,$55,$55, $55,$55,$55, $55,$55,$55
.byte $55,$55,$55, $55,$55,$55, $55,$55,$55

// Zmienne dla sprite'ów
sprite_anim_counter: .byte 0
sprite_anim_delay: .byte 0
sprite_frame: .byte 0 