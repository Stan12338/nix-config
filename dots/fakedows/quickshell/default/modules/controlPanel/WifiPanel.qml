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

ColumnLayout {
    anchors.fill: parent
    anchors.margins: 1
    spacing: 0

    signal wifiClicked()

    signal back()

    Item {
        Layout.fillWidth: true
        implicitHeight: 40
        RowLayout {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.bottomMargin: 4
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 12
            Item {

                Layout.alignment: Qt.alignLeft | Qt.alignVCenter
                Layout.fillHeight: true
                implicitWidth: height

                Item {
                    anchors.fill: parent
                    Rectangle {
                        radius: 4
                        anchors.fill: parent
                        opacity: 0
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                        color: "#313131"
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.opacity = 1
                            }
                            onExited: {
                                parent.opacity = 0
                            }
                            onClicked : {
                                back()
                            }
                        }
                    }

                }
                StyledText {
                    color: "white"
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: 16
                }
            }

            StyledText {
                Layout.alignment: Qt.alignRight | Qt.alignVCenter
                text: "Wi-Fi"
                font.pixelSize: 14
                color: "white"
            }
            Item {
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.alignment: Qt.alignRight | Qt.alignVCenter
                Layout.rightMargin: 8
                implicitWidth: 40
                implicitHeight: 20
                color: "#a6a5a1"
                radius: 10
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    Item {
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        color: "#000000"
                        implicitWidth:12
                        implicitHeight: 12
                        radius: 6

                    }
                }

            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Column {
            anchors.fill: parent
            anchors {
                topMargin: 8
                leftMargin: 4
                rightMargin: 4
            }
            Rectangle {
                color: "#313131"
                implicitWidth: parent.width
                implicitHeight: 108
                radius: 4
                StyledText {
                    anchors.centerIn: parent
                    text: "You got pranked, this is actually linux"
                    color: "white"
                    font.pixelSize: 20
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
            anchors.bottomMargin: 14
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            StyledText {
                color: "white"
                text: "More Wi-Fi settings"
                font.pixelSize: 12
                Layout.fillHeight: true
                Layout.alignment: Qt.alignLeft | Qt.alignVCenter
            }
            Item {
                Layout.fillWidth: true
            }
            Image {
                Layout.alignment: Qt.alignRight | Qt.alignVCenter
                source: "../../images/speedtest-restart-wifi.png"
            }
        }
    }
}
