import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.config
import qs.widgets
import qs.services
import "."

Scope {

    QtObject {
        id: sharedState
        property bool isOpen: false
        property string openedOnMonitor: ""
        property string mode: "clipboard"
    }

    IpcHandler {
        id: ipc
        target: "clipboard"

        function toggle() {
            Quickshell.execDetached(["qs", "ipc", "call", "powermenu", "close"])
            Quickshell.execDetached(["qs", "ipc", "call", "launcher", "close"])
            if (!sharedState.isOpen) {
                sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
            }
            sharedState.isOpen = !sharedState.isOpen
        }

        function open() {
            Quickshell.execDetached(["qs", "ipc", "call", "powermenu", "close"])
            Quickshell.execDetached(["qs", "ipc", "call", "launcher", "close"])
            if (!sharedState.isOpen) {
                sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
            }
            sharedState.isOpen = true
        }

        function open_clipboard() {
            if (sharedState.mode === "clipboard" && sharedState.isOpen === true) {
                close()
                return
            }
            sharedState.mode = "clipboard"
            open()
        }

        function open_emoji() {
            if (sharedState.mode === "emoji" && sharedState.isOpen === true) {
                close()
                return
            }
            sharedState.mode = "emoji"
            open()
        }

        function close() {
            sharedState.isOpen = false
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            id: clipboardPanel
            screen: modelData

            anchors {
                top: true
                right: true
                left: true
                bottom: true
            }

            margins.top: 40
            color: "transparent"

            readonly property int slideDuration: 350
            property bool shouldShow: modelData.name === sharedState.openedOnMonitor

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            mask: null

            Timer {
                id: closeDelayTimer
                interval: clipboardPanel.slideDuration + 100
                repeat: false
                onTriggered: {
                    clipboardPanel.WlrLayershell.layer = WlrLayer.Background
                    clipboardPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                    clipboardPanel.mask = null
                }
            }

            Connections {
                target: sharedState

                function onIsOpenChanged() {
                    if (sharedState.isOpen) {
                        closeDelayTimer.stop()
                        clipboardPanel.WlrLayershell.layer = WlrLayer.Top
                        clipboardPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        clipboardPanel.mask = null

                        if (shouldShow) {
                            if (sharedState.mode === "clipboard") {
                                ClipboardService.refresh()
                            }
                            searchField.text = ""
                            if (clipList.count > 0) {
                                clipList.currentIndex = 0
                            } else {
                                clipList.currentIndex = -1
                            }
                            focusScope.forceActiveFocus()
                            searchField.forceActiveFocus()
                        }
                    } else {
                        searchField.text = ""
                        clipboardPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                        closeDelayTimer.start()
                    }
                }

                function onModeChanged() {
                    if (sharedState.isOpen && shouldShow) {
                         searchField.text = ""
                         focusScope.forceActiveFocus()
                         searchField.forceActiveFocus()
                    }
                }
            }

            function closePanel() {
                sharedState.isOpen = false
            }

            function performCopy(item) {
                if (sharedState.mode === "emoji") {
                    // Extract just the emoji (first part before space)
                    // e.g., "🌹 rose" -> "🌹"
                    const emojiOnly = item.split(' ')[0]
                    ClipboardService.copyRaw(emojiOnly)
                } else {
                    ClipboardService.copy(item)
                }
                clipboardPanel.closePanel()
            }

            FocusScope {
                id: focusScope
                anchors.fill: parent
                focus: true
                visible: shouldShow

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        clipboardPanel.closePanel()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (clipList.currentIndex >= 0 && clipList.currentIndex < clipList.count) {
                            const item = filteredItems[clipList.currentIndex]
                            clipboardPanel.performCopy(item)
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Delete) {
                        if (sharedState.mode === "clipboard" && clipList.currentIndex >= 0 && clipList.currentIndex < clipList.count) {
                            const item = filteredItems[clipList.currentIndex]
                            ClipboardService.deleteEntry(item)
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Down) {
                        if (clipList.count > 0) {
                            if (clipList.currentIndex === clipList.count - 1) {
                                clipList.currentIndex = 0
                            } else {
                                clipList.currentIndex++
                            }
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Up) {
                        if (clipList.count > 0) {
                            if (clipList.currentIndex <= 0) {
                                clipList.currentIndex = clipList.count - 1
                            } else {
                                clipList.currentIndex--
                            }
                        }
                        event.accepted = true
                        return
                    }

                    if (event.text && event.text.length > 0 && !searchField.activeFocus) {
                        searchField.forceActiveFocus()
                    }
                }

                property var filteredItems: sharedState.mode === "emoji"
                    ? Emojis.fuzzyQuery(searchField.text)
                    : ClipboardService.fuzzyQuery(searchField.text)

                MouseArea {
                    anchors.fill: parent
                    enabled: sharedState.isOpen
                    onClicked: {
                        clipboardPanel.closePanel()
                    }
                }

                Item {
                    id: popupContainer
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: content.width
                    height: 700

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: sharedState.isOpen && shouldShow
                    }

                    PopupShape {
                        id: content
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 600
                        height: (sharedState.isOpen && shouldShow) ? 700 : 0

                        style: 1
                        alignment: 0
                        radius: 24
                        color: Appearance.colors.cSurfaceContainerLowest

                        Behavior on height {
                            NumberAnimation {
                                duration: clipboardPanel.slideDuration
                                easing.type: Easing.OutCubic
                            }
                        }

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            anchors.bottomMargin: 12

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
                                    duration: clipboardPanel.slideDuration
                                    easing.type: Easing.OutCubic
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    StyledText {
                                        text: sharedState.mode === "emoji" ? "Emoji Picker" : "Clipboard History"
                                        color: Appearance.colors.cOnSurface
                                        font.pixelSize: 20
                                        font.bold: true
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        radius: 8
                                        color: clearMouseArea.containsMouse ? Appearance.colors.cErrorContainer : "transparent"
                                        visible: sharedState.mode === "clipboard"

                                        Behavior on color {
                                            ColorAnimation { duration: 200 }
                                        }

                                        MouseArea {
                                            id: clearMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                ClipboardService.wipe()
                                            }
                                        }

                                        StyledText {
                                            anchors.centerIn: parent
                                            color: Appearance.colors.cPrimary
                                            text: ""
                                            font.pixelSize: 18
                                        }
                                    }
                                }

                                TextField {
                                    id: searchField
                                    Layout.fillWidth: true
                                    implicitHeight: 48
                                    placeholderText: sharedState.mode === "emoji" ? "Type to search emojis..." : "Type to search clipboard..."
                                    placeholderTextColor: Appearance.colors.cOnSurface

                                    background: Rectangle {
                                        color: Appearance.colors.cSurfaceContainer
                                        radius: 12
                                    }
                                    color: Appearance.colors.cOnSurface
                                    font.pixelSize: 16
                                    leftPadding: 16
                                    rightPadding: 16
                                    onTextChanged: {
                                        clipList.currentIndex = clipList.count > 0 ? 0 : -1
                                    }
                                }

                                ListView {
                                    id: clipList
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    spacing: 8
                                    highlightFollowsCurrentItem: true
                                    keyNavigationWraps: true
                                    highlightMoveDuration: 0
                                    model: focusScope.filteredItems

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                    }

                                    delegate: Rectangle {
                                        required property string modelData
                                        required property int index
                                        implicitWidth: clipList.width
                                        implicitHeight: 72
                                        radius: 12
                                        color: (clipList.currentIndex === index) ? Appearance.colors.cPrimary :
                                            (clipMouseArea.containsMouse ? Appearance.colors.cSurfaceVariant : "transparent")

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 0
                                            }
                                        }

                                        property string displayText: {
                                            const parts = modelData.split('\t')
                                            return parts.length > 1 ? parts.slice(1).join('\t') : modelData
                                        }

                                        MouseArea {
                                            id: clipMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                                            onClicked: (mouse) => {
                                                if (mouse.button === Qt.RightButton && sharedState.mode === "clipboard") {
                                                    ClipboardService.deleteEntry(modelData)
                                                } else {
                                                    clipboardPanel.performCopy(modelData)
                                                }
                                            }
                                            onEntered: {
                                                clipList.currentIndex = index
                                            }
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 16
                                            anchors.rightMargin: 16
                                            anchors.topMargin: 16
                                            anchors.bottomMargin: 16
                                            spacing: 16

                                            Rectangle {
                                                Layout.preferredWidth: 40
                                                Layout.preferredHeight: 40
                                                Layout.alignment: Qt.AlignTop
                                                radius: 8
                                                color: (clipList.currentIndex === index) ? Appearance.colors.cPrimary :
                                                    Appearance.colors.cPrimary

                                                Behavior on color {
                                                    ColorAnimation { duration: 0 }
                                                }

                                                StyledText {
                                                    anchors.centerIn: parent
                                                    text: sharedState.mode === "emoji" ? "" : ""
                                                    font.pixelSize: 20
                                                }
                                            }

                                            StyledText {
                                                id: contentText
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                text: displayText
                                                color: (clipList.currentIndex === index) ? Appearance.colors.cOnPrimary :
                                                    Appearance.colors.cOnSurface
                                                font.pixelSize: 14
                                                wrapMode: Text.Wrap
                                                elide: Text.ElideRight
                                                maximumLineCount: 4

                                                Behavior on color {
                                                    ColorAnimation { duration: 0; easing.type: Easing.InOutQuad }
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
    }
}
