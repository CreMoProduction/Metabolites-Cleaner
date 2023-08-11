@echo off
setlocal enabledelayedexpansion

set "replacement_line=OS_environment = TRUE  #<-------EDIT HERE TO DEBUG MODE"

for %%F in ("NIST Cleaner.R" "Excel Cleaner.R" "Name Fixer.R") do (
    set "temp_file=%%~nF_temp%%~xF"
    set "line_count=0"
    
    (for /f "usebackq delims=" %%L in ("%%~F") do (
        set /a "line_count+=1"
        if !line_count! equ 3 (
            echo !replacement_line!
        ) else (
            echo %%L
        )
    )) > "!temp_file!"

    move /y "!temp_file!" "%%~F" > nul
)

echo Replacement complete.
