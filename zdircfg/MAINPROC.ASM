;=============================================================================
;=============================================================================
;FILE:  mainproc.asm
;
;DESC:  all main procedures (read/write to zdir, view config, extension edit,
;       register)
;
;NOTE:  no procedures save any registers
;=============================================================================

include   model.inc
include   console.inc
include   window.inc
include   menu.inc
include   fileio.inc
include   string.inc
include   status.inc
include   winmsgbx.inc

include   extrn.inc


.codeseg
.extrn    status_line:auto
.extrn    goto_entry:auto
.extrn    error_memory:auto
.extrn    color_box:auto
.extrn    string_window:auto, string_input:auto
.extrn    backup_config_data:auto
.extrn    compare_config_data:auto
.extrn    win_msg_box:auto

.ends

.dataseg
.extrn    color_win:window
.extrn    cbox_proc:word
.extrn    cbox_proc_data:word
.extrn    config_backup:word
.extrn    crlf:byte
.extrn    crlfcrlf:byte

.extrn    screen_rows:byte
;----------------------------------------------------------
; Declare external library and program data here...
;----------------------------------------------------------
include   config.inc

load_filename       string    <60,,no_leave_keys,,file_prompt,$+2>
                    db        61 dup (0)
file_prompt         db        "Enter ZDir filename",0

save_filename       string    <60,,no_leave_keys,,file_prompt,$+2>
                    db        61 dup (0)

reg_name_str        string    <25,init_info,reg_keys,s11,,$+2>
                    db        26 dup (0)

reg_num_str         string    <25,init_info,reg_keys,s12,,$+2>
                    db        26 dup (0)

                    dw        3
reg_keys            db        up_arrow,down_arrow,f1

encode_data         dw        6192,10234,40929,23877,12796
                    ; magic numbers!
wd                  equ       2         ; bytes per word


ver_detect_data     struc
          ver_file_spot       dw        ?
          detect_bytes        db        3 dup (?)
          version_data        dw        ?
          version_string      dw        ?
                    ends


ver_detect   label  ver_detect_data
             ver_detect_data <78,"2.1",zdir20_data,zdir21_string>
             ver_detect_data <78,"2.0",zdir20_data,zdir20_string>
             ver_detect_data <72,"1R4",zdir14_data,zdir14r_string>
             ver_detect_data <72,"1.4",zdir14_data,zdir14u_string>
             ver_detect_data <66,"1R3",zdir13_data,zdir13r_string>
             ver_detect_data <66,"1.3",zdir13_data,zdir13u_string>
             ver_detect_data <66,"1R2",zdir12_data,zdir12r_string>
             ver_detect_data <66,"1.2",zdir12_data,zdir12u_string>
             ver_detect_data <66,"1.1",zdir11_data,zdir11u_string>
             ver_detect_data < 1,"âZ",zdir10_data,zdir10u_string>

num_versions        equ       9

zdir10u_string      db        "1.0 unregistered",0
zdir11u_string      db        "1.1 unregistered",0
zdir12u_string      db        "1.2 unregistered",0
zdir12r_string      db        "1.2 registered",0
zdir13u_string      db        "1.3 unregistered",0
zdir13r_string      db        "1.3 registered",0
zdir14u_string      db        "1.4 unregistered",0
zdir14r_string      db        "1.4 registered",0
zdir20_string       db        "2.0",0
zdir21_string       db        "2.1",0

load_move_type      equ       1

load_move struc
          load_type db        load_move_type
          file_offset dw      ?
          zdircfg_offset dw   ?
          bytes     dw        ?
          ends

load_cond struc
          load_type db        2
          file_offset dw      ?
          zdircfg_offset dw   ?
          if_z_val  dw        ?         ; only do byte vals
          if_nz_val dw        ?
          ends
load_nop  equ       0ffffh              ; since word val, can detect to ignore


load_set_bytes struc
          load_type db        3
          byte_val  db        ?
          bytes_set db        1
          zdircfg_offset dw   ?
          ends

load_end  struc
	  load_type db	      0
	  ends

load_cond_temp_byte db        ?

                    dw        load_action_procs
                    dw        3
load_actions        db        1,2,3
load_action_procs   dw        load_do_move,load_do_cond,load_do_set_bytes



zdir10_data         label     byte
          load_cond <,00B9h,number_of_columns,1,4>
          load_move <,00BAh,left_to_right,1>
          load_move <,00B6h,sort_factor_1,2>
          load_cond <,00B8h,sort_factor_1,load_nop,10>
          load_set_bytes <,0,,put_star_in_front>
          load_set_bytes <,-1,,add_dir_entries>
          load_set_bytes <,-1,,show_dot_file>
          load_set_bytes <,-1,,hidden_show>
          load_set_bytes <,-1,,read_only_show>
          load_set_bytes <,-1,,system_show>
          load_set_bytes <,-1,,volume_label_show>
          load_set_bytes <,PS_none,,presort>
          load_set_bytes <,0,,entry_one_color>
          load_set_bytes <,0,,BIOS>
          load_set_bytes <,0,,clear_screen>
          load_set_bytes <,0,,print_graphics>
          load_set_bytes <,-1,,wait_for_key>
          load_set_bytes <,0,,commas_in_file_size>
          load_set_bytes <,0,,period_extension>
          load_set_bytes <,totals_always,,disk_totals>
          load_set_bytes <,0,,extension1+4> ; reset the checks
          load_set_bytes <,0,,extension2+4>
          load_set_bytes <,0,,extension3+4>
          load_set_bytes <,0,,extension4+4>
          load_set_bytes <,0,,extension5+4>
          load_set_bytes <,0,,extension6+4>
          load_set_bytes <,0,,extension7+4>
          load_set_bytes <,0,,extension8+4>
          load_set_bytes <,0,,extension9+4>
          load_set_bytes <,0,,extension10+4>
          load_set_bytes <,0,,extension11+4>
          load_set_bytes <,0,,extension12+4>
          load_set_bytes <,0,,extension13+4>
          load_set_bytes <,0,,extension14+4>
          load_set_bytes <,0,,extension15+4>
          load_set_bytes <,0,,extension16+4>
          load_set_bytes <,0,,extension17+4>
          load_move <,00DAh,extension1,4>
          load_move <,00DEh,extension2,4>
          load_move <,00E2h,extension3,4>
          load_move <,00E6h,extension4,4>
          load_move <,00EAh,extension5,4>
          load_move <,00EEh,extension6,4>
          load_move <,00F2h,extension7,4>
          load_move <,00F6h,extension8,4>
          load_move <,00FAh,extension9,4>
          load_move <,00FEh,extension10,4>
          load_move <,0102h,extension11,4>
          load_move <,0106h,extension12,4>
          load_move <,010Ah,extension13,4>
          load_move <,010Eh,extension14,4>
          load_move <,0112h,extension15,4>
          load_move <,0116h,extension16,4>
          load_move <,011Ah,extension17,4>
          load_move <,011Eh,file_color,1>
          load_move <,011Fh,directory_color,1>
          load_move <,0120h,hidden_color,1>
          load_move <,0121h,top_msg_color,1>
          load_move <,0122h,top_data_color,1>
          load_move <,0125h,graphics_color,1>
          load_move <,0126h,length_color,1>
          load_move <,0127h,attribute_color,1>
          load_move <,0128h,date_color,1>
          load_move <,0129h,time_color,1>
          load_move <,012Ah,totals_msg_clr,1>
          load_move <,012Bh,totals_color,1>
          load_end  <,>

