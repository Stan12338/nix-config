import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.services
import qs.config
import qs.functions
import qs.widgets

Item {
    id: root
    
    readonly property bool usePasswordChars: !PolkitService.flow?.responseVisible ?? true
    
    
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            PolkitService.cancel()
        }
    }
    
    function submit() {
        PolkitService.submit(inputField.text)
    }
    
    Connections {
        target: PolkitService
        function onInteractionAvailableChanged() {
            if (!PolkitService.interactionAvailable) return
            inputField.text = ""
            inputField.forceActiveFocus()
        }
    }
    
    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#80000000"
        opacity: 0
        visible: true
        
        Component.onCompleted: {
            opacity = 1
        }
        
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
    
    Rectangle {
        id: dialog
        anchors.centerIn: parent
        width: 450
        height: column.height + 60
        radius: 12
        color: Appearance.colors.cSurfaceContainerLowest
        border.color: Appearance.colors.cOutline
        border.width: 1
        visible: true
        
        scale: 0
        Component.onCompleted: {
            scale = 1
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }
        
        ColumnLayout {
            id: column
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 30
            }
            spacing: 20
            
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: ""
                color: Appearance.colors.cOnSurface
                font.pixelSize: 32
            }
            
            StyledText {
                Layout.fillWidth: true
                text: "Authentication Required"
                font.pixelSize: 18
                font.bold: true
                color: Appearance.colors.cOnSurface
                horizontalAlignment: Text.AlignHCenter
            }
            
            // Message
            StyledText {
                Layout.fillWidth: true
                text: {
                    if (!PolkitService.flow) {
                        return ""
                    }
                    const msg = PolkitService.flow.message
                    return msg.endsWith(".") ? msg.slice(0, -1) : msg
                }
                font.pixelSize: 14
                color: Appearance.colors.cOnSurface
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
            }
            
            // input field
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 24
                color: Appearance.colors.cSurfaceContainer
                border.color: inputField.activeFocus ? Appearance.colors.cPrimary : Appearance.colors.cOutline
                border.width: 2
                
                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }
                
                TextInput {
                    id: inputField
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    focus: true
                    enabled: PolkitService.interactionAvailable
                    color: Appearance.colors.cOnSurface
                    font.pixelSize: 14
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: root.usePasswordChars ? TextInput.Password : TextInput.Normal
                    
                    
                    onAccepted: {
                        root.submit()
                    }
                    
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            PolkitService.cancel()
                        }
                    }
                    
                    StyledText {
                        visible: inputField.text.length === 0
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: {
                            const prompt = PolkitService.flow?.inputPrompt.trim() ?? ""
                            const cleaned = prompt.endsWith(":") ? prompt.slice(0, -1) : prompt
                            const result = cleaned || (root.usePasswordChars ? "Password" : "Input")
                            return result
                        }
                        color: Appearance.colors.cOutline
                        font.pixelSize: 14
                    }
                }
            }
            
            // buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Item {
                    Layout.fillWidth: true
                }
                
                // cancel button
                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    radius: 24
                    color: cancelMouseArea.containsMouse ?  Appearance.colors.cSurfaceContainerHighest : Appearance.colors.cSurfaceContainer
                    border.color: Appearance.colors.cOutline
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    
                    StyledText {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Appearance.colors.cOnSurface
                        font.pixelSize: 14
                    }
                    
                    MouseArea {
                        id: cancelMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            PolkitService.cancel()
                        }
                    }
                }
                
                // submit button
                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    radius: 24
                    color: {
                        if (!PolkitService.interactionAvailable) return Appearance.colors.cOnPrimary
                        return okMouseArea.containsMouse ?  ColorModifier.colorWithLightness(Appearance.colors.cPrimary, 0.9) : Appearance.colors.cPrimary
                    }
                    opacity: PolkitService.interactionAvailable ? 1 : 0.5

                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    
                    StyledText {
                        anchors.centerIn: parent
                        text: "OK"
                        color: Appearance.colors.cOnPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    MouseArea {
                        id: okMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: PolkitService.interactionAvailable
                        onClicked: {
                            root.submit()
                        }
                    }
                }
            }
        }
    }
}