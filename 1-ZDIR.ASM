;   A86 +E 1-Zdir.asm 15-Zdir.asm 2-Zdir.asm # End-Zdir.asm TO Zdir.com
;
;                          ZanySoft Dir version 2.1
;                          ========================
;                              by Chris Kirmse
;

Version_spot        EQU       100h + 78

;Exit codes:
Normal_EC           EQU       0
Path_search_EC      EQU       1
File_error_EC       EQU       2
Invalid_drive_EC    EQU       3
Help_EC             EQU       4
Reg_screen_EC       EQU       5


Encrypt_code        EQU       11001010xB

Enter_Key           EQU       13
Backspace           EQU       8
Escape_key          EQU       27
Space               EQU       32

down_arrow_key      EQU       50h

black               equ       00h
blue                equ       01h
green               equ       02h
cyan                equ       03h
red                 equ       04h
magenta             equ       05h
brown               equ       06h
ltgray              equ       07h
darkgray            equ       08h
ltblue              equ       09h
ltgreen             equ       0Ah
ltcyan              equ       0Bh
ltred               equ       0Ch
ltmagenta           equ       0Dh
yellow              equ       0Eh
white               equ       0Fh
bold                equ       08h
blink               equ       80h

Blink               EQU       128

Read_only           EQU       0000_0001xB
Hidden              EQU       0000_0010xB
System              EQU       0000_0100xB
Volume_label        EQU       0000_1000xB
Directory           EQU       0001_0000xB
Archive             EQU       0010_0000xB
Network             EQU       1000_0000xB


Attribute = Read_only + Hidden + System + Directory + Archive + Volume_label

Max_files           EQU       1450

Row                 EQU       160
Col                 EQU       2



Archive_char        EQU       "A"
Hidden_char         EQU       "H"
Read_only_char      EQU       "R"
System_char         EQU       "S"
Network_char        EQU       "N"

Entry_Length        EQU       23

Intersection_up     EQU       "Ï"
Intersection_down   EQU       "Ñ"
Horizontal_line     EQU       "Í"
Vertical_line       EQU       "³"

EOF                 EQU       26
CR                  EQU       13
LF                  EQU       10

No_sort_factor      EQU       10

Vol_scr_spot        EQU       59*Col

Tree_level_width    EQU       8
Tree_levels         EQU       5
tree_start_spaces   equ       13        ; for files & size


To_video MACRO ;Register

        MOV         #1,Video_segment

         #EM

Restore MACRO ;Register

        MOV     #1,CS

        #EM

Encrypt MACRO ;Name,string (in SINGLE quotes only)
#1 DB
     #CZ2
          DB '#Z' XOR Encrypt_code
     #EC
        #EM

          ORG       100h

Main:     JMP       Pastdata

          DB 3 DUP Backspace
Copyright DB "ZDir Copyright (C) 1990, 1994 Christopher Kirmse",CR,LF ;56 chars
          DB "Type ZDir /? for help",EOF                  ;22 chars

Version_spot EQU $
Version   DB "2.1"

                    DW        9                   ; Old sort factor
Auto_detect         EQU       7
Number_of_columns   DB        Auto_detect
Left_to_right       DB        0
;-- new to zdir 1.1
                    DB        0
;-- new to zdir 1.2
BIOS                DB        0
Clear_Screen        DB        0
Print_graphics      DB        -1
Wait_for_key        DB        -1
;;;Zippy_check         DB        -1     NO MORE ZIPPY
Put_star_in_front   DB        -1        ; replaced with * in front, 2.0
;;;Auto_detect         DB        -1     NOW IN Number_of_columns
                    DB        0         ; useless.  if less than col 2, do 1
Columns_2           DB        20
Columns_3           DB        40
Columns_4           DB        60
Columns_6           DB        90
;-- new to zdir 1.3
Show_dot_file       DB        -1
Add_dir_entries     DB        0
Sort_factor         DW
Sort_factor_1       DW        9
Sort_factor_2       DW        9
Past_factors        DW        ?         ; doesn't matter
;-- new to zdir 1.4
Entry_one_color     DB        0
Commas_in_file_size DB        0
Hidden_show         DB        -1
;-- new to zdir 2.0
Sort_factor_3       DW        9
Sort_factor_4       DW        9
Really_past_factors DW        9
Read_only_show      DB        -1
System_show         DB        -1
Volume_label_show   DB        -1
PS_none             EQU       0
PS_dir_first        EQU       1
PS_dir_last         EQU       2
Presort             DB        PS_dir_first
Period_extension    DB        0
Totals_always       EQU       0
Totals_AB_only      EQU       1
Totals_never        EQU       2
Disk_totals         DB        Totals_always
;-- new to zdir 2.1
;-- none
;------------------------------------------------------------------------------

just_user_ext       DB       0

Lines_printed       DB        ?
Star_dot_star       DB        "*.*",0
Printer_handle      DW        4

Change_dir_attrib   DB        0                   ; Can't make a default!!

user_ext            equ       -1
not_user_ext        equ       0

extension_data      DB

