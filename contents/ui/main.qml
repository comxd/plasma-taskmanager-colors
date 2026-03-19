/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Task Manager Colors — Per-application color coding for task manager entries.
    Uses Panel Colorizer technique: traverse panel QML tree, inject overlays.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
// ColorDialog replaced by inline picker (dialogs don't work in Plasma popups)
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager
import "components" as Components
import "tabs" as Tabs

PlasmoidItem {
    id: root
    activationTogglesExpanded: true
    Plasmoid.icon: Qt.resolvedUrl("../icons/icon.svg")

    property int pendingTabIndex: -1

    function applyPendingTabIndex() {
        if (!expanded || pendingTabIndex < 0) return;
        let rep = fullRepresentationItem;
        if (!rep || !rep.tabBarRef) return;
        rep.tabBarRef.currentIndex = pendingTabIndex;
        pendingTabIndex = -1;
    }

    onExpandedChanged: {
        if (expanded) {
            Qt.callLater(function() { root.applyPendingTabIndex(); });
        }
    }

    // ── Configuration helpers ──

    function getColorMap() {
        try {
            return JSON.parse(plasmoid.configuration.appColorMap);
        } catch (e) {
            return {};
        }
    }

    function setAppColor(appId, color) {
        let map = getColorMap();
        // Preserve :nyan suffix if new color doesn't already have it
        let existing = map[appId] || "";
        let hadNyan = existing.endsWith(":nyan") && !color.endsWith(":nyan");
        map[appId] = (color || "") + (hadNyan ? ":nyan" : "");
        plasmoid.configuration.appColorMap = JSON.stringify(map);
        // applyColors() triggered by onAppColorMapChanged handler
    }

    function removeAppColor(appId) {
        let map = getColorMap();
        delete map[appId];
        plasmoid.configuration.appColorMap = JSON.stringify(map);
        // applyColors() triggered by onAppColorMapChanged handler
    }

    function toggleNyan(appId, enable) {
        let map = getColorMap();
        let existing = map[appId] || "";
        let base = existing.replace(/:nyan$/, "");
        if (enable) {
            map[appId] = base + ":nyan";
        } else {
            if (base === "") {
                delete map[appId];
            } else {
                map[appId] = base;
            }
        }
        plasmoid.configuration.appColorMap = JSON.stringify(map);
    }

    // ── Panel tree traversal (Panel Colorizer technique) ──

    property Item panelLayout: {
        let candidate = root.parent;
        while (candidate) {
            if (candidate instanceof GridLayout) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null;
    }

    property bool onDesktop: Plasmoid.location === PlasmaCore.Types.Floating
    property bool isVertical: Plasmoid.location === PlasmaCore.Types.LeftEdge ||
                              Plasmoid.location === PlasmaCore.Types.RightEdge

    // ── Task detection ──

    property var detectedTasks: []
    property var detectedWindows: []  // All windows (not deduplicated), with overlay refs
    property var usedColors: []  // Colors already assigned to apps (for reuse picker)
    property int computedMaxRadius: 24   // Updated dynamically from task delegate size
    property int computedMaxBorder: 10  // 50% of task height
    property var colorMapCache: ({})    // Cached parsed colorMap (avoids JSON.parse per delegate)
    property var activeOverlays: []     // Track all created overlays for reliable cleanup

    // ── Global Nyan Cat state (single timer for all overlays) ──
    readonly property var nyanColors: [
        Qt.rgba(1, 0, 0, 1), Qt.rgba(1, 0.6, 0, 1), Qt.rgba(1, 1, 0, 1),
        Qt.rgba(0.2, 1, 0, 1), Qt.rgba(0, 0.6, 1, 1), Qt.rgba(0.4, 0.2, 1, 1)
    ]
    property real nyanScroll: 0         // 0→1 continuous scroll position
    property int nyanStep: 0            // 0→5 discrete color index
    property bool hasNyanOverlays: false
    property bool nyanPreviewActive: false  // Set by Nyan Cat tab
    Timer {
        interval: plasmoid.configuration.rainbowFps
        running: root.hasNyanOverlays || root.nyanPreviewActive
        repeat: true
        onTriggered: {
            var s = plasmoid.configuration.rainbowSpeed;
            var dt = plasmoid.configuration.rainbowFps / 1000.0;
            root.nyanScroll = (root.nyanScroll + dt / s) % 1.0;
            root.nyanStep = Math.floor(root.nyanScroll * 6) % 6;
        }
    }

    function findTaskManagerWidget() {
        if (!panelLayout) return null;
        for (let i = 0; i < panelLayout.children.length; i++) {
            let child = panelLayout.children[i];
            if (!child.applet?.plasmoid?.pluginName) continue;
            let pluginName = child.applet.plasmoid.pluginName;
            if (pluginName === "org.kde.plasma.taskmanager" ||
                pluginName === "org.kde.plasma.icontasks") {
                return child;
            }
        }
        return null;
    }

    function findTaskDelegates(item, depth, maxDepth) {
        if (!item || depth > maxDepth) return [];
        let results = [];

        let isTaskDelegate = (
            item.hasOwnProperty("appId") &&
            item.hasOwnProperty("appName") &&
            item.hasOwnProperty("isWindow")
        );

        if (isTaskDelegate) {
            let isActive = false;
            try { isActive = item.model?.IsActive ?? false; } catch(e) {}

            let iconName = "";
            try { iconName = item.model?.decoration ?? ""; } catch(e) {}
            if (!iconName) iconName = item.appId || "";

            let windowTitle = "";
            try { windowTitle = item.model?.display ?? ""; } catch(e) {}

            let isLauncher = false;
            try { isLauncher = item.model?.IsLauncher ?? false; } catch(e) {}
            let isRunning = (item.isWindow || false) && !isLauncher;

            let isMinimized = false;
            try { isMinimized = item.model?.IsMinimized ?? false; } catch(e) {}

            results.push({
                item: item,
                appId: item.appId || "",
                appName: item.appName || "",
                iconName: iconName,
                windowTitle: windowTitle,
                isWindow: item.isWindow || false,
                isRunning: isRunning,
                isActive: isActive,
                isMinimized: isMinimized
            });
        }

        if (item.children) {
            for (let i = 0; i < item.children.length; i++) {
                results = results.concat(
                    findTaskDelegates(item.children[i], depth + 1, maxDepth)
                );
            }
        }
        return results;
    }

    // ── Overlay management ──

    function findFrameSvg(taskItem) {
        if (!taskItem?.children) return null;
        for (let i = 0; i < taskItem.children.length; i++) {
            let child = taskItem.children[i];
            if (child.hasOwnProperty("imagePath") &&
                String(child.imagePath).indexOf("widgets/tasks") >= 0) {
                return child;
            }
        }
        return null;
    }

    function findExistingOverlay(taskItem) {
        let svg = findFrameSvg(taskItem);
        if (svg?.children) {
            for (let i = 0; i < svg.children.length; i++) {
                if (svg.children[i].taskManagerColorsOverlay) return svg.children[i];
            }
        }
        if (taskItem?.children) {
            for (let i = 0; i < taskItem.children.length; i++) {
                if (taskItem.children[i].taskManagerColorsOverlay) return taskItem.children[i];
            }
        }
        return null;
    }

    Component {
        id: overlayComponent
        Components.ColorOverlay {}
    }

    // ── Icon dominant color extraction ──

    Components.IconExtractor {
        id: iconExtractor
        onAppColorExtracted: function(appId, hex) {
            root.setAppColor(appId, hex);
        }
        onWindowColorExtracted: function(overlay, hex) {
            let hadNyan = overlay.windowColorOverride.endsWith(":nyan");
            overlay.windowColorOverride = hex + (hadNyan ? ":nyan" : "");
        }
    }

    function removeAllOverlays() {
        for (let o of root.activeOverlays) {
            if (o) { o.visible = false; o.destroy(); }
        }
        root.activeOverlays = [];
        let tm = findTaskManagerWidget();
        if (!tm) return;
        let tasks = findTaskDelegates(tm, 0, 15);
        for (let t of tasks) {
            let existing = findExistingOverlay(t.item);
            if (existing) { existing.visible = false; existing.destroy(); }
        }
    }

    function applyColors() {
        if (onDesktop) return;

        let tm = findTaskManagerWidget();
        if (!tm) {
            root.detectedTasks = [];
            root.detectedWindows = [];
            for (let o of root.activeOverlays) {
                if (o) { try { o.visible = false; o.destroy(); } catch(e) {} }
            }
            root.activeOverlays = [];
            return;
        }

        let tasks = findTaskDelegates(tm, 0, 15);

        if (!plasmoid.configuration.isEnabled) {
            for (let t of tasks) {
                let existing = findExistingOverlay(t.item);
                if (existing) { existing.visible = false; existing.destroy(); }
            }
            root.activeOverlays = [];
            return;
        }
        let colorMap = getColorMap();
        root.colorMapCache = colorMap;

        let mode = plasmoid.configuration.colorMode;
        if (root.isVertical) {
            let swap = { "top": "left", "bottom": "right", "left": "top", "right": "bottom",
                         "top+bottom": "left+right", "left+right": "top+bottom" };
            if (swap[mode]) mode = swap[mode];
        }
        let cfgRadius = plasmoid.configuration.borderRadius;
        let autoBorderW = plasmoid.configuration.autoBorderWidth;
        let borderW = plasmoid.configuration.borderWidth;
        let bgOpac = plasmoid.configuration.backgroundOpacity;
        let focMode = plasmoid.configuration.focusedMode || "background";
        let focColorMode = (focMode === "custom") ? (plasmoid.configuration.focusedColorMode || "") : "";
        if (focColorMode && root.isVertical) {
            let swap = { "top": "left", "bottom": "right", "left": "top", "right": "bottom",
                         "top+bottom": "left+right", "left+right": "top+bottom" };
            if (swap[focColorMode]) focColorMode = swap[focColorMode];
        }
        let focAutoBorderW = plasmoid.configuration.focusedAutoBorderWidth;
        let focBorderW = plasmoid.configuration.focusedBorderWidth;
        let focOpacity = plasmoid.configuration.focusedOpacity;
        let focRadius = plasmoid.configuration.focusedBorderRadius;
        let minMode = plasmoid.configuration.minimizedMode || "normal";
        let minColorMode = (minMode === "custom") ? (plasmoid.configuration.minimizedColorMode || "") : "";
        if (minColorMode && root.isVertical) {
            let swap = { "top": "left", "bottom": "right", "left": "top", "right": "bottom",
                         "top+bottom": "left+right", "left+right": "top+bottom" };
            if (swap[minColorMode]) minColorMode = swap[minColorMode];
        }
        let minDim = plasmoid.configuration.minimizedDim || false;
        let minDesaturate = plasmoid.configuration.minimizedDesaturate || false;
        let minAutoBorderW = plasmoid.configuration.minimizedAutoBorderWidth;
        let minBorderW = plasmoid.configuration.minimizedBorderWidth;
        let minOpacity = plasmoid.configuration.minimizedOpacity;
        let minRadius = plasmoid.configuration.minimizedBorderRadius;

        let uniqueTasks = {};
        for (let t of tasks) {
            if (!t.appId) continue;
            if (!uniqueTasks[t.appId]) {
                uniqueTasks[t.appId] = {
                    appId: t.appId,
                    appName: t.appName,
                    iconName: t.iconName || t.appId,
                    isRunning: t.isRunning
                };
            } else if (t.isRunning) {
                uniqueTasks[t.appId].isRunning = true;
            }
        }
        let taskList = Object.values(uniqueTasks);
        taskList.sort((a, b) => a.appName.localeCompare(b.appName));
        detectedTasks = taskList;

        let colorValues = Object.values(colorMap).map(c => c.replace(/:nyan$/, "")).filter(c => c !== "");
        let uniqueUsedColors = [...new Set(colorValues)];
        let usedList = [];
        for (let c of uniqueUsedColors) {
            let apps = Object.keys(colorMap).filter(k => colorMap[k].replace(/:nyan$/, "") === c);
            let appNames = apps.map(k => uniqueTasks[k]?.appName || k);
            usedList.push({ color: c, appNames: appNames, count: appNames.length });
        }
        root.usedColors = usedList;

        let pinnedBehavior = plasmoid.configuration.pinnedBehavior;

        if (tasks.length > 0) {
            let t = tasks[0].item;
            root.computedMaxRadius = Math.max(
                Math.floor(Math.min(t.width, t.height) / 2), 1
            );
            function borderDimFor(m) {
                // Max border = half the dimension the border grows into
                if (m === "left" || m === "right" || m === "left+right") return t.width;
                if (m === "top" || m === "bottom" || m === "top+bottom") return t.height;
                if (m === "center") return root.isVertical ? t.height : t.width;
                if (m === "center-h") return root.isVertical ? t.width : t.height;
                if (m === "frame" || m === "background+frame") return Math.min(t.width, t.height);
                return Math.min(t.width, t.height);
            }
            let borderDim = borderDimFor(mode);
            if (minColorMode) borderDim = Math.min(borderDim, borderDimFor(minColorMode));
            root.computedMaxBorder = Math.max(
                Math.floor(borderDim / 2), 1
            );
        }

        let windowList = [];
        let liveOverlays = [];
        let nyanIndex = 0;
        for (let t of tasks) {
            let rawColor = colorMap[t.appId] || "";
            let hasAppColor = rawColor !== "";

            // Skip non-running tasks: no overlay needed for pinned launchers
            // without app color, or when pinnedBehavior is "runningOnly"
            let shouldSkip = !t.isRunning &&
                (!hasAppColor || pinnedBehavior === "runningOnly");
            if (shouldSkip) {
                let existing = findExistingOverlay(t.item);
                if (existing) { existing.visible = false; existing.destroy(); }
                continue;
            }

            let svg = findFrameSvg(t.item);

            function autoMarginFor(m) {
                if (!svg) return 0;
                if (m === "bottom") return svg.margins.bottom;
                if (m === "left" || m === "left+right") return svg.margins.left;
                if (m === "right") return svg.margins.right;
                if (m === "center" || m === "center-h") return Math.min(svg.margins.top, svg.margins.left);
                return svg.margins.top;
            }

            let effectiveBorderW = borderW;
            if (autoBorderW && svg) {
                let margin = autoMarginFor(mode);
                if (minColorMode) margin = Math.max(margin, autoMarginFor(minColorMode));
                if (margin > 0) effectiveBorderW = margin;
            }
            effectiveBorderW = Math.min(effectiveBorderW, root.computedMaxBorder);

            let effectiveMinBorderW = -1;
            if (minColorMode && minColorMode !== "background") {
                effectiveMinBorderW = minBorderW;
                if (minAutoBorderW && svg) {
                    let minMargin = autoMarginFor(minColorMode);
                    if (minMargin > 0) effectiveMinBorderW = minMargin;
                }
                effectiveMinBorderW = Math.min(effectiveMinBorderW, root.computedMaxBorder);
            }

            let effectiveFocBorderW = -1;
            if (focColorMode && focColorMode !== "background") {
                effectiveFocBorderW = focBorderW;
                if (focAutoBorderW && svg) {
                    let focMargin = autoMarginFor(focColorMode);
                    if (focMargin > 0) effectiveFocBorderW = focMargin;
                }
                effectiveFocBorderW = Math.min(effectiveFocBorderW, root.computedMaxBorder);
            }

            let effectiveRadius = cfgRadius >= 0 ? cfgRadius : 0;
            if (cfgRadius < 0 && svg) {
                let r = Math.min(svg.fixedMargins?.top ?? 0, svg.fixedMargins?.left ?? 0);
                effectiveRadius = Math.max(r, 0);
            }
            effectiveRadius = Math.min(effectiveRadius, root.computedMaxRadius);

            let isNyan = hasAppColor && rawColor.endsWith(":nyan");
            let assignedColor = isNyan ? rawColor.slice(0, -5) : (hasAppColor ? rawColor : "");
            let overlayColorVal = assignedColor || "transparent";

            let existing = findExistingOverlay(t.item);
            let props = {
                hasAppColor: hasAppColor,
                overlayColor: overlayColorVal,
                colorMode: mode,
                borderRadius: effectiveRadius,
                borderSize: effectiveBorderW,
                minimizedBorderSize: effectiveMinBorderW,
                bgOpacity: bgOpac,
                focusedMode: focMode,
                focusedColorMode: focColorMode,
                focusedBorderSize: effectiveFocBorderW,
                focusedOpacity: focOpacity,
                focusedBorderRadius: focRadius >= 0 ? Math.min(focRadius, root.computedMaxRadius) : -1,
                minimizedOpacity: minOpacity,
                minimizedBorderRadius: minRadius >= 0 ? Math.min(minRadius, root.computedMaxRadius) : -1,
                panelIsVertical: root.isVertical,
                windowTitle: t.windowTitle || "",
                isMinimized: t.isMinimized,
                minimizedMode: minMode,
                minimizedColorMode: minColorMode,
                minimizedDim: minDim,
                minimizedDesaturate: minDesaturate,
                isNyanApp: isNyan,
                nyanStyle: plasmoid.configuration.rainbowStyle,
                nyanWaveOffset: nyanIndex % 6,
                nyanColors: root.nyanColors,
                nyanStep: Qt.binding(function() { return root.nyanStep; }),
                nyanScroll: Qt.binding(function() { return root.nyanScroll; })
            };
            if (isNyan) nyanIndex++;
            if (existing) {
                let savedOverride = existing.windowColorOverride;
                Object.keys(props).forEach(k => existing[k] = props[k]);
                existing.windowColorOverride = savedOverride;
            } else {
                let parentItem = svg || t.item;
                existing = overlayComponent.createObject(parentItem, props);
            }
            liveOverlays.push(existing);

            if (t.isRunning) {
                windowList.push({
                    appId: t.appId,
                    appName: t.appName,
                    iconName: t.iconName || t.appId,
                    windowTitle: t.windowTitle || t.appName,
                    overlay: existing
                });
            }
        }
        root.activeOverlays = liveOverlays;
        root.hasNyanOverlays = liveOverlays.some(function(o) { return o.isNyan; });
        windowList.sort((a, b) => (a.windowTitle || a.appName).localeCompare(b.windowTitle || b.appName));
        root.detectedWindows = windowList;
    }

    // ── Reactive task tracking (no polling) ──

    TaskManager.TasksModel {
        id: tasksModel
        onCountChanged: applyDebounce.restart()
        onActiveTaskChanged: applyDebounce.restart()
        onDataChanged: applyDebounce.restart()
    }

    onPanelLayoutChanged: {
        if (panelLayout) applyDebounce.restart();
    }

    Timer {
        id: applyDebounce
        interval: 200
        repeat: false
        onTriggered: applyColors()
    }

    Component.onCompleted: { applyDebounce.restart(); updatePlasmoidStatus(); hideWidgetAction.checked = plasmoid.configuration.hideWidget; }
    Component.onDestruction: removeAllOverlays()

    Connections {
        target: plasmoid.configuration
        function onAppColorMapChanged() { applyDebounce.restart(); }
        function onColorModeChanged() { applyDebounce.restart(); }
        function onFocusedModeChanged() { applyDebounce.restart(); }
        function onFocusedColorModeChanged() { applyDebounce.restart(); }
        function onFocusedBorderWidthChanged() { applyDebounce.restart(); }
        function onFocusedAutoBorderWidthChanged() { applyDebounce.restart(); }
        function onFocusedOpacityChanged() { applyDebounce.restart(); }
        function onFocusedBorderRadiusChanged() { applyDebounce.restart(); }
        function onMinimizedOpacityChanged() { applyDebounce.restart(); }
        function onMinimizedBorderRadiusChanged() { applyDebounce.restart(); }
        function onBorderRadiusChanged() { applyDebounce.restart(); }
        function onPinnedBehaviorChanged() { applyDebounce.restart(); }
        function onMinimizedModeChanged() { applyDebounce.restart(); }
        function onMinimizedColorModeChanged() { applyDebounce.restart(); }
        function onMinimizedDimChanged() { applyDebounce.restart(); }
        function onMinimizedDesaturateChanged() { applyDebounce.restart(); }
        function onMinimizedBorderWidthChanged() { applyDebounce.restart(); }
        function onMinimizedAutoBorderWidthChanged() { applyDebounce.restart(); }
        function onAutoBorderWidthChanged() { applyDebounce.restart(); }
        function onBorderWidthChanged() { applyDebounce.restart(); }
        function onRainbowSpeedChanged() { applyDebounce.restart(); }
        function onRainbowStyleChanged() { applyDebounce.restart(); }
        function onBackgroundOpacityChanged() { applyDebounce.restart(); }
        function onIsEnabledChanged() { applyDebounce.restart(); }
    }

    // ── UI: Popup for color assignment ──

    fullRepresentation: Item {
        id: fullRep
        Layout.preferredWidth: Kirigami.Units.gridUnit * 26
        Layout.preferredHeight: Kirigami.Units.gridUnit * 24
        Layout.minimumWidth: Kirigami.Units.gridUnit * 18
        Layout.minimumHeight: Kirigami.Units.gridUnit * 14

        property alias tabBarRef: tabBar
        Component.onCompleted: root.applyPendingTabIndex()

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header ──
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.mediumSpacing

                Kirigami.Heading {
                    text: i18n("Task Manager Colors")
                    level: 3
                    Layout.fillWidth: true
                }

                Controls.Switch {
                    checked: plasmoid.configuration.isEnabled
                    onToggled: plasmoid.configuration.isEnabled = checked
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                visible: plasmoid.configuration.isEnabled
            }

            // ── Tab bar ──
            Controls.TabBar {
                id: tabBar
                Layout.fillWidth: true
                visible: plasmoid.configuration.isEnabled
                position: Controls.TabBar.Header

                Controls.TabButton { text: i18n("Applications") }
                Controls.TabButton { text: i18n("Windows (%1)", root.detectedWindows.length) }
                Controls.TabButton { text: i18n("Settings") }
                Controls.TabButton { text: i18n("Nyan Cat") }
                Controls.TabButton { text: i18n("About") }
                onCurrentIndexChanged: root.nyanPreviewActive = (currentIndex === 3)
            }

            // ── Tab content ──
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: plasmoid.configuration.isEnabled
                color: Qt.rgba(
                    Kirigami.Theme.backgroundColor.r,
                    Kirigami.Theme.backgroundColor.g,
                    Kirigami.Theme.backgroundColor.b,
                    0.4
                )
                border.color: Qt.rgba(
                    Kirigami.Theme.textColor.r,
                    Kirigami.Theme.textColor.g,
                    Kirigami.Theme.textColor.b,
                    0.1
                )
                border.width: 1

                StackLayout {
                    anchors.fill: parent
                    currentIndex: tabBar.currentIndex

                    Tabs.ApplicationsTab {
                        id: appTab
                        detectedTasks: root.detectedTasks
                        colorMapCache: root.colorMapCache
                        usedColors: root.usedColors
                        extractorBusy: iconExtractor.busy

                        onSetAppColor: function(appId, color) { root.setAppColor(appId, color); }
                        onRemoveAppColor: function(appId) { root.removeAppColor(appId); }
                        onToggleNyan: function(appId, enable) { root.toggleNyan(appId, enable); }
                        onExtractColorFromIcon: function(appId, iconName) { iconExtractor.extractForApp(appId, iconName); }
                        onResetAllColors: { plasmoid.configuration.appColorMap = "{}"; root.applyColors(); }

                        Connections {
                            target: iconExtractor
                            function onColorExtracted() { appTab.extractionComplete(); }
                        }
                    }

                    Tabs.WindowsTab {
                        id: winTab
                        detectedWindows: root.detectedWindows
                        usedColors: root.usedColors
                        extractorBusy: iconExtractor.busy
                        activeOverlays: root.activeOverlays

                        onExtractColorForWindow: function(overlay, iconName) { iconExtractor.extractForWindow(overlay, iconName); }
                        onNyanOverlaysChanged: {
                            root.hasNyanOverlays = root.activeOverlays.some(function(o) { return o.isNyan; });
                        }
                        onResetWindowOverrides: {
                            for (let o of root.activeOverlays) {
                                if (o) o.windowColorOverride = "";
                            }
                            root.hasNyanOverlays = false;
                            root.applyColors();
                        }

                        Connections {
                            target: iconExtractor
                            function onColorExtracted() { winTab.extractionComplete(); }
                        }
                    }

                    Tabs.SettingsTab {
                        computedMaxRadius: root.computedMaxRadius
                        computedMaxBorder: root.computedMaxBorder
                    }

                    Tabs.NyanTab {
                        nyanColors: root.nyanColors
                        nyanStep: root.nyanStep
                        nyanScroll: root.nyanScroll
                    }

                    Tabs.AboutTab {}
                }
            }

            // Disabled state
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !plasmoid.configuration.isEnabled

                Controls.Label {
                    anchors.centerIn: parent
                    text: i18n("Disabled \u2014 toggle switch above to enable")
                    color: Kirigami.Theme.disabledTextColor
                }
            }
        }
    }

    // ── Widget visibility ──
    property bool editMode: {
        if (Plasmoid.containment && Plasmoid.containment.corona) {
            return Plasmoid.containment.corona.editMode;
        }
        return false;
    }
    property bool hideWidget: plasmoid.configuration.hideWidget

    function updatePlasmoidStatus() {
        Plasmoid.status = (editMode || !hideWidget)
            ? PlasmaCore.Types.ActiveStatus
            : PlasmaCore.Types.HiddenStatus;
    }
    onEditModeChanged: updatePlasmoidStatus()
    onHideWidgetChanged: updatePlasmoidStatus()

    property PlasmaCore.Action hideWidgetAction: PlasmaCore.Action {
        text: i18n("Hide widget from panel")
        icon.name: "visibility-symbolic"
        checkable: true
        onTriggered: {
            plasmoid.configuration.hideWidget = !plasmoid.configuration.hideWidget;
            plasmoid.configuration.writeConfig();
        }
    }
    Connections {
        target: plasmoid.configuration
        function onHideWidgetChanged() {
            hideWidgetAction.checked = plasmoid.configuration.hideWidget;
        }
    }
    property PlasmaCore.Action aboutAction: PlasmaCore.Action {
        text: i18n("About Task Manager Colors")
        icon.name: "help-about"
        onTriggered: {
            root.pendingTabIndex = 4;
            root.expanded = true;
            Qt.callLater(function() { root.applyPendingTabIndex(); });
        }
    }

    Plasmoid.contextualActions: [hideWidgetAction, aboutAction]

    toolTipMainText: i18n("Task Manager Colors")
    toolTipSubText: {
        if (onDesktop) return i18n("Must be placed in a panel");
        if (!plasmoid.configuration.isEnabled) return i18n("Disabled");
        let count = Object.keys(root.colorMapCache).length;
        return count > 0
            ? i18n("%1 application(s) colored", count)
            : i18n("Click to assign colors");
    }
}
