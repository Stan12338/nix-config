import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets

Item {
    id: root
    implicitWidth: playButtonBg.implicitWidth + playerDetailsBg.implicitWidth + playerRow.spacing
    implicitHeight: 32
    anchors.verticalCenter: parent.verticalCenter

    property var mpris: MprisController



    Row {
        id: playerRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        spacing: 8

        Rectangle {
            id: playButtonBg
            implicitWidth: 32
            implicitHeight: 32
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            color: playMouse.containsMouse ? Appearance.colors.cPrimary : Appearance.colors.cSurfaceContainer

            visible: mpris && mpris.activePlayer !== null

            StyledText {
                id: playText
                anchors.centerIn: parent
                text: mpris.isPlaying ? "" : ""
                color: playMouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
                font.pixelSize: 16
                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            }

            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            MouseArea {
                id: playMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: mpris.canTogglePlaying
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                // onEntered: {
                //     playButtonBg.color = Appearance.colors.cPrimary
                //     playText.color = Appearance.colors.cOnPrimary
                // }
                // onExited: {
                //     playButtonBg.color = Appearance.colors.cSurfaceContainer
                //     playText.color = Appearance.colors.cPrimary
                // }
                onClicked: {
                    mpris.togglePlaying()
                }
            }
        }

        Rectangle {
            id: playerDetailsBg
            implicitWidth: 256
            implicitHeight: 32
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            color: detailsMouse.containsMouse ? Appearance.colors.cPrimary : Appearance.colors.cSurfaceContainer

            visible: mpris && mpris.activePlayer !== null

            StyledText {
                id: playerDetailsText
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 8
                anchors.rightMargin: 8

                text: (mpris && mpris.activeTrack && mpris.activeTrack.title !== "Unknown Title") ?
                      `${mpris.activeTrack.title} - ${mpris.activeTrack.artist}` :
                      "No media playing"

                color: detailsMouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
                font.pixelSize: 14

                elide: Text.ElideRight
                clip: true
                wrapMode: Text.NoWrap

                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            }

            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            MouseArea {
                id: detailsMouse
                anchors.fill: parent
                hoverEnabled: true

                // onEntered: {
                //     playerDetailsBg.color = Appearance.colors.cPrimary
                //     playerDetailsText.color = Appearance.colors.cOnPrimary
                // }
                // onExited: {
                //     playerDetailsBg.color = Appearance.colors.cSurfaceContainer
                //     playerDetailsText.color = Appearance.colors.cPrimary
                // }
                onClicked: {
                    Quickshell.execDetached(["qs", "ipc", "call", "mprispanel", "toggle"])
                }
            }
        }
    }
}
