/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Windows tab: persistent per-window color rules + full-page color picker + nyan toggle.
    A rule colors any window whose title contains its (editable) match text, so colors
    survive closing and reopening a window. Uses StackLayout for picker page navigation.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import "../components" as Components
import "../utils/colorUtils.js" as ColorUtils

StackLayout {
    id: windowsTab

    // Data from root
    required property var detectedWindows     // root.detectedWindows
    required property var usedColors          // root.usedColors
    required property bool extractorBusy       // iconExtractor.busy
    required property var colorMapCache        // root.colorMapCache
    required property var windowColorMapCache
    required property var autoColorCache       // autoColorManager.autoColorCache

    // Signals for root to handle
    signal setWindowColor(string appId, string match, string color)
    signal removeWindowColor(string appId, string match)
    signal toggleWindowNyan(string appId, string match, bool enable)
    signal extractColorForWindow(string appId, string match, var iconName)
    signal resetWindowOverrides()

    // Connected by root to close picker on extraction complete
    signal extractionComplete()

    currentIndex: 0

    function ruleForWindow(appId, title) {
        for (let r of windowsTab.windowColorMapCache) {
            if (r.appId === appId && r.match === title) return r;
        }
        return null;
    }

    function ruleIsActive(rule) {
        for (let w of windowsTab.detectedWindows) {
            if (w.appId === rule.appId && (w.windowTitle || "") === rule.match) return true;
        }
        return false;
    }

    property var orphanRules: {
        let out = [];
        for (let r of windowsTab.windowColorMapCache) {
            if (!ruleIsActive(r)) out.push(r);
        }
        return out;
    }

    // ════════════════════════════════════════
    // ── Page 0: Window list ──
    // ════════════════════════════════════════

    Item {
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.mediumSpacing
            spacing: Kirigami.Units.smallSpacing

            Controls.Label {
                text: i18n("Assign a persistent color to a window. The color follows the window as its title changes and is restored when the window is reopened.")
                color: Kirigami.Theme.disabledTextColor
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
            }

            Item { height: Kirigami.Units.smallSpacing; width: 1 }
            Kirigami.Separator { Layout.fillWidth: true }

            Controls.Label {
                visible: windowsTab.detectedWindows.length === 0
                text: i18n("No windows detected — open some windows to assign colors.")
                color: Kirigami.Theme.disabledTextColor
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
            }

            ListView {
                id: windowListView
                visible: windowsTab.detectedWindows.length > 0
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
                    property var rule: windowsTab.ruleForWindow(modelData.appId, modelData.windowTitle)
                    property string ruleMatch: rule ? rule.match : ""
                    property string windowOverride: rule ? (rule.color || "") : ""
                    property string cleanOverride: ColorUtils.stripNyan(windowOverride)
                    property bool hasWindowOverride: cleanOverride !== "" || ColorUtils.hasNyan(windowOverride)
                    property bool isNyanApp: modelData.overlay ? modelData.overlay.isNyanApp : false
                    property bool isNyanWindow: ColorUtils.hasNyan(windowOverride)
                    property bool isNyanInherited: isNyanApp && !isNyanWindow && windowOverride === ""
                    property string appColor: modelData.overlay ? String(modelData.overlay.overlayColor) : "transparent"
                    property bool hasInheritedColor: !hasWindowOverride && appColor !== "transparent" && appColor !== "" && appColor !== "#00000000"
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
                                winColorPicker.targetAppId = modelData.appId;
                                winColorPicker.targetMatch = ruleMatch || modelData.windowTitle;
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
                            visible: hasWindowOverride
                            flat: true
                            onClicked: windowsTab.removeWindowColor(modelData.appId, ruleMatch)

                            Controls.ToolTip.text: i18n("Remove window color")
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

            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing
                visible: windowsTab.orphanRules.length > 0

                Kirigami.Separator { Layout.fillWidth: true }

                Controls.Label {
                    text: i18n("Saved rules (window not open)")
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Kirigami.Theme.disabledTextColor
                    Layout.fillWidth: true
                }

                Repeater {
                    model: windowsTab.orphanRules
                    delegate: RowLayout {
                        id: orphanRow
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        property string ruleColorRaw: modelData.color || ""
                        property string cleanRuleColor: ColorUtils.stripNyan(ruleColorRaw)
                        property bool ruleIsNyan: ColorUtils.hasNyan(ruleColorRaw)

                        Rectangle {
                            implicitWidth: Kirigami.Units.gridUnit
                            implicitHeight: Kirigami.Units.gridUnit
                            radius: 3
                            color: orphanRow.cleanRuleColor !== "" ? orphanRow.cleanRuleColor
                                   : Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.5)
                            border.color: Kirigami.Theme.textColor
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                visible: orphanRow.ruleIsNyan
                                text: i18n("nyan")
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize * 0.8
                                color: Kirigami.Theme.textColor
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Controls.Label {
                                text: modelData.match
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            }
                            Controls.Label {
                                text: modelData.appId
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                color: Kirigami.Theme.disabledTextColor
                            }
                        }

                        Controls.Button {
                            icon.name: "edit-delete"
                            implicitWidth: Kirigami.Units.gridUnit * 1.5
                            implicitHeight: Kirigami.Units.gridUnit * 1.5
                            flat: true
                            onClicked: windowsTab.removeWindowColor(modelData.appId, modelData.match)
                            Controls.ToolTip.text: i18n("Delete rule")
                            Controls.ToolTip.visible: hovered
                        }
                    }
                }
            }

            // Reset window overrides (two-click confirmation)
            Controls.Button {
                id: resetWinButton
                property bool armed: false
                Layout.alignment: Qt.AlignRight
                Layout.topMargin: Kirigami.Units.smallSpacing
                visible: windowsTab.windowColorMapCache.length > 0
                flat: true
                icon.name: armed ? "dialog-warning" : "edit-clear-all"
                text: armed ? i18n("Click again to confirm") : i18n("Reset window rules")
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

        property string targetAppId: ""
        property string targetMatch: ""
        property var targetIconName: ""

        onColorSelected: function(color) {
            windowsTab.setWindowColor(targetAppId, targetMatch, color);
            windowsTab.currentIndex = 0;
        }
        onAutoFromIconRequested: {
            windowsTab.extractColorForWindow(targetAppId, targetMatch, targetIconName);
        }
        onNyanToggled: function(enabled) {
            windowsTab.toggleWindowNyan(targetAppId, targetMatch, enabled);
        }
        onBackRequested: windowsTab.currentIndex = 0
    }

    Connections {
        target: windowsTab
        function onExtractionComplete() { windowsTab.currentIndex = 0; }
    }
}
