;   A86 +E 1-Zdir.asm 15-Zdir.asm 2-Zdir.asm # End-Zdir.asm TO Zdir.com
                                

Illegal_table DB '."/\[]:|<>+=;,?*'
Length_illegal_table EQU $ - Illegal_table

;------------------------------------------------------------------------------
Put_char:
          TEST      AL
          IF Z MOV AL," "
          TEST      Internal
          JNZ       Store
          TEST      Printer
          JNZ       >L1

Screen_char:
          TEST      Bios
          JNZ       >L0
Store:
          STOSW
          RET

L0:       PUSH      AX,BX,CX,DX

          PUSH      AX
          MOV       AX,DI
          xor       dx,dx
          mov       bx,row_bytes
          div       bx
          SHR       dl,1
          mov       dh,al
          XOR       BH,BH
          MOV       AH,2
          INT       10h
          POP       AX

          MOV       BL,AH
          XOR       BH,BH
          MOV       AH,9
          MOV       CX,1
          INT       10h
          POP       DX,CX,BX,AX
          INC       DI,Col
          RET

Char_put  DB        ?
Prev_color DB       0

L1:
          CALL      Screen_Char

Printer_char:
          PUSH      AX,BX,CX,DX

          TEST      Print_graphics
          JNZ       >L2

          CMP       AL,Horizontal_line
          IF E MOV AL,"-"
          CMP       AL,Vertical_line
          IF E MOV AL,"|"
          CMP       AL,Intersection_up
          IF E MOV AL,"+"
          CMP       AL,Intersection_down
          IF E MOV AL,"+"
          CMP       AL,"Ä"
          IF E MOV AL,"-"
          CMP       AL,"³"
          IF E MOV AL,"|"
          CMP       AL,179
          JB        >L2
          CMP       AL,218
          JA        >L2
          MOV       AL,"+"
L2:
          MOV       BX,Printer_Handle
          MOV       CX,1
          MOV       DX,OFFSET Char_put

          TEST      ANSI_printer
          JZ        >L3

          CMP       AH,Prev_color
          JE        >L3

          MOV       Prev_color,AH
          PUSH      AX
          CALL      ANSI_Color
          POP       AX
          MOV       AH,40h
          MOV       Char_put,AL
          INT       21h
          JMP short End_print

L3:
          MOV       Char_put,AL
          MOV       AH,40h
          INT       21h
End_print:
          POP       DX,CX,BX,AX
          RET

Print_space:
          PUSH      AX
          MOV       AH,Empty_color
          CMP       Entry_one_color,0
          IF NE MOV AH,Entry_color
          MOV       AL," "
          CALL      Put_Char
          POP       AX
          RET

print_bar:
	  mov	    ah,graphics_color
	  mov	    al,vertical_line
	  cmp	    columns_left,1
	  if ne call put_char
	  ret

Change_attributes:
          CMP       b[FileName],'.'
          JE        end_change_attributes

          MOV       DI,OFFSET Full_path
          ADD       DI,Length_Full_path
          MOV       SI,OFFSET FileName
          MOV       CX,13
          REP       MOVSB

          MOV       AX,4300h
          MOV       DX,OFFSET Full_Path
          INT       21h

          TEST      CL,Directory
          JZ        >L1
          CMP       Change_dir_attrib,0
          JZ        end_change_attributes
L1:

          OR        CL,New_on_attrib
          AND       CL,New_off_attrib

          PUSH      CX

          CMP       Change_dir_attrib,0
          IF NE AND CL,NOT Directory

          MOV       AX,4301h
          TEST      AL,Directory
          IF Z INT 21h

          POP       CX

          IF NC MOV Attrib,CL
end_change_attributes:
          CALL      Fix_FileName
          RET

