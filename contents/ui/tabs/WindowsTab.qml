/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Windows tab: per-window color overrides + nyan toggle.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import "../components" as Components

Item {
    id: windowsTab

    // Data from root
    required property var detectedWindows  // root.detectedWindows
    required property var usedColors       // root.usedColors
    required property bool extractorBusy   // iconExtractor.busy
    required property var activeOverlays   // root.activeOverlays

    // Signals for root to handle
    signal extractColorForWindow(var overlay, var iconName)
    signal nyanOverlaysChanged()

    // Connected by root to close picker on extraction complete
    signal extractionComplete()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.mediumSpacing
        spacing: Kirigami.Units.smallSpacing

        Controls.Label {
            text: windowsTab.detectedWindows.length > 0
                ? i18n("Temporarily override the color of a specific window. Overrides are lost when the window is closed.")
                : i18n("No windows detected \u2014 open some windows to use per-window overrides.")
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        Item { height: Kirigami.Units.smallSpacing; width: 1 }
        Kirigami.Separator { Layout.fillWidth: true }
        Item { height: Kirigami.Units.smallSpacing; width: 1 }

        ListView {
            id: windowListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Kirigami.Units.smallSpacing

            model: windowsTab.detectedWindows

            delegate: RowLayout {
                required property var modelData
                required property int index
                width: windowListView.width
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: modelData.iconName || modelData.appId
                    implicitWidth: Kirigami.Units.iconSizes.small
                    implicitHeight: Kirigami.Units.iconSizes.small
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Controls.Label {
                        text: modelData.windowTitle || modelData.appName
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Controls.Label {
                        text: modelData.appName
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        color: Kirigami.Theme.disabledTextColor
                        visible: (modelData.windowTitle || "") !== "" && modelData.windowTitle !== modelData.appName
                    }
                }

                Controls.Button {
                    implicitWidth: Kirigami.Units.gridUnit * 2.5
                    implicitHeight: Kirigami.Units.gridUnit * 1.5

                    property string rawOverride: modelData.overlay?.windowColorOverride ?? ""
                    property string currentOverride: rawOverride.replace(/:nyan$/, "")
                    property bool winNyan: rawOverride.endsWith(":nyan")

                    visible: !!modelData.overlay && !winNyan
                    enabled: !!modelData.overlay

                    contentItem: Item {}
                    background: Rectangle {
                        color: parent.currentOverride
                            ? parent.currentOverride
                            : Qt.rgba(Kirigami.Theme.backgroundColor.r,
                                       Kirigami.Theme.backgroundColor.g,
                                       Kirigami.Theme.backgroundColor.b, 0.5)
                        radius: 3
                        border.color: Kirigami.Theme.textColor
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: parent.parent.currentOverride ? "" : "+"
                            color: Kirigami.Theme.textColor
                            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        }
                    }

                    onClicked: {
                        windowColorPicker.targetOverlay = modelData.overlay;
                        windowColorPicker.targetIconName = modelData.iconName || modelData.appId;
                        windowColorPicker.title = i18n("Window color override");
                        windowColorPicker.visible = true;
                    }
                }

                Controls.Switch {
                    implicitWidth: Kirigami.Units.gridUnit * 2
                    implicitHeight: Kirigami.Units.gridUnit * 1.5
                    visible: !!modelData.overlay
                    checked: (modelData.overlay?.windowColorOverride ?? "").endsWith(":nyan")
                    onToggled: {
                        if (!modelData.overlay) return;
                        let raw = modelData.overlay.windowColorOverride || "";
                        let base = raw.replace(/:nyan$/, "");
                        if (checked) {
                            modelData.overlay.windowColorOverride = (base || "") + ":nyan";
                        } else {
                            modelData.overlay.windowColorOverride = base;
                        }
                        if (checked && windowColorPicker.targetOverlay === modelData.overlay) {
                            windowColorPicker.visible = false;
                        }
                        windowsTab.nyanOverlaysChanged();
                    }
                    Controls.ToolTip.text: i18n("Nyan Cat rainbow effect")
                    Controls.ToolTip.visible: hovered
                }

                Controls.Button {
                    icon.name: "edit-clear"
                    implicitWidth: Kirigami.Units.gridUnit * 1.5
                    implicitHeight: Kirigami.Units.gridUnit * 1.5
                    visible: (modelData.overlay?.windowColorOverride ?? "") !== ""
                    flat: true
                    onClicked: {
                        if (modelData.overlay) {
                            modelData.overlay.windowColorOverride = "";
                            windowsTab.nyanOverlaysChanged();
                        }
                    }

                    Controls.ToolTip.text: i18n("Reset to app color")
                    Controls.ToolTip.visible: hovered
                }
            }
        }

        // Inline window color picker
        Components.ColorPicker {
            id: windowColorPicker
            Layout.fillWidth: true
            visible: false
            usedColors: windowsTab.usedColors
            extractorBusy: windowsTab.extractorBusy

            color: Qt.rgba(
                Kirigami.Theme.backgroundColor.r,
                Kirigami.Theme.backgroundColor.g,
                Kirigami.Theme.backgroundColor.b,
                0.6
            )
            border.color: Kirigami.Theme.highlightColor

            property var targetOverlay: null
            property var targetIconName: ""

            onColorSelected: function(color) {
                if (targetOverlay) {
                    let hadNyan = targetOverlay.windowColorOverride.endsWith(":nyan");
                    targetOverlay.windowColorOverride = color + (hadNyan ? ":nyan" : "");
                }
                visible = false;
            }
            onAutoFromIconRequested: {
                if (targetOverlay) {
                    windowsTab.extractColorForWindow(targetOverlay, targetIconName);
                }
            }
            onCloseRequested: visible = false
        }

        Connections {
            target: windowsTab
            function onExtractionComplete() { windowColorPicker.visible = false; }
        }
    }
}
