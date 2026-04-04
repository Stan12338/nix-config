import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.widgets.fakedows
Item {
    property string icon
    property var command
    Layout.fillWidth: true
    Layout.preferredHeight: width
    Rectangle {
        anchors.fill: parent
        radius: 4
        color: "#383838"
        opacity: 0
        Behavior on opacity { NumberAnimation{duration: 150; easing.type: Easing.InOutQuad} }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: icon != null
            onEntered: {
                if (icon != "") {
                    parent.opacity = 1
                }

            }
            onExited: {
                if (icon != "") {
                    parent.opacity = 0
                }
            }
            onClicked: {
                if (icon != "") {
                    Quickshell.execDetached(command)
                    Quickshell.execDetached(["qs", "ipc", "call", "startmenu", "close"])
                }

            }
        }

    }
    Image {
        source: icon
        sourceSize.width: 36
        sourceSize.height: 36
        anchors.centerIn: parent
    }
}
