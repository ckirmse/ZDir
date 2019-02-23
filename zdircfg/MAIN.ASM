;=============================================================================
;FILE:  main.asm
;
;DESC:  main function of ZDir Configuration Program
;
;NOTES:
;
;=============================================================================

include   model.inc
include   console.inc
include   window.inc
include   menu.inc
include   status.inc
include   winmsgbx.inc

include   extrn.inc

.codeseg
.extrn    exit_ok:auto
.extrn    one_menu:auto
.extrn    load_zdir:auto, save_zdir:auto, view_config:auto
.extrn    edit_extensions:auto
.extrn    auto_detect_ranges:auto
.extrn    win_msg_box:auto
.extrn    status_line:auto
.extrn    registration_screen:auto
.ends

.dataseg
;----------------------------------------------------------
; Declare external library and program data here...
;----------------------------------------------------------
include   config.inc
.extrn    config_start:byte
.extrn    config_length:abs
.extrn    crlf:byte
.extrn    crlfcrlf:byte
.extrn    menu_colors:byte
;----------------------------------------------------------
; Declare local data here...
;----------------------------------------------------------

          top_str             db        " ZanySoft Dir Configuration Program "
                              db        "v2.1  Copyright (C) 1992 Christopher "
                              db        "Kirmse",0

                              dw        menu_choices_procs
                              dw        5
          menu_choices        db        1,2,3,4,5
          menu_choices_procs  dw        load_zdir,save_zdir
                              dw        edit_extensions,registration_screen
                              dw        auto_detect_ranges

          main_menu           menu_head <32,9,2,0,7,,yes_root,>
                              menu_entry <1,,,0,1,"L",,,>
                              db        "Load ZDir configuration",0
                              menu_entry <2,,,1,2,"S",,,>
                              db        "Save ZDir configuration",0
                              menu_entry <3,,,2,3,"E",,,>
                              db        "Extension edit",0
                              menu_entry <4,,color_menu,3,,"C",ET_submenu,,>
                              db        "Color edit",0
                              menu_entry <5,,default_menu,4,,"D",ET_submenu,,>
                              db        "Default edit",0
                              menu_entry <6,,,5,4,"R",,,>
                              db        "Registration form",0
                              menu_entry <7,,,6,,"Q",ET_close,,>
                              db        "Quit",0

          color_menu          menu_head <24,7,,,5,,,>
                              menu_entry <1,,header_menu,0,,"H",ET_submenu,,>
                              db        "Header lines",0
                              menu_entry <2,,file_menu,1,,"F",ET_submenu,,>
                              db        "File entry area",0
                              menu_entry <3,,summary_menu,2,,"S",ET_submenu,,>
                              db        "Summary lines",0
                              menu_entry <4,,tree_menu,3,,"T",ET_submenu,,>
                              db        "Tree display",0
                              menu_entry <5,,misc_menu,4,,"M",ET_submenu,,>
                              db        "Miscellaneous",0

          header_menu         menu_head <42,7,,,5,,,>
                              menu_entry <1,,,0,,"C",ET_color,time_date_color,>
                              db        "Current time and date",0
                              menu_entry <2,,,1,,"P",ET_color,top_msg_color,>
                              db        "Path: and volume - messages",0
                              menu_entry <3,,,2,,"A",ET_color,top_data_color,>
                              db        "Actual path and volume",0
                              menu_entry <4,,,3,-1,"Z",ET_color,signature_color,>
                              db        "ZDir title message",0
                              menu_entry <5,,,4,-1,"H",ET_color,ZS_color,>
                              db        "Highlighted ZDir title message",0

          file_menu           menu_head <44,12,,,10,,,>
                              menu_entry <1,,,0,,"F",ET_color,file_color,>
                              db        "Files not matching any extension",0
                              menu_entry <2,,,1,,"I",ET_color,directory_color,>
                              db        "Directory entries",0
                              menu_entry <3,,,2,,"H",ET_color,hidden_color,>
                              db        "Hidden files",0
                              menu_entry <4,,,3,,"V",ET_color,volume_color,>
                              db        "Volume label ""files""",0
                              menu_entry <5,,,4,,"G",ET_color,graphics_color,>
                              db        "Graphic lines",0
                              menu_entry <6,,,5,,"S",ET_color,length_color,>
                              db        "Size of file",0
                              menu_entry <7,,,6,,"U",ET_color,file_usage_color,>
                              db        "Used disk space of file",0
                              menu_entry <8,,,7,,"A",ET_color,attribute_color,>
                              db        "Attributes",0
                              menu_entry <9,,,8,,"D",ET_color,date_color,>
                              db        "Date stamp",0
                              menu_entry <10,,,9,,"T",ET_color,time_color,>
                              db        "Time stamp",0

          summary_menu        menu_head <35,5,,,3,,>
                              menu_entry <1,,,0,,"U",ET_color,just_user_ext_color,>
                              db        "User extensions message",0
                              menu_entry <2,,,1,,"T",ET_color,totals_msg_clr,>
                              db        "Text of totals messages",0
                              menu_entry <3,,,2,,"D",ET_color,totals_color,>
                              db        "Data in totals messages",0

          tree_menu           menu_head <37,7,,,5,,>
                              menu_entry <1,,,0,,"H",ET_color,tree_text_color,>
                              db        "Header text color",0
                              menu_entry <2,,,1,,"G",ET_color,tree_graphics_color,>
                              db        "Graphic lines",0
                              menu_entry <3,,,2,,"D",ET_color,tree_dir_color,>
                              db        "Directories",0
                              menu_entry <4,,,3,,"N",ET_color,tree_files_color,>
                              db        "Number of files",0
                              menu_entry <5,,,4,,"B",ET_color,tree_size_color,>
                              db        "Bytes used by directory",0

          misc_menu           menu_head  <44,7,,,5,,>
                              menu_entry <1,,,0,,"E",ET_color,empty_color,>
                              db        "Empty space",0
                              menu_entry <2,,,1,,"P",ET_color,any_key_attrib,>
                              db        "Press any key color",0
                              menu_entry <3,,,2,,"A",ET_color,bracket_attrib,>
                              db        "¯ and ® in Press any key message",0
                              menu_entry <4,,,3,,"N",ET_color,no_files_color,>
                              db        "No files found message",0
                              menu_entry <5,,,4,,"W",ET_color,write_file_color,>
                              db        "Writing to file message",0


          default_menu        menu_head <26,5,,,3,,,>
                              menu_entry <1,,search_menu,0,12,"S",ET_submenu,,>
                              db        "Search options",0
                              menu_entry <2,,file_list_menu,1,13,"F",ET_submenu,,>
                              db        "File list choices",0
                              menu_entry <3,,output_menu,2,14,"O",ET_submenu,,>
                              db        "Output format",0

          search_menu         menu_head <41,9,,,7,,,>
                              menu_entry <1,,,0,,"P",ET_table,T_put_star_in_front,>
                              db        "Put * before filespec",0
                              menu_entry <2,,,1,,"A",ET_table,T_add_dir_entries,>
                              db        "Add directory entries in totals",0
                              menu_entry <3,,,2,,"S",ET_table,T_show_dot_file,>
                              db        "Show . and .. files",0
                              menu_entry <4,,,3,,"H",ET_table,T_hidden_show,>
                              db        "Include:  Hidden files",0
                              menu_entry <5,,,4,,"R",ET_table,T_read_only_show,>
                              db        "          Read only files",0
                              menu_entry <6,,,5,,"S",ET_table,T_system_show,>
                              db        "          System files",0
                              menu_entry <7,,,6,,"V",ET_table,T_volume_label_show,>
                              db        "          Volume labels",0

                              dw        0                   ; "starting indx"
                              dw        2                   ; 2 choices
          T_put_star_in_front db        -1,0                ; yes/no
                              dw        put_star_in_front   ; pointer to var
                              dw        yes                 ; pointer to str1
                              dw        no                  ; pointer to str2

                              dw        0,2
          T_add_dir_entries   db        -1,0
                              dw        add_dir_entries
                              dw        yes,no

                              dw        0,2
          T_show_dot_file     db        -1,0
                              dw        show_dot_file
                              dw        yes,no

                              dw        0,2
          T_hidden_show       db        -1,0
                              dw        hidden_show
                              dw        yes,no

                              dw        0,2
          T_read_only_show    db        -1,0
                              dw        read_only_show
                              dw        yes,no

                              dw        0,2
          T_system_show       db        -1,0
                              dw        system_show
                              dw        yes,no

                              dw        0,2
          T_volume_label_show db        -1,0
                              dw        volume_label_show
                              dw        yes,no

          file_list_menu      menu_head <47,11,,,9,,,>
                              menu_entry <1,,,0,,"N",ET_table,T_number_of_columns,>
                              db        "Number of columns",0
                              menu_entry <2,,,1,5,"A",,,>
                              db        "Auto detect settings",0
                              menu_entry <3,,,2,,"S",ET_table,T_left_to_right,>
                              db        "Sort ordering",0
                              menu_entry <4,,,3,,"D",ET_table,T_presort,>
                              db        "Directory placement",0
                              menu_entry <5,,,4,,"E",ET_table,T_entry_one_color,>
                              db        "Entire entry in file color",0
                              menu_entry <6,,,5,,"1",ET_table,T_sort_factor_1,>
                              db        "1st sort factor",0
                              menu_entry <7,,,6,,"2",ET_table,T_sort_factor_2,>
                              db        "2nd sort factor",0
                              menu_entry <8,,,7,,"3",ET_table,T_sort_factor_3,>
                              db        "3rd sort factor",0
                              menu_entry <9,,,8,,"4",ET_table,T_sort_factor_4,>
                              db        "4th sort factor",0

                              dw        0,6
          T_number_of_columns db        1,2,3,4,6,auto_detect
                              dw        number_of_columns
                              dw        one,two,three,four,six,auto_detect_str

                              dw        0,2
          T_left_to_right     db        -1,0
                              dw        left_to_right
                              dw        left_to_right_str,top_to_bottom_str

                              dw        0,3
          T_presort           db        PS_none,PS_dir_first,PS_dir_last
                              dw        presort
                              dw        PS_none_str,PS_dir_first_str,PS_dir_last_str

                              dw        0,2
          T_entry_one_color   db        -1,0
                              dw        entry_one_color
                              dw        yes,no

                              dw        0,11
          T_sort_factor_1     db        9,18,5,3,1,No_sort_factor
                              db        rev or  9, rev or 18,rev or  5
                              db        rev or  3, rev or  1
                              dw        sort_factor_1
                              dw        name_str,ext_str,size_str
                              dw        date_str,time_str
                              dw        none_str
                              dw        rev_name_str,rev_ext_str,rev_size_str
                              dw        rev_date_str,rev_time_str

                              dw        0,11
          T_sort_factor_2     db        9,18,5,3,1,No_sort_factor
                              db        rev or  9, rev or 18,rev or  5
                              db        rev or  3, rev or  1
                              dw        sort_factor_2
                              dw        name_str,ext_str,size_str
                              dw        date_str,time_str
                              dw        none_str
                              dw        rev_name_str,rev_ext_str,rev_size_str
                              dw        rev_date_str,rev_time_str

                              dw        0,11
          T_sort_factor_3     db        9,18,5,3,1,No_sort_factor
                              db        rev or  9, rev or 18,rev or  5
                              db        rev or  3, rev or  1
                              dw        sort_factor_3
                              dw        name_str,ext_str,size_str
                              dw        date_str,time_str
                              dw        none_str
                              dw        rev_name_str,rev_ext_str,rev_size_str
                              dw        rev_date_str,rev_time_str

                              dw        0,11
          T_sort_factor_4     db        9,18,5,3,1,No_sort_factor
                              db        rev or  9, rev or 18,rev or  5
                              db        rev or  3, rev or  1
                              dw        sort_factor_4
                              dw        name_str,ext_str,size_str
                              dw        date_str,time_str
                              dw        none_str
                              dw        rev_name_str,rev_ext_str,rev_size_str
                              dw        rev_date_str,rev_time_str

          output_menu         menu_head <48,9,,,7,,,>
                              menu_entry <1,,,0,,"S",ET_table,T_BIOS,>
                              db        "Screen writes",0
                              menu_entry <2,,,1,,"C",ET_table,T_clear_screen,>
                              db        "Clear screen to start",0
                              menu_entry <3,,,2,,"G",ET_table,T_print_graphics,>
                              db        "Graphics in alt. output",0
                              menu_entry <4,,,3,,"W",ET_table,T_wait_for_key,>
                              db        "Wait for keypress each screen",0
                              menu_entry <5,,,4,,"U",ET_table,T_commas_in_file_size,>
                              db        "Use commas in file size",0
                              menu_entry <6,,,5,,"P",ET_table,T_period_extension,>
                              db        "Print a . before extensions",0
                              menu_entry <7,,,6,,"D",ET_table,T_disk_totals,>
                              db        "Disk totals",0

                              dw        0,2
          T_BIOS              db        0,-1
                              dw        BIOS
                              dw        fast_str,bios_str

                              dw        0,2
          T_clear_screen      db        0,-1
                              dw        clear_screen
                              dw        no,yes

                              dw        0,2
          T_print_graphics    db        -1,0
                              dw        print_graphics
                              dw        IBM_extended_str,ASCII_str

                              dw        0,2
          T_wait_for_key      db        -1,0
                              dw        wait_for_key
                              dw        yes,no

                              dw        0,2
          T_commas_in_file_size db      0,-1
                              dw        commas_in_file_size
                              dw        no,yes

                              dw        0,2
          T_period_extension  db        0,-1
                              dw        period_extension
                              dw        no,yes

                              dw        0,3
          T_disk_totals       db        0,1,2
                              dw        disk_totals
                              dw        always_str,ab_str,never_str

          yes                 db        "Yes",0
          no                  db        "No",0
          one                 db        "1",0
          two                 db        "2",0
          three               db        "3",0
          four                db        "4",0
          six                 db        "6",0
          auto_detect_str     db        "Auto detect",0
          left_to_right_str   db        "Left to right",0
          top_to_bottom_str   db        "Top to bottom",0
          PS_none_str         db        "In between files",0
          PS_dir_first_str    db        "Before all files",0
          PS_dir_last_str     db        "After all files",0
          none_str            db        "DOS file order",0
          rev_name_str        db        "Reverse "
          name_str            db        "Name",0
          rev_ext_str         db        "Reverse "
          ext_str             db        "Extension",0
          rev_size_str        db        "Reverse "
          size_str            db        "Size",0
          rev_date_str        db        "Reverse "
          date_str            db        "Date",0
          rev_time_str        db        "Reverse "
          time_str            db        "Time",0
          fast_str            db        "Fast",0
          bios_str            db        "BIOS",0
          IBM_extended_str    db        "IBM extended",0
          ASCII_str           db        "Standard ASCII",0
          always_str          db        "Always",0
          ab_str              db        "A: and B: only",0
          never_str           db        "Never",0

                              dw        0
          quit_keys           label     byte

