; Menu include file with definitions of menuing structures

ET_close        equ     0               ; to close all the menus and return
                                        ; with the return value

ET_normal       equ     1               ; to just call the handler with
                                        ; the return value

ET_table        equ     2               ; to scroll through the table pointed
                                        ; to by entry_data.  Format of the
                                        ; table is a byte table followed
                                        ; by a word pointing to the variable,
                                        ; followed by an array of words
                                        ; pointing to the associated strings

ET_color        equ     3               ; to pop up a color picker and
                                        ; pick the color pointed to by
                                        ; entry_data

ET_submenu      equ     4               ; if there is a submenu defined for
                                        ; this entry.  For use with status line

last_ET         equ     4               ; max # of ET_xxx

no_fast_char    equ     0               ; to have no fast_char

menu_quit       equ     0               ; if hit esc from a menu
menu_key        equ     1               ; if hit key that you said to quit
menu_choice     equ     2               ; if chose a selection

not_root  equ   80h
yes_root  equ   0

          menu_head           struc
          mwidth              db        ?
          mheight             db        ?
          mrow                dw        1       ; defaults for sub menus
          mcol                dw        2       ; to be in right spot
          max_choice          dw        ?
          current_choice      dw        1
          is_root             db        not_root
          win_handle          dw        STDWIN    ; means CLOSED
                              ends

          menu_entry          struc
          number              dw        ?
          disabled            db        0
          sub_menu            dw        0
          row                 db        ?
          return              db        0
          fast_char           db        ?
          entry_type          db        ET_normal
          entry_data          dw        ?
          status_line_num     db        0
                              ends

color_win_h         equ       20
color_win_w         equ       30