Size_to_Clusters:
          MOV       BX,AX                         ;DX:AX has file size
          MOV       CX,Bytes_per_sector
          DEC       CX
          NOT       CX                            ;Fill CX w/1s above size

          AND       AX,CX                         ;Get out bottom stuff
          CMP       AX,BX
          JE        RET

          ADD       AX,Bytes_per_sector
          adc       dx,0                          ;If overflow

          RET

;------------------------------------------------------------------------------
Print_file_size:
; in: ch has color

          cmp       number_of_columns,1
          je        short print_size_non_abbrev
          ;---------
          CMP       DX,0Fh
          JA        short print_size_abbrev       ;If 1 M +
          JB        print_size_non_abbrev
          CMP       AX,04240h
          JB        print_size_non_abbrev

print_size_abbrev:
          cmp       entry_one_color,0
          if e mov ch,megabyte_size_color

          AND       Right_justify,0

          push      cx
          mov       cx,6
l1:
          call      div_10
          loop      l1
          pop       cx

          ; ax now has millions, bl has remainder of last div which
          ; is hundred thousands

          cmp       ax,1000
          if ae call print_space

          cmp       ax,100
          if b call print_space

          cmp       ax,10
          if b call print_space


          push      ax,bx
          call      print_number
          pop       bx,ax

          cmp       ax,1000
          jae       print_size_m

          mov       ah,ch
          MOV       AL,"."
          CALL      Put_Char

          mov       al,bl
          add       al,"0"
          call      put_char

print_size_m:
          mov       ah,ch
          mov       al,"M"
          call      put_char

          jmp       ret

print_size_non_abbrev:

          OR        Right_justify,-1

          CMP       Number_of_columns,1
          jne       short check_allow_commas

print_size_and_ret:
          CALL      Print_Number
          RET

check_allow_commas:
          PUSH      AX,BX,DX
          MOV       BX,10_000
          DIV       BX
          CMP       AX,10
          POP       DX,BX,AX
          jb        print_size_and_ret
          MOV       BL,Commas_in_numbers
          PUSH      BX
          AND       Commas_in_numbers,0           ; not enough room
                                                  ; for commas if 100000
          CALL      Print_number
          POP       BX
          MOV       Commas_in_numbers,BL
          RET
;------------------------------------------------------------------------------
Print_disk_info:

          TEST      Disk_totals
          JZ        >L1

          CMP       Disk_totals,Totals_AB_only
          JNE       RET

          MOV       BX,Path_spot
          CMP       b[BX],"A"
          JE        >L1
          CMP       b[BX],"B"
          JNE       RET
L1:

          OR        Internal,-1
          MOV       DI,OFFSET String_spot
          
          MOV       AX,w[Free_space]
          MOV       DX,w[Free_space+2]
          MOV       CH,totals_color
          CALL      Print_number

          MOV       SI,OFFSET Free_space_msg
          MOV       CX,Length_Free_space
          MOV       AH,Totals_msg_clr
          CALL      Print_string

          MOV       AX,w[Total_space]
          MOV       DX,w[Total_space+2]
          MOV       CH,totals_color
          ;AND       Right_justify,0
          CALL      Print_number

          MOV       SI,OFFSET Total_space_msg
          MOV       CX,Length_Total_space
          MOV       AH,Totals_msg_clr
          CALL      Print_string

          MOV       SI,Path_spot
          MOV       CX,2
          MOV       AH,Totals_color
          CALL      Print_string

          To_video  ES
          AND       Internal,0
          CALL      Print_string_spot

          mov       ah,empty_color
          call      print_space
          call      scroll_up
          
          RET

Clear_string_spot:
          MOV       AX,0 BY " "
          MOV       DI,OFFSET String_spot
          MOV       CX,80
          REP       STOSW

          RET

Print_string:
L1:       LODSB
          CALL      Put_char
          LOOP      L1
          RET

Print_to_screen:
L1:       LODSB
          CALL      Screen_char
          LOOP      L1
          RET

