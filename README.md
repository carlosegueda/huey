# Huey

A menu bar color picker for macOS. Sample any pixel on screen, copy it in the format you need, and return to recent colors with a single click.

## Download

[Download the latest release](https://github.com/carlosegueda/huey/releases/latest)

Requires macOS 14 Sonoma or later.

## Features

- **Screen color picker**: sample the color of any pixel using the system magnifier.
- **Automatic copy** of the selected color.
- **Six color formats**: HEX, RGB, HSL, HSB, CMYK and OKLCH. Click any value to copy it.
- **History** of the six most recent colors. Click to view, double-click to copy.
- **Global keyboard shortcut**: <kbd>Control</kbd> + <kbd>Command</kbd> + <kbd>C</kbd> opens the picker from any app.
- **Settings**:
  - Copy color on pick
  - Copy format
  - Lowercase HEX and optional `#` prefix
  - Close the panel after picking a color
  - Launch at login
  - Interface language: English, Spanish, Portuguese and Russian

## Installation

1. Download `Huey-x.y.z.zip` from [Releases](https://github.com/carlosegueda/huey/releases/latest) and unzip it.
2. Move `Huey.app` to the Applications folder.
3. Open the app. The eyedropper icon appears in the menu bar.

### First launch

Huey is not signed with an Apple Developer ID, so macOS blocks it the first time it is opened. To allow it:

1. Try to open Huey and dismiss the warning.
2. Open **System Settings > Privacy & Security**.
3. Scroll to the message about Huey and click **Open Anyway**.

If macOS reports that the app is damaged, run the following command in Terminal and open it again:

```bash
xattr -dr com.apple.quarantine /Applications/Huey.app
```

## Usage

| Action | How |
|---|---|
| Open the panel | Click the menu bar icon |
| Pick a color | Click the eyedropper button, press <kbd>Return</kbd> with the panel open, or press <kbd>Control</kbd> + <kbd>Command</kbd> + <kbd>C</kbd> from any app |
| Cancel picking | Press <kbd>Esc</kbd> while the magnifier is visible |
| Copy a format | Click its row |
| Copy a recent color | Double-click its swatch |
| Open settings | Click the gear icon |
| Quit | Click the power icon |

## Building from source

Requires Xcode 16 or later.

```bash
git clone https://github.com/carlosegueda/huey.git
cd huey
open Huey.xcodeproj
```

Press <kbd>Command</kbd> + <kbd>R</kbd> to build and run. Xcode resolves the Swift Package Manager dependencies automatically:

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts): global keyboard shortcut
- [MenuBarExtraAccess](https://github.com/orchetect/MenuBarExtraAccess): programmatic control of the menu bar panel

### Project structure

```
Huey/
├── HueyApp.swift          # App entry point and menu bar item
├── Model/
│   ├── RGB.swift          # Color value and format conversions
│   └── ColorStore.swift   # History, selection, picking and copying
├── Views/                 # Main panel, settings and controls
├── Support/               # Clipboard, shortcuts, preferences and languages
├── Localizable.xcstrings  # Translations
└── Assets.xcassets        # App icon
HueyTests/
```
