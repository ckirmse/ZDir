;=============================================================================
;FILE:  menu.asm
;
;DESC:  complete menuing system
;
;NOTES:
;
;=============================================================================

include   model.inc
include   console.inc
include   window.inc
include   char.inc

include   menu.inc
include   status.inc

.codeseg  lib
;----------------------------------------------------------
; Declare external library functions here...
;----------------------------------------------------------
.extrn    cget_chr:auto
.extrn    near_malloc:auto, near_free:auto
.extrn    win_bufsize:auto, win_create:auto, win_remove:auto
.extrn    str_end:auto
.extrn    goto_xy:auto, cput_chri:auto
.extrn    set_attr:auto
.extrn    rel_xy:auto
.extrn    btbl_to_wptr:auto
.extrn    is_inbtbl:auto, index_byte:auto, xlat_byte:auto
.extrn    cput_stri:auto, cput_nchri:auto, str_len:auto
.extrn    update_off:auto, update_window:auto, update_on:auto
.extrn    clr_region:auto
.extrn    get_whandle:auto, where_xy:auto
.extrn    read_textattr:auto, write_textattr:auto
.extrn    mem_cpydi:auto
.extrn    win_select:auto
.ends

.codeseg
;----------------------------------------------------------
; Declare external program functions here...
;----------------------------------------------------------
.extrn    do_menu_item:auto
.extrn    error_memory:auto
.extrn    status_line:auto
.ends


.dataseg

.extrn    screen_rows:byte
;----------------------------------------------------------
; Declare external library and program data here...
;----------------------------------------------------------
;----------------------------------------------------------
; Declare local data here...
;----------------------------------------------------------

menu_win  window <,,,,yellow+16*blue,,,,,,yellow+16*blue,,,,,darkgray,,,>
color_win_bc        equ       16*blue             ; background color
color_win window <,,color_win_w,color_win_h,yellow or color_win_bc,,,,,,yellow or color_win_bc,,,,,darkgray,,WCURSOR_OFF,>
.public   color_win

color_test_str      db        "Sample",0

.public   cbox_proc
.public   cbox_proc_data
cbox_proc           dw        0         ; procedure it calls before wait key
cbox_proc_data      dw        0         ; used for ptr to menu to redraw "Sample"

cbox_cursor         db        "ÚÄÄÄ¿³   ³ÀÄÄÄÙ"
length_cbox_cursor  equ       $ - cbox_cursor

                    dw        cbox_key_actions
                    dw        8
cbox_keys           db        up_arrow,down_arrow,left_arrow,right_arrow
                    db        home_key,end_key,page_up,page_down
cbox_max_it         equ       20
cbox_zero_it        equ       21        ; arbitrary values
cbox_key_actions    db        0,-1      ; up arrow
                    db         0,1      ; down arrow
                    db        -1,0      ; left arrow
                    db         1,0      ; right arrow
                    db        cbox_zero_it,0      ; home
                    db        cbox_max_it,0       ; end
                    db        0,cbox_zero_it      ; page up
                    db        0,cbox_max_it       ; page down

menu_colors         label     byte
.public             menu_colors
disabled_c          db        ltgray+16*blue
disabled_current_c  db        darkgray
entry_c             db        yellow+16*blue
entry_current_c     db        yellow+16*magenta
fast_char_c         db        ltcyan+16*blue
fast_char_current_c db        ltcyan+16*magenta

                    dw        menu_functions
                    dw        4
menu_keys           db        up_arrow
                    db        down_arrow
                    db        page_up
                    db        page_down


menu_functions      dw        menu_up
                    dw        menu_down
                    dw        menu_page_up
                    dw        menu_page_down

menu_goto_ptr       dw        menu_goto           ; for fast chars


                    dw        0
no_quit_key         label     word                ; 0 length table
.public   no_quit_key

.ends

.dataseg?

cbox_buffer         label     byte      ; color box stuff
                    db        ?,?       ; dimensions
                    dw        15 dup (?); buffer

cbox_buffer_edit    label     byte
                    db        ?,?       ; dimensions
                    dw        15 dup (?); buffer

past_fast_char      db        ?
entry_char_c        db        ?
entry_fast_char_c   db        ?

.ends


