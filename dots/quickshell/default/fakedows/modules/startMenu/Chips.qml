import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.widgets.fakedows
import QtQuick.Controls

Row {
    spacing: 4
    Rectangle {
        color: "#a6a5a1"
        implicitHeight: 32
        implicitWidth: 40
        radius: 16
        border {
            color: "#3d3d3d"
            width: 1
        }
        StyledText {
            color: "black"
            font.pixelSize: 13
            anchors.centerIn: parent
            text: "All"
            font.weight: 650
        }
    }
    Rectangle {
        color: "#313131"
        implicitHeight: 32
        implicitWidth: 56
        radius: 16
        border {
            color: "#3d3d3d"
            width: 1
        }
        StyledText {
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 13
            text: "Apps"
            font.weight: 650
        }
    }
    Rectangle {
        color: "#313131"
        implicitHeight: 32
        implicitWidth: 96
        radius: 16
        border {
            color: "#3d3d3d"
            width: 1
        }
        StyledText {
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 13
            text: "Documents"
            font.weight: 650
        }
    }
    Rectangle {
        color: "#313131"
        implicitHeight: 32
        implicitWidth: 52
        radius: 16
        border {
            color: "#3d3d3d"
            width: 1
        }
        StyledText {
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 13
            text: "Web"
            font.weight: 650
        }
    }
    Rectangle {
        color: "#313131"
        implicitHeight: 32
        implicitWidth: 76
        radius: 16
        border {
            color: "#3d3d3d"
            width: 1
        }
        StyledText {
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 13
            text: "Settings"
            font.weight: 650
        }
    }
    Rectangle {
        color: "#313131"
        implicitHeight: 32
        implicitWidth: 66
        radius: 16
        border {
            color: "#3d3d3d"
            width: 1
        }
        StyledText {
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 13
            text: "People"
            font.weight: 650
        }
    }
    Rectangle {
        color: "#313131"
        implicitHeight: 32
        implicitWidth: 70
        radius: 16
        border {
            color: "#3d3d3d"
            width: 1
        }
        StyledText {
            color: "white"
            anchors.centerIn: parent
            text: "Folders"
            font.pixelSize: 13
            font.weight: 650
        }
    }
    Rectangle {
        color: "#313131"
        implicitHeight: 32
        implicitWidth: 66
        radius: 16
        border {
            color: "#3d3d3d"
            width: 1
        }
        StyledText {
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: 13
            text: "Photos"
            font.weight: 650
        }
    }
    Item {
        implicitWidth: 4
        implicitHeight: 32
    }
    Item {
        implicitWidth: 32
        implicitHeight: 32

        Rectangle {
            anchors.fill: parent
            radius: 16
            opacity: 0
            color: "#363636"
            Behavior on opacity { NumberAnimation{duration: 150; easing.type: Easing.InOutQuad} }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    parent.opacity = 1
                }
                onExited: {
                    parent.opacity = 0
                }
            }
        }
        StyledText {
            anchors.centerIn: parent
            text: ""
            font.pixelSize: 22
            color: "white"
        }
    }

}
