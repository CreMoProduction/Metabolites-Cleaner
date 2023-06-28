TITLE NIST Cleaner 
@echo off

cls
setlocal enabledelayedexpansion
set "dot=."
set "msg=initializing Metabolites Cleaner"
for /L %%A in (1,1,3) do (
	set msg=!msg!%dot%
	echo !msg!
	timeout 1 >nul
	ping 127.0.0.1 -n 1 > nul
	cls
)

echo !msg!
rem specify path and script name
set "rscript=%~dp0\Metabolites Cleaner.R" 

rem define if R.exe is installed and use its path to launch script.R
for /r "c:\Program Files" %%F in (*Rscript.exe*) do (
	"%%~fF" "%rscript%" %*

	rem msg * /time:4  "Succeeded"
    rem Echo x=msgbox^("mevis finished running",64,"mevis"^)>"%temp%\msg.vbs"
	rem start %temp%\msg.vbs
	pause
    echo close in 2 seconds
	timeout 2 >nul
  	goto :eof
)
echo ---mevis error---
echo.
echo No Rscript.exe found. 
echo Maybe you need to install R or make sure it is installed in 'C:\Program Files\...'
echo Check for details on mevis webpage https://github.com/CreMoProduction/mevis
echo.  
echo Do you want to download R?
echo.
pause
call :MsgBox "Would you like to download R?"  "VBYesNo+VBQuestion" "mevis"
    if errorlevel 7 (
        echo NO - don't go to the url
    ) else if errorlevel 6 (
        echo YES - go to the url
        start "" "https://cran.r-project.org/bin/windows/base/"
    )

    exit /b