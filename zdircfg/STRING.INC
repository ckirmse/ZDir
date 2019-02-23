; String include file with definitions of the string structure

include status.inc

.extrn  no_quit_key:word

no_leave_keys   equ     no_quit_key
init_info       equ     0

        string          struc
        string_len      db      ?               ; max length of string
        init_str        db      -1              ; if init stuff can be cleared
        leave_key_table dw      ?               ; table of keys to quit by
        string_status   db      s6              ; status line #, defaults to
                                                ; generic string info
        header_str      dw      0               ; ptr to str in string window
        string_space    dw      ?               ; ptr to the data area
                        ends