;=============================================================================
;FUNC:  menu_system
;
;DESC:  Do the menu system on the top of the screen, plus pop up stuff
;
;IN:	
;
;OUT:	
;
;NOTES:	
;
;ALG:	
;=============================================================================

.codeseg

assume    cs:@codeseg, ds:@dataseg, es:nothing, ss:nothing

.public   one_menu
.proc     one_menu            auto
;----------------------------------------------------------
; pre : DS:SI -> a menu head structure, followed by menu entries
;       ES:DI -> table of keys to quit on
;       DS = ES = @dataseg

          .push     cx,dx,si,di
          mov       ax,[si].mrow
          mov       menu_win.w_top,ax
          mov       ax,[si].mcol
          mov       menu_win.w_left,ax
          mov       al,[si].mwidth
          mov       menu_win.w_width,al
          mov       al,[si].mheight
          mov       menu_win.w_height,al

          push      di

          push      si
          mov       si,offset @dataseg:menu_win
          call      win_bufsize
          jc        error_memory
          call      near_malloc
          jc        error_memory
          call      win_create
          jc        error_memory
          pop       si
          mov       [si].win_handle,bx

          pop       di                  ; has address of exit keys

          call      print_all_entries
menu_loop:
          ; first, print out the status line
          push      si
          mov       dx,[si].current_choice
          call      goto_entry
          mov       al,[si].entry_type  ; the entry_type is also a status type!
          pop       si
          add       al,[si].is_root
          call      status_line

          call      cget_chr
          je        menu_fast_char_check

          push      si
          mov       dx,[si].current_choice
          call      goto_entry
          mov       bx,si
          pop       si

          cmp       [bx].entry_type,menu_choice
          jne       menu_ignore_left_right

          cmp       al,right_arrow
          jne       menu_ext_key_not_right

          call      menu_increase
          jmp       menu_loop

menu_ext_key_not_right:

          cmp       al,left_arrow
          jne       menu_ext_key_not_left

          call      menu_decrease
          jmp       menu_loop

menu_ext_key_not_left:

menu_ignore_left_right:
          mov       bx,offset @dataseg:menu_keys
          call      btbl_to_wptr        ; get address of key handler
          jc        menu_quit_key_check

          call      move_bar_bx
          jmp       menu_loop

menu_quit_key_check:
          mov       bx,di               ; get address of quit key table
          call      is_inbtbl
          jc        menu_loop
          mov       ah,al
          mov       al,menu_key
          jmp       end_one_menu

menu_fast_char_check:
          cmp       al,escape_key
          jne       menu_not_esc
          mov       al,menu_quit
          jmp       end_one_menu
menu_not_esc:
          cmp       al,enter_key
          je        menu_enter
          cmp       al," "
          jne       menu_not_enter
menu_enter:
          push      si
          mov       dx,[si].current_choice
          call      goto_entry
          mov       bx,si
          pop       si

menu_selection:
          test      [bx].disabled,-1    ; hit enter on a disabled entry?
          jnz       menu_loop           ;  y: ignore it
          test      [bx].sub_menu,-1    ;  n: check for sub menus
          jz        menu_item_picked
          mov       ax,[bx].sub_menu
          call      do_sub_menu         ; go do the sub menu then!
          cmp       al,menu_quit        ; check if they hit escape
          .if e     menu_loop           ; if so, then continue here
          ; if menu_key or menu_choice, then quit just the same as sub menu
          ; menu_key should NEVER be returned from a sub menu
          jmp       end_one_menu
menu_item_picked:
          mov       al,menu_choice
          cmp       [bx].entry_type,ET_close
          jne       menu_not_close
          mov       al,[bx].return
          jmp       end_one_menu
menu_not_close:
          cmp       [bx].entry_type,ET_normal
          jne       menu_not_normal
          mov       al,[bx].return
          call      do_menu_item        ; does whatever was picked
          jmp       menu_loop           ; and then continue on
menu_not_normal:
          cmp       [bx].entry_type,ET_color
          jne       menu_not_color
          call      menu_pick_color
          jmp       menu_loop
menu_not_color:
          call      menu_increase
          jmp       menu_loop

menu_not_enter:
          ; search for fast_char
          mov       bx,si               ; save pointer to menu_head
          .to_upper al
          add       si,type menu_head
          mov       cx,1
          mov       dx,[bx].max_choice
          inc       dx                  ; max_choice + 1, if done
