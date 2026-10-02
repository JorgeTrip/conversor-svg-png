<#
.SYNOPSIS
    Script principal interactivo para la conversión de archivos SVG a PNG con ImageMagick.
#>

[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline = $true)]
    [string]$RutaCarpeta = ""
)

# Resolución de carpeta de trabajo
if ([string]::IsNullOrWhiteSpace($RutaCarpeta)) {
    $RutaCarpeta = if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) { $PSScriptRoot } else { (Get-Location).Path }
}

# Configuración de codificación para caracteres en español
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
try { $Host.UI.RawUI.WindowTitle = "Conversor SVG a PNG (300 DPI) - ImageMagick" } catch { }

# [INICIO_MODULOS]
# Carga de módulos en entorno modular si existe el directorio
$dirModulos = Join-Path $RutaCarpeta "modulos"
if (-not (Test-Path -LiteralPath $dirModulos) -and -not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $dirModulos = Join-Path $PSScriptRoot "modulos"
}

if (Test-Path -LiteralPath $dirModulos) {
    . (Join-Path $dirModulos "Validar-Entorno.ps1")
    . (Join-Path $dirModulos "Buscar-ArchivosSvg.ps1")
    . (Join-Path $dirModulos "Interpretar-Seleccion.ps1")
    . (Join-Path $dirModulos "Ejecutar-ConversionSvg.ps1")
}
# [FIN_MODULOS]

<#
.SYNOPSIS
    Muestra el arte ASCII representativo del conversor junto con la firma del autor.
#>
function Mostrar-ArteAscii {
    $lineas = @(
        @{ Svg = "   ____  __     ______  "; Flecha = "         "; Png = "   ____  _   _  ____  " },
        @{ Svg = "  / ___| \ \   / / ___| "; Flecha = "  ====>  "; Png = "  |  _ \| \ | |/ ___| " },
        @{ Svg = "  \___ \  \ \ / / |  _  "; Flecha = "         "; Png = "  | |_) |  \| | |  _  " },
        @{ Svg = "   ___) |  \ V / | |_| |"; Flecha = "         "; Png = "  |  __/| |\  | |_| | " },
        @{ Svg = "  |____/    \_/   \____|"; Flecha = "         "; Png = "  |_|   |_| \_|\____| " }
    )
    foreach ($l in $lineas) {
        Write-Host $l.Svg -NoNewline -ForegroundColor Cyan
        Write-Host $l.Flecha -NoNewline -ForegroundColor DarkGray
        Write-Host $l.Png -ForegroundColor Green
    }
    Write-Host (" " * 43 + "by J.O.T.`n") -ForegroundColor DarkGray
}

try { Clear-Host } catch { }
Mostrar-ArteAscii
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       CONVERSOR DE ARCHIVOS SVG A PNG (ALTA RESOLUCIÓN)  " -ForegroundColor White
Write-Host "                   Densidad fijada: 300 DPI               " -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Validar disponibilidad de ImageMagick e instalar vía winget si falta
if (-not (Validar-HerramientaMagick -Comando "magick")) {
    Write-Host "`n[AVISO] No se encontró el comando 'magick' en el sistema." -ForegroundColor Yellow
    Write-Host "ImageMagick es necesario para convertir archivos SVG a PNG.`n" -ForegroundColor Cyan
    
    $respuestaInstalar = Read-Host "¿Deseas instalar ImageMagick ahora con 'winget install ImageMagick.ImageMagick'? [S/N] (Por defecto: S)"
    $opcion = if ([string]::IsNullOrWhiteSpace($respuestaInstalar)) { "S" } else { $respuestaInstalar.Trim().ToUpperInvariant() }

    if ($opcion -eq "S") {
        $instalado = Instalar-HerramientaMagick -IdPaquete "ImageMagick.ImageMagick"
        if (-not $instalado) {
            Write-Host "`n[ERROR CRÍTICO] La instalación o verificación de ImageMagick no se completó." -ForegroundColor Red
            Write-Host "Puedes instalarlo manualmente desde: https://imagemagick.org/script/download.php`n" -ForegroundColor Yellow
            Read-Host "Presiona Enter para cerrar"
            exit 1
        }
        Write-Host "`nImageMagick instalado y configurado correctamente. Continuando...`n" -ForegroundColor Green
    } else {
        Write-Host "`nOperación cancelada por el usuario. ImageMagick es requerido para continuar." -ForegroundColor Red
        Read-Host "Presiona Enter para cerrar"
        exit 1
    }
}