Clr_Scr:
          and       bottom_row,0

          TEST      Bios
          JNZ       >L1

          PUSH      ES
          To_video  ES
          XOR       DI,DI
          mov       ax,row_bytes
          mov       dl,screen_rows
          xor       dh,dh
          mul       dx
          mov       cx,ax
          MOV       AH,Empty_color
          MOV       AL," "
          REP       STOSW

          POP       ES
          RET
L1:
          MOV       AX,0600h
          JMP       Bios_do

Check_AL_file_char:
;Pre : AL = char to check
;Post: C if illegal char, NC if legal

          PUSH      CX,DI,ES

          CMP       AL,21h
          JB        Illegal_char

          Restore   ES
          MOV       DI,OFFSET Illegal_Table
          MOV       CX,Length_Illegal_Table
          REPNE     SCASB
          JNE       Legal_char

Illegal_char:
          STC
          JMP       Exit_file_char
Legal_char:
          CLC

Exit_file_char:
          POP       ES,DI,CX
          RET

Check_AL_path_char:

          CMP       AL,":"
          JE        Ok_char
          CMP       AL,"\"
          JE        Ok_char
          CMP       AL,"."
          JNE       Check_AL_file_char

OK_char:
          CLC
          RET

Check_AL_any_char:

          CMP       AL,"*"
          JE        Ok_char
          CMP       AL,"?"
          JE        OK_char

          JMP       Check_AL_path_char

print_just_user_ext_str:

          cmp       number_of_files,0
          jnz       >l0
          test      num_user_extensions
          jz        ret
l0:
          mov       ah,just_user_ext_color
          mov       si,offset just_user_ext_str
          mov       di,offset string_spot
          mov       cx,len_just_user_ext_str
          or        internal,-1
          call      print_string

          mov       si,offset extension_data
          mov       cx,num_extensions
          mov       dx,len_just_user_ext_str
          xor       bx,bx
l1:
          cmp       b[si+4],user_ext
          jne       next_user_ext_check
          test      bx,bx
          jz        >l2
          cmp       dx,80-9
          jae       >l3
          mov       ah,just_user_ext_color
          mov       al,","
          call      put_char
          mov       al," "
          call      put_char
          add       dx,2
l2:
          mov       ah,b[si+3]
          lodsb
          call      put_char
          lodsb
          call      put_char
          lodsb
          call      put_char
          add       dx,3
          or        bx,-1
          sub       si,3
next_user_ext_check:
          add       si,5
          loop      l1

          jmp       >l4

l3:       mov       al," "
          mov       ah,just_user_ext_color
          call      put_char
          mov       al,"."
          call      put_char
          call      put_char
          call      put_char
l4:
          to_video  es
          and       internal,0
          call      print_string_spot
          call      scroll_up
          restore   es
          ret

check_if_ext:
; pre  : filename has the filename
; post : carry set if not a user extension

          push      si,di

          mov       di,offset filename
          mov       al,"."
          mov       cx,9
          repne     scasb
          mov       si,offset extension_data
          mov       cx,num_extensions

each_ext_check:
          cmp       b[si+4],not_user_ext
          je        next_ext_check

          call      move_si_to_ext_check
          push      si,di
          mov       si,offset ext_check
          call      match
          pop       di,si

          test      al,al
          jnz       is_user_ext

next_ext_check:
          add       si,5
          loop      each_ext_check

          ; if here, didn't match any user ext

isnt_user_ext:
          stc
          jmp       end_ext_if_check

is_user_ext:
          clc
end_ext_if_check:
          pop       di,si
          ret
;==============================================================================
move_si_to_ext_check:

          push      si,di

          mov       di,offset ext_check

          lodsb
          cmp       al," "
          if e xor al,al
          stosb
          lodsb
          cmp       al," "
          if e xor al,al
          stosb
          lodsb
          cmp       al," "
          if e xor al,al
          stosb

          pop       di,si

          ret