extension1          DB        "COM",ltred  ,user_ext
extension2          DB        "EXE",ltcyan ,user_ext
extension3          DB        "BAT",White  ,user_ext
extension4          DB        "ZIP",magenta,not_user_ext
extension5          DB        "ARJ",magenta,not_user_ext
extension6          DB        "LZH",magenta,not_user_ext
extension7          DB        "ZOO",magenta,not_user_ext
extension8          DB        "ARC",magenta,not_user_ext
extension9          DB        "TAR",magenta,not_user_ext
extension10         DB        "TRZ",magenta,not_user_ext
extension11         DB        "BAS",ltcyan ,not_user_ext
extension12         DB        "PAS",ltred  ,not_user_ext
extension13         DB        "INC",ltred  ,not_user_ext
extension14         DB        "C  ",ltgreen,not_user_ext
extension15         DB        "CPP",ltgreen,not_user_ext
extension16         DB        "CXX",ltgreen,not_user_ext
extension17         DB        "H  ",ltgreen,not_user_ext
extension18         DB        "HPP",ltgreen,not_user_ext
extension19         DB        "HXX",ltgreen,not_user_ext
extension20         DB        "PRJ",cyan   ,not_user_ext
extension21         DB        "MAK",cyan   ,not_user_ext
extension22         DB        "OBJ",red    ,not_user_ext
extension23         DB        "LIB",red    ,not_user_ext
extension24         DB        "ASM",ltred  ,not_user_ext
extension25         DB        "A86",ltred  ,not_user_ext
extension26         DB        "LST",red    ,not_user_ext
extension27         DB        "SYM",red    ,not_user_ext
extension28         DB        "MAP",red    ,not_user_ext
extension29         DB        "Z86",yellow ,not_user_ext
extension30         DB        "ZDV",yellow ,not_user_ext
extension31         DB        "SYS",green  ,not_user_ext
extension32         DB        "DRV",green  ,not_user_ext
extension33         DB        "ME ",white  ,not_user_ext
extension34         DB        "DOC",white  ,not_user_ext
extension35         DB        "TXT",white  ,not_user_ext
extension36         DB        "WP ",white  ,not_user_ext
extension37         DB        "BAK",cyan   ,not_user_ext
extension38         DB        "BK?",cyan   ,not_user_ext
extension39         DB        "NDX",ltgreen,not_user_ext
extension40         DB        "PRG",ltgreen,not_user_ext
extension41         DB        "DBF",ltgreen,not_user_ext
extension42         DB        "EXT",ltgreen,not_user_ext
extension43         DB        "DAT",ltgreen,not_user_ext
extension44         DB        "INX",yellow ,not_user_ext
extension45         DB        "WK?",yellow ,not_user_ext
extension46         DB        "XL?",yellow ,not_user_ext
extension47         DB        "PIC",yellow ,not_user_ext
extension48         DB        "CGM",yellow ,not_user_ext
extension49         DB        "GIF",yellow ,not_user_ext
extension50         DB        "WPG",yellow ,not_user_ext

End_extension_data  DB

num_extensions      equ     (offset end_extension_data-offset extension_data)/5


File_color          DB        ltgray
File_usage_color    DB        white
Directory_color     DB        ltmagenta
Hidden_color        DB        green
Volume_color        DB        ltred
Time_date_color     DB        white
Top_msg_color       DB        cyan
Top_data_color      DB        white
Graphics_color      DB        ltblue
Length_color        DB        yellow
Attribute_color     DB        cyan
Date_color          DB        red
Time_color          DB        brown
Totals_msg_clr      DB        cyan
Totals_color        DB        white
Empty_color         DB        ltgray
Signature_color     DB        cyan
ZS_color            DB        ltcyan
tree_graphics_color db        ltblue
tree_dir_color      db        ltmagenta
tree_files_color    db        ltcyan
tree_size_color     db        white
tree_text_color     db        ltred
any_key_attrib      db        cyan
bracket_attrib      db        ltblue
no_files_color      db        ltred
write_file_color    db        ltred
just_user_ext_color db        cyan
megabyte_size_color db        ltred
;------------------------------------------------------------------------------
File_error_msg      DB        "Error!  NOT w"
Length_file_error EQU $ - File_error_msg
File_message        DB        "riting to file "
Length_file_message EQU $ - File_message
File_close_err_msg  DB        "Error! Can't close file"
Length_file_close_err EQU $ - File_close_err_msg

Encrypted_area      DB

Encrypt Any_key_msg,' Press a key to continue '
Length_Any_key EQU $ - Any_key_msg

Encrypt Dir_size_msg,'<Dir>'
Length_Dir_size EQU $ - Dir_size_msg

Encrypt Vol_size_msg,'<Vol>'
Length_Vol_size EQU $ - Vol_size_msg

Encrypt Total_size_msg1,' files totalling '
Length_Total_size1 EQU $ - Total_size_msg1

Encrypt Total_size_msg15,' file totalling '
Length_total_size15 EQU $ - Total_size_msg15


Encrypt Total_size_msg2,' bytes using '
Length_Total_size2 EQU $ - Total_size_msg2

Encrypt Total_size_msg3,' bytes of disk space.'
Length_Total_size3 EQU $ - Total_size_msg3

Encrypt Volume_label_msg,'Volume - '
Length_Volume_label EQU $ - Volume_label_msg

Encrypt signature1_msg,'ZDir'
Length_signature1 EQU $ - signature1_msg

Encrypt signature2_msg,' v2.1, by '
Length_signature2 EQU $ - signature2_msg

Encrypt signature3_msg,'any'
Length_signature3 EQU $ - signature3_msg

Encrypt signature4_msg,'oft'
Length_signature4 EQU $ - signature4_msg

Encrypt Path_msg,'Path: '
Length_path EQU $ - Path_msg

Encrypt Free_space_msg,' bytes available out of '
Length_Free_space EQU $ - Free_space_msg

Encrypt Total_space_msg,' total bytes on drive '
Length_Total_space EQU $ - Total_space_msg

Encrypt No_files_msg,'No files found'
Length_No_files EQU $ - No_files_msg

encrypt no_files2_msg,' - no user extensions'
length_no_files2 equ $ - no_files2_msg

Encrypt Invalid_drive_msg,'Invalid drive '
Length_Invalid_drive EQU $ - Invalid_drive_msg

Encrypt File_listing_msg,'File listing of '
Length_file_listing EQU $ - File_listing_msg

Encrypt And_sub_dirs_msg,'   and the '
Length_and_sub_dirs EQU $ - And_sub_dirs_msg

encrypt dirs_under_msg1,' director'
length_dirs_under1 equ $ - dirs_under_msg1

