; Include file with externs for all ZDir configuration data

; Defaults ------------------------------------------------

; Search options

.extrn  put_star_in_front:byte
.extrn  add_dir_entries:byte
.extrn  show_dot_file:byte
.extrn  hidden_show:byte
.extrn  read_only_show:byte
.extrn  system_show:byte
.extrn  volume_label_show:byte

; File list options

auto_detect     equ     7
.extrn  number_of_columns:byte
.extrn  left_to_right:byte
.extrn  columns_1:byte
.extrn  columns_2:byte
.extrn  columns_3:byte
.extrn  columns_4:byte
.extrn  columns_6:byte
PS_none             EQU       0
PS_dir_first        EQU       1
PS_dir_last         EQU       2
.extrn  presort:byte
.extrn  entry_one_color:byte
No_sort_factor      EQU       10
Rev                 EQU       (1 shl 7)
.extrn  sort_factor_1:word
.extrn  sort_factor_2:word
.extrn  sort_factor_3:word
.extrn  sort_factor_4:word
.extrn  really_past_factors:word

; Display choices

.extrn  BIOS:byte
.extrn  clear_screen:byte
.extrn  print_graphics:byte
.extrn  wait_for_key:byte
.extrn  commas_in_file_size:byte
.extrn  period_extension:byte
Totals_always       EQU       0
Totals_AB_only      EQU       1
Totals_never        EQU       2
.extrn  disk_totals:byte

; Extensions ----------------------------------------------


num_extensions      equ       50
.extrn  extension_data:byte
.extrn  extension1:byte
.extrn  extension2:byte
.extrn  extension3:byte
.extrn  extension4:byte
.extrn  extension5:byte
.extrn  extension6:byte
.extrn  extension7:byte
.extrn  extension8:byte
.extrn  extension9:byte
.extrn  extension10:byte
.extrn  extension11:byte
.extrn  extension12:byte
.extrn  extension13:byte
.extrn  extension14:byte
.extrn  extension15:byte
.extrn  extension16:byte
.extrn  extension17:byte
.extrn  extension18:byte
.extrn  extension19:byte
.extrn  extension20:byte
.extrn  extension21:byte
.extrn  extension22:byte
.extrn  extension23:byte
.extrn  extension24:byte
.extrn  extension25:byte
.extrn  extension26:byte
.extrn  extension27:byte
.extrn  extension28:byte
.extrn  extension29:byte
.extrn  extension30:byte
.extrn  extension31:byte
.extrn  extension32:byte
.extrn  extension33:byte
.extrn  extension34:byte
.extrn  extension35:byte
.extrn  extension36:byte
.extrn  extension37:byte
.extrn  extension38:byte
.extrn  extension39:byte
.extrn  extension40:byte
.extrn  extension41:byte
.extrn  extension42:byte
.extrn  extension43:byte
.extrn  extension44:byte
.extrn  extension45:byte
.extrn  extension46:byte
.extrn  extension47:byte
.extrn  extension48:byte
.extrn  extension49:byte
.extrn  extension50:byte


; Colors --------------------------------------------------

; Header lines
.extrn  time_date_color:byte
.extrn  top_msg_color:byte
.extrn  top_data_color:byte
.extrn  signature_color:byte
.extrn  ZS_color:byte

; Main area
.extrn  file_color:byte
.extrn  file_usage_color:byte
.extrn  directory_color:byte
.extrn  hidden_color:byte
.extrn  volume_color:byte
.extrn  graphics_color:byte
.extrn  length_color:byte
.extrn  attribute_color:byte
.extrn  date_color:byte
.extrn  time_color:byte

; Summary lines

.extrn  just_user_ext_color:byte
.extrn  totals_msg_clr:byte
.extrn  totals_color:byte
.extrn  empty_color:byte

; Tree display

.extrn  tree_graphics_color:byte
.extrn  tree_dir_color:byte
.extrn  tree_files_color:byte
.extrn  tree_size_color:byte
.extrn  tree_text_color:byte

; Misc

.extrn  any_key_attrib:byte
.extrn  bracket_attrib:byte
.extrn  no_files_color:byte
.extrn  write_file_color:byte

