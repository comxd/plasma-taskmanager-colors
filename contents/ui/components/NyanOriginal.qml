/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Nyan Cat rainbow background — original mode.
    Constant-width bands with alternating vertical offset (faithful to original Nyan Cat).
*/

import QtQuick

Item {
    id: nyanOriginal

    required property int nyanStep     // root.nyanStep (0-5)
    required property real bgOpacity
    required property bool focusEnhanced
    required property var nyanColors   // 6 Qt.rgba values (may be desaturated)

    clip: true
    readonly property real amplitude: Math.max(2, Math.min(height * 0.06, 4))

    Repeater {
        model: 6
        Rectangle {
            required property int index
            width: nyanOriginal.width
            height: Math.ceil(nyanOriginal.height / 6) + 1
            y: index * (nyanOriginal.height / 6) + (index % 2 === 0 ? 1 : -1) * nyanOriginal.amplitude * (nyanOriginal.nyanStep % 2 === 0 ? 1 : -1)
            color: nyanOriginal.nyanColors[index]
            opacity: nyanOriginal.focusEnhanced ? 0.8 : nyanOriginal.bgOpacity
        }
    }
}
