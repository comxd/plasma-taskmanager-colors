/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Applications tab: app list + color picker + nyan toggle.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import "../components" as Components

Item {
    id: applicationsTab

    // Data from root
    required property var detectedTasks    // root.detectedTasks
    required property var colorMapCache    // root.colorMapCache
    required property var usedColors       // root.usedColors
    required property bool extractorBusy   // iconExtractor.busy

    // Signals for root to handle
    signal setAppColor(string appId, string color)
    signal removeAppColor(string appId)
    signal toggleNyan(string appId, bool enable)
    signal extractColorFromIcon(string appId, var iconName)

    // Connected by root to close picker on extraction complete
    signal extractionComplete()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.mediumSpacing
        spacing: Kirigami.Units.smallSpacing

        Controls.Label {
            text: applicationsTab.detectedTasks.length > 0
                ? i18n("Assign a persistent color to each application. The color applies to all windows of that application.")
                : i18n("No tasks detected \u2014 open some windows to assign colors.")
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        Item { height: Kirigami.Units.smallSpacing; width: 1 }
        Kirigami.Separator { Layout.fillWidth: true }
        Item { height: Kirigami.Units.smallSpacing; width: 1 }

        ListView {
            id: taskListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Kirigami.Units.smallSpacing

            model: applicationsTab.detectedTasks

            delegate: RowLayout {
                required property var modelData
                width: taskListView.width
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: modelData.iconName || modelData.appId
                    implicitWidth: Kirigami.Units.iconSizes.small
                    implicitHeight: Kirigami.Units.iconSizes.small
                }

                Controls.Label {
                    text: modelData.appName || modelData.appId
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Controls.Label {
                    text: i18n("(pinned)")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    visible: !modelData.isRunning
                }

                Controls.Button {
                    implicitWidth: Kirigami.Units.gridUnit * 2.5
                    implicitHeight: Kirigami.Units.gridUnit * 1.5

                    property string appId: modelData.appId
                    property string rawColor: applicationsTab.colorMapCache[appId] || ""
                    property string assignedColor: rawColor.replace(/:nyan$/, "")
                    property bool isNyan: rawColor.endsWith(":nyan")

                    visible: !isNyan

                    contentItem: Item {}
                    background: Rectangle {
                        color: parent.assignedColor
                            ? parent.assignedColor
                            : Kirigami.Theme.backgroundColor
                        radius: 3
                        border.color: Kirigami.Theme.textColor
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: parent.parent.assignedColor ? "" : "+"
                            color: Kirigami.Theme.textColor
                            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        }
                    }

                    onClicked: {
                        inlineColorPicker.targetAppId = appId;
                        inlineColorPicker.targetIconName = modelData.iconName || appId;
                        inlineColorPicker.title = i18n("Color for: %1", appId);
                        inlineColorPicker.visible = true;
                    }
                }

                // Nyan Cat toggle (always visible — can be used without a color)
                Controls.Switch {
                    implicitWidth: Kirigami.Units.gridUnit * 2
                    implicitHeight: Kirigami.Units.gridUnit * 1.5
                    checked: {
                        let raw = applicationsTab.colorMapCache[modelData.appId] || "";
                        return raw.endsWith(":nyan");
                    }
                    onToggled: {
                        applicationsTab.toggleNyan(modelData.appId, checked);
                        if (checked && inlineColorPicker.targetAppId === modelData.appId) {
                            inlineColorPicker.visible = false;
                        }
                    }
                    Controls.ToolTip.text: i18n("Nyan Cat rainbow effect")
                    Controls.ToolTip.visible: hovered
                }

                Controls.Button {
                    icon.name: "edit-clear"
                    implicitWidth: Kirigami.Units.gridUnit * 1.5
                    implicitHeight: Kirigami.Units.gridUnit * 1.5
                    visible: modelData.appId in applicationsTab.colorMapCache
                    onClicked: applicationsTab.removeAppColor(modelData.appId)

                    Controls.ToolTip.text: i18n("Remove color")
                    Controls.ToolTip.visible: hovered
                }
            }
        }

        // Inline color picker
        Components.ColorPicker {
            id: inlineColorPicker
            Layout.fillWidth: true
            visible: false
            usedColors: applicationsTab.usedColors
            extractorBusy: applicationsTab.extractorBusy

            property string targetAppId: ""
            property var targetIconName: ""

            onColorSelected: function(color) {
                applicationsTab.setAppColor(targetAppId, color);
                visible = false;
            }
            onAutoFromIconRequested: applicationsTab.extractColorFromIcon(targetAppId, targetIconName)
            onCloseRequested: visible = false
        }

        Connections {
            target: applicationsTab
            function onExtractionComplete() { inlineColorPicker.visible = false; }
        }
    }
}
