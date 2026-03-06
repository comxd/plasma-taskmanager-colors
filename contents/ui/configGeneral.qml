/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_isEnabled: enabledCheck.checked
    property alias cfg_colorMode: modeCombo.currentValue
    property bool cfg_autoBorderWidth
    property int cfg_borderWidth
    property alias cfg_backgroundOpacity: opacitySlider.value
    property int cfg_borderRadius
    property alias cfg_showOnFocus: focusCheck.checked
    property alias cfg_pinnedBehavior: pinnedCombo.currentValue
    property string cfg_appColorMap

    Controls.CheckBox {
        id: enabledCheck
        Kirigami.FormData.label: i18n("General:")
        text: i18n("Enable color overlays")
    }

    Controls.ComboBox {
        id: modeCombo
        Kirigami.FormData.label: i18n("Color mode:")
        model: [
            { value: "frame", text: i18n("Frame (all sides)") },
            { value: "top", text: i18n("Top line") },
            { value: "bottom", text: i18n("Bottom line") },
            { value: "left", text: i18n("Left line") },
            { value: "right", text: i18n("Right line") },
            { value: "top+bottom", text: i18n("Top + Bottom") },
            { value: "left+right", text: i18n("Left + Right") },
            { value: "center", text: i18n("Center │") },
            { value: "center-h", text: i18n("Center ─") },
            { value: "background", text: i18n("Background") },
            { value: "background+frame", text: i18n("Background + Frame") },
            { value: "diagonal", text: i18n("Diagonal \\") },
            { value: "diagonal-reverse", text: i18n("Diagonal /") },
            { value: "diagonal-cross", text: i18n("Diagonal ✕") }
        ]
        textRole: "text"
        valueRole: "value"
        Component.onCompleted: currentIndex = indexOfValue(cfg_colorMode)
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Thickness:")
        visible: cfg_colorMode !== "background"

        Controls.Slider {
            id: borderSlider
            from: -1
            to: 48  // Max fallback; actual value clamped to task delegate size at runtime
            stepSize: 1
            value: cfg_autoBorderWidth ? -1 : cfg_borderWidth
            onMoved: {
                if (value < 0) {
                    cfg_autoBorderWidth = true;
                } else {
                    cfg_autoBorderWidth = false;
                    cfg_borderWidth = value;
                }
            }
            Layout.fillWidth: true
        }

        Controls.Label {
            text: borderSlider.value < 0 ? i18n("Auto") : borderSlider.value + "px"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Corner radius:")
        visible: ["frame", "background", "background+frame"].indexOf(cfg_colorMode) >= 0

        Controls.Slider {
            id: radiusSlider
            from: -1
            to: 48  // Max fallback; actual value clamped to task delegate size at runtime
            stepSize: 1
            value: cfg_borderRadius
            onMoved: cfg_borderRadius = value
            Layout.fillWidth: true
        }

        Controls.Label {
            text: radiusSlider.value < 0 ? i18n("Auto") : radiusSlider.value + "px"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Opacity:")

        Controls.Slider {
            id: opacitySlider
            from: 0.1
            to: 1.0
            stepSize: 0.05
            Layout.fillWidth: true
        }

        Controls.Label {
            text: Math.round(opacitySlider.value * 100) + "%"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
        }
    }

    Controls.ComboBox {
        id: pinnedCombo
        Kirigami.FormData.label: i18n("Pinned apps:")
        model: [
            { value: "always", text: i18n("Always colored") },
            { value: "runningOnly", text: i18n("Only when running") }
        ]
        textRole: "text"
        valueRole: "value"
        Component.onCompleted: currentIndex = indexOfValue(cfg_pinnedBehavior)
    }

    Controls.CheckBox {
        id: focusCheck
        Kirigami.FormData.label: i18n("Focus:")
        text: i18n("Keep color visible on focused task")
    }

    Item { Kirigami.FormData.isSection: true }

    Controls.Label {
        Kirigami.FormData.label: i18n("Colors:")
        text: {
            try {
                let map = JSON.parse(cfg_appColorMap);
                let count = Object.keys(map).length;
                return i18n("%1 application(s) configured", count);
            } catch (e) {
                return i18n("No colors configured");
            }
        }
    }

    Controls.Button {
        id: resetButton
        property bool armed: false
        text: armed ? i18n("Click again to confirm") : i18n("Reset all colors")
        icon.name: armed ? "dialog-warning" : "edit-clear-all"
        onClicked: {
            if (armed) {
                cfg_appColorMap = "{}";
                armed = false;
            } else {
                armed = true;
                resetDisarmTimer.restart();
            }
        }
        Timer {
            id: resetDisarmTimer
            interval: 3000
            onTriggered: resetButton.armed = false
        }
    }
}
