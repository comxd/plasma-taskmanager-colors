/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Settings tab: collapsible sections for Appearance, Focused, Minimized, Behavior, Widget.
    Uses StackLayout for inline mode picker pages.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "../components" as Components

StackLayout {
    id: settingsTab

    // Dynamic max values from task delegate dimensions
    required property int computedMaxRadius
    required property int computedMaxBorder

    currentIndex: 0

    // Mode value → display text lookup
    readonly property var modeLabels: ({
        "frame": i18n("Frame (all sides)"),
        "top": i18n("Top line"),
        "bottom": i18n("Bottom line"),
        "left": i18n("Left line"),
        "right": i18n("Right line"),
        "top+bottom": i18n("Top + Bottom"),
        "left+right": i18n("Left + Right"),
        "center": i18n("Center \u2502"),
        "center-h": i18n("Center \u2500"),
        "background": i18n("Background"),
        "background+frame": i18n("Background + Frame"),
        "diagonal": i18n("Diagonal \\"),
        "diagonal-reverse": i18n("Diagonal /"),
        "diagonal-cross": i18n("Diagonal \u2715")
    })

    function modeLabelFor(value) {
        return modeLabels[value] || value;
    }

    // ════════════════════════════════════════
    // ── Page 0: Settings content ──
    // ════════════════════════════════════════

    Flickable {
        id: settingsFlickable

        contentWidth: width
        contentHeight: settingsColumn.implicitHeight + settingsColumn.y + Kirigami.Units.mediumSpacing
        clip: true
        flickableDirection: Flickable.VerticalFlick
        Controls.ScrollBar.vertical: Controls.ScrollBar { id: settingsScrollBar }

        // Section expanded states (all collapsed by default)
        property bool appearanceExpanded: false
        property bool focusedExpanded: false
        property bool minimizedExpanded: false
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

            Controls.ItemDelegate {
                Layout.fillWidth: true
                verticalPadding: 0; horizontalPadding: 0; topInset: 0; bottomInset: 0
                implicitHeight: Kirigami.Units.gridUnit * 1.5
                onClicked: settingsFlickable.appearanceExpanded = !settingsFlickable.appearanceExpanded
                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        source: settingsFlickable.appearanceExpanded ? "arrow-down" : "arrow-right"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Controls.Label {
                        text: i18n("Appearance")
                        font.bold: true
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing
                visible: settingsFlickable.appearanceExpanded

                // -- Color mode --
                Controls.Label {
                    text: i18n("Mode")
                    font.bold: true
                }
                Controls.ItemDelegate {
                    Layout.fillWidth: true
                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Controls.Label {
                            text: settingsTab.modeLabelFor(plasmoid.configuration.colorMode)
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Kirigami.Icon {
                            source: "go-next"
                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                            Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        }
                    }
                    onClicked: {
                        settingsTab.currentIndex = 1;
                        normalModePicker.activate();
                    }
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
            // ── Focused window section ──
            // ════════════════════════════════════════

            Item { height: Kirigami.Units.smallSpacing; width: 1 }

            Controls.ItemDelegate {
                Layout.fillWidth: true
                verticalPadding: 0; horizontalPadding: 0; topInset: 0; bottomInset: 0
                implicitHeight: Kirigami.Units.gridUnit * 1.5
                onClicked: settingsFlickable.focusedExpanded = !settingsFlickable.focusedExpanded
                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        source: settingsFlickable.focusedExpanded ? "arrow-down" : "arrow-right"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Controls.Label {
                        text: i18n("Focused window")
                        font.bold: true
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing
                visible: settingsFlickable.focusedExpanded

                RowLayout {
                    Layout.fillWidth: true
                    Controls.Label { text: i18n("Focused window:"); Layout.preferredWidth: Kirigami.Units.gridUnit * 9 }
                    Controls.ComboBox {
                        id: focusedModeCombo
                        Layout.fillWidth: true
                        model: [
                            { value: "hide", text: i18n("Hide overlay") },
                            { value: "background", text: i18n("Background (80%)") },
                            { value: "custom", text: i18n("Custom style\u2026") }
                        ]
                        textRole: "text"; valueRole: "value"
                        Component.onCompleted: currentIndex = indexOfValue(plasmoid.configuration.focusedMode)
                        onActivated: {
                            plasmoid.configuration.focusedMode = currentValue;
                            if (currentValue === "custom" && !plasmoid.configuration.focusedColorMode) {
                                plasmoid.configuration.focusedColorMode = "frame";
                            }
                        }
                    }
                }
                Controls.Label {
                    text: i18n("How the color overlay behaves when a task has focus.")
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Kirigami.Theme.disabledTextColor
                    wrapMode: Text.Wrap; Layout.fillWidth: true
                }

                // -- Custom focused style options --
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.gridUnit
                    spacing: Kirigami.Units.smallSpacing
                    visible: plasmoid.configuration.focusedMode === "custom"

                    RowLayout {
                        Layout.fillWidth: true
                        Controls.Label { text: i18n("Focused style:"); Layout.preferredWidth: Kirigami.Units.gridUnit * 9 }
                        Controls.ItemDelegate {
                            Layout.fillWidth: true
                            padding: Kirigami.Units.smallSpacing
                            Kirigami.Theme.colorSet: Kirigami.Theme.View
                            Kirigami.Theme.inherit: false
                            background: Rectangle {
                                color: Kirigami.Theme.backgroundColor
                                border.color: Kirigami.Theme.separatorColor || Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
                                border.width: 1
                                radius: Kirigami.Units.smallSpacing
                            }
                            contentItem: RowLayout {
                                spacing: Kirigami.Units.smallSpacing
                                Controls.Label {
                                    text: settingsTab.modeLabelFor(plasmoid.configuration.focusedColorMode || "frame")
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Kirigami.Icon {
                                    source: "arrow-down"
                                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                }
                            }
                            onClicked: {
                                settingsTab.currentIndex = 3;
                                focusedModePicker.activate();
                            }
                        }
                    }

                    // -- Focused thickness --
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        visible: plasmoid.configuration.focusedColorMode !== "background"
                              && plasmoid.configuration.focusedColorMode !== ""

                        Controls.Label { text: i18n("Thickness"); font.bold: true }
                        RowLayout {
                            Layout.fillWidth: true
                            Controls.Slider {
                                id: focBorderSlider; Layout.fillWidth: true
                                from: -1; to: settingsTab.computedMaxBorder; stepSize: 1
                                value: plasmoid.configuration.focusedAutoBorderWidth ? -1 : plasmoid.configuration.focusedBorderWidth
                                onMoved: {
                                    if (value < 0) {
                                        plasmoid.configuration.focusedAutoBorderWidth = true;
                                    } else {
                                        plasmoid.configuration.focusedAutoBorderWidth = false;
                                        plasmoid.configuration.focusedBorderWidth = value;
                                    }
                                }
                            }
                            Controls.Label {
                                text: focBorderSlider.value < 0 ? i18n("Auto") : focBorderSlider.value + "px"
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                            }
                        }
                        Controls.Label {
                            text: i18n("Border thickness for focused windows.")
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            color: Kirigami.Theme.disabledTextColor
                            wrapMode: Text.Wrap; Layout.fillWidth: true
                        }
                    }

                    // -- Focused opacity --
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Controls.CheckBox {
                            id: focOpacityCheck
                            text: i18n("Custom opacity")
                            checked: plasmoid.configuration.focusedOpacity >= 0
                            onToggled: {
                                if (!checked) plasmoid.configuration.focusedOpacity = -1;
                                else plasmoid.configuration.focusedOpacity = 0.8;
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            visible: focOpacityCheck.checked
                            Controls.Slider {
                                id: focOpacitySlider; Layout.fillWidth: true
                                from: 0.1; to: 1.0; stepSize: 0.05
                                value: plasmoid.configuration.focusedOpacity >= 0 ? plasmoid.configuration.focusedOpacity : 0.8
                                onMoved: plasmoid.configuration.focusedOpacity = value
                            }
                            Controls.Label {
                                text: Math.round(focOpacitySlider.value * 100) + "%"
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                            }
                        }
                    }

                    // -- Focused corners --
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        visible: ["frame", "background", "background+frame"].indexOf(plasmoid.configuration.focusedColorMode) >= 0

                        Controls.CheckBox {
                            id: focRadiusCheck
                            text: i18n("Custom corners")
                            checked: plasmoid.configuration.focusedBorderRadius >= 0
                            onToggled: {
                                if (!checked) plasmoid.configuration.focusedBorderRadius = -1;
                                else plasmoid.configuration.focusedBorderRadius = 0;
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            visible: focRadiusCheck.checked
                            Controls.Slider {
                                id: focRadiusSlider; Layout.fillWidth: true
                                from: 0; to: settingsTab.computedMaxRadius; stepSize: 1
                                value: plasmoid.configuration.focusedBorderRadius >= 0 ? plasmoid.configuration.focusedBorderRadius : 0
                                onMoved: plasmoid.configuration.focusedBorderRadius = value
                            }
                            Controls.Label {
                                text: focRadiusSlider.value + "px"
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                            }
                        }
                    }
                }
            }

            // ════════════════════════════════════════
            // ── Minimized window section ──
            // ════════════════════════════════════════

            Item { height: Kirigami.Units.smallSpacing; width: 1 }

            Controls.ItemDelegate {
                Layout.fillWidth: true
                verticalPadding: 0; horizontalPadding: 0; topInset: 0; bottomInset: 0
                implicitHeight: Kirigami.Units.gridUnit * 1.5
                onClicked: settingsFlickable.minimizedExpanded = !settingsFlickable.minimizedExpanded
                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        source: settingsFlickable.minimizedExpanded ? "arrow-down" : "arrow-right"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Controls.Label {
                        text: i18n("Minimized window")
                        font.bold: true
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing
                visible: settingsFlickable.minimizedExpanded

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
                        Controls.ItemDelegate {
                            Layout.fillWidth: true
                            contentItem: RowLayout {
                                spacing: Kirigami.Units.smallSpacing
                                Controls.Label {
                                    text: settingsTab.modeLabelFor(plasmoid.configuration.minimizedColorMode || "frame")
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Kirigami.Icon {
                                    source: "go-next"
                                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                }
                            }
                            onClicked: {
                                settingsTab.currentIndex = 2;
                                minimizedModePicker.activate();
                            }
                        }
                    }
                    Controls.Label {
                        text: i18n("Use a different display mode when windows are minimized.")
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        color: Kirigami.Theme.disabledTextColor
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

                    // -- Minimized thickness --
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        visible: plasmoid.configuration.minimizedColorMode !== "background"
                              && plasmoid.configuration.minimizedColorMode !== ""

                        Controls.Label { text: i18n("Thickness"); font.bold: true }
                        RowLayout {
                            Layout.fillWidth: true
                            Controls.Slider {
                                id: minBorderSlider; Layout.fillWidth: true
                                from: -1; to: settingsTab.computedMaxBorder; stepSize: 1
                                value: plasmoid.configuration.minimizedAutoBorderWidth ? -1 : plasmoid.configuration.minimizedBorderWidth
                                onMoved: {
                                    if (value < 0) {
                                        plasmoid.configuration.minimizedAutoBorderWidth = true;
                                    } else {
                                        plasmoid.configuration.minimizedAutoBorderWidth = false;
                                        plasmoid.configuration.minimizedBorderWidth = value;
                                    }
                                }
                            }
                            Controls.Label {
                                text: minBorderSlider.value < 0 ? i18n("Auto") : minBorderSlider.value + "px"
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                            }
                        }
                        Controls.Label {
                            text: i18n("Border thickness for minimized windows.")
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            color: Kirigami.Theme.disabledTextColor
                            wrapMode: Text.Wrap; Layout.fillWidth: true
                        }
                    }

                    // -- Minimized opacity --
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Controls.CheckBox {
                            id: minOpacityCheck
                            text: i18n("Custom opacity")
                            checked: plasmoid.configuration.minimizedOpacity >= 0
                            onToggled: {
                                if (!checked) plasmoid.configuration.minimizedOpacity = -1;
                                else plasmoid.configuration.minimizedOpacity = plasmoid.configuration.backgroundOpacity;
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            visible: minOpacityCheck.checked
                            Controls.Slider {
                                id: minOpacitySlider; Layout.fillWidth: true
                                from: 0.1; to: 1.0; stepSize: 0.05
                                value: plasmoid.configuration.minimizedOpacity >= 0 ? plasmoid.configuration.minimizedOpacity : plasmoid.configuration.backgroundOpacity
                                onMoved: plasmoid.configuration.minimizedOpacity = value
                            }
                            Controls.Label {
                                text: Math.round(minOpacitySlider.value * 100) + "%"
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                            }
                        }
                    }

                    // -- Minimized corners --
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        visible: ["frame", "background", "background+frame"].indexOf(plasmoid.configuration.minimizedColorMode) >= 0

                        Controls.CheckBox {
                            id: minRadiusCheck
                            text: i18n("Custom corners")
                            checked: plasmoid.configuration.minimizedBorderRadius >= 0
                            onToggled: {
                                if (!checked) plasmoid.configuration.minimizedBorderRadius = -1;
                                else plasmoid.configuration.minimizedBorderRadius = 0;
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            visible: minRadiusCheck.checked
                            Controls.Slider {
                                id: minRadiusSlider; Layout.fillWidth: true
                                from: 0; to: settingsTab.computedMaxRadius; stepSize: 1
                                value: plasmoid.configuration.minimizedBorderRadius >= 0 ? plasmoid.configuration.minimizedBorderRadius : 0
                                onMoved: plasmoid.configuration.minimizedBorderRadius = value
                            }
                            Controls.Label {
                                text: minRadiusSlider.value + "px"
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                            }
                        }
                    }
                }
            }

            // ════════════════════════════════════════
            // ── Behavior section ──
            // ════════════════════════════════════════

            Item { height: Kirigami.Units.smallSpacing; width: 1 }

            Controls.ItemDelegate {
                Layout.fillWidth: true
                verticalPadding: 0; horizontalPadding: 0; topInset: 0; bottomInset: 0
                implicitHeight: Kirigami.Units.gridUnit * 1.5
                onClicked: settingsFlickable.behaviorExpanded = !settingsFlickable.behaviorExpanded
                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        source: settingsFlickable.behaviorExpanded ? "arrow-down" : "arrow-right"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Controls.Label {
                        text: i18n("Behavior")
                        font.bold: true
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing
                visible: settingsFlickable.behaviorExpanded

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
            }

            // ════════════════════════════════════════
            // ── Widget section ──
            // ════════════════════════════════════════

            Item { height: Kirigami.Units.smallSpacing; width: 1 }

            Controls.ItemDelegate {
                Layout.fillWidth: true
                verticalPadding: 0; horizontalPadding: 0; topInset: 0; bottomInset: 0
                implicitHeight: Kirigami.Units.gridUnit * 1.5
                onClicked: settingsFlickable.widgetExpanded = !settingsFlickable.widgetExpanded
                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        source: settingsFlickable.widgetExpanded ? "arrow-down" : "arrow-right"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Controls.Label {
                        text: i18n("Widget")
                        font.bold: true
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing
                visible: settingsFlickable.widgetExpanded

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

    // ════════════════════════════════════════
    // ── Page 1: Normal color mode picker ──
    // ════════════════════════════════════════

    Components.ModePicker {
        id: normalModePicker
        title: i18n("Select mode")
        activeMode: plasmoid.configuration.colorMode

        onModeSelected: function(value) {
            plasmoid.configuration.colorMode = value;
            settingsTab.currentIndex = 0;
        }
        onBackRequested: settingsTab.currentIndex = 0
    }

    // ════════════════════════════════════════
    // ── Page 2: Minimized color mode picker ──
    // ════════════════════════════════════════

    Components.ModePicker {
        id: minimizedModePicker
        title: i18n("Minimized style")
        activeMode: plasmoid.configuration.minimizedColorMode || "frame"
        disabledMode: ""

        onModeSelected: function(value) {
            plasmoid.configuration.minimizedColorMode = value;
            settingsTab.currentIndex = 0;
        }
        onBackRequested: settingsTab.currentIndex = 0
    }

    // ════════════════════════════════════════
    // ── Page 3: Focused color mode picker ──
    // ════════════════════════════════════════

    Components.ModePicker {
        id: focusedModePicker
        title: i18n("Focused style")
        activeMode: plasmoid.configuration.focusedColorMode || "frame"
        disabledMode: ""

        onModeSelected: function(value) {
            plasmoid.configuration.focusedColorMode = value;
            settingsTab.currentIndex = 0;
        }
        onBackRequested: settingsTab.currentIndex = 0
    }
}