zdir11_data         label     byte
          load_cond <,0048h,number_of_columns,1,4>
          load_move <,0049h,left_to_right,1>
          load_move <,0045h,sort_factor_1,2>
          load_cond <,0047h,sort_factor_1,load_nop,10>
          load_set_bytes <,0,,put_star_in_front>
          load_set_bytes <,-1,,add_dir_entries>
          load_set_bytes <,-1,,show_dot_file>
          load_set_bytes <,-1,,hidden_show>
          load_set_bytes <,-1,,read_only_show>
          load_set_bytes <,-1,,system_show>
          load_set_bytes <,-1,,volume_label_show>
          load_set_bytes <,PS_none,,presort>
          load_set_bytes <,0,,entry_one_color>
          load_set_bytes <,0,,BIOS>
          load_set_bytes <,0,,clear_screen>
          load_set_bytes <,0,,print_graphics>
          load_set_bytes <,-1,,wait_for_key>
          load_set_bytes <,0,,commas_in_file_size>
          load_set_bytes <,0,,period_extension>
          load_set_bytes <,totals_always,,disk_totals>
          load_set_bytes <,0,,extension1+4> ; reset the checks
          load_set_bytes <,0,,extension2+4>
          load_set_bytes <,0,,extension3+4>
          load_set_bytes <,0,,extension4+4>
          load_set_bytes <,0,,extension5+4>
          load_set_bytes <,0,,extension6+4>
          load_set_bytes <,0,,extension7+4>
          load_set_bytes <,0,,extension8+4>
          load_set_bytes <,0,,extension9+4>
          load_set_bytes <,0,,extension10+4>
          load_set_bytes <,0,,extension11+4>
          load_set_bytes <,0,,extension12+4>
          load_set_bytes <,0,,extension13+4>
          load_set_bytes <,0,,extension14+4>
          load_set_bytes <,0,,extension15+4>
          load_set_bytes <,0,,extension16+4>
          load_set_bytes <,0,,extension17+4>
          load_set_bytes <,0,,extension18+4>
          load_set_bytes <,0,,extension19+4>
          load_set_bytes <,0,,extension20+4>
          load_set_bytes <,0,,extension21+4>
          load_set_bytes <,0,,extension22+4>
          load_set_bytes <,0,,extension23+4>
          load_set_bytes <,0,,extension24+4>
          load_set_bytes <,0,,extension25+4>
          load_set_bytes <,0,,extension26+4>
          load_set_bytes <,0,,extension27+4>
          load_set_bytes <,0,,extension28+4>
          load_set_bytes <,0,,extension29+4>
          load_set_bytes <,0,,extension30+4>
          load_move <,0050h,extension1,4>
          load_move <,0054h,extension2,4>
          load_move <,0058h,extension3,4>
          load_move <,005Ch,extension4,4>
          load_move <,0060h,extension5,4>
          load_move <,0064h,extension6,4>
          load_move <,0068h,extension7,4>
          load_move <,006Ch,extension8,4>
          load_move <,0070h,extension9,4>
          load_move <,0074h,extension10,4>
          load_move <,0078h,extension11,4>
          load_move <,007Ch,extension12,4>
          load_move <,0080h,extension13,4>
          load_move <,0084h,extension14,4>
          load_move <,0088h,extension15,4>
          load_move <,008Ch,extension16,4>
          load_move <,0090h,extension17,4>
          load_move <,0094h,extension18,4>
          load_move <,0098h,extension19,4>
          load_move <,009Ch,extension20,4>
          load_move <,00A0h,extension21,4>
          load_move <,00A4h,extension22,4>
          load_move <,00A8h,extension23,4>
          load_move <,00ACh,extension24,4>
          load_move <,00B0h,extension25,4>
          load_move <,00B4h,extension26,4>
          load_move <,00B8h,extension27,4>
          load_move <,00BCh,extension28,4>
          load_move <,00C0h,extension29,4>
          load_move <,00C4h,extension30,4>
          load_move <,00C8h,file_color,1>
          load_move <,00C9h,directory_color,1>
          load_move <,00CAh,hidden_color,1>
          load_move <,00CBh,volume_color,1>
          load_move <,00CDh,top_msg_color,1>
          load_move <,00CEh,top_data_color,1>
          load_move <,00CFh,graphics_color,1>
          load_move <,00D0h,length_color,1>
          load_move <,00D1h,attribute_color,1>
          load_move <,00D2h,date_color,1>
          load_move <,00D3h,time_color,1>
          load_move <,00D4h,totals_msg_clr,1>
          load_move <,00D5h,totals_color,1>
          load_move <,00D6h,empty_color,1>
          load_end  <,>

zdir12_data         label     byte
          load_move <,0044h,sort_factor_1,2>
          load_move <,0046h,number_of_columns,1>
          load_move <,0047h,left_to_right,1>
          load_move <,0049h,BIOS,1>
          load_move <,004Ah,clear_screen,1>
          load_move <,004Bh,print_graphics,1>
          load_move <,004Ch,wait_for_key,1>
          load_move <,004Dh,put_star_in_front,1>
          load_cond <,004Fh,number_of_columns,load_nop,auto_detect>
          load_move <,0050h,columns_1,1>
          load_move <,0051h,columns_2,1>
          load_move <,0052h,columns_3,1>
          load_move <,0053h,columns_4,1>
          load_move <,0054h,columns_6,1>
          load_set_bytes <,-1,,add_dir_entries>
          load_set_bytes <,-1,,show_dot_file>
          load_set_bytes <,-1,,hidden_show>
          load_set_bytes <,-1,,read_only_show>
          load_set_bytes <,-1,,system_show>
          load_set_bytes <,-1,,volume_label_show>
          load_set_bytes <,PS_none,,presort>
          load_set_bytes <,0,,commas_in_file_size>
          load_set_bytes <,0,,period_extension>
          load_set_bytes <,totals_always,,disk_totals>
          load_set_bytes <,0,,extension1+4> ; reset the checks
          load_set_bytes <,0,,extension2+4>
          load_set_bytes <,0,,extension3+4>
          load_set_bytes <,0,,extension4+4>
          load_set_bytes <,0,,extension5+4>
          load_set_bytes <,0,,extension6+4>
          load_set_bytes <,0,,extension7+4>
          load_set_bytes <,0,,extension8+4>
          load_set_bytes <,0,,extension9+4>
          load_set_bytes <,0,,extension10+4>
          load_set_bytes <,0,,extension11+4>
          load_set_bytes <,0,,extension12+4>
          load_set_bytes <,0,,extension13+4>
          load_set_bytes <,0,,extension14+4>
          load_set_bytes <,0,,extension15+4>
          load_set_bytes <,0,,extension16+4>
          load_set_bytes <,0,,extension17+4>
          load_set_bytes <,0,,extension18+4>
          load_set_bytes <,0,,extension19+4>
          load_set_bytes <,0,,extension20+4>
          load_set_bytes <,0,,extension21+4>
          load_set_bytes <,0,,extension22+4>
          load_set_bytes <,0,,extension23+4>
          load_set_bytes <,0,,extension24+4>
          load_set_bytes <,0,,extension25+4>
          load_set_bytes <,0,,extension26+4>
          load_set_bytes <,0,,extension27+4>
          load_set_bytes <,0,,extension28+4>
          load_set_bytes <,0,,extension29+4>
          load_set_bytes <,0,,extension30+4>
          load_move <,005Ah,extension1,4>
          load_move <,005Eh,extension2,4>
          load_move <,0062h,extension3,4>
          load_move <,0066h,extension4,4>
          load_move <,006Ah,extension5,4>
          load_move <,006Eh,extension6,4>
          load_move <,0072h,extension7,4>
          load_move <,0076h,extension8,4>
          load_move <,007Ah,extension9,4>
          load_move <,007Eh,extension10,4>
          load_move <,0082h,extension11,4>
          load_move <,0086h,extension12,4>
          load_move <,008Ah,extension13,4>
          load_move <,008Eh,extension14,4>
          load_move <,0092h,extension15,4>
          load_move <,0096h,extension16,4>
          load_move <,009Ah,extension17,4>
          load_move <,009Eh,extension18,4>
          load_move <,00A2h,extension19,4>
          load_move <,00A6h,extension20,4>
          load_move <,00AAh,extension21,4>
          load_move <,00AEh,extension22,4>
          load_move <,00B2h,extension23,4>
          load_move <,00B6h,extension24,4>
          load_move <,00BAh,extension25,4>
          load_move <,00BEh,extension26,4>
          load_move <,00C2h,extension27,4>
          load_move <,00C6h,extension28,4>
          load_move <,00CAh,extension29,4>
          load_move <,00CEh,extension30,4>
          load_move <,00D2h,file_color,1>
          load_move <,00D3h,directory_color,1>
          load_move <,00D4h,hidden_color,1>
          load_move <,00D5h,volume_color,1>
          load_move <,00D7h,top_msg_color,1>
          load_move <,00D6h,top_data_color,1>
          load_move <,00D9h,graphics_color,1>
          load_move <,00DAh,length_color,1>
          load_move <,00DBh,attribute_color,1>
          load_move <,00DCh,date_color,1>
          load_move <,00DDh,time_color,1>
          load_move <,00DEh,totals_msg_clr,1>
          load_move <,00DFh,totals_color,1>
          load_move <,00E0h,empty_color,1>
          load_end  <,>