Encrypt Dirs_under_msg2,'ies'
Length_dirs_under2 EQU $ - Dirs_under_msg2

encrypt dirs_under_msg3,' under it, of files of the form '
length_dirs_under3 equ $ - dirs_under_msg3

Encrypt Totals_msg,'Totals --'
Length_totals_msg EQU $ - Totals_msg

encrypt tree_header,'Files  Bytes Path'
length_tree_header equ $ - tree_header

encrypt just_user_ext_str,'Files matching extensions '
len_just_user_ext_str equ $ - just_user_ext_str
          
Bytes_to_unencrypt EQU $ - Encrypted_Area
;------------------------------------------------------------------------------
PastData:

;;         testing of the new print_number
;          push      es
;          mov       es,0b800h
;          xor       di,di
;          and       b right_justify,0
;          mov       ax,0ffffh
;          mov       dx,0ffffh
;          mov       ch,0fh
;          call      print_number
;          xor       ax,ax
;          int       16h
;          pop       es

          MOV       AX,3300h
          INT       21h                           ; Get break status
          MOV       b Break_status,DL

          MOV       AX,3301h
          MOV       DL,1
          INT       21h                           ; Set break status on

          MOV       AH,0Fh
          INT       10h
          MOV       Video_segment,0B800h
          CMP       AL,7
          JNE       >L00
          MOV       Video_segment,0B000h
          JMP       >L2
L00:
          cmp       al,13h
          ja        >l2
          cmp       al,4
          jae       >l0
;          CMP       AL,2
;          JE        >L005
;
;          CMP       AL,3
;          JNE       >L0
L005:
          TEST      BH
          JNZ       >L1
          JMP       >L2
L0:

          MOV       AX,3
          INT       10h
L1:
          MOV       AX,0500h                      ;Page 0
          INT       10h
L2:
          MOV       AH,3
          INT       10h

          TEST      DH
          IF NZ DEC DH

          push      dx

          MOV       AX,1A00h
          INT       10h
          CMP       AL,1Ah
          JE        >L3                 ; if is EGA or newer
          MOV       AL,25               ; since not, must be 25 lines then!
          mov       bx,80
          JMP       >L4
L3:
          ; this don't work pre-EGA!!!!!
          PUSH      DS
          xor       ax,ax
          MOV       DS,AX
          MOV       al,[0484h]
          mov       bx,[044Ah]
          POP       DS
          INC       AL
L4:
          mov       w screen_cols,bx
          shl       bx,1
          mov       w row_bytes,bx
          mov       b screen_rows,al
          mov       lines_printed,al
          dec       al
          xor       ah,ah
          mov       bx,row_bytes
          mul       bx
          mov       w max_row_x_row,ax            ; 24*row, normally

          pop       dx

          mov       ax,row_bytes
          mov       dl,dh
          xor       dh,dh
          mul       dx
          add       ax,row_bytes
          mov       bottom_row,ax


          CALL      Cursor_to_row

          XOR       AX,AX
          MOV       DI,OFFSET Total_size
          MOV       CX,Length_to_Zero
          REP       STOSW
          
          mov       si,offset extension_data
          mov       cx,num_extensions
          xor       bx,bx
l1:
          cmp       b[si+4],user_ext
          if e inc bx
          add       si,5
          loop      l1

          mov       b num_user_extensions,bl

          and       b[ext_check+3],0

          MOV       b New_off_attrib,-1

          MOV       b Initial_num_columns,AL,Number_of_columns
          ; because Auto_detect is in there, need to keep for /f


          mov       dx,offset dta
          mov       ah,1ah
          int       21h                           ;set dta

Capitalize:
          MOV       DI,81h
          MOV       CX,80h
Check_letter:
          CMP       b [DI],"a"
          JB        cap_next
          CMP       b [DI],"z"
          JA        cap_next
          AND       b [DI],NOT 20h
Cap_next: INC       DI
          LOOP      Check_letter


          MOV       DI,81h
          XOR       CH,CH
          MOV       CL,[80h]
          TEST      CX
          IF Z JMP No_switches

Search_switch:
          MOV       AL,b[DI]
          INC       DI
          CMP       AL,"/"
          JE        found_delm
          loop      search_switch
          JMP       No_more_switches
;------------------------------------------------------------------------------
found_delm:
          and       b[DI-1],0
Get_next_switch:
          MOV       SI,DI
          LODSB

          CMP       AL,"H"
          IF E JMP Help

          CMP       AL,"?"
          IF E JMP Help

          CMP       AL,"R"
          IF E JMP Register

L0:
          CMP       AL,"S"
          JNE       >L1
          MOV       Sort_Factor,no_sort_factor
          JMP       got_switch
L1:

L2:
          CMP       AL,"1"
          JNE       >L25
          MOV       Number_of_columns,1
          JMP       GotColumn
L25:
          CMP       AL,"2"
          JNE       >L275
          MOV       Number_of_columns,2
          JMP       GotColumn

L275:
          CMP       AL,"3"
          JNE       >L3
          MOV       Number_of_columns,3
          JMP       GotColumn
L3:
          CMP       AL,"4"
          JNE       >L35
          MOV       Number_of_columns,4
          JMP       GotColumn

L35:
          CMP       AL,"6"
          JNE       >L37        
          MOV       Number_of_columns,6
          JMP       GotColumn

L37:
          CMP       AL,"W"
          JNE       >L4
          MOV       Number_of_columns,6
          JMP       GotColumn

L4:
          CMP       AL,"X"
          JNE       >L5
          MOV       Sort_factor,18
          JMP       got_switch
L5:
          CMP       AL,"D"
          JNE       >L6
          MOV       Sort_factor,3
          MOV       Sort_factor_2,1               ; secondary time
          JMP       got_switch
L6:
          ; sorting by time eliminated -- it's useless

          CMP       AL,"T"
          JNE       >L7

          OR        b Totals_only,-1
          MOV       b Path_search,-1
          JMP       got_switch

