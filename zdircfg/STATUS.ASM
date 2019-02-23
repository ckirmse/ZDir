;=============================================================================
;FILE:  status.asm
;
;DESC:  function to display the status line
;
;NOTES:
;
;=============================================================================

include   model.inc
include   console.inc
include   window.inc
include   char.inc
include   status.inc

.codeseg lib
.extrn    near_malloc:auto, near_free:auto
.extrn    win_bufsize:auto, win_create:auto, win_remove:auto
.extrn    goto_xy:auto, cput_chri:auto
.extrn    set_attr:auto
.extrn    rel_xy:auto
.extrn    btbl_to_wptr:auto
.extrn    cput_str:auto,cput_stri:auto, cput_nchri:auto, str_len:auto
.extrn    update_off:auto, update_window:auto, update_on:auto
.extrn    update_cursor:auto
.extrn    clr_region:auto
.extrn    get_whandle:auto, where_xy:auto
.extrn    div_wb:auto
.extrn    cursor_on:auto, cursor_off:auto
.extrn    screen_bufsize:auto
.extrn    save_screen:auto,restore_screen:auto
.extrn    win_select:auto
.extrn    is_inbtbl:auto,to_upper:auto
.extrn    cput_strci:auto,cput_newline:auto
.extrn    str_cpy:auto
.extrn    get_wspec:auto
.extrn    get_attr:auto
;----------------------------------------------------------
; Declare external library functions here...
;----------------------------------------------------------
.ends


.codeseg
;----------------------------------------------------------
; Declare external program functions here...
;----------------------------------------------------------
.ends


.dataseg

.extrn    screen_rows:byte

.extrn    backbuf:word
;----------------------------------------------------------
; Declare external library and program data here...
;----------------------------------------------------------

status_color        db        yellow+16*blue      ; status color 1
                    db        ltcyan+16*blue      ; status color 2
                    db        white+16*magenta    ; status color 3

status_colors       equ       3

                    dw        status_strings
                    dw        21
status_table        db        s1,s2,s3,s4,s5,sr1,sr2,sr3,sr4,sr5
                    db        s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15
status_strings      dw        s1str,s2str,s3str,s4str,s5str
                    dw        s1str,sr2str,s3str,s4str,sr5str
                    dw        s5str,s6str,s7str,s8str,s9str,s10str,s11str
                    dw        s12str,s13str,s14str,s15str

s1str     db        " ",2,"Esc ды",1,"-Quit ZDircfg "
          db            2," ",1,"-Move cursor"
          db        0
s2str     db        " ",2,"Esc",1,"-Quit ZDircfg "
          db            2," ",1,"-Move cursor "
          db            2,"ды",1,"-Select current choice"
          db        0
sr2str    db        " ",2,"Esc",1,"-Previous menu "
          db            2," ",1,"-Move cursor "
          db            2,"ды",1,"-Select current choice"
          db        0
s3str     db        " ",2,"Esc",1,"-Previous menu "
          db            2," ",1,"-Move cursor "
          db            2," ",1,"-Increase/decrease option"
          db        0
s4str     db        " ",2,"Esc",1,"-Previous menu "
          db            2," ",1,"-Move cursor "
          db            2,"ды",1,"-Edit color"
          db        0
s5str     db        " ",2,"Esc",1,"-Quit ZDircfg "
          db            2," ",1,"-Move cursor "
          db            2,"ды",1,"-Goto submenu"
          db        0
sr5str    db        " ",2,"Esc",1,"-Previous menu "
          db            2," ",1,"-Move cursor "
          db            2,"ды",1,"-Goto submenu"
          db        0
s6str     db        " ",2,"Esc",1,"-Previous menu "
          db            2," ",1,"-Move cursor "
          db            2,"ды",1,"-Accept string "
          db            2,"дд Del",1,"-Delete char "
          db            2,"Ins"
          db        0
s7str     db        " ",2,"Esc",1,"-Previous menu "
          db            2,"   ",1,"-Move cursor "
          db            2,"ды",1,"-Edit color "
          db            2,"A..Z",1,"-Edit extension"
          db        0
