;   A86 +E 1-Zdir.asm 15-Zdir.asm 2-Zdir.asm # End-Zdir.asm TO Zdir.com

Months    DW        Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Decm

Jan       DB        7,"January"
Feb       DB        8,"February"
Mar       DB        5,"March"
Apr       DB        5,"April"
May       DB        3,"May"
Jun       DB        4,"June"
Jul       DB        4,"July"
Aug       DB        6,"August"
Sep       DB        9,"September"
Oct       DB        7,"October"
Nov       DB        8,"November"
Decm      DB        8,"December"

;------------------------------------------------------------------------------
Print_totals_in_only:         ; start of tree stuff
; since didn't go to bottom info, do some important stuff first:

          TEST      Not_first_path_search
          if z call do_straight_graph_line

          CALL      Add_up_this_directory

          Restore   ES

          OR        Internal,-1

          CALL      Clear_string_spot
          MOV       DI,OFFSET String_spot

          mov       ax,number_of_files
          cmp       ax,1000
          if b call print_space
          cmp       ax,100
          if b call print_space
          cmp       ax,10
          if b call print_space


          mov       number_of_columns,2           ; not 1.  Just for print num
                                                  ; to not print an extra " "

          XOR       DX,DX
          MOV       CH,tree_files_color
          CALL      Print_number

          MOV       AH,CH
          MOV       AL," "
          CALL      Put_char

          MOV       AX,w[total_size]
          MOV       DX,w[total_size+2]
          ; divide by 1000 to get K...
          call      div_10
          call      div_10
          call      div_10

          or        right_justify,-1
          or        commas_in_numbers,-1
          MOV       CH,tree_size_color

          ; check for >= 100,000k, print in megs
          cmp       dx,1
          ja        >l1
          jb        >l2
          cmp       ax,34464
          jbe       >l2
l1:
          call      div_10
          call      div_10
          call      div_10
          CALL      Print_number
          MOV       AL,"M"
          jmp       >l3
l2:
          CALL      Print_number
          MOV       AL,"k"
l3:
          MOV       AH,CH
          CALL      Put_char

          MOV       AH,CH
          MOV       AL," "
          CALL      Put_char

          XOR       CX,CX

          MOV       SI,Path_spot
L1:
          LODSB
          CMP       AL,"\"
          IF E INC CL
          TEST      AL,AL
          JNZ       L1


          TEST      Not_first_path_search
          if nz jmp Not_first_totals_run

          MOV       Totals_top_slash,CL

          CALL      Scroll_up
          push      di
          mov       di,bottom_row
          mov       si,offset tree_header
          mov       cx,length_tree_header
          mov       ah,tree_text_color
          and       internal,0
          push      es
          to_video  es
          call      print_string
          pop       es
          or        internal,-1
          call      scroll_up
          pop       di

          MOV       b Total_prev_deep,AL,Totals_top_slash

          CMP       Totals_top_slash,1
          JNE       Do_last_dir_name

          MOV       AH,tree_dir_color
          MOV       SI,Path_spot
          MOV       CX,3
          CALL      Print_string
          MOV       b Prev_totals_dir_length,3
          JMP       >L3

Do_last_dir_name:
; ES:DI -> spot to print it
          PUSH      DI
          MOV       DI,Path_spot
          XOR       AL,AL
          MOV       CX,80
          REPNE     SCASB
          DEC       DI
          STD
          MOV       AL,"\"
          MOV       CX,80
          REPNE     SCASB
          MOV       BX,CX
          REPNE     SCASB               ; find second \ from end
          CLD
          SUB       BX,CX
          MOV       CX,BX
          DEC       CX                  ; don't print out \
          MOV       b Prev_totals_dir_length,CL

          ADD       DI,2
          MOV       SI,DI
          MOV       AH,tree_dir_color
          POP       DI
          CALL      Print_string

L3:
          jmp       totals_done_line

Not_first_totals_run:
          ; CX has # of \ in file spec
          ; ES:DI -> string spot

          MOV       Totals_this_slash,CL

          MOV       AX,DX,CX
          SUB       CL,Totals_top_slash
          CMP       CL,Tree_levels+1      ; deep
          IF A JMP Totals_no_print       ; outta here--can't print anything
          PUSH      DX
          SUB       DL,b Totals_next_slash
          SUB       AL,Total_prev_deep
          CBW                           ; sign extend
          MOV       BX,AX

          PUSH      DX


          MOV       DX,CX               ; keep total (max)
          MOV       AH,tree_graphics_color
          CMP       DX,Tree_levels
Each_level_deep_draw:
          ADD       DI,(Tree_level_width+1)*col
          MOV       AL,"³"
          PUSH      BX
          MOV       BX,1
          ADD       BX,DX
          SUB       BX,CX
          TEST      b No_more_this_level[BX]
          POP       BX
          IF NZ MOV AL," "
          CALL      Put_char
          LOOP      Each_level_deep_draw

          CMP       DX,Tree_levels
          POP       DX
          IF A JMP long >L4

          CMP       BX,1
          JNE       >L2

          MOV       CL,Prev_totals_dir_length
          XOR       CH,CH
          mov       al,total_prev_deep
          sub       al,totals_top_slash ; has height of prev with top = 0

          AND       CX,-2               ; SHL 1 cause of char,color shr 1
                                        ; cause of centering
          SUB       DI,(Tree_level_width+1)*Col
          test      al,al
          if z sub di,Col
          ADD       DI,CX
          SHR       CX,1
          NEG       CX
          ADD       CX,Tree_level_width-1
          test      al,al
          if z inc cx
          MOV       AL,"À"
          CALL      Put_char
          MOV       AL,"Ä"
          jcxz      >l125
L1:       CALL      Put_char                                          
          LOOP      L1
l125:
          PUSH      BX
          MOV       BL,Totals_this_slash
          SUB       BL,Totals_top_slash
          XOR       BH,BH
          CMP       BX,Tree_levels
          IF BE AND No_more_this_level[BX],0      ; BX is slashes
                                                  ; relative to top
          MOV       AL,"Â"
          CMP       DL,0
          JLE       >L15
          MOV       AL,"Ä"
          CMP       BX,Tree_levels
          IF BE NOT No_more_this_level[BX]        ; means no more!
L15:
          CALL      Put_char
          POP       BX
          JMP       >L3

L2:
          SUB       DI,Col

          PUSH      BX
          MOV       BL,Totals_this_slash
          SUB       BL,Totals_top_slash
          XOR       BH,BH
          CMP       BX,Tree_levels
          IF BE AND No_more_this_level[BX],0       ; BX is slashes
                                                   ; relative to top
          MOV       AL,"Ã"
          CMP       DL,0
          JLE       >L25
          mov       al,"À"
          or        no_more_this_level[bx],-1