menu_find_fast_char:
          cmp       [si].fast_char,al
          je        menu_found_fast_char
          add       si,type menu_entry
          call      str_end
          inc       si
          inc       cx
          cmp       cx,dx
          jb        menu_find_fast_char
          mov       si,bx
          jmp       menu_loop
menu_found_fast_char:
          .push     bx,si
          cmp       [bx].current_choice,cx        ; see if already on the fast
          je        redrew_fast_char_entries      ; char'd entry, if so no redraw
          mov       si,bx
          mov       ch,cl               ; for the menu_goto procedure,
                                        ; it'll know what to set current_choice
          mov       bx,offset @dataseg:menu_goto_ptr
          call      move_bar_bx
redrew_fast_char_entries:
          .pop      si,bx               ; si -> menu_head,
                                        ; bx -> current menu_entry
          jmp       menu_selection      ; check if now return or if sub menu

end_one_menu:
          .push     ax,bx
          mov       bx,[si].win_handle
          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory
          .pop      ax,bx

          .pop      cx,dx,si,di
          ; al has return key
          ret
;----------------------------------------------------------
move_bar_bx:
; pre : bx has proc to call to actually move the current choice
;       ch has data to pass to procedures (if used, like menu_goto)

          .push     ax,bx,cx,dx,si
          ; now clear old entry
          mov       ax,bx               ; has address of proc to call
          mov       bx,si
          mov       dx,[bx].current_choice
          call      goto_entry
          mov       cl,[bx].mwidth
          xor       dx,dx               ; so this entry is NOT current
          call      print_one_entry     ; redraw old entry
          mov       si,bx
          mov       bx,ax
          call      w[bx]               ; change current_entry
          ; now highlight new entry
          mov       bx,si
          mov       dx,[bx].current_choice
          call      goto_entry
          mov       cl,[bx].mwidth
          call      print_one_entry
          .pop      ax,bx,cx,dx,si
          ret
;----------------------------------------------------------
menu_increase:
; pre : bx -> current entry
; post: current entry choice increased, printed

          call      next_menu_table
          push      si
          mov       dx,[si].current_choice
          mov       cl,[si].mwidth
          mov       si,bx               ; pointer to menu_entry
          call      print_one_entry     ; reprint changed entry
          pop       si
          ret
;----------------------------------------------------------
menu_decrease:
; pre : bx -> current entry
; post: current entry choice decreased, printed

          call      prev_menu_table
          push      si
          mov       dx,[si].current_choice
          mov       cl,[si].mwidth
          mov       si,bx               ; pointer to menu_entry
          call      print_one_entry     ; reprint changed entry
          pop       si
          ret
;----------------------------------------------------------
; menu key functions
; pre : si -> a menu_entry, ch has any info needed (like entry to go to,
;       found from fast_char)
menu_up:
          push      ax
          dec       [si].current_choice
          test      [si].current_choice,-1
          jnz       end_menu_up
          mov       ax,[si].max_choice
          mov       [si].current_choice,ax
end_menu_up:
          pop       ax
          ret

menu_down:
          push      ax
          inc       [si].current_choice
          mov       ax,[si].max_choice
          inc       ax
          cmp       [si].current_choice,ax
          jne       end_menu_down
          mov       [si].current_choice,1
end_menu_down:
          pop       ax
          ret

menu_page_up:
          mov       [si].current_choice,1
          ret

menu_page_down:
          push      ax
          mov       ax,[si].max_choice
          mov       [si].current_choice,ax
          pop       ax
          ret

menu_goto:
          push      ax
          mov       al,ch
          xor       ah,ah
          mov       [si].current_choice,ax
          pop       ax
          ret
;----------------------------------------------------------
do_sub_menu:
; pre : ax has address of the sub menu, si has address of this menu

          .push     cx,dx,si,di

          mov       bx,si
          mov       si,ax

          .push      [si].mrow,[si].mcol

          mov       cx,[bx].mcol
          mov       ax,[bx].mrow
          mov       dx,[bx].current_choice
          add       [si].mrow,ax
          add       [si].mrow,dx
          add       [si].mcol,cx

          mov       di,offset @dataseg:no_quit_key
          call      one_menu

          .pop       [si].mrow,[si].mcol

          .pop      cx,dx,si,di
          ret
