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
import QtQuick.Controls

ColumnLayout {
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true;

        Layout.topMargin: 30
        Layout.rightMargin: 60
        Layout.leftMargin: 60
        color: "#242424"

        Column{
            anchors.fill: parent
            spacing: 4
            StyledText {
                text:"Pinned"
                font.bold: true
                font.pixelSize: 13
                color: "white"
            }
            Item{
                implicitHeight: 4
                anchors.left: parent.left
                anchors.right: parent.right
            }
            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                spacing: 64
                Item {
                    implicitHeight: 90
                    implicitWidth: 32
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            zenHover.opacity = 1
                        }
                        onExited: {
                            zenHover.opacity = 0
                        }
                        onClicked: {
                            Quickshell.execDetached(["zen"])
                            ipc.close()
                        }
                    }
                    Rectangle {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter:  parent.horizontalCenter
                        color: "#313131"
                        implicitWidth: 90
                        radius: 8
                        opacity: 0
                        Behavior on opacity { NumberAnimation{duration: 150; easing.type: Easing.InOutQuad} }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.opacity = 1
                            }
                            onExited: {
                                parent.opacity = 0
                            }
                            onClicked: {
                                Quickshell.execDetached(["zen"])
                                ipc.close()
                            }
                        }
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.centerIn: parent
                        anchors.topMargin: 8

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Image {

                                anchors.centerIn: parent
                                source: "image://icon/zen"
                                sourceSize.width: 32
                                sourceSize.height: 32
                            }
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: "Zen"
                            color: "white"
                            font.weight: 550
                        }
                        Item {
                            implicitHeight: 16
                            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                        }
                    }
                }

                Item {
                    implicitHeight: 90
                    implicitWidth: 32
                    Rectangle {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter:  parent.horizontalCenter
                        color: "#313131"
                        implicitWidth: 90
                        radius: 8
                        opacity: 0
                        Behavior on opacity { NumberAnimation{duration: 150; easing.type: Easing.InOutQuad} }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.opacity = 1
                            }
                            onExited: {
                                parent.opacity = 0
                            }
                            onClicked: {
                                Quickshell.execDetached(["nemo"])
                                ipc.close()
                            }
                        }
                    }
                    ColumnLayout {

                        anchors.fill: parent
                        anchors.centerIn: parent
                        anchors.topMargin: 8

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Image {
                                anchors.centerIn: parent
                                source: "../../images/icons/file_explorer.webp"
                                sourceSize.width: 40
                                sourceSize.height: 40
                            }
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: "File Explorer"
                            color: "white"
                            font.weight: 550
                        }
                        Item {
                            implicitHeight: 16
                            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                        }
                    }
                }
                Item {
                    implicitHeight: 90
                    implicitWidth: 32

                    Rectangle {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter:  parent.horizontalCenter
                        color: "#313131"
                        implicitWidth: 90
                        radius: 8
                        opacity: 0
                        Behavior on opacity { NumberAnimation{duration: 150; easing.type: Easing.InOutQuad} }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.opacity = 1
                            }
                            onExited: {
                                parent.opacity = 0
                            }
                        }
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.centerIn: parent
                        anchors.topMargin: 8

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Image {

                                anchors.centerIn: parent
                                source: "../../images/icons/settings.png"
                                sourceSize.width: 32
                                sourceSize.height: 32
                            }
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: "Settings"
                            color: "white"
                            font.weight: 550
                        }
                        Item {
                            implicitHeight: 16
                            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                        }
                    }
                }
                Item {
                    implicitHeight: 90
                    implicitWidth: 32



                    Rectangle {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter:  parent.horizontalCenter
                        implicitWidth: 90
                        color: "#313131"
                        radius: 8
                        opacity: 0
                        Behavior on opacity { NumberAnimation{duration: 150; easing.type: Easing.InOutQuad} }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.opacity = 1
                            }
                            onExited: {
                                parent.opacity = 0
                            }
                            onClicked: {
                                Quickshell.execDetached(["zeditor"])
                                ipc.close()
                            }
                        }
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.centerIn: parent
                        anchors.topMargin: 8

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Image {

                                anchors.centerIn: parent
                                source: "image://icon/zed"
                                sourceSize.width: 32
                                sourceSize.height: 32
                            }
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: "Zed"
                            color: "white"
                            font.weight: 550
                        }
                        Item {
                            implicitHeight: 16
                            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                        }
                    }
                }
            }
            Item{
                implicitHeight: 26
                anchors.left: parent.left
                anchors.right: parent.right
            }
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 32
                StyledText {
                    Layout.alignment: Qt.AlignLeft
                    text: "All"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 13
                }
                Item {
                    Layout.alignment: Qt.AlignRight
                    Layout.fillHeight: true
                    implicitWidth: 112


                    Rectangle {
                        radius: 4
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#313131"

                        implicitHeight: 32
                        implicitWidth: parent.implicitWidth + 8
                        opacity: 0
                        Behavior on opacity { NumberAnimation{duration: 150; easing.type: Easing.InOutQuad} }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.opacity = 1
                            }
                            onExited: {
                                parent.opacity = 0
                            }
                        }
                    }
                    StyledText {
                        text: "View: Category  "
                        color: "white"
                        font.weight: 550
                        font.pixelSize: 13
                    }
                }

            }

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 12
            }
            GridLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                rows: 2
                columns: 4
                rowSpacing: 16
                columnSpacing: 32
                anchors.leftMargin: 2
                anchors.rightMargin: 2
                Category {
                    category: "Other"
                }

                Category {
                    category: "Browsers"
                }
                Category {
                    category: "Coding"
                }
                Category {
                    category: "System"
                }
                Category {
                    category: "Creativity"
                }
                Category {
                    category: "Games"
                }




            }
        }



    }
    Rectangle {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignBottom
        implicitHeight: 64
        color: "#1c1c1c"
        opacity: root.debug ? 0.9 : 1
        bottomLeftRadius: 8
        bottomRightRadius: 8
        RowLayout {
            anchors.fill: parent
            anchors {
                topMargin:13
                bottomMargin:11
                leftMargin: 50
                rightMargin: 50
            }
            Item {
                Layout.fillHeight: true
                implicitWidth: 154
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered :{
                        accountHover.opacity = 1
                    }
                    onExited :{
                        accountHover.opacity = 0
                    }
                }
                Rectangle {
                    id: accountHover
                    anchors.fill: parent
                    radius: 4
                    opacity: 0
                    Behavior on opacity { NumberAnimation{duration: 150; easing.type: Easing.InOutQuad} }
                    color: "#292929"

                }
                RowLayout {
                    anchors.fill: parent
                    Image {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 13
                        source: "../../images/account_icon.png"
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        StyledText {
                            anchors.centerIn: parent
                            text: "Stanley Morrish"
                            color: "white"
                            font.pixelSize: 11
                            font.weight: 600
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                implicitWidth: 40
                Layout.alignment: Qt.AlignRight
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered :{
                        powerHover.opacity = 1
                    }
                    onExited :{
                        powerHover.opacity = 0
                    }
                }
                Rectangle {
                    id: powerHover
                    implicitHeight: 40
                    implicitWidth: 40
                    radius: 4
                    color: "#292929"
                    opacity: 0
                    Behavior on opacity { NumberAnimation{duration: 150; easing.type: Easing.InOutQuad} }
                }
                StyledText {
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: 18
                    color: "white"
                }
            }

        }
    }

}
