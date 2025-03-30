//----------------------------------------------------------
// Moduł przewijania tekstu (scroll)
//----------------------------------------------------------

// Inicjalizacja scrollera
init_scroll:
    // Zainicjuj wiersz scrollera (ostatni wiersz ekranu) spacjami
    ldx #0
!loop:
    lda #32             // Kod ASCII spacji
    sta SCREEN + 24*40, x
    lda #1              // Kolor biały
    sta COLOR_RAM + 24*40, x
    inx
    cpx #40
    bne !loop-
    
    lda #0              // Zainicjuj licznik znaków i offsetu
    sta scroll_char_index
    sta scroll_xpos
    rts

// Aktualizacja scrollera podczas przerwania
update_scroll:
    // Przesuń znaki w wierszu w lewo
    ldx #0
!loop:
    lda SCREEN + 24*40 + 1, x
    sta SCREEN + 24*40, x
    inx
    cpx #39
    bne !loop-
    
    // Aktualizuj pozycję X scrollera
    dec scroll_xpos
    lda scroll_xpos
    and #7
    sta scroll_xpos
    bne skip_new_char
    
    // Pobierz nowy znak z tekstu
    ldx scroll_char_index
    lda scroll_text, x
    
    // Sprawdź czy to koniec tekstu
    cmp #0
    bne not_end_of_text
    
    // Jeśli koniec tekstu, zacznij od początku
    ldx #0
    stx scroll_char_index
    lda scroll_text, x
    
not_end_of_text:
    // Wstaw nowy znak na końcu wiersza
    sta SCREEN + 24*40 + 39
    
    // Przejdź do następnego znaku w tekście
    inc scroll_char_index
    
skip_new_char:
    // Efekt kolorów dla wiersza scrollera
    lda frame_counter
    lsr
    lsr
    and #$07
    tax
    lda color_table, x

    // Ustaw kolor dla całego wiersza scrollera
    ldx #0
!loop:
    sta COLOR_RAM + 24*40, x
    inx
    cpx #40
    bne !loop-
    
    // Inkrementuj licznik ramek
    inc frame_counter
    rts
    
// Tekst scrollera
scroll_text:
.text "witaj w najlepszym intro na commodore 64! napisane w kick assemblerze z wykorzystaniem wielu zaawansowanych technik. "
.text "pozdrowienia dla wszystkich fanow demosceny i retro komputerow! jesli to czytasz, to znaczy ze scroller dziala poprawnie! "
.text "czas na kolejne okrazenie...    "
.byte 0

// Tablica kolorów dla scrollera
color_table:
.byte 1, 7, 8, 2, 8, 7, 1, 1  // Biały, żółty, pomarańczowy, czerwony i z powrotem

// Zmienne scrollera
frame_counter: .byte 0
scroll_char_index: .byte 0
scroll_xpos: .byte 0 