;==============================================================================
File_match:
;Pre : DS=ES:SI -> a file spec (w/ * or ?), DS=ES:DI -> a filename to match
;Post: AL = 0 if did NOT meet form of the spec

          PUSH      BX,CX,DX,SI,DI

          MOV       DX,SI
          MOV       BX,DI

          MOV       DI,SI
          MOV       CX,9;;;;;;;;;15     ; 9 is not long enough, for end-zdir*.*
L1:
          INC       DI
          TEST      b[DI-1]
          JNE       >L2
          DEC       DI
          OR        AL,-1     ; clear the zero flag so it'll NOT find the "."
          JMP       >L3
L2:
          CMP       b[DI-1],"."
          LOOPNE    L1
L3:

          PUSHF
          MOV       w[Specextension],DI
          MOV       DI,OFFSET Tempspec
          POPF
          JNE       >L2

          ; SI still at start
L1:
          CMP       CX,8      ; don't store .
          JE        >L4
          MOVSB
          INC       CX
          JMP       L1
L2:
L3:
          CMP       b[SI],0
          JE        >L4
          MOVSB
          JMP       L3
L4:
          XOR       AL,AL
          STOSB

L6:


          MOV       SI,DI,BX
          MOV       CX,9
L1:
          INC       DI
          TEST      b[DI-1]
          JNE       >L2
          DEC       DI
          OR        AL,-1     ; clear the zero flag so it'll NOT find the "."
          JMP       >L3
L2:
          CMP       b[DI-1],"."
          LOOPNE    L1
L3:



          PUSHF
          MOV       w[Stringextension],DI
          MOV       DI,OFFSET Tempstring
          POPF
          JNE       >L2

L1:
          CMP       CX,8      ; don't store .
          JE        >L4
          MOVSB
          INC       CX
          JMP       L1
L2:
L3:
          CMP       b[SI],0
          JE        >L4
          MOVSB
          JMP       L3
L4:
          XOR       AL,AL
          STOSB

          MOV       SI,OFFSET Tempspec
          MOV       DI,OFFSET Tempstring
          CALL      Match
          TEST      AL
          JZ        End_file_match
          MOV       SI,Specextension
          MOV       DI,Stringextension
          CALL      Match

End_file_match:
          POP       DI,SI,DX,BX,CX
          RET
;==============================================================================
Match:
;Pre : DS:SI -> a string spec (w/ * or ?), ES:DI -> a string to match
;Post: AL = 0 if did NOT meet form of the spec

          TEST      b[SI]
          JNZ       >L1

          TEST      b[ES:DI]
          JZ        Do_match
          JMP       short Dont_match
L1:
          TEST      b[ES:DI]
          JNZ       >L3

          CMP       b[SI],"*"
          JE        >L2
          CMP       b[SI],"?"
          JNE       Dont_match
L2:
          INC       SI
          JMP       Match

L3:

          CMP       b[SI],"?"
          JNE       >L4

          INC       SI
          PUSH      SI,DI
          CALL      Match
          POP       DI,SI
          TEST      AL,AL
          JNZ       RET                 ; ? was replaced with nothing, ok
          INC       DI                  ; ? was replaced with char
          JMP       Match               ; see if it is ok

L4:
          CMP       b[SI],"*"
          JNE       >L5

          PUSH      SI,DI
          INC       SI
          CALL      Match
          POP       DI,SI
          TEST      AL,AL
          JNZ       RET                 ; * was replaced with nothing, ok
          PUSH      SI,DI
          INC       SI
          INC       DI
          CALL      Match
          POP       DI,SI
          TEST      AL,AL
          JNZ       RET                 ; * was replaced with this char, ok
          INC       DI
          JMP       Match               ; * not replaced, skip this char

L5:
          MOV       AL,b[SI]
          CMP       AL,"a"
          JB        >L6
          CMP       AL,"z"
          JA        >L6
          AND       AL,NOT 20h
L6:
          PUSH      AX
          MOV       AH,b[ES:DI]
          CMP       AH,"a"
          JB        >L7
          CMP       AH,"z"
          JA        >L7
          AND       AH,NOT 20h
