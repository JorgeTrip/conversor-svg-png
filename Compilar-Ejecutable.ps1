<#
.SYNOPSIS
    Script de compilación que genera un archivo ejecutable único (.exe) a partir de los scripts de PowerShell.
.DESCRIPTION
    Concatena los módulos y el script principal en un archivo temporal y genera un binario
    autónomo de 64 bits utilizando el módulo ps2exe.
#>

[CmdletBinding()]
param(
    [string]$Version = "0.1.0",
    [string]$Destino = "dist/ConversorSVG.exe"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Iniciando proceso de compilación a ejecutable único..." -ForegroundColor Cyan

# 1. Verificar disponibilidad de ps2exe
if (-not (Get-Command "Invoke-ps2exe" -ErrorAction SilentlyContinue)) {
    Write-Host "Módulo ps2exe no encontrado. Configurando entorno e instalando..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    }
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    Install-Module -Name "ps2exe" -Scope CurrentUser -Force -SkipPublisherCheck
}

# 2. Asegurar carpeta de destino
$carpetaSalida = Split-Path -Path $Destino -Parent
if (-not [string]::IsNullOrWhiteSpace($carpetaSalida) -and -not (Test-Path -LiteralPath $carpetaSalida)) {
    New-Item -ItemType Directory -Path $carpetaSalida -Force | Out-Null
}

$rutaTemporal = Join-Path $env:TEMP ("ConversorSVG_compilacion_" + [guid]::NewGuid().ToString() + ".ps1")
$directorioRaiz = $PSScriptRoot

try {
    Write-Host "Unificando módulos en archivo temporal..." -ForegroundColor DarkGray
    
    # 3. Concatenar cabecera, módulos y script principal
    $contenidoTotal = [System.Text.StringBuilder]::new()
    [void]$contenidoTotal.AppendLine("# Generado automáticamente para empaquetado v$Version")
    [void]$contenidoTotal.AppendLine("# Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    [void]$contenidoTotal.AppendLine()

    $modulos = @(
        (Join-Path $directorioRaiz "modulos/Validar-Entorno.ps1"),
        (Join-Path $directorioRaiz "modulos/Buscar-ArchivosSvg.ps1"),
        (Join-Path $directorioRaiz "modulos/Interpretar-Seleccion.ps1"),
        (Join-Path $directorioRaiz "modulos/Ejecutar-ConversionSvg.ps1")
    )

    foreach ($archivoModulo in $modulos) {
        if (-not (Test-Path -LiteralPath $archivoModulo)) {
            throw "No se encontró el módulo requerido: $archivoModulo"
        }
        $lineas = Get-Content -LiteralPath $archivoModulo -Raw -Encoding UTF8
        [void]$contenidoTotal.AppendLine($lineas)
        [void]$contenidoTotal.AppendLine()
    }

    # Agregar el script principal
    $rutaPrincipal = Join-Path $directorioRaiz "Iniciar-Conversor.ps1"
    $lineasPrincipal = Get-Content -LiteralPath $rutaPrincipal -Raw -Encoding UTF8
    [void]$contenidoTotal.AppendLine($lineasPrincipal)

    [System.IO.File]::WriteAllText($rutaTemporal, $contenidoTotal.ToString(), [System.Text.Encoding]::UTF8)

    # 4. Invocar compilador ps2exe
    Write-Host "Compilando binario con ps2exe (Versión: $Version)..." -ForegroundColor Cyan
    
    Invoke-ps2exe `
        -inputFile $rutaTemporal `
        -outputFile $Destino `
        -title "Conversor SVG a PNG (300 DPI)" `
        -description "Conversor interactivo de gráficos vectoriales SVG a formato PNG en alta resolución" `
        -company "Jorge" `
        -product "Conversor SVG a PNG" `
        -copyright "Jorge - Distribuido bajo Licencia MIT" `
        -version $Version `
        -requireAdmin:$false `
        -noConsole:$false

    # 5. Comprobar que el ejecutable existe
    if (Test-Path -LiteralPath $Destino) {
        $tamanoMb = [math]::Round(((Get-Item -LiteralPath $Destino).Length / 1MB), 2)
        Write-Host "`n✅ Compilación exitosa: $Destino ($tamanoMb MB)" -ForegroundColor Green
    } else {
        throw "El archivo de salida $Destino no fue generado."
    }
}
finally {
    # 6. Limpieza segura del archivo temporal
    if (Test-Path -LiteralPath $rutaTemporal) {
        Remove-Item -LiteralPath $rutaTemporal -Force -ErrorAction SilentlyContinue
    }
}
