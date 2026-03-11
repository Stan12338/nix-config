import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Wayland
import QtMultimedia
import qs.config

Scope {
    id: root
    property var fileUrl: Appearance.wallpaper
    property bool isVideo: false

    function updateFileType() {
        if (!fileUrl) {
            isVideo = false
            return
        }

        const path = fileUrl.toString().toLowerCase()
        const videoExtensions = ['.mp4', '.mkv', '.webm', '.avi', '.mov', '.flv', '.wmv', '.m4v', '.mpg', '.mpeg']
        isVideo = videoExtensions.some(ext => path.endsWith(ext))
    }

    Component.onCompleted: {
        if (Appearance.wallpaper) {
            fileUrl = Appearance.wallpaper
            updateFileType()
        }
    }

    Connections {
        target: Appearance
        function onWallpaperChanged() {
            root.fileUrl = Appearance.wallpaper
            root.updateFileType()
        }
    }

    IpcHandler {
        id: ipc
        target: "wallpaper"
        function set(file: string) {
            fileUrl = file
            updateFileType()
            Appearance.setWallpaper(file)
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: panelWindow
                required property var modelData
                screen: modelData
                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                exclusionMode: ExclusionMode.Ignore
                mask: Region {}
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Background
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                Loader {
                    anchors.fill: parent
                    active: true
                    sourceComponent: root.isVideo ? video : image
                }

                Component {
                    id: video
                    Video {
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectCrop
                        source: "file://" +root.fileUrl
                        loops: MediaPlayer.Infinite
                        autoPlay: true
                        muted: true
                    }
                }

                Component {
                    id: image
                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        source: root.fileUrl
                        sourceSize.width: panelWindow.width
                        sourceSize.height: panelWindow.height
                        opacity: 1
                        Image {
                            id: wallpaper
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            source: root.fileUrl

                            sourceSize.width: panelWindow.width
                            sourceSize.height: panelWindow.height
                            opacity: 1

                            Behavior on source {
                                SequentialAnimation {
                                    NumberAnimation {
                                        target: wallpaper
                                        property: "opacity"
                                        to: 0
                                        duration: 250
                                        easing.type: Easing.InOutQuad
                                    }

                                    PropertyAction {}

                                    NumberAnimation {
                                        target: wallpaper
                                        property: "opacity"
                                        to: 1
                                        duration: 250
                                        easing.type: Easing.InOutQuad
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
