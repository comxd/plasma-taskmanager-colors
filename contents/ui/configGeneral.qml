/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configPage

    // UI-bound properties
    property alias cfg_isEnabled: enabledCheck.checked
    property string cfg_appColorMap

    // Properties required by Plasma config framework (mapped from main.xml)
    property string cfg_colorMode
    property int cfg_borderRadius
    property bool cfg_autoBorderWidth
    property int cfg_borderWidth
    property bool cfg_minimizedAutoBorderWidth
    property int cfg_minimizedBorderWidth
    property double cfg_backgroundOpacity
    property string cfg_focusedMode
    property string cfg_focusedColorMode
    property bool cfg_focusedAutoBorderWidth
    property int cfg_focusedBorderWidth
    property double cfg_focusedOpacity
    property int cfg_focusedBorderRadius
    property double cfg_minimizedOpacity
    property int cfg_minimizedBorderRadius
    property string cfg_pinnedBehavior
    property double cfg_rainbowSpeed
    property string cfg_rainbowStyle
    property int cfg_rainbowFps
    property bool cfg_hideWidget
    property string cfg_minimizedMode
    property string cfg_minimizedColorMode
    property bool cfg_minimizedDim
    property bool cfg_minimizedDesaturate

    Kirigami.FormLayout {
        id: formLayout

        Controls.CheckBox {
            id: enabledCheck
            Kirigami.FormData.label: i18n("Enable:")
            text: i18n("Enable color overlays")
        }

        // ── Status section ──

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Status")
        }

        Item { width: 1; height: Kirigami.Units.smallSpacing }

        Controls.Label {
            Kirigami.FormData.label: i18n("Colors:")
            text: {
                try {
                    let map = JSON.parse(cfg_appColorMap);
                    let count = Object.keys(map).length;
                    return i18n("%1 application(s) configured", count);
                } catch (e) {
                    return i18n("No colors configured");
                }
            }
        }

        // ── Help section ──

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Help")
        }

        Item { width: 1; height: Kirigami.Units.smallSpacing }

        Controls.Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: i18n("All settings and color management are available in the widget popup. Click the widget icon in the panel to open it.")
            color: Kirigami.Theme.disabledTextColor
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        }
    }
}
