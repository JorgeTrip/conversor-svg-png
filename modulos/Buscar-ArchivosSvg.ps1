<#
.SYNOPSIS
    Busca y lista archivos con extensión .svg en un directorio especificado.

.DESCRIPTION
    Examina la ruta proporcionada, valida su existencia y retorna los archivos .svg
    ordenados alfabéticamente por su nombre base para asegurar predictibilidad en el menú.

.PARAMETER RutaDirectorio
    Ruta del directorio donde se escanearán los archivos.

.OUTPUTS
    [System.IO.FileInfo[]] Colección de archivos SVG encontrados.
#>
function Buscar-ArchivosSvg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RutaDirectorio
    )

    if (-not (Test-Path -LiteralPath $RutaDirectorio -PathType Container)) {
        Write-Warning "El directorio especificado no existe: $RutaDirectorio"
        return @()
    }

    $archivos = Get-ChildItem -LiteralPath $RutaDirectorio -Filter "*.svg" -File | 
        Sort-Object -Property Name

    if ($null -eq $archivos) {
        return @()
    }

    return ,@($archivos)
}