L7:
          CMP       AL,AH
          POP       AX
          JNE       Dont_match
          INC       SI
          INC       DI
          JMP       Match

Do_match:
          OR        AL,-1
          RET
Dont_match:
          XOR       AL,AL
          RET
;==============================================================================
Fixup_file_spec:
; add *'s to the variable file_spec, general cleanup (repeat *?s, etc.)

          MOV       CX,Length_file_spec
          MOV       DI,OFFSET File_spec
          TEST      CX,CX
          JNZ       >L0
          MOV       SI,OFFSET Star_dot_star
          JMP       >L1
L0:
          MOV       AL,"."
          REPNE     SCASB
          JNE       >L05
          CMP       b[DI],0             ; in case dir ZDir asfdj.
          JNE       >L2
          DEC       DI
          XOR       AL,AL
          STOSB
          JMP       >L5
L05:

          MOV       SI,OFFSET Star_dot_star
          CMP       b[DI-1],"*"
          IF E INC SI
          CMP       b[DI-1],"?"
          IF E INC SI
L1:
          PUSH      DI

          MOV       CX,4
          REP       MOVSB

          TEST      Put_star_in_front
          JZ        >L15

          MOV       DI,OFFSET File_spec + 24
          MOV       SI,OFFSET File_spec + 23
          MOV       CX,24                         ; 24 max, not go past data
          STD
          REP       MOVSB
          CLD
          MOV       b[File_spec],"*"

L15:

          POP       DI

L2:                                     ; fixup if too long

          MOV       CX,OFFSET File_spec
          ADD       CX,Length_file_spec
          SUB       CX,DI

          CMP       CX,3                ; if within 3 chars of end
          JBE       >L3                 ; if so, then ok

          PUSH      DI
          ADD       DI,3                ; to cut off extra long extension
          XOR       AL,AL
          STOSB

          POP       DI
L3:
          CALL      Remove_multiple_star
          CALL      Fixup_first_8
L5:

          CALL      Check_dot_ext

          MOV       DI,OFFSET File_spec
          XOR       AL,AL
          MOV       CX,13
          REPNE     SCASB
          NEG       CX
          ADD       CX,12                         ; don't count the 0 at end
          MOV       Length_file_spec,CX

          RET

Check_dot_ext:

          CMP       b[File_spec],"."
          JNE       RET

          MOV       SI,OFFSET File_spec
          ADD       SI,Length_file_spec
          MOV       DI,SI
          INC       DI
          MOV       CX,Length_file_spec
          INC       CX                  ; for the terminating 0
          STD
          REP       MOVSB
          CLD
          MOV       b[DI],"*"

          RET