zdir13_data         label     byte
          load_move <,0047h,number_of_columns,1>
          load_move <,0048h,left_to_right,1>
          load_move <,004Ah,BIOS,1>
          load_move <,004Bh,clear_screen,1>
          load_move <,004Ch,print_graphics,1>
          load_move <,004Dh,wait_for_key,1>
          load_move <,004Eh,put_star_in_front,1>
          load_cond <,004Fh,number_of_columns,load_nop,auto_detect>
          load_move <,0050h,columns_1,1>
          load_move <,0051h,columns_2,1>
          load_move <,0052h,columns_3,1>
          load_move <,0053h,columns_4,1>
          load_move <,0054h,columns_6,1>
          load_move <,0055h,show_dot_file,1>
          load_move <,0056h,add_dir_entries,1>
          load_move <,0057h,sort_factor_1,2>
          load_move <,0059h,sort_factor_2,2>
          load_set_bytes <,-1,,hidden_show>
          load_set_bytes <,-1,,read_only_show>
          load_set_bytes <,-1,,system_show>
          load_set_bytes <,-1,,volume_label_show>
          load_set_bytes <,PS_none,,presort>
          load_set_bytes <,0,,commas_in_file_size>
          load_set_bytes <,0,,period_extension>
          load_set_bytes <,totals_always,,disk_totals>
          load_set_bytes <,0,,extension1+4> ; reset the checks
          load_set_bytes <,0,,extension2+4>
          load_set_bytes <,0,,extension3+4>
          load_set_bytes <,0,,extension4+4>
          load_set_bytes <,0,,extension5+4>
          load_set_bytes <,0,,extension6+4>
          load_set_bytes <,0,,extension7+4>
          load_set_bytes <,0,,extension8+4>
          load_set_bytes <,0,,extension9+4>
          load_set_bytes <,0,,extension10+4>
          load_set_bytes <,0,,extension11+4>
          load_set_bytes <,0,,extension12+4>
          load_set_bytes <,0,,extension13+4>
          load_set_bytes <,0,,extension14+4>
          load_set_bytes <,0,,extension15+4>
          load_set_bytes <,0,,extension16+4>
          load_set_bytes <,0,,extension17+4>
          load_set_bytes <,0,,extension18+4>
          load_set_bytes <,0,,extension19+4>
          load_set_bytes <,0,,extension20+4>
          load_set_bytes <,0,,extension21+4>
          load_set_bytes <,0,,extension22+4>
          load_set_bytes <,0,,extension23+4>
          load_set_bytes <,0,,extension24+4>
          load_set_bytes <,0,,extension25+4>
          load_set_bytes <,0,,extension26+4>
          load_set_bytes <,0,,extension27+4>
          load_set_bytes <,0,,extension28+4>
          load_set_bytes <,0,,extension29+4>
          load_set_bytes <,0,,extension30+4>
          load_move <,0064h,extension1,4>
          load_move <,0068h,extension2,4>
          load_move <,006Ch,extension3,4>
          load_move <,0070h,extension4,4>
          load_move <,0074h,extension5,4>
          load_move <,0078h,extension6,4>
          load_move <,007Ch,extension7,4>
          load_move <,0080h,extension8,4>
          load_move <,0084h,extension9,4>
          load_move <,0088h,extension10,4>
          load_move <,008Ch,extension11,4>
          load_move <,0090h,extension12,4>
          load_move <,0094h,extension13,4>
          load_move <,0098h,extension14,4>
          load_move <,009Ch,extension15,4>
          load_move <,00A0h,extension16,4>
          load_move <,00A4h,extension17,4>
          load_move <,00A8h,extension18,4>
          load_move <,00ACh,extension19,4>
          load_move <,00B0h,extension20,4>
          load_move <,00B4h,extension21,4>
          load_move <,00B8h,extension22,4>
          load_move <,00BCh,extension23,4>
          load_move <,00C0h,extension24,4>
          load_move <,00C4h,extension25,4>
          load_move <,00C8h,extension26,4>
          load_move <,00CCh,extension27,4>
          load_move <,00D0h,extension28,4>
          load_move <,00D4h,extension29,4>
          load_move <,00D8h,extension30,4>
          load_move <,00DCh,file_color,1>
          load_move <,00DDh,directory_color,1>
          load_move <,00DEh,hidden_color,1>
          load_move <,00DFh,volume_color,1>
          load_move <,00E1h,top_msg_color,1>
          load_move <,00E0h,top_data_color,1>
          load_move <,00E3h,graphics_color,1>
          load_move <,00E4h,length_color,1>
          load_move <,00E5h,attribute_color,1>
          load_move <,00E6h,date_color,1>
          load_move <,00E7h,time_color,1>
          load_move <,00E8h,totals_msg_clr,1>
          load_move <,00E9h,totals_color,1>
          load_move <,00EAh,empty_color,1>
          load_end  <,>

zdir14_data         label     byte
          load_move <,004Dh,number_of_columns,1>
          load_move <,004Eh,left_to_right,1>
          load_move <,0050h,BIOS,1>
          load_move <,0051h,clear_screen,1>
          load_move <,0052h,print_graphics,1>
          load_move <,0053h,wait_for_key,1>
          load_move <,0054h,put_star_in_front,1>
          load_cond <,0055h,number_of_columns,load_nop,auto_detect>
          load_move <,0056h,columns_1,1>
          load_move <,0057h,columns_2,1>
          load_move <,0058h,columns_3,1>
          load_move <,0059h,columns_4,1>
          load_move <,005Ah,columns_6,1>
          load_move <,005Bh,show_dot_file,1>
          load_move <,005Ch,add_dir_entries,1>
          load_move <,005Dh,sort_factor_1,2>
          load_move <,005Fh,sort_factor_2,2>
          load_move <,0063h,entry_one_color,1>
          load_move <,0064h,commas_in_file_size,1>
          load_move <,0065h,hidden_show,1>
          load_set_bytes <,-1,,read_only_show>
          load_set_bytes <,-1,,system_show>
          load_set_bytes <,-1,,volume_label_show>
          load_set_bytes <,PS_none,,presort>
          load_set_bytes <,0,,period_extension>
          load_set_bytes <,totals_always,,disk_totals>
          load_set_bytes <,0,,extension1+4> ; reset the checks
          load_set_bytes <,0,,extension2+4>
          load_set_bytes <,0,,extension3+4>
          load_set_bytes <,0,,extension4+4>
          load_set_bytes <,0,,extension5+4>
          load_set_bytes <,0,,extension6+4>
          load_set_bytes <,0,,extension7+4>
          load_set_bytes <,0,,extension8+4>
          load_set_bytes <,0,,extension9+4>
          load_set_bytes <,0,,extension10+4>
          load_set_bytes <,0,,extension11+4>
          load_set_bytes <,0,,extension12+4>
          load_set_bytes <,0,,extension13+4>
          load_set_bytes <,0,,extension14+4>
          load_set_bytes <,0,,extension15+4>
          load_set_bytes <,0,,extension16+4>
          load_set_bytes <,0,,extension17+4>
          load_set_bytes <,0,,extension18+4>
          load_set_bytes <,0,,extension19+4>
          load_set_bytes <,0,,extension20+4>
          load_set_bytes <,0,,extension21+4>
          load_set_bytes <,0,,extension22+4>
          load_set_bytes <,0,,extension23+4>
          load_set_bytes <,0,,extension24+4>
          load_set_bytes <,0,,extension25+4>
          load_set_bytes <,0,,extension26+4>
          load_set_bytes <,0,,extension27+4>
          load_set_bytes <,0,,extension28+4>
          load_set_bytes <,0,,extension29+4>
          load_set_bytes <,0,,extension30+4>
          load_move <,006Eh,extension1,4>
          load_move <,0072h,extension2,4>
          load_move <,0076h,extension3,4>
          load_move <,007Ah,extension4,4>
          load_move <,007Eh,extension5,4>
          load_move <,0082h,extension6,4>
          load_move <,0086h,extension7,4>
          load_move <,008Ah,extension8,4>
          load_move <,008Eh,extension9,4>
          load_move <,0092h,extension10,4>
          load_move <,0096h,extension11,4>
          load_move <,009Ah,extension12,4>
          load_move <,009Eh,extension13,4>
          load_move <,00A2h,extension14,4>
          load_move <,00A6h,extension15,4>
          load_move <,00AAh,extension16,4>
          load_move <,00AEh,extension17,4>
          load_move <,00B2h,extension18,4>
          load_move <,00B6h,extension19,4>
          load_move <,00BAh,extension20,4>
          load_move <,00BEh,extension21,4>
          load_move <,00C2h,extension22,4>
          load_move <,00C6h,extension23,4>
          load_move <,00CAh,extension24,4>
          load_move <,00CEh,extension25,4>
          load_move <,00D2h,extension26,4>
          load_move <,00D6h,extension27,4>
          load_move <,00DAh,extension28,4>
          load_move <,00DEh,extension29,4>
          load_move <,00E2h,extension30,4>
          load_move <,00E6h,file_color,1>
          load_move <,00E7h,directory_color,1>
          load_move <,00E8h,hidden_color,1>
          load_move <,00E9h,volume_color,1>
          load_move <,00EAh,time_date_color,1>
          load_move <,00EBh,top_msg_color,1>
          load_move <,00ECh,top_data_color,1>
          load_move <,00EDh,graphics_color,1>
          load_move <,00EEh,length_color,1>
          load_move <,00EFh,attribute_color,1>
          load_move <,00F0h,date_color,1>
          load_move <,00F1h,time_color,1>
          load_move <,00F2h,totals_msg_clr,1>
          load_move <,00F3h,totals_color,1>
          load_move <,00F4h,empty_color,1>
          load_end  <,>