quit_wmb window <22,9,35,5,normal_color,,,,,,normal_color,,,,,darkgray,,wcursor_off>
          wmb_str   <wmb_ic,quit1_msg>
          wmb_str   <wmb_n ,crlfcrlf>
          wmb_str   <wmb_ic,quit2_msg>
          wmb_str   <wmb_leave>

quit1_msg db        "Configuration changes not saved",0
quit2_msg db        "Really quit? (Y/N) ",0

;z menu colors stuff
menu_color_ptr      dw        mono_table,bw_table

mono_table label byte
          db        M_NORMAL
          db        M_NORMAL
          db        M_BOLD
          db        M_REVERSE
          db        M_BOLDUNDER
          db        M_BOLD+M_REVERSE
bw_table label byte
          db        M_NORMAL
          db        M_NORMAL
          db        M_BOLD
          db        M_REVERSE
          db        M_BOLDUNDER
          db        M_REVERSE

.ends

.dataseg?
          scrbuf_addr         dw        ?
          backbuf             dw        ?
          config_backup       dw        ?
.ends
          .public   backbuf


IF NOT __TINY__
.stackseg
                    db      1024 dup(?)     ;define a 1024 byte stack
.ends
ENDIF


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

IF __TINY__
assume    cs:@codeseg, ds:@dataseg, es:@dataseg, ss:@dataseg
ELSE
assume    cs:@codeseg, ds:@dataseg, es:@dataseg, ss:@stackseg
ENDIF

