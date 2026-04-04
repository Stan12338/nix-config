import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.widgets
import qs.services
import qs.services.niri
import QtQuick.Controls

Scope {
    id: root

    property bool debug: false
    property bool typing: false
    property string searchQuery: ""
    property string thisistofixabugnotanythingmeaninful: Compositor.compositor
    property string thisistofixabugnotanythingmeaninful2: Niri.focusedWorkspace?.output ?? ""



    QtObject {
        id: sharedState
        property bool isOpen: false
        property string openedOnMonitor: ""
    }

    IpcHandler {
        id: ipc
        target: "startmenu"

        function toggle() {
            if (!sharedState.isOpen) {
                if (Compositor.compositor === "hyprland") {
                    sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
                } else if (Compositor.compositor === "niri") {
                    sharedState.openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
                }
            }
            sharedState.isOpen = !sharedState.isOpen
            Appearance.startMenuOpened = sharedState.isOpen
        }

        function open() {
            if (!sharedState.isOpen) {
                if (Compositor.compositor === "hyprland") {
                    sharedState.openedOnMonitor = Hyprland.focusedMonitor?.name ?? ""
                } else if (Compositor.compositor === "niri") {
                    sharedState.openedOnMonitor = Niri.focusedWorkspace?.output ?? ""
                }
            }
            sharedState.isOpen = true
            Appearance.startMenuOpened = sharedState.isOpen
        }

        function close() {
            sharedState.isOpen = false
            Appearance.startMenuOpened = sharedState.isOpen
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            id: startPanel
            screen: modelData

            anchors {
                top: true
                right: true
                left: true
                bottom: true
            }

            color: "transparent"

            readonly property int slideDuration: 200
            property bool shouldShow: modelData.name === sharedState.openedOnMonitor

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            mask: null

            Timer {
                id: closeDelayTimer
                interval: startPanel.slideDuration + 100
                repeat: false
                onTriggered: {
                    startPanel.WlrLayershell.layer = WlrLayer.Background
                    startPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                    startPanel.mask = null
                }
            }

            Connections {
                target: sharedState

                function onIsOpenChanged() {
                    if (sharedState.isOpen) {
                        closeDelayTimer.stop()
                        startPanel.WlrLayershell.layer = WlrLayer.Top
                        startPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                        startPanel.mask = null

                        if (shouldShow) {
                            focusScope.forceActiveFocus()
                            root.typing = false
                            root.searchQuery = ""
                            globalSearchField.text = ""
                        }
                    } else {
                        startPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
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

                Keys.onEscapePressed: {
                    if (root.typing) {
                        root.typing = false
                        root.searchQuery = ""
                        globalSearchField.text = ""
                    } else {
                        startPanel.closePanel()
                    }
                }

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
                        if (root.typing && searchLoader.item) {
                            if (event.key === Qt.Key_Down) {
                                searchLoader.item.moveDown()
                            } else {
                                searchLoader.item.moveUp()
                            }
                            event.accepted = true
                            return
                        }
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (root.typing && searchLoader.item) {
                            searchLoader.item.executeCurrent()
                            event.accepted = true
                            return
                        }
                    }

                    if (!root.typing && event.text && event.text.length > 0) {
                        root.typing = true
                        globalSearchField.text = event.text
                        root.searchQuery = event.text
                        globalSearchField.forceActiveFocus()
                        globalSearchField.cursorPosition = globalSearchField.text.length
                        event.accepted = true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: sharedState.isOpen
                    onClicked: {
                        startPanel.closePanel()
                    }
                }

                Item {
                    id: popupContainer
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 60
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 832
                    height: 864

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: sharedState.isOpen && shouldShow
                    }

                    Rectangle {
                        id: startRect
                        width: parent.width
                        height: parent.height

                        clip: true
                        radius: 8
                        color: root.debug ? "white" : "#242424"
                        opacity: root.debug ? 0.3 : 1
                        border {
                            width: 1
                            color: "#484953"
                        }

                        transform: Translate {
                            y: (sharedState.isOpen && shouldShow) ? 0 : startRect.height + 16
                            Behavior on y {
                                NumberAnimation {
                                    duration: startPanel.slideDuration
                                    easing.type: (sharedState.isOpen && shouldShow)
                                        ? Easing.OutQuad
                                        : Easing.InQuad
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.margins: 1
                            anchors.fill: parent
                            spacing: 0
                            opacity: 0.8

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop
                                implicitHeight: 64
                                color: root.typing ? "#242424" : "#1c1c1c"
                                opacity: root.debug ? 0.9 : 1
                                topLeftRadius: 8
                                topRightRadius: 8

                                Rectangle {
                                    anchors.fill: parent
                                    anchors {
                                        topMargin: 16
                                        bottomMargin: 16
                                        leftMargin: 32
                                        rightMargin: 32
                                    }
                                    radius: 32
                                    color: "#1d1d1d"
                                    border {
                                        color: "#2c2c2c"
                                        width: 1
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        Item {
                                            Layout.alignment: Qt.AlignLeft
                                            implicitWidth: 42
                                            Layout.fillHeight: true

                                            StyledText {
                                                text: ""
                                                anchors.centerIn: parent
                                                font.pixelSize: 18
                                                color: "white"
                                            }
                                        }

                                        TextField {
                                            id: globalSearchField
                                            Layout.fillWidth: true
                                            Layout.rightMargin: 16
                                            placeholderText: "Search for apps, settings and documents"
                                            placeholderTextColor: "#959595"
                                            background: Item {}
                                            font.pixelSize: 14
                                            color: "white"

                                            onTextChanged: {
                                                root.searchQuery = text
                                                if (text.length > 0) {
                                                    if (!root.typing) root.typing = true
                                                } else {
                                                    root.typing = false
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    globalSearchField.forceActiveFocus()
                                                }
                                            }

                                            Keys.onEscapePressed: {
                                                if (text.length > 0) {
                                                    text = ""
                                                    root.searchQuery = ""
                                                    root.typing = false
                                                } else {
                                                    startPanel.closePanel()
                                                }
                                            }

                                            Keys.onPressed: (event) => {
                                                if (!searchLoader.item) return
                                                if (event.key === Qt.Key_Down) {
                                                    searchLoader.item.moveDown()
                                                    event.accepted = true
                                                } else if (event.key === Qt.Key_Up) {
                                                    searchLoader.item.moveUp()
                                                    event.accepted = true
                                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                                    searchLoader.item.executeCurrent()
                                                    event.accepted = true
                                                }
                                            }
                                        }

                                    }
                                }
                            }

                            Loader {
                                id: searchLoader
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                sourceComponent: root.typing ? searchComponent : mainComponent

                                onLoaded: {
                                    if (root.typing) {
                                        item.searchQuery = Qt.binding(() => root.searchQuery)
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
        id: mainComponent
        Main {
            anchors.fill: parent
        }
    }

    Component {
        id: searchComponent

        Item {
            id: searchRoot
            anchors.fill: parent



            property string searchQuery: root.searchQuery
            property var allApps: AppSearch.fuzzyQuery(searchQuery)
            property var bestMatch: allApps.length > 0 ? [allApps[0]] : []
            property var otherApps: allApps.length > 1 ? allApps.slice(1) : []

            property int currentIndex: 0

            property var selectedApp: (currentIndex >= 0 && currentIndex < allApps.length)
                ? allApps[currentIndex]
                : null

            onAllAppsChanged: {
                if (currentIndex >= allApps.length) {
                    currentIndex = allApps.length > 0 ? 0 : -1
                }
            }

            function moveDown() {
                if (allApps.length === 0) return
                currentIndex = (currentIndex + 1) % allApps.length
            }

            function moveUp() {
                if (allApps.length === 0) return
                currentIndex = currentIndex <= 0 ? allApps.length - 1 : currentIndex - 1
            }

            function executeCurrent() {
                if (currentIndex >= 0 && currentIndex < allApps.length) {
                    var app = allApps[currentIndex]
                    AppSearch.trackAppLaunch(app.id)
                    app.execute()
                    sharedState.isOpen = false
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                spacing: 0

                RowLayout {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true

                    Row {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 8
                        spacing: 4

                        Item {
                            implicitHeight: 32
                            implicitWidth: 32

                            Rectangle {
                                id: backHover
                                anchors.fill: parent
                                radius: 16
                                color: "#363636"
                                opacity: 0
                                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: parent.opacity = 1
                                    onExited: parent.opacity = 0
                                    onClicked: {
                                        root.typing = false
                                        root.searchQuery = ""
                                        globalSearchField.text = ""
                                    }
                                }
                            }

                            StyledText {
                                anchors.centerIn: parent
                                text: ""
                                font.weight: 400
                                font.pixelSize: 20
                                color: "white"
                            }
                        }

                        Chips {}
                    }
                    Item {
                        Layout.alignment: Qt.AlignRight
                        implicitWidth: 32
                        implicitHeight: 32
                        Rectangle {
                            anchors.fill: parent
                            color: "#363636"
                            radius: 16
                            opacity: 0
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: {
                                    parent.opacity = 1
                                }
                                onExited: {
                                    parent.opacity = 0
                                }
                            }

                        }
                        StyledText {
                            anchors.centerIn: parent
                            text: "󰇘"
                            color: "white"

                            font.pixelSize: 20
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    Item {
                        id: searchContent
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 16
                        Layout.leftMargin: 2
                        Layout.bottomMargin: 12
                        StyledText {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.rightMargin: 2
                            text: ""
                            color: "white"
                            font.pixelSize: 16
                        }
                        StyledText {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: 2
                            text: ""
                            color: "white"
                            font.pixelSize: 16
                        }

                        StyledText {
                            text: "Best match"
                            font.pixelSize: 13
                            font.weight: 695
                            color: "white"
                            anchors.topMargin: 8
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            visible: searchRoot.bestMatch.length > 0
                        }


                        ScrollView {
                            anchors.fill: parent
                            clip: true
                            anchors.topMargin: 24
                            ScrollBar.vertical: ScrollBar {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.top: parent.top
                                anchors.rightMargin: 5
                                anchors.bottomMargin: 24

                                background: Rectangle {

                                    color: "transparent"
                                    implicitWidth: 6
                                }
                                contentItem: Rectangle {
                                    color: "#a9a9a9"
                                    radius: 1
                                }
                            }


                            ColumnLayout {
                                width: searchContent.width - 16
                                spacing: 0

                                Item {
                                    Layout.fillWidth: true
                                    implicitHeight: 16
                                }




                                Repeater {
                                    model: searchRoot.bestMatch
                                    delegate: Rectangle {
                                        required property var modelData
                                        readonly property int flatIndex: 0


                                        Layout.fillWidth: true
                                        implicitHeight: 60
                                        radius: 4

                                        color: (searchRoot.currentIndex === flatIndex)
                                            ? "#363636"
                                            : "transparent"

                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onEntered: searchRoot.currentIndex = flatIndex
                                            onClicked: {
                                                AppSearch.trackAppLaunch(modelData.id)
                                                modelData.execute()
                                                sharedState.isOpen = false
                                            }
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12
                                            spacing: 6

                                            Rectangle {
                                                width: 24
                                                height: 24
                                                radius: 8
                                                color: "transparent"

                                                property bool showFallback: false

                                                Image {
                                                    anchors.fill: parent
                                                    source: modelData.icon ? "image://icon/" + modelData.icon : ""
                                                    sourceSize.width: 24
                                                    sourceSize.height: 24
                                                    smooth: true
                                                    asynchronous: true
                                                    fillMode: Image.PreserveAspectFit
                                                    visible: !parent.showFallback
                                                    onStatusChanged: {
                                                        if (status === Image.Error || status === Image.Null)
                                                            parent.showFallback = true
                                                        else if (status === Image.Ready)
                                                            parent.showFallback = false
                                                    }
                                                }

                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 8
                                                    color: "#555"
                                                    visible: parent.showFallback
                                                    StyledText {
                                                        anchors.centerIn: parent
                                                        text: modelData.name.charAt(0).toUpperCase()
                                                        font.pixelSize: 18
                                                        font.weight: Font.Bold
                                                        color: "white"
                                                    }
                                                }
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 3
                                                StyledText {
                                                    text: modelData.name
                                                    color: "white"
                                                    font.pixelSize: 14
                                                    font.weight: 650
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                }
                                                StyledText {
                                                    text: "App"
                                                    color: "#999"
                                                    font.pixelSize: 11
                                                    font.weight: 700
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                    visible: text !== ""
                                                }
                                            }
                                        }
                                    }
                                }

                                StyledText {
                                    text: "Apps"
                                    font.pixelSize: 14
                                    font.weight: 650
                                    color: "white"
                                    Layout.leftMargin: 8
                                    Layout.topMargin: 14
                                    Layout.bottomMargin: 12
                                    visible: searchRoot.otherApps.length > 0
                                }

                                Repeater {
                                    model: searchRoot.otherApps
                                    delegate: Rectangle {
                                        required property var modelData
                                        required property int index
                                        readonly property int flatIndex: index + (searchRoot.bestMatch.length > 0 ? 1 : 0)

                                        width: parent ? parent.width : 0
                                        implicitHeight: 40
                                        radius: 4

                                        color: (searchRoot.currentIndex === flatIndex)
                                            ? "#3d3d3d"
                                            : "transparent"

                                        Behavior on color { ColorAnimation { duration: 80 } }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onEntered: searchRoot.currentIndex = flatIndex
                                            onClicked: {
                                                AppSearch.trackAppLaunch(modelData.id)
                                                modelData.execute()
                                                sharedState.isOpen = false
                                            }
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 12
                                            spacing: 10

                                            Rectangle {
                                                width: 28
                                                height: 28
                                                radius: 5
                                                color: "transparent"
                                                property bool showFallback: false

                                                Image {
                                                    anchors.fill: parent
                                                    source: modelData.icon ? "image://icon/" + modelData.icon : ""
                                                    sourceSize.width: 28
                                                    sourceSize.height: 28
                                                    smooth: true
                                                    asynchronous: true
                                                    fillMode: Image.PreserveAspectFit
                                                    visible: !parent.showFallback
                                                    onStatusChanged: {
                                                        if (status === Image.Error || status === Image.Null)
                                                            parent.showFallback = true
                                                        else if (status === Image.Ready)
                                                            parent.showFallback = false
                                                    }
                                                }

                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 5
                                                    color: "#555"
                                                    visible: parent.showFallback
                                                    StyledText {
                                                        anchors.centerIn: parent
                                                        text: modelData.name.charAt(0).toUpperCase()
                                                        font.pixelSize: 13
                                                        font.weight: Font.Bold
                                                        color: "white"
                                                    }
                                                }
                                            }

                                            StyledText {
                                                Layout.fillWidth: true
                                                text: modelData.name
                                                font.weight: 600
                                                color: "white"
                                                font.pixelSize: 13
                                                elide: Text.ElideRight
                                            }

                                            StyledText {
                                                Layout.alignment: Qt.AlignLeft
                                                Layout.rightMargin: 12
                                                text: ""
                                                color: "white"
                                                font.pixelSize: 13
                                                font.weight: 700

                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        color: "#2f2f2f"
                        implicitWidth: 424
                        Layout.fillHeight: true
                        Layout.topMargin: 12
                        radius: 8
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Column {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop
                                spacing: 0
                                Item {
                                    // color: "#2f2f2f"
                                    implicitWidth: parent.width
                                    implicitHeight: 188
                                    Repeater {
                                        anchors.fill: parent
                                        model: searchRoot.selectedApp
                                        delegate: Item {
                                            required property var modelData
                                            anchors.fill: parent
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Image {
                                                    source: modelData.icon ? "image://icon/" + modelData.icon : ""
                                                    sourceSize.width: 64
                                                    sourceSize.height: 64
                                                    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                                                    Layout.topMargin: 36
                                                }

                                                Column {
                                                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                                                    Layout.bottomMargin: 30
                                                    spacing: 0
                                                    StyledText {
                                                        text: modelData.name
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        color: "white"
                                                        font.pixelSize: 20
                                                        font.weight: 650
                                                    }
                                                    StyledText {
                                                        text: "App"
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        color: "white"
                                                        font.pixelSize: 12
                                                        font.weight: 550
                                                    }
                                                }

                                            }

                                        }
                                    }
                                }
                                Rectangle {
                                    color: "#404040"
                                    implicitHeight: 2
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 20
                                    anchors.rightMargin: 20
                                }

                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Repeater {
                                    anchors.fill: parent
                                    model: searchRoot.selectedApp
                                    delegate: Column {
                                        anchors.topMargin: 10
                                        anchors.leftMargin: 20
                                        anchors.rightMargin: 20
                                        spacing: 0

                                        anchors.fill: parent
                                        Item{

                                            implicitWidth: parent.width
                                            implicitHeight: 32
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 4
                                                opacity: 0
                                                color: "#393939"
                                                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onExited: {
                                                        parent.opacity = 0
                                                    }
                                                    onEntered: {
                                                        parent.opacity = 1
                                                    }
                                                    onClicked: {
                                                        modelData.execute()
                                                        ipc.close()
                                                    }
                                                }
                                            }
                                            Row {
                                                anchors.top: parent.top
                                                anchors.bottom: parent.bottom
                                                anchors.left: parent.left
                                                anchors.leftMargin: 12
                                                spacing: 12
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    font.pixelSize: 16
                                                    font.weight: 600
                                                    text: "󰏌"
                                                    color: "white"
                                                }
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    font.weight: 600
                                                    font.pixelSize: 11
                                                    text: "Open"
                                                    color: "white"
                                                }
                                            }

                                        }
                                        Item{

                                            implicitWidth: parent.width
                                            implicitHeight: 32
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 4
                                                opacity: 0
                                                color: "#393939"
                                                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onExited: {
                                                        parent.opacity = 0
                                                    }
                                                    onEntered: {
                                                        parent.opacity = 1
                                                    }
                                                    onClicked: {
                                                        //prob not going to implement this depending on time
                                                    }
                                                }
                                            }
                                            Row {
                                                anchors.top: parent.top
                                                anchors.bottom: parent.bottom
                                                anchors.left: parent.left
                                                anchors.leftMargin: 12
                                                spacing: 12
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    font.pixelSize: 18
                                                    font.weight: 600
                                                    rotation: 45
                                                    text: "󰤱"
                                                    color: "white"
                                                }
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    font.weight: 600
                                                    text: "Pin to Start"
                                                    font.pixelSize: 11
                                                    color: "white"
                                                }
                                            }


                                        }
                                        Item{

                                            implicitWidth: parent.width
                                            implicitHeight: 32
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 4
                                                opacity: 0
                                                color: "#393939"
                                                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                                MouseArea {
                                                    cursorShape: Qt.PointingHandCursor
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onExited: {
                                                        parent.opacity = 0
                                                    }
                                                    onEntered: {
                                                        parent.opacity = 1
                                                    }
                                                    onClicked: {
                                                        TaskManager.togglePin(modelData.id)

                                                    }
                                                }
                                            }
                                            Row {
                                                anchors.top: parent.top
                                                anchors.bottom: parent.bottom
                                                anchors.left: parent.left
                                                anchors.leftMargin: 12
                                                spacing: 12
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    font.pixelSize: 18
                                                    font.weight: 600
                                                    rotation: 45
                                                    text: "󰤱"
                                                    color: "white"
                                                }
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    font.weight: 600
                                                    text: TaskManager.isPinned(modelData.id) ? "Unpin from taskbar" : "Pin to taskbar"
                                                    font.pixelSize: 11
                                                    color: "white"
                                                }
                                            }

                                        }
                                        Item{

                                            implicitWidth: parent.width
                                            implicitHeight: 32
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 4
                                                opacity: 0
                                                color: "#393939"
                                                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                                MouseArea {
                                                    cursorShape: Qt.PointingHandCursor
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onExited: {
                                                        parent.opacity = 0
                                                    }
                                                    onEntered: {
                                                        parent.opacity = 1
                                                    }
                                                    onClicked: {
                                                        // definitely not implementing
                                                    }
                                                }
                                            }
                                            Row {
                                                anchors.top: parent.top
                                                anchors.bottom: parent.bottom
                                                anchors.left: parent.left
                                                anchors.leftMargin: 12
                                                spacing: 12
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    font.pixelSize: 16
                                                    font.weight: 600
                                                    text: ""
                                                    color: "white"
                                                }
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    font.weight: 600
                                                    text: "Share"
                                                    font.pixelSize: 11
                                                    color: "white"
                                                }
                                            }

                                        }
                                        Item{

                                            implicitWidth: parent.width
                                            implicitHeight: 32
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 4
                                                opacity: 0
                                                color: "#393939"
                                                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                                                MouseArea {
                                                    cursorShape: Qt.PointingHandCursor
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onExited: {
                                                        parent.opacity = 0
                                                    }
                                                    onEntered: {
                                                        parent.opacity = 1
                                                    }
                                                    onClicked: {
                                                        // definitely not implementing
                                                    }
                                                }
                                            }
                                            Row {
                                                anchors.top: parent.top
                                                anchors.bottom: parent.bottom
                                                anchors.left: parent.left
                                                anchors.leftMargin: 12
                                                spacing: 12
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    font.pixelSize: 16
                                                    font.weight: 600
                                                    text: ""
                                                    color: "white"
                                                }
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    font.weight: 600
                                                    text: "Uninstall"
                                                    font.pixelSize: 11
                                                    color: "white"
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
