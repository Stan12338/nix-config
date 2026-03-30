import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.widgets
import qs.services
import qs.services.niri

ColumnLayout{

    spacing: 0
    Rectangle {
        radius: 4
        color: "#a6a5a1"
        border.width: 1
        border.color: "#adaca8"
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        RowLayout {
            anchors.fill: parent
            spacing: 0
            Rectangle {
                color: "#a6a5a1"
                topLeftRadius: 4
                bottomLeftRadius:4
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            Rectangle {
                color: "#adaca8"
                implicitWidth: 2
                Layout.fillHeight: true
            }
            Rectangle {
                color: "#a6a5a1"
                topRightRadius: 4
                bottomRightRadius:4
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 8
            text: "Minions"
            color: "white"
            font.pixelSize: 12
        }
    }
}