L25:
          CALL      Put_char
          POP       BX

L3:
          MOV       AL,"Ä"
          CALL      Put_char

          POP       DX
          MOV       b Total_prev_deep,DL

          MOV       BL,Totals_this_slash
          SUB       BL,Totals_top_slash
          CMP       BL,Tree_levels+1
          IF BE JMP Do_last_dir_name
          JA        Totals_no_print

L4:
          SUB       DI,(Tree_level_width+1)*Col
          MOV       AL,"À"
          CALL      Put_char
          MOV       AL,"Ä"
          MOV       CX,Tree_level_width
More_arrow_shaft:
          CALL      Put_char
          LOOP      More_arrow_shaft
          MOV       AL,">"
          CALL      Put_char

totals_done_line:
          To_Video  ES
          AND       Internal,0
          MOV       DI,OFFSET String_spot+(80-1)*Col  ; print out whole thing
                                                      ; -1 cause ansi alt output
          CALL      Print_string_spot
          CALL      Scroll_up
          Restore   ES

Totals_no_print:                        ; if more than 5 levels deep

          TEST      Path_search
          JNZ       End_ZDir_check_nextdir

          To_video  ES
          CALL      Scroll_up
          call      do_straight_graph_line
          JMP       Bottom_info

End_ZDir_check_nextdir:
          MOV       AL,normal_EC

          TEST      Path_search
          IF Z JMP Exit
;------------------------------------------------------------------------------
Start_r:
          AND       Right_justify,0
          OR        Not_first_print,-1

No_files_path_search:

          TEST      Not_first_path_search
          JNZ       >L1
          MOV       w High_path_spot,OFFSET Paths
          OR        Not_First_path_search,-1

          MOV       SI,OFFSET Full_path
          MOV       CX,Length_full_path
          MOV       Main_dir_length,CX
          MOV       DI,OFFSET Main_dir
          REP       MOVSB

L1:
          CALL      Clear_FileName
          MOV       DI,OFFSET Full_path
          ADD       DI,Length_full_path
          MOV       SI,OFFSET Star_dot_star
          MOV       CX,4
          REP       MOVSB


          CMP       Length_full_path,53           ; can MD another, but not CD!
          JAE       No_subs_dir

          MOV       AH,4Eh                        ;Find first file
          MOV       DX,OFFSET Full_path
          MOV       CX,Directory or read_only or hidden or system
          INT       21h
          JC        No_subs_dir

          MOV       DI,High_path_spot
;------------------------------------------------------------------------------
Next_dir:
                                                  ;DS:DX MUST always
                                                  ;point to path_spot
          CMP       DI,OFFSET DTA - 64
          JAE       Done_dir

          CMP       b FileName,"."
          JE        Get_next_dir

          TEST      Attrib,Directory
          JZ        Get_next_dir

          INC       w Path_number_of_dirs

          PUSH      DI
          MOV       SI,OFFSET Full_path
          MOV       CX,Length_full_path
          REP       MOVSB
          MOV       SI,OFFSET FileName
          MOV       CX,13
          REP       MOVSB                         
          POP       DI

          ADD       DI,64

          CALL      Clear_FileName

Get_next_dir:
          MOV       AH,4Fh                        ;Find next file
          INT       21h
          JNC       Next_dir

Done_dir: MOV       High_path_spot,DI
No_subs_dir:
          MOV       AX,High_path_spot
          CMP       AX,w Max_depth_path_spot
          IF A MOV Max_depth_path_spot,AX
          CMP       AX,OFFSET Paths
          JBE       Done_path_search
          MOV       SI,High_path_spot
          SUB       SI,64
          MOV       DI,81h
          MOV       CX,64
          REP       MOVSB
          MOV       DI,81h
          XOR       AL,AL
          MOV       CX,64
          REPNE     SCASB
          DEC       DI
          MOV       AL,"\"
          STOSB
          MOV       SI,OFFSET File_spec
          MOV       CX,13
          REP       MOVSB
          MOV       b[80h],77
          SUB       High_path_spot,64

          ; now check if next path AFTER this one is equal length, shorter
          ; or longer

          AND       b Totals_next_slash,0         ; means "less"

          MOV       AX,High_path_spot
          CMP       AX,Max_depth_path_spot
          JA        >L2
          SUB       AX,64
          MOV       SI,AX
          XOR       CX,CX
L1:
          LODSB
          CMP       AL,"\"
          IF E INC CX
          TEST      AL,AL
          JNZ       L1
          INC       CL                  ; for we have only path, not trailing
                                        ; \*.* (for example)
          MOV       Totals_next_slash,CL


L2:
          JMP       No_switches

Done_path_search:
          OR        Commas_in_numbers,-1
          AND       Right_justify,0

          TEST      Totals_only
          IF Z CALL Scroll_up

          To_Video  ES
          MOV       DI,Bottom_row

          TEST      Totals_only
          JZ        >L3
          CALL      Scroll_up
          call      do_straight_graph_line
L3:
          MOV       DI,Bottom_row

          MOV       SI,OFFSET File_listing_msg
          MOV       CX,Length_file_listing
          MOV       AH,Totals_msg_clr
          CALL      Print_string

          MOV       SI,OFFSET Main_dir
          MOV       CX,Main_dir_length
          MOV       AH,Totals_color
          CALL      Print_string

          CALL      Scroll_up
          MOV       DI,Bottom_row

          MOV       SI,OFFSET And_sub_dirs_msg
          MOV       CX,Length_and_sub_dirs
          MOV       AH,Totals_msg_clr
          CALL      Print_string

          MOV       AX,Path_number_of_dirs
          XOR       DX,DX
          MOV       CH,Totals_color
          CALL      Print_number

          mov       ah,totals_msg_clr

          mov       si,offset dirs_under_msg1
          mov       cx,length_dirs_under1
          call      print_string

          cmp       path_number_of_dirs,1
          jne       >l1

          mov       al,'y'
          call      put_char
          jmp       >l2
l1:
          mov       si,offset dirs_under_msg2
          mov       cx,length_dirs_under2
          call      print_string
l2:

          mov       si,offset dirs_under_msg3
          mov       cx,length_dirs_under3
          call      print_string

          MOV       AH,Totals_color
          Restore   ES
          PUSH      DI
          MOV       DI,OFFSET File_spec
          XOR       AL,AL
          MOV       CX,13
          REPNE     SCASB
          NEG       CX
          ADD       CX,12
          POP       DI
          To_video  ES

          MOV       SI,OFFSET File_spec
          CALL      Print_string

          CALL      Scroll_up
          MOV       DI,Bottom_row

          MOV       SI,OFFSET Totals_msg
          MOV       CX,Length_totals_msg
          MOV       AH,Totals_msg_clr
          CALL      Print_string

          CALL      Scroll_up

          Restore   ES

          test      just_user_ext,-1
          if nz call print_just_user_ext_str
