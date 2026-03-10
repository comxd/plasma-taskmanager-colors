/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        Item { Layout.fillHeight: true }

        Kirigami.Icon {
            source: "preferences-desktop-color"
            Layout.preferredWidth: Kirigami.Units.iconSizes.huge
            Layout.preferredHeight: Kirigami.Units.iconSizes.huge
            Layout.alignment: Qt.AlignHCenter
        }

        Controls.Label {
            text: i18n("Task Manager Colors")
            font.bold: true
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.4
            Layout.alignment: Qt.AlignHCenter
        }

        Controls.Label {
            text: i18n("Version %1", Plasmoid.metaData.version || "1.0.0")
            color: Kirigami.Theme.disabledTextColor
            Layout.alignment: Qt.AlignHCenter
        }

        Item { height: Kirigami.Units.largeSpacing; width: 1 }

        Controls.Label {
            text: i18n("Per-application and per-window color overlays for the Plasma task manager.")
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
        }

        Item { height: Kirigami.Units.largeSpacing; width: 1 }

        Controls.Label {
            text: i18n("Author")
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        Controls.Label {
            text: "David DIVERRES"
            Layout.alignment: Qt.AlignHCenter
        }
        Controls.Label {
            text: "<a href=\"mailto:david@comexpertise.com\">david@comexpertise.com</a>"
            onLinkActivated: (link) => Qt.openUrlExternally(link)
            Layout.alignment: Qt.AlignHCenter
            MouseArea {
                anchors.fill: parent
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                acceptedButtons: Qt.NoButton
            }
        }

        Controls.Label {
            text: "<a href=\"https://comexpertise.com\">comexpertise.com</a>"
            onLinkActivated: (link) => Qt.openUrlExternally(link)
            Layout.alignment: Qt.AlignHCenter
            MouseArea {
                anchors.fill: parent
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                acceptedButtons: Qt.NoButton
            }
        }

        Item { height: Kirigami.Units.smallSpacing; width: 1 }

        Controls.Label {
            text: "© 2026 ComExpertise"
            color: Kirigami.Theme.disabledTextColor
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            Layout.alignment: Qt.AlignHCenter
        }
        Controls.Label {
            text: "GPL-2.0-or-later"
            color: Kirigami.Theme.disabledTextColor
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            Layout.alignment: Qt.AlignHCenter
        }

        Item { Layout.fillHeight: true }
    }
}
