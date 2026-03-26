# Changelog

All notable changes to Task Manager Colors will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/).

## [1.2.0] — 2026-03-26

### Added

- Auto color from icon: global toggle that automatically extracts and applies the dominant color from each app's icon
- Auto color indicator in Applications tab with 4 states (active, pending, skipped, overridden)
- Per-app auto color skip list (disable auto for specific apps)
- Refresh button to re-extract all auto colors (useful after icon theme changes)
- Soften colors toggle: adapts overlay colors to match current theme brightness
- HSL partial desaturation option for minimized windows (keeps hue, reduces saturation)
- Window count segment indicators for grouped windows (up to 5 dots)
- Overlay pulse animation when hovering a window in the Windows tab
- "inherit" label on WindowsTab swatch for inherited colors with contextual tooltips
- "nyan" label on swatch for nyan-only apps/windows (both tabs)
- Shared color utilities: rgbToHsl, hslToRgb, desaturatePartial, tintWithAlpha
- Per-state Plasma decoration control: customize theme borders or hide all decoration for focused, normal, and hover states
- Hover window mode: full collapsible section with hide/background/custom style options (mirrors focused/minimized modes)
- Priority-aware state management: hover > focused > minimized > normal for all overlay properties

### Changed

- WindowsTab swatch redesigned with 6 visual states and inherited color display
- Auto indicator button uses flat style with pointer cursor for better UX
- Desaturation style selector: grayscale (classic) or partial (HSL, keeps hue)

### Fixed

- Auto-color reactivation delay when re-enabling after skip
- CPU loop (28% constant) caused by persistTimer ↔ config change handler feedback
- Race condition on stale paletteChanged results via job sequence counters
- hasAppColor incorrectly blocking manual colors for skipped apps
- drainTimer polling waste (changed to repeat: false)
- Collapsible section headers: proper vertical centering and hover fill

## [1.1.0] — 2026-03-19

### Added

- Minimized window modes: normal, hide, dim, desaturate, or custom style with optional dim/desaturate effect
- Custom focus mode: hide, background (80%), or custom style with independent thickness, opacity, and corner radius
- Full-page ColorPicker with Back navigation and Nyan Cat toggle
- "Reset all colors" and "Reset window overrides" buttons with two-click confirmation
- Expanded color palette from 30 to 40 swatches (neutrals + vivid colors)
- Alphabetical sorting of windows list

### Changed

- Popup width increased by 20% for better readability
- Redesigned About tab, Applications and Windows tabs with improved layout
- System settings dialog with scroll support and structured sections

### Fixed

- About context menu popup closing immediately after opening
- ComboBox delegate collapse in Plasma/Qt6
- Various layout and padding issues across all tabs

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

[1.2.0]: https://github.com/comxd/plasma-taskmanager-colors/releases/tag/v1.2.0
[1.1.0]: https://github.com/comxd/plasma-taskmanager-colors/releases/tag/v1.1.0
[1.0.1]: https://github.com/comxd/plasma-taskmanager-colors/releases/tag/v1.0.1
[1.0.0]: https://github.com/comxd/plasma-taskmanager-colors/releases/tag/v1.0.0
