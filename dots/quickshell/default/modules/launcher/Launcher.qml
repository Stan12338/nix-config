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
import qs.services.niri

Scope {

    QtObject {
        id: sharedState
        property bool isOpen: false
        property string openedOnMonitor: ""
        property string mode: "launcher"
    }

    IpcHandler {
        id: ipc
        target: "launcher"

        function toggle() {
            if (!sharedState.isOpen) {
                if (Compositor.compositor === "hyprland") {
                    sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
                } else if (Compositor.compositor === "niri") {
                    sharedState.openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
                }
            }
            sharedState.isOpen = !sharedState.isOpen
        }

        function open() {
            Quickshell.execDetached(["qs", "ipc", "call", "powermenu", "close"])
            if (!sharedState.isOpen) {
                if (Compositor.compositor === "hyprland") {
                    sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
                } else if (Compositor.compositor === "niri") {
                    sharedState.openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
                }
            }
            sharedState.isOpen = true
        }

        function close() {
            sharedState.isOpen = false
        }

        function toggle_launcher() {
            if (sharedState.mode === "launcher" && sharedState.isOpen) {
                close()
            } else {
                sharedState.mode = "launcher"
                open()
            }
        }

        function toggle_clipboard() {
            if (sharedState.mode === "clipboard" && sharedState.isOpen) {
                close()
            } else {
                sharedState.mode = "clipboard"
                open()
            }
        }

        function toggle_emoji() {
            if (sharedState.mode === "emoji" && sharedState.isOpen) {
                close()
            } else {
                sharedState.mode = "emoji"
                open()
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            id: popupPanel
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
                interval: popupPanel.slideDuration + 100
                repeat: false
                onTriggered: {
                    popupPanel.WlrLayershell.layer = WlrLayer.Background
                    popupPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                    popupPanel.mask = null
                }
            }

            Connections {
                target: sharedState

                function onIsOpenChanged() {
                    if (sharedState.isOpen) {
                        closeDelayTimer.stop()
                        popupPanel.WlrLayershell.layer = WlrLayer.Top
                        popupPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        popupPanel.mask = null

                        if (shouldShow) {
                            focusScope.forceActiveFocus()
                            if (contentLoader.item && contentLoader.item.reset) {
                                contentLoader.item.reset()
                            }
                        }
                    } else {
                        popupPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                        closeDelayTimer.start()
                    }
                }

                function onModeChanged() {
                    if (sharedState.isOpen && shouldShow) {
                        focusScope.forceActiveFocus()
                        if (contentLoader.item && contentLoader.item.reset) {
                            contentLoader.item.reset()
                        }
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
                        popupPanel.closePanel()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (contentLoader.item && contentLoader.item.executeCurrentItem) {
                            contentLoader.item.executeCurrentItem()
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Delete) {
                        if (sharedState.mode === "clipboard" && contentLoader.item && contentLoader.item.deleteCurrentItem) {
                            contentLoader.item.deleteCurrentItem()
                        }
                        event.accepted = true
                        return
                    }

                    if (!contentLoader.item) return

                    if (event.key === Qt.Key_Down) {
                        if (contentLoader.item.count > 0) {
                            if (contentLoader.item.currentIndex === contentLoader.item.count - 1) {
                                contentLoader.item.currentIndex = 0
                            } else {
                                contentLoader.item.currentIndex++
                            }
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Up) {
                        if (contentLoader.item.count > 0) {
                            if (contentLoader.item.currentIndex <= 0) {
                                contentLoader.item.currentIndex = contentLoader.item.count - 1
                            } else {
                                contentLoader.item.currentIndex--
                            }
                        }
                        event.accepted = true
                        return
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: sharedState.isOpen
                    onClicked: {
                        popupPanel.closePanel()
                    }
                }

                Item {
                    id: popupContainer
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: content.width
                    height: (sharedState.isOpen && shouldShow) ? screen.height > 800 ? 700 : 600 : 0

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: sharedState.isOpen && shouldShow
                    }

                    PopupShape {
                        id: content
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter

                        implicitWidth: 600
                        implicitHeight: (sharedState.isOpen && shouldShow) ? screen.height > 800 ? 700 : 600 : 0

                        style: 1
                        alignment: 0
                        radius: 24
                        color: Appearance.colors.cSurfaceContainerLowest

                        Behavior on implicitHeight {
                            NumberAnimation {
                                duration: popupPanel.slideDuration
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
                                    duration: popupPanel.slideDuration
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Loader {
                                id: contentLoader
                                anchors.fill: parent

                                sourceComponent: {
                                    switch(sharedState.mode) {
                                        case "clipboard": return clipboardComponent
                                        case "emoji": return emojiComponent
                                        default: return launcherComponent
                                    }
                                }

                                onLoaded: {
                                    item.opacity = 0
                                    item.scale = 0.95
                                    entranceAnimation.restart()

                                    // 3. Keep your existing logic for signals
                                    if (item && item.closeRequested !== undefined) {
                                        item.closeRequested.connect(popupPanel.closePanel)
                                    }
                                }

                                ParallelAnimation {
                                    id: entranceAnimation
                                    NumberAnimation {
                                        target: contentLoader.item
                                        property: "opacity"
                                        from: 0
                                        to: 1
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                    NumberAnimation {
                                        target: contentLoader.item
                                        property: "scale"
                                        from: 0.95
                                        to: 1.0
                                        duration: 250
                                        easing.type: Easing.OutBack
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: launcherComponent

        Item {
            id: launcherRoot

            signal closeRequested()

            property alias currentIndex: appList.currentIndex
            property alias count: appList.count

            function reset() {
                searchField.text = ""
                if (appList.count > 0) {
                    appList.currentIndex = 0
                } else {
                    appList.currentIndex = -1
                }
                searchField.forceActiveFocus()
            }

            function executeCurrentItem() {
                if (appList.currentIndex >= 0 && appList.currentIndex < appList.count) {
                    var app = appList.model[appList.currentIndex]
                    AppSearch.trackAppLaunch(app.id)
                    app.execute()
                    closeRequested()
                } else if (appList.count > 0) {
                    const filteredApps = AppSearch.fuzzyQuery(searchField.text)
                    if (filteredApps.length > 0) {
                        AppSearch.trackAppLaunch(filteredApps[0].id)
                        filteredApps[0].execute()
                        closeRequested()
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 16

                StyledText {
                    text: "Applications"
                    color: Appearance.colors.cOnSurface
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    implicitHeight: 48
                    placeholderText: "Type to search applications..."
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
                        appList.currentIndex = appList.count > 0 ? 0 : -1
                    }
                }

                ListView {
                    id: appList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    highlightFollowsCurrentItem: true
                    keyNavigationWraps: true
                    highlightMoveDuration: 0
                    model: AppSearch.fuzzyQuery(searchField.text)

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Rectangle {
                        required property DesktopEntry modelData
                        required property int index
                        width: appList.width
                        height: 64
                        radius: 12
                        color: (appList.currentIndex === index) ? Appearance.colors.cPrimary :
                            (appMouseArea.containsMouse ? Appearance.colors.cSurfaceVariant : "transparent")

                        Behavior on color {
                            ColorAnimation { duration: 0 }
                        }

                        MouseArea {
                            id: appMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                AppSearch.trackAppLaunch(modelData.id)
                                modelData.execute()
                                launcherRoot.closeRequested()
                            }
                            onEntered: {
                                appList.currentIndex = index
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 16

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: 8
                                color: "transparent"

                                property string resolvedIcon: {
                                    const iconName = modelData.icon || modelData.id || modelData.name
                                    const guessedIcon = AppSearch.guessIcon(iconName)
                                    const guessedPath = Quickshell.iconPath(guessedIcon, true)
                                    if ((!guessedPath || guessedPath.length === 0) && modelData.icon) {
                                        const originalPath = Quickshell.iconPath(modelData.icon, true)
                                        if (originalPath && originalPath.length > 0) {
                                            return modelData.icon
                                        }
                                    }
                                    if (!guessedPath || guessedPath.length === 0) {
                                        return ""
                                    }
                                    return guessedIcon
                                }

                                property bool shouldShowFallback: !resolvedIcon || resolvedIcon.length === 0

                                Image {
                                    anchors.fill: parent
                                    source: parent.resolvedIcon ? "image://icon/" + parent.resolvedIcon : ""
                                    sourceSize.width: 40
                                    sourceSize.height: 40
                                    smooth: true
                                    asynchronous: true
                                    cache: true
                                    fillMode: Image.PreserveAspectFit
                                    visible: !parent.shouldShowFallback

                                    onStatusChanged: {
                                        if (status === Image.Error || status === Image.Null) {
                                            parent.shouldShowFallback = true
                                        } else if (status === Image.Ready) {
                                            parent.shouldShowFallback = false
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 8
                                    color: (appList.currentIndex === index) ? Appearance.colors.cPrimary :
                                        Appearance.colors.cPrimaryContainer
                                    visible: parent.shouldShowFallback

                                    Behavior on color {
                                        ColorAnimation { duration: 0 }
                                    }

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: modelData.name.charAt(0).toUpperCase()
                                        color: (appList.currentIndex === index) ? Appearance.colors.cOnPrimary :
                                            Appearance.colors.cPrimary
                                        font.pixelSize: 20
                                        font.weight: Font.Bold

                                        Behavior on color {
                                            ColorAnimation { duration: 0 }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                StyledText {
                                    text: modelData.name
                                    color: (appList.currentIndex === index) ? Appearance.colors.cOnPrimary :
                                        Appearance.colors.cOnSurface
                                    font.pixelSize: 15
                                    font.weight: Font.Medium
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight

                                    Behavior on color {
                                        ColorAnimation { duration: 0; easing.type: Easing.InOutQuad }
                                    }
                                }

                                StyledText {
                                    text: modelData.genericName || modelData.comment || ""
                                    color: (appList.currentIndex === index) ? Appearance.colors.cOnPrimary :
                                        Appearance.colors.cOnSurfaceVariant
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    visible: text !== ""

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

    Component {
        id: clipboardComponent

        Item {
            id: clipboardRoot

            signal closeRequested()

            property alias currentIndex: clipList.currentIndex
            property alias count: clipList.count
            property var filteredItems: ClipboardService.fuzzyQuery(searchField.text)

            function reset() {
                ClipboardService.refresh()
                searchField.text = ""
                if (clipList.count > 0) {
                    clipList.currentIndex = 0
                } else {
                    clipList.currentIndex = -1
                }
                searchField.forceActiveFocus()
            }

            function executeCurrentItem() {
                if (clipList.currentIndex >= 0 && clipList.currentIndex < clipList.count) {
                    const item = filteredItems[clipList.currentIndex]
                    ClipboardService.copy(item)
                    closeRequested()
                }
            }

            function deleteCurrentItem() {
                if (clipList.currentIndex >= 0 && clipList.currentIndex < clipList.count) {
                    const item = filteredItems[clipList.currentIndex]
                    ClipboardService.deleteEntry(item)
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    StyledText {
                        text: "Clipboard History"
                        color: Appearance.colors.cOnSurface
                        font.pixelSize: 20
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                    }


                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        radius: 8
                        color: clearMouseArea.containsMouse ? Appearance.colors.cErrorContainer : "transparent"

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
                    placeholderText: "Type to search clipboard..."
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
                    model: clipboardRoot.filteredItems

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
                            ColorAnimation { duration: 0 }
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
                                if (mouse.button === Qt.RightButton) {
                                    ClipboardService.deleteEntry(modelData)
                                } else {
                                    ClipboardService.copy(modelData)
                                    clipboardRoot.closeRequested()
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
                                color: Appearance.colors.cPrimary

                                StyledText {
                                    anchors.centerIn: parent
                                    text: ""
                                    font.pixelSize: 20
                                }
                            }

                            StyledText {
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

    Component {
        id: emojiComponent

        Item {
            id: emojiRoot

            signal closeRequested()

            property alias currentIndex: emojiList.currentIndex
            property alias count: emojiList.count
            property var filteredItems: Emojis.fuzzyQuery(searchField.text)

            function reset() {
                searchField.text = ""
                if (emojiList.count > 0) {
                    emojiList.currentIndex = 0
                } else {
                    emojiList.currentIndex = -1
                }
                searchField.forceActiveFocus()
            }

            function executeCurrentItem() {
                if (emojiList.currentIndex >= 0 && emojiList.currentIndex < emojiList.count) {
                    const item = filteredItems[emojiList.currentIndex]
                    const emojiOnly = item.split(' ')[0]
                    ClipboardService.copyRaw(emojiOnly)
                    closeRequested()
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 16

                StyledText {
                    text: "Emoji Picker"
                    color: Appearance.colors.cOnSurface
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    implicitHeight: 48
                    placeholderText: "Type to search emojis..."
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
                        emojiList.currentIndex = emojiList.count > 0 ? 0 : -1
                    }
                }

                ListView {
                    id: emojiList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    highlightFollowsCurrentItem: true
                    keyNavigationWraps: true
                    highlightMoveDuration: 0
                    model: emojiRoot.filteredItems

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Rectangle {
                        required property string modelData
                        required property int index
                        implicitWidth: emojiList.width
                        implicitHeight: 72
                        radius: 12
                        color: (emojiList.currentIndex === index) ? Appearance.colors.cPrimary :
                            (emojiMouseArea.containsMouse ? Appearance.colors.cSurfaceVariant : "transparent")

                        Behavior on color {
                            ColorAnimation { duration: 0 }
                        }

                        MouseArea {
                            id: emojiMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const emojiOnly = modelData.split(' ')[0]
                                ClipboardService.copyRaw(emojiOnly)
                                emojiRoot.closeRequested()
                            }
                            onEntered: {
                                emojiList.currentIndex = index
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
                                color: Appearance.colors.cPrimary

                                StyledText {
                                    anchors.centerIn: parent
                                    text: ""
                                    font.pixelSize: 20
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: modelData
                                color: (emojiList.currentIndex === index) ? Appearance.colors.cOnPrimary :
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
