import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.config
import qs.widgets
import Quickshell.Hyprland
import qs.functions
import qs.services
import qs.services.niri

Scope {
    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"

    QtObject {
        id: sharedState
        property bool isOpen: false
        property string openedOnMonitor: ""
    }

    IpcHandler {
        id: ipc
        target: "wallpaperSwitcher"

        function toggle() {
            if (Compositor.compositor === "hyprland") {
                sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
            } else if (Compositor.compositor === "niri") {
                sharedState.openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
            }
            sharedState.isOpen = !sharedState.isOpen
        }

        function open() {
            if (Compositor.compositor === "hyprland") {
                sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
            } else if (Compositor.compositor === "niri") {
                sharedState.openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
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

            id: wallpaperWindow
            screen: modelData
            color: "transparent"

            readonly property bool shouldShow: modelData.name === sharedState.openedOnMonitor

            anchors {
                top: true
                bottom: true
                right: true
                left: true
            }

            margins.bottom: (Appearance.configDataLoaded && Appearance.barEdges) ? 12 : 0

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            mask: null

            // Reactive binding: automatically updates when Appearance changes
            readonly property string activeWallpaper: Appearance.wallpaper !== ""
                                                      ? "file://" + Appearance.wallpaper
                                                      : ""
            readonly property int slideDuration: 350
            property bool needsInitialization: false

            Timer {
                id: closeDelayTimer
                interval: wallpaperWindow.slideDuration + 10
                repeat: false
                onTriggered: {
                    wallpaperWindow.WlrLayershell.layer = WlrLayer.Background
                    wallpaperWindow.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                    wallpaperWindow.mask = null
                }
            }

            Connections {
                target: sharedState
                function onIsOpenChanged() {
                    if (sharedState.isOpen) {
                        closeDelayTimer.stop()
                        wallpaperWindow.WlrLayershell.layer = WlrLayer.Top
                        wallpaperWindow.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        wallpaperWindow.mask = null

                        if (shouldShow) {
                            fs.forceActiveFocus()
                            // Trigger selection logic immediately when opening
                            grid.initializeSelection()
                        }
                    } else {
                        closeDelayTimer.start()
                    }
                }
            }

            function setWallpaper(url) {
                var cleanPath = url.toString().replace("file://", "")
                Quickshell.execDetached(["matugen", "image", cleanPath, "-m", Appearance.isDark ? "dark" : "light", "-t", Appearance.scheme, "--source-color-index", 0])
            }

            function closePanel() {
                sharedState.isOpen = false
            }

            FocusScope {
                id: fs
                anchors.fill: parent
                focus: true
                visible: shouldShow

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        wallpaperWindow.closePanel()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                        if (grid.currentIndex < grid.count - 1) {
                            grid.currentIndex++
                        } else {
                            grid.currentIndex = 0
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                        if (grid.currentIndex > 0) {
                            grid.currentIndex--
                        } else {
                            grid.currentIndex = grid.count - 1
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                        var itemsPerRow = 4
                        if (grid.currentIndex + itemsPerRow < grid.count) {
                            grid.currentIndex += itemsPerRow
                        } else {
                            var currentColumn = grid.currentIndex % itemsPerRow
                            grid.currentIndex = currentColumn
                        }
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                        var itemsPerRow = 4
                        if (grid.currentIndex - itemsPerRow >= 0) {
                            grid.currentIndex -= itemsPerRow
                        } else {
                            var currentColumn = grid.currentIndex % itemsPerRow
                            var lastRowStart = Math.floor((grid.count - 1) / itemsPerRow) * itemsPerRow
                            var targetIndex = lastRowStart + currentColumn
                            if (targetIndex >= grid.count) {
                                targetIndex = lastRowStart + (grid.count - 1) % itemsPerRow
                            }
                            grid.currentIndex = targetIndex
                        }
                        event.accepted = true
                        return
                    }
                }

                MouseArea {
                    id: dimmer
                    anchors.fill: parent
                    enabled: sharedState.isOpen
                    onClicked: wallpaperWindow.closePanel()
                }

                Item {
                    id: popupContainer
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: content.width
                    height: 500

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    PopupShape {
                        id: content
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 800
                        height: (sharedState.isOpen && shouldShow) ? 500 : 0

                        style: 1
                        alignment: 4
                        radius: 24
                        color: Appearance.colors.cSurfaceContainerLowest

                        Behavior on height {
                            NumberAnimation {
                                duration: wallpaperWindow.slideDuration
                                easing.type: Easing.OutCubic
                            }
                        }

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20

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
                                    duration: wallpaperWindow.slideDuration
                                    easing.type: Easing.OutCubic
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 12

                                StyledText {
                                    text: "Select Wallpaper"
                                    color: Appearance.colors.cOnSurface
                                    font.pixelSize: 20
                                    font.bold: true
                                    Layout.alignment: Qt.AlignHCenter
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
                                                            return darkMouseArea.containsMouse ? ColorModifier.colorWithLightness(Appearance.colors.cOnPrimary, Qt.color(Appearance.colors.cOnPrimary).hslLightness + 0.1) : Appearance.colors.cOnPrimary
                                                        } else {
                                                            return darkMouseArea.containsMouse ? Appearance.colors.cPrimary : Appearance.colors.cOnSurface
                                                        }
                                                    }
                                                    font.weight: Appearance.isDark ? Font.Medium : Font.Normal
                                                    z: 2
                                                    Behavior on color {
                                                        ColorAnimation {
                                                            duration: 200
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
                                                            return lightMouseArea.containsMouse ? ColorModifier.colorWithLightness(Appearance.colors.cOnPrimary, Qt.color(Appearance.colors.cOnPrimary).hslLightness + 0.1) : Appearance.colors.cOnPrimary
                                                        } else {
                                                            return lightMouseArea.containsMouse ? Appearance.colors.cPrimary : Appearance.colors.cOnSurface
                                                        }
                                                    }
                                                    font.weight: !Appearance.isDark ? Font.Medium : Font.Normal
                                                    z: 2
                                                    Behavior on color {
                                                        ColorAnimation {
                                                            duration: 200
                                                            easing.type: Easing.InOutQuad
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                ScrollView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true

                                    GridView {
                                        id: grid
                                        cellWidth: width / 4
                                        cellHeight: cellWidth * 0.75
                                        focus: true
                                        interactive: true
                                        currentIndex: -1
                                        highlightFollowsCurrentItem: true
                                        highlightMoveDuration: 200

                                        cacheBuffer: 400

                                        property bool isInitializing: false
                                        property bool indexChangedByMouse: false

                                        function initializeSelection() {
                                            if (count === 0) {
                                                wallpaperWindow.needsInitialization = true
                                                return
                                            }

                                            isInitializing = true
                                            var foundIndex = -1

                                            // Find the index of the current wallpaper
                                            for (var i = 0; i < count; i++) {
                                                var itemUrl = model.get(i, "fileUrl").toString()
                                                if (itemUrl === wallpaperWindow.activeWallpaper) {
                                                    foundIndex = i
                                                    break
                                                }
                                            }

                                            if (foundIndex !== -1) {
                                                currentIndex = foundIndex
                                                Qt.callLater(scrollToCurrentItem)
                                            } else {
                                                currentIndex = 0
                                            }

                                            Qt.callLater(() => { isInitializing = false })
                                        }

                                        onCountChanged: {
                                            if (wallpaperWindow.needsInitialization && count > 0) {
                                                wallpaperWindow.needsInitialization = false
                                                Qt.callLater(initializeSelection)
                                            }
                                        }

                                        function scrollToCurrentItem() {
                                            if (currentIndex >= 0 && currentIndex < count) {
                                                positionViewAtIndex(currentIndex, GridView.Center)
                                            }
                                        }

                                        Timer {
                                            id: wallpaperChangeTimer
                                            interval: 200
                                            repeat: false
                                            property var pendingUrl: null
                                            onTriggered: {
                                                if (pendingUrl && !grid.isInitializing) {
                                                    wallpaperWindow.setWallpaper(pendingUrl)
                                                    pendingUrl = null
                                                }
                                            }
                                        }

                                        onCurrentIndexChanged: {
                                            if (isInitializing) {
                                                return
                                            }

                                            // Only set wallpaper if not changed by mouse hover (to avoid spamming while browsing)
                                            if (!indexChangedByMouse && currentIndex >= 0 && currentIndex < count) {
                                                var item = model.get(currentIndex, "fileUrl")
                                                // Only trigger if it's actually different
                                                if (item.toString() !== wallpaperWindow.activeWallpaper) {
                                                    wallpaperChangeTimer.pendingUrl = item
                                                    wallpaperChangeTimer.restart()
                                                }
                                            }

                                            indexChangedByMouse = false
                                        }

                                        model: FolderListModel {
                                            id: folderModel
                                            folder: "file://" + wallpaperDir
                                            nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif"]
                                            showDirs: false
                                        }

                                        delegate: Item {
                                            required property url fileUrl
                                            required property int index
                                            width: grid.cellWidth
                                            height: grid.cellHeight

                                            // Determine selection state based on the window's active wallpaper
                                            readonly property bool isSelected: fileUrl.toString() === wallpaperWindow.activeWallpaper
                                            readonly property bool isCurrentIndex: grid.currentIndex === index

                                            Rectangle {
                                                anchors.fill: parent
                                                anchors.margins: 5
                                                radius: 6
                                                border.width: 8
                                                color: "transparent"

                                                border.color: {
                                                    if (isCurrentIndex) return Appearance.colors.cSecondary
                                                    if (mouseArea.containsMouse) return Appearance.colors.cPrimary
                                                    if (isSelected) return Appearance.colors.cPrimary
                                                    return "transparent"
                                                }

                                                Behavior on border.color {
                                                    ColorAnimation {
                                                        duration: 200
                                                        easing.type: Easing.InOutQuad
                                                    }
                                                }

                                                Image {
                                                    anchors.fill: parent
                                                    anchors.margins: 4
                                                    fillMode: Image.PreserveAspectCrop
                                                    asynchronous: true
                                                    sourceSize.width: grid.cellWidth
                                                    sourceSize.height: grid.cellHeight
                                                    cache: true
                                                    source: fileUrl
                                                }
                                            }

                                            MouseArea {
                                                id: mouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    wallpaperWindow.setWallpaper(fileUrl)
                                                }
                                                onEntered: {
                                                    grid.indexChangedByMouse = true
                                                    grid.currentIndex = index
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