l1:

          CALL      Clear_string_spot
          MOV       DI,OFFSET String_spot

          OR        Internal,-1
          MOV       AX,Path_number_of_files

          XOR       DX,DX
          MOV       CH,Totals_color
          CALL      Print_number

          MOV       AH,Totals_color
          MOV       AL,"+"
          TEST      Any_truncated
          IF NZ CALL Put_char

          CMP       Path_number_of_files,1
          JE        >L1

          MOV       SI,OFFSET total_size_msg1
          MOV       CX,Length_Total_size1
          JMP       >L2

L1:       MOV       SI,OFFSET Total_size_msg15
          MOV       CX,Length_total_size15

L2:       MOV       AH,Totals_msg_clr
          CALL      Print_string

          MOV       DX,w[Total_path_size+2]
          MOV       AX,w[Total_path_size]

          MOV       CH,Totals_color
          AND       Right_justify,0
          CALL      Print_number
          MOV       SI,OFFSET Total_size_msg2
          MOV       CX,Length_Total_size2
          MOV       AH,Totals_msg_clr
          CALL      Print_String

          MOV       DX,w[Path_Consumption+2]
          MOV       AX,w[Path_Consumption]

          MOV       CH,Totals_color
          CALL      Print_number

          MOV       SI,OFFSET Total_size_msg3
          MOV       CX,Length_Total_size3
          MOV       AH,Totals_msg_clr
          CALL      Print_string

          To_Video  ES
          AND       Internal,0
          CALL      Print_string_spot
          Restore   ES


          CALL      Scroll_up

          CALL      Print_disk_info

          MOV       AL,Path_search_EC

Exit:     PUSH      AX

          push      ax
          CALL      Cursor_to_row

          test      bios,-1
          jz        >l1

          mov       di,bottom_row
          cmp       di,max_row_x_row
          if b call scroll_up
          pop       ax
l1:
          cmp       al,help_ec
          jae       >l15
          mov       ah,empty_color
          xor       al,al
          call      put_char
l15:

          CMP       Printer_Handle,4
          JBE       >L2

          MOV       AH,3Eh
          MOV       BX,Printer_Handle
          INT       21h
          JNC       >L2

          call      scroll_up
          MOV       DI,Bottom_row
          MOV       SI,OFFSET File_close_err_msg
          MOV       CX,Length_file_close_err
          MOV       AH,Write_file_color
          CALL      Print_to_screen
L2:
          MOV       AX,3301h
          MOV       DL,Break_status
          INT       21h                           ; Set break status

          POP       AX

          MOV       AH,4Ch
          INT       21h

;------------------------------------------------------------------------------
Scroll_Up:
          TEST      Printer
          JNZ       Print_CR_LF

Screen_Scroll_up:
          PUSH      AX,BX,CX,DX,DS,ES,DI,SI
          To_video  ES
          MOV       AX,Bottom_row
          CMP       AX,Max_row_x_row
          JE        Move_Screen
          mov       ax,row_bytes
          add       bottom_row,ax
          MOV       DI,Bottom_row
          MOV       AH,CS:Empty_color
          MOV       AL," "
          MOV       CX,screen_cols
L1:       CALL      Screen_Char
          LOOP      L1

          JMP       short End_scroll_up
Move_screen:
          TEST      Bios
          JNZ       Bios_scroll
          MOV       CX,Max_row_x_row
          SHR       CX,1
          XOR       DI,DI
          MOV       SI,row_bytes
          To_video  DS
          REP       MOVSW
          Restore   DS
          MOV       AH,Empty_color
          MOV       AL," "
          MOV       CX,screen_cols
          REP       STOSW

End_scroll_up:
          CALL      Cursor_to_row
          DEC       Lines_printed
          IF Z CALL Wait_key
          POP       SI,DI,ES,DS,dx,CX,BX,AX
          RET

Print_CR_LF:
          PUSH      AX

          TEST      ANSI_printer
          JZ        >L1
                                                  ; Color matters here!
          MOV       AH,b Prev_color
          MOV       AL,CR
          CALL      Printer_char
          MOV       AH,Prev_color
          MOV       AL,LF
          CALL      Printer_char
          POP       AX
          JMP       Screen_scroll_up
L1:
          MOV       AL,CR
          CALL      Printer_char
          MOV       AL,LF
          CALL      Printer_char
          POP       AX
          JMP       Screen_scroll_up

Bios_scroll:
          MOV       AX,0601h
          CALL      Bios_do
          JMP       End_scroll_up

Bios_do:
          MOV       BH,Empty_Color
          XOR       CX,CX
          mov       dx,screen_cols
          dec       dl
          MOV       DH,Screen_rows
          INT       10h
          RET


Clear_filename:
          PUSH      DI
          MOV       DI,OFFSET FileName
          MOV       AL," "
          MOV       CX,13
          REP       STOSB
          POP       DI
          RET

Fix_FileName:
          PUSH      DI
          MOV       BP,SP

          MOV       DI,OFFSET FileName
Fix_name:
          MOV       AL,"."
          SCASB
          JE        Clean_up_zeroes
          MOV       CX,8
          REPNE     SCASB
          JNE       Clean_up_zeroes
          DEC       DI
          XOR       AL,AL
          STOSB
          MOV       SI,DI

          MOV       DI,Temp_Holder
          MOVSB
          MOV       [SI-1],AL
          MOVSB
          MOV       [SI-1],AL
          MOVSB
          MOV       [SI-1],AL

          MOV       SI,Temp_Holder
          MOV       DI,OFFSET FileName
          ADD       DI,9
          MOV       CX,3
          REP       MOVSB

          TEST      Period_extension
          IF NZ MOV b[Filename+8],"."

Clean_up_zeroes:                                  ;Clear out ASCII 0
          MOV       SI,OFFSET FileName
          MOV       CX,12
Zeroes_to_space:
          TEST      b[SI]
          IF Z MOV  b[SI]," "
          INC       SI
          LOOP      Zeroes_to_space

No_Period:
          POP       DI
          RET

Wait_Key:
          PUSH      ES,AX,CX,SI
          To_video  ES

          TEST      Wait_for_key
          JZ        end_wait_key

          CMP       Printer_handle,4
          JA        >L2

          TEST      Printer
          JNZ       end_wait_key

L2:
          MOV       DI,bottom_row
          MOV       AH,Bracket_attrib
          MOV       AL,"¯"
          CALL      Screen_Char
          CALL      Screen_Char

          MOV       SI,OFFSET Any_key_msg
          MOV       CX,Length_Any_key
          MOV       AH,Any_key_attrib

          CALL      Print_to_screen

          MOV       AH,Bracket_attrib
          MOV       AL,"®"
          CALL      Screen_char
          CALL      Screen_char

          MOV       AH,8                ; checks for ctrl-c, ctrl-break
          INT       21h
          TEST      AL,AL               ; if extended key
          jnz       >l3
          int       21h
          cmp       al,down_arrow_key
          jne       page_wait_key
          mov       lines_printed,2
          jmp       page2_wait_key

          jmp       page_wait_key
