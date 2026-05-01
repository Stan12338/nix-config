import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets

Item {
    id: root
    implicitWidth: 200
    implicitHeight: 32
    anchors.verticalCenter: parent.verticalCenter


    Rectangle {
        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        id: pillBg
        anchors.fill: parent
        radius: height / 2
        color: mouse.containsMouse ? Appearance.colors.cPrimary : Appearance.colors.cSurfaceContainer

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6

            StyledText {
                id: clockText
                text: "󱐿"
                color: mouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
                font.pixelSize: 14
            }

            StyledText {
                id: dayText
                text: Time.format("ddd")
                color: mouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
                font.pixelSize: 14
            }

            StyledText {
                id: timeText
                text: Time.format("HH:mm")
                color: mouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
                font.pixelSize: 14
            }
            StyledText {
                id: bellText
                text: "󰂚"
                color: mouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
                font.pixelSize: 14
            }
            StyledText {
                id: notifText
                text: {
                    if (NotifServer.unreadCount > 0 && NotifServer.unreadCount < 100) {
                        return Math.min(99, NotifServer.unreadCount) + " unread"
                    } else if (NotifServer.unreadCount > 99) {
                        return "99+ unread"
                    } else {
                        return "no notifs"
                    }
                }
                color: mouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
                font.pixelSize: 14
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            dayText.text = Time.format("ddd")
            timeText.text = Time.format("HH:mm")
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            Quickshell.execDetached(["qs", "ipc", "call", "notifpanel", "toggle"])
        }
    }
}
