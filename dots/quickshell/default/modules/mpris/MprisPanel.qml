import QtQuick
import QtQuick.Controls
import Quickshell
import qs.widgets
import qs.config
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.services.niri

Scope {
    id: mprisPanelRoot

    QtObject {
        id: sharedState
        property bool isOpen: false
        property string openedOnMonitor: ""
    }

    IpcHandler {
        id: ipc
        target: "mprispanel"
        function toggle() {
            Quickshell.execDetached(["qs", "ipc", "call", "controlpanel", "close"])
            if (Compositor.compositor === "hyprland") {
                sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
            } else if (Compositor.compositor === "niri") {
                sharedState.openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
            }
            sharedState.isOpen = !sharedState.isOpen
        }
        function open() {
            Quickshell.execDetached(["qs", "ipc", "call", "controlpanel", "close"])
            if (Compositor.compositor === "hyprland") {
                sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
            } else if (Compositor.compositor === "niri") {
                sharedState.openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
            }
            sharedState.isOpen = true
        }
        function close() {
            sharedState.isOpen = false
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            id: panel
            screen: modelData

            anchors {
                top: true
                right: true
                left: true
                bottom: true
            }
            margins.top: Appearance.barEdges ? 40 : 48
            color: "transparent"

            readonly property int slideDuration: 350

            property bool shouldShow: modelData.name === sharedState.openedOnMonitor

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            mask: null

            Timer {
                id: closeDelayTimer
                interval: panel.slideDuration + 100
                repeat: false
                onTriggered: {
                    panel.WlrLayershell.layer = WlrLayer.Background
                    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                    panel.mask = null
                }
            }

            Connections {
                target: sharedState
                function onIsOpenChanged() {
                    if (sharedState.isOpen) {
                        closeDelayTimer.stop()
                        panel.WlrLayershell.layer = WlrLayer.Top
                        panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
                        panel.mask = null
                        if (shouldShow) {
                            focusScope.forceActiveFocus()
                        }
                    } else {
                        panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                        closeDelayTimer.start()
                    }
                }
            }

            function closePanel() {
                sharedState.isOpen = false
            }

            FocusScope {
                id: focusScope
                anchors.fill: parent
                focus: true

                visible: shouldShow

                Keys.onEscapePressed: {
                    panel.closePanel()
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: sharedState.isOpen
                    onClicked: {
                        panel.closePanel()
                    }
                }

                Item {
                    id: popupContainer
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: 72
                    width: content.width
                    height: 640

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: sharedState.isOpen && shouldShow
                    }

                    PopupShape {
                        id: content
                        anchors.top: parent.top
                        anchors.right: parent.right

                        implicitWidth: 420
                        implicitHeight: (sharedState.isOpen && shouldShow) ? 640 : 0

                        style: 1
                        alignment: 0
                        radius: 24
                        color: Appearance.colors.cSurfaceContainerLowest

                        Behavior on implicitHeight {
                            NumberAnimation {
                                duration: panel.slideDuration
                                easing.type: Easing.OutCubic
                            }
                        }

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 24
                            anchors.rightMargin: 24
                            anchors.bottomMargin: 24

                            opacity: (sharedState.isOpen && shouldShow) ? 1 : 0
                            visible: opacity > 0
                            scale: (sharedState.isOpen && shouldShow) ? 1 : 0.95

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 350
                                    easing.type: Easing.OutQuad
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: panel.slideDuration
                                    easing.type: Easing.OutCubic
                                }
                            }

                            MprisContent {
                                id: mprisContent
                                anchors.fill: parent
                            }
                        }
                    }
                }
            }
        }
    }
}