s8str     db        " ",2,"Esc",1,"-Previous menu "
          db            2,"   ",1,"-Move cursor "
          db            2,"ды",1,"-Toggle Ш"
          db        0
s9str     db        " ",2,"Esc",1,"-Use original color "
          db            2,"   ",1,"-Move cursor "
          db            2,"ды",1,"-Accept color"
          db        0
s10str    db        " ",2,"Any key",1,"-Continue"
          db        0
s11str    db        " ",2,"Esc",1,"-Previous menu "
          db            2," ",1,"-Move cursor "
          db            2,"ды",1,"-Accept name "
          db            2,"дд Del",1,"-Delete char "
          db            2,"Ins"
          db        0
s12str    db        " ",2,"Esc",1,"-Previous menu "
          db            2," ",1,"-Move cursor "
          db            2,"ды",1,"-Accept reg info "
          db            2,"дд Del",1,"-Delete char "
          db            2,"Ins"
          db        0
s13str    db        " ",2,"Esc",1,"-Previous menu "
          db            2," ",1,"-Move cursor "
          db            2," ",1,"-Increase/decrease range "
          db            2,"- +",1,"-Step by 10"
          db        0
s14str    db        " ",2,"Esc N",1,"-Previous menu "
          db            2,"Y",1,"-Quit ZDircfg"
          db        0
s15str    db        " ",2,"Esc N",1,"-Previous menu "
          db            2,"Y",1,"-Load ZDir configuration"
          db        0
.ends


;=============================================================================
;FUNC:  status_line
;
;DESC:  displays the status line
;
;IN:    al has the number of the status message to display
;
;OUT:   none
;
;NOTES:	
;
;ALG:	
;=============================================================================

.codeseg

assume  cs:@codeseg, ds:@dataseg, es:nothing, ss:nothing

.public   status_line
.proc     status_line         auto
;----------------------------------------------------------
          .push     ax,bx,cx,dx,si,di

          call      get_attr
          push      ax

          push      ax
          xor       ax,ax
          call      get_whandle
          pop       ax

          push      bx

          mov       bx,stdwin
          call      win_select          ; write to the main screen

          push      ax
          mov       ah,screen_rows
          dec       ah
          xor       al,al
          call      goto_xy
          pop       ax

          mov       bx,offset @dataseg:status_table
          call      btbl_to_wptr
          jc        end_status_line
          mov       si,[bx]

          mov       ah,status_color[0]
          mov       cx,80
each_status_char:
          lodsb
          test      al,al
          jz        end_status_line
          cmp       al,status_colors
          ja        status_do_char
          dec       al
          mov       bl,al
          xor       bh,bh
          mov       ah,status_color[bx]
          jmp       each_status_char
status_do_char:
          dec       cx
          call      put_screen_char
          jmp       each_status_char

end_status_line:
          mov       ah,status_color[0]
          mov       al," "
          jcxz      done_status_end_spaces
status_end_spaces:
          call      put_screen_char
          loop      status_end_spaces
done_status_end_spaces:
          pop       bx
          call      win_select

          pop       ax
          call      set_attr

          .pop      ax,bx,cx,dx,si,di
          ret
;----------------------------------------------------------
.endp     status_line

;----------------------------------------------------------
put_screen_char:
; pre : ah has color, al has char
; post: char printed on screen and in screen buffer

          .push     ax,bx,cx,dx,si,di

          mov       bx,ax


          mov       di,backbuf
          add       di,16               ; first 16 bytes are header
          call      where_xy
z:
          mov       cl,al
          xor       ch,ch
          shl       cx,1                ; bytes per column
          mov       al,160              ; bytes per row
          mul       ah
          add       ax,cx
          add       di,ax
          mov       w[di],bx

          mov       ax,bx

          call      set_attr
          call      cput_chri

          .pop      ax,bx,cx,dx,si,di

          ret
;----------------------------------------------------------

;----------------------------------------------------------
; Declare additional functions here...
;----------------------------------------------------------


.ends

        end
