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
import Quickshell.Services.Pipewire

ColumnLayout {
    anchors.fill: parent
    anchors.margins: 1
    spacing: 0
    clip: true

    signal wifiClicked()
    signal back()
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
                    border.color: Network.wifiEnabled ? "#adaca8" : "#404040"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 1
                        spacing: 0
                        Rectangle {
                            id: wifiToggle
                            color: wifiToggleMouse.pressed
                                ? Network.wifiEnabled ? "#686562" : "#2b2b2b"
                                : wifiToggleMouse.containsMouse
                                    ? Network.wifiEnabled ? "#dfdedc" : "#363636"
                                    : Network.wifiEnabled
                                        ? "#a6a5a1"
                                        : "#313131"
                            Behavior on color {
                                ColorAnimation { duration: 50 }
                            }
                            topLeftRadius: 3
                            bottomLeftRadius:3
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Image {
                                source: Network.wifiEnabled ? "../../images/wifi-full-black.png" : "../../images/wifi-full-white.png"
                                anchors.centerIn: parent
                            }
                            MouseArea {
                                id: wifiToggleMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    Network.toggleWifi()
                                }
                            }
                        }
                        Rectangle {
                            color: Network.wifiEnabled ? "#adaca8" : "#404040"
                            implicitWidth: 2
                            Layout.fillHeight: true
                        }
                        Rectangle {
                            color: wifiMouse.pressed
                                ? Network.wifiEnabled ? "#686562" : "#2b2b2b"
                                : wifiMouse.containsMouse
                                    ? Network.wifiEnabled ? "#dfdedc" : "#363636"
                                    : Network.wifiEnabled
                                        ? "#a6a5a1"
                                        : "#313131"
                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }
                            topRightRadius: 3
                            bottomRightRadius:3
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Image {
                                source: Network.wifiEnabled ? "../../images/right-arrow-black.png" : "../../images/right-arrow-white.png"
                                anchors.centerIn: parent
                            }
                            MouseArea {
                                id: wifiMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: wifiClicked()
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
                        text:  Network.wifiEnabled ? Network.networkName : "No internet"
                        color: "white"
                        font.pixelSize: 12
                    }
                }
            }
            ColumnLayout{
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 0
                spacing: 0
                Rectangle {
                    radius: 4
                    color: "#a6a5a1"
                    border.width: 1
                    border.color: BluetoothService.enabled ? "#adaca8" : "#404040"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 1
                        spacing: 0
                        Rectangle {
                            id: bluetoothToggle
                            color: bluetoothToggleMouse.pressed
                                ? BluetoothService.enabled ? "#686562" : "#2b2b2b"
                                : bluetoothToggleMouse.containsMouse
                                    ? BluetoothService.enabled ? "#dfdedc" : "#363636"
                                    : BluetoothService.enabled
                                        ? "#a6a5a1"
                                        : "#313131"
                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }
                            topLeftRadius: 3
                            bottomLeftRadius:3
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Image {
                                source: BluetoothService.enabled ? "../../images/bluetooth2.png" : "../../images/bluetooth-white.png"
                                anchors.centerIn: parent
                            }
                            MouseArea {
                                id: bluetoothToggleMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    BluetoothService.togglePower()
                                }
                            }
                        }
                        Rectangle {
                            border.color: BluetoothService.enabled ? "#adaca8" : "#404040"
                            implicitWidth: 2
                            Layout.fillHeight: true
                        }
                        Rectangle {
                            color: bluetoothMouse.pressed
                                ? BluetoothService.enabled ? "#686562" : "#2b2b2b"
                                : bluetoothMouse.containsMouse
                                    ? BluetoothService.enabled ? "#dfdedc" : "#363636"
                                    : BluetoothService.enabled
                                        ? "#a6a5a1"
                                        : "#313131"
                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }
                            topRightRadius: 3
                            bottomRightRadius:3
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Image {
                                source: BluetoothService.enabled ? "../../images/right-arrow-black.png"  : "../../images/right-arrow-white.png"
                                anchors.centerIn: parent
                            }
                            MouseArea {
                                id: bluetoothMouse
                                anchors.fill: parent
                                hoverEnabled: true
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
                        text: BluetoothService.enabled ? "Not Connected" : "Disabled"
                        color: "white"
                        font.pixelSize: 12
                    }
                }
            }
            ColumnLayout{
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 0
                spacing: 0
                Rectangle {
                    radius: 4
                    color: "#313131"
                    border.width: 1
                    border.color: "#444444"
                    anchors.margins: 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    Image {
                        anchors.centerIn: parent
                        source: "../../images/airplane-mode.png"
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: {
                            parent.color = "#363636"
                        }
                        onExited: {
                            parent.color = "#313131"
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
                        text: "Airplane mode"
                        color: "white"
                        font.pixelSize: 12
                    }
                }
            }
            ColumnLayout{
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 0
                spacing: 0
                Rectangle {
                    radius: 4
                    anchors.margins: 1
                    color: "#313131"
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                    border.width: 1
                    border.color: "#444444"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    Image {
                        anchors.centerIn: parent
                        source: "../../images/energy-saver.png"
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: {
                            parent.color = "#363636"
                        }
                        onExited: {
                            parent.color = "#313131"
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
                        text: "Energy saver"
                        color: "white"
                        font.pixelSize: 12
                    }
                }
            }
            ColumnLayout{
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 0
                spacing: 0
                Rectangle {
                    radius: 4
                    color: "#313131"
                    anchors.margins: 1
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                    border.width: 1
                    border.color: "#444444"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    Image {
                        anchors.centerIn: parent
                        source: "../../images/night-light.png"
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: {
                            parent.color = "#363636"
                        }
                        onExited: {
                            parent.color = "#313131"
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
                        text: "Night light"
                        color: "white"
                        font.pixelSize: 12
                    }
                }
            }
            ColumnLayout{
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 0
                spacing: 0
                Rectangle {
                    radius: 4
                    anchors.margins: 1
                    color: "#313131"
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                    border.width: 1
                    border.color: "#444444"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    Image {
                        anchors.centerIn: parent
                        source: "../../images/accessibility.png"
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: {
                            parent.color = "#363636"
                        }
                        onExited: {
                            parent.color = "#313131"
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
                        text: "Accesibility"
                        color: "white"
                        font.pixelSize: 12
                    }
                }
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
        Item {
            anchors.fill: parent
            anchors {
                topMargin: 18
                bottomMargin: 14
                leftMargin: 20
                rightMargin: 20
            }
            Column{
                anchors.fill: parent
                spacing: 12

                RowLayout {
                    implicitWidth: parent.width
                    spacing: 0
                    Item {
                        Layout.alignment: Qt.AlignVCenter
                        implicitHeight: 24
                        implicitWidth: 26
                        Image {
                            anchors.centerIn: parent
                            source: "../../images/brightness.png"
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                        implicitWidth: 10
                    }
                    StyledSlider {
                        id: brightnessSlider
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillHeight: true
                        from: 0
                        to: 1
                        value: Brightness.monitors.length > 0 ? Brightness.monitors[0].brightness : 0.5

                        Connections {
                            target: Brightness.monitors.length > 0 ? Brightness.monitors[0] : null
                            function onBrightnessChanged() {
                                if (!brightnessSlider.pressed)
                                    brightnessSlider.value = target.brightness
                            }
                        }

                        onMoved: {
                            if (Brightness.monitors.length > 0)
                                Brightness.monitors[0].setBrightness(value)
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                        implicitWidth: 16
                    }

                    Image {
                        opacity: 0
                        source: "../../images/sound-mixing.png"
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    }
                }
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 2
                }
                RowLayout {
                    implicitWidth: parent.width
                    implicitHeight: 24
                    spacing: 0

                    Item {
                        Layout.alignment: Qt.AlignVCenter
                        implicitHeight: 24
                        implicitWidth: 26

                        Image {
                            anchors.centerIn: parent
                            source: {
                                const audio = Volume.defaultSpeaker?.audio
                                if (!audio || audio.muted || audio.volume === 0)
                                    return "../../images/control-volume-none.png"
                                else if (audio.volume < 0.33)
                                    return "../../images/control-volume-low.png"
                                else if (audio.volume < 0.66)
                                    return "../../images/control-volume-medium.png"
                                else
                                    return "../../images/control-volume-high.png"
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        implicitWidth: 10
                    }

                    StyledSlider {
                        id: volumeSlider
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillHeight: true
                        from: 0
                        to: 1
                        value: Volume.defaultSpeaker?.audio?.volume ?? 0

                        Connections {
                            target: Volume.defaultSpeaker?.audio ?? null
                            function onVolumeChanged() {
                                volumeSlider.value = target.volume
                            }
                        }

                        onMoved: {
                            if (Pipewire.defaultAudioSink)
                                Pipewire.defaultAudioSink.audio.volume = value
                        }
                    }



                    Item {
                        Layout.fillHeight: true
                        implicitWidth: 16
                    }

                    Image {
                        source: "../../images/sound-mixing.png"
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    }
                }
            }


        }
    }
    Rectangle {
        // radius: 6
        bottomLeftRadius: 6
        bottomRightRadius: 6
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
                    text: Math.round(Battery.percentage) + "%"
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
