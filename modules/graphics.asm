//----------------------------------------------------------
// Moduł graficzny - efekty, animacje, logo
//----------------------------------------------------------
.importonce // Zapewnia, że plik będzie zaimportowany tylko raz

// Stałe dla efektów graficznych
.const LOGO_START_X = 10      // Pozycja startowa logo (kolumna)
.const LOGO_START_Y = 5       // Pozycja startowa logo (wiersz)
.const LOGO_WIDTH = 20        // Szerokość logo (w znakach)
.const LOGO_HEIGHT = 5        // Wysokość logo (w wierszach)

// Inicjalizacja grafiki
init_graphics:
    // Wyczyść ekran
    ldx #0
    lda #32                 // Kod spacji
!loop:
    sta SCREEN, x
    sta SCREEN + $100, x
    sta SCREEN + $200, x
    sta SCREEN + $300, x
    inx
    bne !loop-
    
    // Wyczyść kolory
    ldx #0
    lda #1                 // Kolor biały
!loop:
    sta COLOR_RAM, x
    sta COLOR_RAM + $100, x
    sta COLOR_RAM + $200, x
    sta COLOR_RAM + $300, x
    inx
    bne !loop-
    
    // Narysuj ramkę i tło ekranu
    jsr draw_border
    
    // Narysuj logo
    jsr draw_logo
    
    // Zainicjuj efekty dla poszczególnych części ekranu
    lda #0
    sta raster_bar_pos
    sta plasma_counter
    
    rts

// Rysowanie ramki dookoła ekranu
draw_border:
    // Górna krawędź
    ldx #0
!loop:
    lda #64                  // Znak '@' (zmodyfikowany na logo w module charset)
    sta SCREEN, x
    lda #7                   // Żółty kolor
    sta COLOR_RAM, x
    inx
    cpx #40
    bne !loop-
    
    // Dolna krawędź
    ldx #0
!loop:
    lda #64                  // Znak '@'
    sta SCREEN + 23*40, x
    lda #7                   // Żółty kolor
    sta COLOR_RAM + 23*40, x
    inx
    cpx #40
    bne !loop-
    
    // Lewa krawędź
    ldx #0
    stx border_index         // Zapisz licznik do zmiennej pomocniczej
!loop:
    lda #66                  // Znak 'B'
    
    // Oblicz adres na podstawie border_index
    lda border_index
    asl                      // × 2
    asl                      // × 4
    asl                      // × 8
    asl                      // × 16
    asl                      // × 32
    clc
    adc border_index         // + border_index × 8 = border_index × 40
    adc border_index         // + index = 40 × border_index
    tax                      // Przenieś do X jako indeks
    
    lda #66                  // Znak 'B'
    sta SCREEN, x            // Zapisz na ekranie
    lda #1                   // Biały kolor
    sta COLOR_RAM, x         // Zapisz kolor
    
    ldx border_index         // Przywróć licznik
    inc border_index
    inx
    cpx #24
    bne !loop-
    
    // Prawa krawędź
    ldx #0
    stx border_index         // Zapisz licznik do zmiennej pomocniczej
!loop:
    // Oblicz adres na podstawie border_index
    lda border_index
    asl                      // × 2
    asl                      // × 4
    asl                      // × 8
    asl                      // × 16
    asl                      // × 32
    clc
    adc border_index         // + border_index × 8 = border_index × 40
    adc border_index         // + index = 40 × border_index
    clc
    adc #39                  // Dodaj 39 do adresu (ostatnia kolumna)
    tax                      // Przenieś do X jako indeks
    
    lda #66                  // Znak 'B'
    sta SCREEN, x            // Zapisz na ekranie
    lda #1                   // Biały kolor
    sta COLOR_RAM, x         // Zapisz kolor
    
    ldx border_index         // Przywróć licznik
    inc border_index
    inx
    cpx #24
    bne !loop-
    
    rts

// Rysowanie logo
draw_logo:
    // Ustaw adres ekranu dla logo
    lda #<(SCREEN + LOGO_START_Y*40 + LOGO_START_X)
    sta logo_screen_ptr
    lda #>(SCREEN + LOGO_START_Y*40 + LOGO_START_X)
    sta logo_screen_ptr+1
    
    // Ustaw adres kolorów dla logo
    lda #<(COLOR_RAM + LOGO_START_Y*40 + LOGO_START_X)
    sta logo_color_ptr
    lda #>(COLOR_RAM + LOGO_START_Y*40 + LOGO_START_X)
    sta logo_color_ptr+1
    
    // Wskaźnik do danych logo
    lda #<logo_data
    sta logo_data_ptr
    lda #>logo_data
    sta logo_data_ptr+1
    
    // Licznik wierszy logo
    ldx #0
    
logo_row_loop:
    // Licznik kolumn logo
    ldy #0
    
logo_col_loop:
    // Pobierz znak z danych logo
    lda (logo_data_ptr), y
    
    // Zapisz znak na ekranie
    sta (logo_screen_ptr), y
    
    // Pobierz kolor z danych logo (zaraz po danych znaków)
    lda (logo_data_ptr), y
    clc
    adc #LOGO_WIDTH * LOGO_HEIGHT
    tay
    lda (logo_data_ptr), y
    tay
    
    // Zapisz kolor na ekranie
    sta (logo_color_ptr), y
    
    // Następna kolumna
    iny
    cpy #LOGO_WIDTH
    bne logo_col_loop
    
    // Przejdź do następnego wiersza
    lda logo_screen_ptr
    clc
    adc #40
    sta logo_screen_ptr
    lda logo_screen_ptr+1
    adc #0
    sta logo_screen_ptr+1
    
    lda logo_color_ptr
    clc
    adc #40
    sta logo_color_ptr
    lda logo_color_ptr+1
    adc #0
    sta logo_color_ptr+1
    
    lda logo_data_ptr
    clc
    adc #LOGO_WIDTH
    sta logo_data_ptr
    lda logo_data_ptr+1
    adc #0
    sta logo_data_ptr+1
    
    // Następny wiersz
    inx
    cpx #LOGO_HEIGHT
    bne logo_row_loop
    
    rts

