@echo off
title Conversor SVG a PNG (300 DPI) - ImageMagick
chcp 65001 >nul
cd /d "%~dp0"

echo ==========================================================
echo   Iniciando Conversor Interactivo de SVG a PNG (300 DPI)
echo ==========================================================
echo.

set "PS_CMD=powershell.exe"
where pwsh.exe >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set "PS_CMD=pwsh.exe"
)

"%PS_CMD%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Iniciar-Conversor.ps1"
set "CODIGO_SALIDA=%ERRORLEVEL%"

if %CODIGO_SALIDA% neq 0 (
    echo.
    echo Ocurrio un error durante la ejecucion [Codigo: %CODIGO_SALIDA%].
)

echo.
echo Presione cualquier tecla para cerrar esta ventana...
pause >nul

