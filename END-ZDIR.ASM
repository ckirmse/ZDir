;   A86 +E 1-Zdir.asm 15-Zdir.asm 2-Zdir.asm # End-Zdir.asm TO Zdir.com

FCB_vol   DB        0FFh, 0, 0, 0, 0, 0           ;Structure of the FCB
          DB        Volume_Label
FCB_drive DB        0
          DB        11 DUP "?"
Length_program      EQU       $ - 100h

;------------------------------------------------Uninitialized
FCB_to_Zero         EQU       b[$]

DTA                 EQU       b[$+25]
FCB_file            EQU       b[$+33]
Attrib              EQU       b[$+46]
Time                EQU       w[$+47]
Date                EQU       w[$+49]
Size                EQU       d[$+51]

FileName            EQU       b[$+55]
          ; leave space here!!!!!!!!!
Path_spot           EQU       w[$+75]
Video_segment       EQU       w[$+77]

Bottom_row          EQU       w[$+79]
Bytes_per_sector    EQU       w[$+81]

Current_Col         EQU       b[$+83]
Current_Row         EQU       b[$+84]

exist_vol_label     equ       b[$+85]

Extension_holder    EQU       b[$+86]

Columns_left        EQU       b[$+90]

Volume_temp         EQU       b[$+91]

Length_Full_Path    EQU       w[$+101]
Full_Path           EQU       b[$+103]

File_spec           EQU       b[$+470]  ; gives 30 chars so can be sloppy

Main_dir_length     EQU       w[$+190]
Main_dir            EQU       b[$+192]
Length_File_Spec    EQU       w[$+464]  
Break_status        EQU       b[$+266]
Max_row_x_row       EQU       w[$+267]
Screen_rows         EQU       b[$+269]
Entry_color         EQU       b[$+270]
Digit_count         EQU       b[$+271]
First_digit         EQU       b[$+272]
Commas_in_numbers   EQU       b[$+273]
Total_prev_deep     EQU       b[$+274]
Totals_next_slash   EQU       b[$+276]
Totals_this_slash   EQU       b[$+277]

Tempspec            EQU       b[$+500]            ; unused space... look vvv
Tempstring          EQU       b[$+515]
Specextension       EQU       w[$+530]
Stringextension     EQU       w[$+532]
Temp_AX             EQU       w[$+534]
Temp_DX             EQU       w[$+536]
Factor_ptr          EQU       w[$+538]
Have_serial_number  EQU       b[$+540]
Initial_num_columns EQU       b[$+541]
ext_check           EQU       b[$+542]
screen_cols         EQU       w[$+546]
row_bytes           EQU       w[$+548]
num_user_extensions EQU       b[$+550]

mediaID             equ       b[$+551]
serial_high_word    equ       b[$+555]
serial_low_word     equ       b[$+553]

the_color           equ       b[$+576]            ; for ANSI temp storage

                    ;EQU       b[$+577]



;------------------------------------------------All below must be set to 0
Total_size          EQU       d[$+300]
Consumption         EQU       d[$+304]
Total_space         EQU       d[$+308]
Free_space          EQU       d[$+312]

Number_done         EQU       b[$+316]
Number_of_files     EQU       w[$+317]
Files_to_print      EQU       w[$+319]
PM_flag             EQU       b[$+321]
Colon_found         EQU       b[$+322]
;;;Done_names          EQU       b[$+323] NOT USED ANY MORE
Right_justify       EQU       b[$+324]
Truncated           EQU       b[$+325]
Internal            EQU       b[$+326]
;Zippy               EQU       b[$+327] NOT USED ANY MORE!!!
Dir_entries         EQU       w[$+328]
Length_to_always_Zero EQU    15


Default_flag        EQU       b[$+330]
;;Switch_found        EQU       b[$+331] not needed w/o /Q

Change_Attrib       EQU       b[$+332]
New_on_Attrib       EQU       b[$+333]
New_off_Attrib      EQU       b[$+334]

Col_Override        EQU       b[$+335]

Not_First_path_search EQU     b[$+336]

Total_path_size     EQU       d[$+337]
Path_Consumption    EQU       d[$+341]
Path_Number_of_files EQU      w[$+345]
Not_first_print     EQU       b[$+347]
Path_search         EQU       b[$+348]
Any_truncated       EQU       b[$+349]
Printer             EQU       b[$+350]
ANSI_printer        EQU       b[$+351]
Max_depth_path_spot EQU       w[$+352]
Totals_only         EQU       b[$+354]
Totals_top_slash    EQU       b[$+355]
Prev_totals_dir_length EQU    b[$+356]
No_more_this_level  EQU       b[$+357]
; need to have Tree_levels+1 chars here--assume 15, is PLENTY
Path_number_of_dirs EQU       w[$+372]           ; 36 words
                    ;EQU       b[$+374]           ; 36 1/2 words
Length_to_Zero      EQU       37                     ;words

String_spot         EQU       w[$+700]

;------------------------------------------------
Temp_holder         EQU       $+900

Pointer_Area        EQU       $+1024

Pointer2_Area       EQU       $+1024 + (Max_files+3)*2

Data_Area           EQU       $+1024 + (Max_files+3)*4
