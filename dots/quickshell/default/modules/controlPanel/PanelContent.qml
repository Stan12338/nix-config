import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config

Item {
    id: panelRoot
    anchors.fill: parent

    property string currentPage: "Main"
    property string prevPage: "Main"

    function setCurrentPage(page) {
        prevPage = currentPage
        currentPage = page
    }

    Loader {
        id: pageLoader
        anchors.fill: parent

        sourceComponent: {
            switch(panelRoot.currentPage) {
                case "Wifi": return wifiComponent
                case "Bluetooth": return bluetoothComponent
                default: return mainContentComponent
            }
        }

        onLoaded: {
            if (item && item.panelRef !== undefined) {
                item.panelRef = panelRoot
            }
        }
    }

    Component {
        id: mainContentComponent
        MainContent { }
    }

    Component {
        id: wifiComponent
        WifiPage { }
    }

    Component {
        id: bluetoothComponent
        BluetoothPage { }
    }
}