L7:
          CMP       AL,"Z"
          JNE       >L8
          MOV       Sort_factor,5
          JMP       got_switch
L8:
          CMP       AL,"N"
          JNE       >L9
          MOV       Sort_factor,9
          JMP       got_switch
L9:
;          CMP       AL,"A"             ; no more sort by attribute
;          JNE       >L10
;          and       Sort_factor,0
;          JMP       got_switch
L10:
          CMP       AL,"A"
          JNE       >L11
          OR        b ANSI_printer,-1
          JMP       got_switch

L11:
          CMP       AL,"+"
          JNE       >L12

          OR        b Change_Attrib,-1

          XOR       AL,AL
          STOSB

          DEC       CX

          MOV       SI,DI
          LODSB

          CMP       AL,Archive_char
          JNE       >A1

          OR        b New_on_Attrib,Archive
          JMP       got_switch

A1:       CMP       AL,Hidden_char
          JNE       >A2

          OR        New_on_Attrib,Hidden
          JMP       got_switch

A2:       CMP       AL,Read_only_char
          JNE       >A3

          OR        New_on_Attrib,Read_only
          JMP       got_switch

A3:       CMP       AL,System_char
          IF NE JMP Help

          OR        New_on_Attrib,System
          JMP       got_switch

L12:      CMP       AL,"-"
          JNE       >L13

          OR        Change_Attrib,-1

          XOR       AL,AL
          STOSB

          DEC       CX

          MOV       SI,DI
          LODSB

          CMP       AL,Archive_char
          JNE       >B1

          AND       b New_off_Attrib,not Archive
          JMP       got_switch
B1:
          CMP       AL,Hidden_char
          JNE       >B2

          AND       New_off_Attrib,not Hidden
          JMP       got_switch
B2:
          CMP       AL,Read_only_char
          JNE       >B3

          AND       New_off_Attrib,not Read_only
          JMP       got_switch
B3:
          CMP       AL,System_char
          IF NE JMP Help

          AND       New_off_Attrib,not System
          JMP       got_switch

L13:      CMP       AL," "
          JE        >L135

          TEST      AL
          JNZ       >L14
L135:
          DEC       CX,2
          JMP       Search_switch

L14:
          CMP       AL,"F"
          JNE       >L15
          MOV       b Path_search,-1
          JMP       got_switch

L15:
          CMP       AL,"K"
          JNE       >L16
          NOT       Wait_for_key
          JMP       got_switch

L16:
          cmp       al,"U"
          jne       >l17
          or        just_user_ext,-1
          jmp       got_switch

L17:

L18:

L19:

L20:
          CMP       AL,"L"
          JNE       >L21

          and       wait_for_key,0

          PUSH      CX

          PUSH      DI
          INC       DI
          MOV       BX,DX,SI,DI

Find_End_Char:
          LODSB
          CALL      Check_AL_path_char
          JNC       Find_End_char
          MOV       DI,SI
          DEC       DI
F1:
          XOR       AL,AL
          STOSB

          SUB       BX,SI
          NEG       BX

          To_video  ES
          MOV       DI,Bottom_row

          MOV       AX,4300h
          INT       21h
          JNC       >F2

          MOV       AH,3Ch
          XOR       CX,CX
          INT       21h


          JC        >F2

          MOV       Printer_Handle,AX
          OR        b Printer,-1

          MOV       AH,Write_file_color
          MOV       AL,"W"
          CALL      Screen_char
          JMP       >F3

F2:
          MOV       AH,Write_file_color
          MOV       SI,OFFSET File_error_msg
          MOV       CX,Length_file_error
          CALL      Print_to_screen
F3:
          MOV       SI,OFFSET File_message
          MOV       CX,Length_file_message
          CALL      Print_to_screen

          MOV       CX,BX
          MOV       SI,DX
          CALL      Print_to_screen

          call      screen_scroll_up

          Restore   ES

          MOV       CX,BX
          MOV       DI,DX
          XOR       AL,AL
          REP       STOSB

          POP       DI
          POP       CX

          JMP       got_switch
L21:
          CMP       AL,"Y"
          JNE       >L22
          OR        b Change_dir_attrib,-1
          JMP       got_switch
L22:
          ; no more toggle of commas in file size
L23:

          CMP       AL,"/"
          JE        got_switch


          CMP       AL,Enter_key
          JE        No_more_switches

          JMP       Help                          ;Invalid switch

GotColumn:
          OR        b Col_Override,-1

got_switch:
          XOR       AL,AL
          STOSB
          JMP       Get_next_switch

No_more_switches:


;------------------------------------------------------------------------------
No_switches:
          XOR       AX,AX
          MOV       DI,OFFSET Total_size
          MOV       CX,Length_to_always_Zero
          REP       STOSW

          CALL      Clear_string_spot
          
          MOV       Commas_in_numbers,AL,Commas_in_file_size

          MOV       DI,81h

          XOR       CX,CX
          MOV       CL,[80h]
          JCXZ      Default

Find_first_char:
          MOV       AL,b[DI]
          CALL      Check_AL_any_char
          JNC       Check_string
          INC       DI
          LOOP      Find_first_char
          JMP       short Default

Check_string:
          MOV       path_spot,DI

          ADD       DI,63                         ; max path length of 63
                                                  ; for space for vol label
          CMP       DI,0FFh
          IF A MOV DI,0FFh
          XOR       AL,AL
          STOSB
          MOV       DI,Path_spot
Each_Char:
          MOV       AL,b[DI]
          CALL      Check_AL_any_char
          JC        Make_ASCIIZ
          INC       DI
          JMP       Each_char

Default:
          MOV       Path_spot,SI,DI,82h
          MOV       CX,78h
          XOR       AL,AL
          REP       STOSB

Make_ASCIIZ:
          XOR       AL,AL
          STOSB

