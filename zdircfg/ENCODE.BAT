@echo off
set tasmd=
set tlinkd=
if not %1.==debug. goto assemble
set tasmd=/zi
set tlinkd=/v
:assemble
tasm /z %tasmd% /ic:\sa\include /d_model=tiny encode.asm
tlink /t %tlinkd% c:\sa\lib\startt.obj+encode.obj,encode.com,,c:\sa\lib\sat.lib
del encode.map
del encode.obj
goto end
:end
set tasmd=
set tlinkd=
