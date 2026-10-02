# Conversor Interactivo de SVG a PNG en Alta Resolución (300 DPI)

Herramienta diseñada para Windows que permite escanear cualquier carpeta, listar sus archivos `.svg` y convertirlos interactivamente a `.png` a 300 DPI utilizando ImageMagick (`magick`).

---

## 🚀 Uso Rápido (Doble Clic)

1. Haz doble clic en **`ejecutar_conversor.bat`**.
2. **Verificación e Instalación Automática**: Si ImageMagick no está instalado en el equipo, el script lo detectará y te ofrecerá instalarlo automáticamente en ese mismo instante mediante:
   ```cmd
   winget install ImageMagick.ImageMagick
   ```
3. Se abrirá la consola interactiva:
   - Presiona `Enter` para escanear la carpeta actual, o escribe la ruta de otra carpeta.
   - Elige los archivos a convertir:
     - Un número individual (ej: `2`)
     - Varios números separados por comas (ej: `1, 3, 5`)
     - Un rango continuo (ej: `2-4`)
     - La letra `T` para convertir **todos** los archivos encontrados.
     - La letra `Q` para salir sin realizar cambios.
4. El script procesará cada archivo con:
   ```cmd
   magick -density 300 "archivo.svg" "archivo.png"
   ```
5. Al finalizar se mostrará un resumen con el total de archivos convertidos con éxito.

---

## 📂 Estructura Modular

El proyecto cumple con la Regla de Hierro de modularidad (menos de 200 líneas por archivo):

```text
conversor-svg-png/
├── ejecutar_conversor.bat          # Lanzador batch para doble clic
├── Iniciar-Conversor.ps1          # Orquestador del menú interactivo (UI)
├── modulos/
│   ├── Validar-Entorno.ps1        # Detección e instalación con winget
│   ├── Buscar-ArchivosSvg.ps1     # Escaneo y ordenamiento de archivos SVG
│   ├── Interpretar-Seleccion.ps1  # Parser de opciones, listas y rangos
│   └── Ejecutar-ConversionSvg.ps1 # Invocación de magick con -density 300
├── tests/
│   └── ConversorSvg.Tests.ps1     # Suite de 17 pruebas unitarias y de integración (TDD)
└── ejemplos/
    └── estrella_prueba.svg        # Archivo vectorial de muestra
```

---

## 🧪 Pruebas Unitarias (TDD)

Para ejecutar la suite de pruebas automatizadas:
```powershell
powershell -ExecutionPolicy Bypass -File .\tests\ConversorSvg.Tests.ps1
```

## 🛡️ Auditoría de Gobernanza
```bash
node C:\Users\Jorge\.gemini\tools\auditarProyecto.mjs C:\Users\Jorge\.gemini\antigravity\scratch\conversor-svg-png
```
