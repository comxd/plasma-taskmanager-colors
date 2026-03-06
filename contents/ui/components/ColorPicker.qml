/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Inline color picker: 30 presets + used colors reuse + hex input + auto from icon.
    Used by both ApplicationsTab and WindowsTab (with different signal wiring).
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Rectangle {
    id: colorPicker

    // Data from parent
    required property var usedColors       // root.usedColors array
    required property bool extractorBusy   // iconExtractor.busy

    // Title displayed in header
    property string title: i18n("Pick a color")

    // Signals for parent to handle
    signal colorSelected(string color)
    signal autoFromIconRequested()
    signal closeRequested()

    readonly property int swatchSize: 22
    readonly property var presetColors: [
        "#e74c3c", "#e67e22", "#f1c40f", "#2ecc71", "#1abc9c",
        "#3498db", "#9b59b6", "#e91e63", "#795548", "#607d8b",
        "#c0392b", "#d35400", "#f39c12", "#27ae60", "#16a085",
        "#2980b9", "#8e44ad", "#c2185b", "#5d4037", "#455a64",
        "#ff6b6b", "#ffa726", "#ffee58", "#66bb6a", "#26c6da",
        "#42a5f5", "#ab47bc", "#ec407a", "#8d6e63", "#78909c"
    ]

    height: pickerColumn.implicitHeight + Kirigami.Units.smallSpacing * 2
    color: Kirigami.Theme.backgroundColor
    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
    border.width: 1
    radius: 4

    ColumnLayout {
        id: pickerColumn
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true
            Controls.Label {
                text: colorPicker.title
                font.bold: true
                Layout.fillWidth: true
            }
            Controls.Button {
                icon.name: "dialog-close"
                implicitWidth: Kirigami.Units.gridUnit * 1.5
                implicitHeight: Kirigami.Units.gridUnit * 1.5
                flat: true
                onClicked: colorPicker.closeRequested()
                Controls.ToolTip.text: i18n("Cancel")
                Controls.ToolTip.visible: hovered
            }
        }

        // Used colors (from other apps)
        Flow {
            Layout.fillWidth: true
            spacing: 3
            visible: colorPicker.usedColors.length > 0

            Controls.Label {
                text: i18n("Used:")
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: Kirigami.Theme.disabledTextColor
                height: colorPicker.swatchSize
                verticalAlignment: Text.AlignVCenter
            }

            Repeater {
                model: colorPicker.usedColors
                delegate: Controls.AbstractButton {
                    required property var modelData
                    width: colorPicker.swatchSize; height: colorPicker.swatchSize
                    Accessible.name: modelData.appName || modelData.color
                    Controls.ToolTip.text: modelData.appName
                    Controls.ToolTip.visible: hovered

                    background: Rectangle {
                        radius: 3
                        color: parent.modelData.color
                        border.color: Qt.darker(parent.modelData.color, 1.3)
                        border.width: parent.activeFocus ? 2 : 1
                    }

                    onClicked: colorPicker.colorSelected(modelData.color)
                }
            }
        }

        // Auto color from icon
        Controls.Button {
            Layout.fillWidth: true
            icon.name: "color-management"
            text: colorPicker.extractorBusy ? i18n("Extracting\u2026") : i18n("Auto (from icon)")
            enabled: !colorPicker.extractorBusy
            onClicked: colorPicker.autoFromIconRequested()
        }

        // Preset colors
        Grid {
            columns: 10
            spacing: 3
            Layout.alignment: Qt.AlignHCenter

            Repeater {
                model: colorPicker.presetColors

                delegate: Controls.AbstractButton {
                    required property string modelData
                    width: colorPicker.swatchSize; height: colorPicker.swatchSize
                    Accessible.name: modelData

                    background: Rectangle {
                        radius: 3
                        color: parent.modelData
                        border.color: Qt.darker(parent.modelData, 1.3)
                        border.width: parent.activeFocus ? 2 : 1
                    }

                    onClicked: colorPicker.colorSelected(modelData)
                }
            }
        }

        // Hex input with validation feedback
        RowLayout {
            Layout.fillWidth: true
            Controls.Label { text: "#" }
            Controls.TextField {
                id: hexInput
                Layout.fillWidth: true
                placeholderText: "ff0000"
                maximumLength: 6
                inputMethodHints: Qt.ImhNoPredictiveText
                property bool isValid: text.length === 0 || /^[0-9a-fA-F]{6}$/.test(text.trim())
                palette.base: isValid ? Kirigami.Theme.backgroundColor : Qt.rgba(1, 0, 0, 0.15)
                onAccepted: {
                    let color = "#" + text.trim();
                    if (/^#[0-9a-fA-F]{6}$/.test(color)) {
                        colorPicker.colorSelected(color);
                        text = "";
                    }
                }
            }
            Controls.Button {
                text: i18n("OK")
                enabled: hexInput.isValid && hexInput.text.length === 6
                onClicked: hexInput.accepted()
            }
            Controls.Button {
                text: i18n("Cancel")
                onClicked: colorPicker.closeRequested()
            }
        }
    }
}
