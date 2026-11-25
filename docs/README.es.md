[English](../README.md) | [한국어](README.ko.md) | [简体中文](README.zh-Hans.md) | [日本語](README.ja.md) | Español | [Deutsch](README.de.md) | [Français](README.fr.md) | [tlhIngan Hol](README.tlh.md)

# PopPage

[![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-000000?logo=apple&logoColor=white)](#requisitos)
[![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](#requisitos)
[![Latest Release](https://img.shields.io/github/v/release/badugisoft/poppage?label=Release)](https://github.com/badugisoft/poppage/releases/latest)
[![Website](https://img.shields.io/badge/Website-GitHub%20Pages-2563EB)](https://badugisoft.github.io/poppage/)

Una aplicación ligera de barra de menús para macOS escrita en Swift para fijar sitios web y abrirlos rápidamente en una ventana emergente.

[Sitio web](https://badugisoft.github.io/poppage/) · [Descargar última versión](https://github.com/badugisoft/poppage/releases/latest) · [Capturas de pantalla](#capturas-de-pantalla) · [Características](#características) · [Atajos](#atajos-de-teclado) · [Changelog](../CHANGELOG.md)

## ¿Por qué PopPage?

Ya existen muchas aplicaciones similares de navegador en la barra de menús para macOS —algunas con muchas más funciones—, como **MenubarX**, **FloatBrowser** y **MenuBox**. PopPage nació de la necesidad de contar con una aplicación nativa **completamente gratuita** y **ligera**, centrada únicamente en lo esencial (personalización de iconos por página, políticas de navegación, cabeceras HTTP personalizadas y exportación/importación de ajustes) sin sobrecarga innecesaria.

Esta aplicación fue **creada al 100 % con Antigravity**.

## Capturas de pantalla

| Ventana emergente | Ajustes de página | Ajustes de la app |
| :---: | :---: | :---: |
| ![Ventana emergente](images/screenshot-popover.png) | ![Ajustes de página](images/screenshot-page-settings.png) | ![Ajustes de la app](images/screenshot-app-settings.png) |

## Descarga e instalación

1. Descarga el archivo `.dmg` o `.zip` más reciente (firmado y notarizado) desde [GitHub Releases](https://github.com/badugisoft/poppage/releases/latest).
2. Abre el `.dmg` (o descomprime el `.zip`) y arrastra **PopPage.app** a `/Applications`.
3. Inicia **PopPage** desde Aplicaciones o Spotlight.

## Características

- **Gestión de páginas**: Añade, edita, elimina, reordena y activa/desactiva sitios web desde la ventana de gestión
- **Personalización del icono de la barra de menús**: Obtén favicons automáticamente, usa texto personalizado o elige una imagen propia (compatible con modo plantilla)
- **Alternancia y foco de la ventana emergente**: Haz clic en el elemento de la barra de menús para abrir o cerrar la ventana emergente y ciérrala automáticamente al perder el foco si lo deseas
- **Animación de apertura/cierre**: Opción por página para activar o desactivar la animación
- **Políticas de nuevas ventanas y navegación**:
  - Abre enlaces de nueva ventana (`target="_blank"`, etc.) en el navegador externo predeterminado
  - Configura el comportamiento de navegación (`No navegar` / `Abrir en navegador externo` / `Navegar en la ventana emergente`)
- **Cabeceras HTTP personalizadas**: Añade, activa/desactiva y elimina cabeceras HTTP/HTTPS por página (incluido `User-Agent`)
- **Tamaño y redimensionamiento**: Define ancho y alto predeterminados, cambia el tamaño desde la esquina inferior derecha y guarda opcionalmente el tamaño modificado
- **Control de zoom**: Define un zoom predeterminado por página y recuerda opcionalmente el zoom ajustado
- **Atajos de teclado**: Atajos activables por página con un popover compacto de referencia junto al interruptor
- **Barra inferior y superposición**: Muestra u oculta los botones de Atrás/Adelante, Recargar y Zoom, o superpón la barra sobre la página web con opacidad ajustable
- **Fondo adaptativo de la barra**: Ajusta automáticamente el color de la barra inferior al fondo de la página web
- **Ajustes de la aplicación**: Configura el inicio automático al iniciar sesión, el idioma de la aplicación (`Predeterminado del sistema` / `English` / `한국어` / `简体中文` / `日本語` / `Español` / `Deutsch` / `Français` / `tlhIngan Hol`) y exporta/importa ajustes (páginas, iconos personalizados e idioma) en JSON desde la pestaña Ajustes
- **Localización**: Compatible con inglés (predeterminado), coreano, chino simplificado, japonés, español, alemán, francés y klingon

## Atajos de teclado

Disponibles dentro de la ventana emergente cuando **Activar atajos de teclado** está habilitado en la página:

| Atajo | Acción |
| :---: | :--- |
| `⌘ +` | Acercar |
| `⌘ -` | Alejar |
| `⌘ 0` | Restablecer zoom |
| `⌘ [` | Atrás |
| `⌘ ]` | Adelante |
| `⌘ R` | Recargar |

## Requisitos

- macOS 14.0 o posterior
- Xcode / cadena de herramientas Swift 6 (para compilar desde el código fuente)

## Compilación desde el código fuente

```bash
# Mostrar todos los objetivos disponibles
make help

# Compilación debug / release
make build
make release

# Crear paquete .app (build/PopPage.app)
make app

# Compilar y ejecutar
make run

# Instalar en /Applications (o INSTALL_DIR=/ruta/personalizada make install)
make install
make uninstall

# Regenerar AppIcon.icns o validar plist/strings
make icon
make lint

# Limpiar artefactos de compilación
make clean
```

## Almacenamiento de datos

- Configuración de páginas: `~/Library/Application Support/PopPage/pages.json`
- Favicons en caché e imágenes personalizadas: `~/Library/Application Support/PopPage/icons/`
- Preferencia de idioma de la app: `~/Library/Preferences/com.badugisoft.poppage.plist`
