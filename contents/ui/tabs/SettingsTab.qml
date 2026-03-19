/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Settings tab: collapsible sections for Appearance, Behavior, Widget.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Flickable {
    id: settingsTab

    // Dynamic max values from task delegate dimensions
    required property int computedMaxRadius
    required property int computedMaxBorder

    contentWidth: width
    contentHeight: settingsColumn.implicitHeight + settingsColumn.y + Kirigami.Units.mediumSpacing
    clip: true
    flickableDirection: Flickable.VerticalFlick
    Controls.ScrollBar.vertical: Controls.ScrollBar { id: settingsScrollBar }

    // Section expanded states (all collapsed by default)
    property bool appearanceExpanded: false
    property bool behaviorExpanded: false
    property bool widgetExpanded: false

    ColumnLayout {
        id: settingsColumn
        x: Kirigami.Units.mediumSpacing
        y: Kirigami.Units.mediumSpacing
        width: parent.width - x - (settingsScrollBar.visible ? settingsScrollBar.width + Kirigami.Units.smallSpacing : Kirigami.Units.mediumSpacing)
        spacing: Kirigami.Units.smallSpacing

        Controls.Label {
            text: i18n("Configure how colors are displayed on task manager entries.")
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        // ════════════════════════════════════════
        // ── Appearance section ──
        // ════════════════════════════════════════

        Item { height: Kirigami.Units.smallSpacing; width: 1 }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: settingsTab.appearanceExpanded ? "arrow-down" : "arrow-right"
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
            }
            Controls.Label {
                text: i18n("Appearance")
                font.bold: true
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                Layout.fillWidth: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: settingsTab.appearanceExpanded = !settingsTab.appearanceExpanded
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing
            visible: settingsTab.appearanceExpanded

            // -- Color mode --
            Controls.Label {
                text: i18n("Mode")
                font.bold: true
            }
            Controls.ComboBox {
                id: modeCombo
                Layout.fillWidth: true
                model: [
                    { value: "frame", text: i18n("Frame (all sides)") },
                    { value: "top", text: i18n("Top line") },
                    { value: "bottom", text: i18n("Bottom line") },
                    { value: "left", text: i18n("Left line") },
                    { value: "right", text: i18n("Right line") },
                    { value: "top+bottom", text: i18n("Top + Bottom") },
                    { value: "left+right", text: i18n("Left + Right") },
                    { value: "center", text: i18n("Center \u2502") },
                    { value: "center-h", text: i18n("Center \u2500") },
                    { value: "background", text: i18n("Background") },
                    { value: "background+frame", text: i18n("Background + Frame") },
                    { value: "diagonal", text: i18n("Diagonal \\") },
                    { value: "diagonal-reverse", text: i18n("Diagonal /") },
                    { value: "diagonal-cross", text: i18n("Diagonal \u2715") }
                ]
                textRole: "text"; valueRole: "value"
                Component.onCompleted: currentIndex = indexOfValue(plasmoid.configuration.colorMode)
                onActivated: plasmoid.configuration.colorMode = currentValue
            }
            Controls.Label {
                text: i18n("How the color overlay is rendered on each task.")
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: Kirigami.Theme.disabledTextColor
                wrapMode: Text.Wrap; Layout.fillWidth: true
            }

            Kirigami.Separator { Layout.fillWidth: true; Layout.topMargin: 2; Layout.bottomMargin: 2 }

            // -- Thickness --
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                visible: plasmoid.configuration.colorMode !== "background"

                Controls.Label { text: i18n("Thickness"); font.bold: true }
                RowLayout {
                    Layout.fillWidth: true
                    Controls.Slider {
                        id: borderSlider; Layout.fillWidth: true
                        from: -1; to: settingsTab.computedMaxBorder; stepSize: 1
                        value: plasmoid.configuration.autoBorderWidth ? -1 : plasmoid.configuration.borderWidth
                        onMoved: {
                            if (value < 0) {
                                plasmoid.configuration.autoBorderWidth = true;
                            } else {
                                plasmoid.configuration.autoBorderWidth = false;
                                plasmoid.configuration.borderWidth = value;
                            }
                        }
                    }
                    Controls.Label {
                        text: borderSlider.value < 0 ? i18n("Auto") : borderSlider.value + "px"
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                    }
                }
                Controls.Label {
                    text: i18n("Border/line thickness. Auto reads from theme SVG margins.")
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Kirigami.Theme.disabledTextColor
                    wrapMode: Text.Wrap; Layout.fillWidth: true
                }
            }

            // -- Opacity --
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Controls.Label { text: i18n("Opacity"); font.bold: true }
                RowLayout {
                    Layout.fillWidth: true
                    Controls.Slider {
                        id: opacitySlider; Layout.fillWidth: true
                        from: 0.1; to: 1.0; stepSize: 0.05
                        value: plasmoid.configuration.backgroundOpacity
                        onMoved: plasmoid.configuration.backgroundOpacity = value
                    }
                    Controls.Label {
                        text: Math.round(opacitySlider.value * 100) + "%"
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                    }
                }
                Controls.Label {
                    text: i18n("Color overlay intensity.")
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Kirigami.Theme.disabledTextColor
                    wrapMode: Text.Wrap; Layout.fillWidth: true
                }
            }

            // -- Corner radius --
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                visible: ["frame", "background", "background+frame"].indexOf(plasmoid.configuration.colorMode) >= 0
                      || (plasmoid.configuration.minimizedMode === "custom" && ["frame", "background", "background+frame"].indexOf(plasmoid.configuration.minimizedColorMode) >= 0)

                Controls.Label { text: i18n("Corners"); font.bold: true }
                RowLayout {
                    Layout.fillWidth: true
                    Controls.Slider {
                        id: radiusSlider; Layout.fillWidth: true
                        from: -1; to: settingsTab.computedMaxRadius; stepSize: 1
                        value: plasmoid.configuration.borderRadius
                        onMoved: plasmoid.configuration.borderRadius = value
                    }
                    Controls.Label {
                        text: radiusSlider.value < 0 ? i18n("Auto") : radiusSlider.value + "px"
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                    }
                }
                Controls.Label {
                    text: i18n("Corner rounding. Auto matches current theme. Max = perfect circle.")
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Kirigami.Theme.disabledTextColor
                    wrapMode: Text.Wrap; Layout.fillWidth: true
                }
            }
        }

        // ════════════════════════════════════════
        // ── Behavior section ──
        // ════════════════════════════════════════

        Item { height: Kirigami.Units.smallSpacing; width: 1 }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: settingsTab.behaviorExpanded ? "arrow-down" : "arrow-right"
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
            }
            Controls.Label {
                text: i18n("Behavior")
                font.bold: true
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                Layout.fillWidth: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: settingsTab.behaviorExpanded = !settingsTab.behaviorExpanded
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing
            visible: settingsTab.behaviorExpanded

            // -- Pinned apps --
            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: i18n("Pinned apps:"); Layout.preferredWidth: Kirigami.Units.gridUnit * 6 }
                Controls.ComboBox {
                    Layout.fillWidth: true
                    model: [
                        { value: "always", text: i18n("Always colored") },
                        { value: "runningOnly", text: i18n("Only when running") }
                    ]
                    textRole: "text"; valueRole: "value"
                    currentIndex: plasmoid.configuration.pinnedBehavior === "runningOnly" ? 1 : 0
                    onActivated: plasmoid.configuration.pinnedBehavior = currentValue
                }
            }
            Controls.Label {
                text: i18n("Show color on pinned favorites even when no window is open.")
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: Kirigami.Theme.disabledTextColor
                wrapMode: Text.Wrap; Layout.fillWidth: true
            }

            Kirigami.Separator { Layout.fillWidth: true; Layout.topMargin: 2; Layout.bottomMargin: 2 }

            // -- Focus --
            Controls.CheckBox {
                text: i18n("Keep color on focused task")
                checked: plasmoid.configuration.showOnFocus
                onToggled: plasmoid.configuration.showOnFocus = checked
            }
            Controls.Label {
                text: i18n("Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).")
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: Kirigami.Theme.disabledTextColor
                wrapMode: Text.Wrap; Layout.fillWidth: true
            }

            Kirigami.Separator { Layout.fillWidth: true; Layout.topMargin: 2; Layout.bottomMargin: 2 }

            // -- Minimized windows --
            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: i18n("Minimized windows:"); Layout.preferredWidth: Kirigami.Units.gridUnit * 6 }
                Controls.ComboBox {
                    id: minimizedModeCombo
                    Layout.fillWidth: true
                    model: [
                        { value: "normal", text: i18n("Normal (no change)") },
                        { value: "hide", text: i18n("Hide overlay") },
                        { value: "dim", text: i18n("Dim overlay") },
                        { value: "desaturate", text: i18n("Desaturate (grayscale)") },
                        { value: "custom", text: i18n("Custom style\u2026") }
                    ]
                    textRole: "text"; valueRole: "value"
                    Component.onCompleted: currentIndex = indexOfValue(plasmoid.configuration.minimizedMode)
                    onActivated: {
                        plasmoid.configuration.minimizedMode = currentValue;
                        if (currentValue === "custom" && !plasmoid.configuration.minimizedColorMode) {
                            plasmoid.configuration.minimizedColorMode = "frame";
                        }
                    }
                }
            }
            Controls.Label {
                text: i18n("How color overlays behave on minimized windows.")
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: Kirigami.Theme.disabledTextColor
                wrapMode: Text.Wrap; Layout.fillWidth: true
            }

            // -- Custom minimized style options --
            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.gridUnit
                spacing: Kirigami.Units.smallSpacing
                visible: plasmoid.configuration.minimizedMode === "custom"

                RowLayout {
                    Layout.fillWidth: true
                    Controls.Label { text: i18n("Minimized style:"); Layout.preferredWidth: Kirigami.Units.gridUnit * 6 }
                    Controls.ComboBox {
                        id: minimizedStyleCombo
                        Layout.fillWidth: true
                        model: [
                            { value: "frame", text: i18n("Frame (all sides)") },
                            { value: "top", text: i18n("Top line") },
                            { value: "bottom", text: i18n("Bottom line") },
                            { value: "left", text: i18n("Left line") },
                            { value: "right", text: i18n("Right line") },
                            { value: "top+bottom", text: i18n("Top + Bottom") },
                            { value: "left+right", text: i18n("Left + Right") },
                            { value: "center", text: i18n("Center \u2502") },
                            { value: "center-h", text: i18n("Center \u2500") },
                            { value: "background", text: i18n("Background") },
                            { value: "background+frame", text: i18n("Background + Frame") },
                            { value: "diagonal", text: i18n("Diagonal \\") },
                            { value: "diagonal-reverse", text: i18n("Diagonal /") },
                            { value: "diagonal-cross", text: i18n("Diagonal \u2715") }
                        ]
                        textRole: "text"; valueRole: "value"
                        delegate: Controls.ItemDelegate {
                            width: minimizedStyleCombo.width
                            text: modelData.text
                            enabled: modelData.value !== plasmoid.configuration.colorMode
                            highlighted: minimizedStyleCombo.highlightedIndex === index
                        }
                        Component.onCompleted: {
                            let saved = plasmoid.configuration.minimizedColorMode;
                            if (saved) {
                                let idx = indexOfValue(saved);
                                if (idx >= 0) currentIndex = idx;
                            }
                        }
                        onActivated: {
                            if (currentValue !== plasmoid.configuration.colorMode) {
                                plasmoid.configuration.minimizedColorMode = currentValue;
                            }
                        }
                    }
                }
                Controls.Label {
                    text: i18n("Use a different display mode when windows are minimized.")
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Kirigami.Theme.disabledTextColor
                    wrapMode: Text.Wrap; Layout.fillWidth: true
                }
                Controls.Label {
                    visible: plasmoid.configuration.minimizedColorMode === plasmoid.configuration.colorMode
                    text: i18n("Current normal mode is disabled \u2014 use Dim or Desaturate for same-shape effects.")
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Kirigami.Theme.neutralTextColor
                    wrapMode: Text.Wrap; Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    Controls.Label { text: i18n("Effect:"); Layout.preferredWidth: Kirigami.Units.gridUnit * 6 }
                    Controls.ComboBox {
                        id: minimizedEffectCombo
                        Layout.fillWidth: true
                        model: [
                            { value: "none", text: i18n("None") },
                            { value: "dim", text: i18n("Dim overlay") },
                            { value: "desaturate", text: i18n("Desaturate overlay") }
                        ]
                        textRole: "text"; valueRole: "value"
                        Component.onCompleted: {
                            if (plasmoid.configuration.minimizedDesaturate) currentIndex = indexOfValue("desaturate");
                            else if (plasmoid.configuration.minimizedDim) currentIndex = indexOfValue("dim");
                            else currentIndex = indexOfValue("none");
                        }
                        onActivated: {
                            plasmoid.configuration.minimizedDim = (currentValue === "dim");
                            plasmoid.configuration.minimizedDesaturate = (currentValue === "desaturate");
                        }
                    }
                }
            }
        }

        // ════════════════════════════════════════
        // ── Widget section ──
        // ════════════════════════════════════════

        Item { height: Kirigami.Units.smallSpacing; width: 1 }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: settingsTab.widgetExpanded ? "arrow-down" : "arrow-right"
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
            }
            Controls.Label {
                text: i18n("Widget")
                font.bold: true
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                Layout.fillWidth: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: settingsTab.widgetExpanded = !settingsTab.widgetExpanded
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing
            visible: settingsTab.widgetExpanded

            Controls.CheckBox {
                id: hideWidgetCheck
                text: i18n("Hide widget icon from panel")
                checked: plasmoid.configuration.hideWidget
                onToggled: {
                    plasmoid.configuration.hideWidget = checked;
                    plasmoid.configuration.writeConfig();
                }
                Connections {
                    target: plasmoid.configuration
                    function onHideWidgetChanged() {
                        hideWidgetCheck.checked = plasmoid.configuration.hideWidget;
                    }
                }
            }
            Controls.Label {
                text: plasmoid.configuration.hideWidget
                    ? i18n("The widget icon is hidden. Colors continue to work. To show it again: right-click the panel \u2192 Enter Edit Mode \u2192 the widget will reappear \u2192 right-click it \u2192 uncheck this option. Tip: a global shortcut can open this popup even when hidden.")
                    : i18n("Hides the widget icon from the panel. Colors continue to work normally in the background. Also available via right-click on the widget icon. Tip: set a global shortcut to open this popup even when hidden.")
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: plasmoid.configuration.hideWidget ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.disabledTextColor
                wrapMode: Text.Wrap; Layout.fillWidth: true
            }

            Controls.Button {
                icon.name: "preferences-desktop-keyboard"
                text: i18n("Configure Keyboard Shortcut\u2026")
                onClicked: Plasmoid.internalAction("configure").trigger()
                Layout.topMargin: Kirigami.Units.smallSpacing
            }
            Controls.Label {
                text: i18n("Opens the widget configuration dialog where you can set a global shortcut to toggle this popup.")
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: Kirigami.Theme.disabledTextColor
                wrapMode: Text.Wrap; Layout.fillWidth: true
            }
        }
    }
}
