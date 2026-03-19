/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Nyan Cat rainbow background — wave mode (pre-rendered Canvas, scrolled).
*/

import QtQuick

Item {
    id: nyanWaveClip

    required property real nyanScroll      // root.nyanScroll (0-1 continuous)
    required property int nyanWaveOffset
    required property real bgOpacity
    required property bool focusEnhanced
    required property var nyanColors       // 6 Qt.rgba values (may be desaturated)

    clip: true

    Canvas {
        id: nyanWaveCanvas
        width: parent.width * 2
        height: parent.height
        x: {
            var total = nyanWaveClip.nyanScroll + nyanWaveClip.nyanWaveOffset / 6.0;
            return -(total - Math.floor(total)) * parent.width;
        }
        property real bgAlpha: nyanWaveClip.focusEnhanced ? 0.8 : nyanWaveClip.bgOpacity
        property var canvasColors: nyanWaveClip.nyanColors
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onBgAlphaChanged: requestPaint()
        onCanvasColorsChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            var fullW = width, h = height, pw = fullW / 2;
            if (pw <= 0 || h <= 0) return;
            var colors = nyanWaveClip.nyanColors;
            var n = colors.length, bandH = h / n;
            var amp = Math.max(3, h * 0.08);
            var freq = Math.PI * 4 / pw;
            var stp = Math.max(2, Math.floor(pw / 30));
            ctx.globalAlpha = bgAlpha;
            for (var i = 0; i < n; i++) {
                ctx.fillStyle = Qt.rgba(colors[i].r, colors[i].g, colors[i].b, 1);
                ctx.beginPath();
                if (i === 0) {
                    ctx.moveTo(0, -amp);
                    ctx.lineTo(fullW, -amp);
                } else {
                    for (var x = 0; x <= fullW; x += stp) {
                        var y = i * bandH + Math.sin(x * freq + i * 0.8) * amp;
                        if (x === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                    }
                    ctx.lineTo(fullW, i * bandH + Math.sin(fullW * freq + i * 0.8) * amp);
                }
                if (i === n - 1) {
                    ctx.lineTo(fullW, h + amp);
                    ctx.lineTo(0, h + amp);
                } else {
                    var bi = i + 1;
                    for (var x2 = fullW; x2 >= 0; x2 -= stp) {
                        var y2 = bi * bandH + Math.sin(x2 * freq + bi * 0.8) * amp;
                        ctx.lineTo(x2, y2);
                    }
                    ctx.lineTo(0, bi * bandH + Math.sin(bi * 0.8) * amp);
                }
                ctx.closePath();
                ctx.fill();
            }
        }
    }
}
