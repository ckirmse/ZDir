;=============================================================================
;FILE:  winmsgbx.asm
;
;DESC:  Does a win_msg_box
;
;NOTES:
;
;=============================================================================

include   model.inc
include   console.inc
include   window.inc
include   string.inc
include   status.inc
include   winmsgbx.inc

include   extrn.inc

.codeseg
.extrn    error_memory:auto
.extrn    status_line:auto
.ends


.dataseg

wmb_window window   <>      ; temp storage of a window

                    dw        wmb_procs
                    dw        3
wmb_table           db        wmb_n,wmb_i,wmb_ic
wmb_procs           dw        cput_str,cput_stri,wmb_cput_strci

crlfcrlf  db        13,10
crlf      db        13,10,0
.public   crlfcrlf
.public   crlf
.ends


;=============================================================================
;FUNC:  win_msg_box
;
;DESC:	
;
;IN: si -> a window message box
;
;OUT: message displayed, if wmb_key_quit then al=key was hit, window erased
;     if wmb_leave, then just displayed, bx has the window handle
;
;NOTES:	
;
;ALG:	
;=============================================================================

.codeseg

assume  cs:@codeseg, ds:nothing, es:nothing, ss:nothing

.public win_msg_box
.proc   win_msg_box  auto
;----------------------------------------------------------
          .push     ax,bx,cx,dx,si,di

          ; first, calculate width of window based on longest string
          push      si

          mov       bx,si
          add       bx,type window
          xor       dx,dx               ; max len
wmb_each_str:
          cmp       [bx].print_proc,wmb_quit_conditions
          jbe       wmb_done_calc

          mov       si,[bx].string_ptr
          call      str_len
          cmp       cx,dx
          jbe       wmb_next_calc
          mov       dx,cx
wmb_next_calc:
          add       bx,type wmb_str
          jmp       wmb_each_str


wmb_done_calc:
          pop       si

          add       dx,4                ; 2 spaces + 2 border
          mov       [si].w_width,dl
          shr       dx,1
          neg       dx
          add       dx,40
          mov       [si].w_left,dx

          call      update_off

          call      win_bufsize
          jc        error_memory
          call      near_malloc
          jc        error_memory
          call      win_create
          jc        error_memory

          push      bx

          add       si,type window
          xor       ax,ax
          call      goto_xy

wmb_each_line:
          mov       al,[si].print_proc
          cmp       al,wmb_quit_conditions
          jbe       printed_wmb
          mov       bx,offset @dataseg:wmb_table
          call      btbl_to_wptr
          jc        error_memory
          push      si
          mov       si,[si].string_ptr
          call      [bx]                ; like cput_str, cput_strci, whatever
          pop       si
          add       si,type wmb_str
          jmp       wmb_each_line
printed_wmb:

          call      update_on

          pop       bx

          cmp       al,wmb_leave
          je        leave_win_msg_box

          mov       al,s10                        ; status of wmb
          call      status_line                   ; print status line

          call      cget_chr
          jnc       wmb_ok_char
          xor       al,al                         ; extended key trashed
wmb_ok_char:
          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory

          .pop      bx,cx,dx,si,di
          add       sp,2                          ; pop ax w/o change
          ret

leave_win_msg_box:
          .pop      ax,ax,cx,dx,si,di             ; killing bx on stack
          ret
;----------------------------------------------------------
        ret
;----------------------------------------------------------
.endp   win_msg_box

;----------------------------------------------------------
wmb_cput_strci:

          push      cx

          .push     ax,bx,si

          xor       ax,ax
          call      get_whandle
          mov       si,offset @dataseg:wmb_window
          call      get_wspec
          mov       cl,[si].w_width
          sub       cl,[si].w_rtcols
          sub       cl,[si].w_ltcols

          .pop      ax,bx,si

          call      cput_strci

          pop       cx

          ret
;----------------------------------------------------------

;----------------------------------------------------------
; Declare additional functions here...
;----------------------------------------------------------

.ends

        end
