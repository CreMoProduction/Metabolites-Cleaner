set TITLE=NIST Cleaner

TITLE %title%
@echo off

if not exist "C:\metabolite_cleaner_data\" mkdir "C:\metabolite_cleaner_data"
COPY "%~dp0\config.yml" "C:\%title%_data\config.yml"
rem echo %~dp0 > data
cls
setlocal enabledelayedexpansion
set "dot=."
set "msg=initializing %title%"
for /L %%A in (1,1,1) do (
	set msg=!msg!%dot%
	echo !msg!
	timeout 1 >nul
	ping 127.0.0.1 -n 1 > nul
	cls
)

echo !msg!
rem specify path and script name
set "rscript=%~dp0\res\%title%.R" 

rem define if R.exe is installed and use its path to launch script.R
for /r "d:\Program Files" %%F in (*Rscript.exe*) do (
	"%%~fF" "%rscript%" %*

	rem msg * /time:4  "Succeeded"
    rem Echo x=msgbox^("finished running",64,""^)>"%temp%\msg.vbs"
	rem start %temp%\msg.vbs
	pause
    echo close in 2 seconds
	timeout 2 >nul
  	goto :eof
)
echo ---%title% error---
echo.
echo Rscript.exe not found. 
echo You need to install R or you have to make sure it is installed in: 'C:\Program Files\'
echo Check for details on the webpage https://github.com/CreMoProduction/
echo.  
echo.
echo Do you want to to download R? (Y/N)
choice /C YN /N
if errorlevel 2 (
    echo Canceled.
    pause
    echo close in 2 seconds
	timeout 2 >nul
  	goto :eof
) else (
    start """%~dp0\res\R downloader.exe"
)

    exit /b