/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Color overlay visual component for task manager entries.
    Contains all color modes (frame, borders, background, diagonals, center lines)
    plus nyan rainbow renderers.
*/

import QtQuick
import org.kde.kirigami as Kirigami
import "../utils/colorUtils.js" as ColorUtils

Item {
    id: overlay

    property bool taskManagerColorsOverlay: true
    property color overlayColor: "transparent"
    property string colorMode: "frame"
    property int borderSize: 2
    property int minimizedBorderSize: -1
    property int borderRadius: 0
    property real bgOpacity: 0.35
    property string focusedMode: "background"
    property string focusedColorMode: ""
    property int focusedBorderSize: -1
    property real focusedOpacity: -1
    property int focusedBorderRadius: -1
    property real minimizedOpacity: -1
    property int minimizedBorderRadius: -1
    property int plasmaFocusDecoration: -1   // -1=default, 0-15=border bitmask (0=hide all)
    property int plasmaNormalDecoration: -1
    property int plasmaHoverDecoration: -1
    property bool panelIsVertical: false

    property bool isMinimized: false
    property string minimizedMode: "normal"
    property string minimizedColorMode: ""
    property bool minimizedDim: false
    property bool minimizedDesaturate: false
    property string desaturationStyle: "grayscale"
    property bool softenColors: false
    property int childCount: 0
    property bool showWindowCount: true

    property string windowColorOverride: ""
    property string windowTitle: ""

    property bool isNyanApp: false
    property string nyanStyle: "wave"
    property int nyanWaveOffset: 0

    // Nyan animation state from root
    property var nyanColors: []
    property int nyanStep: 0
    property real nyanScroll: 0

    // Desaturated nyan colors for minimized windows
    property var effectiveNyanColors: {
        if (isMinimized && (minimizedMode === "desaturate" || (minimizedMode === "custom" && minimizedDesaturate))) {
            return nyanColors.map(function(c) {
                if (desaturationStyle === "partial") {
                    return ColorUtils.desaturatePartial(c, 0.3);
                }
                var gray = 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
                return Qt.rgba(gray, gray, gray, c.a);
            });
        }
        return nyanColors;
    }

    property bool isNyanWindow: windowColorOverride.endsWith(":nyan")
    property bool isNyan: isNyanWindow || (windowColorOverride === "" && isNyanApp)
    property string cleanWindowOverride: {
        if (windowColorOverride.endsWith(":nyan"))
            return windowColorOverride.slice(0, -5);
        return windowColorOverride;
    }

    property color effectiveColor: {
        if (cleanWindowOverride !== "") return cleanWindowOverride;
        return overlayColor;
    }

    // Minimized window mode helpers
    property bool hiddenByMinimized: isMinimized && minimizedMode === "hide"
    property real minimizedDimFactor: (isMinimized && (minimizedMode === "dim" || (minimizedMode === "custom" && minimizedDim))) ? 0.35 : 1.0
    property color displayColor: {
        var c = effectiveColor;
        // Step 1: desaturation for minimized
        if (isMinimized && (minimizedMode === "desaturate" || (minimizedMode === "custom" && minimizedDesaturate))) {
            if (desaturationStyle === "partial") {
                c = ColorUtils.desaturatePartial(c, 0.3);
            } else {
                let gray = 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
                c = Qt.rgba(gray, gray, gray, c.a);
            }
        }
        // Step 2: theme-adaptive softening
        if (softenColors) {
            var bg = Kirigami.Theme.backgroundColor;
            var bgLuma = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
            var tintColor = bgLuma < 0.5 ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1);
            c = ColorUtils.tintWithAlpha(c, tintColor, 0.38);
        }
        return c;
    }

    // Effective color mode (focused takes priority over minimized)
    property string effectiveMode: {
        if (taskIsActive && focusedMode === "custom" && focusedColorMode !== "")
            return focusedColorMode;
        if (taskIsActive && focusedMode === "background")
            return "background";
        if (isMinimized && minimizedMode === "custom" && minimizedColorMode !== "")
            return minimizedColorMode;
        return colorMode;
    }

    property int effectiveBorderSize: {
        if (taskIsActive && focusedMode === "custom" && focusedBorderSize >= 0)
            return focusedBorderSize;
        if (isMinimized && minimizedMode === "custom" && minimizedBorderSize >= 0)
            return minimizedBorderSize;
        return borderSize;
    }

    property real effectiveOpacity: {
        if (taskIsActive && focusedMode === "background")
            return 0.8;
        if (taskIsActive && focusedMode === "custom")
            return focusedOpacity >= 0 ? focusedOpacity : 0.8;
        if (isMinimized && minimizedMode === "custom" && minimizedOpacity >= 0)
            return minimizedOpacity;
        return bgOpacity;
    }

    property int effectiveBorderRadius: {
        if (taskIsActive && focusedMode === "custom" && focusedBorderRadius >= 0)
            return focusedBorderRadius;
        if (isMinimized && minimizedMode === "custom" && minimizedBorderRadius >= 0)
            return minimizedBorderRadius;
        return borderRadius;
    }

    // Derived helpers from effective color mode
    property bool hasBackground: effectiveMode === "background" || effectiveMode === "background+frame"
    property bool hasFrame: effectiveMode === "frame" || effectiveMode === "background+frame"
    property bool hasTop: effectiveMode === "top" || effectiveMode === "top+bottom"
    property bool hasBottom: effectiveMode === "bottom" || effectiveMode === "top+bottom"
    property bool hasLeft: effectiveMode === "left" || effectiveMode === "left+right"
    property bool hasRight: effectiveMode === "right" || effectiveMode === "left+right"
    property bool hasCenter: effectiveMode === "center"
    property bool hasCenterH: effectiveMode === "center-h"
    property bool hasDiagDown: effectiveMode === "diagonal" || effectiveMode === "diagonal-cross"
    property bool hasDiagUp: effectiveMode === "diagonal-reverse" || effectiveMode === "diagonal-cross"
    property bool hasDiag: hasDiagDown || hasDiagUp

    // Find the task delegate ancestor (has appId property)
    property Item taskDelegate: {
        let p = parent;
        while (p) {
            if (p.hasOwnProperty("appId")) return p;
            p = p.parent;
        }
        return null;
    }
    // Detect if this task currently has focus (reactive binding)
    property bool taskIsActive: taskDelegate?.model?.IsActive ?? false
    property bool focusEnhanced: taskIsActive && focusedMode !== "hide"
    property bool hiddenByFocus: taskIsActive && focusedMode === "hide"
    property bool focusIsBackground: taskIsActive && focusedMode === "background"

    // Set to true when overlay was created without an app-level color
    property bool hasAppColor: true

    // True when there's no app color AND no window override AND not nyan
    property bool hasNoColor: !hasAppColor && cleanWindowOverride === "" && !isNyan

    anchors.fill: parent
    visible: !hiddenByFocus && !hasNoColor && !hiddenByMinimized
    z: focusEnhanced ? 1 : -1

    // Pulse highlight (triggered from Windows tab hover)
    property bool pulseHighlight: false
    onPulseHighlightChanged: if (pulseHighlight) pulseAnim.start()

    SequentialAnimation {
        id: pulseAnim
        running: false
        loops: 2
        NumberAnimation { target: overlay; property: "opacity"; to: 1.0; duration: 300; easing.type: Easing.InOutQuad }
        NumberAnimation { target: overlay; property: "opacity"; to: 0.4; duration: 300; easing.type: Easing.InOutQuad }
        onFinished: { overlay.opacity = 1.0; overlay.pulseHighlight = false; }
    }

    // ── Plasma decoration control (3-state × 2-mode) ──
    // -1 = default (don't modify), 0-15 = border bitmask (0 = hide all borders)
    property var _savedBorders: null
    property bool needsDecorationControl: plasmaFocusDecoration !== -1 || plasmaNormalDecoration !== -1 || plasmaHoverDecoration !== -1

    Connections {
        target: (overlay.needsDecorationControl && overlay.parent && overlay.parent.hasOwnProperty("prefix")) ? overlay.parent : null
        function onPrefixChanged() {
            overlay._applyDecoration();
        }
    }

    function _applyDecoration() {
        if (!parent || !parent.hasOwnProperty("enabledBorders")) return;

        // Save original on first call
        if (_savedBorders === null) _savedBorders = parent.enabledBorders;

        // Determine current state — hover > focus > normal
        var isHovered = parent.hasOwnProperty("isHovered") ? parent.isHovered : false;
        var decoration = -1;
        if (isHovered && plasmaHoverDecoration !== -1) {
            decoration = plasmaHoverDecoration;
        } else if (taskIsActive && plasmaFocusDecoration !== -1) {
            decoration = plasmaFocusDecoration;
        } else if (!taskIsActive && !isMinimized && plasmaNormalDecoration !== -1) {
            decoration = plasmaNormalDecoration;
        }

        // Apply: >= 0 = custom bitmask (0 hides all borders), -1 = restore default
        if (decoration >= 0) {
            parent.enabledBorders = decoration;
        } else {
            parent.enabledBorders = _savedBorders !== null ? _savedBorders : 15;
        }
    }

    onTaskIsActiveChanged: _applyDecoration()
    onIsMinimizedChanged: _applyDecoration()
    onPlasmaFocusDecorationChanged: _applyDecoration()
    onPlasmaNormalDecorationChanged: _applyDecoration()
    onPlasmaHoverDecorationChanged: _applyDecoration()
    Component.onCompleted: _applyDecoration()
    Component.onDestruction: {
        try {
            if (parent && parent.hasOwnProperty("enabledBorders") && _savedBorders !== null)
                parent.enabledBorders = _savedBorders;
        } catch(e) {}
    }

    // Background fill (hidden when nyan rainbow canvas is active)
    Rectangle {
        anchors.fill: parent
        radius: overlay.effectiveBorderRadius
        visible: (overlay.hasBackground || overlay.focusIsBackground) && !overlay.isNyan
        color: Qt.rgba(
            overlay.displayColor.r,
            overlay.displayColor.g,
            overlay.displayColor.b,
            overlay.effectiveOpacity * overlay.minimizedDimFactor
        )
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // ── Window count segment indicators ──
    Row {
        id: segmentRow
        visible: overlay.showWindowCount && overlay.childCount > 1 && !overlay.hasNoColor && !overlay.hiddenByFocus && !overlay.hiddenByMinimized && !overlay.isNyan
        anchors.horizontalCenter: overlay.panelIsVertical ? undefined : parent.horizontalCenter
        anchors.verticalCenter: overlay.panelIsVertical ? parent.verticalCenter : undefined
        anchors.bottom: overlay.panelIsVertical ? undefined : parent.bottom
        anchors.right: overlay.panelIsVertical ? parent.right : undefined
        anchors.bottomMargin: overlay.panelIsVertical ? 0 : 2
        anchors.rightMargin: overlay.panelIsVertical ? 2 : 0
        spacing: 2
        z: 2

        Repeater {
            model: Math.min(overlay.childCount, 5)
            Rectangle {
                width: overlay.panelIsVertical ? 3 : Math.max(4, Math.min(8, (overlay.width - segmentRow.spacing * (Math.min(overlay.childCount, 5) - 1)) / Math.min(overlay.childCount, 5)))
                height: overlay.panelIsVertical ? Math.max(4, Math.min(8, (overlay.height - segmentRow.spacing * (Math.min(overlay.childCount, 5) - 1)) / Math.min(overlay.childCount, 5))) : 3
                radius: 1
                color: Qt.darker(overlay.displayColor, 1.3)
                opacity: overlay.effectiveOpacity
            }
        }
    }

    // ── Nyan Cat rainbow: background (flat mode) ──
    NyanFlat {
        anchors.fill: parent
        visible: overlay.isNyan && overlay.nyanStyle === "flat" && (overlay.hasBackground || overlay.focusIsBackground)
        nyanColors: overlay.effectiveNyanColors
        nyanStep: overlay.nyanStep
        nyanWaveOffset: overlay.nyanWaveOffset
        bgOpacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        focusEnhanced: overlay.focusIsBackground
        borderRadius: overlay.effectiveBorderRadius
    }

    // ── Nyan Cat rainbow: background (wave mode) ──
    NyanWaveClip {
        anchors.fill: parent
        visible: overlay.isNyan && overlay.nyanStyle === "wave" && (overlay.hasBackground || overlay.focusIsBackground)
        nyanColors: overlay.effectiveNyanColors
        nyanScroll: overlay.nyanScroll
        nyanWaveOffset: overlay.nyanWaveOffset
        bgOpacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        focusEnhanced: overlay.focusIsBackground
    }

    // ── Nyan Cat rainbow: background (original mode) ──
    NyanOriginal {
        anchors.fill: parent
        visible: overlay.isNyan && overlay.nyanStyle === "original" && (overlay.hasBackground || overlay.focusIsBackground)
        nyanColors: overlay.effectiveNyanColors
        nyanStep: overlay.nyanStep
        bgOpacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        focusEnhanced: overlay.focusIsBackground
    }

    // ── Nyan Cat rainbow: borders (Canvas + clip) ──
    NyanBorderCanvas {
        anchors.fill: parent
        visible: overlay.isNyan && (overlay.hasFrame || overlay.hasTop || overlay.hasBottom || overlay.hasLeft || overlay.hasRight || overlay.hasCenter || overlay.hasCenterH || overlay.hasDiag || overlay.focusIsBackground)

        hasFrame: overlay.hasFrame
        hasTop: overlay.hasTop
        hasBottom: overlay.hasBottom
        hasLeft: overlay.hasLeft
        hasRight: overlay.hasRight
        hasCenter: overlay.hasCenter
        hasCenterH: overlay.hasCenterH
        hasDiag: overlay.hasDiag
        hasDiagDown: overlay.hasDiagDown
        hasDiagUp: overlay.hasDiagUp
        focusEnhanced: overlay.focusIsBackground
        panelIsVertical: overlay.panelIsVertical
        borderSize: overlay.effectiveBorderSize

        nyanStep: overlay.nyanStep
        nyanScroll: overlay.nyanScroll
        nyanStyle: overlay.nyanStyle
        nyanWaveOffset: overlay.nyanWaveOffset
        nyanColors: overlay.effectiveNyanColors
        bgOpacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
    }

    // ── Regular color rendering ──

    Rectangle {
        anchors.fill: parent
        radius: overlay.effectiveBorderRadius
        visible: overlay.hasFrame && !overlay.focusIsBackground && !overlay.isNyan
        color: "transparent"
        border.color: overlay.displayColor
        border.width: overlay.effectiveBorderSize
        opacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: overlay.effectiveBorderSize
        visible: ((overlay.focusIsBackground && !overlay.panelIsVertical) || (overlay.hasTop && !overlay.hasFrame)) && !overlay.isNyan
        color: overlay.displayColor
        opacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: overlay.effectiveBorderSize
        visible: overlay.hasBottom && !overlay.hasFrame && !overlay.focusIsBackground && !overlay.isNyan
        color: overlay.displayColor
        opacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: overlay.effectiveBorderSize
        visible: ((overlay.focusIsBackground && overlay.panelIsVertical) || (overlay.hasLeft && !overlay.hasFrame && !overlay.focusIsBackground)) && !overlay.isNyan
        color: overlay.displayColor
        opacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: overlay.effectiveBorderSize
        visible: overlay.hasRight && !overlay.hasFrame && !overlay.focusIsBackground && !overlay.isNyan
        color: overlay.displayColor
        opacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // Center line vertical (swaps to horizontal in vertical panels)
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: overlay.effectiveBorderSize
        visible: overlay.hasCenter && !overlay.panelIsVertical && !overlay.isNyan
        color: overlay.displayColor
        opacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        Behavior on color { ColorAnimation { duration: 200 } }
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: overlay.effectiveBorderSize
        visible: overlay.hasCenter && overlay.panelIsVertical && !overlay.isNyan
        color: overlay.displayColor
        opacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // Center line horizontal (swaps to vertical in vertical panels)
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: overlay.effectiveBorderSize
        visible: overlay.hasCenterH && !overlay.panelIsVertical && !overlay.isNyan
        color: overlay.displayColor
        opacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        Behavior on color { ColorAnimation { duration: 200 } }
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: overlay.effectiveBorderSize
        visible: overlay.hasCenterH && overlay.panelIsVertical && !overlay.isNyan
        color: overlay.displayColor
        opacity: overlay.effectiveOpacity * overlay.minimizedDimFactor
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // Diagonal lines (Canvas-based)
    Canvas {
        id: diagCanvas
        anchors.fill: parent
        visible: overlay.hasDiag && !overlay.focusIsBackground && !overlay.isNyan
        opacity: overlay.effectiveOpacity * overlay.minimizedDimFactor

        onVisibleChanged: if (visible) requestPaint()
        property color diagColor: overlay.displayColor
        property int diagWidth: overlay.effectiveBorderSize
        property string diagMode: overlay.effectiveMode
        onDiagColorChanged: requestPaint()
        onDiagWidthChanged: requestPaint()
        onDiagModeChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            let ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = Qt.rgba(diagColor.r, diagColor.g, diagColor.b, diagColor.a);
            ctx.lineWidth = diagWidth;
            ctx.lineCap = "round";

            if (overlay.hasDiagDown) {
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(width, height);
                ctx.stroke();
            }
            if (overlay.hasDiagUp) {
                ctx.beginPath();
                ctx.moveTo(width, 0);
                ctx.lineTo(0, height);
                ctx.stroke();
            }
        }
    }
}
