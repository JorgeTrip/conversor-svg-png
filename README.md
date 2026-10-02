# Conversor Interactivo de SVG a PNG en Alta Resolución (300 DPI)

[![GitHub Release](https://img.shields.io/github/v/release/JorgeTrip/conversor-svg-png?style=for-the-badge&color=2563eb)](https://github.com/JorgeTrip/conversor-svg-png/releases/latest)
[![Descargar Ejecutable](https://img.shields.io/badge/Descargar-ConversorSVG.exe-10b981?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/JorgeTrip/conversor-svg-png/releases/latest/download/ConversorSVG.exe)
[![Estado CI/CD](https://img.shields.io/github/actions/workflow/status/JorgeTrip/conversor-svg-png/publicar-release.yml?branch=main&style=for-the-badge&label=CI%2FCD)](https://github.com/JorgeTrip/conversor-svg-png/actions)

Herramienta diseñada para Windows que permite escanear cualquier carpeta, listar sus archivos `.svg` y convertirlos interactivamente a formato `.png` a 300 DPI utilizando ImageMagick (`magick`).

---

## 📥 Descarga Directa (Archivo Único)

Puedes descargar la última versión distribuible lista para usar:

👉 **[Descargar ConversorSVG.exe (Última versión)](https://github.com/JorgeTrip/conversor-svg-png/releases/latest/download/ConversorSVG.exe)**

> [!NOTE]
> No requiere instalación de scripts ni dependencias de PowerShell. Es un único archivo ejecutable independiente (`.exe`) para Windows.

---

## 🚀 Modos de Uso

### Modo 1: Ejecutable Único (`ConversorSVG.exe`)
1. Descarga y haz doble clic sobre **`ConversorSVG.exe`**.
2. **Detección Automática**: Si ImageMagick no está instalado en el equipo, te ofrecerá instalarlo automáticamente en ese mismo instante mediante `winget`.
3. Sigue las instrucciones interactivas en pantalla.

### Modo 2: Lanzador Batch (`ejecutar_conversor.bat`)
Si ejecutas desde el código fuente del repositorio, haz doble clic en **`ejecutar_conversor.bat`**.

---

## ⌨️ Opciones del Menú Interactivo
- **Ruta**: Presiona `Enter` para escanear la carpeta actual o introduce otra ruta.
- **Selección de archivos**:
  - `2`: Selecciona un archivo individual.
  - `1, 3, 5`: Selecciona archivos específicos separados por coma.
  - `2-4`: Selecciona un rango consecutivo de archivos.
  - `T`: Convierte **todos** los archivos SVG encontrados.
  - `Q`: Sale del conversor sin realizar cambios.

---

## ⚙️ Compilación Local a Ejecutable

Para compilar el binario único `.exe` en tu equipo:
```powershell
npm run compilar
```
O directamente con PowerShell:
```powershell
pwsh -ExecutionPolicy Bypass -File .\Compilar-Ejecutable.ps1 -Version "0.1.0"
```
El ejecutable resultante se genera en la carpeta `dist/ConversorSVG.exe`.

---

## 🧪 Pruebas Automatizadas y Auditoría

Ejecutar suite de pruebas:
```powershell
npm run test:ps1
```

Ejecutar auditoría centralizada de gobernanza:
```powershell
npm run auditar
```
