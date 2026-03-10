/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Icon dominant color extraction via Kirigami.ImageColors.
    Passes QIcon object directly to ImageColors, which converts it
    to pixmap → QImage in C++ — no scene graph rendering needed.
*/

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: iconExtractor

    visible: false
    width: 0; height: 0

    property string pendingAppId: ""
    property var pendingOverlay: null
    property bool busy: false

    // Emitted when extraction succeeds — parent should wire this to close pickers
    signal colorExtracted()

    // Emitted with the result so parent can apply it
    signal appColorExtracted(string appId, string hex)
    signal windowColorExtracted(var overlay, string hex)

    function extractForApp(appId, iconName) {
        if (busy) return;
        busy = true;
        pendingAppId = appId;
        pendingOverlay = null;
        busyTimeout.restart();
        imageColors.source = iconName;
    }

    function extractForWindow(overlay, iconName) {
        if (busy) return;
        busy = true;
        pendingAppId = "";
        pendingOverlay = overlay;
        busyTimeout.restart();
        imageColors.source = iconName;
    }

    function colorToHex(c) {
        let r = Math.round(c.r * 255);
        let g = Math.round(c.g * 255);
        let b = Math.round(c.b * 255);
        return "#" + ((1 << 24) | (r << 16) | (g << 8) | b).toString(16).slice(1);
    }

    function _reset() {
        busyTimeout.stop();
        pendingAppId = "";
        pendingOverlay = null;
        busy = false;
    }

    // Safety timeout — reset busy if paletteChanged never fires
    Timer {
        id: busyTimeout
        interval: 3000
        repeat: false
        onTriggered: {
            // Emit colorExtracted so picker closes (avoids silent no-op)
            iconExtractor.colorExtracted();
            iconExtractor._reset();
        }
    }

    Kirigami.ImageColors {
        id: imageColors
        // source is set dynamically to QIcon object
        // ImageColors converts QIcon → pixmap(128x128) → QImage in C++

        onPaletteChanged: {
            if (!iconExtractor.busy) return;

            let c = imageColors.dominant;
            if (!c) {
                iconExtractor._reset();
                return;
            }

            let hex = iconExtractor.colorToHex(c);

            try {
                if (iconExtractor.pendingOverlay && iconExtractor.pendingOverlay.parent) {
                    iconExtractor.windowColorExtracted(iconExtractor.pendingOverlay, hex);
                } else if (iconExtractor.pendingAppId) {
                    iconExtractor.appColorExtracted(iconExtractor.pendingAppId, hex);
                }
                iconExtractor.colorExtracted();
            } catch (e) {
                // Overlay was destroyed during async extraction — ignore
            }

            iconExtractor._reset();
        }
    }
}
