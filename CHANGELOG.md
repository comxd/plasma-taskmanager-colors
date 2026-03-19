# Changelog

All notable changes to Task Manager Colors will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

## [1.1.0] — 2026-03-17

### Added

- Minimized window mode with 5 options: normal, hide, dim, desaturate, custom style
- Custom color mode for minimized windows: use a different display mode when windows are minimized (e.g., background → left border) with optional dim or desaturate effect
- Nyan Cat desaturation support for minimized windows
- "Buy me a coffee" donation button in About tab
- "About" entry in plasmoid context menu
- KDE Store link in About tab
- Collapsible sections in Settings tab (Appearance, Behavior, Widget)
- Expanded color palette from 30 to 40 swatches (neutrals + vivid colors)

### Changed

- Redesigned About tab with compact header, centered author card, and polished layout
- Build script touches QML/JS files to invalidate Plasma cache on update
- VM reload script supports `--reset` flag to clear widget settings

### Fixed

- ComboBox delegate collapse in Plasma/Qt6 (minimized style selector)
- Auto border width calculation for cross-axis minimized color modes
- Corner radius visibility when only minimized mode uses rounded styles

## [1.0.1] — 2026-03-10

### Added

- Custom SVG icons (panel icon + store logo) with KDE color scheme support
- GitHub sponsoring configuration

### Fixed

- License and repository URL in README

## [1.0.0] — 2026-03-06

Initial release for KDE Plasma 6.

### Added

- Per-application color assignment with inline color picker (30 presets + hex input)
- Per-window temporary color overrides
- 13 display modes: frame, top, bottom, left, right, top+bottom, left+right, center, background, background+frame, diagonal, diagonal-reverse, diagonal-cross
- Nyan Cat rainbow effect with flat and wave modes, per-app or per-window
- Icon color extraction via Kirigami.ImageColors (dominant color from app icons)
- Adjustable opacity for all styles (borders, backgrounds, diagonals, nyan)
- Slider-based config: thickness, corners, opacity with Auto (from theme) option
- Focus override and focus hide options
- Vertical panel support with automatic orientation swap
- Theme-aware border radius from Plasma theme
- Pinned apps: always colored or only when running
- Hide widget from panel option
- 5-tab popup UI: Applications, Windows, Settings, Nyan Cat, About
- System settings dialog
- 15 language translations (fr, de, es, pt_BR, ru, zh_CN, ja, ko, it, nl, pl, tr, ar, uk, cs)
- CI/CD with GitHub Actions (validate, lint, build, release on tag)

[1.1.0]: https://github.com/comxd/plasma-taskmanager-colors/releases/tag/v1.1.0
[1.0.1]: https://github.com/comxd/plasma-taskmanager-colors/releases/tag/v1.0.1
[1.0.0]: https://github.com/comxd/plasma-taskmanager-colors/releases/tag/v1.0.0
