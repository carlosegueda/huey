# Huey

Selector de color para la barra de menús de macOS. Elige cualquier píxel de la pantalla con el cuentagotas, cópialo en el formato que necesites y vuelve a tus colores recientes con un clic.

![Huey](docs/screenshot.png)

## Descargar

**[⬇ Descargar la última versión](https://github.com/carlosegueda/huey/releases/latest)**

Requiere **macOS 14 Sonoma** o posterior.

## Funciones

- **Cuentagotas de pantalla**: elige el color de cualquier píxel con la lupa del sistema.
- **Copia automática** del color al elegirlo.
- **6 formatos**: HEX, RGB, HSL, HSB, CMYK y OKLCH. Haz clic en cualquiera para copiarlo.
- **Historial** de los últimos 6 colores: clic para verlo, doble clic para copiarlo.
- **Atajo global** <kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>C</kbd> para abrir el cuentagotas desde cualquier app.
- **Ajustes**:
  - Copiar al elegir un color
  - Formato a copiar
  - HEX en minúsculas e incluir `#`
  - Cerrar el panel al elegir un color
  - Abrir al iniciar sesión
  - Idioma: English, Español, Português, Русский

## Instalación

1. Descarga `Huey-x.y.z.zip` desde [Releases](https://github.com/carlosegueda/huey/releases/latest) y descomprímelo.
2. Mueve `Huey.app` a la carpeta **Aplicaciones**.
3. Ábrela. Aparecerá el icono del cuentagotas en la barra de menús, junto al reloj.

### "No se puede abrir porque Apple no puede comprobar si contiene software malicioso"

Huey no está firmada con una cuenta de Apple Developer, así que macOS la bloquea la primera vez. Para permitirla:

1. Intenta abrir Huey y cierra el aviso.
2. Ve a **Ajustes del Sistema › Privacidad y seguridad**.
3. Baja hasta el mensaje sobre Huey y pulsa **Abrir igualmente**.

Si macOS dice que la app "está dañada", ejecuta esto en la Terminal y vuelve a abrirla:

```bash
xattr -dr com.apple.quarantine /Applications/Huey.app
```

## Uso

| Acción | Cómo |
|---|---|
| Abrir el panel | Clic en el icono de la barra de menús |
| Elegir un color | Botón del cuentagotas, <kbd>Enter</kbd> con el panel abierto, o <kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>C</kbd> desde cualquier app |
| Cancelar | <kbd>Esc</kbd> con la lupa abierta |
| Copiar un formato | Clic en su fila |
| Copiar un color reciente | Doble clic en su círculo |
| Ajustes | Icono del engranaje |
| Salir | Icono de encendido |

## Compilar desde el código

Requiere Xcode 16 o posterior.

```bash
git clone https://github.com/carlosegueda/huey.git
cd huey
open Huey.xcodeproj
```

Pulsa <kbd>⌘</kbd> <kbd>R</kbd>. Xcode descarga las dependencias solo:

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts): atajo global
- [MenuBarExtraAccess](https://github.com/orchetect/MenuBarExtraAccess): abrir y cerrar el panel desde el código

### Estructura

```
Huey/
├── HueyApp.swift          # punto de entrada: icono en la barra de menús
├── Model/
│   ├── RGB.swift          # el color y sus conversiones de formato
│   └── ColorStore.swift   # historial, selección, elegir y copiar
├── Views/                 # panel principal, ajustes y sus controles
├── Support/               # portapapeles, atajos, preferencias, idiomas
├── Localizable.xcstrings  # traducciones
└── Assets.xcassets        # icono de la app
HueyTests/
```
