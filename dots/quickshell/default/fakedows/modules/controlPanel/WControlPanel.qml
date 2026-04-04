import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.widgets.fakedows
import qs.services
import qs.services.niri

Scope {
    id: root

    property bool debug: false

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
                    height: 386
                    opacity: 0.5

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

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 1
                            spacing: 0
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                GridLayout {
                                    anchors.fill: parent
                                    anchors.margins: 20
                                    columns: 3
                                    rows: 2
                                    rowSpacing: 20
                                    columnSpacing: 8
                                    ColumnLayout{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.preferredHeight: 0
                                        spacing: 0
                                        Rectangle {
                                            radius: 4
                                            color: "#a6a5a1"
                                            border.width: 1
                                            border.color: "#adaca8"
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 50
                                            RowLayout {
                                                anchors.fill: parent
                                                spacing: 0
                                                Rectangle {
                                                    color: "#a6a5a1"
                                                    topLeftRadius: 4
                                                    bottomLeftRadius:4
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    Image {
                                                        source: "../../images/wifi-full-black.png"
                                                        anchors.centerIn: parent
                                                    }
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                    }
                                                }
                                                Rectangle {
                                                    color: "#adaca8"
                                                    implicitWidth: 2
                                                    Layout.fillHeight: true
                                                }
                                                Rectangle {
                                                    color: "#a6a5a1"
                                                    topRightRadius: 4
                                                    bottomRightRadius:4
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    Image {
                                                        source: "../../images/right-arrow-black.png"
                                                        anchors.centerIn: parent
                                                    }

                                                }
                                            }
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            StyledText {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                anchors.top: parent.top
                                                anchors.topMargin: 8
                                                text: "Minions"
                                                color: "white"
                                                font.pixelSize: 12
                                            }
                                        }
                                    }
                                    Rectangle {
                                        color: "red"
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    }
                                    Rectangle {
                                        color: "red"
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    }
                                    Rectangle {
                                        color: "red"
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    }
                                    Rectangle {
                                        color: "red"
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    }
                                    Rectangle {
                                        color: "red"
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    }
                                }
                            }
                            Rectangle {
                                color: "#363636"
                                Layout.fillWidth: true
                                implicitHeight: 1
                            }
                            Item {
                                Layout.fillWidth: true
                                implicitHeight: 124
                            }
                            Rectangle {
                                radius: 6
                                Layout.fillWidth: true
                                implicitHeight: 48
                                color: "#1c1c1c"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.topMargin: 16
                                    anchors.bottomMargin: 16
                                    anchors.leftMargin: 24
                                    anchors.rightMargin: 24
                                    RowLayout {
                                        spacing: 5

                                        Image {
                                            source: "../../images/battery/" + Battery.capacity + ".png"
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                        StyledText {
                                            text: Battery.percentage + "%"
                                            color: "white"
                                            Layout.alignment: Qt.AlignVCenter
                                            font.pixelSize: 11
                                            font.weight: 550
                                        }
                                    }
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    }
                                    Item {
                                        Layout.fillHeight: true
                                        implicitWidth: height
                                        Image {
                                            anchors.centerIn: parent
                                            source: "../../images/settings-icon.png"
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