zdir20_data         label     byte
          load_move <,0053h,number_of_columns,1>
          load_move <,0054h,left_to_right,1>
          load_move <,0056h,BIOS,1>
          load_move <,0057h,clear_screen,1>
          load_move <,0058h,print_graphics,1>
          load_move <,0059h,wait_for_key,1>
          load_move <,005Ah,put_star_in_front,1>
          load_move <,005Bh,columns_1,1>
          load_move <,005Ch,columns_2,1>
          load_move <,005Dh,columns_3,1>
          load_move <,005Eh,columns_4,1>
          load_move <,005Fh,columns_6,1>
          load_move <,0060h,show_dot_file,1>
          load_move <,0061h,add_dir_entries,1>
          load_move <,0062h,sort_factor_1,2>
          load_move <,0064h,sort_factor_2,2>
          load_move <,0068h,entry_one_color,1>
          load_move <,0069h,commas_in_file_size,1>
          load_move <,006Ah,hidden_show,1>
          load_move <,006Bh,sort_factor_3,2>
          load_move <,006Dh,sort_factor_4,2>
          load_move <,0071h,read_only_show,1>
          load_move <,0072h,system_show,1>
          load_move <,0073h,volume_label_show,1>
          load_move <,0074h,presort,1>
          load_move <,0075h,period_extension,1>
          load_move <,0076h,disk_totals,1>
          load_move <,0080h,extension1,5>
          load_move <,0085h,extension2,5>
          load_move <,008Ah,extension3,5>
          load_move <,008Fh,extension4,5>
          load_move <,0094h,extension5,5>
          load_move <,0099h,extension6,5>
          load_move <,009Eh,extension7,5>
          load_move <,00A3h,extension8,5>
          load_move <,00A8h,extension9,5>
          load_move <,00ADh,extension10,5>
          load_move <,00B2h,extension11,5>
          load_move <,00B7h,extension12,5>
          load_move <,00BCh,extension13,5>
          load_move <,00C1h,extension14,5>
          load_move <,00C6h,extension15,5>
          load_move <,00CBh,extension16,5>
          load_move <,00D0h,extension17,5>
          load_move <,00D5h,extension18,5>
          load_move <,00DAh,extension19,5>
          load_move <,00DFh,extension20,5>
          load_move <,00E4h,extension21,5>
          load_move <,00E9h,extension22,5>
          load_move <,00EEh,extension23,5>
          load_move <,00F3h,extension24,5>
          load_move <,00F8h,extension25,5>
          load_move <,00FDh,extension26,5>
          load_move <,0102h,extension27,5>
          load_move <,0107h,extension28,5>
          load_move <,010Ch,extension29,5>
          load_move <,0111h,extension30,5>
          load_move <,0116h,extension31,5>
          load_move <,011Bh,extension32,5>
          load_move <,0120h,extension33,5>
          load_move <,0125h,extension34,5>
          load_move <,012Ah,extension35,5>
          load_move <,012Fh,extension36,5>
          load_move <,0134h,extension37,5>
          load_move <,0139h,extension38,5>
          load_move <,013Eh,extension39,5>
          load_move <,0143h,extension40,5>
          load_move <,0148h,extension41,5>
          load_move <,014Dh,extension42,5>
          load_move <,0152h,extension43,5>
          load_move <,0157h,extension44,5>
          load_move <,015Ch,extension45,5>
          load_move <,0161h,extension46,5>
          load_move <,0166h,extension47,5>
          load_move <,016Bh,extension48,5>
          load_move <,0170h,extension49,5>
          load_move <,0175h,extension50,5>
          load_move <,017Ah,file_color,1>
          load_move <,017Bh,file_usage_color,1>
          load_move <,017Ch,directory_color,1>
          load_move <,017Dh,hidden_color,1>
          load_move <,017Eh,volume_color,1>
          load_move <,017Fh,time_date_color,1>
          load_move <,0180h,top_msg_color,1>
          load_move <,0181h,top_data_color,1>
          load_move <,0182h,graphics_color,1>
          load_move <,0183h,length_color,1>
          load_move <,0184h,attribute_color,1>
          load_move <,0185h,date_color,1>
          load_move <,0186h,time_color,1>
          load_move <,0187h,totals_msg_clr,1>
          load_move <,0188h,totals_color,1>
          load_move <,0189h,empty_color,1>
          load_move <,018Ah,signature_color,1>
          load_move <,018Bh,ZS_color,1>
          load_move <,018Ch,tree_graphics_color,1>
          load_move <,018Dh,tree_dir_color,1>
          load_move <,018Eh,tree_files_color,1>
          load_move <,018Fh,tree_size_color,1>
          load_move <,0190h,tree_text_color,1>
          load_move <,0191h,any_key_attrib,1>
          load_move <,0192h,bracket_attrib,1>
          load_move <,0193h,no_files_color,1>
          load_move <,0194h,write_file_color,1>
          load_move <,0195h,just_user_ext_color,1>
          load_end  <,>

zdir_newest         equ       offset @dataseg:zdir21_string

max_ext_num         equ       num_extensions-1    ; we number 0.., not 1..

dot_com             db        ".COM",0
load_temp           db        "xxx",0   ; space for an extension
                    db        60 dup (?) ; in case 64 char extension illegally

save_temp           db        "xxx",0   ; space for an extension
                    db        60 dup (?) ; in case 64 char extension illegally


load_fail_wmb window <5,5,50,15,error_color,,,,,,error_color,,,,,darkgray,,wcursor_off>
                    wmb_str   <wmb_ic,error_msg>
                    wmb_str   <wmb_n ,crlfcrlf>
                    wmb_str   <wmb_ic ,any_key_msg>
                    wmb_str   <wmb_key_quit>

error_wmb window <22,9,35,7,error_color,,,,,,error_color,,,,,darkgray,,wcursor_off>
                    wmb_str   <wmb_ic,error_msg>
                    wmb_str   <wmb_n ,crlfcrlf>
error_wmb_str       wmb_str   <wmb_ic,>
                    wmb_str   <wmb_n ,crlfcrlf>
                    wmb_str   <wmb_ic,any_key_msg>
                    wmb_str   <wmb_key_quit>

loaded_wmb window <20,10,40,3,normal_color,,,,,,normal_color,,,,,darkgray,,wcursor_off>
                    wmb_str   <wmb_ic,loaded_str>
                    wmb_str   <wmb_key_quit>

saved_wmb window <20,10,40,3,normal_color,,,,,,normal_color,,,,,darkgray,,wcursor_off>
                    wmb_str   <wmb_ic,saved_str>
                    wmb_str   <wmb_key_quit>

upgrade_wmb window <18,4,44,16,normal_color,,,,,,normal_color,,,,,darkgray,,wcursor_on>
                    wmb_str   <wmb_ic,upgrade1_str>
                    wmb_str   <wmb_n ,crlfcrlf>
                    wmb_str   <wmb_n,upgrade2_str>
                    wmb_str   <wmb_n ,crlf>
                    wmb_str   <wmb_n,upgrade3_str>
                    wmb_str   <wmb_n ,crlf>
                    wmb_str   <wmb_n,upgrade4_str>
                    wmb_str   <wmb_n ,crlf>
                    wmb_str   <wmb_n,upgrade5_str>
                    wmb_str   <wmb_n ,crlf>
                    wmb_str   <wmb_n,upgrade6_str>
                    wmb_str   <wmb_n ,crlf>
                    wmb_str   <wmb_n,upgrade7_str>
                    wmb_str   <wmb_n ,crlf>
                    wmb_str   <wmb_n,upgrade8_str>
                    wmb_str   <wmb_n ,crlfcrlf>
                    wmb_str   <wmb_n,upgrade9_str>
                    wmb_str   <wmb_n ,crlfcrlf>
                    wmb_str   <wmb_n,upgrade10_str>
                    wmb_str   <wmb_leave>

reg_err_wmb window <22,9,35,7,error_color,,,,,,error_color,,,,,darkgray,,wcursor_off>
                    wmb_str   <wmb_ic,error_msg>
                    wmb_str   <wmb_n ,crlfcrlf>
                    wmb_str   <wmb_ic,reg_err_msg>
                    wmb_str   <wmb_n ,crlfcrlf>
                    wmb_str   <wmb_ic,any_key_msg>
                    wmb_str   <wmb_key_quit>

error_msg db        "Error",0
any_key_msg db      "Press any key to continue",0
not_zdir_msg db     "File is not recognized as ZDir",0
not_zdir_newest_msg db "File is not version ZDir 2.1",0
unknown_str db      "Unknown",0
reg_err_msg db      "Invalid registration name/number",0

upgrade1_str db     "Upgrading ZDir Configuration",0
upgrade2_str db     "    Loading in configuration information from a",0
upgrade3_str db     " previous version of ZDir shows that you use",0
upgrade4_str db     " ZDir on a regular basis, and are obligated",0
upgrade5_str db     " to register it.  If you already have, type in",0
upgrade6_str db     " your registration name and number.  If you",0
upgrade7_str db     " have not registered, hit F1 to see a registra-",0
upgrade8_str db     " tion form.",0
upgrade9_str db     " Registration name   :",0
upgrade10_str db    " Registration number :",0


loaded_str db       "Loaded ZDir version "
loaded_ver_str db   20 dup (?)          ; space to copy

saved_str db        "Saved ZDir version "
saved_ver_str  db   20 dup (?)          ; space to copy

ext_win_column      equ       8         ; chars across
ext_win_col_count   equ       10        ; 10 extensions per column
ext_win_w           equ       7+ext_win_column*num_extensions/ext_win_col_count
ext_win_h           equ       6+ext_win_col_count
ext_win   window <,,ext_win_w,ext_win_h,yellow+16*blue,,,,,,yellow+16*blue,,,,,darkgray,,wcursor_on>

ext_line1           db        "User Extensions",0
ext_line2           db        "A û means the extension is a user extension",0
ext_line3           db        "Toggle on/off with the space bar",0

current_ext         dw        0         ; current extension in menu
current_char        dw        0         ; current char offset to be edited
                                        ; (0,1,2), word to add to si
                                        ; 3 means it's on the check mark


                    dw        ext_key_actions
                    dw        10
ext_keys            db        up_arrow,down_arrow,left_arrow,right_arrow
                    db        home_key,end_key,page_up,page_down,backtab_key
                    db        delete_key
ext_key_actions     dw        ext_do_up,ext_do_down,ext_do_left,ext_do_right
                    dw        ext_do_home,ext_do_end,ext_do_page_up
                    dw        ext_do_page_down,ext_do_backtab
                    dw        ext_do_delete

                    dw        ext_char_key_actions
                    dw        4
ext_char_keys       db        enter_key,tab_key,backspace_key," "
ext_char_key_actions dw       ext_do_enter,ext_do_tab,ext_do_backspace
                    dw        ext_do_space

                    dw        14
illegal_ext_table   db         '."/\[]:|<>+=;,'


auto_win  window <,,40,7,yellow+16*blue,,,,,,yellow+16*blue,,,,,darkgray,,wcursor_on>
auto_lines          dw        auto_line1,auto_line2,auto_line3,auto_line4
                    dw        auto_line5,0
auto_line1    db    " 1 column range               ..",13,10,0
auto_line2    db    " 2 column range               ..",13,10,0
auto_line3    db    " 3 column range               ..",13,10,0
auto_line4    db    " 4 column range               ..",13,10,0
auto_line5    db    " 6 column range               or more",0

auto_range_start_col equ      26

auto_print_struc    struc
          var_num   db        -1
          a_row     db        ?
          col_add   db        ?         ; added to auto_range_start_col
          num_ptr   dw        ?         ; pointer to the number
          num_add   db        ?         ; added to the num
                    ends

auto_num_dump       db        "xxx",0   ; space for converting nums to strs

zero                db        0

