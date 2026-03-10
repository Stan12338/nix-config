import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets

Item {
    id: root
    implicitWidth: 84
    implicitHeight: 32
    anchors.verticalCenter: parent.verticalCenter


    Rectangle {
        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        id: pillBg
        anchors.fill: parent
        radius: height / 2
        color: Appearance.colors.cSurfaceContainer

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6

            StyledText {
                id: dayText
                text: Time.format("ddd")
                color: Appearance.colors.cPrimary
                font.pixelSize: 14
            }

            StyledText {
                id: timeText
                text: Time.format("HH:mm")
                color: Appearance.colors.cPrimary
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
}
