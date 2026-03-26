/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Nyan Cat tab: speed, style, FPS, animated preview.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Flickable {
    id: nyanTab

    // Nyan animation state from root (for preview)
    required property var nyanColors
    required property int nyanStep
    required property real nyanScroll

    contentWidth: width
    contentHeight: nyanColumn.implicitHeight + nyanColumn.y + Kirigami.Units.mediumSpacing
    clip: true
    flickableDirection: Flickable.VerticalFlick

    Controls.ScrollBar.vertical: Controls.ScrollBar {
        id: nyanScrollBar
        policy: Controls.ScrollBar.AsNeeded
    }

    ColumnLayout {
        id: nyanColumn
        x: Kirigami.Units.mediumSpacing
        y: Kirigami.Units.mediumSpacing
        width: parent.width - x - (nyanScrollBar.visible ? nyanScrollBar.width + Kirigami.Units.smallSpacing : Kirigami.Units.mediumSpacing)
        spacing: Kirigami.Units.smallSpacing

        Controls.Label {
            text: i18n("Configure the rainbow animation effect. Enable it per-app using the switch next to each color button in the Applications tab.")
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.Wrap; Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing
        }

        Item { height: Kirigami.Units.smallSpacing; width: 1 }
        Kirigami.Separator { Layout.fillWidth: true }
        Item { height: Kirigami.Units.smallSpacing; width: 1 }

        // -- Speed slider --
        Controls.Label { text: i18n("Speed"); font.bold: true }
        RowLayout {
            Layout.fillWidth: true
            Controls.Slider {
                id: nyanSpeedSlider; Layout.fillWidth: true
                from: 0.5; to: 10; stepSize: 0.5
                value: plasmoid.configuration.rainbowSpeed
                onMoved: plasmoid.configuration.rainbowSpeed = value
            }
            Controls.Label {
                text: nyanSpeedSlider.value.toFixed(1) + "s"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
            }
        }
        Controls.Label {
            text: i18n("Duration of one full rainbow cycle. Lower = faster.")
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.Wrap; Layout.fillWidth: true
        }

        Kirigami.Separator { Layout.fillWidth: true; Layout.topMargin: 2; Layout.bottomMargin: 2 }

        // -- Style selector --
        Controls.Label { text: i18n("Style"); font.bold: true }
        Controls.ComboBox {
            id: nyanStyleCombo
            Layout.fillWidth: true
            model: [
                { value: "flat", text: i18n("Flat") },
                { value: "wave", text: i18n("Wave") },
                { value: "original", text: i18n("Original") }
            ]
            textRole: "text"
            valueRole: "value"
            onActivated: plasmoid.configuration.rainbowStyle = currentValue
            Component.onCompleted: currentIndex = indexOfValue(plasmoid.configuration.rainbowStyle)
        }
        Controls.Label {
            text: {
                var s = plasmoid.configuration.rainbowStyle;
                if (s === "flat") return i18n("Color-shifting flat bands.");
                if (s === "original") return i18n("Faithful to the original Nyan Cat rainbow: constant-width bands with alternating vertical offset.");
                return i18n("Wavy band edges with flowing animation.");
            }
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.Wrap; Layout.fillWidth: true
        }

        Kirigami.Separator { Layout.fillWidth: true; Layout.topMargin: 2; Layout.bottomMargin: 2 }

        // -- Animation FPS --
        Controls.Label { text: i18n("Animation FPS"); font.bold: true }
        RowLayout {
            Layout.fillWidth: true
            Controls.Slider {
                id: nyanFpsSlider
                Layout.fillWidth: true
                from: 30; to: 500; stepSize: 10
                value: plasmoid.configuration.rainbowFps
                onMoved: plasmoid.configuration.rainbowFps = value
            }
            Controls.Label {
                text: Math.round(1000 / nyanFpsSlider.value) + " fps"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
            }
        }
        Controls.Label {
            text: i18n("Refresh interval in ms. Lower = smoother but more CPU. Default: 150ms (~7 fps).")
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.Wrap; Layout.fillWidth: true
        }

        Kirigami.Separator { Layout.fillWidth: true; Layout.topMargin: 2; Layout.bottomMargin: 2 }

        // -- Animated preview --
        Controls.Label { text: i18n("Preview"); font.bold: true }
        Item {
            Layout.fillWidth: true
            height: Kirigami.Units.gridUnit * 2

            // Border frame
            Rectangle {
                anchors.fill: parent; radius: 4; color: "transparent"
                border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
                border.width: 1; z: 2
            }

            // Flat preview
            Item {
                anchors.fill: parent; clip: true; z: 1
                visible: plasmoid.configuration.rainbowStyle === "flat"
                Repeater {
                    model: 6
                    Rectangle {
                        width: parent.width
                        height: Math.ceil(parent.height / 6) + 1
                        y: index * (parent.height / 6)
                        color: nyanTab.nyanColors[(index + nyanTab.nyanStep) % 6]
                        opacity: plasmoid.configuration.backgroundOpacity
                    }
                }
            }

            // Wave preview
            Item {
                id: wavePreviewClip
                anchors.fill: parent; clip: true; z: 1
                visible: plasmoid.configuration.rainbowStyle === "wave"
                onVisibleChanged: if (visible) wavePreviewCanvas.requestPaint()
                Canvas {
                    id: wavePreviewCanvas
                    width: parent.width * 2; height: parent.height
                    x: -(nyanTab.nyanScroll - Math.floor(nyanTab.nyanScroll)) * parent.width
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset(); ctx.clearRect(0, 0, width, height);
                        var fullW = width, h = height, pw = fullW / 2;
                        if (pw <= 0 || h <= 0) return;
                        var colors = [[1,0,0],[1,0.6,0],[1,1,0],[0.2,1,0],[0,0.6,1],[0.4,0.2,1]];
                        var n = colors.length, bandH = h / n;
                        var amp = Math.max(3, h * 0.08);
                        var freq = Math.PI * 4 / pw;
                        var step = Math.max(2, Math.floor(pw / 30));
                        ctx.globalAlpha = plasmoid.configuration.backgroundOpacity;
                        for (var i = 0; i < n; i++) {
                            ctx.fillStyle = Qt.rgba(colors[i][0], colors[i][1], colors[i][2], 1);
                            ctx.beginPath();
                            if (i === 0) { ctx.moveTo(0, -amp); ctx.lineTo(fullW, -amp); }
                            else { for (var x = 0; x <= fullW; x += step) { var y = i*bandH + Math.sin(x*freq + i*0.8)*amp; if (x===0) ctx.moveTo(x,y); else ctx.lineTo(x,y); } ctx.lineTo(fullW, i*bandH + Math.sin(fullW*freq + i*0.8)*amp); }
                            if (i === n-1) { ctx.lineTo(fullW, h+amp); ctx.lineTo(0, h+amp); }
                            else { var bi=i+1; for (var x = fullW; x >= 0; x -= step) { var y = bi*bandH + Math.sin(x*freq + bi*0.8)*amp; ctx.lineTo(x,y); } ctx.lineTo(0, bi*bandH + Math.sin(bi*0.8)*amp); }
                            ctx.closePath(); ctx.fill();
                        }
                    }
                }
            }

            // Original preview
            Item {
                anchors.fill: parent; clip: true; z: 1
                visible: plasmoid.configuration.rainbowStyle === "original"
                readonly property var origColors: ["#FD1B00", "#FD9B01", "#FDEF01", "#20DB01", "#008AFC", "#6D3FFC"]
                readonly property real amplitude: Math.max(2, Math.min(parent.height * 0.06, 4))
                Repeater {
                    model: 6
                    Rectangle {
                        required property int index
                        width: parent.width
                        height: Math.ceil(parent.height / 6) + 1
                        y: index * (parent.height / 6) + (index % 2 === 0 ? 1 : -1) * parent.amplitude * (nyanTab.nyanStep % 2 === 0 ? 1 : -1)
                        color: parent.origColors[index]
                        opacity: plasmoid.configuration.backgroundOpacity
                    }
                }
            }
        }
    }
}