Add_drive:
          MOV       DI,Path_spot
          INC       DI
          MOV       AL,":"
          SCASB
          JE        Get_drive

          MOV       DI,Path_spot
          SUB       DI,2
          MOV       Path_spot,DI
          MOV       AH,19h
          INT       21h
          ADD       AL,"A"
          STOSB
          MOV       AL,":"
          STOSB

Get_drive:
          MOV       SI,DI,Path_spot
          LODSB
          CMP       AL,"a"
          JB        Capital_drive
          SUB       AL,20h
          STOSB
Capital_drive:
          SUB       AL,"A"-1

Get_size:
          MOV       AH,36h
          MOV       DL,AL
          MOV       FCB_drive,AL
          INT       21h
          CMP       AX,-1
          IF E JMP Invalid_drive
          PUSH      DX
          MUL       CX
          MOV       Bytes_per_sector,AX
          MUL       BX
          MOV       w[Free_space],AX
          MOV       w[Free_space+2],DX
          POP       DX

          MOV       AX,Bytes_per_sector
          MUL       DX

          MOV       w[Total_space],AX
          MOV       w[Total_space+2],DX

Add_Path:
          MOV       DI,Path_spot
          INC       DI,2
          CMP       b[DI],"\"
          IF E JMP Last_check
          MOV       SI,DI
          MOV       DI,Data_area
          XOR       CX,CX

Store_old_path:
          MOVSB
          INC       CX
          TEST      b[SI]
          JNZ       Store_old_path

          PUSH      CX
          MOV       DI,Path_spot
          INC       DI,2
          MOV       AL,"\"
          STOSB     
          MOV       SI,Path_spot
          LODSB
          SUB       AL,"A"-1
          MOV       DL,AL
          MOV       AH,47h
          INC       SI,2
          INT       21h

          MOV       DI,SI
          MOV       CX,63
          XOR       AL,AL
          REPNE     SCASB
          CMP       b[DI-2],"\"
          JNE       >L1
          DEC       DI
          JMP       short Add_old_end

L1:       MOV       b[DI-1],"\"

Add_old_end:                                      ;If you did zdir a:data
          MOV       SI,Data_area                  ;This puts back the data
          POP       CX                            ;on the end
          REP       MOVSB
          XOR       AX,AX
          STOSB                                   ;Make ASCIIZ

Last_check:
          CMP       b Not_first_path_search,0
          JNZ       Start_search

          MOV       DI,Path_spot
          XOR       AL,AL
          MOV       CX,64
          REPNE     SCASB               ; go to end of file spec
          NEG       CX
          ADD       CX,64
          MOV       AL,"\"
          STD
          REPNE     SCASB
          CLD
          JE        >L1
          MOV       AL,":"
          MOV       CX,3
          REPNE     SCASB
L1:
          MOV       SI,DI
          MOV       CX,13
L2:
          LODSB
          TEST      AL,AL
          JZ        Do_check_dir_file_spec
          CMP       AL,"*"
          JE        Start_search
          CMP       AL,"?"
          JE        Start_search
          JMP       L2

Do_check_dir_file_spec:       ; check if did like C:\chris
          MOV       DX,Path_spot
          MOV       AX,4300h
          INT       21h                           ; get attrib (if exist)
          JC        Start_search
          TEST      CL,Directory
          JZ        Start_search
          MOV       DI,Path_spot
          MOV       CX,64
          XOR       AL,AL
          REPNE     SCASB
          CMP       b[DI-2],"."
          JNE       >L1
          MOV       AL,b[DI-3]          ; check in case \..
          CALL      Check_AL_file_char
          JC        >L1
          DEC       DI                             ; in case \chris.
L1:
          CMP       b[DI-2],"\"
          JE        Start_search                  ; no A:\\!!!!
          MOV       b[DI-1],"\"
          and       b[DI],0

Start_search:
;------------------------------------------------------------------------------
; first, get the volume label and serial number

          call      do_serial_number              ; that loads in the serial #

          xor       al,al
          mov       di,offset fcb_to_zero
          mov       cx,25
          rep       stosb

          mov       dx,offset fcb_vol
          mov       ah,11h
          int       21h                     ; DOS Services  ah=function 11h
                                            ;  find filename, FCB @ ds:dx
          mov       b exist_vol_label,0
          test      al
          jnz       fix_dir_names

          or        exist_vol_label,-1
          mov       di,offset fcb_drive+1
          mov       si,offset fcb_file
          mov       cx,11
          rep       movsb               ; store vol label till later

;------------------------------------------------------------------------------
; next, make all directory names <= 12 chars long
fix_dir_names:

          MOV       DI,Path_spot
          MOV       CX,80                         ; max length is like 64
          XOR       AL,AL
          REPNE     SCASB
          NEG       CX
          ADD       CX,80                         ; now has length


          MOV       DI,Path_spot
          MOV       AL,"\"
          REPNE     SCASB
          JNE       Take_out_dot_dot

Check_dir_length:
          MOV       BX,CX                         ; store location
          MOV       SI,DI
          REPNE     SCASB
          JNE       Take_out_dot_dot
          SUB       BX,CX
          CMP       BX,12
          JBE       Check_dir_length

          ; fix directory name
          DEC       DI                            ; SCASB goes one past
          PUSH      CX
          XCHG      SI,DI
          ADD       DI,12                         ; right after prev directory
          MOV       CX,80                         ; plenty of length
          REP       MOVSB
          POP       CX
          JMP       Check_dir_length


Take_out_dot_dot:
          MOV       DI,Path_spot
          MOV       CX,80h
          XOR       AL,AL
          REPNE     SCASB
          NEG       CX
          ADD       CX,80h                        ; don't go past end of spec
          MOV       DI,Path_spot
          MOV       AL,"\"                        ;Take out all ..
