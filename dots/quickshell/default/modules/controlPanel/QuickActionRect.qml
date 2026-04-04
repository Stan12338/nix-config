import Quickshell
import QtQuick
import qs.config
import qs.widgets
import qs.services.niri


Rectangle {
    id:root
    anchors.fill: parent
    // anchors.margins: 8
    radius: 12
    property bool on: {
        if (type === "dnd") {
            return Appearance.silent
        } else if (type === "screenshot") {
            return false
        } else if (type === "bar") {
            return Appearance.barEdges
        } else if (type === "windows") {
            return Appearance.fakedows
        }
    }
    Timer {
        id: fakedowsTimer
        interval: 500
        repeat: false
        onTriggered: {
            Appearance.fakedows = !Appearance.fakedows
        }
    }
    property string type: ""
    color: on ? Appearance.colors.cPrimary : mouse.containsMouse ? Qt.lighter(Appearance.colors.cPrimaryContainer, Appearance.isDark ? 1.5 : 0.9) : Appearance.colors.cPrimaryContainer

    Behavior on color {
        ColorAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
    StyledText {
        anchors.centerIn: parent
        color: on ? Appearance.colors.cOnPrimary : Appearance.colors.cOnPrimaryContainer
        Behavior on color {
            ColorAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
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
                Appearance.barType = Appearance.barType === "default" ? "floating" : "default"
            } else if (type === "windows") {
                root.on = true;
                fakedowsTimer.restart()
            } else if (type === "dnd") {
                Appearance.silent = !Appearance.silent
            }
        }
    }
}