# 2. Determinar carpeta a escanear
Write-Host "`nCarpeta actual: $RutaCarpeta" -ForegroundColor Gray
$opcionCarpeta = Read-Host "Presiona Enter para escanear esta carpeta o escribe otra ruta"
if (-not [string]::IsNullOrWhiteSpace($opcionCarpeta)) {
    if (Test-Path -LiteralPath $opcionCarpeta -PathType Container) {
        $RutaCarpeta = $opcionCarpeta
    } else {
        Write-Host "La ruta especificada no existe. Usando carpeta predeterminada: $RutaCarpeta" -ForegroundColor Yellow
    }
}

# 3. Escanear archivos SVG
Write-Host "`nBuscando archivos SVG en: $RutaCarpeta ..." -ForegroundColor Gray
$archivosSvg = Buscar-ArchivosSvg -RutaDirectorio $RutaCarpeta

if ($archivosSvg.Count -eq 0) {
    Write-Host "`n[AVISO] No se encontraron archivos .svg en la carpeta seleccionada." -ForegroundColor Yellow
    Write-Host "Copia tus archivos SVG en esta carpeta y vuelve a ejecutar el programa.`n" -ForegroundColor Gray
    Read-Host "Presiona Enter para finalizar"
    exit 0
}

# 4. Mostrar listado interactivo
Write-Host "`nSe encontraron $($archivosSvg.Count) archivo(s) SVG:`n" -ForegroundColor Green
for ($i = 0; $i -lt $archivosSvg.Count; $i++) {
    $archivo = $archivosSvg[$i]
    $numero = "{0,3}" -f ($i + 1)
    $tamanoKb = [Math]::Round($archivo.Length / 1KB, 1)
    $pngDestino = Join-Path $archivo.DirectoryName "$($archivo.BaseName).png"
    $estadoPng = if (Test-Path -LiteralPath $pngDestino) { "[PNG existe]" } else { "[Pendiente ]" }
    
    $colorEstado = if (Test-Path -LiteralPath $pngDestino) { "DarkYellow" } else { "DarkGray" }
    Write-Host "  [$numero] " -NoNewline -ForegroundColor Cyan
    Write-Host "$($archivo.Name.PadRight(35)) " -NoNewline -ForegroundColor White
    Write-Host "($($tamanoKb) KB) " -NoNewline -ForegroundColor DarkGray
    Write-Host "$estadoPng" -ForegroundColor $colorEstado
}

# 5. Capturar selección del usuario
Write-Host "`nOpciones de selección:" -ForegroundColor Gray
Write-Host "  - Número(s) individual(es) o separados por coma (ej: 1, 3, 5)" -ForegroundColor DarkCyan
Write-Host "  - Rango de números (ej: 1-4)" -ForegroundColor DarkCyan
Write-Host "  - 'T' para transformar TODOS los archivos" -ForegroundColor DarkCyan
Write-Host "  - 'Q' para salir sin realizar cambios" -ForegroundColor DarkCyan

$seleccionTexto = Read-Host "`n¿Qué archivos deseas convertir?"
$indices = Interpretar-Seleccion -Entrada $seleccionTexto -TotalElementos $archivosSvg.Count

if ($null -eq $indices -or $indices.Count -eq 0) {
    Write-Host "`nOperación cancelada o selección vacía. No se realizaron conversiones." -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 0
}

# 6. Ejecutar conversiones
Write-Host "`nIniciando conversión de $($indices.Count) archivo(s) a 300 DPI...`n" -ForegroundColor Green

$exitosos = 0
$fallidos = 0

foreach ($idx in $indices) {
    $svg = $archivosSvg[$idx]
    $salidaPng = Join-Path $svg.DirectoryName "$($svg.BaseName).png"

    Write-Host "⚙️  Convirtiendo: $($svg.Name) -> $($svg.BaseName).png ... " -NoNewline -ForegroundColor White
    $resultado = Ejecutar-ConversionSvg -RutaOrigen $svg.FullName -RutaDestino $salidaPng -Densidad 300

    if ($resultado.Exito) {
        Write-Host "[OK]" -ForegroundColor Green
        $exitosos++
    } else {
        Write-Host "[ERROR]" -ForegroundColor Red
        Write-Host "   $($resultado.Mensaje)" -ForegroundColor DarkRed
        $fallidos++
    }
}

# 7. Resumen de ejecución
Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "                 RESUMEN DE CONVERSIÓN                    " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Total procesados : $($indices.Count)" -ForegroundColor White
Write-Host "Exitosos         : $exitosos" -ForegroundColor Green
if ($fallidos -gt 0) {
    Write-Host "Con errores      : $fallidos" -ForegroundColor Red
}
Write-Host "==========================================================" -ForegroundColor Cyan

Read-Host "`nProceso finalizado. Presiona Enter para salir"