.public   main
.proc     main      auto
;----------------------------------------------------------
          call      chk_version2        ; terminate if not dos 2 +
          or        ax,-1
          call      cem_install         ; critical error manager
          call      kbd_init
          or        ax,-1               ;ask for all available heap space
          call      near_init           ;init the near heap
          or        ax,-1
          xor       cx,cx               ; leave no dos room--who cares?
          call      far_init
          call      console_init        ;init the console i/o system
          call      screen_bufsize      ;get size of screen buffer
          call      near_malloc         ;error allocating screen buffer?
          jc        error_start         ;  y: exit without screen restore
          mov       scrbuf_addr,di      ;  n: save screen buffer address
          call      save_screen         ;        and save the screen
          call      set_80cols          ;force 80 column mode if not already
          mov       ax,WWORKBUF_SIZE    ;window system work buffer size
          call      near_malloc         ;error allocating work buffer?
          jc        error_memory        ;  y: exit
          call      win_init            ;  n: init windowing system
          mov       ax,config_length    ; in config.asm
          call      near_malloc
          jc        error_memory
          mov       config_backup,di
          call      backup_config_data
          jmp       short main_start    ; does program

;----------------------------------------------------------
.label    error_start

.public   error_memory
.label    error_memory

          call      cget_chr
          call      cget_chr
          call      cget_chr
          call      cget_chr
          call      cget_chr
          call      cget_chr
          call      cget_chr
          call      cget_chr
          call      cget_chr
          call      cget_chr
          call      cget_chr

          call      update_on

          ; display error message

