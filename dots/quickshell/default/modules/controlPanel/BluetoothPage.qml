import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.widgets
import qs.services

Item {
    id: bluetoothRoot
    anchors.fill: parent
    anchors.bottomMargin: 12
    // clip: true
    property var panelRef: null

    Component.onCompleted: {
        if (BluetoothService.enabled && BluetoothService.adapter) {
            BluetoothService.adapter.discovering = true
        }
    }

    Component.onDestruction: {
        if (BluetoothService.adapter) {
            BluetoothService.adapter.discovering = false
        }
    }

    Connections {
        target: BluetoothService
        function onEnabledChanged() {
            if (!BluetoothService.adapter) return
            BluetoothService.adapter.discovering = BluetoothService.enabled
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: backMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer

                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (bluetoothRoot.panelRef) {
                            bluetoothRoot.panelRef.setCurrentPage("Main")
                        }
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: 18
                    color: Appearance.colors.cOnSurface
                }
            }

            StyledText {
                text: "Bluetooth Devices"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Appearance.colors.cOnSurface
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 36
                height: 36
                radius: 18
                visible: BluetoothService.enabled
                color: rescanMouse.containsMouse
                    ? Appearance.colors.cSurfaceContainerHighest
                    : Appearance.colors.cSurfaceContainer

                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    id: rescanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: BluetoothService.toggleDiscovery()
                }

                StyledText {
                    anchors.centerIn: parent
                    text: BluetoothService.discovering ? "󰑐" : "󰑓"
                    font.pixelSize: 18
                    color: Appearance.colors.cOnSurface

                    RotationAnimation on rotation {
                        running: BluetoothService.discovering
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 1000
                    }
                }
            }

            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: toggleMouse.containsMouse
                    ? Appearance.colors.cSurfaceContainerHighest
                    : Appearance.colors.cSurfaceContainer

                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    id: toggleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: BluetoothService.togglePower()
                }

                StyledText {
                    anchors.centerIn: parent
                    text: BluetoothService.enabled ? "󰂯" : "󰂲"
                    font.pixelSize: 18
                    color: BluetoothService.enabled
                        ? Appearance.colors.cPrimary
                        : Appearance.colors.cOnSurface
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: Appearance.colors.cSurfaceContainer
            clip: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: 8
                clip: true

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOff }

                ColumnLayout {
                    width: parent.width
                    spacing: 4

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        visible: !BluetoothService.enabled

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            StyledText {
                                text: "󰂲"
                                font.pixelSize: 48
                                color: Appearance.colors.cOnSurfaceVariant
                                Layout.alignment: Qt.AlignHCenter
                            }

                            StyledText {
                                text: "Bluetooth is disabled"
                                font.pixelSize: 16
                                color: Appearance.colors.cOnSurfaceVariant
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    Repeater {
                        model: BluetoothService.friendlyDeviceList

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            radius: 8
                            visible: BluetoothService.enabled
                            color: deviceMouse.containsMouse
                                ? Appearance.colors.cSurfaceContainerHighest
                                : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 0; easing.type: Easing.InOutQuad }
                            }

                            MouseArea {
                                id: deviceMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (modelData.connected) return
                                    if (modelData.paired)
                                        modelData.connect()
                                    else
                                        modelData.pair()
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12

                                StyledText {
                                    text: modelData.connected ? "󰂱" : "󰂯"
                                    font.pixelSize: 24
                                    color: modelData.connected
                                        ? Appearance.colors.cPrimary
                                        : Appearance.colors.cOnSurface
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    StyledText {
                                        text: modelData.name || modelData.address
                                        color: Appearance.colors.cOnSurface
                                        font.pixelSize: 14
                                        font.weight: modelData.connected
                                            ? Font.Medium
                                            : Font.Normal
                                        elide: Text.ElideRight
                                    }

                                    StyledText {
                                        text: modelData.connected
                                            ? "Connected"
                                            : (modelData.paired ? "Paired" : "")
                                        font.pixelSize: 12
                                        color: modelData.connected
                                            ? Appearance.colors.cPrimary
                                            : Appearance.colors.cOnSurfaceVariant
                                        visible: text !== ""
                                    }
                                }

                                RowLayout {
                                    spacing: 4
                                    visible: modelData.connected || modelData.paired

                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: 16
                                        visible: modelData.connected
                                        color: disconnectMouse.containsMouse
                                            ? Appearance.colors.cErrorContainer
                                            : Appearance.colors.cSurfaceContainerHighest

                                        Behavior on color {
                                            ColorAnimation { duration: 250 }
                                        }

                                        MouseArea {
                                            id: disconnectMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                modelData.disconnect()
                                                mouse.accepted = true
                                            }
                                        }

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: "󰂲"
                                            font.pixelSize: 16
                                            color: disconnectMouse.containsMouse
                                                ? Appearance.colors.cOnErrorContainer
                                                : Appearance.colors.cOnSurface
                                        }
                                    }

                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: 16
                                        visible: modelData.paired
                                        color: forgetMouse.containsMouse
                                            ? Appearance.colors.cErrorContainer
                                            : Appearance.colors.cSurfaceContainerHighest

                                        Behavior on color {
                                            ColorAnimation { duration: 250 }
                                        }

                                        MouseArea {
                                            id: forgetMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                BluetoothService.forgetDevice(modelData)
                                                mouse.accepted = true
                                            }
                                        }

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: "󰆴"
                                            font.pixelSize: 16
                                            color: forgetMouse.containsMouse
                                                ? Appearance.colors.cOnErrorContainer
                                                : Appearance.colors.cOnSurface
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        visible: BluetoothService.enabled
                            && BluetoothService.friendlyDeviceList.length === 0
                            && !BluetoothService.discovering

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            StyledText {
                                text: "󰀦"
                                font.pixelSize: 48
                                color: Appearance.colors.cOnSurfaceVariant
                                Layout.alignment: Qt.AlignHCenter
                            }

                            StyledText {
                                text: "No devices found"
                                font.pixelSize: 16
                                color: Appearance.colors.cOnSurfaceVariant
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