l3:
          ;cmp       al,enter_key
          ;jne       >l4
          ;mov       lines_printed,2
          ;jmp       page2_wait_key
l4:
          cmp       al,escape_key
          jne       >l5
          mov       di,bottom_row
          mov       al," "
          mov       cx,80
          rep       stosw
          mov       al,normal_ec
          jmp       exit
l5:

page_wait_key:
          MOV       AL,Screen_rows
          MOV       Lines_printed,AL
page2_wait_key:
          mov       ax,row_bytes
          SUB       Bottom_row,ax
          CALL      Screen_scroll_up

end_wait_key:

          MOV       DI,Bottom_row
          POP       SI,CX,AX,ES

          RET

Print_attribs:
          MOV       AH,Attribute_color
          CMP       Entry_one_color,0
          IF NE MOV AH,Entry_color
          MOV       AL," "
          MOV       DL,Attrib
          TEST      DL,Archive
          IF NZ MOV AL,Archive_char
          CALL      Put_Char

          MOV       AL," "
          TEST      DL,Hidden
          IF NZ MOV AL,Hidden_char
          CALL      Put_Char

          MOV       AL," "
          TEST      DL,Read_only
          IF NZ MOV AL,Read_only_char
          CALL      Put_Char

          MOV       AL," "
          TEST      DL,System
          IF NZ MOV AL,System_char
          CALL      Put_Char

          MOV       AL," "
          TEST      DL,Network
          IF NZ MOV AL,Network_char
          CALL      Put_Char
L1:
          RET


Set_color:
          PUSH      ES
          Restore   ES
          MOV       SI,OFFSET Extension_data
          MOV       DI,OFFSET FileName
          ADD       DI,9
          mov       b[di+3],0
          cmp       b[di]," "
          if e mov b[di],0
          cmp       b[di+1]," "
          if e mov b[di+1],0
          cmp       b[di+2]," "
          if e mov b[di+2],0
Check_extension:
          call      move_si_to_ext_check
          mov       ah,[si+3]           ; the color
          push      si,di
          mov       si,offset ext_check
          call      match                         ; wildcards allowed!
          pop       di,si
          test      al,al
          jnz       extension_set           ; extension found
next_extension:
          add       si,5
          cmp       si,offset end_extension_data
          jb        check_extension

          MOV       AH,File_color                 ; didn't match it

Extension_set:
          POP       ES

          MOV       AL,Attrib
          TEST      AL,Volume_Label
          JZ        >L1
          MOV       AH,Volume_color
          JMP       short Color_set

L1:       TEST      AL,Directory
          JZ        >L2
          MOV       AH,Directory_color

L2:       TEST      AL,Hidden
          JZ        Color_set
          MOV       AH,Hidden_color

Color_set:
          RET

;------------------------------------------------------------------------------
Do_serial_number:
          AND       b Have_serial_number,0
          ret
          mov       ax,3001h
          int       21h                 ; get dos version
          cmp       al,4                ; need ver 4 for vol serial #
          jb        ret

          mov       bx,path_spot
          mov       bl,b[bx]
          sub       bl,"A"-1            ; 1 = a:, 2 = b:, etc.
          xor       bh,bh
          mov       cx,0866h            ; get media id
          mov       ax,440Dh            ; ioctl
          mov       dx,offset mediaID
          int       21h
          jc        ret

          or        b have_serial_number,-1
          ret

;------------------------------------------------------------------------------
Print_serial_number:
; pre: make sure Have_serial_number is TRUE

          MOV       AH,Empty_color
          CALL      Print_space
          mov       bx,w [serial_high_word] ; Print high word
          call      print_half_serial

          ; AH is now the right color for this
          MOV       AL,"-"
          CALL      Put_char
          mov       bx,w [serial_low_word]  ; Print low word

; fall right through here!
;          call      print_half_serial
;          RET

Print_half_serial:

          MOV       CH,4
          MOV       AL,4
          MOV       AH,Top_data_color
Each_serial_digit:
          ROL       BX,4
          MOV       AL,BL
          AND       AL,0Fh
          ADD       AL,"0"
          CMP       AL,"9"
          IF A ADD AL,"A"-"0"-10
          CALL      Put_char
          DEC       CH
          JNZ       Each_serial_digit
          RET

;----------------
; top two lines of display stuff

Top_two_lines:
          ; line one
          CALL      Clear_string_spot
          OR        b Internal,-1
          TEST      b Not_first_print
          IF NZ JMP Line_two
          MOV       DI,OFFSET String_spot + 29*Col
          CALL      Print_name

          MOV       DI,OFFSET String_spot
          MOV       AH,2Ch
          INT       21h                 ; get time

          MOV       AL,CH
          PUSH      CX
          MOV       CL,6
          SHL       AX,CL
          POP       CX
          OR        AL,CL
          SHR       DH,1                ; seconds even only
          MOV       CL,5
          SHL       AX,CL
          OR        AL,DH
          MOV       w Time,AX

          MOV       CH,Time_date_color
          MOV       CL,Number_of_columns
          AND       Right_justify,0
          PUSH      CX
          MOV       Number_of_columns,1  ; NOT 2! so print seconds
          CALL      Print_time_color_set
          POP       CX
          MOV       Number_of_columns,CL

          MOV       AH,CH
          MOV       AL,"m"
          CALL      Put_char

          MOV       AH,2Ah
          INT       21h                 ; get date

          MOV       DI,OFFSET String_spot + Vol_scr_spot + 16*Col

          cmp       totals_only,0
          jne       >l1

          CMP       Number_of_columns,3
          IF E SUB DI,2*Col
          CMP       Number_of_columns,6
          IF E SUB DI,2*Col
