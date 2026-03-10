import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.services
import qs.services.niri
import qs.widgets

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData

        id: osd
        screen: modelData
        anchors {
            bottom: true
            left: true
            right: true
        }
        margins {
            left: 0
            right: 0
            bottom: Appearance.barEdges ? 12 : 0
        }

        implicitHeight: 180
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        color: "transparent"

        visible: true

        property bool isShowing: false
        property real hideDelay: 1000

        property bool isFocusedMonitor: {
            if (Compositor.compositor === "hyprland") {
                return Hyprland.focusedMonitor?.name === modelData.name
            } else if (Compositor.compositor === "niri") {
                return (Niri.focusedWorkspace?.output ?? "") === modelData.name
            }
        }


        Region {
            id: emptyRegion
            item: Item {}
        }

        mask: emptyRegion

        Timer {
            id: hideTimer
            interval: hideDelay
            repeat: false
            onTriggered: {
                isShowing = false
            }
        }

        property var audioTarget: Volume.defaultSpeaker?.audio ?? null


        onAudioTargetChanged: {
            if (audioTarget) {
                audioConnection.target = audioTarget
            }
        }

        Connections {
            id: audioConnection
            target: null

            function onVolumeChanged() {
                showOSD()
            }

            function onMutedChanged() {
                showOSD()
            }
        }

        Component.onCompleted: {
            if (Volume.defaultSpeaker?.audio) {
                audioConnection.target = Volume.defaultSpeaker.audio
            }
        }

        function showOSD() {
            hideTimer.restart()
            if (!isShowing) {
                isShowing = true
            }
        }

        Item {
            id: popupContainer
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: content.width
            height: 150

            visible: isFocusedMonitor

            PopupShape {
                id: content
                anchors.bottom: parent.bottom

                anchors.horizontalCenter: parent.horizontalCenter

                width: 400
                height: (isShowing && isFocusedMonitor) ? 72 : 0

                style: 1
                alignment: 4 // Bottom alignment (attachedBottom)
                radius: 24
                color: Appearance.colors.cSurfaceContainerLowest

                Behavior on height {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                Item {
                    anchors.fill: parent
                    anchors.topMargin: 8
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.bottomMargin: 32

                    opacity: (isShowing && isFocusedMonitor) ? 1 : 0
                    visible: opacity > 0
                    scale: (isShowing && isFocusedMonitor) ? 1 : 0.95

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 350
                            easing.type: Easing.OutQuad
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 350
                            easing.type: Easing.OutCubic
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 16

                        StyledText {
                            id: volumeIcon
                            text: {
                                const vol = Volume.defaultSpeaker?.audio.volume ?? 0
                                const muted = Volume.defaultSpeaker?.audio.muted ?? false

                                if (muted || vol === 0) return "󰖁"
                                if (vol < 0.33) return "󰕿"
                                if (vol < 0.66) return "󰖀"
                                return "󰕾"
                            }
                            color: Appearance.colors.cPrimary
                            font.pixelSize: 32
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4

                            StyledText {
                                text: {
                                    const muted = Volume.defaultSpeaker?.audio.muted ?? false
                                    if (muted) return "Muted"
                                    return "Volume: " + Math.round((Volume.defaultSpeaker?.audio.volume ?? 0) * 100) + "%"
                                }
                                color: Appearance.colors.cPrimary
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 8
                                    radius: 4
                                    color: Appearance.colors.cSurfaceVariant

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: {
                                            const vol = Volume.defaultSpeaker?.audio.volume ?? 0
                                            const muted = Volume.defaultSpeaker?.audio.muted ?? false
                                            if (muted) return 0
                                            return Math.min(vol / Volume.maxVolume, 1.0) * parent.width
                                        }
                                        height: parent.height
                                        radius: 4
                                        color: Appearance.colors.cPrimary

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 100
                                                easing.type: Easing.OutQuad
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
