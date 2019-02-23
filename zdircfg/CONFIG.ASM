;=============================================================================
;FILE:  config.asm
;
;DESC:  all configuration data stored here
;
;=============================================================================


include   model.inc
include   console.inc

.dataseg
;----------------------------------------------------------

config_start        equ       $
.public   config_start

; Defaults ------------------------------------------------

; Search options

put_star_in_front   DB        -1        ; replaced with * in front, 2.0
add_dir_entries     DB        0
show_dot_file       DB        -1
hidden_show         DB        -1
read_only_show      DB        -1
system_show         DB        -1
volume_label_show   DB        -1

; File list options

auto_detect         EQU       7
number_of_columns   DB        auto_detect
left_to_right       DB        0
columns_1           DB        0
columns_2           DB        15
columns_3           DB        25
columns_4           DB        35
columns_6           DB        60
PS_none             EQU       0
PS_dir_first        EQU       1
PS_dir_last         EQU       2
presort             DB        PS_dir_first
sort_factor         label     word
sort_factor_1       DW        9
sort_factor_2       DW        9
sort_factor_3       DW        9
sort_factor_4       DW        9
really_past_factors DW        9
entry_one_color     DB        0

; Display choices

BIOS                DB        0
clear_screen        DB        0
print_graphics      DB        -1
wait_for_key        DB        -1
commas_in_file_size DB        0
period_extension    DB        0
totals_always       EQU       0
totals_AB_only      EQU       1
totals_never        EQU       2
disk_totals         DB        Totals_always

; Extensions ----------------------------------------------

num_extensions      equ       50

user_ext            equ       -1
not_user_ext        equ       0

extension_data      label     byte

extension1          DB        "COM",ltred  ,user_ext
extension2          DB        "EXE",ltcyan ,user_ext
extension3          DB        "BAT",White  ,user_ext
extension4          DB        "ZIP",magenta,not_user_ext
extension5          DB        "ARJ",magenta,not_user_ext
extension6          DB        "LZH",magenta,not_user_ext
extension7          DB        "ZOO",magenta,not_user_ext
extension8          DB        "ARC",magenta,not_user_ext
extension9          DB        "DWC",magenta,not_user_ext
extension10         DB        "TAR",magenta,not_user_ext
extension11         DB        "TRZ",magenta,not_user_ext
extension12         DB        "BAS",ltcyan ,not_user_ext
extension13         DB        "PAS",ltred  ,not_user_ext
extension14         DB        "INC",ltred  ,not_user_ext
extension15         DB        "C  ",ltgreen,not_user_ext
extension16         DB        "CPP",ltgreen,not_user_ext
extension17         DB        "CXX",ltgreen,not_user_ext
extension18         DB        "H  ",ltgreen,not_user_ext
extension19         DB        "HPP",ltgreen,not_user_ext
extension20         DB        "HXX",ltgreen,not_user_ext
extension21         DB        "PRJ",cyan   ,not_user_ext
extension22         DB        "MAK",cyan   ,not_user_ext
extension23         DB        "OBJ",red    ,not_user_ext
extension24         DB        "LIB",red    ,not_user_ext
extension25         DB        "ASM",ltred  ,not_user_ext
extension26         DB        "A86",ltred  ,not_user_ext
extension27         DB        "LST",red    ,not_user_ext
extension28         DB        "SYM",red    ,not_user_ext
extension29         DB        "MAP",red    ,not_user_ext
extension30         DB        "Z86",yellow ,not_user_ext
extension31         DB        "ZDV",yellow ,not_user_ext
extension32         DB        "SYS",green  ,not_user_ext
extension33         DB        "DRV",green  ,not_user_ext
extension34         DB        "ME ",white  ,not_user_ext
extension35         DB        "DOC",white  ,not_user_ext
extension36         DB        "TXT",white  ,not_user_ext
extension37         DB        "WP ",white  ,not_user_ext
extension38         DB        "BAK",cyan   ,not_user_ext
extension39         DB        "BK?",cyan   ,not_user_ext
extension40         DB        "NDX",ltgreen,not_user_ext
extension41         DB        "PRG",ltgreen,not_user_ext
extension42         DB        "DBF",ltgreen,not_user_ext
extension43         DB        "EXT",ltgreen,not_user_ext
extension44         DB        "DAT",ltgreen,not_user_ext
extension45         DB        "INX",yellow ,not_user_ext
extension46         DB        "WK?",yellow ,not_user_ext
extension47         DB        "PIC",yellow ,not_user_ext
extension48         DB        "CGM",yellow ,not_user_ext
extension49         DB        "GIF",yellow ,not_user_ext
extension50         DB        "WPG",yellow ,not_user_ext


