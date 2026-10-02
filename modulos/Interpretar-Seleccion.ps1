<#
.SYNOPSIS
    Interpreta y valida la selección del usuario en consola.

.DESCRIPTION
    Transforma la entrada del usuario (números, rangos '1-3', listas '1,2', 'T' para todos o 'Q' para salir)
    en un arreglo ordenado de índices base 0 válidos.

.PARAMETER Entrada
    Cadena de texto ingresada por el usuario en el menú interactivo.

.PARAMETER TotalElementos
    Cantidad total de elementos disponibles en la lista para validar límites.

.OUTPUTS
    [int[]] Arreglo de índices seleccionados (base 0) o $null en caso de solicitud de salida o entrada vacía.
#>
function Interpretar-Seleccion {
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [string]$Entrada,

        [Parameter(Mandatory = $true)]
        [int]$TotalElementos
    )

    if ([string]::IsNullOrWhiteSpace($Entrada)) {
        return $null
    }

    $textoLimpio = $Entrada.Trim().ToUpperInvariant()

    # Opciones de salida inmediata
    if ($textoLimpio -eq "Q" -or $textoLimpio -eq "S") {
        return $null
    }

    # Opción de seleccionar todos los elementos
    if ($textoLimpio -eq "T" -or $textoLimpio -eq "A") {
        if ($TotalElementos -le 0) { return @() }
        return @(0..($TotalElementos - 1))
    }

    $indicesSeleccionados = [System.Collections.Generic.HashSet[int]]::new()
    $segmentos = $textoLimpio -split ','

    foreach ($segmento in $segmentos) {
        $parte = $segmento.Trim()
        if ([string]::IsNullOrEmpty($parte)) { continue }

        # Manejo de rango numérico: ej. "2-5"
        if ($parte -match '^\s*(\d+)\s*-\s*(\d+)\s*$') {
            $desde = [int]$matches[1]
            $hasta = [int]$matches[2]
            $inicio = [Math]::Min($desde, $hasta)
            $fin = [Math]::Max($desde, $hasta)

            for ($num = $inicio; $num -le $fin; $num++) {
                $indiceBase0 = $num - 1
                if ($indiceBase0 -ge 0 -and $indiceBase0 -lt $TotalElementos) {
                    [void]$indicesSeleccionados.Add($indiceBase0)
                }
            }
        }
        # Manejo de número individual: ej. "3"
        elseif ($parte -match '^\s*(\d+)\s*$') {
            $indiceBase0 = [int]$matches[1] - 1
            if ($indiceBase0 -ge 0 -and $indiceBase0 -lt $TotalElementos) {
                [void]$indicesSeleccionados.Add($indiceBase0)
            }
        }
    }

    $resultadoFinal = @($indicesSeleccionados) | Sort-Object
    return ,$resultadoFinal
}