;----------------------------------------------------------
.label    exit

          mov       di,scrbuf_addr      ;es:di->screen buffer address
          call      restore_screen      ;restore original screen
          call      cursor_on

          jmp       exit_ok             ;exit to DOS via SA
;----------------------------------------------------------
main_start:
          call      init_screen
          mov       ax,ds     ; @dataseg
          mov       es,ax
main_loop:
          mov       si,offset @dataseg:main_menu
          mov       di,offset @dataseg:quit_keys
          call      one_menu
          call      compare_config_data
          je        exit
          ; do a wmb, check if ok to quit
          mov       si,offset @dataseg:quit_wmb
          call      win_msg_box
main_check_quit:
          mov       al,s14
          call      status_line
          call      cget_chr
          jc        main_check_quit
          call      to_upper
          cmp       al,"Y"
          je        quit_main
          cmp       al,"N"
          je        main_do_quit
          cmp       al,escape_key
          jne       main_check_quit
main_do_quit:
          call      win_remove
          jc        error_memory
          call      near_free
          jc        error_memory
          jmp       main_loop
quit_main:
          jmp       exit
;----------------------------------------------------------
.endp     main

.proc     init_screen         auto
;----------------------------------------------------------

          call      get_dmode
          and       al,11111110b
          cmp       al,COLOR8           ; if color mode or grayscale mode
          jae       menu_colors_set
          mov       bl,al
          xor       bh,bh
          mov       si,menu_color_ptr[bx]
          mov       di,offset menu_colors
          mov       cx,6
          rep       movsb
