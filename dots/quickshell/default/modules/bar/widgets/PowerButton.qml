import QtQuick
import Quickshell
import qs.config
import qs.widgets

Item {
    id: root
    implicitWidth: 32
    implicitHeight: 32
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
        id: powerBg
        implicitWidth: 32
        implicitHeight: 32
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter 
        anchors.horizontalCenter: parent.horizontalCenter
        color: mouse.containsMouse ? Appearance.colors.cPrimary : Appearance.colors.cSurfaceContainer

        StyledText {
            id: powerText
            anchors.centerIn: parent
            text: "⏻"
            color: mouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
            font.pixelSize: 16
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true

            // onEntered: {
            //     powerBg.color = Appearance.colors.cPrimary
            //     powerText.color = Appearance.colors.cOnPrimary
            // }
            // onExited: {
            //     powerBg.color = Appearance.colors.cSurfaceContainer
            //     powerText.color = Appearance.colors.cPrimary
            // }

            onClicked: {
                Quickshell.execDetached(["qs", "ipc", "call", "powermenu", "toggle"])
            }
        }
    }
}
