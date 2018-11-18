@echo off
set a86=
set a86lib=
if %1.==regver. goto :regver
if %1.==debug. goto :debug
A86 +E 1-ZDir.asm 15-ZDir.asm 2-ZDir.asm # End-ZDir.asm TO ZDir.com
goto :end
:regver
A86 +E =Registered 1-ZDir.asm 15-ZDir.asm 2-ZDir.asm # End-ZDir.asm TO ZDir.com
goto :end
:debug
A86 +E 1-ZDir.asm 15-ZDir.asm 2-ZDir.asm # End-ZDir.asm TO ZDir.com
if errorlevel 1 goto :end
sym-z86 zdir
zd86 zdir
goto :end

:end
