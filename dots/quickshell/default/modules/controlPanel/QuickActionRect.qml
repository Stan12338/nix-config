import Quickshell
import QtQuick
import qs.config
import qs.widgets
import qs.services.niri


Rectangle {
    anchors.fill: parent
    // anchors.margins: 8
    radius: 8
    property bool on: {
        if (type === "dnd") {
            return false
        } else if (type === "screenshot") {
            return false
        } else if (type === "bar") {
            return Appearance.barEdges
        } else if (type === "windows") {
            return ""
        }
    }
    property string type: ""
    color: on ? Appearance.colors.cPrimary : mouse.containsMouse ? Appearance.colors.cPrimary : Appearance.colors.cPrimaryContainer

    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }
    StyledText {
        anchors.centerIn: parent
        color: on ? Appearance.colors.cOnPrimary : mouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cOnPrimaryContainer
        font.pixelSize: 32
        text: {
            if (type === "dnd") {
                return "󰂛"
            } else if (type === "screenshot") {
                return ""
            } else if (type === "bar") {
                return "󰕮"
            } else if (type === "windows") {
                return ""
            }
        }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (type === "screenshot") {
                Niri.screenshotWindow()
            } else if (type === "bar") {
                Appearance.barEdges = !Appearance.barEdges
            }
        }
    }
}