;----------------------------------------------------------
.endp     one_menu

.public   next_menu_table
.proc     next_menu_table               auto
;----------------------------------------------------------
next_menu_table:
; pre : ds:bx -> a menu_entry structure of type ET_table

          .push     ax,bx,cx,si
          mov       bx,[bx].entry_data  ; pointer to byte table
          mov       cx,w[bx-2]          ; has # of entries
          mov       si,bx
          add       si,cx               ; points to the pointer to data
          mov       si,[si]             ; si -> the byte data
          mov       al,[si]             ; the actual data
          call      index_byte          ; search for data
          jnc       menu_table_found    ; if found data in table
          xor       ax,ax               ; means first entry in index table
menu_table_found:
          inc       ax                  ; go to next entry
          cmp       ax,cx               ; if rollover
          jne       menu_table_no_rollover
          xor       ax,ax               ; then restart
menu_table_no_rollover:
          call      xlat_byte           ; get the value from the index
          mov       [si],al             ; store in variable

          .pop      ax,bx,cx,si

          ret
;----------------------------------------------------------
.endp     next_menu_table

.public   prev_menu_table
.proc     prev_menu_table               auto
;----------------------------------------------------------
prev_menu_table:
; pre : ds:bx -> a menu_entry structure of type ET_table

          .push     ax,bx,cx,si
          mov       bx,[bx].entry_data  ; pointer to byte table
          mov       cx,w[bx-2]          ; has # of entries
          mov       si,bx
          add       si,cx               ; points to the pointer to data
          mov       si,[si]             ; si -> the byte data
          mov       al,[si]             ; the actual data
          call      index_byte          ; search for data
          jnc       prev_menu_1         ; if found data in table
          xor       ax,ax               ; means first entry in index table
prev_menu_1:
          dec       ax                  ; go to prev entry
          cmp       ax,-1               ; if rollover
          jne       prev_menu_2
          mov       ax,cx
          dec       ax
prev_menu_2:
          call      xlat_byte           ; get the value from the index
          mov       [si],al             ; store in variable

          .pop      ax,bx,cx,si

          ret
;----------------------------------------------------------
.endp     prev_menu_table

.public   menu_pick_color
.proc     menu_pick_color               auto
;----------------------------------------------------------
menu_pick_color:
; pre : ds:bx -> a menu_entry structure of type ET_color
;       ds:si -> a menu_head structure containing this entry

          .push     ax,bx,cx,dx

          xor       ah,ah
          mov       al,[bx].row         ; rows down in menu
          add       ax,[si].mrow        ; + top of menu - 1
          add       ax,2                ; one row below current row
          mov       dl,screen_rows
          xor       dh,dh
          sub       dx,color_win_h + 2  ; + 2 for shadow, status line
          cmp       ax,dx
          jb        color_top_ok
          mov       ax,dx               ; don't go off screen
color_top_ok:
          mov       color_win.w_top,ax
          mov       ax,[si].mcol        ; left of menu
          add       ax,2                ; 2 columns more
          mov       color_win.w_left,ax

          mov       cbox_proc,offset @codeseg:redraw_sample
          mov       cbox_proc_data,si   ; needs the menu_head ptr
          mov       al,[bx].return      ; ensure diff fore/back or not
          mov       bx,[bx].entry_data  ; ptr to color
          mov       dl,[bx]             ; the actual color
          and       dl,not blink
          call      color_box

          test      al,al               ; if need to ensure diff fore/back
          jz        save_color

          mov       al,dl
          mov       ah,dl
          mov       cl,4
          shr       ah,cl
          and       al,00001111B
          cmp       al,ah
          je        saved_color
save_color:
          mov       [bx],dl
saved_color:
          mov       dl,[bx]
          call      redraw_sample       ; in case color_box choice overruled

          .pop      ax,bx,cx,dx
          ret
;----------------------------------------------------------
.endp     menu_pick_color

