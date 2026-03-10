/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Color overlay visual component for task manager entries.
    Contains all color modes (frame, borders, background, diagonals, center lines)
    plus nyan rainbow renderers.
*/

import QtQuick

Item {
    id: overlay

    property bool taskManagerColorsOverlay: true
    property color overlayColor: "transparent"
    property string colorMode: "frame"
    property int borderSize: 2
    property int borderRadius: 0
    property real bgOpacity: 0.35
    property bool focusOverride: false
    property bool panelIsVertical: false

    property string windowColorOverride: ""
    property string windowTitle: ""

    property bool isNyanApp: false
    property string nyanStyle: "wave"
    property int nyanWaveOffset: 0

    // Nyan animation state from root
    property var nyanColors: []
    property int nyanStep: 0
    property real nyanScroll: 0

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

    // Derived helpers from unified colorMode
    property bool hasBackground: colorMode === "background" || colorMode === "background+frame"
    property bool hasFrame: colorMode === "frame" || colorMode === "background+frame"
    property bool hasTop: colorMode === "top" || colorMode === "top+bottom"
    property bool hasBottom: colorMode === "bottom" || colorMode === "top+bottom"
    property bool hasLeft: colorMode === "left" || colorMode === "left+right"
    property bool hasRight: colorMode === "right" || colorMode === "left+right"
    property bool hasCenter: colorMode === "center"
    property bool hasCenterH: colorMode === "center-h"
    property bool hasDiagDown: colorMode === "diagonal" || colorMode === "diagonal-cross"
    property bool hasDiagUp: colorMode === "diagonal-reverse" || colorMode === "diagonal-cross"
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
    property bool focusEnhanced: focusOverride && taskIsActive
    property bool hiddenByFocus: !focusOverride && taskIsActive

    // Set to true when overlay was created without an app-level color
    property bool hasAppColor: true

    // True when there's no app color AND no window override AND not nyan
    property bool hasNoColor: !hasAppColor && cleanWindowOverride === "" && !isNyan

    anchors.fill: parent
    visible: !hiddenByFocus && !hasNoColor
    z: focusEnhanced ? 1 : -1

    // Background fill (hidden when nyan rainbow canvas is active)
    Rectangle {
        anchors.fill: parent
        radius: overlay.borderRadius
        visible: (overlay.hasBackground || overlay.focusEnhanced) && !overlay.isNyan
        color: Qt.rgba(
            overlay.effectiveColor.r,
            overlay.effectiveColor.g,
            overlay.effectiveColor.b,
            overlay.focusEnhanced ? 0.8 : overlay.bgOpacity
        )
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // ── Nyan Cat rainbow: background (flat mode) ──
    NyanFlat {
        anchors.fill: parent
        visible: overlay.isNyan && overlay.nyanStyle === "flat" && (overlay.hasBackground || overlay.focusEnhanced)
        nyanColors: overlay.nyanColors
        nyanStep: overlay.nyanStep
        nyanWaveOffset: overlay.nyanWaveOffset
        bgOpacity: overlay.bgOpacity
        focusEnhanced: overlay.focusEnhanced
        borderRadius: overlay.borderRadius
    }

    // ── Nyan Cat rainbow: background (wave mode) ──
    NyanWaveClip {
        anchors.fill: parent
        visible: overlay.isNyan && overlay.nyanStyle === "wave" && (overlay.hasBackground || overlay.focusEnhanced)
        nyanScroll: overlay.nyanScroll
        nyanWaveOffset: overlay.nyanWaveOffset
        bgOpacity: overlay.bgOpacity
        focusEnhanced: overlay.focusEnhanced
    }

    // ── Nyan Cat rainbow: background (original mode) ──
    NyanOriginal {
        anchors.fill: parent
        visible: overlay.isNyan && overlay.nyanStyle === "original" && (overlay.hasBackground || overlay.focusEnhanced)
        nyanStep: overlay.nyanStep
        bgOpacity: overlay.bgOpacity
        focusEnhanced: overlay.focusEnhanced
    }

    // ── Nyan Cat rainbow: borders (Canvas + clip) ──
    NyanBorderCanvas {
        anchors.fill: parent
        visible: overlay.isNyan && (overlay.hasFrame || overlay.hasTop || overlay.hasBottom || overlay.hasLeft || overlay.hasRight || overlay.hasCenter || overlay.hasCenterH || overlay.hasDiag || overlay.focusEnhanced)

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
        focusEnhanced: overlay.focusEnhanced
        panelIsVertical: overlay.panelIsVertical
        borderSize: overlay.borderSize

        nyanStep: overlay.nyanStep
        nyanScroll: overlay.nyanScroll
        nyanStyle: overlay.nyanStyle
        nyanWaveOffset: overlay.nyanWaveOffset
        bgOpacity: overlay.bgOpacity
    }

    // ── Regular color rendering ──

    Rectangle {
        anchors.fill: parent
        radius: overlay.borderRadius
        visible: overlay.hasFrame && !overlay.focusEnhanced && !overlay.isNyan
        color: "transparent"
        border.color: overlay.effectiveColor
        border.width: overlay.borderSize
        opacity: overlay.bgOpacity
        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: overlay.borderSize
        visible: ((overlay.focusEnhanced && !overlay.panelIsVertical) || (overlay.hasTop && !overlay.hasFrame)) && !overlay.isNyan
        color: overlay.effectiveColor
        opacity: overlay.focusEnhanced ? 0.8 : overlay.bgOpacity
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: overlay.borderSize
        visible: overlay.hasBottom && !overlay.hasFrame && !overlay.focusEnhanced && !overlay.isNyan
        color: overlay.effectiveColor
        opacity: overlay.bgOpacity
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: overlay.borderSize
        visible: ((overlay.focusEnhanced && overlay.panelIsVertical) || (overlay.hasLeft && !overlay.hasFrame && !overlay.focusEnhanced)) && !overlay.isNyan
        color: overlay.effectiveColor
        opacity: overlay.focusEnhanced ? 0.8 : overlay.bgOpacity
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: overlay.borderSize
        visible: overlay.hasRight && !overlay.hasFrame && !overlay.focusEnhanced && !overlay.isNyan
        color: overlay.effectiveColor
        opacity: overlay.bgOpacity
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // Center line vertical (swaps to horizontal in vertical panels)
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: overlay.borderSize
        visible: overlay.hasCenter && !overlay.panelIsVertical && !overlay.isNyan
        color: overlay.effectiveColor
        opacity: overlay.bgOpacity
        Behavior on color { ColorAnimation { duration: 200 } }
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: overlay.borderSize
        visible: overlay.hasCenter && overlay.panelIsVertical && !overlay.isNyan
        color: overlay.effectiveColor
        opacity: overlay.bgOpacity
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // Center line horizontal (swaps to vertical in vertical panels)
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: overlay.borderSize
        visible: overlay.hasCenterH && !overlay.panelIsVertical && !overlay.isNyan
        color: overlay.effectiveColor
        opacity: overlay.bgOpacity
        Behavior on color { ColorAnimation { duration: 200 } }
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: overlay.borderSize
        visible: overlay.hasCenterH && overlay.panelIsVertical && !overlay.isNyan
        color: overlay.effectiveColor
        opacity: overlay.bgOpacity
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // Diagonal lines (Canvas-based)
    Canvas {
        id: diagCanvas
        anchors.fill: parent
        visible: overlay.hasDiag && !overlay.focusEnhanced && !overlay.isNyan
        opacity: overlay.bgOpacity

        onVisibleChanged: if (visible) requestPaint()
        property color diagColor: overlay.effectiveColor
        property int diagWidth: overlay.borderSize
        property string diagMode: overlay.colorMode
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
