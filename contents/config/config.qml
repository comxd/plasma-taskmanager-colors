import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: Qt.resolvedUrl("../icons/icon.svg")
        source: "configGeneral.qml"
    }
}