auto_print_data     auto_print_struc <,0,0,     zero,0>,<0,0,7,columns_2,-1>
                    auto_print_struc <,1,0,columns_2,0>,<1,1,7,columns_3,-1>
                    auto_print_struc <,2,0,columns_3,0>,<2,2,7,columns_4,-1>
                    auto_print_struc <,3,0,columns_4,0>,<3,3,7,columns_6,-1>
                    auto_print_struc <,4,0,columns_6,0>

num_auto_print_data equ       9

auto_max_current    equ       3
auto_current        db        0         ; start at the first range
auto_current_color  db        yellow+16*magenta
auto_normal_color   db        yellow+16*blue

                    dw        auto_key_actions
                    dw        8
auto_keys           db        up_arrow,down_arrow,left_arrow,right_arrow
                    db        page_up,page_down,backtab_key
auto_key_actions    dw        auto_do_up,auto_do_down,auto_do_left,auto_do_right
                    dw        auto_do_page_up,auto_do_page_down,auto_do_up



load_wmb window <22,9,35,5,normal_color,,,,,,normal_color,,,,,darkgray,,wcursor_off>
          wmb_str   <wmb_ic,load1_msg>
          wmb_str   <wmb_n ,crlfcrlf>
          wmb_str   <wmb_ic,load2_msg>
          wmb_str   <wmb_leave>

load1_msg db        "Configuration changes not saved",0
load2_msg db        "Really load ZDir? (Y/N) ",0


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
        DB      30,'Hit Print Screen to print'

;----------------------------------------------------------
; Declare local data here...
;----------------------------------------------------------
.ends

.dataseg?
file_handle         dw        ?
is_registered       db        ?

temp_reg_word       dw        ?
auto_buf_addr       dw        ?
reg_buf_addr        dw        ?
.ends

assume  cs:@codeseg, ds:@dataseg, es:nothing, ss:nothing


.codeseg

.public   load_zdir
.proc     load_zdir           auto
;----------------------------------------------------------

          call      compare_config_data
          je        no_lose_data_load
          push      si
          mov       si,offset @dataseg:load_wmb
          call      win_msg_box
load_check_quit:
          mov       al,s15
          call      status_line
          call      cget_chr
          jc        load_check_quit
          call      to_upper
          cmp       al,"Y"
          je        end_check_load
          cmp       al,"N"
          je        load_do_quit
          cmp       al,escape_key
          jne       load_check_quit
load_do_quit:
          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory
          pop       si
          jmp       end_load
end_check_load:
          call      win_remove
          pop       si
no_lose_data_load:
          mov       ax,[si].mrow
          add       ax,2                ; one row under current_entry
          mov       bx,[si].mcol
          add       bx,2                ; and two col to the right
          mov       dx,[si].current_choice
          call      goto_entry                    ; si -> menu_entry
          mov       cl,[si].row
          xor       ch,ch
          add       ax,cx
          ; ax has row bx has col of string window placement
          mov       si,offset @dataseg:load_filename
          call      string_window
          .if c     end_load

          mov       si,[si].string_space          ; get to the data

          mov       di,save_filename.string_space
          call      str_cpy

          mov       di,offset @dataseg:load_temp
          call      split_ext

          cmp       b[load_temp],0
          pushf
          mov       di,offset @dataseg:load_temp
          mov       si,load_filename.string_space
          call      str_cpy
          .popf
          jne       load_ext_set

          mov       si,offset @dataseg:dot_com
          call      merge_ext           ; make it .com

load_ext_set:
          mov       si,offset @dataseg:load_temp
          mov       al,o_rdonly
	  call	    openex_h		; open the EXISTING file
	  jc	    load_err_open

	  mov	    file_handle,bx

          ; get si from a procedure determining the version
          call      get_version
          jc        load_fail
          test      si,si
          jz        load_not_zdir

          call      check_zdir_registered
          jc        end_load

each_load_action:
          cmp       is_registered,0
          jz        load_err_reg

          mov       al,[si].load_type
	  test	    al,al
          jz        load_success

	  mov	    bx,offset @dataseg:load_actions
	  call	    btbl_to_wptr
          jc        load_done           ; data error!!!
          push      di
          call      [bx]
          pop       di
          jc        load_fail
	  jmp	    each_load_action

load_fail:
          call      safe_dos_errmsge
          mov       error_wmb_str.string_ptr,si
          mov       si,offset @dataseg:error_wmb
          call      win_msg_box
          jmp       load_done
load_not_zdir:
          call      safe_dos_errmsge
          mov       error_wmb_str.string_ptr,offset @dataseg:not_zdir_msg
          mov       si,offset @dataseg:error_wmb
          call      win_msg_box
          jmp       end_load

load_success:
          call      normalize_auto_detect
          call      backup_config_data  ; to check if later changed

          mov       si,di               ; pointer to version str
          mov       di,offset @dataseg:loaded_ver_str
          call      str_cpy
          mov       si,offset @dataseg:loaded_wmb
          call      win_msg_box

load_done:
	  mov	    bx,file_handle
	  call	    close_h
          jmp       end_load

load_err_open:
          call      safe_dos_errmsge
          mov       error_wmb_str.string_ptr,si
          mov       si,offset @dataseg:error_wmb
          call      win_msg_box
          jmp       end_load

load_err_reg:
          mov       si,offset @dataseg:reg_err_wmb
          call      win_msg_box

end_load:
          ret
;----------------------------------------------------------
.endp     load_zdir


;----------------------------------------------------------
check_zdir_registered:
; pre : di -> the version string
; post: is_registered is set correctly

          .push     ax,bx,cx,dx,si,di

          mov       is_registered,0

          cmp       di,offset @dataseg:zdir21_string
          je        allowed_to_load

          mov       si,offset @dataseg:upgrade_wmb
          call      win_msg_box
          ; bx has the window handle

          mov       ax,0C17h
          call      goto_xy
          mov       si,reg_num_str.string_space
          call      cput_stri

get_reg_info:
          mov       ax,0A17h
          call      goto_xy

          mov       si,offset @dataseg:reg_name_str
          call      string_input
          jnc       get_reg_num

          cmp       al,escape_key
          je        aborted_reg_info

          cmp       al,f1
          je        reg_screen_info

get_reg_num:
          mov       ax,0C17h
          call      goto_xy

          mov       si,offset @dataseg:reg_num_str
          call      string_input
          jnc       entered_reg_info

          cmp       al,escape_key
          je        aborted_reg_info

          cmp       al,f1
          je        reg_screen_info

          jmp       get_reg_info

reg_screen_info:

          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory

          call      registration_screen

          stc
          jmp       end_check_reg

aborted_reg_info:

          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory

          stc
          jmp       end_check_reg

entered_reg_info:

          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory

          call      check_reg_info

          clc
          jmp       end_check_reg

allowed_to_load:
          ; call int 1 to set is_registered
          or        is_registered,-1
          clc

end_check_reg:
          .pop      ax,bx,cx,dx,si,di

          ret
;----------------------------------------------------------

;----------------------------------------------------------
check_reg_info:
; pre : reg_name_str, reg_num_str both entered
; post: is_registered set to the correct value

          .push     ax,bx,cx,dx,si,di,bp

          mov       si,reg_name_str.string_space
          call      str_len
          cmp       cx,9
          jb        reg_fail

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


          mov       si,reg_num_str.string_space
          call      dec_to_word
          jne       reg_fail

          sub       dx,ax
          jnz       reg_fail

          xor       dl,dh               ; some trickery
          not       dl
          mov       is_registered,dl


reg_fail:
          .pop      ax,bx,cx,dx,si,di,bp
          ret
;----------------------------------------------------------

;----------------------------------------------------------
safe_dos_errmsge:
; pre : same as dos_errmsge
; post: if not found, then si -> unknown

          call      dos_errmsge
          jnc       end_safe_dos_errmsge
          mov       si,offset @dataseg:unknown_str
end_safe_dos_errmsge:
          ret
;----------------------------------------------------------

;----------------------------------------------------------
get_version:
; pre : file opened
; post: si -> zdirxx_data for reading, Carry flag if error
;       di -> string describing version

          mov       cx,num_versions
          mov       si,offset @dataseg:ver_detect - type ver_detect_data

load_ver_detect:
          add       si,type ver_detect_data
          push      cx
          mov       ax,[si].ver_file_spot
          mov       cx,3
          mov       dx,offset @dataseg:load_temp
          call      file_read
          jc        end_get_version
          .push     si,di
          mov       di,offset @dataseg:load_temp
          lea       si,[si].detect_bytes
          mov       cx,3
          rep       cmpsb
          .pop      si,di
          pop       cx
          loopne    load_ver_detect
          jne       si_to_zero

          mov       di,[si].version_string
          mov       si,[si].version_data
          clc

end_get_version:
          ret

si_to_zero:
          clc
          xor       si,si
          ret
;----------------------------------------------------------


;----------------------------------------------------------
load_do_move:

          mov       ax,[si].file_offset
          mov       cx,[si].bytes
          mov       dx,[si].zdircfg_offset
          add       si,type load_move
          call      file_read
          ; return of file_read (carry if error) is returned

          ret
;----------------------------------------------------------

;----------------------------------------------------------
load_do_cond:

          mov       bx,[si].zdircfg_offset ; this stuff is need after the
          mov       cx,[si].if_z_val       ; load, but then si is changed
          mov       dx,[si].if_nz_val      ; so get now and save it

          .push     cx,dx

          mov       ax,[si].file_offset
          mov       cx,1
          mov       dx,offset @dataseg:load_cond_temp_byte
          add       si,type load_cond
          call      file_read

          .pop      cx,dx

          jc        err_load_do_cond

          mov       ax,cx               ; assume it's zero
          cmp       load_cond_temp_byte,0
          je        load_cond_write_byte
          mov       ax,dx