l1:
          PUSH      DI
          MOV       AX,CX
          MOV       BX,DX               ; store month, day
          XOR       DX,DX
          MOV       CH,Time_date_color

          MOV       CL,Commas_in_numbers
          PUSH      CX
          PUSH      BX
          AND       Commas_in_numbers,0
          CALL      Print_number
          POP       BX
          POP       CX
          MOV       Commas_in_numbers,CL

          POP       DI
          SUB       DI,4*Col
          CMP       BL,10               ; day of month
          IF B INC DI,Col
          PUSH      DI
          MOV       AL,BL
          XOR       AH,AH
          XOR       DX,DX
          MOV       CH,Time_date_color
          PUSH      BX
          CALL      Print_number
          POP       BX
          MOV       AH,CH
          MOV       AL,","
          CALL      Put_char
          POP       DI
          SUB       DI,Col

          PUSH      BX
          MOV       BL,BH
          XOR       BH,BH
          DEC       BX                  ; convert 1-12 to offsets 0-11
          SHL       BX,1                ; table is in words
          MOV       SI,Months[BX]
          LODSB
          XOR       AH,AH
          SHL       AX,1
          SUB       DI,AX
          SHR       AX,1
          MOV       CX,AX
          MOV       AH,Time_date_color
          CALL      Print_string

          POP       BX

          To_video  ES
          AND       Internal,0
          MOV       DI,OFFSET String_spot + (80-1)*Col
                              ; -1 for ansi in alt output to not reset color
          CALL      Print_string_spot
          CALL      Scroll_up
          Restore   ES

Line_two:
          AND       Internal,0

          CALL      Clear_string_spot

          cmp       exist_vol_label,0
          jz        print_path


          MOV       DI,offset fcb_drive+1+10
          MOV       CX,11
          STD
          MOV       AL,' '
          REPE      SCASB
          CLD
          INC       CX
          PUSH      CX
          NEG       CX
          ADD       CX,11                         ; CX has length of vol label
          SHL       CX,1

          OR        Internal,-1
          MOV       DI,OFFSET String_spot + Vol_scr_spot
          TEST      Have_serial_number
          IF NZ SUB DI,10*Col
          ADD       DI,CX

          cmp       totals_only,0
          jne       >l1

          CMP       Number_of_columns,3
          IF E SUB DI,2*Col
          CMP       Number_of_columns,6
          IF E SUB DI,2*Col
l1:
          MOV       BX,DI
          SUB       BX,OFFSET String_spot
          SHR       BX,1                          ; BX has Volume - spot on scr
          ; DON't CHANGE BX

          MOV       SI,OFFSET Volume_label_msg
          MOV       CX,Length_Volume_label
          MOV       AH,Top_msg_color
          CALL      Print_string

          POP       CX
          mov       si,offset fcb_drive+1
          MOV       AH,Top_data_color
          CALL      Print_String

          TEST      Have_serial_number
          IF NZ CALL Print_serial_number

Print_path:

          OR        Internal,-1
          MOV       DI,Path_spot

          XOR       AL,AL
          MOV       CX,80h
          REPNE     SCASB

          SUB       CX,80h
          NEG       CX                  ; has true length of string, w/ 0

          PUSH      CX
          MOV       DI,OFFSET String_spot
          MOV       SI,OFFSET Path_msg
          MOV       CX,Length_path
          MOV       AH,Top_msg_color
          CALL      Print_string
          POP       CX

          MOV       AH,Top_data_color
          MOV       SI,Path_spot
          DEC       CX                              ;DON'T print out ASCII 0

          ; CX has length of file spec for real now
          ; BX has Volume - spot on screen
          SUB       BX,7                ; 6 is for Path:
          CMP       CX,BX

          JA        Path_not_fit                   ; doesn't fit! shrink!
          CALL      Print_string
          JMP       Setup_line_2
Path_not_fit:
          LODSB
          CALL      Put_char
          LODSB
          CALL      Put_char
          LODSB
          CALL      Put_char
          MOV       AL,'.'
          CALL      Put_char            ; not enough room for whole path
          CALL      Put_char            ; so put c:\...\
          CALL      Put_char            ; and leave out some dirs

          SUB       BX,6                ; for the c:\...
          SUB       CX,3                ; for the ..., don't print 3 extra
                                        ; characters

          MOV       DX,CX               ; need CX in the SCASBs
          INC       DX
          PUSH      DI
          MOV       DI,SI
          MOV       AL,'\'
Search_kill_backslash:
          DEC       DX
          MOV       CX,13
          REPNE     SCASB
          NEG       CX
          ADD       CX,13 - 1           ; -1 to save the \
          SUB       DX,CX
          CMP       DX,BX
          JA        Search_kill_backslash

          MOV       SI,DI
          DEC       SI
          MOV       CX,DX
          POP       DI

          CALL      Print_string


Setup_line_2:                           ; already setup in string_spot
          To_video  ES
          AND       Internal,0
          MOV       DI,OFFSET String_spot + 79*Col
          CALL      Print_String_spot

          CALL      Scroll_up
          RET

;------------------------------------------------------------------------------
; date and time stuff
;
;
; Pre : Date and Time have packed date and time to print out

Print_Date:
          MOV       CH,Date_color
          CMP       Entry_one_color,0
          IF NE MOV CH,Entry_color

          MOV       AX,w Date                       ;Month
          MOV       CL,5
          SHR       AX,CL
          AND       AX,00000000_00001111xB
          CMP       AL,10
          IF B CALL Print_space

L1:       XOR       DX,DX
          AND       Right_justify,0
          CALL      Print_number
          MOV       AH,Date_color
          CMP       Entry_one_color,0
          IF NE MOV AH,Entry_color
          MOV       AL,"-"
          CALL      Put_Char

          MOV       AX,Date                       ;Day
          AND       AX,00000000_00011111xb
          CMP       AL,9
          JA        >L2
          PUSH      AX
          MOV       AH,Date_color
          CMP       Entry_one_color,0
          IF NE MOV AH,Entry_color
          MOV       AL,"0"
          CALL      Put_Char
          POP       AX

L2:       XOR       DX,DX
          AND       Right_justify,0
          CALL      Print_number

          MOV       AH,Date_color
          CMP       Entry_one_color,0
          IF NE MOV AH,Entry_color
          MOV       AL,"-"
          CALL      Put_Char

          MOV       AX,Date                       ;Year
          MOV       CL,9
          SHR       AX,CL
          ADD       AX,80
L21:
          CMP       AX,99
          JB        >L25
          SUB       AX,100
          JMP       L21
L25:
          CMP       AX,10
          JAE       >L35
L3:       PUSH      AX
          MOV       AH,Date_color
          CMP       Entry_one_color,0
          IF NE MOV AH,Entry_color
          MOV       AL,"0"
          CALL      Put_Char
          POP       AX
L35:
          XOR       DX,DX
          AND       Right_justify,0
          CMP       AX,10
          IF Z CALL Print_number
          CALL      Print_number

          CALL      Print_space

          RET

Print_time:

          MOV       CH,Time_color
          CMP       Entry_one_color,0
          IF NE MOV CH,Entry_color
          OR        Right_justify,-1              ; for hour

Print_time_color_set:
                                                  ;Hour
          MOV       AX,w Time
          MOV       CL,11
          SHR       AX,CL
          
          CMP       Number_of_columns,2
          JE        Have_hour
          CMP       AX,12
          JNA       >L4
          SUB       AX,12
          OR        b PM_flag,-1

