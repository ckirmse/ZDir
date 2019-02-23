; Equates for status line messages

include   menu.inc

s1        equ       ET_close
s2        equ       ET_normal
s3        equ       ET_table
s4        equ       ET_color
s5        equ       ET_submenu
sr1       equ       ET_close   + not_root
sr2       equ       ET_normal  + not_root
sr3       equ       ET_table   + not_root
sr4       equ       ET_color   + not_root
sr5       equ       ET_submenu + not_root
s6        equ       last_ET+1
s7        equ       s6+1
s8        equ       s7+1
s9        equ       s8+1
s10       equ       s9+1
s11       equ       s10+1
s12       equ       s11+1
s13       equ       s12+1
s14       equ       s13+1
s15       equ       s14+1
