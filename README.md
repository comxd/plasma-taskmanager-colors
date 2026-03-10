# Task Manager Colors

A KDE Plasma 6 plasmoid that adds per-application color overlays to your task manager.

![Plasma 6](https://img.shields.io/badge/Plasma-6-blue) ![License](https://img.shields.io/badge/license-GPL--2.0--or--later-green)

## Features

- **Per-application colors** — assign a unique color to each app in your taskbar
- **Per-window overrides** — temporarily override colors on individual windows
- **13 display modes** — frame, top/bottom/left/right lines, center, background, background+frame, diagonal variants
- **Nyan Cat rainbow** — animated rainbow effect with flat and wave modes, per-app or per-window
- **Icon color extraction** — auto-detect dominant color from app icons
- **Adjustable opacity** — works on all styles (borders, backgrounds, diagonals, nyan)
- **Vertical panel support** — auto-adapts orientation
- **Theme-aware** — auto border radius and thickness from your Plasma theme
- **15 languages** — fr, de, es, pt_BR, ru, zh_CN, ja, ko, it, nl, pl, tr, ar, uk, cs

## Installation

### From .plasmoid file

```bash
kpackagetool6 -t Plasma/Applet -i com.comexpertise.plasma.taskmanagercolors-*.plasmoid
```

### From source

```bash
git clone https://github.com/comxd/plasma-taskmanager-colors.git
cd org.kde.comexpertise.plasma.task-manager.colors
kpackagetool6 -t Plasma/Applet -i .
```

Then right-click your panel → **Add Widgets** → search **"Task Manager Colors"**.

## Configuration

The widget popup has 5 tabs:

| Tab              | Description                                             |
| ---------------- | ------------------------------------------------------- |
| **Applications** | Assign colors and Nyan Cat effect per app               |
| **Windows**      | Temporary per-window color overrides                    |
| **Settings**     | Color mode, thickness, opacity, corners, focus behavior |
| **Nyan Cat**     | Rainbow speed, wave effect, FPS                         |
| **About**        | Version and links                                       |

System settings are also available via right-click → **Configure Task Manager Colors**.

## Building

```bash
bash scripts/build-plasmoid.sh
```

Produces `com.comexpertise.plasma.taskmanagercolors-<version>.plasmoid` ready for distribution.

## Development

### Requirements

- KDE Plasma 6
- `kpackagetool6`
- `gettext` (for translations)

### Translations

```bash
bash translate/merge.sh   # extract strings → update .po files
bash translate/build.sh   # compile .po → .mo
```

## License

GPL-2.0-or-later — see individual file headers for details.

## Author

David DIVERRES — [ComExpertise](https://www.comexpertise.com)