load_cond_write_byte:
          cmp       ax,load_nop
          je        end_load_cond

          mov       b[bx],al

end_load_cond:

          clc
          ret

err_load_do_cond:
          stc
          ret
;----------------------------------------------------------

;----------------------------------------------------------
load_do_set_bytes:

          mov       di,[si].zdircfg_offset
          mov       al,[si].byte_val
          xor       ch,ch
          mov       cl,[si].bytes_set
          rep       stosb
          add       si,type load_set_bytes

          ret
;----------------------------------------------------------

;----------------------------------------------------------
file_read:
; pre : ax has offset in file to read from
;       cx has number of bytes to read
;    ds:dx is where to put the data

          .push     bx,cx,dx,si

          mov       bx,file_handle
          mov       si,dx
          xor       dx,dx     ; dx:ax is file offset
          call      lseekb_h
          jc        err_end_file_read

          call      read_h
          je        success_end_file_read
err_end_file_read:
          stc
          jmp       end_file_read
success_end_file_read:
          clc
end_file_read:
          .pop      bx,cx,dx,si
          ret
;----------------------------------------------------------

;----------------------------------------------------------
normalize_auto_detect:
; pre : none;
; post: autodetect nums in increasing order

          cmp       columns_2,252
          jbe       columns_2_ok

          mov       columns_2,252
          mov       columns_3,253
          mov       columns_4,254
          mov       columns_6,255
          jmp       end_normalize_auto_detect
columns_2_ok:
          mov       al,columns_2
          cmp       columns_3,al
          ja        columns_3_ok
          inc       al
          mov       columns_3,al
columns_3_ok:
          mov       al,columns_3
          cmp       columns_4,al
          ja        columns_4_ok
          inc       al
          mov       columns_4,al
columns_4_ok:
          mov       al,columns_4
          cmp       columns_6,al
          ja        columns_6_ok
          inc       al
          mov       columns_6,al
columns_6_ok:
          ; we're all set then

end_normalize_auto_detect:
          ret
;----------------------------------------------------------


.public   save_zdir
.proc     save_zdir           auto
;----------------------------------------------------------
          mov       ax,[si].mrow
          add       ax,2                ; one row under current_entry
          mov       bx,[si].mcol
          add       bx,2                ; and two col to the right
          mov       dx,[si].current_choice
          call      goto_entry                    ; si -> menu_entry
          mov       cl,[si].row
          xor       ch,ch
          add       ax,cx
          ; ax has row bx has col of string window placement
          mov       si,offset @dataseg:save_filename
          call      string_window
          .if c     end_save

          mov       si,[si].string_space          ; get to the data
          mov       di,offset @dataseg:save_temp
          call      split_ext

          cmp       b[save_temp],0
          pushf
          mov       di,offset @dataseg:save_temp
          mov       si,save_filename.string_space
          call      str_cpy
          .popf
          jne       save_ext_set

          mov       si,offset @dataseg:dot_com
          call      merge_ext           ; make it .com

save_ext_set:
          mov       si,offset @dataseg:save_temp
          mov       al,o_rdwr
	  call	    openex_h		; open the EXISTING file
          jc        save_err_open

	  mov	    file_handle,bx
          ; get si from a procedure determining the version
          call      get_version
          jc        save_fail
          test      si,si
          jz        save_not_zdir_newest

          cmp       di,zdir_newest
          jne       save_not_zdir_newest

each_save_action:
          mov       al,[si].load_type
	  test	    al,al
          jz        save_success


          cmp       al,load_move_type   ; newest version should be
                                        ; all load_moves
          jne       save_fail
          push      di
          call      save_do_move
          pop       di
          jc        save_fail
          jmp       each_save_action

save_fail:
          call      safe_dos_errmsge
          mov       error_wmb_str.string_ptr,si
          mov       si,offset @dataseg:error_wmb
          call      win_msg_box
          jmp       save_done
save_not_zdir_newest:
          mov       error_wmb_str.string_ptr,offset @dataseg:not_zdir_newest_msg
          mov       si,offset @dataseg:error_wmb
          call      win_msg_box
          jmp       end_save

save_success:
          call      backup_config_data  ; to check if later changed
          mov       si,di               ; pointer to version str
          mov       di,offset @dataseg:saved_ver_str
          call      str_cpy
          mov       si,offset @dataseg:saved_wmb
          call      win_msg_box

save_done:
	  mov	    bx,file_handle
	  call	    close_h
          jmp       end_save

save_err_open:
          call      safe_dos_errmsge
          mov       error_wmb_str.string_ptr,si
          mov       si,offset @dataseg:error_wmb
          call      win_msg_box

end_save:

          ret
;----------------------------------------------------------
.endp     save_zdir


;----------------------------------------------------------
save_do_move:

          mov       ax,[si].file_offset
          mov       cx,[si].bytes
          mov       dx,[si].zdircfg_offset
          add       si,type load_move
          call      file_write
          ; return of file_write (carry if error) is returned

          ret
;----------------------------------------------------------

;----------------------------------------------------------
file_write:
; pre : ax has offset in file to write to
;       cx has number of bytes to write
;    ds:dx is where to get the data

          .push     bx,cx,dx,si

          mov       bx,file_handle
          mov       si,dx
          xor       dx,dx     ; dx:ax is file offset
          call      lseekb_h
          jc        err_end_file_write

          call      write_h
          je        success_end_file_write
err_end_file_write:
          stc
          jmp       end_file_write
success_end_file_write:
          clc
end_file_write:
          .pop      bx,cx,dx,si
          ret
;----------------------------------------------------------


;.public   view_config
;.proc     view_config                   auto
;;----------------------------------------------------------
;
;          xor       ax,ax               ; current window
;          call      get_whandle         ; get its handle
;          push      bx
;
;          mov       bx,STDWIN           ; make it current to write in
;          call      win_select
;          call      screen_bufsize      ;get size of screen buffer
;          call      near_malloc         ;error allocating screen buffer?
;          jc        error_memory        ;  y: exit without screen restore
;          mov       view_buf_addr,di    ;  n: save screen buffer address
;          call      save_screen         ;        and save the screen
;          call      clr_region
;
;          call      cget_chr
;
;          mov       di,view_buf_addr    ;es:di->screen buffer address
;          call      restore_screen      ;restore original screen
;          call      near_free
;
;          pop       bx
;          call      win_select
;
;          ret
;;----------------------------------------------------------
;.endp     view_config

.public   registration_screen
.proc     registration_screen           auto
;----------------------------------------------------------

          xor       ax,ax               ; current window
          call      get_whandle         ; get its handle
          push      bx

          mov       bx,STDWIN           ; make whole screen to write in
          call      win_select
          call      screen_bufsize      ;get size of screen buffer
          call      near_malloc         ;error allocating screen buffer?
          jc        error_memory        ;  y: exit without screen restore
          mov       reg_buf_addr,di     ;  n: save screen buffer address
          call      save_screen         ;        and save the screen

          call      clr_region

          xor       ax,ax
          call      goto_xy

          mov       si,offset print_form_screen
          mov       cx,print_form_scr_length
          call      uncrunch

          call      cget_chr

          mov       di,reg_buf_addr     ;es:di->screen buffer address
          call      restore_screen      ;restore original screen
          call      near_free

          pop       bx
          call      win_select

          ret
;----------------------------------------------------------
.endp     registration_screen

;----------------------------------------------------------
UnCrunch:
;Parameters Required:
;  DS:SI  ImageData source pointer.
;  CX     Length of ImageData source data.

          push      si                      ;save registers.
          push      di
          push      ax
          push      cx
          push      dx

          xor       ax,ax                   ;set current attributes.

loopa:    lodsb                              ;get next character.
          cmp       al,27                   ;does user want to toggle the blink
          jne       foreground              ;attibute?
          xor       ah,128                  ;done.
          jmp       short next

foreground:
          cmp       al,16                   ;if less than 16, then change the
          jae       background              ;foreground color.  otherwise jump.
          and       ah,0f0h                 ;strip off old foreground.
          or        ah,al
          jmp       short next

background:
          cmp       al,24                   ;if less than 24, then change the
          je        nextline                ;background color.  if exactly 24,
          ja        multioutput             ;then jump down to next line.
          sub       al,16                   ;otherwise jump to multiple output
          push      cx                      ;routines.
          mov       cl,4
          shl       al,cl
          pop       cx
          and       ah,0fh                  ;strip off old background.
          or        ah,al
          jmp       short next

nextline:
          call      cput_newline
          jmp       short next              ;the next line.

multioutput:
          cmp       al,25                   ;if equal to 25,
          jnz       notmultispaces          ;then using the
          lodsb                             ;following code as
          push      cx                      ;a count, output
          xor       ch,ch                   ;said number of
          mov       cl,al                   ;spaces.
          mov       al,32
          jmp       startoutput             ;use below loop.

notmultispaces:
          cmp       al,26                   ;if equal to 26, then using
          jnz       normalletter            ;the following two codes, display
          lodsb                             ;<x> number of <y> characters.
          dec       cx                      ;adjust main counter.
          push      cx                      ;display as many of
          xor       ch,ch                   ;whatever the user
          mov       cl,al                   ;wants.
          lodsb                             ;get character.

startoutput:
          jcxz      stop                    ;abort if already at zilch.
          call      set_attr
          call      cput_nchri

stop:     pop       cx
          dec       cx                      ;adjust main counter.

