import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.widgets
import qs.services
import qs.services.niri
import Quickshell.Io
import qs.modules.powerMenu.widgets

Scope {

    QtObject {
        id: sharedState
        property bool isOpen: false
        property string openedOnMonitor: ""
        property int selectedIndex: 2  // Start in the middle (Reboot)
    }

    IpcHandler {
        id: ipc
        target: "powermenu"

        function toggle() {
            Quickshell.execDetached(["qs", "ipc", "call", "launcher", "close"])
            if (Compositor.compositor === "hyprland") {
                sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
            } else if (Compositor.compositor === "niri") {
                sharedState.openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
            }
            sharedState.isOpen = !sharedState.isOpen
            if (sharedState.isOpen) {
                sharedState.selectedIndex = 2
            }
        }

        function open() {
            Quickshell.execDetached(["qs", "ipc", "call", "launcher", "close"])
            if (Compositor.compositor === "hyprland") {
                sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
            } else if (Compositor.compositor === "niri") {
                sharedState.openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
            }
            sharedState.isOpen = true
            sharedState.selectedIndex = 2
        }

        function close() {
            sharedState.isOpen = false
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            id: powerMenuPanel
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
                interval: powerMenuPanel.slideDuration + 100
                repeat: false
                onTriggered: {
                    powerMenuPanel.WlrLayershell.layer = WlrLayer.Background
                    powerMenuPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                    powerMenuPanel.mask = null
                }
            }

            Connections {
                target: sharedState

                function onIsOpenChanged() {
                    if (sharedState.isOpen) {
                        closeDelayTimer.stop()
                        powerMenuPanel.WlrLayershell.layer = WlrLayer.Top
                        powerMenuPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        powerMenuPanel.mask = null

                        if (shouldShow) {
                            focusScope.forceActiveFocus()
                        }
                    } else {
                        powerMenuPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
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

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        powerMenuPanel.closePanel()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
                        if (sharedState.selectedIndex > 0) {
                            sharedState.selectedIndex--
                        } else {
                            sharedState.selectedIndex = 4
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
                        if (sharedState.selectedIndex < 4) {
                            sharedState.selectedIndex++
                        } else {
                            sharedState.selectedIndex = 0
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_K || event.key === Qt.Key_Down) {
                        if (sharedState.selectedIndex < 4) {
                            sharedState.selectedIndex++
                        } else {
                            sharedState.selectedIndex = 0
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_J || event.key === Qt.Key_Up) {
                        if (sharedState.selectedIndex > 0) {
                            sharedState.selectedIndex--
                        } else {
                            sharedState.selectedIndex = 4
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (sharedState.selectedIndex === 0) {
                            lockItem.clicked()
                        } else if (sharedState.selectedIndex === 1) {
                            logoutItem.clicked()
                        } else if (sharedState.selectedIndex === 2) {
                            rebootItem.clicked()
                        } else if (sharedState.selectedIndex === 3) {
                            powerItem.clicked()
                        } else if (sharedState.selectedIndex === 4) {
                            suspendItem.clicked()
                        }
                        event.accepted = true
                        return
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: sharedState.isOpen
                    onClicked: {
                        powerMenuPanel.closePanel()
                    }
                }

                Item {
                    id: popupContainer
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: content.width
                    height: 160

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: sharedState.isOpen && shouldShow
                    }

                    PopupShape {
                        id: content
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 800
                        height: (sharedState.isOpen && shouldShow) ? 160 : 0

                        style: 1
                        alignment: 0
                        radius: 24
                        color: Appearance.colors.cSurfaceContainerLowest

                        Behavior on height {
                            NumberAnimation {
                                duration: powerMenuPanel.slideDuration
                                easing.type: Easing.OutCubic
                            }
                        }

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

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
                                    duration: powerMenuPanel.slideDuration
                                    easing.type: Easing.OutCubic
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16
                                focus: true

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 16
                                    focus: true

                                    Lock {
                                        id: lockItem
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        isSelected: sharedState.selectedIndex === 0
                                        onClicked: {

                                        }
                                    }

                                    Logout {
                                        id: logoutItem
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        isSelected: sharedState.selectedIndex === 1
                                        onClicked: {
                                            if (Compositor.compositor === "hyprland") {
                                                Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
                                            } else if (Compositor.compositor === "niri") {
                                                Quickshell.execDetached(["niri", "msg", "action", "quit"])
                                            }

                                        }
                                    }

                                    Reboot {
                                        id: rebootItem
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        isSelected: sharedState.selectedIndex === 2
                                        onClicked: {
                                            Quickshell.execDetached(["systemctl", "reboot"])
                                        }
                                    }

                                    Power {
                                        id: powerItem
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        isSelected: sharedState.selectedIndex === 3
                                        onClicked: {
                                            Quickshell.execDetached(["systemctl", "poweroff"])
                                        }
                                    }

                                    Suspend {
                                        id: suspendItem
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        isSelected: sharedState.selectedIndex === 4
                                        onClicked: {
                                            Quickshell.execDetached(["systemctl", "suspend"])
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
