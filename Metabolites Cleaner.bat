set TITLE=Metabolites Cleaner

TITLE %title%
@echo off

if not exist "C:\metabolite_cleaner_data\" mkdir "C:\metabolite_cleaner_data"
COPY "%~dp0\config.yml" "C:\metabolite_cleaner_data\config.yml"
rem echo %~dp0 > data
cls
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
echo      __  ___    __       __        ___ __        
echo     /  \/  /__ / /____ _/ /  ___  / (_) /____ ___
echo    / /\_/ / -_) __/ _ `/ _ \/ _ \/ / / __/ -___-/
echo   /_/__/_/\__/\__/\_,_/_.__/\___/_/_/\__/\__/___/
echo    / ___/ /__ ___ ____  ___ ____                 
echo   / /__/ / -_) _ `/ _ \/ -_) __/                 
echo   \___/_/\__/\_,_/_//_/\__/_/ 
echo.                                                                                                
setlocal enabledelayedexpansion
echo Welcome to %title%
rem choose path and script name
:start 
echo Please select an option:
echo 1. NIST Cleaner
echo 2. EXCEL Cleaner
echo 3. Name Fixer 
set /p choice=Enter your choice (1-3): 

if "%choice%"=="1" (
    echo NIST Cleaner starting.
    set "rscript=%~dp0\res\NIST Cleaner.R" 
    echo. 
) else if "%choice%"=="2" (
    echo EXCEL Cleaner starting.
    set "rscript=%~dp0\res\Excel Cleaner.R" 
    echo. 
) else if "%choice%"=="3" (
    echo Name Fixer starting.
    set "rscript=%~dp0\res\Name Fixer.R" 
    echo. 
) else (
    echo. 
    echo Invalid choice. Please select a number between 1 and 3.
    pause
    echo. 
    timeout 1 >nul
    goto :start
)


rem define if R.exe is installed and use its path to launch script.R
for /r "c:\Program Files" %%F in (*Rscript.exe*) do (
	"%%~fF" "%rscript%" %*

	rem msg * /time:4  "Succeeded"
    rem Echo x=msgbox^("finished running",64,""^)>"%temp%\msg.vbs"
	rem start %temp%\msg.vbs
	pause
    echo restarting...
    echo. 
	timeout 2 >nul
  	goto :start
)
echo ---%title% error---
echo.
echo Rscript.exe not found. 
echo You need to install R or you have to make sure it is installed in: 'C:\Program Files\'
echo Check for details on the webpage https://github.com/CreMoProduction/
echo.  
echo.
set /p choice="Do you want to download R? (Y/N): "
if /i "%choice%"=="Y" (
    start "R downloader" "%~dp0\res\R downloader.exe"
) else (
    echo Canceled.
    pause
    echo close in 2 seconds
    timeout 2 >nul
    goto :eof
)

    exit /b