normalletter:
          call      set_attr
          call      cput_chri               ;save screen letter.

next:     jcxz      done_uncrunch           ;get next, unless cx
          loop      loopa                   ;has already one to zero.

done_uncrunch:
          pop       dx                      ;restore registers.
          pop       cx
          pop       ax
          pop       di
          pop       si
          ret
;----------------------------------------------------------


.public   edit_extensions
.proc     edit_extensions               auto
;----------------------------------------------------------
; pre : si -> menu_head of menu

          call      update_off

          mov       ax,[si].mrow
          add       ax,2                ; one row under current_entry
          mov       ext_win.w_top,ax
          mov       ax,[si].mcol
          add       ax,2                ; and two col to the right
          mov       ext_win.w_left,ax
          mov       dx,[si].current_choice
          call      goto_entry                    ; si -> menu_entry
          mov       al,[si].row
          xor       ah,ah
          add       ext_win.w_top,ax

          mov       si,offset @dataseg:ext_win
          call      win_bufsize
          jc        error_memory
          call      near_malloc
          jc        error_memory
          call      win_create
          jc        error_memory

          push      bx

          mov       cl,ext_win_w
          sub       cl,2                ; border columns
          mov       si,offset @dataseg:ext_line1
          call      cput_strci
          call      cput_newline                  ; goto line 2
          mov       si,offset @dataseg:ext_line2
          call      cput_strci
          call      cput_newline                  ; goto line 3
          mov       si,offset @dataseg:ext_line3
          call      cput_strci

          ; draw rest of window stuff here


          xor       cx,cx
each_ext_entry_print:
          call      print_one_ext_entry
          inc       cx
          cmp       cx,num_extensions
          jne       each_ext_entry_print


ext_key_loop:
          mov       cx,current_ext
          call      print_one_ext_entry ; reprint in case it changed
          mov       dx,current_char
          call      goto_ext_scr        ; set cursor to correct position

          xor       ax,ax
          call      get_whandle         ; get handle of current window
          call      update_window       ; draw it on the screen

          call      update_cursor       ; on screen set cursor


          mov       al,s7               ; on text
          call      status_line

          call      cget_chr
          jnc       ext_char_hit

          mov       bx,offset @dataseg:ext_keys
          call      btbl_to_wptr
          jc        ext_key_loop        ; hit junk key

          call      [bx]
          jmp       ext_key_loop


ext_char_hit:

          cmp       al,escape_key
          je        quit_ext_key_loop

          mov       bx,offset @dataseg:ext_char_keys
          call      btbl_to_wptr
          jc        ext_hit_letter

          call      [bx]

          jmp       ext_key_loop

ext_hit_letter:

          ; check if file char, if so use it
          cmp       al," "
          jb        ext_key_loop                  ; not legal char then

          mov       bx,offset @dataseg:illegal_ext_table
          call      is_inbtbl
          jnc       ext_key_loop                  ; if found then illegal

          call      to_upper                      ; must be uppercase

          mov       cx,current_ext
          call      goto_ext_ptr
          add       si,current_char               ; go to specific char
          mov       b[si],al                      ; set the char
          inc       current_char
          cmp       current_char,3                ; if at the end
          jne       ext_key_loop
          dec       current_char                  ; set back to end

          jmp       ext_key_loop

quit_ext_key_loop:
          pop       bx

          call      update_on

          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory

          ret
;----------------------------------------------------------
.endp     edit_extensions

;----------------------------------------------------------
ext_do_up:

          dec       current_ext
          cmp       current_ext,-1
          jne       end_ext_do_up
          mov       current_ext,max_ext_num
end_ext_do_up:
          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_down:

          inc       current_ext
          cmp       current_ext,max_ext_num
          jbe       end_ext_do_down
          and       current_ext,0
end_ext_do_down:
          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_left:

          dec       current_char
          cmp       current_char,-1
          jne       end_ext_do_left
          mov       current_char,2
          sub       current_ext,ext_win_col_count
          cmp       current_ext,0
          jge       end_ext_do_left
          add       current_ext,num_extensions
          dec       current_ext         ; move to prev row
          cmp       current_ext,num_extensions-ext_win_col_count-1
          jne       end_ext_do_left
          mov       current_ext,max_ext_num

end_ext_do_left:
          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_right:

          inc       current_char
          cmp       current_char,3
          jne       end_ext_do_right
          and       current_char,0
          add       current_ext,ext_win_col_count
          cmp       current_ext,max_ext_num
          jbe       end_ext_do_right
          sub       current_ext,num_extensions
          inc       current_ext                   ; move to next row
          cmp       current_ext,ext_win_col_count
          jne       end_ext_do_right
          and       current_ext,0
end_ext_do_right:
          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_home:

          and       current_char,0
          mov       ax,current_ext
          mov       bl,ext_win_col_count          ; which col is ext in?
          call      div_wb                        ; bh = remainder, ax = quo
          mov       al,bh
          xor       ah,ah
          mov       current_ext,ax

          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_end:

          mov       current_char,2
          mov       ax,current_ext
          mov       bl,ext_win_col_count          ; which col is ext in?
          call      div_wb                        ; bh = remainder, ax = quo
          mov       al,bh
          xor       ah,ah
          add       ax,num_extensions-ext_win_col_count
                                                  ; go to last column
          mov       current_ext,ax

          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_page_up:

          mov       ax,current_ext
          mov       bl,ext_win_col_count          ; which col is ext in?
          call      div_wb                        ; bh = remainder, ax = quo
          mov       ah,ext_win_col_count
          mul       ah
          mov       current_ext,ax

          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_page_down:

          mov       ax,current_ext
          mov       bl,ext_win_col_count          ; which col is ext in?
          call      div_wb                        ; bh = remainder, ax = quo
          mov       ah,ext_win_col_count
          mul       ah
          add       ax,ext_win_col_count-1        ; go to bottom of the col
          mov       current_ext,ax

          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_delete:

          mov       cx,current_ext
          call      goto_ext_ptr

          mov       bx,current_char     ; shift until get to the right (2)
ext_each_shift:
          cmp       bx,2
          je        ext_shifted
          mov       al,b[si+bx+1]
          mov       b[si+bx],al
          inc       bx
          jmp       ext_each_shift

ext_shifted:
          mov       b[si+bx]," "        ; space out the rightmost char

end_ext_do_delete:
          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_backtab:

          and       current_char,0
          sub       current_ext,ext_win_col_count
          cmp       current_ext,0
          jge       end_ext_do_backtab
          add       current_ext,num_extensions
          dec       current_ext         ; move to prev row
          cmp       current_ext,num_extensions-ext_win_col_count-1
          jne       end_ext_do_backtab
          mov       current_ext,max_ext_num

end_ext_do_backtab:
          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_enter:

ext_do_color_set:
          ; first, setup the color_win.w_top and .w_left
          mov       cx,current_ext
          xor       dx,dx
          call      goto_ext_scr
          call      where_xy            ; get position in window
          mov       bx,ext_win.w_top
          add       bl,ah
          mov       cx,ext_win.w_left
          add       cl,al
          add       cx,ext_win_column
          mov       dl,screen_rows
          xor       dh,dh
          sub       dx,color_win_h + 2  ; + 2 for shadow, status line
          cmp       bx,dx
          jb        ext_color_top_ok
          mov       bx,dx               ; don't go off screen
ext_color_top_ok:
          mov       color_win.w_top,bx
          mov       color_win.w_left,cx


          mov       cx,current_ext
          call      goto_ext_ptr
          mov       dl,b[si+3]          ; the color of the extension

          xor       ax,ax               ; get current window handle
          call      get_whandle
          mov       cbox_proc_data,bx
          mov       cbox_proc,offset @codeseg:ext_color_box_update
          call      color_box
          ; the extension's color is automatically updated by
          ; ext_color_box_update, so we don't need to redo it here


          ret
;----------------------------------------------------------
ext_color_box_update:
; Pre : ds:cbox_proc_data has the handle of the extension window
;       dl has the color

          .push     ax,bx,cx,dx,si,di

          xor       ax,ax
          call      get_whandle
          push      bx

          mov       bx,cbox_proc_data
          call      win_select          ; write to the extension box

          mov       cx,current_ext
          call      goto_ext_ptr
          mov       b[si+3],dl          ; set the color in the extension

          call      print_one_ext_entry

          ; bx still has window handle
          call      update_window

          pop       bx
          call      win_select
          .pop      ax,bx,cx,dx,si,di

          ret
;----------------------------------------------------------


;----------------------------------------------------------
ext_do_tab:

          and       current_char,0
          add       current_ext,ext_win_col_count
          cmp       current_ext,max_ext_num
          jbe       end_ext_do_tab
          sub       current_ext,num_extensions
          inc       current_ext                   ; move to next row
          cmp       current_ext,ext_win_col_count
          jne       end_ext_do_tab
          and       current_ext,0
end_ext_do_tab:

          ret
;----------------------------------------------------------

;----------------------------------------------------------
ext_do_backspace:

          cmp       current_char,0
          je        end_ext_do_backspace

          dec       current_char

          call      ext_do_delete       ; remember, it saves no regs!

end_ext_do_backspace:
          ret
;----------------------------------------------------------


;----------------------------------------------------------
ext_do_space:

          mov       cx,current_ext
          call      goto_ext_ptr
          mov       dl,b[si+4]          ; whether checked or not
          test      dl,dl
          jnz       ext_set_check
          or        dl,-1
          jmp       ext_do_check
ext_set_check:
          xor       dl,dl
ext_do_check:
          mov       b[si+4],dl
          ret
