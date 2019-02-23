;=============================================================================
;FILE:  string.asm
;
;DESC:  get string functions
;
;NOTES:
;
;=============================================================================

include   model.inc
include   console.inc
include   window.inc
include   string.inc

.codeseg lib
.extrn    cget_chr:auto
.extrn    near_malloc:auto, near_free:auto
.extrn    win_bufsize:auto, win_create:auto, win_remove:auto
.extrn    str_end:auto, where_xy:auto
.extrn    goto_xy:auto, cput_chri:auto,cput_nchri:auto
.extrn    update_off:auto, update_window:auto, update_on:auto
.extrn    update_cursor:auto
.extrn    set_attr:auto
.extrn    rel_xy:auto,get_whandle:auto
.extrn    str_len:auto,cput_stri:auto,cget_chr:auto
.extrn    btbl_to_wptr:auto,str_cpy:auto
.extrn    set_cursor:auto, is_inbtbl:auto
.extrn    wborder_on:auto, wborder_off:auto
;----------------------------------------------------------
; Declare external library functions here...
;----------------------------------------------------------
.ends

.codeseg
.extrn    error_memory:auto
.extrn    status_line:auto
.ends

.dataseg
;----------------------------------------------------------
; Declare external library and program data here...
;----------------------------------------------------------
text_init_color     db        yellow+16*magenta
text_color          db        yellow+16*blue

str_win   window <,,,3,yellow+16*blue,,,,,,yellow+16*blue,,,,,darkgray,,wcursor_on>

str_ptr             dw        ?
str_cursor          dw        ?
str_init            db        ?
str_insert          db        -1

str_length          db        ?
str_data            db        80 dup (?)

str_home_position   dw        ?

                    dw        str_key_actions
                    dw        6
str_keys            db        left_arrow,right_arrow,home_key,end_key
                    db        delete_key,insert_key
str_key_actions     dw        str_do_left,str_do_right,str_do_home,str_do_end
                    dw        str_do_delete,str_do_insert



;----------------------------------------------------------
; Declare local data here...
;----------------------------------------------------------
.ends


;=============================================================================
;FUNC:  string_window
;
;DESC:  in a window get a string
;
;IN:    ax = row, bx = col of window, ds:si -> the string
;
;OUT:   the string is entered, Carry flag if escaped
;
;NOTES:	
;
;ALG:	
;=============================================================================

.codeseg

assume  cs:@codeseg, ds:@dataseg, es:nothing, ss:nothing

.public   string_window
.proc     string_window       auto
;----------------------------------------------------------

          .push     ax,bx,cx,dx,si,di

          mov       str_win.w_top,ax
          mov       str_win.w_left,bx
          xor       ch,ch
          mov       cl,[si].string_len            ; the max length of string
          add       cx,4
          mov       str_win.w_width,cl

          call      update_off

          push      si
          mov       si,offset @dataseg:str_win
          call      win_bufsize
          jc        error_memory
          call      near_malloc
          jc        error_memory
          call      win_create
          jc        error_memory
          pop       si

          test      [si].header_str,-1
          jz        did_header_str

          push      si
          call      wborder_on
          mov       ax,0001h
          call      goto_xy
          mov       si,[si].header_str
          call      cput_stri
          call      wborder_off
          pop       si

did_header_str:
          mov       ax,0001h
          call      goto_xy

          push      bx
          xor       ax,ax
          call      get_whandle         ; get handle of current window
          call      update_window
          call      string_input
          pop       bx

          pushf

          call      update_on

          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory

          .popf

          .pop      ax,bx,cx,dx,si,di

          ret
;----------------------------------------------------------
.endp     string_window



.public   string_input
.proc     string_input        auto
;----------------------------------------------------------
; pre : cursor at place to input string, ds:si -> string
; post: carry flag set -> al has key
;       carry flag cleared -> data entered

          .push     bx,cx,dx,si,di

          mov       str_ptr,si

          mov       al,[si].string_len
          mov       str_length,al

          mov       si,[si].string_space
          mov       di,offset @dataseg:str_data
          call      str_cpy

          mov       si,offset @dataseg:str_data

          call      where_xy
          mov       str_home_position,ax

          mov       dl,b[si-1]
          xor       dh,dh
          dec       dx
          call      str_len
          cmp       cx,dx
          jbe       str_cursor_ok
          dec       cx
str_cursor_ok:
          mov       str_cursor,cx

          mov       al,b[si]
          mov       bx,str_ptr
          and       al,[bx].init_str
          mov       str_init,al         ; if zero, no init string

str_key_loop:
          mov       ax,str_home_position
          call      goto_xy

          cmp       str_init,0
          jz        str_normal_print

          mov       ah,text_init_color
          call      set_attr
          call      cput_stri
          jmp       str_printed

str_normal_print:
          mov       ah,text_color
          call      set_attr
          call      cput_stri

str_printed:
          mov       ah,text_color
          call      set_attr
          xor       dh,dh
          mov       dl,b[si-1]
          call      str_len
          sub       dx,cx
          mov       cx,dx               ; has spaces to print
          mov       al," "
          call      cput_nchri

          mov       ax,str_home_position
          add       ax,str_cursor       ; ah = 0 = row
          call      goto_xy

          mov       ax,block_cursor
          cmp       str_insert,0
          jz        str_not_insert
          mov       ax,default_cursor