// Efekt paska rastrowego (raster bar)
update_raster_bar:
    ldx raster_bar_pos
    
    // Utwórz efekt paska rasterowego na dole ekranu (nad scrollerem)
    lda raster_colors, x
    sta BORDER_COLOR
    sta BACKGROUND_COLOR
    
    // Przesuwaj pozycję paska
    inc raster_bar_pos
    
    rts

// Efekt efekt "plasmy" na części ekranu 
update_plasma:
    // Zwiększ licznik animacji plasmy
    inc plasma_counter
    ldx plasma_counter
    
    // Pobierz offset z tabeli sinusa
    lda sine_table, x
    tax
    
    // 10 wierszy plasmy na środku ekranu (8-17)
    lda #8          // Początkowy wiersz
    sta temp_row
    
plasma_row_loop:
    // Oblicz offset dla aktualnego wiersza
    lda temp_row
    asl                 // Mnożenie przez 2
    asl                 // Mnożenie przez 4
    asl                 // Mnożenie przez 8
    asl                 // Mnożenie przez 16
    asl                 // Mnożenie przez 32
    clc
    adc temp_row        // Dodaj wiersz * 8 = wiersz * 40
    adc temp_row        // ... 
    
    // Teraz w A mamy temp_row * 40
    tay                 // Przenieś do Y jako offset
    
    // Każdy wiersz ma swój własny offset koloru
    lda plasma_colors, x
    sta COLOR_RAM + 3, y   // COLOR_RAM + (3 + 40*temp_row)
    inx
    lda plasma_colors, x
    sta COLOR_RAM + 4, y   // COLOR_RAM + (4 + 40*temp_row)
    inx
    lda plasma_colors, x
    sta COLOR_RAM + 5, y   // COLOR_RAM + (5 + 40*temp_row)
    inx
    
    // Zwiększymy wiersz
    inc temp_row
    lda temp_row
    cmp #18         // Kończymy na wierszu 17
    bne plasma_row_loop
    
    rts

// Dane logo (znaki)
logo_data:
// 5 wierszy po 20 znaków (znaki ASCII)
.text "   commodore  64    "
.text "  best demo ever!   "
.text "        by         "
.text "  kickass masters  "
.text "   demoscene 2023  "

// Kolory dla logo (5 wierszy po 20 znaków)
.byte 1,1,1,7,7,7,7,7,7,7,7,7,7,14,14,1,1,1,1,1
.byte 1,1,7,7,7,7,7,7,1,1,7,7,7,7,7,7,1,1,1,1
.byte 1,1,1,1,1,1,1,1,7,7,1,1,1,1,1,1,1,1,1,1
.byte 1,1,7,7,7,7,7,7,7,7,1,1,7,7,7,7,7,1,1,1
.byte 1,1,1,7,7,7,7,7,7,7,7,7,7,1,1,1,1,1,1,1

// Tablica kolorów dla paska rastrowego
raster_colors:
.byte 0,0,0,9,2,2,2,8,8,8,7,7,7,1,1,1,1,1,1,1,7,7,7,8,8,8,2,2,2,9,0,0

// Tablica kolorów dla efektu plasmy
plasma_colors:
.byte 9,9,9,9,2,2,2,2,8,8,8,8,7,7,7,7,1,1,1,1,7,7,7,7,8,8,8,8,2,2,2,2
.byte 9,9,9,9,2,2,2,2,8,8,8,8,7,7,7,7,1,1,1,1,7,7,7,7,8,8,8,8,2,2,2,2
.byte 9,9,9,9,2,2,2,2,8,8,8,8,7,7,7,7,1,1,1,1,7,7,7,7,8,8,8,8,2,2,2,2
.byte 9,9,9,9,2,2,2,2,8,8,8,8,7,7,7,7,1,1,1,1,7,7,7,7,8,8,8,8,2,2,2,2
.byte 9,9,9,9,2,2,2,2,8,8,8,8,7,7,7,7,1,1,1,1,7,7,7,7,8,8,8,8,2,2,2,2
.byte 9,9,9,9,2,2,2,2,8,8,8,8,7,7,7,7,1,1,1,1,7,7,7,7,8,8,8,8,2,2,2,2
.byte 9,9,9,9,2,2,2,2,8,8,8,8,7,7,7,7,1,1,1,1,7,7,7,7,8,8,8,8,2,2,2,2
.byte 9,9,9,9,2,2,2,2,8,8,8,8,7,7,7,7,1,1,1,1,7,7,7,7,8,8,8,8,2,2,2,2

// Zmienne graficzne
raster_bar_pos: .byte 0
plasma_counter: .byte 0
logo_screen_ptr: .word 0
logo_color_ptr: .word 0
logo_data_ptr: .word 0
temp_row: .byte 0
border_index: .byte 0  // Indeks dla rysowania ramki 