;----------------------------------------------------------


.proc     print_one_ext_entry           auto
;----------------------------------------------------------
; pre : cx has the number of the extension to print

          .push     ax,bx,cx,dx,si,di

          xor       dx,dx               ; set to beginning of extension
          call      goto_ext_scr

          call      goto_ext_ptr        ; si -> the extension

          mov       ah,[si+3]           ; the color
          call      set_attr
          mov       cx,3                ; 3 characters long
each_ext_char:
          lodsb
          call      cput_chri
          loop      each_ext_char

          mov       al," "
          call      cput_chri

          test      b[si+1],-1          ; just user only or not
          jz        print_no_user_ext
          mov       al,"û"
print_no_user_ext:
          call      cput_chri

          .pop      ax,bx,cx,dx,si,di
          ret
;----------------------------------------------------------
.endp     print_one_ext_entry


.proc     goto_ext_scr        auto
;----------------------------------------------------------
; pre : cx is number of the extension to go to on screen
;       dx has the current_char position of the extension

          .push     ax,bx
          mov       ax,0404h            ; top left of first extension
          call      goto_xy

          mov       ax,cx
          mov       bl,ext_win_col_count          ; which col is ext in?
          call      div_wb                        ; bh = remainder, ax = quo
          ; al is the only important part, only like 1-5
          mov       ah,ext_win_column
          mul       ah
          mov       ah,bh               ; has rows to go down
          call      rel_xy              ; al = cols to right,

          mov       al,dl
          cmp       al,3
          jne       goto_ext_scr1
          inc       al                  ; means its the check mark, so one over
goto_ext_scr1:
          xor       ah,ah
          call      rel_xy

          .pop      ax,bx
          ret
;----------------------------------------------------------
.endp     goto_ext_scr

.proc     goto_ext_ptr        auto
;----------------------------------------------------------
; pre : cx is num of extension to set si to point to
; post: si -> extension

          push      cx

          mov       si,cx               ; extension # to print
          add       cx,cx
          add       cx,cx
          add       cx,si               ; cx = cx * 5 (offset to str)
          mov       si,offset @dataseg:extension_data
          add       si,cx

          pop       cx

          ret
;----------------------------------------------------------
.endp     goto_ext_ptr


.public   register
.proc     register            auto
;----------------------------------------------------------
          ret
;----------------------------------------------------------
.endp     register

.public   auto_detect_ranges
.proc     auto_detect_ranges  auto
;----------------------------------------------------------

          call      update_off

          mov       ax,[si].mrow
          add       ax,2                ; one row under current_entry
          mov       auto_win.w_top,ax
          mov       ax,[si].mcol
          add       ax,2                ; and two cols to the right
          mov       auto_win.w_left,ax
          mov       dx,[si].current_choice
          call      goto_entry                    ; si -> menu_entry
          mov       al,[si].row
          xor       ah,ah
          add       auto_win.w_top,ax

          mov       si,offset @dataseg:auto_win
          call      win_bufsize
          jc        error_memory
          call      near_malloc
          jc        error_memory
          call      win_create
          jc        error_memory

          push      bx

          mov       si,offset @dataseg:auto_lines
auto_init:
          lodsw
          test      ax,ax
          jz        auto_printed_lines
          push      si
          mov       si,ax
          call      cput_str
          pop       si
          jmp       auto_init

auto_key_loop:

auto_printed_lines:
          mov       al,auto_range_start_col
          xor       ah,ah
          call      goto_xy

          mov       cx,num_auto_print_data
          mov       si,offset @dataseg:auto_print_data
auto_print_data_loop:
          .push     cx,si
          mov       al,auto_range_start_col
          add       al,[si].col_add
          mov       ah,[si].a_row
          call      goto_xy
          mov       al,[si].var_num
          cmp       al,auto_current
          jne       auto_normal_num
          mov       ah,auto_current_color
          jmp       auto_did_num
auto_normal_num:
          mov       ah,auto_normal_color
auto_did_num:
          call      set_attr
          mov       bx,[si].num_ptr
          mov       al,b[bx]
          add       al,[si].num_add
          mov       si,offset @dataseg:auto_num_dump
          call      convert_byte_justified
          mov       bx,si
          mov       cl,2                ; justify in width of 2
          call      cput_stri
          .pop      cx,si
          add       si,type auto_print_data
          loop      auto_print_data_loop


          mov       ah,auto_current
          mov       al,auto_range_start_col+9
          call      goto_xy

          xor       ax,ax
          call      get_whandle         ; get handle of this window
          call      update_window       ; draw it on the screen
          call      update_cursor       ; on screen set cursor

          mov       al,s13              ; status of auto detect settings box
          call      status_line         ; print status line

          call      cget_chr
          jnc       auto_char_hit

          mov       bx,offset @dataseg:auto_keys
          call      btbl_to_wptr
          jc        auto_key_loop                 ; hit junk key

          call      [bx]
          jmp       auto_key_loop

auto_char_hit:
          cmp       al,escape_key
          je        quit_auto

          cmp       al,tab_key
          jne       auto_plus_minus

          call      auto_do_down
          jmp       auto_key_loop

auto_plus_minus:
          cmp       al,"+"
          jne       auto_minus
          mov       cx,10
auto_plus_loop:
          push      cx
          call      auto_do_right
          pop       cx
          loop      auto_plus_loop
          jmp       auto_key_loop

auto_minus:
          cmp       al,"-"
          .ifne     auto_key_loop
          mov       cx,10
auto_minus_loop:
          push      cx
          call      auto_do_left
          pop       cx
          loop      auto_minus_loop

          jmp       auto_key_loop

quit_auto:
          pop       bx

          call      update_on

          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory

          ret
;----------------------------------------------------------
.endp     auto_detect_ranges

;----------------------------------------------------------
auto_do_up:

          dec       auto_current
          cmp       auto_current,-1
          jne       end_auto_do_up
          mov       auto_current,auto_max_current
end_auto_do_up:
          ret
;----------------------------------------------------------

;----------------------------------------------------------
auto_do_down:

          inc       auto_current
          cmp       auto_current,auto_max_current+1
          jne       end_auto_do_down
          and       auto_current,0
end_auto_do_down:
          ret
;----------------------------------------------------------

;----------------------------------------------------------
auto_do_left:

          mov       cl,auto_current
          call      goto_auto_ptr
          mov       bx,[si].num_ptr
          dec       b[bx]
          call      auto_do_left_check

auto_do_left_check:
          cmp       bx,offset @dataseg:columns_2  ; if last one, limit it
          jne       not_auto_do_left_last
          cmp       b[bx],0
          je        uflow_auto_do_left
end_auto_left_safe:
          clc
          ret
uflow_auto_do_left:
          inc       b[bx]                         ; can't go below 0
end_auto_left_uflow:
          stc
          ret
not_auto_do_left_last:
          mov       cl,b[bx-1]                    ; the previous num
          cmp       b[bx],cl
          jne       end_auto_left_safe
          dec       bx
          dec       b[bx]
          call      auto_do_left_check
          jnc       end_auto_left_safe
          inc       bx                            ; undo if would make uflow
          inc       b[bx]
          jmp       end_auto_left_uflow
;----------------------------------------------------------

;----------------------------------------------------------
auto_do_right:

          mov       cl,auto_current
          call      goto_auto_ptr
          mov       bx,[si].num_ptr
          inc       b[bx]
          call      auto_do_right_check
          ret

auto_do_right_check:
          cmp       bx,offset @dataseg:columns_6  ; if last one, limit it
          jne       not_auto_do_right_last
          cmp       b[bx],0
          je        oflow_auto_do_right
end_auto_right_safe:
          clc
          ret
oflow_auto_do_right:
          dec       b[bx]                         ; can't go above 255
end_auto_right_oflow:
          stc
          ret
not_auto_do_right_last:
          mov       cl,b[bx+1]                    ; the next num
          cmp       b[bx],cl
          jne       end_auto_right_safe
          inc       bx
          inc       b[bx]
          call      auto_do_right_check
          jnc       end_auto_right_safe
          dec       bx                            ; undo if would make oflow
          dec       b[bx]
          jmp       end_auto_right_oflow
;----------------------------------------------------------

;----------------------------------------------------------
auto_do_page_up:

          and       auto_current,0

          ret
;----------------------------------------------------------

;----------------------------------------------------------
auto_do_page_down:

          mov       auto_current,auto_max_current

          ret
;----------------------------------------------------------



;----------------------------------------------------------
goto_auto_ptr:
; pre : cl has the auto_print_data entry to go to
;       and it EXISTS!
; post: si -> the auto_print_struc with that val_num

          .push     bx,cx
          mov       bl,cl
          mov       si,offset @dataseg:auto_print_data
          mov       cx,num_auto_print_data
goto_auto_loop:
          cmp       [si].var_num,bl
          je        end_goto_auto_ptr
          add       si,type auto_print_struc
          loop      goto_auto_loop
          mov       si,offset @dataseg:auto_print_data ; if can't find
                                                       ; use first one
end_goto_auto_ptr:
          .pop      bx,cx
          ret
;----------------------------------------------------------


;----------------------------------------------------------
convert_byte_justified:
; pre : al has byte to print at ds:si justified right

          .push     ax,bx,cx,dx,si

          mov       ah," "
          cmp       al,10
          jae       cbj_1
          mov       b[si],ah
          inc       si
cbj_1:
          cmp       al,100
          jae       cbj_2
          mov       b[si],ah
          inc       si
cbj_2:
          call      byte_to_dec

          .pop      ax,bx,cx,dx,si
          ret
;----------------------------------------------------------


.ends

        end
