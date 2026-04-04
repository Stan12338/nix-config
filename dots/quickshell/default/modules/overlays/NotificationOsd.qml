import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.services
import qs.widgets

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData

        id: notifOsd
        screen: modelData
        anchors {
            top: true
            right: true
        }

        margins {
            top: Appearance.barEdges ? 40 : 48
            right: Appearance.barEdges ? 12 : 24
        }

        implicitHeight: Quickshell.screens[0].height - 80
        implicitWidth: 420
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        color: "transparent"

        property bool isFocusedMonitor: Hyprland.focusedMonitor?.name === modelData.name
        visible:true

        Region {
            id: inputRegion
            item: notifShape
        }

        mask: inputRegion

        ListModel {
            id: stableNotifModel
        }

        property var trackedIds: ({})

        Timer {
            id: syncTimer
            interval: 16
            running: true
            repeat: true
            onTriggered: {
                const currentPopups = NotifServer.popups
                const currentIds = new Set()

                for (let i = 0; i < currentPopups.length; i++) {
                    const id = currentPopups[i].notification.id
                    currentIds.add(id)

                    if (!trackedIds[id]) {
                        stableNotifModel.append({
                            notifId: id,
                            notifData: currentPopups[i],
                            shouldRemove: false
                        })
                        trackedIds[id] = true
                    }
                }

                for (let i = 0; i < stableNotifModel.count; i++) {
                    const modelId = stableNotifModel.get(i).notifId
                    if (!currentIds.has(modelId) && !stableNotifModel.get(i).shouldRemove) {
                        stableNotifModel.setProperty(i, "shouldRemove", true)
                    }
                }
            }
        }

        Item {
            id: notifContainer
            anchors.top: parent.top
            anchors.right: parent.right
            width: 400
            height: parent.height

            property real targetX: Appearance.barEdges ? (stableNotifModel.count > 0 ? 0 : 450) : 0
            property real targetY: Appearance.barEdges ? 0 : (stableNotifModel.count > 0 ? 0 : -500)

            PopupShape {
                id: notifShape

                width: 400
                height: notifColumn.implicitHeight < 20 ? 0 : notifColumn.implicitHeight + 40

                x: notifContainer.targetX
                y: notifContainer.targetY

                Behavior on x {
                    enabled: Appearance.barEdges
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on y {
                    enabled: !Appearance.barEdges
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }

                style: 1
                alignment: Appearance.barEdges ? 1 : 0
                radius: 16
                color: Appearance.colors.cSurfaceContainerLowest

                visible: stableNotifModel.count > 0

                Flickable {
                    id: notifFlickable
                    anchors.fill: parent
                    anchors.bottomMargin: 16
                    anchors.leftMargin: 16
                    anchors.rightMargin: Appearance.barEdges ? 0 : 16

                    contentHeight: notifColumn.implicitHeight
                    clip: true

                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 6
                    }

                    ColumnLayout {
                        id: notifColumn
                        width: parent.width
                        spacing: 12

                        Repeater {
                            model: stableNotifModel

                            delegate: Item {
                                id: notifWrapper
                                required property int notifId
                                required property var notifData
                                required property bool shouldRemove
                                required property int index

                                Layout.fillWidth: true
                                Layout.preferredHeight: removing ? 0 : notifRect.height
                                clip: false

                                property bool removing: false
                                property bool hasAppeared: false
                                property real slideOffset: 400

                                Component.onCompleted: {
                                    hasAppeared = true
                                    slideOffset = 0
                                }

                                Component.onDestruction: {
                                    delete trackedIds[notifId]
                                }

                                onShouldRemoveChanged: {
                                    if (shouldRemove && !removing) {
                                        startDismissAnimation()
                                    }
                                }

                                function startDismissAnimation() {
                                    if (removing) {
                                        return
                                    }
                                    // If not yet at target position, animate back to 400
                                    if (slideOffset !== 400) {
                                        slideOffset = 400
                                    }
                                    collapseTimer.start()
                                }
                                Timer {
                                    id: collapseTimer
                                    interval: 300
                                    repeat: false
                                    onTriggered: {
                                        notifWrapper.removing = true
                                        dismissTimer.start()
                                    }
                                }

                                Timer {
                                    id: dismissTimer
                                    interval: 350
                                    repeat: false
                                    onTriggered: {
                                        for (let i = 0; i < stableNotifModel.count; i++) {
                                            if (stableNotifModel.get(i).notifId === notifId) {
                                                stableNotifModel.remove(i)
                                                break
                                            }
                                        }
                                    }
                                }

                                Behavior on slideOffset {
                                    enabled: hasAppeared
                                    NumberAnimation {
                                        duration: 400
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Behavior on Layout.preferredHeight {
                                    enabled: removing
                                    NumberAnimation {
                                        duration: 300
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Rectangle {
                                    id: notifRect

                                    width: parent.width
                                    height: contentColumn.implicitHeight + 24
                                    x: parent.slideOffset

                                    color: Appearance.colors.cSurfaceContainer
                                    radius: 12

                                    opacity: notifWrapper.removing ? 0 : 1

                                    Behavior on opacity {
                                        enabled: removing
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.InOutQuad
                                        }
                                    }

                                    ColumnLayout {
                                        id: contentColumn
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.margins: 12
                                        spacing: 0

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 12

                                            Rectangle {
                                                Layout.preferredWidth: 48
                                                Layout.preferredHeight: 48
                                                Layout.alignment: Qt.AlignTop
                                                radius: 8
                                                color: Appearance.colors.cPrimaryContainer

                                                Image {
                                                    anchors.fill: parent
                                                    source: notifData && notifData.appIcon ? "image://icon/" + notifData.appIcon : ""
                                                    sourceSize.width: 48
                                                    sourceSize.height: 48
                                                    smooth: true
                                                    asynchronous: true
                                                    fillMode: Image.PreserveAspectFit
                                                    visible: notifData && notifData.appIcon && notifData.appIcon.length > 0
                                                }

                                                StyledText {
                                                    anchors.centerIn: parent
                                                    text: notifData && notifData.appName ? notifData.appName.charAt(0).toUpperCase() : "N"
                                                    color: Appearance.colors.cPrimary
                                                    font.pixelSize: 24
                                                    font.weight: Font.Bold
                                                    visible: !notifData || !notifData.appIcon || notifData.appIcon.length === 0
                                                }
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignTop
                                                spacing: 4

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 8

                                                    StyledText {
                                                        text: notifData && notifData.appName ? notifData.appName : "Notification"
                                                        color: Appearance.colors.cOnSurface
                                                        font.pixelSize: 12
                                                        font.weight: Font.Medium
                                                        opacity: 0.7
                                                        Layout.fillWidth: true
                                                        elide: Text.ElideRight
                                                    }

                                                    StyledText {
                                                        text: notifData ? notifData.timeStr : ""
                                                        color: Appearance.colors.cOnSurface
                                                        font.pixelSize: 11
                                                        opacity: 0.5
                                                    }
                                                }

                                                StyledText {
                                                    text: notifData ? notifData.summary : ""
                                                    color: Appearance.colors.cOnSurface
                                                    font.pixelSize: 15
                                                    font.weight: Font.Bold
                                                    Layout.fillWidth: true
                                                    wrapMode: Text.Wrap
                                                    maximumLineCount: 2
                                                    elide: Text.ElideRight
                                                }

                                                StyledText {
                                                    text: notifData ? notifData.body : ""
                                                    color: Appearance.colors.cOnSurfaceVariant
                                                    font.pixelSize: 13
                                                    Layout.fillWidth: true
                                                    wrapMode: Text.Wrap
                                                    maximumLineCount: 3
                                                    elide: Text.ElideRight
                                                    visible: notifData && notifData.body && notifData.body.length > 0
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 120
                                                    Layout.topMargin: 4
                                                    radius: 8
                                                    color: "transparent"
                                                    clip: true
                                                    visible: notifData && notifData.image && notifData.image.length > 0

                                                    Image {
                                                        anchors.fill: parent
                                                        source: notifData && notifData.image ? notifData.image : ""
                                                        fillMode: Image.PreserveAspectCrop
                                                        smooth: true
                                                        asynchronous: true
                                                    }
                                                }

                                                Flow {
                                                    Layout.fillWidth: true
                                                    Layout.topMargin: 4
                                                    spacing: 8
                                                    visible: notifData && notifData.actions.length > 0

                                                    Repeater {
                                                        model: notifData ? notifData.actions : []

                                                        Rectangle {
                                                            required property var modelData

                                                            width: Math.min(actionText.implicitWidth + 24, 150)
                                                            height: 32
                                                            radius: 8
                                                            color: actionMouse.containsMouse ? Appearance.colors.cPrimary : Appearance.colors.cPrimaryContainer

                                                            Behavior on color {
                                                                ColorAnimation {
                                                                    duration: 200
                                                                    easing.type: Easing.InOutQuad
                                                                }
                                                            }

                                                            MouseArea {
                                                                id: actionMouse
                                                                anchors.fill: parent
                                                                hoverEnabled: true
                                                                cursorShape: Qt.PointingHandCursor
                                                                onClicked: {
                                                                    modelData.invoke()
                                                                    if (notifData) notifData.notification.dismiss()
                                                                    notifWrapper.startDismissAnimation()
                                                                }
                                                            }

                                                            StyledText {
                                                                id: actionText
                                                                anchors.centerIn: parent
                                                                text: modelData.text
                                                                color: actionMouse.containsMouse ? Appearance.colors.cOnPrimary : Appearance.colors.cOnPrimaryContainer
                                                                font.pixelSize: 12
                                                                font.weight: Font.Medium
                                                                elide: Text.ElideRight

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

                                            Rectangle {
                                                Layout.preferredWidth: 24
                                                Layout.preferredHeight: 24
                                                Layout.alignment: Qt.AlignTop
                                                radius: 12
                                                color: closeMouse.containsMouse ? Appearance.colors.cErrorContainer : "transparent"

                                                Behavior on color {
                                                    ColorAnimation {
                                                        duration: 200
                                                        easing.type: Easing.InOutQuad
                                                    }
                                                }

                                                MouseArea {
                                                    id: closeMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (notifData) notifData.notification.dismiss()
                                                        notifWrapper.startDismissAnimation()
                                                    }
                                                }

                                                StyledText {
                                                    anchors.centerIn: parent
                                                    text: "×"
                                                    color: closeMouse.containsMouse ? Appearance.colors.cOnErrorContainer : Appearance.colors.cOnSurfaceVariant
                                                    font.pixelSize: 18
                                                    font.weight: Font.Bold

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
                            }
                        }
                    }
                }
            }
        }
    }
}
