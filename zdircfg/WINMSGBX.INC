; Definitions for win_msg_box-es

; a wmb is a window message box, displayed by win_msg_box

error_color         equ       white + 16*red
normal_color        equ       yellow + 16*blue

wmb_key_quit        equ       0
wmb_leave           equ       1                   ; leave wmb on the screen
wmb_quit_conditions equ       1                   ; <= this means quit

wmb_n               equ       2
wmb_i               equ       3
wmb_ic              equ       4

wmb_str   struc
          print_proc db       ?
          string_ptr dw       ?
          ends

