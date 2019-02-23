@echo off
if .%1==.rebuild goto rebuildit
if .%1==.debug goto debugit
make -fassemble.mak
goto end
:rebuildit
make -B -fassemble.mak
goto end
:debugit
make -B -Ddebug -fassemble.mak
:end
