import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.widgets
import qs.services
import qs.services.niri
import Quickshell.Services.Pipewire

Scope {
    id: root

    property bool debug: false

    property string state: "main"


    QtObject {
        id: sharedState
        property bool isOpen: false
        property string openedOnMonitor: ""

        function setOpen(open) {
            if (open && !isOpen) {
                if (Compositor.compositor === "hyprland") {
                    openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
                } else if (Compositor.compositor === "niri") {
                    openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
                }
            }
            isOpen = open
            Appearance.controlPanelOpened = open

        }
    }

    IpcHandler {
        target: "control"
        function toggle() { sharedState.setOpen(!sharedState.isOpen) }
        function open()   { sharedState.setOpen(true) }
        function close()  { sharedState.setOpen(false) }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            id: startPanel
            screen: modelData

            anchors { top: true; right: true; left: true; bottom: true }
            color: "transparent"

            readonly property int slideDuration: 200
            readonly property bool shouldShow: modelData.name === sharedState.openedOnMonitor

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            mask: emptyRegion

            Region { id: emptyRegion }

            Timer {
                id: closeDelayTimer
                interval: startPanel.slideDuration + 100
                repeat: false
                onTriggered: {
                    startPanel.WlrLayershell.layer = WlrLayer.Background
                    startPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                    startPanel.mask = emptyRegion
                    root.state = "main"
                }
            }

            Connections {
                target: sharedState
                function onIsOpenChanged() {
                    if (sharedState.isOpen) {
                        closeDelayTimer.stop()
                        startPanel.WlrLayershell.layer = WlrLayer.Top
                        startPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        startPanel.mask = null
                        if (startPanel.shouldShow) focusScope.forceActiveFocus()
                    } else {
                        startPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                        closeDelayTimer.start()
                    }
                }
            }

            FocusScope {
                id: focusScope
                anchors.fill: parent
                focus: true
                visible: startPanel.shouldShow

                Keys.onEscapePressed: sharedState.setOpen(false)

                MouseArea {
                    anchors.fill: parent
                    enabled: sharedState.isOpen
                    onClicked: sharedState.setOpen(false)
                }

                Item {
                    id: popupContainer
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.bottomMargin: 60
                    width: 360
                    height: root.state === "main" ? 386 : 400
                    Behavior on height {NumberAnimation {duration: 150}}
                    opacity: 1

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: sharedState.isOpen && startPanel.shouldShow
                    }

                    Rectangle {
                        id: controlRect
                        anchors.fill: parent
                        clip: true
                        radius: 8
                        color: root.debug ? "white" : "#242424"
                        opacity: root.debug ? 0.3 : 1
                        border { width: 1; color: "#484953" }

                        transform: Translate {
                            y: (sharedState.isOpen && startPanel.shouldShow) ? 0 : controlRect.height + 16
                            Behavior on y {
                                NumberAnimation {
                                    duration: startPanel.slideDuration
                                    easing.type: (sharedState.isOpen && startPanel.shouldShow)
                                        ? Easing.OutQuad : Easing.InQuad
                                }
                            }
                        }

                        Loader {
                            anchors.fill: parent
                            sourceComponent: root.state === "main" ? mainComponent : wifiComponent
                            onItemChanged: {
                                if (item) {
                                    item.wifiClicked.connect(() => {
                                        root.state = "wifi"
                                    })
                                    item.back.connect(() => {
                                        root.state = "main"
                                    })
                                }
                            }
                        }

                        Component {
                            id: mainComponent
                            MainContent {}
                        }
                        Component {
                            id: wifiComponent
                            WifiPanel {}
                        }


                    }
                }
            }
        }
    }
}
