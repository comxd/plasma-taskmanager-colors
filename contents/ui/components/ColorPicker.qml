/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Full-page color picker: 40 presets + used colors reuse + hex input + auto from icon.
    Designed as a StackLayout page (like ModePicker).
    Used by both ApplicationsTab and WindowsTab (with different signal wiring).
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents3

ColumnLayout {
    id: colorPicker
    spacing: 0

    // Data from parent
    required property var usedColors       // root.usedColors array
    required property bool extractorBusy   // iconExtractor.busy

    // Title displayed in header
    property string title: i18n("Pick a color")

    // Nyan state
    property bool isNyan: false

    // Signals for parent to handle
    signal colorSelected(string color)
    signal autoFromIconRequested()
    signal nyanToggled(bool enabled)
    signal backRequested()

    readonly property int swatchSize: 22
    readonly property var presetColors: [
        "#e74c3c", "#e67e22", "#f1c40f", "#2ecc71", "#1abc9c",
        "#3498db", "#9b59b6", "#e91e63", "#795548", "#607d8b",
        "#c0392b", "#d35400", "#f39c12", "#27ae60", "#16a085",
        "#2980b9", "#8e44ad", "#c2185b", "#5d4037", "#455a64",
        "#ff6b6b", "#ffa726", "#ffee58", "#66bb6a", "#26c6da",
        "#42a5f5", "#ab47bc", "#ec407a", "#8d6e63", "#78909c",
        "#FFFFFF", "#BDBDBD", "#757575", "#424242", "#212121",
        "#00BCD4", "#FF00FF", "#CDDC39", "#3F51B5", "#FF5722"
    ]

    function swatchBorder(c) {
        let darker = Qt.darker(c, 1.3);
        let lum = 0.299 * darker.r + 0.587 * darker.g + 0.114 * darker.b;
        return lum > 0.85 ? "#999999" : darker;
    }

    function activate() {
        hexInput.text = "";
    }

    // ── Header with back button ──

    PlasmaExtras.PlasmoidHeading {
        Layout.fillWidth: true

        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Button {
                icon.name: mirrored ? "go-next" : "go-previous"
                text: i18n("Back")
                onClicked: colorPicker.backRequested()
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: colorPicker.title
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                elide: Text.ElideRight
            }

            // Spacer to balance the back button
            Item {
                implicitWidth: Kirigami.Units.gridUnit * 4
            }
        }
    }

    // ── Picker content ──

    Flickable {
        id: pickerFlickable
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: width
        contentHeight: pickerColumn.implicitHeight + pickerColumn.y + Kirigami.Units.largeSpacing * 2
        clip: true
        flickableDirection: Flickable.VerticalFlick
        Controls.ScrollBar.vertical: Controls.ScrollBar { id: pickerScrollBar; policy: Controls.ScrollBar.AsNeeded }

        ColumnLayout {
            id: pickerColumn
            x: Kirigami.Units.largeSpacing * 2
            y: Kirigami.Units.largeSpacing * 2
            width: parent.width - x - (pickerScrollBar.visible ? pickerScrollBar.width + Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing * 2)
            spacing: Kirigami.Units.smallSpacing

            // Used colors (from other apps)
            Flow {
                Layout.fillWidth: true
                spacing: 3
                visible: colorPicker.usedColors.length > 0
                enabled: !colorPicker.isNyan
                opacity: colorPicker.isNyan ? 0.4 : 1.0

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

                        property string tooltipText: {
                            let joined = (modelData.appNames || []).join(", ");
                            return joined.length > 80 ? joined.substring(0, 77) + "\u2026" : joined;
                        }

                        Accessible.name: tooltipText || modelData.color
                        Controls.ToolTip.text: tooltipText
                        Controls.ToolTip.visible: hovered

                        background: Rectangle {
                            radius: 3
                            color: parent.modelData.color
                            border.color: colorPicker.swatchBorder(parent.modelData.color)
                            border.width: parent.activeFocus ? 2 : 1

                            // Count badge when multiple apps share this color
                            Rectangle {
                                visible: parent.parent.modelData.count > 1
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.bottomMargin: -3
                                anchors.rightMargin: -3
                                property int badgeSize: Math.max(badgeLabel.implicitWidth, badgeLabel.implicitHeight) + 6
                                width: badgeSize
                                height: badgeSize
                                radius: badgeSize / 2
                                color: Qt.rgba(0, 0, 0, 0.6)

                                Text {
                                    id: badgeLabel
                                    anchors.centerIn: parent
                                    text: parent.parent.parent.modelData.count
                                    color: "#ffffff"
                                    font.pixelSize: 8
                                    font.bold: true
                                }
                            }
                        }

                        onClicked: colorPicker.colorSelected(modelData.color)
                    }
                }
            }

            Item { height: Kirigami.Units.largeSpacing * 2; width: 1 }
            Kirigami.Separator { Layout.fillWidth: true; opacity: 0.3 }
            Item { height: Kirigami.Units.largeSpacing; width: 1 }

            // Preset colors
            Grid {
                columns: 10
                spacing: 3
                Layout.alignment: Qt.AlignHCenter
                enabled: !colorPicker.isNyan
                opacity: colorPicker.isNyan ? 0.4 : 1.0

                Repeater {
                    model: colorPicker.presetColors

                    delegate: Controls.AbstractButton {
                        required property string modelData
                        width: colorPicker.swatchSize; height: colorPicker.swatchSize
                        Accessible.name: modelData

                        background: Rectangle {
                            radius: 3
                            color: parent.modelData
                            border.color: colorPicker.swatchBorder(parent.modelData)
                            border.width: parent.activeFocus ? 2 : 1
                        }

                        onClicked: colorPicker.colorSelected(modelData)
                    }
                }
            }

            Item { height: Kirigami.Units.largeSpacing; width: 1 }

            // Auto color from icon
            Controls.Button {
                Layout.fillWidth: true
                icon.name: "color-management"
                text: colorPicker.extractorBusy ? i18n("Extracting\u2026") : i18n("Auto (from icon)")
                enabled: !colorPicker.extractorBusy && !colorPicker.isNyan
                onClicked: colorPicker.autoFromIconRequested()
            }

            // Nyan Cat rainbow toggle
            Controls.Button {
                id: nyanButton
                Layout.fillWidth: true
                text: colorPicker.isNyan ? i18n("Nyan Cat (active)") : i18n("Nyan Cat")
                icon.name: colorPicker.isNyan ? "starred" : "non-starred"
                checkable: true
                checked: colorPicker.isNyan
                highlighted: colorPicker.isNyan
                onToggled: {
                    colorPicker.isNyan = checked;
                    colorPicker.nyanToggled(checked);
                }
            }

            Item { height: Kirigami.Units.largeSpacing; width: 1 }

            // Hex input with validation feedback
            RowLayout {
                Layout.fillWidth: true
                enabled: !colorPicker.isNyan
                opacity: colorPicker.isNyan ? 0.4 : 1.0
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
            }
        }
    }
}