L2:
          REPNE     SCASB
          TEST      CX
          IF Z JMP Start_real_search
          CMP       b[DI],"."
          JNE       L2
          CMP       b[DI+1],"."
          JE        Double_dot

          CMP       b[DI+1],"\"
          JE        Single_dot
          mov       al,b[di+1]
          call      check_al_file_char
          jc        single_dot
          
          JMP       L2

Double_dot:
          PUSH      CX

          PUSH      DI
          MOV       SI,DI
          INC       SI,2

          MOV       DX,CX,80h
          MOV       DI,OFFSET Data_area
          REP       MOVSB
          POP       DI

          DEC       DI,2
          CMP       b[DI],":"
          JE        >L1
          STD
          MOV       CX,13
          REPNE     SCASB
          IF NE MOV DI,81h
          CLD
L1:
          INC       DI
          CMP       b[Data_area],"\"
          IF NE INC DI
          MOV       SI,Data_Area
          MOV       CX,DX
          REP       MOVSB

          POP       CX
          JMP       Take_out_dot_dot

Single_dot:
          PUSH      CX
          PUSH      DI
          MOV       SI,DI
          INC       SI
          MOV       DI,OFFSET Data_area
          MOV       DX,CX,80h
          REP       MOVSB
          POP       DI
          CMP       b[Data_area],"\"
          IF E DEC DI
          
          MOV       SI,OFFSET Data_area
          MOV       CX,DX
          REP       MOVSB

          POP       CX
          JMP       Take_out_dot_dot
;------------------------------------------------------------------------------
Start_real_search:
          XOR       AL,AL
          MOV       SI,DI,Path_Spot
          MOV       CX,80h
          REPNE     SCASB
          MOV       DX,DI
          STD
          DEC       DI
          MOV       AL,"\"
          MOV       CX,80h
          REPNE     SCASB
          CLD
          INC       DI,2                          ;ASCIIZ
          MOV       CX,DI
          SUB       CX,SI                         ;Length of path to last \
          SUB       DX,DI
          DEC       DX
          CMP       DX,20                         ; Fixup_file_spec 'll shorten
          IF A MOV DX,20                          ; each individual part
          MOV       Length_file_spec,DX
          MOV       Length_Full_Path,CX
          MOV       SI,Path_Spot
          MOV       DI,OFFSET Full_path
          REP       MOVSB
          XOR       AL,AL
          STOSB                         ; make the full_path asciiz!
          MOV       DI,OFFSET File_spec
          MOV       CX,Length_file_spec
          INC       CX                  ; store the 0, asciiz!
          REP       MOVSB

          TEST      Not_first_path_search
          IF Z CALL Fixup_file_spec     ; Add *'s where necessary


          MOV       DI,Path_spot
          ADD       DI,Length_full_path
          MOV       SI,OFFSET Star_dot_star
          MOV       CX,4
          REP       MOVSB

L3:
;------------------------------------------------------------------------------
          CALL      Clear_FileName

          MOV       AH,4Eh                        ;Find first file
          MOV       DX,path_spot
          MOV       CX,Attribute
          INT       21H
          IF C JMP Done

          MOV       DI,OFFSET Data_Area
;------------------------------------------------------------------------------
Next_filename:

          MOV       AL,b Attrib
          TEST      Hidden_show
          JNZ       >L1
          TEST      AL,Hidden
          JNZ       Wrong_attrib
L1:
          TEST      Read_only_show
          JNZ       >L2
          TEST      AL,Read_only
          JNZ       Wrong_attrib
L2:
          TEST      System_show
          JNZ       >L3
          TEST      AL,System
          JNZ       Wrong_attrib
L3:
          TEST      Volume_label_show
          JNZ       >L4
          TEST      AL,Volume_label
          JNZ       Wrong_attrib
L4:
          JMP       Right_attrib

Wrong_attrib:
          JMP       Get_next_file
Right_attrib:
          test      just_user_ext,-1
          jz        >l1
          call      check_if_ext
          jc        get_next_file
l1:


          PUSH      DI
          MOV       SI,OFFSET File_spec
          MOV       DI,OFFSET Filename
          CALL      file_match
          POP       DI
          TEST      AL
          JZ        Get_next_file                 ; it didn't match

L2:
          TEST      Show_dot_file
          JNZ       >L3

          CMP       b[FileName],"."
          JE        Get_next_file
l3:

          TEST      b Attrib,Directory OR Volume_label
          IF NZ INC w Dir_entries

          INC       w Number_of_files
                                                  ;DS:DX MUST always
                                                  ;point to path_spot
          TEST      Change_Attrib
          IF Z CALL Fix_FileName

          MOV       SI,OFFSET Attrib
          MOV       CX,Entry_Length
          REP       MOVSB                         

          PUSH      DX

          MOV       DX,w[Size+2]
          MOV       AX,w[Size]

          ADD       w[Total_Size],AX
          ADC       w[Total_Size+2],DX

          CALL      Size_to_Clusters              ;from DX:AX to DX:AX

          ADD       w[Consumption],AX             ;If not exactly 1 cluster
          ADC       w[Consumption+2],DX           ;long, add entire cluster

          POP       DX

          CMP       Number_of_files,Max_files
          JNE       Get_next_file
          OR        b Truncated,-1
          OR        b Any_truncated,-1
          JMP       short Done

Get_next_file:
          CALL      Clear_FileName
          MOV       AH,4Fh                        ;Find next file
          INT       21H
          JC        DONE

          JMP       Next_Filename
;------------------------------------------------------------------------------
Invalid_Drive:
          CALL      UnEncrypt
          To_video  ES
          MOV       DI,Bottom_row
          MOV       SI,OFFSET Invalid_drive_msg
          MOV       CX,Length_Invalid_drive
          MOV       AH,Write_file_color
          CALL      Print_string
          MOV       AL,Invalid_Drive_EC
          JMP       Exit

