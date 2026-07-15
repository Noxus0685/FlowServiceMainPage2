@echo off
set CURDATE=%DATE%
set CURTIME=%TIME%
set NAMEARH="COMPONENTS_FP_full_src_"
@rar a -r -x*.rar -x*.~* -x*.zip -x*.wav -x*.log -x*.dcu -x*.bak -x*.pdf -x*.dll -x*.idb -x*.txt -x*.dcu -x*.exe -x__history -x__recovery -xWIN32 -xTMP -xUTILS -xskins -xIMAGES -xLOGS -xDOC -x*.git %NAMEARH%%CURDATE:~8,2%%CURDATE:~3,2%%CURDATE:~0,2%%CURTIME:~0,2%%CURTIME:~3,2%%CURTIME:~6,2% -p"az!@QA"
MOVE *.RAR e:\GOOGLE\Archives\Projects\Delphi\FMX
set CURDATE=
set CURTIME=
set NAMEARH=