.public   redraw_sample
.proc     redraw_sample       auto
;----------------------------------------------------------
;pre : dl has the color

          .push     ax,bx,cx,dx,si,di

          xor       ax,ax               ; current window
          call      get_whandle         ; get its handle
          push      bx                  ; and save

          mov       si,cbox_proc_data   ; has the menu_head ptr
          mov       bx,[si].win_handle
          call      win_select

          xor       al,al
          mov       al,[si].mwidth
          call      goto_xy             ; goto end of entry's row

          push      dx
          mov       dx,[si].current_choice
          call      goto_entry          ; si -> current entry
          pop       dx

          mov       ah,[si].row
          mov       si,offset @dataseg:color_test_str
          call      str_len
          mov       al,cl
          neg       al                  ; go back this many
          sub       al,3                ; and one more for space, + 2 for borders
          call      rel_xy              ; goto the entry's row
          mov       ah,dl
          call      set_attr
          call      cput_stri

          call      update_window       ; bx set already to the handle

          pop       bx
          call      win_select

          .pop      ax,bx,cx,dx,si,di

          ret
;----------------------------------------------------------
.endp     redraw_sample

.public   color_box
.proc     color_box           auto
;----------------------------------------------------------
;pre : dl has the color to use/abuse, color_win setup
;post: dl has the chosen color

          .push     ax,bx,cx,si,di

          mov       dh,dl               ; backup in case hit escape

          mov       si,offset @dataseg:color_win
          call      win_bufsize
          jc        error_memory
          call      near_malloc
          jc        error_memory
          call      update_off
          call      win_create
          jc        error_memory
          push      bx                  ; color window handle

color_box_loop:
          call      update_off
          call      clr_region          ; blank out outside area especially

          mov       ax,0102h            ; row 1 column 2
          call      goto_xy
          xor       ah,ah               ; current attribute

          mov       cx,8                ; 8 background colors

each_column_color:
          call      set_attr

          mov       al," "
          call      cput_chri
          mov       al,"þ"
          call      cput_chri
          mov       al," "
          call      cput_chri
          push      ax
          mov       al,-3
          mov       ah,1
          call      rel_xy              ; move to next spot
          pop       ax
          inc       ah
          test      ah,00001111B        ; see if mod 16
          jnz       each_column_color

          push      ax
          mov       al,3
          mov       ah,-16
          call      rel_xy              ; move to top of next column
          pop       ax
          loop      each_column_color


each_cbox_keypress:
          ; draw current box
          mov       ax,0102h            ; row 1 column 2
          call      goto_xy
          mov       ah,white
          call      set_attr
          mov       al,dl
          mov       cl,4
          shr       al,cl
          and       al,00000111B        ; take out the blink bit
          mov       bl,al
          add       al,bl
          add       al,bl               ; al*3 for background
          mov       ah,dl
          and       ah,00001111B        ; all foregrounds
          call      rel_xy
          mov       ax,0FFFFh           ; -1, -1
          call      rel_xy


          push      dx
          call      where_xy
          mov       dx,ax               ; current spot is top left
          mov       di,offset @dataseg:cbox_buffer
          mov       ax,0305h            ; 3 high, 5 wide
          call      read_textattr       ; read in screen info
          mov       si,offset @dataseg:cbox_buffer_edit
          mov       cx,(1+3*5)*2        ; (1 dim + rows x cols) x 2 bytes/char
          call      mem_cpydi           ; copy from es:di to ds:si
          pop       dx

          mov       di,si
          push      di                  ; di -> edited buffer

          add       di,2                ; point to data area
          mov       cx,length_cbox_cursor
          mov       si,offset @dataseg:cbox_cursor

each_cbox_cursor_char:
          lodsb
          cmp       al," "
          je        skip_cbox_cursor_char
          mov       b[di],al
          or        b[di+1],white         ; turn on foreground
skip_cbox_cursor_char:
          add       di,2                ; next char
          loop      each_cbox_cursor_char

          pop       di                  ; di -> edited buffer

          push      dx
          call      where_xy
          mov       dx,ax               ; current spot is top left
          mov       ax,w[di]            ; get dimensions
          call      write_textattr
          pop       dx

          xor       ax,ax
          call      get_whandle         ; get handle of current window
          call      update_window       ; draw it on the screen

          mov       bx,cbox_proc        ; procedure to call 'tween each key
          test      bx,bx
          jz        no_cbox_proc
          call      bx