;------------------------------------------------------------------------------
Done:
          CMP       w Number_of_files,1
          IF NE JMP Print_start
          MOV       SI,OFFSET Data_area
          LODSB
          TEST      AL,Directory
          IF Z JMP Print_start

          MOV       DI,OFFSET File_spec

Directory_check:

          CMP       b[DI],"*"
          IF E JMP Print_start
          CMP       b[DI],"?"
          IF E JMP Print_start
          TEST      b[DI]
          JZ        Dir_only
          INC       DI
          JMP       Directory_check

Dir_only:
          MOV       DI,Path_spot
          XOR       AL,AL
          MOV       CX,80h
          REPNE     SCASB
          DEC       DI

Add_star:
          AND       w Number_of_files,0

          MOV       AL,[DI-1]
          CALL      Check_AL_file_char
          JC        >L1                           ; Add \ only if directory
                                                  ; is already there
          MOV       AL,"\"
          STOSB
L1:

          MOV       SI,OFFSET Star_dot_star
          MOV       CX,4
          REP       MOVSB

          JMP       start_search

;------------------------------------------------------------------------------
No_files:
          restore   es
          or        b internal,-1
          call      clear_string_spot
          mov       di,offset string_spot

          MOV       SI,OFFSET No_files_msg
          MOV       CX,Length_No_files
          MOV       AH,no_files_color
          CALL      Print_string

          test      num_user_extensions
          jnz       >l2

          mov       si,offset no_files2_msg
          mov       cx,length_no_files2
          mov       ah,no_files_color
          call      print_string

l2:

          and       internal,0
          to_video  es
          call      print_string_spot
          CALL      Scroll_up

          CALL      do_top_graph_line

          JMP       Bottom_info
;------------------------------------------------------------------------------
Print_start:

          MOV       DI,Path_spot
          ADD       DI,Length_full_path
          MOV       SI,OFFSET File_spec
          MOV       CX,Length_file_spec
          REP       MOVSB
          XOR       AL,AL
          STOSB



          TEST      b Not_first_path_search
          JNZ       >L00
          CALL      UnEncrypt

          ; need to do something bout this
;          TEST      Printer
;          JNZ       >L00
          TEST      Clear_screen
          IF NZ CALL Clr_Scr
L00:

          TEST      Path_search
          JZ        >L0
          TEST      Number_of_files
          JNZ       >L0
          TEST      b Not_first_print
          JZ        >L0
          TEST      Totals_only
          IF Z JMP No_files_path_search
L0:

          MOV       Files_to_print,CX,Number_of_files


          TEST      Col_Override
          JNZ       >L2

          CMP       Initial_num_columns,Auto_detect
          JNE       >L2

          MOV       AX,Number_of_files
          TEST      AH
          JZ        >L1
          MOV       Number_of_columns,6
          JMP       >L2
L1:
          MOV       Number_of_columns,1

          CMP       AL,Columns_2
          IF AE MOV Number_of_columns,2

          CMP       AL,Columns_3
          IF AE MOV Number_of_columns,3

          CMP       AL,Columns_4
          IF AE MOV Number_of_columns,4

          CMP       AL,Columns_6
          IF AE MOV Number_of_columns,6
L2:
          TEST      Change_Attrib
          JZ        Got_path

          CMP       Number_of_Columns,3
          IF A MOV Number_of_Columns,3


Got_path:
          MOV       Columns_left,CL,Number_of_columns

          MOV       Files_to_print,CX,w Number_of_files

          CALL      Setup_pointers
          CMP       Sort_factor,no_sort_factor
          if ne call sort

          TEST      Totals_only
          JZ        >L15
          TEST      Not_first_path_search
          JNZ        >L17
L15:
          CALL      Scroll_up
L17:
          MOV       DI,OFFSET String_spot + 29*Col


          TEST      Totals_only
          JZ        >L2

          TEST      Not_first_path_search
          JNZ       >L3
L2:
          CALL      Top_two_lines
L3:

          TEST      Files_to_print
          jz        >l4

          Restore   ES
          CMP       Number_of_columns,1
          JE        >L1

          TEST      Left_to_right
          IF Z CALL Vertical_sort

L1:
          TEST      Add_dir_entries
          JNZ       >L4

          MOV       AX,Dir_entries
          SUB       Number_of_files,AX            ;if not count dir entries
L4:
          To_video  ES

          TEST      Totals_only
          IF NZ JMP Print_totals_in_only

          CALL      do_top_graph_line

          MOV       CX,Files_to_print
          TEST      CX
          IF Z JMP No_Files


          MOV       SI,Pointer_Area
          MOV       DI,Bottom_row