str_not_insert:
          call      set_cursor

          xor       ax,ax
          call      get_whandle         ; get handle of current window
          call      update_window       ; draw it on the screen
          call      update_cursor       ; on screen set cursor

          mov       bx,str_ptr
          mov       al,[bx].string_status
          call      status_line

          call      cget_chr
          jnc       str_char_hit

          mov       bx,offset @dataseg:str_keys
          call      btbl_to_wptr
          jc        str_ext_key

          and       str_init,0

          call      [bx]
          jmp       str_key_loop
str_ext_key:
          mov       bx,str_ptr
          mov       bx,[bx].leave_key_table
          call      is_inbtbl
          .if c     str_key_loop

          call      save_string

          jmp       quit_string_input

str_char_hit:
          cmp       al,enter_key
          je        save_string_input

          cmp       al,escape_key
          je        quit_string_input

          cmp       al,backspace_key
          jne       str_not_backspace

          and       str_init,0

          mov       ax,str_cursor
          call      str_do_left
          cmp       ax,str_cursor
          .if e     str_key_loop        ; if left didn't move it

          call      str_do_delete

          jmp       str_key_loop

str_not_backspace:
          cmp       al,tab_key
          .if e str_key_loop

          call      str_do_char

          jmp       str_key_loop

save_string_input:

          call      save_string

          clc
          jmp       end_string_input
quit_string_input:
          stc

end_string_input:

          pushf
          push      ax
          mov       ax,default_cursor
          call      set_cursor
          pop       ax
          .popf

          .pop      bx,cx,dx,si,di

          ret
;----------------------------------------------------------
.endp     string_input

;----------------------------------------------------------
save_string:
; pre : str_ptr -> a string structure
; post: string moved from the string data to the structure

          .push     ax,si,di

          mov       di,str_ptr
          mov       al,str_length
          mov       [di].string_len,al
          mov       si,offset @dataseg:str_data
          mov       di,[di].string_space
          call      str_cpy

          .pop      ax,si,di
          ret
;----------------------------------------------------------

;----------------------------------------------------------
str_do_left:

          cmp       str_cursor,0
          je        end_str_do_left
          dec       str_cursor

end_str_do_left:
          ret
;----------------------------------------------------------

;----------------------------------------------------------
str_do_right:

          call      str_len
          cmp       str_cursor,cx
          je        end_str_do_right
          mov       cl,b[si-1]          ; max str len
          xor       ch,ch
          dec       cx                  ; from length (1-xx) to cursor (0-xx)
          cmp       str_cursor,cx
          je        end_str_do_right

          inc       str_cursor

end_str_do_right:

          ret
;----------------------------------------------------------

;----------------------------------------------------------
str_do_home:

          and       str_cursor,0

          ret
;----------------------------------------------------------

;----------------------------------------------------------
str_do_end:

          mov       al,b[si-1]
          xor       ah,ah
          dec       ax

          call      str_len
          cmp       cx,ax
          jb        str_end_past
          dec       cx
str_end_past:
          mov       str_cursor,cx

          ret
;----------------------------------------------------------

;----------------------------------------------------------
str_do_delete:

          cmp       b[si],0                       ; if empty string
          jz        end_str_do_delete

          add       si,str_cursor
          mov       di,si
          inc       si
          call      str_cpy   ; move it back one

          mov       si,offset @dataseg:str_data
end_str_do_delete:

          ret
;----------------------------------------------------------

;----------------------------------------------------------
str_do_insert:

          not       str_insert

          ret
;----------------------------------------------------------

;----------------------------------------------------------
str_do_char:

          cmp       str_init,0
          je        str_no_kill_init
          and       str_init,0
          and       b[si],0             ; kill the init string
          call      str_do_home         ; and move cursor to left
str_no_kill_init:
          cmp       str_insert,0
          jnz       str_char_insert
          .push     cx,si
          mov       cx,si
          add       cx,str_cursor
          call      str_end
          cmp       cx,si
          .pop      cx,si
          je        str_char_insert
          add       si,str_cursor
          mov       b[si],al
          jmp       end_str_do_char
str_char_insert:
          mov       cl,b[si-1]
          xor       ch,ch
          mov       dx,str_cursor
          inc       dx
          cmp       cx,dx
          jne       str_not_at_end
          add       cx,si
          dec       cx
          call      str_end
          cmp       cx,si
          je        str_not_at_end
          mov       b[si-1],al
          jmp       end_str_do_char

str_not_at_end:
          mov       bx,offset @dataseg:str_data
          add       bx,str_cursor
          add       cx,si
          call      str_end
          cmp       si,cx               ; see if last char is extant
          jne       str_char_move
          sub       si,2                ; to not lengthen string!!!
str_char_move:
          mov       ah,b[si]
          mov       b[si+1],ah
          cmp       si,bx
          je        str_chars_moved
          dec       si
          jmp       str_char_move

str_chars_moved:
          mov       b[si],al

end_str_do_char:
          mov       si,offset @dataseg:str_data

          call      str_do_right

          ret
;----------------------------------------------------------

;----------------------------------------------------------
; Declare additional functions here...
;----------------------------------------------------------

.ends

        end
