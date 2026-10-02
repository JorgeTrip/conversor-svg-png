# Suite de Pruebas Unitarias para el Conversor de SVG a PNG
# Regla TDD: Verificación completa de módulos de lógica

$ErrorActionPreference = "Stop"
$rutaModulos = Join-Path $PSScriptRoot "..\modulos"

# Cargar módulos
. (Join-Path $rutaModulos "Interpretar-Seleccion.ps1")
. (Join-Path $rutaModulos "Buscar-ArchivosSvg.ps1")
. (Join-Path $rutaModulos "Validar-Entorno.ps1")
. (Join-Path $rutaModulos "Ejecutar-ConversionSvg.ps1")

$pruebasTotales = 0
$pruebasSuperadas = 0
$pruebasFallidas = 0

function Afirmar-Igual($valorEsperado, $valorObtenido, $descripcion) {
    $script:pruebasTotales++
    $esperadoJson = ($valorEsperado | ConvertTo-Json -Compress)
    $obtenidoJson = ($valorObtenido | ConvertTo-Json -Compress)
    
    if ($esperadoJson -eq $obtenidoJson) {
        $script:pruebasSuperadas++
        Write-Host "  [OK] $descripcion" -ForegroundColor Green
    } else {
        $script:pruebasFallidas++
        Write-Host "  [FALLO] $descripcion" -ForegroundColor Red
        Write-Host "    Esperado: $esperadoJson" -ForegroundColor DarkRed
        Write-Host "    Obtenido: $obtenidoJson" -ForegroundColor DarkRed
    }
}

Write-Host "=== Iniciando Suite de Pruebas de Conversor SVG a PNG ===" -ForegroundColor Cyan

# 1. Pruebas de Interpretar-Seleccion
Write-Host "`n-- Pruebas: Interpretar-Seleccion --" -ForegroundColor Yellow
Afirmar-Igual @(0, 1, 2) (Interpretar-Seleccion -Entrada "T" -TotalElementos 3) "Opción 'T' selecciona todos los índices base 0"
Afirmar-Igual @(0, 1, 2) (Interpretar-Seleccion -Entrada "t" -TotalElementos 3) "Opción 't' (minúscula) funciona igual"
Afirmar-Igual $null (Interpretar-Seleccion -Entrada "Q" -TotalElementos 3) "Opción 'Q' retorna null (señal de salida)"
Afirmar-Igual @(1) (Interpretar-Seleccion -Entrada "2" -TotalElementos 5) "Selección individual '2' retorna índice 1"
Afirmar-Igual @(0, 2, 4) (Interpretar-Seleccion -Entrada "1, 3, 5" -TotalElementos 5) "Selección por comas '1, 3, 5' retorna índices 0, 2, 4"
Afirmar-Igual @(1, 2, 3) (Interpretar-Seleccion -Entrada "2-4" -TotalElementos 5) "Selección por rango '2-4' retorna índices 1, 2, 3"
Afirmar-Igual @(0, 2) (Interpretar-Seleccion -Entrada "1, 99, 3" -TotalElementos 3) "Ignora índices fuera de rango"

# 2. Pruebas de Buscar-ArchivosSvg
Write-Host "`n-- Pruebas: Buscar-ArchivosSvg --" -ForegroundColor Yellow
$directorioTemporal = Join-Path ([System.IO.Path]::GetTempPath()) ("test_svg_" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $directorioTemporal -Force | Out-Null
try {
    "svg1" | Set-Content (Join-Path $directorioTemporal "b.svg")
    "svg2" | Set-Content (Join-Path $directorioTemporal "a.svg")
    "txt1" | Set-Content (Join-Path $directorioTemporal "c.txt")
    
    $encontrados = Buscar-ArchivosSvg -RutaDirectorio $directorioTemporal
    Afirmar-Igual 2 $encontrados.Count "Encuentra exactamente 2 archivos SVG"
    Afirmar-Igual "a.svg" $encontrados[0].Name "Ordena los archivos alfabéticamente por nombre (primero a.svg)"
    Afirmar-Igual "b.svg" $encontrados[1].Name "Segundo archivo es b.svg"
} finally {
    Remove-Item -Path $directorioTemporal -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. Pruebas de Validar-Entorno
Write-Host "`n-- Pruebas: Validar-Entorno --" -ForegroundColor Yellow
Afirmar-Igual $false (Validar-HerramientaMagick -Comando "comando_inexistente_12345_xyz") "Retorna falso ante un binario inexistente"
$magickDisponible = Validar-HerramientaMagick -Comando "magick"
Afirmar-Igual $true $magickDisponible "Detecta la herramienta ImageMagick en el sistema"

# 4. Pruebas de Ejecutar-ConversionSvg
Write-Host "`n-- Pruebas: Ejecutar-ConversionSvg --" -ForegroundColor Yellow
$resInexistente = Ejecutar-ConversionSvg -RutaOrigen "archivo_que_no_existe_9876.svg" -RutaDestino "destino.png"
Afirmar-Igual $false $resInexistente.Exito "Falla correctamente cuando el archivo origen no existe"

if ($magickDisponible) {
    $rutaSvgPrueba = Join-Path $PSScriptRoot "..\ejemplos\estrella_prueba.svg"
    $rutaPngPrueba = Join-Path ([System.IO.Path]::GetTempPath()) ("estrella_out_" + [System.Guid]::NewGuid().ToString("N") + ".png")
    
    try {
        $resultadoConv = Ejecutar-ConversionSvg -RutaOrigen $rutaSvgPrueba -RutaDestino $rutaPngPrueba -Densidad 300
        Afirmar-Igual $true $resultadoConv.Exito "Convierte exitosamente SVG a PNG con ImageMagick a 300 DPI"
        Afirmar-Igual $true (Test-Path -LiteralPath $rutaPngPrueba) "El archivo PNG generado existe en disco"
        
        # Verificar tamaño mayor que 0
        $tamanoBytes = (Get-Item -LiteralPath $rutaPngPrueba).Length
        Afirmar-Igual $true ($tamanoBytes -gt 100) "El archivo PNG contiene datos generados (tamaño > 100 bytes)"
    } finally {
        Remove-Item -Path $rutaPngPrueba -Force -ErrorAction SilentlyContinue
    }
}

# 5. Pruebas de Instalar-HerramientaMagick
Write-Host "`n-- Pruebas: Instalar-HerramientaMagick --" -ForegroundColor Yellow
$funcionExiste = (Get-Command Instalar-HerramientaMagick -ErrorAction SilentlyContinue) -ne $null
Afirmar-Igual $true $funcionExiste "La función Instalar-HerramientaMagick está definida"

# Resumen
Write-Host "`n==============================================="
Write-Host "Totales: $pruebasTotales | Superadas: $pruebasSuperadas | Fallidas: $pruebasFallidas"
if ($pruebasFallidas -gt 0) {
    exit 1
} else {
    exit 0
}