;------------------------------------------------------------------------------
Print_Files:
; ds:si -> the pointer (#) table, 55555 means print blank (for vsort)
; cx = the number of files to print

          PUSH      SI,CX

          LODSW

	  cmp	    ax,55555
	  jne	    >l1

	  call	    print_blank_entry
	  jmp	    end_print_one_entry

L1:
          DEC       AX
          MOV       DX,Entry_Length
          MUL       DX

          PUSH      DI

          Restore   ES
          MOV       SI,OFFSET Data_Area
          ADD       SI,AX
          MOV       DI,OFFSET Attrib
          MOV       CX,Entry_length
          REP       MOVSB

          TEST      Change_Attrib
          IF NZ CALL Change_Attributes
          To_video  ES

          MOV       AH,File_color
          CALL      Set_Color
          MOV       Entry_color,AH                ; In case all of entry is this
                                                  ; color
	  POP	    DI

          MOV       SI,OFFSET FileName
          MOV       CX,12                           ;FileName length
          CALL      Print_string

          CMP       Number_of_columns,6
          JNE       >L15
          CALL      Print_bar
	  JMP	    end_print_one_entry
L15:
          call      print_space

          TEST      b[Attrib],Volume_Label
          IF NZ JMP Vol_size

          TEST      b[Attrib],Directory
          IF NZ JMP Dir_size

          MOV       DX,w[Size+2]
          MOV       AX,w[Size]

          MOV       CH,Length_color
          CMP       Entry_one_color,0
          IF NE MOV CH,Entry_color
          CALL      Print_file_size
          JMP       >L5

Dir_Size:
          call      print_space
          cmp       number_of_columns,1
          jne       >l25
          mov       cx,5
l2:
          call      print_space
          loop      l2
l25:
          MOV       SI,OFFSET Dir_size_msg
          MOV       CX,Length_Dir_size
          MOV       AH,Directory_color
          CMP       Entry_one_color,0
          IF NE MOV AH,Entry_color
          CALL      Print_string
L3:
          CMP       Number_of_columns,1
          JNE       >L5
          mov       cx,5
l35:
          call      print_space
          loop      l35
          JMP       >L5

Vol_Size:
          CALL      Print_space
          cmp       number_of_columns,1
          jne       >l4
          mov       cx,5
l37:
          call      print_space
          loop      l37
l4:
          MOV       SI,OFFSET Vol_size_msg
          MOV       CX,Length_Vol_size
          MOV       AH,Volume_color
          CMP       Entry_one_color,0
          IF NE MOV AH,Entry_color
          CALL      Print_string
          JMP       L3

L5:
          CMP       Number_of_columns,1
          JNE       >L55

          TEST      Attrib,Directory + Volume_label
          JZ        >V2

          MOV       CX,7
V1:       CALL      Print_space
          LOOP      V1
          JMP       >L55

V2:
          CALL      Print_space
          MOV       DX,w[Size+2]
          MOV       AX,w[Size]

          CALL      Size_to_clusters
          MOV       CH,File_usage_color
          CMP       Entry_one_color,0
          IF NE MOV CH,Entry_color
          CALL      Print_file_size

L55:
          CMP       Number_of_columns,4
          JNE       >L4
          CALL      Print_bar
	  JMP	    end_print_one_entry
L4:
          CALL      Print_space
          CALL      Print_Attribs

          CMP       Number_of_columns,3
          JNE       >L3
          CALL      Print_bar
	  JMP	    short end_print_one_entry

L3:

          CMP       Number_of_columns,2
          IF NE CALL Print_space

          CALL      Print_Date
          CALL      Print_Time

          CMP       Number_of_columns,2
	  JNE	    short end_print_one_entry
          CALL      Print_Bar

end_print_one_entry:
          CMP       Number_of_columns,1
          JE        >L7
          DEC       Columns_left
          JNZ       >L8
          MOV       Columns_left,CL,Number_of_columns
L7:
          POP       CX
          PUSH      CX

          CMP       CX,1
          JE        >L8

          CALL      Scroll_up
          MOV       DI,Bottom_row
L8:
          POP       CX,SI
          INC       SI,2

          DEC       CX
          IF NZ JMP Print_Files

          CALL      Scroll_up

          CALL      Do_bottom_graph_line

          JMP       Bottom_info
;------------------------------------------------------------------------------
entry_width         db        39,25,19,0,12
	      ; for # columns 2, 3, 4,-, 6
print_blank_entry:

	  ; in case entry_one_color, make blank entries in empty_color
	  mov	    al,empty_color

	  xor	    bh,bh
	  mov	    bl,number_of_columns
	  sub	    bx,2
	  xor	    ch,ch
	  mov	    cl,entry_width[bx]


l1:	  call	    print_space
	  loop	    l1

	  call	    print_bar

	  ret
;------------------------------------------------------------------------------
Add_up_this_directory:

          MOV       AX,Number_of_files
          ADD       Path_Number_of_files,AX
          MOV       DX,w[Total_size+2]
          MOV       AX,w[Total_size]
          ADD       w[Total_path_size],AX
          ADC       w[Total_path_size+2],DX
          MOV       DX,w[Consumption+2]
          MOV       AX,w[Consumption]
          ADD       w[Path_consumption],AX
          ADC       w[Path_consumption+2],DX

          RET
;------------------------------------------------------------------------------
Bottom_info:

          ; in case entry_one_color, make blank spaces in empty_color
          mov       al,empty_color
          mov       entry_color,al

          CALL      Add_up_this_directory

          OR        Commas_in_numbers,-1
          OR        b Internal,-1

          Restore   ES

          test      path_search,-1
          jnz       >l1

          test      just_user_ext,-1
          if nz call print_just_user_ext_str
l1:
          MOV       DI,OFFSET String_spot

          MOV       AX,Number_of_files

          XOR       DX,DX
          MOV       CH,Totals_color
          AND       b Right_justify,0
          CALL      Print_number
          MOV       AH,Totals_color
          MOV       AL,"+"
          TEST      Truncated
          IF NZ CALL Put_char

          MOV       AH,Totals_msg_clr

          CMP       Number_of_files,1
          JE        >L1

          MOV       SI,OFFSET total_size_msg1
          MOV       CX,Length_Total_size1
          JMP       >L2

L1:       MOV       SI,OFFSET Total_size_msg15
          MOV       CX,Length_total_size15

L2:       CALL      Print_string


          MOV       DX,w[Total_size+2]
          MOV       AX,w[Total_size]

          MOV       CH,Totals_color

          CALL      Print_number
          MOV       SI,OFFSET Total_size_msg2
          MOV       CX,Length_Total_size2
          MOV       AH,Totals_msg_clr
          CALL      Print_String

          MOV       DX,w[Consumption+2]
          MOV       AX,w[Consumption]

          MOV       CH,Totals_color
          CALL      Print_number

          MOV       SI,OFFSET Total_size_msg3
          MOV       CX,Length_Total_size3
          MOV       AH,Totals_msg_clr
          CALL      Print_string

          To_Video  ES
          AND       Internal,0
          CALL      Print_string_spot
          CALL      Scroll_up
          Restore   ES

          TEST      Path_search
          if z call print_disk_info
          JMP       End_ZDir_check_nextdir

