//----------------------------------------------------------
// Moduł obsługi zestawu znaków (charset)
//----------------------------------------------------------

// Adres zestawu znaków (po $2000 żeby uniknąć kolizji z innymi danymi)
.const CHARSET_LOCATION = $2000

// Inicjalizacja zestawu znaków
init_charset:
    // Wyłączenie przerwań podczas kopiowania zestawu znaków
    sei
    
    // Zapisz aktualny stan rejestrów banku pamięci
    lda $01
    pha
    
    // Przełącz na konfigurację banków z ROM znaków dostępnym
    lda #$33
    sta $01
    
    // Skopiuj podstawowy zestaw znaków z ROM do RAM
    ldx #0
!loop:
    lda $d000, x          // Źródło znaków w ROM
    sta CHARSET_LOCATION, x
    lda $d100, x
    sta CHARSET_LOCATION + $100, x
    lda $d200, x
    sta CHARSET_LOCATION + $200, x
    lda $d300, x
    sta CHARSET_LOCATION + $300, x
    lda $d400, x
    sta CHARSET_LOCATION + $400, x
    lda $d500, x
    sta CHARSET_LOCATION + $500, x
    lda $d600, x
    sta CHARSET_LOCATION + $600, x
    lda $d700, x
    sta CHARSET_LOCATION + $700, x
    inx
    bne !loop-
    
    // Przywróć poprzedni stan banku pamięci
    pla
    sta $01
    
    // Przełącz VIC-II na nasz zestaw znaków
    lda $d018
    and #%11110001         // Wyczyść bity 1-3 (adres zestawu znaków)
    ora #%00001000         // Ustaw bit 3 (wskazuje na $2000)
    sta $d018
    
    // Modyfikuj wybrane znaki dla efektu wizualnego
    jsr modify_charset
    
    cli
    rts
    
// Modyfikacja zestawu znaków dla lepszego efektu
modify_charset:
    // Modyfikuj znak '@' (64) - zrobienie z niego logo
    ldx #0
!loop:
    lda custom_char_data, x
    sta CHARSET_LOCATION + 64*8, x  // 64 * 8 bajtów (każdy znak ma 8 bajtów)
    inx
    cpx #8
    bne !loop-
    
    // Modyfikuj litery 'A' do 'Z' - pochylenie dla efektu kursywy
    ldx #0                  // Licznik znaków (A do Z)
!char_loop:
    ldy #0                  // Licznik bajtów dla każdego znaku
!byte_loop:
    lda CHARSET_LOCATION + (65+x)*8, y  // Pobierz bajt z oryginalnego znaku (65 = 'A')
    
    // Przesuń w prawo lub w lewo w zależności od pozycji bajtu
    cpy #0
    beq no_shift            // Nie przesuwamy pierwszego bajtu
    cpy #7
    beq no_shift            // Nie przesuwamy ostatniego bajtu
    
    // Przesunięcie o 1 bit w prawo (dla efektu pochylenia)
    lsr
    
no_shift:
    sta CHARSET_LOCATION + (65+x)*8, y  // Zapisz zmodyfikowany bajt
    
    iny
    cpy #8
    bne !byte_loop-
    
    inx
    cpx #26                 // 26 liter (A-Z)
    bne !char_loop-
    
    rts

// Dane niestandardowych znaków (tutaj przykładowo definicja logo jako znak '@')
custom_char_data:
.byte %00111100    // ****
.byte %01000010    // *    *
.byte %10011001    // *  **  *
.byte %10100101    // * *  * *
.byte %10100101    // * *  * *
.byte %10011001    // *  **  *
.byte %01000010    // *    *
.byte %00111100    // ****

// Dane animowanego zestawu znaków używanego do efektów
.segment Charset "Charset Data"
animated_charset:
// Tutaj umieszczamy dane dla animowanych znaków
// Dla każdego znaku 8 bajtów pomnożone przez ilość klatek animacji
.byte $41, $42, $43, $44, $45  // Przykładowe wypełnienie - kilka liter alfabetu 