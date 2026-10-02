<#
.SYNOPSIS
    Valida la disponibilidad e instalación de herramientas en el sistema.

.DESCRIPTION
    Comprueba si un comando o binario externo (como ImageMagick 'magick') está accesible
    en el PATH o en ubicaciones estándar de instalación en Windows. Si lo encuentra en una
    ruta estándar, agrega automáticamente el directorio a $env:PATH de la sesión.
    También permite la instalación automatizada mediante winget.
#>

function Validar-HerramientaMagick {
    param(
        [Parameter(Mandatory = $false)]
        [string]$Comando = "magick"
    )

    # 1. Comprobación directa en el PATH actual
    $comandoEncontrado = Get-Command -Name $Comando -ErrorAction SilentlyContinue
    if ($null -ne $comandoEncontrado) {
        return $true
    }

    # 2. Búsqueda en rutas de instalación comunes en Windows
    $carpetasBase = @(
        "C:\Program Files",
        "C:\Program Files (x86)",
        "$env:LOCALAPPDATA\Programs"
    )

    foreach ($base in $carpetasBase) {
        if (Test-Path -LiteralPath $base) {
            $coincidencias = Get-ChildItem -LiteralPath $base -Filter "ImageMagick*" -Directory -ErrorAction SilentlyContinue
            foreach ($dir in $coincidencias) {
                $posibleEjecutable = Join-Path $dir.FullName "$Comando.exe"
                if (Test-Path -LiteralPath $posibleEjecutable) {
                    $env:PATH = "$($dir.FullName);$env:PATH"
                    return $true
                }
            }
        }
    }

    return $false
}

<#
.SYNOPSIS
    Instala ImageMagick a través del administrador de paquetes winget.

.DESCRIPTION
    Verifica la disponibilidad de 'winget' en Windows e invoca la instalación del paquete
    oficial de ImageMagick ('ImageMagick.ImageMagick'). Luego actualiza la sesión y verifica.

.PARAMETER IdPaquete
    Identificador del paquete en el catálogo de winget (por defecto 'ImageMagick.ImageMagick').

.OUTPUTS
    [bool] $true si la instalación concluyó con éxito y magick quedó accesible; $false en caso contrario.
#>
function Instalar-HerramientaMagick {
    param(
        [Parameter(Mandatory = $false)]
        [string]$IdPaquete = "ImageMagick.ImageMagick"
    )

    $wingetCmd = Get-Command -Name "winget" -ErrorAction SilentlyContinue
    if ($null -eq $wingetCmd) {
        Write-Warning "El comando 'winget' no está disponible en este sistema."
        return $false
    }

    Write-Host "`nIniciando instalación de ImageMagick mediante winget..." -ForegroundColor Cyan
    Write-Host "Ejecutando: winget install $IdPaquete --accept-source-agreements --accept-package-agreements`n" -ForegroundColor DarkGray

    $argumentos = @("install", $IdPaquete, "--accept-source-agreements", "--accept-package-agreements")
    $proceso = Start-Process -FilePath "winget" -ArgumentList $argumentos -Wait -PassThru -NoNewWindow

    if ($proceso.ExitCode -eq 0) {
        Write-Host "`nInstalación finalizada. Verificando disponibilidad de magick..." -ForegroundColor Green
        return (Validar-HerramientaMagick -Comando "magick")
    } else {
        Write-Warning "winget devolvió el código de salida: $($proceso.ExitCode)"
        return $false
    }
}
