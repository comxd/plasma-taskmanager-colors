/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Windows tab: per-window color overrides + full-page color picker + nyan toggle.
    Uses StackLayout for color picker page navigation.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import "../components" as Components

StackLayout {
    id: windowsTab

    // Data from root
    required property var detectedWindows  // root.detectedWindows
    required property var usedColors       // root.usedColors
    required property bool extractorBusy   // iconExtractor.busy
    required property var activeOverlays   // root.activeOverlays
    required property var colorMapCache    // root.colorMapCache
    required property var autoColorCache   // autoColorManager.autoColorCache

    // Signals for root to handle
    signal extractColorForWindow(var overlay, var iconName)
    signal nyanOverlaysChanged()
    signal resetWindowOverrides()

    // Connected by root to close picker on extraction complete
    signal extractionComplete()

    currentIndex: 0

    // ════════════════════════════════════════
    // ── Page 0: Window list ──
    // ════════════════════════════════════════

    Item {
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing * 2
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

            ListView {
                id: windowListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                clip: true
                spacing: 0
                Controls.ScrollBar.vertical: Controls.ScrollBar { id: winScrollBar; policy: Controls.ScrollBar.AsNeeded }

                model: windowsTab.detectedWindows

                delegate: ColumnLayout {
                    required property var modelData
                    required property int index
                    width: windowListView.width - (winScrollBar.visible ? winScrollBar.width + Kirigami.Units.smallSpacing : 0)
                    spacing: 0

                    // Inherited state computation
                    property string windowOverride: modelData.overlay ? modelData.overlay.windowColorOverride : ""
                    property string cleanOverride: windowOverride.endsWith(":nyan") ? windowOverride.slice(0, -5) : windowOverride
                    property bool hasWindowOverride: cleanOverride !== "" || windowOverride.endsWith(":nyan")
                    property bool isNyanApp: modelData.overlay ? modelData.overlay.isNyanApp : false
                    property bool isNyanWindow: windowOverride.endsWith(":nyan")
                    property bool isNyanInherited: isNyanApp && !isNyanWindow && windowOverride === ""
                    property string appColor: modelData.overlay ? String(modelData.overlay.overlayColor) : "transparent"
                    property bool hasInheritedColor: !hasWindowOverride && appColor !== "transparent" && appColor !== ""
                    property bool isManualApp: modelData.appId in windowsTab.colorMapCache
                    property string autoColor: (windowsTab.autoColorCache[modelData.appId]) || ""
                    property bool isAutoInherited: hasInheritedColor && !isManualApp && autoColor !== ""

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: Kirigami.Units.mediumSpacing
                        Layout.bottomMargin: Kirigami.Units.mediumSpacing
                        spacing: Kirigami.Units.mediumSpacing

                        HoverHandler {
                            onHoveredChanged: {
                                if (hovered && modelData.overlay) {
                                    modelData.overlay.pulseHighlight = true;
                                }
                            }
                        }

                        Kirigami.Icon {
                            source: modelData.iconName || modelData.appId
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Controls.Label {
                                text: modelData.windowTitle || modelData.appName
                                font.weight: Font.DemiBold
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

                            visible: !!modelData.overlay
                            enabled: !!modelData.overlay

                            Controls.ToolTip.text: {
                                if (cleanOverride) return i18n("Custom window override");
                                if (isNyanWindow) return i18n("Custom nyan override");
                                if (isNyanInherited) return i18n("Nyan inherited from app — click to override");
                                if (isAutoInherited) return i18n("Auto-extracted from icon — click to override");
                                if (hasInheritedColor) return i18n("Color inherited from app — click to override");
                                return i18n("Click to set color");
                            }
                            Controls.ToolTip.visible: hovered

                            contentItem: Item {}
                            background: Rectangle {
                                color: {
                                    if (cleanOverride) return cleanOverride;
                                    if (hasInheritedColor && !hasWindowOverride) return appColor;
                                    return Qt.rgba(Kirigami.Theme.backgroundColor.r,
                                                   Kirigami.Theme.backgroundColor.g,
                                                   Kirigami.Theme.backgroundColor.b, 0.5);
                                }
                                radius: 3
                                border.color: Kirigami.Theme.textColor
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    property color swatchColor: parent.color
                                    text: {
                                        if (cleanOverride) return "";
                                        if (isNyanWindow || isNyanInherited) return i18n("nyan");
                                        if (hasInheritedColor && !hasWindowOverride) return i18n("inherit");
                                        return "+";
                                    }
                                    color: {
                                        if (hasInheritedColor && !hasWindowOverride) {
                                            let luma = 0.299 * swatchColor.r + 0.587 * swatchColor.g + 0.114 * swatchColor.b;
                                            return luma < 0.5 ? "white" : "black";
                                        }
                                        return Kirigami.Theme.textColor;
                                    }
                                    font.pixelSize: (isNyanWindow || isNyanInherited || (hasInheritedColor && !hasWindowOverride)) ? Kirigami.Theme.smallFont.pixelSize : Kirigami.Theme.defaultFont.pixelSize
                                }
                            }

                            onClicked: {
                                winColorPicker.targetOverlay = modelData.overlay;
                                winColorPicker.targetIconName = modelData.iconName || modelData.appId;
                                winColorPicker.title = i18n("Window color override");
                                winColorPicker.isNyan = isNyanWindow;
                                windowsTab.currentIndex = 1;
                                winColorPicker.activate();
                            }
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

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        opacity: 0.3
                        visible: index < windowsTab.detectedWindows.length - 1
                    }
                }
            }

            // Reset window overrides (two-click confirmation)
            Controls.Button {
                id: resetWinButton
                property bool armed: false
                Layout.alignment: Qt.AlignRight
                Layout.topMargin: Kirigami.Units.smallSpacing
                flat: true
                icon.name: armed ? "dialog-warning" : "edit-clear-all"
                text: armed ? i18n("Click again to confirm") : i18n("Reset window overrides")
                onClicked: {
                    if (armed) {
                        windowsTab.resetWindowOverrides();
                        armed = false;
                    } else {
                        armed = true;
                        resetWinDisarmTimer.restart();
                    }
                }
                Timer {
                    id: resetWinDisarmTimer
                    interval: 3000
                    onTriggered: resetWinButton.armed = false
                }
            }
        }
    }

    // ════════════════════════════════════════
    // ── Page 1: Color picker ──
    // ════════════════════════════════════════

    Components.ColorPicker {
        id: winColorPicker
        usedColors: windowsTab.usedColors
        extractorBusy: windowsTab.extractorBusy

        property var targetOverlay: null
        property var targetIconName: ""

        onColorSelected: function(color) {
            if (targetOverlay) {
                let hadNyan = targetOverlay.windowColorOverride.endsWith(":nyan");
                targetOverlay.windowColorOverride = color + (hadNyan ? ":nyan" : "");
            }
            windowsTab.currentIndex = 0;
        }
        onAutoFromIconRequested: {
            if (targetOverlay) {
                windowsTab.extractColorForWindow(targetOverlay, targetIconName);
            }
        }
        onNyanToggled: function(enabled) {
            if (targetOverlay) {
                let raw = targetOverlay.windowColorOverride || "";
                let base = raw.replace(/:nyan$/, "");
                if (enabled) {
                    targetOverlay.windowColorOverride = (base || "") + ":nyan";
                } else {
                    targetOverlay.windowColorOverride = base;
                }
                windowsTab.nyanOverlaysChanged();
            }
        }
        onBackRequested: windowsTab.currentIndex = 0
    }

    Connections {
        target: windowsTab
        function onExtractionComplete() { windowsTab.currentIndex = 0; }
    }
}
