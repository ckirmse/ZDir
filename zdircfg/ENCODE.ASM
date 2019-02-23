;  encode.bat
;=============================================================================
;FILE:  encode.asm
;
;DESC:  displays the registration number of name on command line
;
;NOTES:
;
;=============================================================================

include   model.inc

.codeseg  lib
.extrn    exit_ok:auto
.extrn    start:auto
.extrn    set_argtbls:auto
.extrn    arg_count:auto
.extrn    arg_next:auto
.extrn    str_len:auto
.extrn    put_str:auto
.extrn    word_to_dec:auto
.ends

.dataseg
          error_msg db        "Usage: encode ""registration name""",13,10,0
          short_msg db        "Error, string too short.  Registration number would be ",0

          insig_tbl db        "ö",0
          sig_tbl   db        22h,0
          switch_tbl db       "÷",0

          reg_name  db        128 dup (?)

          reg_number db       7 dup (?)
          temp_reg_word dw    ?

          encode_data         dw        6192,10234,40929,23877,12796
                              ; magic numbers!
          wd                  equ       2         ; bytes per word

.ends


;=============================================================================
;FUNC:	MAIN
;
;DESC:	Main body of program.
;
;IN:    DX              segment address of PSP
;
;ASUMS: DS,ES		@DATASEG  (same as @CODESEG in TINY model)
;       SS              @STACKSEG (same as @CODESEG in TINY model)
;=============================================================================

.codeseg

assume    cs:@codeseg, ds:@dataseg, es:@dataseg, ss:@dataseg

.public   main
.proc     main      auto
;----------------------------------------------------------

          mov       ax,offset @dataseg:insig_tbl
          mov       bx,offset @dataseg:sig_tbl
          mov       dx,offset @dataseg:switch_tbl
          call      set_argtbls

          call      arg_count
          test      cx,cx
          jnz       is_argument
          jmp       no_arguments

is_argument:
          mov       si,offset @dataseg:reg_name
          call      arg_next
          jc        no_arguments
          call      arg_next
          jc        no_arguments

          mov       si,offset @dataseg:reg_name
          call      str_len
          cmp       cx,9
          jae       reg_num_do

          mov       si,offset @dataseg:short_msg
          call      put_str

reg_num_do:
          mov       si,offset @dataseg:reg_name
          xor       dx,dx               ; the registration number

          mov       bx,encode_data[0*wd]
          mov       cx,encode_data[1*wd]
          mov       ax,encode_data[2*wd] ; temp storage area
          mov       temp_reg_word,ax
          mov       di,encode_data[3*wd]
          mov       bp,encode_data[4*wd]

each_reg_char:
          lodsb
          test      al,al
          jz        done_reg_char_loop

          push      cx
          xor       ah,ah
          add       dx,ax
          mov       cl,al
          and       cl,7
          rol       dx,cl
          xor       dx,ax
          pop       cx

          mov       ax,bx
          add       ax,dx
          mov       bx,ax
          xor       ax,di
          mov       di,ax
          neg       ax
          add       ax,temp_reg_word
          mov       temp_reg_word,ax
          push      dx
          mul       bp
          pop       dx
          mov       bp,ax
          xor       cx,ax
          add       bx,cx
          sub       dx,bx
          jmp       each_reg_char

done_reg_char_loop:
          sub       dx,11775

          mov       ax,dx
          mov       si,offset @dataseg:reg_number
          call      word_to_dec

          call      put_str

          jmp       exit_ok             ;exit to DOS via SA

no_arguments:
          mov       si,offset @dataseg:error_msg
          call      put_str

          jmp       exit_ok             ;exit to DOS via SA
;----------------------------------------------------------
.endp     main

;----------------------------------------------------------
; Declare additional functions here...
;----------------------------------------------------------
.ends

.public         nheap_default, fheap_default
.label          nheap_default   word    ;used by the near heap
.label          fheap_default   word    ;used by the far heap



                end     start           ;specify START as starting address
