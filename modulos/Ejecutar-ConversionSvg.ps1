<#
.SYNOPSIS
    Ejecuta la conversión de un archivo SVG a PNG usando ImageMagick.

.DESCRIPTION
    Invoca el binario 'magick' con el parámetro de densidad indicado (por defecto 300 DPI)
    para generar una imagen PNG de alta fidelidad a partir del archivo vectorial de origen.

.PARAMETER RutaOrigen
    Ruta completa del archivo SVG a convertir.

.PARAMETER RutaDestino
    Ruta completa del archivo PNG de destino a generar.

.PARAMETER Densidad
    Densidad en puntos por pulgada (DPI) para la rasterización (por defecto 300).

.OUTPUTS
    [PSCustomObject] Objeto con el estado de la operación (Exito, Mensaje, ArchivoGenerado).
#>
function Ejecutar-ConversionSvg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RutaOrigen,

        [Parameter(Mandatory = $true)]
        [string]$RutaDestino,

        [Parameter(Mandatory = $false)]
        [int]$Densidad = 300
    )

    if (-not (Test-Path -LiteralPath $RutaOrigen -PathType Leaf)) {
        return [PSCustomObject]@{
            Exito           = $false
            Mensaje         = "El archivo de origen no existe: $RutaOrigen"
            ArchivoGenerado = $null
        }
    }

    try {
        # Se protegen las rutas con comillas dobles para soportar espacios en la ruta
        $argumentos = @("-density", "$Densidad", "`"$RutaOrigen`"", "`"$RutaDestino`"")
        
        $proceso = Start-Process -FilePath "magick" -ArgumentList $argumentos -Wait -PassThru -NoNewWindow

        if ($proceso.ExitCode -eq 0) {
            return [PSCustomObject]@{
                Exito           = $true
                Mensaje         = "Conversión exitosa a $Densidad DPI."
                ArchivoGenerado = $RutaDestino
            }
        } else {
            return [PSCustomObject]@{
                Exito           = $false
                Mensaje         = "ImageMagick devolvió el código de error $($proceso.ExitCode)."
                ArchivoGenerado = $null
            }
        }
    } catch {
        return [PSCustomObject]@{
            Exito           = $false
            Mensaje         = "Error al invocar magick: $($_.Exception.Message)"
            ArchivoGenerado = $null
        }
    }
}
