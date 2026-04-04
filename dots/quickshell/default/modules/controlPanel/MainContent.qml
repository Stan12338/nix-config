import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config
import qs.widgets
import qs.functions
import qs.services
import Quickshell.Services.Pipewire

Item {
    id: mainPage
    anchors.fill: parent
    property var panelRef: null

    ColumnLayout {
        anchors.fill: parent
        anchors.bottomMargin: 12
        spacing: 16
        ColumnLayout {
            // if youre wondering why this is a grid layout instead of a row layout its because
            // originally i was going to have 4 items but i changed it to 2 later and im too lazy to change it
            // anchors.fill: parent
            // anchors.bottomMargin: 12
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            GridLayout {
                id: grid
                Layout.fillWidth: true;

                columns: 2
                rowSpacing: 16
                columnSpacing: 16

                Rectangle {
                    id: wifiButton
                    radius: 12
                    color: wifiMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer

                    implicitHeight: 72
                    Layout.fillWidth: true
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                    MouseArea {
                        id: wifiMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (panelRef) panelRef.setCurrentPage("Wifi")
                        }

                    }
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: wifiButtonInner
                            anchors.verticalCenter: parent.verticalCenter
                            width: 56
                            height: 56
                            radius: 8
                            color: wifiInnerMouse.containsMouse ? ColorModifier.colorWithLightness(Appearance.colors.cPrimary, Qt.color(Appearance.colors.cPrimary).hslLightness + 0.05) : Appearance.colors.cPrimary
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            MouseArea {
                                id: wifiInnerMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                // onEntered: {
                                //     wifiButtonInner.color = ColorModifier.colorWithLightness(Appearance.colors.cPrimary, Qt.color(Appearance.colors.cPrimary).hslLightness + 0.05)
                                // }
                                // onExited: {
                                //     wifiButtonInner.color = Appearance.colors.cPrimary
                                // }
                            }
                            StyledText {
                                anchors.centerIn: parent
                                text: "󰖩"
                                color: Appearance.colors.cOnPrimary
                                font.pixelSize: 32
                            }
                        }
                        StyledText {
                            id: wifiText
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Wi-Fi"
                            color: Appearance.colors.cOnSurface
                            font.pixelSize: 16
                        }
                    }
                }
                Rectangle {
                    id: bluetoothButton
                    radius: 12
                    color: bluetoothMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer
                    implicitHeight: 72
                    Layout.fillWidth: true

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                    MouseArea {
                        id: bluetoothMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (panelRef) panelRef.setCurrentPage("Bluetooth")
                        }

                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: bluetoothButtonInner
                            anchors.verticalCenter: parent.verticalCenter
                            width: 56
                            height: 56
                            radius: 8
                            color: bluetoothMouseInner.containsMouse ? ColorModifier.colorWithLightness(Appearance.colors.cPrimary, Qt.color(Appearance.colors.cPrimary).hslLightness + 0.05) : Appearance.colors.cPrimary
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            MouseArea {
                                id: bluetoothMouseInner
                                anchors.fill: parent
                                hoverEnabled: true
                                // onEntered: {
                                //     bluetoothButtonInner.color = ColorModifier.colorWithLightness(Appearance.colors.cPrimary, Qt.color(Appearance.colors.cPrimary).hslLightness + 0.05)
                                // }
                                // onExited: {
                                //     bluetoothButtonInner.color = Appearance.colors.cPrimary
                                // }
                            }
                            StyledText {
                                anchors.centerIn: parent
                                text: "󰂯"
                                color: Appearance.colors.cOnPrimary
                                font.pixelSize: 32
                            }
                        }
                        StyledText {
                            id: bluetoothText
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Bluetooth"
                            color: Appearance.colors.cOnSurface
                            font.pixelSize: 16
                        }
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    radius: 12
                    color: Appearance.colors.cSurfaceContainer
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                    Rectangle {
                        id: selector
                        height: parent.height - 8
                        width: parent.width / 2 - 6
                        radius: 10
                        color: Appearance.colors.cPrimary
                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                        y: 4
                        x: Appearance.isDark ? 4 : parent.width / 2 + 2
                        z: 0

                        Behavior on x {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                        }

                    }

                    Row {
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            width: parent.width / 2
                            height: parent.height

                            MouseArea {
                                id: darkMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    Appearance.isDark = true
                                    Appearance.setTheme("dark")
                                }
                            }

                            StyledText {
                                id: darkText
                                anchors.centerIn: parent
                                text: "Dark"
                                font.pixelSize: 16
                                color: {
                                    if (Appearance.isDark) {
                                        return darkMouseArea.containsMouse ?
                                            ColorModifier.colorWithLightness(Appearance.colors.cOnPrimary, Qt.color(Appearance.colors.cOnPrimary).hslLightness + 0.1) :
                                            Appearance.colors.cOnPrimary
                                    } else {
                                        return darkMouseArea.containsMouse ?
                                            Appearance.colors.cPrimary :
                                            Appearance.colors.cOnSurface
                                    }
                                }
                                font.weight: Appearance.isDark ? Font.Medium : Font.Normal
                                z: 2
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                        }

                        Item {
                            width: parent.width / 2
                            height: parent.height

                            MouseArea {
                                id: lightMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    Appearance.isDark = false
                                    Appearance.setTheme("light")
                                }
                            }

                            StyledText {
                                id: lightText
                                anchors.centerIn: parent
                                text: "Light"
                                font.pixelSize: 16
                                color: {
                                    if (!Appearance.isDark) {
                                        return lightMouseArea.containsMouse ?
                                            ColorModifier.colorWithLightness(Appearance.colors.cOnPrimary, Qt.color(Appearance.colors.cOnPrimary).hslLightness + 0.1) :
                                            Appearance.colors.cOnPrimary
                                    } else {
                                        return lightMouseArea.containsMouse ?
                                            Appearance.colors.cPrimary :
                                            Appearance.colors.cOnSurface
                                    }
                                }
                                font.weight: !Appearance.isDark ? Font.Medium : Font.Normal
                                z: 2
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                        }
                    }
                }
            }
            ColumnLayout {
                spacing: 12
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText { text: "Volume:"; font.pixelSize: 16; color: Appearance.colors.cOnSurface }

                        Item { Layout.fillWidth: true }

                        StyledText {
                            id: volumeValue
                            text: Math.round(volumeSlider.value * 100) + "%"
                            font.pixelSize: 16
                            color: Appearance.colors.cOnSurface
                        }
                    }

                    StyledSlider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        stepSize: 0.01

                        Component.onCompleted: {
                            value = Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.volume : 0.5;
                        }

                        Connections {
                            target: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ?
                                    Pipewire.defaultAudioSink.audio : null

                            function onVolumeChanged() {
                                volumeSlider.value = target.volume;
                            }
                        }


                        onMoved: {
                            if (Pipewire.defaultAudioSink)
                                Pipewire.defaultAudioSink.audio.volume = value;
                            volumeValue.text = Math.round(value * 100) + "%";
                        }
                    }

                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText { text: "Brightness:"; font.pixelSize: 16; color: Appearance.colors.cOnSurface }

                        Item { Layout.fillWidth: true }

                        StyledText {
                            id: brightnessValue
                            text: Math.round(brightnessSlider.value * 100) + "%"
                            font.pixelSize: 16
                            color: Appearance.colors.cOnSurface
                        }
                    }

                    StyledSlider {
                        id: brightnessSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        stepSize: 0.01
                        value: Brightness.monitors.length > 0 ? Brightness.monitors[0].brightness : 0.5

                        onMoved: {
                            if (Brightness.monitors.length > 0) {
                                Brightness.monitors[0].setBrightness(value);
                                brightnessValue.text = Math.round(value * 100) + "%";
                            }
                        }
                    }
                }
            }







        }
        RowLayout {
            id: quickActions
            Layout.fillWidth: true
            Layout.maximumHeight: width / 4 - 12
            spacing: 16
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                QuickActionRect {
                    type: "dnd"
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                QuickActionRect {
                    type: "screenshot"
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                QuickActionRect {
                    type: "bar"
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                QuickActionRect {
                    type: "windows"
                }
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

    }



}
