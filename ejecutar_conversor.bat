@echo off
title Conversor SVG a PNG (300 DPI) - ImageMagick
chcp 65001 >nul
cd /d "%~dp0"

echo ==========================================================
echo   Iniciando Conversor Interactivo de SVG a PNG (300 DPI)
echo ==========================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Iniciar-Conversor.ps1"

if %ERRORLEVEL% neq 0 (
    echo.
    echo Ocurrio un error durante la ejecucion (Codigo: %ERRORLEVEL%).
)

echo.
echo Presione cualquier tecla para cerrar esta ventana...
pause >nul
