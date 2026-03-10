import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.widgets
import qs.services
import Quickshell.Io

Scope {

    QtObject {
        id: sharedState
        property bool isOpen: false
        property string openedOnMonitor: ""
    }

    IpcHandler {
        id: ipc
        target: "applauncher"

        function toggle() {
            Quickshell.execDetached(["qs", "ipc", "call", "powermenu", "close"])
            Quickshell.execDetached(["qs", "ipc", "call", "clipboard", "close"])
            if (!sharedState.isOpen) {
                sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
            }
            sharedState.isOpen = !sharedState.isOpen
        }

        function open() {
            Quickshell.execDetached(["qs", "ipc", "call", "powermenu", "close"])
            Quickshell.execDetached(["qs", "ipc", "call", "clipboard", "close"])
            if (!sharedState.isOpen) {
                sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
            }
            sharedState.isOpen = true
        }

        function close() {
            sharedState.isOpen = false
        }
    }

    Variants {
        model: Quickshell.screens


        PanelWindow {
            required property var modelData

            id: launcherPanel
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
                interval: launcherPanel.slideDuration + 100
                repeat: false
                onTriggered: {
                    launcherPanel.WlrLayershell.layer = WlrLayer.Background
                    launcherPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                    launcherPanel.mask = null
                }
            }

            Connections {
                target: sharedState

                function onIsOpenChanged() {
                    if (sharedState.isOpen) {
                        closeDelayTimer.stop()
                        launcherPanel.WlrLayershell.layer = WlrLayer.Top
                        launcherPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        launcherPanel.mask = null

                        if (shouldShow) {
                            searchField.text = ""
                            if (appList.count > 0) {
                                appList.currentIndex = 0
                            } else {
                                appList.currentIndex = -1
                            }
                            focusScope.forceActiveFocus()
                            searchField.forceActiveFocus()
                        }
                    } else {
                        searchField.text = ""
                        launcherPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                        closeDelayTimer.start()
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
                        launcherPanel.closePanel()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (appList.currentIndex >= 0 && appList.currentIndex < appList.count) {
                            var app = appList.model[appList.currentIndex]

                            AppSearch.trackAppLaunch(app.id)
                            app.execute()
                            launcherPanel.closePanel()
                        } else if (appList.count > 0) {
                            const filteredApps = AppSearch.fuzzyQuery(searchField.text)
                            if (filteredApps.length > 0) {
                                AppSearch.trackAppLaunch(filteredApps[0].id)
                                filteredApps[0].execute()
                                launcherPanel.closePanel()
                            }
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Down) {
                        if (appList.count > 0) {
                            if (appList.currentIndex === appList.count - 1) {
                                appList.currentIndex = 0
                            } else {
                                appList.currentIndex++
                            }
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Up) {
                        if (appList.count > 0) {
                            if (appList.currentIndex <= 0) {
                                appList.currentIndex = appList.count - 1
                            } else {
                                appList.currentIndex--
                            }
                        }
                        event.accepted = true
                        return
                    }

                    if (event.text && event.text.length > 0 && !searchField.activeFocus) {
                        searchField.forceActiveFocus()
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: sharedState.isOpen
                    onClicked: {
                        launcherPanel.closePanel()
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
                                duration: launcherPanel.slideDuration
                                easing.type: Easing.OutCubic
                            }
                        }

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            anchors.bottomMargin: 12
                            // anchors.topMargin: 12

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
                                    duration: launcherPanel.slideDuration
                                    easing.type: Easing.OutCubic
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
                                            ColorAnimation {
                                                duration: 0
                                            }
                                        }

                                        MouseArea {
                                            id: appMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                AppSearch.trackAppLaunch(modelData.id)
                                                modelData.execute()
                                                launcherPanel.closePanel()
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
                                                    id: appIcon
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
                                                    id: fallback
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
                }
            }
        }
    }
}
