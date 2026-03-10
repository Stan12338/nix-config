import QtQuick
import Quickshell
import qs.config
import qs.widgets

Item {
    id: root
    implicitWidth: 72
    implicitHeight: 32
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
        id: openControlPanelBg
        implicitWidth: 72
        implicitHeight: 32
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter 
        anchors.horizontalCenter: parent.horizontalCenter
        color: mouse.containsMouse ? Appearance.colors.cPrimary : Appearance.colors.cSurfaceContainer

        Row {
            id: iconRow
            anchors.centerIn: parent
            spacing: 16

            StyledText {
                id: wifiText
                text: "󰤨"
                color: mouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
                font.pixelSize: 16
                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            }

            StyledText {
                id: bluetoothText
                text: ""
                color: mouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
                font.pixelSize: 16
                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            }
        }

        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true

            // onEntered: {
            //     openControlPanelBg.color = Appearance.colors.cPrimary
            //     wifiText.color = Appearance.colors.cOnPrimary
            //     bluetoothText.color = Appearance.colors.cOnPrimary
            // }
            // onExited: {
            //     openControlPanelBg.color = Appearance.colors.cSurfaceContainer
            //     wifiText.color = Appearance.colors.cPrimary
            //     bluetoothText.color = Appearance.colors.cPrimary
            // }

            onClicked: {
                Quickshell.execDetached(["qs", "ipc", "call", "controlpanel", "toggle"])
            }
        }
    }
}
