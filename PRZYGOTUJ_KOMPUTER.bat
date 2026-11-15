@echo off
title Dostepnosc Sal - Konfiguracja Nowego Komputera
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_new_computer.ps1" %*
if %errorlevel% neq 0 (
    echo.
    echo Wystapil blad podczas uruchamiania konfiguracji.
    pause
)
