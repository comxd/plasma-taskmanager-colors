/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Nyan Cat rainbow background — flat mode (pure QML, zero CPU).
    Color-shifting bands via Repeater.
*/

import QtQuick

Item {
    id: nyanFlat

    required property var nyanColors   // root.nyanColors array (6 Qt.rgba values)
    required property int nyanStep     // root.nyanStep (0-5 discrete index)
    required property int nyanWaveOffset
    required property real bgOpacity
    required property bool focusEnhanced
    required property int borderRadius

    clip: true

    Repeater {
        model: 6
        Rectangle {
            width: nyanFlat.width
            height: Math.ceil(nyanFlat.height / 6) + 1
            y: index * (nyanFlat.height / 6)
            radius: index === 0 || index === 5 ? nyanFlat.borderRadius : 0
            color: nyanFlat.nyanColors[(index + nyanFlat.nyanStep + nyanFlat.nyanWaveOffset) % 6]
            opacity: nyanFlat.focusEnhanced ? 0.8 : nyanFlat.bgOpacity
        }
    }
}
