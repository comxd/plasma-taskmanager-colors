/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Nyan Cat rainbow for border modes (single Canvas with ctx.clip for shape masking).
*/

import QtQuick

Canvas {
    id: nyanBorderCanvas

    // Overlay shape properties
    required property bool hasFrame
    required property bool hasTop
    required property bool hasBottom
    required property bool hasLeft
    required property bool hasRight
    required property bool hasCenter
    required property bool hasCenterH
    required property bool hasDiag
    required property bool hasDiagDown
    required property bool hasDiagUp
    required property bool focusEnhanced
    required property bool panelIsVertical
    required property int borderSize

    // Nyan animation state
    required property int nyanStep
    required property real nyanScroll
    required property string nyanStyle
    required property int nyanWaveOffset
    required property real bgOpacity
    required property var nyanColors   // 6 Qt.rgba values (may be desaturated)

    opacity: focusEnhanced ? 0.8 : bgOpacity

    onNyanColorsChanged: if (visible) requestPaint()
    onNyanStepChanged: if (visible && nyanStyle !== "wave") requestPaint()
    onNyanScrollChanged: if (visible && nyanStyle === "wave") requestPaint()
    onNyanStyleChanged: if (visible) requestPaint()
    onWidthChanged: if (visible) requestPaint()
    onHeightChanged: if (visible) requestPaint()
    onVisibleChanged: if (visible) requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        var w = width, h = height, bw = borderSize;
        if (w <= 0 || h <= 0 || bw <= 0) return;

        var pv = panelIsVertical;
        var fe = focusEnhanced;

        // Build clip path from active border edges
        ctx.save();
        ctx.beginPath();
        if (hasFrame) {
            ctx.rect(0, 0, w, h);
            ctx.rect(bw, bw, w - 2 * bw, h - 2 * bw);
            ctx.clip("evenodd");
        } else if (hasDiag) {
            var angle1 = Math.atan2(h, w);
            var nx1 = -Math.sin(angle1) * bw / 2;
            var ny1 = Math.cos(angle1) * bw / 2;
            if (hasDiagDown) {
                ctx.moveTo(nx1, ny1);
                ctx.lineTo(w + nx1, h + ny1);
                ctx.lineTo(w - nx1, h - ny1);
                ctx.lineTo(-nx1, -ny1);
                ctx.closePath();
            }
            var angle2 = Math.atan2(h, -w);
            var nx2 = -Math.sin(angle2) * bw / 2;
            var ny2 = Math.cos(angle2) * bw / 2;
            if (hasDiagUp) {
                ctx.moveTo(w + nx2, ny2);
                ctx.lineTo(nx2, h + ny2);
                ctx.lineTo(-nx2, h - ny2);
                ctx.lineTo(w - nx2, -ny2);
                ctx.closePath();
            }
            ctx.clip();
        } else {
            if (hasTop || (fe && !pv))
                ctx.rect(0, 0, w, bw);
            if (hasBottom && !fe)
                ctx.rect(0, h - bw, w, bw);
            if (hasLeft || (fe && pv))
                ctx.rect(0, 0, bw, h);
            if (hasRight && !fe)
                ctx.rect(w - bw, 0, bw, h);
            if (hasCenter) {
                if (!pv) ctx.rect((w - bw) / 2, 0, bw, h);
                else ctx.rect(0, (h - bw) / 2, w, bw);
            }
            if (hasCenterH) {
                if (!pv) ctx.rect(0, (h - bw) / 2, w, bw);
                else ctx.rect((w - bw) / 2, 0, bw, h);
            }
            ctx.clip();
        }

        // Draw 6 rainbow bands
        var n = 6, bandH = h / n;

        if (nyanStyle === "wave") {
            var colors = nyanColors;
            var amp = Math.max(3, h * 0.08);
            var freq = Math.PI * 4 / w;
            var stp = Math.max(2, Math.floor(w / 30));
            var phase = nyanScroll * Math.PI * 8;
            for (var i = 0; i < n; i++) {
                ctx.fillStyle = Qt.rgba(colors[i].r, colors[i].g, colors[i].b, 1);
                ctx.beginPath();
                if (i === 0) {
                    ctx.moveTo(0, -amp);
                    ctx.lineTo(w, -amp);
                } else {
                    for (var x = 0; x <= w; x += stp) {
                        var y = i * bandH + Math.sin(x * freq + phase + i * 0.8) * amp;
                        if (x === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                    }
                }
                if (i === n - 1) {
                    ctx.lineTo(w, h + amp);
                    ctx.lineTo(0, h + amp);
                } else {
                    var bi = i + 1;
                    for (var x2 = w; x2 >= 0; x2 -= stp) {
                        var y2 = bi * bandH + Math.sin(x2 * freq + phase + bi * 0.8) * amp;
                        ctx.lineTo(x2, y2);
                    }
                }
                ctx.closePath();
                ctx.fill();
            }
        } else if (nyanStyle === "original") {
            var oAmp = Math.max(2, Math.min(h * 0.06, 4));
            var dir = (nyanStep % 2 === 0) ? 1 : -1;
            for (var k = 0; k < n; k++) {
                var yOff = (k % 2 === 0 ? 1 : -1) * oAmp * dir;
                ctx.fillStyle = Qt.rgba(nyanColors[k].r, nyanColors[k].g, nyanColors[k].b, 1);
                ctx.fillRect(0, k * bandH + yOff, w, bandH + 1);
            }
        } else {
            // Flat: color-shifting bands
            var offset = nyanWaveOffset;
            for (var j = 0; j < n; j++) {
                var ci = (j + nyanStep + offset) % n;
                ctx.fillStyle = Qt.rgba(nyanColors[ci].r, nyanColors[ci].g, nyanColors[ci].b, 1);
                ctx.fillRect(0, j * bandH, w, bandH + 1);
            }
        }

        ctx.restore();
    }
}