L4:       CMP       AX,12
          IF E OR PM_flag,-1
          
          TEST      AX
          IF Z ADD AX,12
Have_hour:
          TEST      Right_justify
          JZ        >L5
          CMP       AL,10
          IF B CALL Print_space

L5:       XOR       DX,DX
          AND       Right_justify,0
          PUSH      CX
          CALL      Print_Number
          POP       CX
          MOV       AH,CH
          MOV       AL,":"
          CALL      Put_Char

          PUSH      CX
          MOV       AX,Time                       ;Minute
          MOV       CL,5
          SHR       AX,CL
          POP       CX
          AND       AX,00000000_00111111xB
          CMP       AL,9
          JA        >L6
          PUSH      AX
          MOV       AH,CH
          MOV       AL,"0"
          CALL      Put_char
          POP       AX
L6:       XOR       DX,DX
          AND       Right_justify,0
          CALL      Print_number

          CMP       Number_of_columns,2
          JE        RET

          MOV       AH,CH
          MOV       AL,":"
          CALL      Put_Char

          MOV       AX,Time                       ;Second
          AND       AX,00000000_00011111xB
          SHL       AX,1
          CMP       AL,9
          JA        >L7
          PUSH      AX
          MOV       AH,CH
          MOV       AL,"0"
          CALL      Put_Char
          POP       AX

L7:       XOR       DX,DX
          AND       Right_justify,0
          CALL      Print_number

          MOV       AH,CH
          MOV       AL,"a"
          TEST      b PM_flag
          IF NZ MOV AL,"p"
          CALL      Put_Char
          AND       b PM_flag,0

          RET

;------------------------------------------------------------------------------
Setup_pointers:
          PUSH      CX
          MOV       DI,OFFSET Pointer_area
          XOR       AX,AX
          MOV       CX,Number_of_files
          JCXZ      Quit_setup_ps
L1:       INC       AX
          STOSW
          LOOP      L1

          MOV       CX,Max_files
          SUB       CX,Number_of_files
          MOV       AX,55555
          REP       STOSW
Quit_setup_ps:
          POP       CX

          RET

;------------------------------------------------------------------------------
Sort:

          CMP       Number_of_files,1
          je        ret

Setup_sort:                   ; setup SI and DI for sort of the pointers

          MOV       CX,Number_of_Files
          DEC       CX

          MOV       SI,DI,OFFSET Pointer_Area
          SHL       CX,1
          ADD       DI,CX                         ;SI front, DI end


Quick_sort:
          CMP       SI,DI
          JAE       RET

          PUSH      DI,SI
;---------------------------------------
Rearrange:
          CMP       SI,DI
          JAE       Past_Rearrange

          MOV       BX,SI

L1:       CMP       SI,DI
          JE        Switch_pivot

          MOV       AX,w[DI]
          MOV       DX,w[BX]
          CALL      Compare
          JC        >L2

          DEC       DI,2
          JMP       L1

L2:       CMP       SI,DI
          JE        Switch_pivot
          INC       SI,2
          MOV       AX,w[SI]
          MOV       DX,w[BX]

          CALL      Compare
          JC        L2

          MOV       CX,w[SI]                      ;Exchange w[SI],w[DI]
          MOV       AX,w[DI]
          MOV       w[SI],AX
          MOV       w[DI],CX

          JMP       L1

Switch_pivot:
          MOV       CX,w[DI]
          MOV       AX,w[BX]
          MOV       w[DI],AX
          MOV       w[BX],CX

Past_Rearrange:
          MOV       AX,SI
          POP       SI
          PUSH      AX
          DEC       DI,2

          CALL      Quick_sort
          POP       SI
          POP       DI
          INC       SI,2

          JMP       Quick_sort


;------------------------------------------------------------------------------
do_bottom_graph_line:

          mov       dl,intersection_up
line_start:
          mov       bl,number_of_columns
          test      files_to_print
          if z mov bl,1

line_col_set:
          mov       di,bottom_row

          mov       ah,graphics_color
          mov       al,horizontal_line
          call      graph_lines
          call      scroll_up

          ret

do_top_graph_line:
          mov       dl,intersection_down
          jmp       line_start

do_straight_graph_line:
          mov       bl,1                ; 1 column makes straight line
          jmp       line_col_set
;------------------------------------------------------------------------------
graph_section_width db        79,39,25,19,0,12
                ; for columns  1, 2, 3, 4,x, 6
Graph_lines:
; in: al has horizontal_line,
;     bl has number of columns to print for
;     dl has intersection_up or down

          xor       bh,bh
          mov       dh,bl               ; countdown

          dec       bx                  ; make 0 based to use as index

l1:
          xor       ch,ch
          mov       cl,graph_section_width[bx]
l2:       call      put_char
          loop      l2

          dec       dh
          jz        >l3

          mov       al,dl
          call      put_char
          mov       al,horizontal_line
          jmp       l1

l3:
          ret
