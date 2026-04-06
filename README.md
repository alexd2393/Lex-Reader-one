# AlexReader

Lector personal de documentos para Android. Sin anuncios, sin pagos, sin Play Store.

## Formatos soportados

| Formato | Motor | Zoom | Conversión |
|---------|-------|------|------------|
| PDF     | Syncfusion PdfViewer | ✅ nativo | No necesita |
| EPUB    | epub_view | — | No necesita |
| Markdown| flutter_markdown | — | No necesita |
| XLSX    | excel (Dart) | ✅ InteractiveViewer | No necesita |
| DOCX    | Apache POI → flutter_html | — | On-device (Kotlin) |
| PPTX    | Apache POI → PNG | ✅ InteractiveViewer | On-device (Kotlin) |

## Características

- **Modo oscuro** nativo (Material 3)
- **Filtro de luz azul** ajustable (0–100%)
- **Zoom** por pinch-to-zoom en todos los viewers
- **Transiciones** distintas por tipo de archivo
- **File picker** del sistema Android
- **Compartir** con cualquier app del teléfono
- **Historial reciente** de archivos abiertos
- Recibe archivos compartidos desde otras apps (intent OPEN)

---

## Setup local

### Requisitos

- Flutter SDK ≥ 3.19 (canal stable)
- Java 17
- Android Studio o VS Code con extensión Flutter

### Pasos

```bash
# 1. Clonar
git clone https://github.com/TU_USUARIO/alexreader.git
cd alexreader

# 2. Dependencias
flutter pub get

# 3. Conectar dispositivo o iniciar emulador
flutter devices

# 4. Correr en debug
flutter run

# 5. Build APK release local
flutter build apk --release
# El APK queda en: build/app/outputs/flutter-apk/app-release.apk
```

---

## GitHub Actions — Build automático

Cada push a `main` o `master` dispara el workflow que:

1. Instala Java 17 + Flutter stable
2. Corre `flutter build apk --release`
3. Sube el APK como **artifact descargable** por 30 días

**Cómo bajar el APK:**
1. Ir a tu repo → pestaña **Actions**
2. Click en el último workflow exitoso
3. Bajar sección **Artifacts** → descargar `alexreader-apks-XXXXXXX`

### Release automático por tag

```bash
git tag v1.0.0
git push origin v1.0.0
```

Esto crea un GitHub Release con el APK adjunto directamente.

---

## Estructura del proyecto

```
lib/
├── main.dart                   # Entry point
├── theme/
│   └── app_theme.dart          # Paleta light/dark
├── models/
│   └── document.dart           # Modelo + enum DocumentType
├── services/
│   ├── settings_service.dart   # Estado global (tema, filtro luz azul)
│   ├── file_service.dart       # File picker, historial, compartir
│   └── converter_service.dart  # Platform Channel → Android (POI)
├── screens/
│   ├── home_screen.dart        # Pantalla principal + transiciones
│   ├── viewer_screen.dart      # Wrapper del viewer + AppBar flotante
│   └── settings_screen.dart    # Ajustes de apariencia
├── viewers/
│   ├── pdf_viewer.dart         # Syncfusion
│   ├── epub_viewer.dart        # epub_view
│   ├── markdown_viewer.dart    # flutter_markdown
│   ├── excel_viewer.dart       # excel (Dart nativo)
│   ├── docx_viewer.dart        # flutter_html (recibe HTML de POI)
│   └── pptx_viewer.dart        # PageView de imágenes PNG (de POI)
└── widgets/
    ├── blue_light_filter.dart  # Overlay ámbar ajustable
    └── file_card.dart          # Tarjeta de historial reciente

android/
├── build.gradle                # Kotlin version, repos
└── app/
    ├── build.gradle            # Apache POI deps, multidex, desugaring
    └── src/main/
        ├── AndroidManifest.xml # Permisos + intent-filters por tipo
        └── kotlin/com/alexreader/
            └── MainActivity.kt # Platform Channel: docxToHtml + pptxToImages

.github/workflows/
└── build.yml                   # CI: build APK + Release por tag
```

---

## Notas sobre Apache POI en Android

- POI requiere **multidex** (muchas clases) y **Java 8 desugaring**
- El renderizado de PPTX **no es pixel-perfect** — fuentes custom y algunas
  animaciones no se reproducen, pero el contenido y layout general son fieles
- Para DOCX con imágenes embebidas podés extender `convertDocxToHtml()` para
  extraer las imágenes al temp dir e incluirlas como `<img src="file://..."/>`
- Si `minifyEnabled true` da problemas con POI, dejalo en `false` (ya está así)

---

## Instalación en Android

1. Bajá el APK desde GitHub Actions o el Release
2. En Android: **Ajustes → Seguridad → Orígenes desconocidos** (o "Instalar apps desconocidas")
3. Abrí el APK desde el administrador de archivos
4. Instalá y listo
