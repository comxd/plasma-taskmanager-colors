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
import "utils/colorUtils.js" as ColorUtils

PlasmoidItem {
    id: root
    activationTogglesExpanded: true
    Plasmoid.icon: Qt.resolvedUrl("../icons/icon.svg")

    property int _pendingPage: -1

    function applyPendingTabIndex() {
        if (!expanded || _pendingPage < 0) return;
        let rep = fullRepresentationItem;
        if (!rep || !rep.tabBarRef) return;
        rep.tabBarRef.currentIndex = _pendingPage;
        _pendingPage = -1;
        pendingPageTimeout.stop();
    }

    // Delay popup open to let context menu close first
    Timer {
        id: aboutOpenTimer
        interval: 200
        onTriggered: root.expanded = true
    }

    // Safety net: clear pending state if popup never opens
    Timer {
        id: pendingPageTimeout
        interval: 2000
        onTriggered: root._pendingPage = -1
    }

    onExpandedChanged: {
        if (expanded) {
            Qt.callLater(function() { root.applyPendingTabIndex(); });
        } else if (_pendingPage < 0) {
            // Reset to first tab when popup closes normally (not via context menu)
            let rep = fullRepresentationItem;
            if (rep && rep.tabBarRef) rep.tabBarRef.currentIndex = 0;
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

    function getWindowRules() {
        try {
            let rules = JSON.parse(plasmoid.configuration.windowColorMap);
            return Array.isArray(rules) ? rules : [];
        } catch (e) {
            return [];
        }
    }

    function findRuleIndex(rules, appId, match) {
        return rules.findIndex(r => r.appId === appId && r.match === match);
    }

    function saveWindowRules(rules) {
        plasmoid.configuration.windowColorMap = JSON.stringify(rules);
    }

    function _upsertWindowRule(rules, appId, match, color) {
        let idx = findRuleIndex(rules, appId, match);
        let isEmpty = ColorUtils.stripNyan(color) === "" && !ColorUtils.hasNyan(color);
        if (match === "" || isEmpty) {
            if (idx >= 0) rules.splice(idx, 1);
        } else if (idx >= 0) {
            rules[idx].color = color;
        } else {
            rules.push({ appId: appId, match: match, color: color });
        }
    }

    function setWindowColor(appId, match, color) {
        let rules = getWindowRules();
        let idx = findRuleIndex(rules, appId, match);
        let existing = idx >= 0 ? rules[idx].color : "";
        let newColor = ColorUtils.hasNyan(existing) && !ColorUtils.hasNyan(color)
            ? ColorUtils.withNyan(color || "")
            : (color || "");
        _upsertWindowRule(rules, appId, match, newColor);
        saveWindowRules(rules);
    }

    function removeWindowColor(appId, match) {
        let rules = getWindowRules().filter(r => !(r.appId === appId && r.match === match));
        saveWindowRules(rules);
    }

    function toggleWindowNyan(appId, match, enable) {
        if (match === "") return;
        let rules = getWindowRules();
        let idx = findRuleIndex(rules, appId, match);
        let base = ColorUtils.stripNyan(idx >= 0 ? rules[idx].color : "");
        _upsertWindowRule(rules, appId, match, enable ? ColorUtils.withNyan(base) : base);
        saveWindowRules(rules);
    }

    function renameWindowRule(appId, oldMatch, newMatch) {
        if (oldMatch === newMatch || newMatch === "") return;
        let rules = getWindowRules();
        let oi = findRuleIndex(rules, appId, oldMatch);
        if (oi < 0) return;
        let color = rules[oi].color;
        rules.splice(oi, 1);
        let ni = findRuleIndex(rules, appId, newMatch);
        if (ni >= 0) rules[ni].color = color;
        else rules.push({ appId: appId, match: newMatch, color: color });
        saveWindowRules(rules);
    }

    property var windowTracking: ({})

    property bool _pendingWindowResolution: false
    property int _resettleCount: 0
    readonly property int _resettleMaxPasses: 8

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
    property var windowColorMapCache: []
    property var parsedSkipList: []     // Parsed autoColorSkippedApps (avoids JSON.parse per delegate)
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

            let childCount = 0;
            try { childCount = item.model?.ChildCount ?? 0; } catch(e) {}

            let winId = "";
            try {
                let ids = item.model?.WinIdList;
                if (ids && ids.length > 0) winId = String(ids[0]);
            } catch(e) {}

            results.push({
                item: item,
                appId: item.appId || "",
                appName: item.appName || "",
                iconName: iconName,
                windowTitle: windowTitle,
                isWindow: item.isWindow || false,
                isRunning: isRunning,
                isActive: isActive,
                isMinimized: isMinimized,
                childCount: childCount,
                winId: winId
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
            // Primary: check imagePath (normal case)
            if (child.hasOwnProperty("imagePath") &&
                String(child.imagePath).indexOf("widgets/tasks") >= 0) {
                return child;
            }
        }
        // Fallback: if imagePath was cleared by us, find via overlay sentinel
        for (let i = 0; i < taskItem.children.length; i++) {
            let child = taskItem.children[i];
            if (child.hasOwnProperty("enabledBorders") &&
                child.hasOwnProperty("prefix") && child.children) {
                for (let j = 0; j < child.children.length; j++) {
                    if (child.children[j].taskManagerColorsOverlay) return child;
                }
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
        onWindowColorExtracted: function(appId, match, hex) {
            root.setWindowColor(appId, match, hex);
        }
    }

    Components.AutoColorManager {
        id: autoColorManager
        autoEnabled: plasmoid.configuration.autoColorEnabled
        onQueueDrained: applyDebounce.restart()
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
        root._pendingWindowResolution = false;

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
        root.windowColorMapCache = getWindowRules();

        let skipList = [];
        try { skipList = JSON.parse(plasmoid.configuration.autoColorSkippedApps); } catch(e) {}
        if (!Array.isArray(skipList)) skipList = [];
        root.parsedSkipList = skipList;

        // Update auto color cache BEFORE per-task loop so autoColorCache is current
        if (plasmoid.configuration.autoColorEnabled) {
            autoColorManager.updateTaskList(tasks, colorMap);
        }

        let verticalSwap = { "top": "left", "bottom": "right", "left": "top", "right": "bottom",
                             "top+bottom": "left+right", "left+right": "top+bottom" };

        let mode = plasmoid.configuration.colorMode;
        if (root.isVertical && verticalSwap[mode]) mode = verticalSwap[mode];

        let cfgRadius = plasmoid.configuration.borderRadius;
        let autoBorderW = plasmoid.configuration.autoBorderWidth;
        let borderW = plasmoid.configuration.borderWidth;
        let bgOpac = plasmoid.configuration.backgroundOpacity;
        let focMode = plasmoid.configuration.focusedMode || "background";
        let focColorMode = (focMode === "custom") ? (plasmoid.configuration.focusedColorMode || "") : "";
        if (focColorMode && root.isVertical && verticalSwap[focColorMode]) focColorMode = verticalSwap[focColorMode];

        let focAutoBorderW = plasmoid.configuration.focusedAutoBorderWidth;
        let focBorderW = plasmoid.configuration.focusedBorderWidth;
        let focOpacity = plasmoid.configuration.focusedOpacity;
        let focRadius = plasmoid.configuration.focusedBorderRadius;
        let hovMode = plasmoid.configuration.hoverMode || "normal";
        let hovColorMode = (hovMode === "custom") ? (plasmoid.configuration.hoverColorMode || "") : "";
        if (hovColorMode && root.isVertical && verticalSwap[hovColorMode]) hovColorMode = verticalSwap[hovColorMode];
        let hovAutoBorderW = plasmoid.configuration.hoverAutoBorderWidth;
        let hovBorderW = plasmoid.configuration.hoverBorderWidth;
        let hovOpacity = plasmoid.configuration.hoverOpacity;
        let hovRadius = plasmoid.configuration.hoverBorderRadius;

        let minMode = plasmoid.configuration.minimizedMode || "normal";
        let minColorMode = (minMode === "custom") ? (plasmoid.configuration.minimizedColorMode || "") : "";
        if (minColorMode && root.isVertical && verticalSwap[minColorMode]) minColorMode = verticalSwap[minColorMode];
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

        function autoMarginFor(svg, m) {
            if (!svg) return 0;
            if (m === "bottom") return svg.margins.bottom;
            if (m === "left" || m === "left+right") return svg.margins.left;
            if (m === "right") return svg.margins.right;
            if (m === "center" || m === "center-h") return Math.min(svg.margins.top, svg.margins.left);
            return svg.margins.top;
        }

        let windowList = [];
        let liveOverlays = [];
        let nyanIndex = 0;
        let pendingResolution = false;
        let prevTracking = root.windowTracking;
        let newTracking = {};
        for (let t of tasks) {
            let rawColor = colorMap[t.appId] || "";
            let hasManualColor = rawColor !== "";

            // Auto color: fill in when no manual color exists and not skipped
            let isSkipped = skipList.indexOf(t.appId) >= 0;
            if (!rawColor && !isSkipped && plasmoid.configuration.autoColorEnabled) {
                let autoHex = autoColorManager.autoColorCache[t.appId];
                if (autoHex) rawColor = autoHex;
            }

            // B1: skip only blocks auto colors, not manual ones
            let hasAppColor = hasManualColor || (rawColor !== "" && !isSkipped);

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

            let effectiveBorderW = borderW;
            if (autoBorderW && svg) {
                let margin = autoMarginFor(svg, mode);
                if (minColorMode) margin = Math.max(margin, autoMarginFor(svg, minColorMode));
                if (margin > 0) effectiveBorderW = margin;
            }
            effectiveBorderW = Math.min(effectiveBorderW, root.computedMaxBorder);

            let effectiveMinBorderW = -1;
            if (minColorMode && minColorMode !== "background") {
                effectiveMinBorderW = minBorderW;
                if (minAutoBorderW && svg) {
                    let minMargin = autoMarginFor(svg, minColorMode);
                    if (minMargin > 0) effectiveMinBorderW = minMargin;
                }
                effectiveMinBorderW = Math.min(effectiveMinBorderW, root.computedMaxBorder);
            }

            let effectiveFocBorderW = -1;
            if (focColorMode && focColorMode !== "background") {
                effectiveFocBorderW = focBorderW;
                if (focAutoBorderW && svg) {
                    let focMargin = autoMarginFor(svg, focColorMode);
                    if (focMargin > 0) effectiveFocBorderW = focMargin;
                }
                effectiveFocBorderW = Math.min(effectiveFocBorderW, root.computedMaxBorder);
            }

            let effectiveHovBorderW = -1;
            if (hovColorMode && hovColorMode !== "background") {
                effectiveHovBorderW = hovBorderW;
                if (hovAutoBorderW && svg) {
                    let hovMargin = autoMarginFor(svg, hovColorMode);
                    if (hovMargin > 0) effectiveHovBorderW = hovMargin;
                }
                effectiveHovBorderW = Math.min(effectiveHovBorderW, root.computedMaxBorder);
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

            let winOverride = "";
            let wid = t.winId || "";
            let curTitle = t.windowTitle || "";
            let rules = root.windowColorMapCache;
            if (wid !== "") {
                let boundMatch = prevTracking[wid];
                if (boundMatch !== undefined) {
                    let ri = findRuleIndex(rules, t.appId, boundMatch);
                    if (ri >= 0) {
                        winOverride = rules[ri].color || "";
                        if (curTitle !== "" && curTitle !== boundMatch) {
                            renameWindowRule(t.appId, boundMatch, curTitle);
                            boundMatch = curTitle;
                        }
                        newTracking[wid] = boundMatch;
                    }
                } else {
                    let ri = findRuleIndex(rules, t.appId, curTitle);
                    if (ri >= 0 && curTitle !== "") {
                        winOverride = rules[ri].color || "";
                        newTracking[wid] = curTitle;
                    }
                }
            } else {
                let ri = findRuleIndex(rules, t.appId, curTitle);
                if (ri >= 0 && curTitle !== "") winOverride = rules[ri].color || "";
            }

            if (t.isRunning && winOverride === "" &&
                rules.some(function(r) { return r.appId === t.appId; })) {
                pendingResolution = true;
            }

            let existing = findExistingOverlay(t.item);
            let props = {
                hasAppColor: hasAppColor,
                windowColorOverride: winOverride,
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
                hoverMode: hovMode,
                hoverColorMode: hovColorMode,
                hoverBorderSize: effectiveHovBorderW,
                hoverOpacity: hovOpacity,
                hoverBorderRadius: hovRadius >= 0 ? Math.min(hovRadius, root.computedMaxRadius) : -1,
                minimizedOpacity: minOpacity,
                minimizedBorderRadius: minRadius >= 0 ? Math.min(minRadius, root.computedMaxRadius) : -1,
                panelIsVertical: root.isVertical,
                windowTitle: t.windowTitle || "",
                isMinimized: t.isMinimized,
                minimizedMode: minMode,
                minimizedColorMode: minColorMode,
                minimizedDim: minDim,
                minimizedDesaturate: minDesaturate,
                desaturationStyle: plasmoid.configuration.desaturationStyle,
                softenColors: plasmoid.configuration.softenColors,
                plasmaFocusDecoration: plasmoid.configuration.plasmaFocusDecoration,
                plasmaNormalDecoration: plasmoid.configuration.plasmaNormalDecoration,
                plasmaHoverDecoration: plasmoid.configuration.plasmaHoverDecoration,
                childCount: t.childCount || 0,
                showWindowCount: plasmoid.configuration.showWindowCount,
                isNyanApp: isNyan,
                nyanStyle: plasmoid.configuration.rainbowStyle,
                nyanWaveOffset: nyanIndex % 6,
                nyanColors: root.nyanColors,
                nyanStep: Qt.binding(function() { return root.nyanStep; }),
                nyanScroll: Qt.binding(function() { return root.nyanScroll; })
            };
            if (isNyan) nyanIndex++;
            if (existing) {
                Object.keys(props).forEach(k => existing[k] = props[k]);
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
                    winId: wid,
                    overlay: existing
                });
            }
        }
        root.windowTracking = newTracking;
        root._pendingWindowResolution = pendingResolution;
        root.windowColorMapCache = getWindowRules();
        root.activeOverlays = liveOverlays;
        root.hasNyanOverlays = liveOverlays.some(function(o) { return o.isNyan; });
        windowList.sort((a, b) => (a.windowTitle || a.appName).localeCompare(b.windowTitle || b.appName));
        root.detectedWindows = windowList;

    }

    // ── Reactive task tracking (no polling) ──

    TaskManager.TasksModel {
        id: tasksModel
        onCountChanged: { applyDebounce.restart(); startResettle(); }
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

    Timer {
        id: resettleTimer
        interval: 350
        repeat: true
        onTriggered: {
            root._resettleCount++;
            applyColors();
            if (!root._pendingWindowResolution ||
                root._resettleCount >= root._resettleMaxPasses) {
                resettleTimer.stop();
            }
        }
    }

    function startResettle() {
        if (getWindowRules().length === 0) return;
        root._resettleCount = 0;
        resettleTimer.restart();
    }

    Component.onCompleted: {
        // One-time cleanup: "tint" mode was removed — reset stale KConfig values
        if (plasmoid.configuration.colorMode === "tint")
            plasmoid.configuration.colorMode = "background";
        if (plasmoid.configuration.focusedColorMode === "tint")
            plasmoid.configuration.focusedColorMode = "";
        if (plasmoid.configuration.minimizedColorMode === "tint")
            plasmoid.configuration.minimizedColorMode = "";
        if (plasmoid.configuration.hoverColorMode === "tint")
            plasmoid.configuration.hoverColorMode = "";
        applyDebounce.restart();
        startResettle();
        updatePlasmoidStatus();
        hideWidgetAction.checked = plasmoid.configuration.hideWidget;
    }
    Component.onDestruction: removeAllOverlays()

    Connections {
        target: plasmoid.configuration
        function onAppColorMapChanged() { applyDebounce.restart(); }
        function onWindowColorMapChanged() { applyDebounce.restart(); }
        function onColorModeChanged() { applyDebounce.restart(); }
        function onFocusedModeChanged() { applyDebounce.restart(); }
        function onFocusedColorModeChanged() { applyDebounce.restart(); }
        function onFocusedBorderWidthChanged() { applyDebounce.restart(); }
        function onFocusedAutoBorderWidthChanged() { applyDebounce.restart(); }
        function onFocusedOpacityChanged() { applyDebounce.restart(); }
        function onFocusedBorderRadiusChanged() { applyDebounce.restart(); }
        function onPlasmaFocusDecorationChanged() { applyDebounce.restart(); }
        function onPlasmaNormalDecorationChanged() { applyDebounce.restart(); }
        function onPlasmaHoverDecorationChanged() { applyDebounce.restart(); }
        function onHoverModeChanged() { applyDebounce.restart(); }
        function onHoverColorModeChanged() { applyDebounce.restart(); }
        function onHoverBorderWidthChanged() { applyDebounce.restart(); }
        function onHoverAutoBorderWidthChanged() { applyDebounce.restart(); }
        function onHoverOpacityChanged() { applyDebounce.restart(); }
        function onHoverBorderRadiusChanged() { applyDebounce.restart(); }
        function onMinimizedOpacityChanged() { applyDebounce.restart(); }
        function onMinimizedBorderRadiusChanged() { applyDebounce.restart(); }
        function onBorderRadiusChanged() { applyDebounce.restart(); }
        function onPinnedBehaviorChanged() { applyDebounce.restart(); }
        function onMinimizedModeChanged() { applyDebounce.restart(); }
        function onMinimizedColorModeChanged() { applyDebounce.restart(); }
        function onMinimizedDimChanged() { applyDebounce.restart(); }
        function onMinimizedDesaturateChanged() { applyDebounce.restart(); }
        function onDesaturationStyleChanged() { applyDebounce.restart(); }
        function onSoftenColorsChanged() { applyDebounce.restart(); }
        function onShowWindowCountChanged() { applyDebounce.restart(); }
        function onMinimizedBorderWidthChanged() { applyDebounce.restart(); }
        function onMinimizedAutoBorderWidthChanged() { applyDebounce.restart(); }
        function onAutoBorderWidthChanged() { applyDebounce.restart(); }
        function onBorderWidthChanged() { applyDebounce.restart(); }
        function onRainbowSpeedChanged() { applyDebounce.restart(); }
        function onRainbowStyleChanged() { applyDebounce.restart(); }
        function onBackgroundOpacityChanged() { applyDebounce.restart(); }
        function onIsEnabledChanged() { applyDebounce.restart(); }
        function onAutoColorEnabledChanged() { applyDebounce.restart(); }
        // onAutoColorCacheChanged intentionally omitted — persistTimer writes trigger it,
        // causing infinite loop: write → handler → applyColors → updateTaskList → persistTimer → write
        function onAutoColorSkippedAppsChanged() { applyDebounce.restart(); }
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
                        autoColorEnabled: plasmoid.configuration.autoColorEnabled
                        autoColorCache: autoColorManager.autoColorCache
                        autoSkippedApps: root.parsedSkipList

                        onSetAppColor: function(appId, color) { root.setAppColor(appId, color); }
                        onRemoveAppColor: function(appId) { root.removeAppColor(appId); }
                        onToggleNyan: function(appId, enable) { root.toggleNyan(appId, enable); }
                        onExtractColorFromIcon: function(appId, iconName) { iconExtractor.extractForApp(appId, iconName); }
                        onResetAllColors: { plasmoid.configuration.appColorMap = "{}"; root.applyColors(); }
                        onToggleAutoSkip: function(appId, skip) {
                            let list = root.parsedSkipList.slice();
                            if (skip && list.indexOf(appId) < 0) {
                                list.push(appId);
                            } else if (!skip) {
                                list = list.filter(id => id !== appId);
                            }
                            plasmoid.configuration.autoColorSkippedApps = JSON.stringify(list);
                        }

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
                        colorMapCache: root.colorMapCache
                        windowColorMapCache: root.windowColorMapCache
                        autoColorCache: autoColorManager.autoColorCache

                        onSetWindowColor: function(appId, match, color) { root.setWindowColor(appId, match, color); }
                        onRemoveWindowColor: function(appId, match) { root.removeWindowColor(appId, match); }
                        onToggleWindowNyan: function(appId, match, enable) { root.toggleWindowNyan(appId, match, enable); }
                        onExtractColorForWindow: function(appId, match, iconName) { iconExtractor.extractForWindow(appId, match, iconName); }
                        onResetWindowOverrides: { plasmoid.configuration.windowColorMap = "[]"; }

                        Connections {
                            target: iconExtractor
                            function onColorExtracted() { winTab.extractionComplete(); }
                        }
                    }

                    Tabs.SettingsTab {
                        computedMaxRadius: root.computedMaxRadius
                        computedMaxBorder: root.computedMaxBorder
                        autoQueueBusy: autoColorManager.queueBusy
                        onRefreshAutoColors: { autoColorManager.triggerFullRefresh(); applyDebounce.restart(); }
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
            root.expanded = false;           // Close popup first (let context menu close)
            root._pendingPage = 4;           // Mark which page to open
            pendingPageTimeout.restart();    // Start safety timeout
            aboutOpenTimer.restart();        // Schedule delayed popup open
        }
    }

    Plasmoid.contextualActions: [aboutAction, hideWidgetAction]

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
