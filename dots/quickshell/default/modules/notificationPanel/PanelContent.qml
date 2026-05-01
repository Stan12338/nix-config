import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.widgets
import qs.services

Item {
    id: panelRoot
    anchors.fill: parent

    property bool isPopulated: false
    property var seenNotificationIds: new Set()

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            color: Appearance.colors.cSurfaceContainer
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.fillWidth: true
            implicitHeight: 120
            radius: 16

            Row {
                anchors.centerIn: parent
                spacing: 12

                StyledText {
                    id: timeText
                    text: Time.format("HH:mm")
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Appearance.colors.cOnSurface
                    font.pixelSize: 48
                }
                // StyledText {
                //     text: "|"
                //     anchors.verticalCenter: parent.verticalCenter
                //     verticalAlignment: Text.AlignVCenter
                //     color: Appearance.colors.cOnSurface
                //     font.pixelSize: 48
                // }
                StyledText {
                    id: dayText
                    text: Time.format("dddd")
                    color: Appearance.colors.cOnSurface
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 48
                }
            }

        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: "Auto clear duration:"
            font.pixelSize: 24
            color: Appearance.colors.cOnSurface
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: 64
            spacing: 4
            Rectangle {
                topLeftRadius: 16
                bottomLeftRadius: 16
                topRightRadius: Appearance.autoClearDays === 1 ? 16 : 4
                bottomRightRadius: Appearance.autoClearDays === 1 ? 16 : 4
                color: Appearance.autoClearDays === 1 ? Appearance.colors.cPrimary : Appearance.colors.cSurfaceContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                Behavior on topRightRadius {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on bottomRightRadius {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Appearance.autoClearDays = 1
                    }
                }
                StyledText {
                    anchors.centerIn: parent
                    text: "1d"
                    font.pixelSize: 24
                    color: Appearance.autoClearDays === 1 ? Appearance.colors.cOnPrimary : Appearance.colors.cOnSurface
                }
            }
            Rectangle {
                radius: Appearance.autoClearDays === 3 ? 16 : 4
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.autoClearDays === 3 ? Appearance.colors.cPrimary : Appearance.colors.cSurfaceContainer
                Behavior on radius {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Appearance.autoClearDays = 3
                    }
                }
                StyledText {
                    anchors.centerIn: parent
                    text: "3d"
                    font.pixelSize: 24
                    color: Appearance.autoClearDays === 3 ? Appearance.colors.cOnPrimary : Appearance.colors.cOnSurface
                }
            }
            Rectangle {
                topRightRadius: 16
                bottomRightRadius: 16
                topLeftRadius: Appearance.autoClearDays === 7 ? 16 : 4
                bottomLeftRadius: Appearance.autoClearDays === 7 ? 16 : 4
                color: Appearance.autoClearDays === 7 ? Appearance.colors.cPrimary : Appearance.colors.cSurfaceContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                Behavior on radius {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on topLeftRadius {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on bottomLeftRadius {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Appearance.autoClearDays = 7
                    }
                }
                StyledText {
                    anchors.centerIn: parent
                    text: "7d"
                    font.pixelSize: 24
                    color: Appearance.autoClearDays === 7 ? Appearance.colors.cOnPrimary : Appearance.colors.cOnSurface
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4

            StyledText {
                text: "Notifications"
                color: Appearance.colors.cOnSurface
                font.pixelSize: 13
                font.weight: Font.Medium
                opacity: 0.7
            }

            Rectangle {
                visible: NotifServer.unreadCount > 0
                width: unreadLabel.implicitWidth + 10
                height: 18
                radius: 9
                color: Appearance.colors.cPrimary

                StyledText {
                    id: unreadLabel
                    anchors.centerIn: parent
                    text: NotifServer.unreadCount
                    color: Appearance.colors.cOnPrimary
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
            }

            Item { Layout.fillWidth: true }

            StyledText {
                text: "Clear all"
                color: Appearance.colors.cPrimary
                font.pixelSize: 12
                opacity: clearAllMouse.containsMouse ? 1.0 : 0.7
                Behavior on opacity { NumberAnimation { duration: 120 } }

                MouseArea {
                    id: clearAllMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        for (let i = 0; i < notifList.count; i++) {
                            const item = notifList.itemAtIndex(i)
                            if (item && item.startDismissAnimation) {
                                item.startDismissAnimation()
                            }
                        }
                        clearAllTimer.start()
                    }
                }
            }
        }



        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Column {
                anchors.centerIn: parent
                spacing: 16
                visible: NotifServer.data.length === 0

                StyledText {
                    text: "󰂚"
                    font.pixelSize: 64
                    color: Appearance.colors.cOnSurfaceVariant
                    opacity: 0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    text: "No notifications"
                    color: Appearance.colors.cOnSurfaceVariant
                    font.pixelSize: 16
                    opacity: 0.7
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            ListView {
                id: notifList
                anchors.fill: parent
                clip: true
                spacing: 8
                model: NotifServer.data
                visible: NotifServer.data.length > 0

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
                Component.onCompleted: {
                    Qt.callLater(() => { panelRoot.isPopulated = true })
                }

                delegate: Item {
                    id: delegateRoot
                    property var entry: modelData ?? null
                    property bool removing: false
                    property bool hasAppeared: false

                    property bool isNewNotification: entry && !panelRoot.seenNotificationIds.has(entry.notifId)

                    property real slideOffset: (isNewNotification && panelRoot.isPopulated) ? 400 : 0

                    width: notifList.width
                    implicitHeight: removing ? 0 : (entry ? cardRect.implicitHeight : 0)

                    Component.onCompleted: {
                        hasAppeared = true
                        if (entry && isNewNotification) {
                            panelRoot.seenNotificationIds.add(entry.notifId)
                            if (slideOffset > 0) {
                                slideOffset = 0
                            }
                        }
                    }

                    function startDismissAnimation() {
                        if (removing) return
                        slideOffset = 400
                        collapseTimer.start()
                    }

                    Timer {
                        id: collapseTimer
                        interval: 300
                        onTriggered: {
                            delegateRoot.removing = true
                            finalDeletionTimer.start()
                        }
                    }

                    Timer {
                        id: finalDeletionTimer
                        interval: 350
                        onTriggered: {
                            if (delegateRoot.entry) {
                                panelRoot.seenNotificationIds.delete(delegateRoot.entry.notifId)
                                NotifServer.removeById(delegateRoot.entry.notifId)
                            }
                        }
                    }

                    Behavior on slideOffset {
                        enabled: hasAppeared
                        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                    }

                    Behavior on implicitHeight {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        id: cardRect
                        x: delegateRoot.slideOffset
                        width: parent.width
                        implicitHeight: cardContent.implicitHeight + 20
                        radius: 12
                        color: Appearance.colors.cSurfaceContainer
                        opacity: delegateRoot.removing ? 0 : 1

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Rectangle {
                            opacity: delegateRoot.entry && !delegateRoot.entry.read ? 1 : 0
                            width: 4 //delegateRoot.entry && !delegateRoot.entry.read ? 4 : 0
                            height: parent.height - 24
                            // Behavior on width { NumberAnimation { duration: 200 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            radius: 2
                            color: Appearance.colors.cPrimary
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                            onEntered: {
                                if (delegateRoot.entry && !delegateRoot.entry.read) {
                                    delegateRoot.entry.read = true
                                    NotifServer.save()
                                }
                            }
                        }

                        RowLayout {
                            id: cardContent
                            anchors {
                                left: parent.left;   leftMargin: 18
                                right: parent.right; rightMargin: 12
                                top: parent.top;     topMargin: 10
                            }
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                Layout.alignment: Qt.AlignTop
                                radius: 8
                                color: Qt.rgba(0,0,0,0.1)

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    source: (delegateRoot.entry && delegateRoot.entry.appIcon) ? "image://icon/" + delegateRoot.entry.appIcon : ""
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    StyledText {
                                        text: delegateRoot.entry ? delegateRoot.entry.appName : ""
                                        color: Appearance.colors.cOnSurface; font.pixelSize: 11; opacity: 0.6
                                        Layout.fillWidth: true
                                    }
                                    StyledText {
                                        text: delegateRoot.entry ? delegateRoot.entry.timeStr : ""
                                        color: Appearance.colors.cOnSurface; font.pixelSize: 11; opacity: 0.4
                                    }
                                }

                                StyledText {
                                    text: delegateRoot.entry ? delegateRoot.entry.summary : ""
                                    color: Appearance.colors.cOnSurface; font.pixelSize: 14; font.weight: Font.Bold
                                    Layout.fillWidth: true
                                }

                                StyledText {
                                    text: delegateRoot.entry ? delegateRoot.entry.body : ""
                                    color: Appearance.colors.cOnSurfaceVariant; font.pixelSize: 12
                                    wrapMode: Text.WordWrap; maximumLineCount: 3
                                    Layout.fillWidth: true; visible: text !== ""
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 120
                                    Layout.topMargin: 4
                                    radius: 8; color: "transparent"; clip: true
                                    visible: delegateRoot.entry && delegateRoot.entry.image && delegateRoot.entry.image.length > 0

                                    Image {
                                        anchors.fill: parent
                                        source: delegateRoot.entry ? delegateRoot.entry.image : ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                    }
                                }
                            }

                            MouseArea {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                Layout.alignment: Qt.AlignTop
                                hoverEnabled: true
                                onClicked: delegateRoot.startDismissAnimation()

                                StyledText {
                                    anchors.centerIn: parent
                                    text: "✕"; font.pixelSize: 14
                                    color: Appearance.colors.cOnSurface
                                    opacity: parent.containsMouse ? 1 : 0.3
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: clearAllTimer
        interval: 750 // Wait for all dismiss animations to complete
        repeat: false
        onTriggered: NotifServer.clearAll()
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            dayText.text  = Time.format("dddd")
            timeText.text = Time.format("HH:mm")
        }
    }
}
