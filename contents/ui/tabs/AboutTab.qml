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
        anchors.margins: Kirigami.Units.largeSpacing * 2
        spacing: Kirigami.Units.largeSpacing

        // ── Header: logo + name/version ──
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                source: Qt.resolvedUrl("../../icons/logo.svg")
                Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                Layout.preferredHeight: Kirigami.Units.iconSizes.huge
            }

            ColumnLayout {
                spacing: 0
                Controls.Label {
                    text: i18n("Task Manager Colors")
                    font.bold: true
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.6
                }
                Controls.Label {
                    text: i18n("Version %1", Plasmoid.metaData.version || "1.0.0")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }
            }
        }

        Item { height: Kirigami.Units.largeSpacing }

        // ── Description ──
        Controls.Label {
            text: i18n("Per-application and per-window color overlays for the Plasma task manager.")
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Item { height: Kirigami.Units.largeSpacing }

        // ── Author card ──
        Rectangle {
            Layout.preferredWidth: authorColumn.implicitWidth + Kirigami.Units.largeSpacing * 4
            implicitHeight: authorColumn.implicitHeight + Kirigami.Units.largeSpacing * 4
            Layout.alignment: Qt.AlignHCenter
            radius: Kirigami.Units.smallSpacing
            color: Qt.rgba(
                Kirigami.Theme.backgroundColor.r,
                Kirigami.Theme.backgroundColor.g,
                Kirigami.Theme.backgroundColor.b,
                0.5
            )
            border.color: Qt.rgba(
                Kirigami.Theme.textColor.r,
                Kirigami.Theme.textColor.g,
                Kirigami.Theme.textColor.b,
                0.08
            )
            border.width: 1

            ColumnLayout {
                id: authorColumn
                anchors.centerIn: parent
                spacing: 2

                Controls.Label {
                    text: "David DIVERRES"
                    font.bold: true
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
                Controls.Label {
                    text: "<a href=\"https://store.kde.org/p/2351299\">KDE Store</a>"
                    onLinkActivated: (link) => Qt.openUrlExternally(link)
                    Layout.alignment: Qt.AlignHCenter
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                        acceptedButtons: Qt.NoButton
                    }
                }
                Controls.Label {
                    text: "© 2026 ComExpertise · GPL-2.0-or-later"
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        Item { height: Kirigami.Units.largeSpacing }

        // ── Buy me a coffee ──
        Controls.Label {
            text: i18n("Enjoying this plasmoid? Support its development!")
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        Controls.Label {
            text: i18n("This plasmoid is developed and maintained on my free time. If you find it useful, a small donation helps keep it going!")
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: bmcRow.implicitWidth + Kirigami.Units.largeSpacing * 2
            Layout.preferredHeight: bmcRow.implicitHeight + Kirigami.Units.mediumSpacing * 2
            radius: Kirigami.Units.smallSpacing
            color: bmcMouse.containsMouse ? "#ffe033" : "#FD0"

            RowLayout {
                id: bmcRow
                anchors.centerIn: parent
                spacing: Kirigami.Units.smallSpacing

                Image {
                    source: Qt.resolvedUrl("../../icons/bmc.svg")
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    fillMode: Image.PreserveAspectFit
                }

                Controls.Label {
                    text: i18n("Buy me a coffee")
                    color: "#0D0C22"
                    font.bold: true
                }
            }

            MouseArea {
                id: bmcMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally("https://buymeacoffee.com/comxd")
            }
        }

        Item { Layout.fillHeight: true }
    }
}
