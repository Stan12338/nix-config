import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config
import qs.widgets
import qs.services

Item {
    id: wifiRoot
    anchors.fill: parent
    anchors.bottomMargin: 12
    property var panelRef: null

    Component.onCompleted: {
        Network.rescanWifi()
    }

    Connections {
        target: Network
        function onWifiNetworksChanged() {
            for (let i = 0; i < Network.wifiNetworks.length; i++) {
                const network = Network.wifiNetworks[i];
                if (network.askingPassword) {
                    passwordDialog.targetNetwork = network;
                    passwordDialog.visible = true;
                    break;
                }
            }
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
                        if (wifiRoot.panelRef) {
                            wifiRoot.panelRef.setCurrentPage("Main")
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
                text: "Wi-Fi Networks"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Appearance.colors.cOnSurface
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: rescanMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer
                visible: Network.wifiEnabled
                
                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    id: rescanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Network.rescanWifi()
                }

                StyledText {
                    anchors.centerIn: parent
                    text: Network.wifiScanning ? "󰑐" : "󰑓"
                    font.pixelSize: 18
                    color: Appearance.colors.cOnSurface
                    
                    RotationAnimation on rotation {
                        running: Network.wifiScanning
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
                color: toggleMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer
                
                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    id: toggleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Network.toggleWifi()
                        Network.rescanWifi()
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: Network.wifiEnabled ? "󰖩" : "󰖪"
                    font.pixelSize: 18
                    color: Network.wifiEnabled ? Appearance.colors.cPrimary : Appearance.colors.cOnSurface
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

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 4

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        visible: !Network.wifiEnabled

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰖪"
                                font.pixelSize: 48
                                color: Appearance.colors.cOnSurfaceVariant
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Wi-Fi is disabled"
                                font.pixelSize: 16
                                color: Appearance.colors.cOnSurfaceVariant
                            }
                        }
                    }

                    Repeater {
                        model: Network.friendlyWifiNetworks
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            radius: 8
                            color: networkMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : "transparent"
                            
                            visible: Network.wifiEnabled
                            
                            Behavior on color {
                                ColorAnimation { duration: 0; easing.type: Easing.InOutQuad }
                            }

                            MouseArea {
                                id: networkMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.active) {
                                    } else {
                                        Network.connectToWifiNetwork(modelData)
                                    }
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                StyledText {
                                    text: {
                                        if (modelData.strength > 80) return "󰤨"
                                        if (modelData.strength > 60) return "󰤥"
                                        if (modelData.strength > 40) return "󰤢"
                                        if (modelData.strength > 20) return "󰤟"
                                        return "󰤯"
                                    }
                                    font.pixelSize: 24
                                    color: modelData.active ? Appearance.colors.cPrimary : Appearance.colors.cOnSurface
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    StyledText {
                                        text: modelData.ssid
                                        font.pixelSize: 14
                                        font.weight: modelData.active ? Font.Medium : Font.Normal
                                        color: Appearance.colors.cOnSurface
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    RowLayout {
                                        spacing: 8

                                        StyledText {
                                            text: modelData.active ? "Connected" : ""
                                            font.pixelSize: 12
                                            color: modelData.active ? Appearance.colors.cPrimary : Appearance.colors.cOnSurfaceVariant
                                            visible: text !== ""
                                        }

                                        StyledText {
                                            text: modelData.security ? "󰌾" : ""
                                            font.pixelSize: 12
                                            color: Appearance.colors.cOnSurfaceVariant
                                            visible: modelData.security !== ""
                                        }
                                    }
                                }

                                RowLayout {
                                    spacing: 4
                                    visible: modelData.active

                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: disconnectMouse.containsMouse ? Appearance.colors.cErrorContainer : Appearance.colors.cSurfaceContainerHighest
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                                        }

                                        MouseArea {
                                            id: disconnectMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Network.disconnectWifiNetwork()
                                                mouse.accepted = true
                                            }
                                        }

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: "󰖪"
                                            font.pixelSize: 16
                                            color: disconnectMouse.containsMouse ? Appearance.colors.cOnErrorContainer : Appearance.colors.cOnSurface
                                        }
                                    }
                                }

                                Item {
                                    width: 32
                                    height: 32
                                    visible: Network.wifiConnecting && Network.wifiConnectTarget === modelData

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "󰑐"
                                        font.pixelSize: 20
                                        color: Appearance.colors.cPrimary
                                        
                                        RotationAnimation on rotation {
                                            running: parent.visible
                                            loops: Animation.Infinite
                                            from: 0
                                            to: 360
                                            duration: 1000
                                        }
                                    }
                                }

                                Item {
                                    width: 32
                                    height: 32
                                    visible: modelData.askingPassword

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "󰌾"
                                        font.pixelSize: 20
                                        color: Appearance.colors.cError
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            passwordDialog.targetNetwork = modelData
                                            passwordDialog.visible = true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        visible: Network.wifiEnabled && Network.wifiNetworks.length === 0 && !Network.wifiScanning

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰀦"
                                font.pixelSize: 48
                                color: Appearance.colors.cOnSurfaceVariant
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No networks found"
                                font.pixelSize: 16
                                color: Appearance.colors.cOnSurfaceVariant
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: passwordDialog
        anchors.centerIn: parent
        width: Math.min(360, parent.width - 32)
        height: passwordColumn.height + 32
        radius: 16
        color: Appearance.colors.cSurfaceContainerHigh
        border.width: 2
        border.color: Appearance.colors.cOutline
        visible: false
        z: 100

        property var targetNetwork: null

        ColumnLayout {
            id: passwordColumn
            anchors.centerIn: parent
            width: parent.width - 32
            spacing: 16

            StyledText {
                text: "Connect to " + (passwordDialog.targetNetwork ? passwordDialog.targetNetwork.ssid : "")
                font.pixelSize: 16
                font.weight: Font.Medium
                color: Appearance.colors.cOnSurface
                Layout.alignment: Qt.AlignHCenter
            }

            StyledText {
                text: "Authentication required"
                font.pixelSize: 13
                color: Appearance.colors.cError
                Layout.alignment: Qt.AlignHCenter
                visible: passwordDialog.targetNetwork && passwordDialog.targetNetwork.askingPassword
            }

            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 8
                color: Appearance.colors.cSurfaceContainer

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: showPasswordCheck.checked ? TextInput.Normal : TextInput.Password
                    font.pixelSize: 14
                    color: Appearance.colors.cOnSurface
                    selectByMouse: true

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Password"
                        font.pixelSize: 14
                        color: Appearance.colors.cOnSurfaceVariant
                        visible: passwordInput.text.length === 0 && !passwordInput.activeFocus
                    }

                    Keys.onReturnPressed: {
                        if (passwordInput.text.length > 0 && passwordDialog.targetNetwork) {
                            Network.changePassword(passwordDialog.targetNetwork, passwordInput.text)
                            passwordDialog.visible = false
                            passwordInput.text = ""
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 18
                    height: 18
                    radius: 4
                    color: showPasswordCheck.checked ? Appearance.colors.cPrimary : Appearance.colors.cSurfaceContainer
                    border.color: Appearance.colors.cOutline
                    border.width: showPasswordCheck.checked ? 0 : 1

                    Behavior on color {
                        ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                    }

                    MouseArea {
                        id: showPasswordCheck
                        anchors.fill: parent
                        property bool checked: false
                        cursorShape: Qt.PointingHandCursor
                        onClicked: checked = !checked
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: "󰄬"
                        font.pixelSize: 12
                        color: Appearance.colors.cOnPrimary
                        visible: showPasswordCheck.checked
                    }
                }

                StyledText {
                    text: "Show password"
                    font.pixelSize: 13
                    color: Appearance.colors.cOnSurface
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 80
                    height: 36
                    radius: 8
                    color: cancelMouse.containsMouse ? Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer

                    Behavior on color {
                        ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            passwordDialog.visible = false
                            passwordInput.text = ""
                            if (passwordDialog.targetNetwork) {
                                passwordDialog.targetNetwork.askingPassword = false
                            }
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: 14
                        color: Appearance.colors.cOnSurface
                    }
                }

                Rectangle {
                    width: 90
                    height: 36
                    radius: 8
                    color: connectMouse.containsMouse ? ColorModifier.colorWithLightness(Appearance.colors.cPrimary, Qt.color(Appearance.colors.cPrimary).hslLightness + 0.05) : Appearance.colors.cPrimary

                    Behavior on color {
                        ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
                    }

                    MouseArea {
                        id: connectMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: passwordInput.text.length > 0
                        onClicked: {
                            if (passwordDialog.targetNetwork) {
                                Network.changePassword(passwordDialog.targetNetwork, passwordInput.text)
                                passwordDialog.visible = false
                                passwordInput.text = ""
                            }
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: "Connect"
                        font.pixelSize: 14
                        color: Appearance.colors.cOnPrimary
                        opacity: connectMouse.enabled ? 1 : 0.5
                    }
                }
            }
        }
    }
}