; Colors --------------------------------------------------

; Top two lines
time_date_color     DB        White
top_msg_color       DB        Cyan
top_data_color      DB        White
signature_color     DB        Cyan
ZS_color            DB        ltcyan

; Main area
file_color          DB        ltgray
file_usage_color    DB        white
directory_color     DB        ltmagenta
hidden_color        DB        green
volume_color        DB        ltred
graphics_color      DB        ltblue
length_color        DB        yellow
attribute_color     DB        cyan
date_color          DB        red
time_color          DB        brown

; Summary lines

just_user_ext_color db        cyan
Totals_msg_clr      DB        Cyan
Totals_color        DB        White
Empty_color         DB        ltgray

; Tree display

tree_graphics_color db        ltblue
tree_dir_color      db        ltmagenta
tree_files_color    db        ltcyan
tree_size_color     db        white
tree_text_color     db        ltred

; Misc

any_key_attrib      db        cyan
bracket_attrib      db        ltblue
no_files_color      db        ltred
write_file_color    db        ltred

; Defaults ------------------------------------------------

; Search options

.public put_star_in_front
.public add_dir_entries
.public show_dot_file
.public hidden_show
.public read_only_show
.public system_show
.public volume_label_show

; File list options

.public number_of_columns
.public left_to_right
.public columns_1
.public columns_2
.public columns_3
.public columns_4
.public columns_6
.public Presort
.public Sort_factor
.public Sort_factor_1
.public Sort_factor_2
.public Sort_factor_3
.public Sort_factor_4
.public Really_past_factors
.public Entry_one_color

; Display choices

.public BIOS
.public Clear_screen
.public Print_graphics
.public Wait_for_key
.public Commas_in_file_size
.public Period_extension
.public Disk_totals

; Extensions ----------------------------------------------

.public extension_data
.public extension1
.public extension2
.public extension3
.public extension4
.public extension5
.public extension6
.public extension7
.public extension8
.public extension9
.public extension10
.public extension11
.public extension12
.public extension13
.public extension14
.public extension15
.public extension16
.public extension17
.public extension18
.public extension19
.public extension20
.public extension21
.public extension22
.public extension23
.public extension24
.public extension25
.public extension26
.public extension27
.public extension28
.public extension29
.public extension30
.public extension31
.public extension32
.public extension33
.public extension34
.public extension35
.public extension36
.public extension37
.public extension38
.public extension39
.public extension40
.public extension41
.public extension42
.public extension43
.public extension44
.public extension45
.public extension46
.public extension47
.public extension48
.public extension49
.public extension50


; Colors --------------------------------------------------

; Top two lines
.public time_date_color
.public top_msg_color
.public top_data_color
.public signature_color
.public ZS_color

; Main area
.public file_color
.public file_usage_color
.public directory_color
.public hidden_color
.public volume_color
.public graphics_color
.public length_color
.public attribute_color
.public date_color
.public time_color

; Summary lines

.public just_user_ext_color
.public totals_msg_clr
.public totals_color
.public empty_color

; Tree display

.public tree_graphics_color
.public tree_dir_color
.public tree_files_color
.public tree_size_color
.public tree_text_color

; Misc

.public any_key_attrib
.public bracket_attrib
.public no_files_color
.public write_file_color

;----------------------------------------------------------

config_end          equ       $

config_length       equ       config_end - config_start

.public   config_length

.ends

        end