no_cbox_proc:
          mov       al,s9               ; status of a color box
          call      status_line         ; print status line

          ; redraw over old cursor first (but not to screen, update off)
          push      dx
          call      where_xy
          mov       dx,ax               ; current spot is top left
          mov       di,offset @dataseg:cbox_buffer
          mov       ax,w[di]            ; get dimensions
          call      write_textattr
          pop       dx

          call      cget_chr
          je        check_quit_cbox_loop
          ; split dl into foreground and background, change,
          ; and put back into dl

          mov       bh,dl
          and       bh,00001111B        ; foreground in bh
          mov       bl,dl
          mov       cl,4
          shr       bl,cl
          and       bl,00000111B        ; background in bl

          mov       cx,bx               ; store for a sec
          mov       bx,offset @dataseg:cbox_keys
          call      btbl_to_wptr
          jc        done_cbox_key
          mov       bx,w[bx]
          ; bx has values to add to cx
          cmp       bl,cbox_max_it
          jne       cbox_1
          mov       cl,7                ; max background
          jmp       cbox_3
cbox_1:
          cmp       bl,cbox_zero_it
          jne       cbox_2
          xor       cl,cl
          jmp       cbox_3
cbox_2:
          add       cl,bl

cbox_3:                       ; do the foreground now
          cmp       bh,cbox_max_it
          jne       cbox_4
          mov       ch,15               ; max foreground
          jmp       cbox_6
cbox_4:
          cmp       bh,cbox_zero_it
          jne       cbox_5
          xor       ch,ch
          jmp       cbox_6
cbox_5:
          add       ch,bh
cbox_6:

done_cbox_key:
          and       cl,00000111B
          mov       dl,cl
          mov       cl,4
          shl       dl,cl
          and       ch,00001111B
          or        dl,ch
          jmp       each_cbox_keypress

check_quit_cbox_loop:
          cmp       al,enter_key
          je        quit_cbox
          cmp       al," "
          je        quit_cbox
          cmp       al,escape_key
          .ifne     each_cbox_keypress
          mov       dl,dh               ; escape means old color

quit_cbox:
          call      update_on
          pop       bx                  ; color window handle
          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory

          mov       bx,cbox_proc        ; procedure to call 'tween each key
          test      bx,bx
          jz        no_cbox_proc_quit
          call      bx
no_cbox_proc_quit:
          and       cbox_proc,0

          .pop      ax,bx,cx,si,di
          ret
;----------------------------------------------------------
.endp     color_box

.public   print_all_entries
.proc     print_all_entries             auto
;----------------------------------------------------------
; pre : ds:si -> a menu_head structure

          .push     ax,bx,cx,dx,si,di
          mov       cx,[si].max_choice
          mov       dx,[si].current_choice
          mov       bl,[si].mwidth
          add       si,type menu_head

each_print_entry:
          push      cx
          mov       cl,bl               ; width of menu
          call      print_one_entry
          add       si,type menu_entry
          call      str_end
          inc       si
          pop       cx
          loop      each_print_entry

          .pop      ax,bx,cx,dx,si,di
          ret
;----------------------------------------------------------
.endp     print_all_entries


.public   print_one_entry
.proc     print_one_entry               auto
;----------------------------------------------------------
; pre : ds:si -> a menu_entry structure, dx has the current_choice
;       and cl has the width of the menu!!!

          .push     ax,bx,cx,dx,si,di

          xor       al,al
          mov       ah,[si].row
          call      goto_xy
          mov       bx,si               ; when we need to still access this
                                        ; structure

          cmp       [bx].number,dx
          jne       not_current

          test      [bx].disabled,-1
          jz        just_current

          mov       al,disabled_current_c
          mov       ah,al
          jmp       colors_in_ax

just_current:
          mov       al,fast_char_current_c
          mov       ah,entry_current_c
          jmp       colors_in_ax

not_current:
          test      [bx].disabled,-1
          jnz       just_disabled

          mov       al,fast_char_c
          mov       ah,entry_c
          jmp       colors_in_ax

just_disabled:
          mov       al,disabled_c
          mov       ah,al

colors_in_ax:
          mov       entry_char_c,ah
          mov       entry_fast_char_c,al

          call      set_attr            ; color in ah

          and       past_fast_char,0

          add       si,type menu_entry
          xor       ch,ch               ; cl has width of menu
          sub       cx,3                ; 2 for border, 1 for initial space
          mov       al," "              ; initial space
          call      cput_chri