;==============================================================================
Fixup_first_8:
; Make the filename have only 8 chars, leaving in all file chars, then
; all wildcards that fit

          PUSH      CX,SI,DI

          MOV       CX,25               ; 20 max length, + 5 for *.* stuff
          MOV       DI,OFFSET File_spec
          XOR       AL,AL
          REPNE     SCASB
          NEG       CX
          ADD       CX,25


          MOV       SI,DI,OFFSET File_spec
          JCXZ      End_fixup_first_8
          MOV       AL,"."
          REPNE     SCASB
          MOV       CX,DI
          SUB       CX,SI
          CMP       CX,8
          JBE       End_fixup_first_8

          PUSH      DI

          ; now count how many NON wildcards, and keep first 8-(# nonwildcards)
          ; and trash the rest

          MOV       DX,CX               ; for storage
          XOR       BX,BX
          MOV       SI,OFFSET File_spec
L1:
          DEC       CX
          JCXZ      >L2
          LODSB
          ; count stuff
          CMP       AL,"?"
          JE        L1
          CMP       AL,"*"
          JE        L1
          INC       BX
          JMP       L1
L2:                           ; BX has # of nonwildcard chars
          CMP       BX,8
          IF A MOV BX,8
          NEG       BX
          ADD       BX,8      ; has # of wildcards to keep

          MOV       SI,DI,OFFSET File_spec
          MOV       CX,DX
          MOV       DX,8      ; chars stored
L3:
          TEST      DX,DX
          JZ        Put_back_ext
          LODSB
          CMP       AL,"?"
          JE        Check_store_file
          CMP       AL,"*"
          JE        Check_store_file
L4:
          STOSB
          DEC       DX
          JMP       L3

Check_store_file:
          TEST      BX,BX
          JZ        L3
          DEC       BX
          JMP       L4

Put_back_ext:
          POP       DI


          DEC       DI                            ; to pick up the .
          MOV       SI,OFFSET File_spec + 8
          XCHG      SI,DI
          MOV       CX,5                          ; .ext0 maxes at 5
          REP       MOVSB

End_fixup_first_8:
          POP       DI,SI,CX

          RET
;==============================================================================
Remove_multiple_star:
; Replace all strings of (*'s and ?'s with at least one *) with just a single
; *

          MOV       SI,BX,DI,OFFSET File_spec
          ; SI keeps track of beginning of current searching string
          ; BX keeps track of current spot in current string
          ; DI keeps track of current writing spot
Check_each_char:
          LODSB
          TEST      AL,AL
          JZ        End_remove_multiple_star
          CMP       AL,"*"
          JE        Check_wild_string
          CMP       AL,"?"
          JE        Check_wild_string
          STOSB
          JMP       Check_each_char
Check_wild_string:
          CALL      Do_wild_string                ; process the ***?*???
          JMP       Check_each_char               ; and keep going

End_remove_multiple_star:
          STOSB               ; put in the 0 at the end

          MOV       DI,OFFSET File_spec
          XOR       AL,AL
          MOV       CX,25
          REPNE     SCASB
          NEG       CX
          ADD       CX,24                         ; recalc'd cause we could
          MOV       Length_file_spec,CX           ; have changed it
                                                  ; don't count the 0 at end

          RET
;------------------------------------------------------------------------------
Do_wild_string:
;Pre : SI-1 -> a string of *'s and ?'s
;Post: string either kept in (if all ?) or replaced with a *

          DEC       SI                  ; now points to string
          MOV       BX,SI               ; store beginning of string
          XOR       CH,CH               ; 0 means no * yet
L1:
          LODSB
          CMP       AL,"*"
          JNE       >L2
          OR        CH,-1
          JMP       L1
L2:       CMP       AL,"?"
          JE        L1

          TEST      CH,CH               ; check if any *'s in string
          JZ        >L3                 ; nope, no *'s, so put back ?'s
          MOV       AL,"*"
          STOSB
          JMP       End_do_wild_string
          RET

L3:
          MOV       CX,SI               ; current location
          SUB       CX,BX               ; sub start location, has count of ?'s
          DEC       CX
          MOV       AL,"?"
          REP       STOSB               ; write in as many ?'s as we found

End_do_wild_string:
          DEC       SI                  ; so points to the non-*? char

          RET
;==============================================================================

High_path_spot      EQU       w[$]
Paths               EQU       w[$+2]


UnCrunch:
;
;Parameters Required:
;  DS:SI  ImageData source pointer.
;  ES:DI  Display address pointer.
;  CX     Length of ImageData source data.
;
          PUSH      SI                      ;Save registers.
          PUSH      DI
          PUSH      AX
          PUSH      CX
          PUSH      DX

          MOV       DX,DI                   ;Save X coordinate for later.
          XOR       AX,AX                   ;Set Current attributes.

LOOPA:    LODSB                              ;Get next character.
          CMP       AL,27                   ;Does user want to toggle the blink
          JNE       ForeGround              ;attibute?
          XOR       AH,128                  ;Done.
          JMP       short Next

ForeGround:
          CMP       AL,16                   ;If less than 16, then change the
          JAE       BackGround              ;foreground color.  Otherwise jump.
          AND       AH,0F0h                 ;Strip off old foreground.
          OR        AH,AL
          JMP       short Next

BackGround:
          CMP       AL,24                   ;If less than 24, then change the
          JE        NextLine                ;background color.  If exactly 24,
          JA        MultiOutput             ;then jump down to next line.
          SUB       AL,16                   ;Otherwise jump to multiple output
          PUSH      CX                      ;routines.
          MOV       CL,4
          SHL       AL,CL
          POP       CX
          AND       AH,0Fh                  ;Strip off old background.
          OR        AH,AL
          JMP       Short Next

NextLine:
          ADD       DX,row_bytes            ;If equal to 24,
          MOV       DI,DX                   ;then jump down to
          JMP       Short Next              ;the next line.

MultiOutput:
          CMP       AL,25                   ;If equal to 25,
          JNZ       NotMultiSpaces          ;then using the
          LODSB                             ;following code as
          PUSH      CX                      ;a count, output
          XOR       CH,CH                   ;said number of
          MOV       CL,AL                   ;spaces.
          MOV       AL,32
          JMP       StartOutput             ;Use below loop.

NotMultiSpaces:
          CMP       AL,26                   ;If equal to 26, then using
          JNZ       NormalLetter            ;the following two codes, display
          LODSB                             ;<x> number of <y> characters.
          DEC       CX                      ;Adjust main counter.
          PUSH      CX                      ;Display as many of
          XOR       CH,CH                   ;whatever the user
          MOV       CL,AL                   ;wants.
          LODSB                             ;Get character.

StartOutput:
          JCXZ      Stop                    ;Abort if already at zilch.
          REP       STOSW

Stop:     POP       CX
          DEC       CX                      ;Adjust main counter.

NormalLetter:
          STOSW                             ;Save screen letter.

Next:     JCXZ      Done_UnCrunch           ;Get next, unless CX
          LOOP      LOOPA                   ;has already one to zero.

Done_UnCrunch:
          POP       DX                      ;Restore registers.
          POP       CX
          POP       AX
          POP       DI
          POP       SI
          RET


; TheDraw Assembler Crunched Screen Image.   Width=80  Depth=25  Length=1401
length_help_screen equ 1401

help_screen db
        DB      16,7,'ZDir (ZanySoft Dir) is Copyright (C) 1990, 199'
        DB      '4 Christopher Kirmse.',24,24,12,'Usage:  ZDir [opti'
        DB      'ons] [d:][path][filespec[.ext]] [options]',24,7,'Op'
        DB      'tions:',24,25,5,'/',11,'H ',7,'/',11,'? ',7,'= This'
        DB      ' help screen',24,25,8,'/',11,'R ',7,'= Registration'
        DB      ' information',24,' /',11,'L',7,'filename = Write a '
        DB      'listing to filename, which may be a device',24,25,13
        DB      '(PRN or LPT1 for printer, AUX or COM1 for modem, et'
        DB      'c.)',24,25,8,'/',11,'A ',7,'= Write ANSI color code'
        DB      's to the file if one is specified by /L',24,25,8,'/'
        DB      11,'F ',7,'= File find - lists all files in specifie'
        DB      'd directory and in all',24,25,13,'directories below'
        DB      ' it',24,25,8,'/',11,'T ',7,'= Display a directory T'
        DB      'ree, including only specified files and',24,25,13,'u'
        DB      'sing the specified directory as the root of the tre'
        DB      'e',24,25,8,'/',11,'U ',7,'= Only list the entries m'
        DB      'atching a User extension',24,' /',11,'+A ',7,'or /',11
        DB      '-A ',7,'= Turn on or off archive attribute for all '
        DB      'found files',24,' /',11,'+H ',7,'or /',11,'-H ',7,'='
        DB      ' Turn on or off hidden attribute for all found file'
        DB      's',24,' /',11,'+R ',7,'or /',11,'-R ',7,'= Turn on '
        DB      'or off read only attribute for all found files',24,' '
        DB      '/',11,'+S ',7,'or /',11,'-S ',7,'= Turn on or off s'
        DB      'ystem attribute for all found files',24,25,8,'/',11,'Y'
        DB      ' ',7,'= Allow attribute changing to affect director'
        DB      'ies',24,'Options to override defaults:',24,'/',11,'N'
        DB      ' ',7,'/',11,'X ',7,'/',11,'Z ',7,'/',11,'D ',7,'= P'
        DB      'rimary sort by file Name, eXtension, siZe, or Date '
        DB      'and time',24,25,8,'/',11,'S ',7,'= Perform no Sort '
        DB      'at all (like the DOS dir command).',24,25,8,'/# = D'
        DB      'isplay in this many columns (',11,'1',7,', ',11,'2',7
        DB      ', ',11,'3',7,', ',11,'4',7,', or ',11,'6 ',7,'or ',11
        DB      'W',7,')',24,25,8,'/',11,'K ',7,'= Toggle wait for k'
        DB      'ey at the end of every displayed screen',24,25,3,12,'T'
        DB      'o configure every option and color of ZDir, run the'
        DB      ' program ZDircfg',24

Help:     To_video  ES

          call      clr_scr

          MOV       AX,Max_row_x_row
          MOV       Bottom_row,AX
          CALL      Cursor_to_row

          XOR       DI,DI
          MOV       SI,OFFSET help_screen
          MOV       CX,length_help_screen
          CALL      UnCrunch

          XOR       AH,AH
          INT       16h

Quit_help:
          MOV       AL,Help_EC
          JMP       Exit

; TheDraw Assembler Crunched Screen Image.   Width=80  Depth=25  Length=916
print_form_scr_length EQU 916

print_form_screen label byte
        DB      16,7,'Name',25,10,26,62,'_',24,24,'Street Address ',26
        DB      62,'_',24,24,'City',25,10,26,34,'_ State ',26,4,'_ Z'
        DB      'ip ',26,10,'_',24,24,'Where did you get ZDir? ',26,53
        DB      '_',24,24,25,26,11,'ZanySoft Dir, version 2.1',24,25,8
        DB      12,'Remember, if you use ZDir, you are obligated to '
        DB      'pay for it.',24,7,'___ $10 I am registering ZDir fo'
        DB      'r use on one computer.  Please send me my',24,25,7,'r'
        DB      'egistration number so I can upgrade configuration c'
        DB      'olors and defaults',24,25,7,'to all future versions'
        DB      ' of ZDir.',24,25,3,'The following three items do NO'
        DB      'T include registration:',24,'___  $5 I would like a'
        DB      ' 3.5" disk with the current version of ZDir.',24,'_'
        DB      '__  $5 I would like a 5.25" disk with the current v'
        DB      'ersion of ZDir.',24,25,3,'The following item is ava'
        DB      'ilable to registered users ONLY:',24,'___  $5 I wou'
        DB      'ld like the laser printed version of the manual.',24
        DB      24,26,6,'_ Total.  Enclose cash or a check drawn on '
        DB      'US currency made out to',24,25,15,11,'Christopher K'
        DB      'irmse',7,'.  Send this form and payment to:',24,25,25
        DB      12,'ZanySoft',24,25,25,'9303 Arabian Ave.',24,25,25,'V'
        DB      'ienna, VA  22182',24,7,'Write any comments below',25
        DB      30,'Hit Print Screen to print',24

Register:
          To_video  ES

          call      clr_scr

          mov       ax,max_row_x_row
          mov       bottom_row,ax
          CALL      Cursor_to_row

          MOV       SI,OFFSET Print_form_screen
          XOR       DI,DI
          MOV       CX,Print_form_scr_length
          CALL      UnCrunch

          XOR       AH,AH
          INT       16h

          MOV       AL,Reg_screen_EC
          JMP       Exit

;;num_dirs dw ($ - paths) shr 6     ; about 37 directories