;------------------------------------------------------------------------------
Compare:
; in : ax and dx have some value (I think # from pointer_area)

          PUSH      SI,DI,AX,BX,CX,DX


          mov       temp_ax,ax
          mov       temp_dx,dx

          MOV       w Factor_ptr,OFFSET Sort_factor_1-2

Each_factor:
          ADD       Factor_ptr,2
          CMP       Factor_ptr,OFFSET Past_factors          ; in version 1.3
          IF E MOV Factor_ptr,OFFSET Sort_factor_3          ; to rejoin string
                                                  ; of sort factors in 2.0
          MOV       SI,Factor_ptr
          MOV       BX,[SI]

          mov       ax,temp_ax

          DEC       AX
          MOV       DX,Entry_Length
          MUL       DX

          MOV       SI,OFFSET Data_Area
          ADD       SI,AX

          mov       ax,temp_dx

          DEC       AX
          MOV       DX,Entry_Length
          MUL       DX

          MOV       DI,OFFSET Data_Area
          ADD       DI,AX

          ; right now, SI and DI point to the beginning of the file dir entries
          ; to compare.  BX has the sort factor, to add to SI and DI if
          ; not checking for directory stuff


          TEST      Presort
          JZ        Normal_compare
          MOV       AL,b[SI]
          MOV       AH,b[DI]
          AND       AX,Directory by Directory     ; isolate directory bit
          CMP       AL,AH
          JE        Normal_compare      ; if equal, then normal sort
          CMP       Presort,PS_dir_last
          IF E XCHG AL,AH               ; put in reverse order then
          CMP       AL,AH
          JA        >L1
          CLC
          JMP       Quit_compare
L1:
          STC
          JMP       Quit_compare

Normal_compare:
          test      bx,00000000_10000000xb        ; reverse sort ?
          if nz xchg si,di                        ; then change order

          and       bx,00000000_01111111xb

          ADD       DI,BX
          ADD       SI,BX

          CMP       BX,9
          JE        Comp_filename
          CMP       BX,18
          JE        Comp_extension
          TEST      BX
          JZ        Comp_attrib

          CMP       BX,5
          JE        Comp_double_word

          CMP       BX,3
          JE        Compare_word

;          cmp       bx,no_sort_factor  ; doesn't work 'cause qsort is
;          jne       >l1                ; not a stable sort
;          clc
;          jmp short quit_compare
;l1:

Compare_word:
          CMPSW
          JNE       Diff_word
          JMP       Each_factor

Diff_word:
          MOV       AX,w[DI-2]
          CMP       w[SI-2],AX
Compare1: JAE       >L1
          STC
          JMP       short Quit_compare
L1:
          CLC
          JMP       short Quit_compare

Comp_filename:
          MOV       CX,12
          REPE      CMPSB
Compare_byte_got:
          MOV       AL,b[DI-1]
          CMP       b[SI-1],AL
Compare2: JAE       >L1
          STC
          JMP       short Quit_compare
L1:
          CLC
          JMP       short Quit_compare

Comp_extension:
          MOV       CX,3
          REPE      CMPSB
          JNE       Compare_byte_got
          JMP       Each_factor
Comp_attrib:
          CMPSB
          JNE       Compare_byte_got
          JMP       Each_factor

Quit_compare:
          POP       DX,CX,BX,AX,DI,SI
          RET

Comp_double_word:
          PUSH      SI,DI
          INC       SI,2
          INC       DI,2
          STD
          MOV       CX,2
L1:       LODSW
          MOV       BX,[DI]
          DEC       DI,2
          CMP       AX,BX
          LOOPE     L1
          POP       DI,SI

          CLD
          JNE       Got_size_diff

          JMP       Each_factor


Got_size_diff:
          CLD
Compare3: JAE       >L1
          STC
          JMP       short Quit_compare
L1:
          CLC
          JMP       Quit_compare


;------------------------------------------------------------------------------
Null_field MACRO

          MOV       w[SI],55555
          INC       DX

           #EM
;------------------------------------------------------------------------------
Vertical_sort:

          MOV       DX,CX,AX,number_of_files
          CMP       Number_of_columns,4
          IF E SHR AX,1

          CMP       Number_of_columns,3
          JE        >L0
          CMP       Number_of_columns,6
          JE        >L05

          JMP       >L1

L0:
          SHL       AX,1                          ;Actually divides by 6 so X 2
L05:
          XOR       BX,BX

Each_div_ax_3:
          CMP       AX,3
          JB        End_div_ax_3
          SUB       AX,3
          INC       BX
          JMP       Each_div_ax_3

End_div_ax_3:
          MOV       AX,BX
L1:
          AND       AX,-2
          XOR       BH,BH
          MOV       BL,Number_of_columns
          DEC       BX
          CMP       BX,5
          JE        >L12
          CMP       BX,2
          JNE       >L15

L12:
          PUSH      CX
          PUSH      AX
          XOR       BX,BX
          MOV       AX,BX
          MOV       AL,Number_of_columns
Check_6:
          CMP       CX,AX
          JB        End_6_check
          SUB       CX,AX
          INC       BX
          JMP       Check_6
End_6_check:
          POP       AX
          JCXZ      >L12

          INC       AX,2
          XOR       BH,BH
          MOV       BL,Number_of_columns
          POP       CX
          ADD       CX,BX
          JMP       >L2

L12:      POP       CX
          JMP       >L2
L15:
          TEST      CX,BX
          JZ        >L2
          INC       AX,2

          INC       BX
          ADD       CX,BX

L2:
          MOV       DI,OFFSET Pointer2_area
          CMP       Number_of_columns,3
          JE        >L21
          SHR       CX,1

          CMP       Number_of_columns,6
          JNE       >L25
L21:
          XOR       BX,BX

Each_div_cx_3:
          CMP       CX,3
          JB        End_div_cx_3
          SUB       CX,3
          INC       BX
          JMP       Each_div_cx_3

End_div_cx_3:
          MOV       CX,BX
L25:
          CMP       Number_of_columns,4
          IF E SHR CX,1
          XOR       BX,BX

L3:       PUSH      CX

          MOV       CX,number_of_files
          DEC       CX
          SHL       CX,1
          ADD       CX,OFFSET Pointer_area

          MOV       SI,OFFSET Pointer_area

          ADD       SI,BX
          MOVSW
          DEC       SI,2


          push      bx

          mov       bl,number_of_columns
          dec       bl
l4:
          ADD       SI,AX
          CMP       SI,CX
          IF A Null_field
          MOVSW
          DEC       SI,2

          dec       bl
          jnz       l4

          pop       bx

Each_vsort:
          INC       BX,2
          POP       CX
          LOOP      L3

          MOV       Files_to_print,DX
          
          MOV       SI,OFFSET Pointer2_Area
          MOV       DI,OFFSET Pointer_area
          MOV       CX,Files_to_print
          REP       MOVSW

          RET
;------------------------------------------------------------------------------
Print_string_spot:
          PUSH      CX,DX

          MOV       CX,DI
          MOV       DI,Bottom_row
          SUB       CX,OFFSET String_spot
          SHR       CX,1
          MOV       DX,CX               ; has count of length of str
          NEG       CX
          ADD       CX,80
          AND       CX,-2
          TEST      CX,CX
          JZ        >L2
          PUSH      CX
          SHR       CX,1

L1:       CALL      Print_space
          LOOP      L1
          POP       CX

L2:
          MOV       SI,OFFSET String_spot
          MOV       CX,DX

L3:       LODSW
          cmp       al," "
          if e mov ah,empty_color
          test      al,al
          if z mov ah,empty_color
          CALL      Put_char
          LOOP      L3

          POP       DX,CX
          RET
;------------------------------------------------------------------------------
Print_name:
          MOV       AH,ZS_color
          MOV       SI,OFFSET Signature1_msg
          MOV       CX,Length_signature1
          CALL      Print_string

          MOV       AH,Signature_color
          MOV       SI,OFFSET Signature2_msg
          MOV       CX,Length_signature2
          CALL      Print_string

          MOV       AH,ZS_color
          MOV       AL,"Z"
          CALL      Put_Char

          MOV       AH,Signature_color
          MOV       SI,OFFSET Signature3_msg
          MOV       CX,Length_signature3
          CALL      Print_string

          MOV       AH,ZS_color
          MOV       AL,"S"
          CALL      Put_Char
          
          MOV       AH,Signature_color
          MOV       SI,OFFSET Signature4_msg
          MOV       CX,Length_Signature4
          CALL      Print_string

          RET
;------------------------------------------------------------------------------
shift_dword:
          shr       dx,1
          rcr       ax,1

          ret

div_10:
; This comment written 6/93, 6 months after I wrote this code.  There were
; no comments here except for "shoddy...".  Uses the representation of 1/10
; in binary (hardcoded into shifts) to add up fractions to get dx:ax / 10.
; Very clean code, but figure it out for yourself.  I wrote it in my head one
; night, and typed it in the next day and it worked.
;
; Looks like dx:ax = dx:ax / 10, bx (bl really) has the remainder.

          push      cx,si,di

          push      ax,dx

          xor       si,si
          xor       di,di

          call      shift_dword

          mov       cx,8
l1:
          call      shift_dword
          call      shift_dword

          call      shift_dword

          add       si,ax
          adc       di,dx

          call      shift_dword

          add       si,ax
          adc       di,dx

          loop      l1

          pop       dx,ax

          ; overall mul by 10

          ; mul by 2
          shl       si,1
          rcl       di,1

; following line removed 7/93--value not used
;          mov       cx,di
          mov       bx,si

          ; then by 2
          shl       bx,1
; following line removed 7/93--value not used
;          rcl       cx,1
          ; then by 2 again, 8 total
          shl       bx,1
; following line removed 7/93--value not used
;          rcl       cx,1

          add       bx,si
; following line removed 7/93--value not used
;          adc       cx,di

          sub       bx,ax
          neg       bx

          mov       dx,di
          mov       ax,si
          call      shift_dword

          ; shoddy patch here for inexactness
l2:
          cmp       bx,10
          jb        >l4

          sub       bx,10
          add       ax,1                ; because inc doesn't set carry
          jnc       >l3
          inc       dx
l3:
          jmp       l2
l4:

          pop       di,si,cx

          ret
;------------------------------------------------------------------------------
print_number:
;Input: DX:AX = number to print
;       ES:DI = address to write to
;       CH = color
;       Right_justify is set
;       commas_in_numbers is set

          and       b digit_count,0
          or        b first_digit,-1    ; both for commas

          ; peel off the digits ...
l1:
          call      div_10
          push      bx                  ; has the digit
          inc       digit_count
          test      ax
          jnz       l1
          test      dx
          jnz       l1

          ; spaces preceding num (do the right justify)
          test      right_justify
          jz        >l3

          mov       bl,digit_count
          xor       bh,bh
          neg       bx
          add       bx,6

          cmp       number_of_columns,1
          if e add bx,5
          ;cmp       number_of_columns,3          there's room, but
          ;if e inc bx                            not good for only 1 & 3 cols
                                                  ; to have a feature
          test      commas_in_numbers
          jz        >l1
          cmp       digit_count,4
          if ae dec bx
          cmp       digit_count,7
          if ae dec bx
l1:
          push      cx
          mov       cx,bx
          jcxz      >l25
l2:       call      print_space
          loop      l2
l25:
          pop       cx
l3:


          ; and retrieve 'em from the stack
l4:
          pop       ax
          call      print_digit
          test      digit_count
          jnz       l4

          ret

Print_digit:
          TEST      Commas_in_numbers
          JZ        >L1
          CMP       First_digit,0                 ; don't do comma no matter
          JNZ       >L1                           ; what if first digit!
          CMP       Digit_count,0
          JZ        >L1
          PUSH      AX,BX
          MOV       AL,Digit_count
          XOR       AH,AH
          MOV       BL,3                          ; 3 digits per comma
          DIV       BL
          TEST      AH,AH
          POP       BX,AX
          JNZ       >L1
          PUSH      AX
          MOV       AH,CH
          MOV       AL,','
          CALL      Put_char
          POP       AX
L1:
          ADD       AL,'0'
          MOV       AH,CH
          CALL      Put_Char
          XOR       AX,AX
          AND       First_digit,0       ; we just printed a digit... not first
                                        ; any more!!!
          DEC       Digit_count
          RET

UnEncrypt:
          MOV       SI,DI,OFFSET Encrypted_area
          MOV       CX,Bytes_to_UnEncrypt
UnEncrypt1:
          LODSB
          XOR       AL,Encrypt_code
          STOSB
          LOOP      UnEncrypt1

          RET

Cursor_to_row:
          mov       ax,cs:bottom_row
          xor       dx,dx
          mov       bx,cs:row_bytes
          div       bx
          MOV       DX,AX
          XCHG      DH,DL

          MOV       AH,2                          ;Move cursor
          XOR       BH,BH
          INT       10h

          RET


ANSI_start:
          MOV       AH,40h
          MOV       b Char_put,27
          INT       21h
          MOV       AH,40h
          MOV       Char_put,"["
          INT       21h
          RET

ANSI_dumb_color DB Black,Red,Green,Brown,Blue,magenta,Cyan,ltgray

ANSI_color:
;Pre : AH has color, BX,CX,DX already set!!!
;Post: Color set, AX messy

          MOV       The_color,AH
          CALL      ANSI_start
          MOV       AH,40h
          MOV       Char_put,"0"
          INT       21h

          MOV       AH,40h
          MOV       Char_put,"m"
          INT       21h

          CALL      ANSI_start

          MOV       AH,40h
          MOV       Char_put,"3"
          INT       21h
          MOV       AH,40h
          MOV       AL,The_color
          AND       AL,0000_0111xB
          PUSH      BX
          MOV       BL,AL
          XOR       BH,BH
          MOV       AL,ANSI_dumb_color[BX]
          POP       BX
          MOV       Char_put,AL
          ADD       Char_put,"0"
          INT       21h
          MOV       AH,40h
          MOV       Char_put,"m"
          INT       21h
          CMP       The_color,8
          JB        RET
          PUSH      CX
          MOV       CL,3
          SHR       The_color,CL
          POP       CX
          SHR       The_color,1
          JNC       >L1

          CALL      ANSI_start
          MOV       AH,40h
          MOV       Char_put,"1"
          INT       21h
          MOV       AH,40h
          MOV       Char_put,"m"
          INT       21h
          
L1:
          CALL      ANSI_start

          MOV       AH,40h
          MOV       Char_put,"4"
          INT       21h
          MOV       AH,40h
          MOV       AL,The_color
          AND       AL,0000_0111xB
          PUSH      BX
          MOV       BL,AL
          XOR       BH,BH
          MOV       AL,ANSI_dumb_color[BX]
          POP       BX
          MOV       Char_put,AL
          ADD       Char_put,"0"
          INT       21h
          MOV       AH,40h
          MOV       Char_put,"m"
          INT       21h
          CMP       The_color,8
          JB        RET
          PUSH      CX
          MOV       CL,3
          SHR       The_color,CL
          POP       CX
          SHR       The_color,1
          JNC       >L2

          CALL      ANSI_start
          MOV       AH,40h
          MOV       Char_put,"5"
          INT       21h
          MOV       AH,40h
          MOV       Char_put,"m"
          INT       21h

L2:
          RET