one_entry_char:
          jcxz      check_sub_menu      ; out of space in window
          lodsb
          test      al,al
          jz        check_sub_menu
          dec       cx                  ; keep track how many chars left
          test      past_fast_char,-1   ; to print
          jnz       do_normal_char
          mov       ah,al
          .to_upper ah
          cmp       ah,[bx].fast_char
          je        do_fast_char
do_normal_char:
          call      cput_chri
          jmp       one_entry_char

do_fast_char:
          or        past_fast_char,-1
          mov       ah,entry_fast_char_c
          call      set_attr
          call      cput_chri
          mov       ah,entry_char_c
          call      set_attr
          jmp       one_entry_char

check_sub_menu:
          cmp       [bx].entry_type,ET_table
          jne       not_table_print_entry

          mov       bx,[bx].entry_data            ; bx -> byte table
          mov       di,bx                         ; di -> byte table
          add       di,w[bx-2]                    ; go past byte table
          mov       di,[di]                       ; di -> var
          mov       al,[di]                       ; al has the variable
          call      index_byte
          jnc       print_entry_in_table          ; if found
          xor       ax,ax                         ; default to first choice
print_entry_in_table:
          add       bx,[bx-2]
          add       bx,2                          ; bx -> string ptr table
          shl       ax,1                          ; convert byte index to word
          add       bx,ax                         ; go to the correct ptr
          mov       si,[bx]                       ; si -> string
          mov       bx,cx                         ; store spaces left
          call      str_len                       ; get length of string
          sub       bx,cx                         ; how many spaces to print
          mov       cx,bx
          dec       cx                            ; leave one space at end
          mov       al," "
          call      cput_nchri
          call      cput_stri
          call      cput_chri                     ; print one space at end
          jmp       end_one_entry


not_table_print_entry:
          cmp       [bx].entry_type,ET_color
          jne       not_color_print_entry

          mov       si,offset @dataseg:color_test_str
          mov       dx,cx
          call      str_len
          sub       dx,cx
          mov       cx,dx                         ; cx has # of spaces to print
          dec       cx                            ; leave a space at end
          dec       cx                            ; one space before it is
                                                  ; the normal color, even with
                                                  ; cursor
          mov       al," "
          call      cput_nchri
          mov       ah,entry_c
          call      set_attr
          call      cput_chri
          mov       bx,[bx].entry_data            ; bx -> color
          mov       ah,[bx]
          call      set_attr
          call      cput_stri

          jmp       end_one_entry

not_color_print_entry:
          ; new entry types added here

          cmp       [bx].return,0
          je        menu_all_spaces
          test      [bx].sub_menu,-1
          jnz       menu_all_spaces     ; sub menu means return never happens
          mov       al,"."
          push      cx
          mov       cx,3
          call      cput_nchri
          pop       cx
          cmp       cx,3
          jbe       finished_spaces
          sub       cx,3
menu_all_spaces:
          jcxz      finished_spaces
          mov       al," "
          call      cput_nchri
finished_spaces:
          test      [bx].sub_menu,-1
          jz        no_sub_menu
          xor       ah,ah
          mov       al,-2               ; move back two cols
          call      rel_xy
          mov       al,""
          call      cput_chri
          mov       al," "
          call      cput_chri
          jmp       end_one_entry
no_sub_menu:

end_one_entry:

          .pop      ax,bx,cx,dx,si,di
          ret
;----------------------------------------------------------
.endp     print_one_entry

.public   goto_entry
.proc     goto_entry                    auto
;----------------------------------------------------------
; pre : ds:si -> a menu_head structure, dx has num of entry
;       to set si to the menu_entry of

          push      dx

          add       si,type menu_head
each_goto_entry:
          dec       dx
          test      dx,dx
          jz        end_goto_entry
          add       si,type menu_entry
          call      str_end
          inc       si
          jmp       each_goto_entry

end_goto_entry:
          pop       dx
          ret
;----------------------------------------------------------
.endp     goto_entry

;----------------------------------------------------------
; Declare additional functions here...
;----------------------------------------------------------

.ends

          end