menu_colors_set:

          mov       ax,default_cursor
          call      set_cursor

          call      cursor_off
          mov       al,"±"
          .mov_attr ah,ltgray,black
          call      fill_region

          xor       ax,ax
          call      goto_xy

          .mov_attr ah,yellow,blue
          call      set_attr

          mov       si,offset @dataseg:top_str
          call      str_len
          call      cput_str
          neg       cx
          add       cx,80               ; cx = 80 - strlen, = # spaces to print

          mov       al," "
          call      cput_nchri


          ; after everything is drawn, save the screen
          call      screen_bufsize      ; find out how much mem needed
          call      near_malloc
          .if c error_memory
          mov       backbuf,di
          call      save_screen
          call      set_backdropbuf
          ret
;----------------------------------------------------------
.endp     init_screen

.public   do_menu_item
.proc     do_menu_item        auto
;----------------------------------------------------------
; pre : al has the menu item # to look up in the table and
;       call to do the stuff, si -> menu_head

          .push     ax,bx,cx,dx,si,di

          mov       bx,offset @dataseg:menu_choices
          call      btbl_to_wptr
          jc        quit_do_menu_item             ; didn't find it

          call      [bx]                ; do the procedure then

quit_do_menu_item:
          .pop      ax,bx,cx,dx,si,di
          ret
;----------------------------------------------------------
.endp     do_menu_item

.public   backup_config_data
.proc     backup_config_data  auto
;----------------------------------------------------------
          .push     cx,si,di

          mov       si,offset @dataseg:config_start
          mov       di,config_backup
          mov       cx,config_length
          rep       movsb

          .pop      cx,si,di
          ret
;----------------------------------------------------------
.endp     backup_config_data

.public   compare_config_data
.proc     compare_config_data auto
;----------------------------------------------------------
; post: je if the same, jne if different

          .push     cx,si,di

          mov       si,offset @dataseg:config_start
          mov       di,config_backup
          mov       cx,config_length
          repe      cmpsb

          .pop      cx,si,di
          ret
;----------------------------------------------------------
.endp     compare_config_data

;----------------------------------------------------------
; Declare additional functions here...
;----------------------------------------------------------

.ends








;=============================================================================
; Stack normalization and memory management initialization labels
;
; NOTE: These declarations must remain after the declaration of the stack
; and anything in the stack segment. These labels define the end of the
; stack and the program which is where the near and far heaps are placed
; by default. These declarations do not affect the size of the program and
; may be left here even if the stack is not normalized and the heaps are
; not used.
;=============================================================================

.public		nheap_default, fheap_default
IF NOT __TINY__
.stackseg
  IF __SMALL__ OR __MEDIUM__
.public		stack_end		;used by START to normalize stack
.label		stack_end	word	;must be defined past entire stack
  ENDIF
.label		nheap_default	word	;used by the near heap
.label		fheap_default	word	;used by the far heap
.ends
ELSE
_BSSEND		segment	byte public 'STACK'
.label		nheap_default	word	;used by the near heap
.label		fheap_default	word	;used by the far heap
_BSSEND		ends
% @codeseg	group	_BSSEND
ENDIF


		end	start		;specify START as starting address
ess
