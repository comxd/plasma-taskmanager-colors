/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Icon dominant color extraction via Kirigami.ImageColors.
    Passes QIcon object directly to ImageColors, which converts it
    to pixmap → QImage in C++ — no scene graph rendering needed.
*/

import QtQuick
import org.kde.kirigami as Kirigami
import "../utils/colorUtils.js" as ColorUtils

Item {
    id: iconExtractor

    visible: false
    width: 0; height: 0

    property string pendingAppId: ""
    property string pendingMatch: ""
    property bool pendingIsWindow: false
    property bool busy: false

    // Emitted when extraction succeeds — parent should wire this to close pickers
    signal colorExtracted()

    // Emitted with the result so parent can apply it
    signal appColorExtracted(string appId, string hex)
    signal windowColorExtracted(string appId, string match, string hex)

    function extractForApp(appId, iconName) {
        if (busy) return;
        busy = true;
        pendingAppId = appId;
        pendingIsWindow = false;
        busyTimeout.restart();
        imageColors.source = iconName;
    }

    function extractForWindow(appId, match, iconName) {
        if (busy) return;
        busy = true;
        pendingAppId = appId;
        pendingMatch = match;
        pendingIsWindow = true;
        busyTimeout.restart();
        imageColors.source = iconName;
    }

    function _reset() {
        busyTimeout.stop();
        pendingAppId = "";
        pendingMatch = "";
        pendingIsWindow = false;
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

            let hex = ColorUtils.colorToHex(c);

            try {
                if (iconExtractor.pendingIsWindow) {
                    iconExtractor.windowColorExtracted(iconExtractor.pendingAppId, iconExtractor.pendingMatch, hex);
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
