@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo        AetherOS ISO Recombination Tool        
echo ===============================================
echo.

cd /d "%~dp0"

set "FOUND=0"
for %%F in (*.iso.part*) do (
    set "FOUND=1"
    set "SAMPLE_FILE=%%~nxF"
)

if "!FOUND!"=="0" (
    echo [-] Error: No .iso.part* files found in the current folder!
    echo Please ensure all downloaded .part files are placed in this folder.
    pause
    exit /b 1
)

:: Identify target ISO prefix
for /f "tokens=1,2,3,4 delims=." %%a in ("!SAMPLE_FILE!") do (
    if "%%c"=="iso" (
        set "TARGET_ISO=%%a.%%b.iso"
    ) else if "%%b"=="iso" (
        set "TARGET_ISO=%%a.iso"
    ) else (
        set "TARGET_ISO=aetheros.iso"
    )
)

echo [*] Target ISO: !TARGET_ISO!
echo [*] Merging parts matching !TARGET_ISO!.part*...
echo.

copy /b "!TARGET_ISO!.part*" "!TARGET_ISO!" >nul
if errorlevel 1 (
    echo [-] Error: Binary copy failed.
    pause
    exit /b 1
)

echo.
echo [!] Merge completed successfully: !TARGET_ISO!
echo [*] Calculating SHA256 hash (please wait)...
certutil -hashfile "!TARGET_ISO!" SHA256

echo.
echo ======================================================
echo  Reassembled: !TARGET_ISO!
echo  Check the hash above against sha256sum.txt.
echo  Ready for Rufus / BalenaEtcher or VM boot!
echo ======================================================
echo.
pause
