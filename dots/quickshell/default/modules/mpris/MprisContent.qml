import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.config
import qs.widgets
import qs.services
import qs.functions

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        ClippingWrapperRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: width
            radius: 16
            color: Appearance.colors.cSurfaceContainer
            clip: true

            Item {
                anchors.fill: parent
                Image {
                    id: albumArt
                    anchors.fill: parent
                    source: MprisController.activeTrack?.artUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    visible: status === Image.Ready
                }

                StyledText {
                    anchors.centerIn: parent
                    text: "󰝚"
                    font.pixelSize: 96
                    color: Appearance.colors.cOnSurfaceVariant
                    visible: albumArt.status !== Image.Ready
                }
            }


        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            StyledText {
                id: trackTitle
                Layout.fillWidth: true
                text: MprisController.activeTrack?.title ?? "No Track"
                font.pixelSize: 20
                font.weight: Font.Medium
                color: Appearance.colors.cOnSurface
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }

            StyledText {
                id: trackArtist
                Layout.fillWidth: true
                text: MprisController.activeTrack?.artist ?? "No Artist"
                font.pixelSize: 16
                color: Appearance.colors.cOnSurfaceVariant
                elide: Text.ElideRight
            }

            StyledText {
                id: trackAlbum
                Layout.fillWidth: true
                text: MprisController.activeTrack?.album ?? ""
                font.pixelSize: 14
                color: Appearance.colors.cOnSurfaceVariant
                elide: Text.ElideRight
                visible: text !== "" && text !== "Unknown Album"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: MprisController.length > 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 24

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Appearance.colors.cSurfaceContainerHighest

                    Rectangle {
                        width: parent.width * MprisController.progress
                        height: parent.height
                        radius: parent.radius
                        color: Appearance.colors.cPrimary

                        Behavior on width {
                            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                        }
                    }
                }

                Rectangle {
                    id: seekHandle
                    x: (parent.width - width) * MprisController.progress
                    anchors.verticalCenter: parent.verticalCenter
                    width: seekMouse.containsMouse || seekMouse.pressed ? 16 : 12
                    height: width
                    radius: width / 2
                    color: Appearance.colors.cPrimary
                    opacity: MprisController.canSeek ? 1.0 : 0.0
                    scale: seekMouse.pressed ? 1.2 : 1.0

                    Behavior on width {
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }
                }

                MouseArea {
                    id: seekMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: MprisController.canSeek
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: (mouse) => {
                        if (MprisController.canSeek) {
                            const percent = mouse.x / width;
                            MprisController.seekToPercent(percent);
                        }
                    }

                    onPositionChanged: (mouse) => {
                        if (pressed && MprisController.canSeek) {
                            const percent = Math.max(0, Math.min(1, mouse.x / width));
                            MprisController.seekToPercent(percent);
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    text: MprisController.positionString
                    font.pixelSize: 12
                    color: Appearance.colors.cOnSurfaceVariant
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: MprisController.lengthString
                    font.pixelSize: 12
                    color: Appearance.colors.cOnSurfaceVariant
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 24
                color: prevMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer
                opacity: MprisController.canGoPrevious ? 1.0 : 0.4

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: MprisController.canGoPrevious
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: MprisController.previous()
                }

                StyledText {
                    anchors.centerIn: parent
                    text: "󰒮"
                    font.pixelSize: 24
                    color: Appearance.colors.cOnSurface
                }
            }

            Rectangle {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                radius: 32
                color: playMouse.containsMouse ?
                    ColorModifier.colorWithLightness(Appearance.colors.cPrimary, Qt.color(Appearance.colors.cPrimary).hslLightness + 0.05) :
                    Appearance.colors.cPrimary
                opacity: MprisController.canTogglePlaying ? 1.0 : 0.4

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: MprisController.canTogglePlaying
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: MprisController.togglePlaying()
                }

                StyledText {
                    anchors.centerIn: parent
                    text: MprisController.isPlaying ? "󰏤" : "󰐊"
                    font.pixelSize: 32
                    color: Appearance.colors.cOnPrimary
                }
            }

            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 24
                color: nextMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer
                opacity: MprisController.canGoNext ? 1.0 : 0.4

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: MprisController.canGoNext
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: MprisController.next()
                }

                StyledText {
                    anchors.centerIn: parent
                    text: "󰒭"
                    font.pixelSize: 24
                    color: Appearance.colors.cOnSurface
                }
            }
        }


        Item { Layout.fillHeight: true}
    }
    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: parent.width
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: shuffleMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer
            opacity: MprisController.shuffleSupported ? 1.0 : 0.4

            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            MouseArea {
                id: shuffleMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: MprisController.shuffleSupported
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                onClicked: MprisController.setShuffle(!MprisController.hasShuffle)
            }

            StyledText {
                anchors.centerIn: parent
                text: "󰒝"
                font.pixelSize: 18
                color: MprisController.hasShuffle ? Appearance.colors.cPrimary : Appearance.colors.cOnSurface

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
            }
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: loopMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer
            opacity: MprisController.loopSupported ? 1.0 : 0.4

            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            MouseArea {
                id: loopMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: MprisController.loopSupported
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                onClicked: {
                    if (MprisController.loopState === 0) {
                        MprisController.setLoopState(1)
                    } else if (MprisController.loopState === 1) {
                        MprisController.setLoopState(2)
                    } else {
                        MprisController.setLoopState(0)
                    }
                }
            }

            StyledText {
                anchors.centerIn: parent
                text: {
                    if (MprisController.loopState === 1) return "󰑘"
                    if (MprisController.loopState === 2) return "󰑖"
                    return "󰑗"
                }
                font.pixelSize: 18
                color: MprisController.loopState !== 0 ? Appearance.colors.cPrimary : Appearance.colors.cOnSurface

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
}
