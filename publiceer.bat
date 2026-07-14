@echo off
setlocal
title Quartz publiceren

cd /d "%~dp0"

echo.
echo ============================
echo    Quartz publiceren
echo ============================
echo.

where git >nul 2>&1
if errorlevel 1 (
    echo Git is niet gevonden.
    echo Installeer Git for Windows en probeer opnieuw.
    pause
    exit /b 1
)

git status --porcelain > "%TEMP%\quartz_changes.txt"

for %%A in ("%TEMP%\quartz_changes.txt") do if %%~zA==0 (
    echo Er zijn geen wijzigingen om te publiceren.
    del "%TEMP%\quartz_changes.txt" >nul 2>&1
    pause
    exit /b 0
)

del "%TEMP%\quartz_changes.txt" >nul 2>&1

set /p MESSAGE=Geef een korte omschrijving van de wijzigingen:

if "%MESSAGE%"=="" (
    echo Geen omschrijving opgegeven.
    pause
    exit /b 1
)

echo.
echo Wijzigingen toevoegen...
git add .

if errorlevel 1 goto :error

echo.
echo Commit maken...
git commit -m "%MESSAGE%"

if errorlevel 1 goto :error

echo.
echo Wijzigingen van GitHub ophalen...
git pull --rebase origin v5

if errorlevel 1 (
    echo.
    echo Ophalen is mislukt. Mogelijk is er een conflict.
    echo Vraag iemand met Git-ervaring om git status te controleren.
    pause
    exit /b 1
)

echo.
echo Publiceren naar GitHub...
git push origin v5

if errorlevel 1 goto :error

echo.
echo ============================
echo Publiceren is gelukt.
echo ============================
pause
exit /b 0

:error
echo.
echo Er is een fout opgetreden.
echo Controleer de meldingen hierboven.
pause
exit /b 1