import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs.config
import QtQuick.Controls
import qs.services
import qs.widgets.fakedows

Scope {
    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: rootPanel
                required property var modelData
                screen: modelData
                WlrLayershell.layer: WlrLayer.Overlay

                color: "transparent"
                anchors {
                    bottom: true
                    left: true
                    right: true
                }
                property bool popupPinned: false

                implicitHeight: 48

                property Item hoveredItem: null

                Timer {
                    id: hideTimer
                    interval: 100
                    onTriggered: rootPanel.hoveredItem = null
                }

                Timer {
                    id: hoverTimer
                    interval: 400
                    onTriggered: rootPanel.hoveredItem = pendingHoverItem
                }

                Timer {
                    id: clockTimer
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        timeText.text = Qt.formatTime(new Date(), "h:mm AP")
                        dateText.text = Qt.formatDate(new Date(), "M/d/yyyy")
                    }
                }

                property Item pendingHoverItem: null

                PopupWindow {
                    anchor.window: rootPanel
                    anchor.rect.x: rootPanel.hoveredItem
                        ? rootPanel.hoveredItem.mapToItem(null, 0, 0).x + (rootPanel.hoveredItem.width / 2) - width / 2
                        : rootPanel.width / 2 - width / 2
                    anchor.rect.y: -height
                    anchor.edges: Edges.Bottom

                    implicitHeight: 212 - 42
                    implicitWidth: 218
                    color: "transparent"
                    visible: rootPanel.hoveredItem !== null && rootPanel.hoveredItem.isRunning

                    MouseArea {
                        id: popupmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            hideTimer.stop()
                            hoverTimer.stop()
                        }
                        onExited: {
                            if (!rootPanel.popupPinned){
                                hideTimer.restart()
                            }
                        }
                        onClicked: {
                            if (rootPanel.hoveredItem) {
                                const item = rootPanel.hoveredItem
                                if (item.modelData.toplevels.length > 0) {
                                    item.modelData.toplevels[0].activate()
                                } else {
                                    const entry = DesktopEntries.byId(item.modelData.appId)
                                    if (entry) entry.execute()
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: popupRect
                        color: popupmouse.containsMouse ? "#383838" : "#2c2c2c"
                        anchors.fill: parent
                        anchors.bottomMargin: 12
                        radius: 8

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 8

                                Image {
                                    Layout.alignment: Qt.AlignVCenter
                                    source: rootPanel.hoveredItem
                                        ? Quickshell.iconPath(rootPanel.hoveredItem.modelData.appId)
                                        : ""
                                    sourceSize.width: 20
                                    sourceSize.height: 20

                                }

                                StyledText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: rootPanel.hoveredItem
                                        ? (rootPanel.hoveredItem.modelData.toplevels[0]?.title
                                            ?? rootPanel.hoveredItem.modelData.name
                                            ?? "")
                                        : ""
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    color: "white"
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                Item {
                                    implicitWidth: 24
                                    implicitHeight: 24


                                    Layout.alignment: Qt.AlignVCenter

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "red"
                                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                        opacity: 0
                                        radius: 2
                                        MouseArea {
                                            hoverEnabled: true
                                            anchors.fill: parent
                                            // propagateComposedEvents: true
                                            onEntered: {
                                                hideTimer.stop()
                                                rootPanel.popupPinned = true
                                                parent.opacity = 1
                                            }
                                            onExited: {
                                                rootPanel.popupPinned = false
                                                parent.opacity = 0
                                                hideTimer.restart()
                                            }
                                            onClicked: (mouse) => {
                                                rootPanel.hoveredItem.modelData.toplevels[0].close()
                                                mouse.accepted = false
                                            }
                                        }
                                    }

                                    StyledText {
                                        text: "󰖭"
                                        anchors.centerIn: parent
                                        color: "white"
                                        font.pixelSize: 20
                                    }




                                }
                            }

                            ScreencopyView {
                                Layout.alignment: Qt.AlignBottom
                                Layout.fillWidth: true
                                implicitHeight: 108
                                captureSource: rootPanel.hoveredItem
                                    ? (rootPanel.hoveredItem.modelData.toplevels.length > 0
                                        ? rootPanel.hoveredItem.modelData.toplevels[0]
                                        : null)
                                    : null
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#1c1c1c"
                    opacity: 1

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.alignment: Qt.AlignTop
                            Layout.fillWidth: true
                            color: "#404040"
                            implicitHeight: 1
                        }

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Row {
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.centerIn: parent
                                spacing: 5
                                populate: Transition { NumberAnimation { properties: "x,y"; duration: 0 } }
                                add: Transition { NumberAnimation { properties: "x,y"; duration: 0 } }
                                move: Transition { NumberAnimation { properties: "x,y"; duration: 250; easing.type: Easing.OutQuad } }

                                Item {
                                    implicitHeight: 40
                                    implicitWidth: 40

                                    MouseArea {
                                        id: windowsMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            Quickshell.execDetached(["qs", "ipc", "call", "startmenu", "toggle"])
                                        }
                                    }

                                    Rectangle {
                                        id: windowsHover
                                        anchors.fill: parent
                                        anchors.centerIn: parent
                                        radius: 4
                                        color: "#292929"
                                        opacity: windowsMouse.containsMouse ? 1 : Appearance.startMenuOpened ? 1 : 0
                                        Behavior on opacity { NumberAnimation{duration: 200; easing.type: Easing.InOutQuad} }
                                        border {
                                            width: 1
                                            color: "#2f2f2f"
                                        }
                                    }

                                    Image {
                                        anchors.centerIn: parent
                                        source: "../../images/windows.png"
                                        scale: windowsMouse.pressed ? 0.8 : 1
                                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
                                    }
                                }

                                Repeater {
                                    model: TaskManager.entries

                                    delegate: Item {
                                        id: delegateRoot
                                        required property var modelData
                                        required property int index

                                        implicitHeight: 40
                                        implicitWidth: 40
                                        z: dragHandler.active ? 999 : 0

                                        property real dragOffsetX: 0

                                        transform: Translate { x: delegateRoot.dragOffsetX }

                                        Behavior on dragOffsetX {
                                            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                                        }

                                        property bool isPinned: modelData.pinned
                                        property bool isRunning: modelData.toplevels.length > 0
                                        property bool isActive: {
                                            for (const t of modelData.toplevels)
                                                if (t.activated) return true
                                            return false
                                        }

                                        property int windowCount: modelData.toplevels.length
                                        property bool multipleWindows: windowCount > 1

                                        Rectangle {
                                            id: iconContainer
                                            anchors.centerIn: parent
                                            width: 40
                                            height: 40
                                            radius: 4
                                            border {
                                                width: isActive && !appMouse.containsMouse ? 1 : 0
                                                color: "#2f2f2f"
                                            }
                                            color: isActive && !appMouse.containsMouse ? "#292929" : "#2f2f2f"
                                            opacity: isActive ? 1 : appMouse.containsMouse || dragHandler.active ? 1 : 0
                                            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                        }

                                        Image {
                                            id: appIcon
                                            anchors.centerIn: parent
                                            source: modelData.iconName !== ""
                                                ? "image://icon/" + modelData.iconName
                                                : Quickshell.iconPath(modelData.appId)
                                            sourceSize.width: 28
                                            sourceSize.height: 28
                                            scale: dragHandler.active ? 1.25 : appMouse.pressed ? 0.8 : 1
                                            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
                                        }

                                        Rectangle {
                                            visible: isRunning
                                            color: "#a6a5a1"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            implicitHeight: 3
                                            implicitWidth: isActive ? 16 : 6
                                            Behavior on implicitWidth { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: 1
                                            radius: 2
                                        }

                                        MouseArea {
                                            id: appMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                                            propagateComposedEvents: true

                                            onEntered: {
                                                hideTimer.stop()
                                                rootPanel.pendingHoverItem = delegateRoot
                                                hoverTimer.restart()
                                            }
                                            onExited: {
                                                hoverTimer.stop()
                                                if (rootPanel.hoveredItem === delegateRoot)
                                                    hideTimer.restart()
                                            }

                                            onClicked: (mouse) => {
                                                if (dragHandler.active) return

                                                if (mouse.button === Qt.LeftButton) {
                                                    if (modelData.toplevels.length > 0) {
                                                        modelData.toplevels[0].activate()
                                                    } else {
                                                        const entry = DesktopEntries.byId(modelData.appId)
                                                        if (entry) entry.execute()
                                                    }
                                                } else {
                                                    contextMenu.popup()
                                                }
                                            }
                                        }

                                        Menu {
                                            id: contextMenu
                                            MenuItem {
                                                text: isPinned ? "Unpin from Taskbar" : "Pin to Taskbar"
                                                onTriggered: TaskManager.togglePin(modelData.appId)
                                            }
                                        }

                                        DragHandler {
                                            id: dragHandler
                                            xAxis.enabled: true
                                            yAxis.enabled: false
                                            target: null

                                            property int startIndex: -1
                                            property real startX: 0

                                            onActiveChanged: {
                                                if (active) {
                                                    startIndex = index
                                                    startX = dragHandler.centroid.scenePosition.x
                                                } else {
                                                    const slotWidth = 45
                                                    const deltaX = dragHandler.centroid.scenePosition.x - startX
                                                    const shift = Math.round(deltaX / slotWidth)

                                                    const targetIndex = Math.max(0, Math.min(
                                                        TaskManager.entries.length - 1,
                                                        startIndex + shift
                                                    ))

                                                    if (targetIndex !== startIndex)
                                                        TaskManager.move(startIndex, targetIndex)

                                                    delegateRoot.dragOffsetX = 0
                                                }
                                            }

                                            onCentroidChanged: {
                                                if (!active) return
                                                delegateRoot.dragOffsetX = dragHandler.centroid.scenePosition.x - startX
                                            }
                                        }
                                    }
                                }
                            }
                            Row {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.topMargin: 3
                                anchors.bottomMargin: 3
                                anchors.rightMargin: 11

                                Item {
                                    implicitWidth: 32
                                    implicitHeight: parent.height
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        color: trayMouse.pressed ? "#2f2f2f" : "#292929"
                                        opacity: 0
                                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }

                                        MouseArea {
                                            id: trayMouse
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
                                        color: "white"

                                        text: ""
                                        font.pixelSize: 15
                                        font.weight: 750
                                        anchors.centerIn: parent




                                    }

                                }

                                Item {
                                    implicitWidth: 44
                                    implicitHeight: parent.height
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        color: langMouse.pressed ? "#2f2f2f" : "#292929"
                                        opacity: 0
                                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }

                                        MouseArea {
                                            id: langMouse
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
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        anchors.centerIn: parent
                                        spacing: 0
                                        StyledText {
                                            color: "white"

                                            text: "ENG"
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignHCenter
                                            horizontalAlignment: Text.AlignHCenter


                                        }

                                        StyledText {

                                            color: "white"
                                            text: "US"
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignHCenter
                                            horizontalAlignment: Text.AlignHCenter

                                        }
                                    }


                                }

                                Item {
                                    implicitWidth: Battery.percentage ? 84 : 56
                                    implicitHeight: parent.height
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        color: controlMouse.pressed ? "#2f2f2f" :"#292929"

                                        opacity: controlMouse.containsMouse || Appearance.controlPanelOpened ? 1 : 0
                                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        MouseArea {
                                            id: controlMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                Quickshell.execDetached(["qs", "ipc", "call", "control", "toggle"])
                                            }

                                        }
                                    }
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.topMargin: 12
                                        anchors.bottomMargin: 12
                                        anchors.leftMargin: 8
                                        anchors.rightMargin:8
                                        spacing: 0
                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            Image {
                                                anchors.centerIn: parent
                                                source: "../../images/wifi-full.png"
                                            }
                                        }
                                        Item {
                                            Layout.fillHeight: true
                                            implicitWidth: 8
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            Image {
                                                anchors.centerIn: parent
                                                source: "../../images/sound.png"
                                            }
                                        }
                                        Item {
                                            Layout.fillHeight: true
                                            implicitWidth: Battery.percentage ? 8 : 0
                                        }
                                        Loader {
                                            active: Battery.percentage
                                            Layout.fillWidth: Battery.percentage
                                            Layout.fillHeight: true
                                            Item {
                                                anchors.fill: parent
                                                Image {
                                                    anchors.centerIn: parent
                                                    source: "../../images/battery/"  + Battery.capacity + ".png"
                                                }
                                            }
                                        }

                                    }

                                }

                                Item {
                                    implicitWidth: Battery.percentage ? 95 : 86
                                    implicitHeight: parent.height
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        color: notifMouse.pressed ? "#2f2f2f" : "#292929"
                                        opacity: 0
                                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }

                                        MouseArea {
                                            id: notifMouse
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
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: Battery.percentage ? 9 : 0
                                        anchors.rightMargin: 9
                                        anchors.topMargin: 4
                                        anchors.bottomMargin: 4
                                        spacing: 8

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            spacing: 0
                                            StyledText {
                                                id: timeText
                                                color: "white"

                                                text: Qt.formatTime(new Date(), "h:mm AP")
                                                font.pixelSize: 11
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true

                                                elide: Text.ElideRight
                                                horizontalAlignment: Text.AlignRight

                                            }

                                            StyledText {
                                                id: dateText

                                                color: "white"
                                                text: Qt.formatDate(new Date(), "d/M/yyyy")
                                                font.pixelSize: 11
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                elide: Text.ElideRight
                                                horizontalAlignment: Text.AlignRight

                                            }
                                        }
                                        // Item {
                                        //     implicitWidth: 4
                                        // }
                                        Item {
                                            implicitWidth: 14
                                            Layout.fillHeight: true
                                            Image {
                                                anchors.centerIn: parent
                                                source: "../../images/bell.png"
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
