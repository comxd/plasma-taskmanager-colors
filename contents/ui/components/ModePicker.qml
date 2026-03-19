/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later

    Searchable color mode picker, designed as a StackLayout page.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents3

ColumnLayout {
    id: modePicker
    spacing: 0

    // ── Required properties ──

    required property string title
    required property string activeMode

    // ── Optional properties ──

    property string disabledMode: ""

    // ── Signals ──

    signal modeSelected(string value)
    signal backRequested()

    // ── Public API ──

    function activate() {
        searchField.text = "";
        filterModel.update();
        searchField.forceActiveFocus();
    }

    // ── Header with back button ──

    PlasmaExtras.PlasmoidHeading {
        Layout.fillWidth: true

        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Button {
                icon.name: mirrored ? "go-next" : "go-previous"
                text: i18n("Back")
                onClicked: modePicker.backRequested()
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: modePicker.title
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                elide: Text.ElideRight
            }

            // Spacer to balance the back button
            Item {
                implicitWidth: Kirigami.Units.gridUnit * 4
            }
        }
    }

    // ── Search field ──

    Controls.TextField {
        id: searchField
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing
        Layout.topMargin: Kirigami.Units.smallSpacing
        placeholderText: i18n("Search mode...")
        onTextChanged: filterModel.update()

        Keys.onEscapePressed: modePicker.backRequested()
    }

    // ── Mode list ──

    PlasmaComponents3.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: Kirigami.Units.smallSpacing

        PlasmaComponents3.ScrollBar.horizontal.policy: PlasmaComponents3.ScrollBar.AlwaysOff

        ListView {
            id: modeListView
            clip: true
            model: filterModel
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds
            Keys.onEscapePressed: modePicker.backRequested()

            delegate: Controls.ItemDelegate {
                width: modeListView.width
                text: model.display
                highlighted: model.value === modePicker.activeMode
                opacity: model.value === modePicker.disabledMode ? 0.4 : 1.0
                onClicked: {
                    if (model.value !== modePicker.disabledMode) {
                        modePicker.modeSelected(model.value);
                        searchField.text = "";
                    }
                }
            }
        }
    }

    // ── Filter model ──

    ListModel {
        id: filterModel

        readonly property var allModes: [
            { value: "frame", text: i18n("Frame (all sides)") },
            { value: "top", text: i18n("Top line") },
            { value: "bottom", text: i18n("Bottom line") },
            { value: "left", text: i18n("Left line") },
            { value: "right", text: i18n("Right line") },
            { value: "top+bottom", text: i18n("Top + Bottom") },
            { value: "left+right", text: i18n("Left + Right") },
            { value: "center", text: i18n("Center \u2502") },
            { value: "center-h", text: i18n("Center \u2500") },
            { value: "background", text: i18n("Background") },
            { value: "background+frame", text: i18n("Background + Frame") },
            { value: "diagonal", text: i18n("Diagonal \\") },
            { value: "diagonal-reverse", text: i18n("Diagonal /") },
            { value: "diagonal-cross", text: i18n("Diagonal \u2715") }
        ]

        function update() {
            clear();
            var search = searchField.text.toLowerCase();
            for (var i = 0; i < allModes.length; i++) {
                var m = allModes[i];
                if (!search || m.text.toLowerCase().indexOf(search) !== -1)
                    append({ value: m.value, display: m.text });
            }
        }

        Component.onCompleted: update()
    }
}
