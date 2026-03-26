/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Applications tab: app list + full-page color picker + nyan toggle.
    Uses StackLayout for color picker page navigation.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import "../components" as Components

StackLayout {
    id: applicationsTab

    // Data from root
    required property var detectedTasks    // root.detectedTasks
    required property var colorMapCache    // root.colorMapCache
    required property var usedColors       // root.usedColors
    required property bool extractorBusy   // iconExtractor.busy
    required property bool autoColorEnabled   // plasmoid.configuration.autoColorEnabled
    required property var autoColorCache      // autoColorManager.autoColorCache
    required property var autoSkippedApps      // root.parsedSkipList (pre-parsed array)

    // Signals for root to handle
    signal setAppColor(string appId, string color)
    signal removeAppColor(string appId)
    signal toggleNyan(string appId, bool enable)
    signal extractColorFromIcon(string appId, var iconName)
    signal resetAllColors()
    signal toggleAutoSkip(string appId, bool skip)

    // Connected by root to close picker on extraction complete
    signal extractionComplete()

    currentIndex: 0

    // ════════════════════════════════════════
    // ── Page 0: App list ──
    // ════════════════════════════════════════

    Item {
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing * 2
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

            ListView {
                id: taskListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                clip: true
                spacing: 0
                Controls.ScrollBar.vertical: Controls.ScrollBar { id: appScrollBar; policy: Controls.ScrollBar.AsNeeded }

                model: applicationsTab.detectedTasks

                delegate: ColumnLayout {
                    required property var modelData
                    required property int index
                    width: taskListView.width - (appScrollBar.visible ? appScrollBar.width + Kirigami.Units.smallSpacing : 0)
                    spacing: 0

                    // Auto color computed properties
                    property bool isSkipped: applicationsTab.autoSkippedApps.indexOf(modelData.appId) >= 0
                    property string autoColor: (applicationsTab.autoColorCache[modelData.appId]) || ""
                    property string rawColor: applicationsTab.colorMapCache[modelData.appId] || ""
                    property bool isAutoActive: applicationsTab.autoColorEnabled && autoColor !== "" && rawColor === "" && !isSkipped
                    property bool isAutoPending: applicationsTab.autoColorEnabled && autoColor === "" && rawColor === "" && !isSkipped
                    property bool isAutoOverridden: applicationsTab.autoColorEnabled && rawColor !== ""

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: Kirigami.Units.mediumSpacing
                        Layout.bottomMargin: Kirigami.Units.mediumSpacing
                        spacing: Kirigami.Units.mediumSpacing

                        Kirigami.Icon {
                            source: modelData.iconName || modelData.appId
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Controls.Label {
                                text: modelData.appName || modelData.appId
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Controls.Label {
                                text: modelData.appId
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                color: Kirigami.Theme.disabledTextColor
                                visible: modelData.appId !== (modelData.appName || modelData.appId)
                            }
                        }

                        Controls.Label {
                            text: i18n("(pinned)")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            visible: !modelData.isRunning
                        }

                        Controls.Button {
                            flat: true
                            visible: applicationsTab.autoColorEnabled
                            implicitWidth: autoLabel.implicitWidth + Kirigami.Units.smallSpacing * 4
                            implicitHeight: Kirigami.Units.gridUnit * 1.5
                            enabled: isAutoActive || isSkipped
                            onClicked: applicationsTab.toggleAutoSkip(modelData.appId, !isSkipped)

                            Controls.ToolTip.text: {
                                if (isSkipped) return i18n("Auto color disabled for this app — click to re-enable");
                                if (isAutoActive) return i18n("Color auto-extracted from icon — click to disable");
                                if (isAutoPending) return i18n("Extracting color from icon…");
                                if (isAutoOverridden) return i18n("Auto color overridden by manual color");
                                return "";
                            }
                            Controls.ToolTip.visible: hovered && Controls.ToolTip.text !== ""

                            contentItem: Controls.Label {
                                id: autoLabel
                                text: i18n("auto")
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                font.strikeout: isSkipped || isAutoOverridden
                                font.italic: isAutoPending
                                color: {
                                    if (isAutoActive) return Kirigami.Theme.positiveTextColor;
                                    return Kirigami.Theme.disabledTextColor;
                                }
                                opacity: isSkipped ? 0.5 : 1.0
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Controls.Button {
                            implicitWidth: Kirigami.Units.gridUnit * 2.5
                            implicitHeight: Kirigami.Units.gridUnit * 1.5

                            property string appId: modelData.appId
                            property string rawColor: applicationsTab.colorMapCache[appId] || ""
                            property string assignedColor: rawColor.replace(/:nyan$/, "")
                            property bool isNyan: rawColor.endsWith(":nyan")

                            contentItem: Item {}
                            background: Rectangle {
                                color: parent.assignedColor ? parent.assignedColor
                                     : (autoColor && applicationsTab.autoColorEnabled) ? autoColor
                                     : Kirigami.Theme.backgroundColor
                                radius: 3
                                border.color: Kirigami.Theme.textColor
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: {
                                        if (parent.parent.assignedColor) return "";
                                        if (autoColor && applicationsTab.autoColorEnabled) return "";
                                        if (parent.parent.isNyan) return i18n("nyan");
                                        return "+";
                                    }
                                    color: Kirigami.Theme.textColor
                                    font.pixelSize: (parent.parent.isNyan && !parent.parent.assignedColor) ? Kirigami.Theme.smallFont.pixelSize : Kirigami.Theme.defaultFont.pixelSize
                                }
                            }

                            onClicked: {
                                appColorPicker.targetAppId = appId;
                                appColorPicker.targetIconName = modelData.iconName || appId;
                                appColorPicker.title = i18n("Color for: %1", appId);
                                appColorPicker.isNyan = isNyan;
                                applicationsTab.currentIndex = 1;
                                appColorPicker.activate();
                            }
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

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        opacity: 0.3
                        visible: index < applicationsTab.detectedTasks.length - 1
                    }
                }
            }

            // Reset all colors (two-click confirmation)
            Controls.Button {
                id: resetButton
                property bool armed: false
                Layout.alignment: Qt.AlignRight
                Layout.topMargin: Kirigami.Units.smallSpacing
                flat: true
                icon.name: armed ? "dialog-warning" : "edit-clear-all"
                text: armed ? i18n("Click again to confirm") : i18n("Reset all colors")
                onClicked: {
                    if (armed) {
                        applicationsTab.resetAllColors();
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
    }

    // ════════════════════════════════════════
    // ── Page 1: Color picker ──
    // ════════════════════════════════════════

    Components.ColorPicker {
        id: appColorPicker
        usedColors: applicationsTab.usedColors
        extractorBusy: applicationsTab.extractorBusy

        property string targetAppId: ""
        property var targetIconName: ""

        onColorSelected: function(color) {
            applicationsTab.setAppColor(targetAppId, color);
            applicationsTab.currentIndex = 0;
        }
        onAutoFromIconRequested: applicationsTab.extractColorFromIcon(targetAppId, targetIconName)
        onNyanToggled: function(enabled) {
            applicationsTab.toggleNyan(targetAppId, enabled);
        }
        onBackRequested: applicationsTab.currentIndex = 0
    }

    Connections {
        target: applicationsTab
        function onExtractionComplete() { applicationsTab.currentIndex = 0; }
    }
}
