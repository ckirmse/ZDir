# makefile for construncting zdircfg from its parts
#  by Chris Kirmse
#       ZanySoft
#
#
!if $(debug)
tlinkdebug=/v
tasmdebug=/zi
!endif

zdircfg.exe : main.obj mainproc.obj config.obj string.obj \
              status.obj winmsgbx.obj menu.obj
	@c:\bin\tlink @assemble.rsp

main.obj     : config.inc menu.inc            status.inc winmsgbx.inc
mainproc.obj : config.inc menu.inc string.inc            winmsgbx.inc
config.obj   :            menu.inc
string.obj   : menu.inc            string.inc status.inc
status.obj   : menu.inc                       status.inc
winmsgbx.obj :                                           winmsgbx.inc
menu.obj     : menu.inc                       status.inc


.asm.obj :
        @c:\bin\tasm /z /kh3000 /ks500 $(tasmdebug) /ic:\sa\include /d_model=small $<

