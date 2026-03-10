import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.widgets
import qs.functions

Scope {
    PanelWindow {
        id: settingsWindow
        color: "transparent"
        visible: false

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }

        property string activeWallpaper: ""
        property string activeTab: tabModel.get(0).name
        property bool allowChanges: false


        ListModel {
            id: tabModel
            ListElement { name: "Theme"; icon: "" }
            ListElement { name: "Bar"; icon: "" }
        }

        Timer {
            id: primeStart
            interval: 120
            running: true
            repeat: false
            onTriggered: {
                settingsWindow.visible = true
                primeFinish.start()
            }
        }

        Timer {
            id: primeFinish
            interval: 80
            repeat: false
            onTriggered: {
                settingsWindow.visible = false
                settingsWindow.allowChanges = true
            }
        }

        FocusScope {
            id: fs
            anchors.fill: parent
            focus: true

            Keys.onEscapePressed: ipc.close()

            Rectangle {
                id: dimmer
                anchors.fill: parent
                color: Appearance.colors.cShadow
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: ipc.close()
                }
            }

            Rectangle {
                id: panel
                anchors.centerIn: parent
                implicitWidth: 1000
                implicitHeight: 640
                color: Appearance.colors.cSurfaceContainerLowest
                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                radius: 10
                clip: true

                opacity: 0
                scale: 0.9

                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                MouseArea {
                    anchors.fill: parent
                    onPressed: function(mouse) {mouse.accepted = true}
                }


                onVisibleChanged: {
                    if (visible) {
                        dimmer.opacity = 0.6
                        panel.opacity = 1
                        panel.scale = 1.0

                        Qt.callLater(function() {
                            if (tabListView.count > 0) {
                                tabListView.currentIndex = 0
                            }
                        })
                    } else {
                        dimmer.opacity = 0
                        panel.opacity = 0
                        panel.scale = 0.9
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    Rectangle {
                        id: nav
                        implicitWidth: 180
                        Layout.fillHeight: true
                        color: Appearance.colors.cSurfaceContainerLowest
                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                        radius: 10
                        clip: true

                        Item {
                            anchors.fill: parent
                            anchors.margins: 0
                            StyledText {
                                text: "Settings"
                                color: Appearance.colors.cOnSurface
                                font.pixelSize: 18
                                font.bold: true
                                anchors.top: parent.top
                                anchors.topMargin: 20
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                            }

                            Rectangle {
                                id: selector
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 6
                                height: 40
                                radius: 12
                                color: Appearance.colors.cPrimary
                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                                x: 0

                                Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                            }

                            ListView {
                                id: tabListView
                                anchors.top: parent.top
                                anchors.topMargin: 80
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                model: tabModel
                                interactive: true
                                clip: true

                                onCurrentIndexChanged: {
                                    var delegateHeight = 40
                                    var targetY = tabListView.y + (currentIndex * delegateHeight)
                                    selector.y = targetY
                                    settingsWindow.activeTab = model.get(currentIndex).name
                                }

                                delegate: Item {
                                    id: tabItem
                                    width: tabListView.width
                                    height: 40

                                    property bool isActive: model.name === settingsWindow.activeTab

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 20

                                        StyledText {
                                            id: tabText
                                            text: model.name
                                            font.pixelSize: 16
                                            color: tabItem.isActive ? Appearance.colors.cOnPrimary : Appearance.colors.cOnSurface
                                            font.weight: isActive ? Font.Medium : Font.Normal
                                            Behavior on color {
                                                ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: tabListView.currentIndex = index
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: contentArea
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"


                        StackLayout {
                            id: contentStack
                            anchors.fill: parent
                            anchors.margins: 8
                            anchors.leftMargin: 2
                            currentIndex: tabListView.currentIndex

                            // Theme Tab
                            Rectangle {
                                color: Appearance.colors.cSurfaceContainer
                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                                radius: 8
                                Layout.fillWidth: true

                                Item {
                                    anchors.margins: 16
                                    anchors.fill: parent
                                    Column {
                                        id: themeColumn
                                        height: 256
                                        width: parent.width
                                        spacing: 8

                                        ListModel {
                                            id: themeModel
                                            ListElement { name: "tonal-spot" }
                                            ListElement { name: "content" }
                                            ListElement { name: "expressive" }
                                            ListElement { name: "fidelity" }
                                            ListElement { name: "fruit-salad" }
                                            ListElement { name: "monochrome" }
                                            ListElement { name: "neutral" }
                                            ListElement { name: "rainbow" }
                                            ListElement { name: "vibrant" }
                                        }

                                        StyledText {
                                            text: "Matugen Color Scheme"
                                            color: Appearance.colors.cOnSurface
                                            font.pixelSize: 16
                                            padding: 4
                                        }

                                        Flow {
                                            id: chipFlow
                                            Layout.fillWidth: true
                                            width: themeColumn.width
                                            spacing: 6
                                            flow: Flow.LeftToRight

                                            Repeater {
                                                model: themeModel

                                                RadioButton {
                                                    id: control
                                                    property string schemeName: "scheme-" + model.name
                                                    text: model.name.charAt(0).toUpperCase() + model.name.slice(1)

                                                    property bool initialised: false
                                                    Component.onCompleted: initialised = true

                                                    checked: Appearance.scheme === schemeName
                                                    onCheckedChanged: {
                                                        if (!initialised)
                                                            return
                                                        if (!settingsWindow.allowChanges)
                                                            return
                                                        if (!checked)
                                                            return

                                                        Appearance.setScheme(
                                                            schemeName,
                                                            Appearance.isDark ? "dark" : "light"
                                                        )
                                                    }

                                                    indicator: Item {}

                                                    contentItem: StyledText {
                                                        id: chipLabel
                                                        text: control.text
                                                        color: control.checked
                                                            ? Appearance.colors.cOnPrimary
                                                            : Appearance.colors.cOnSurface
                                                        font.pixelSize: 16
                                                        font.weight: Font.Medium
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }

                                                    background: Rectangle {
                                                        id: chipBackground
                                                        radius: control.checked ? 16 : 8
                                                        topLeftRadius: model.name === "tonal-spot" ? 16 : model.name === "rainbow" ? 16 : control.checked ? 16 : 8
                                                        bottomLeftRadius: model.name === "tonal-spot" ? 16 : model.name === "rainbow" ? 16 : control.checked ? 16 : 8
                                                        topRightRadius: model.name === "vibrant" ? 16 : control.checked ? 16 : 8
                                                        bottomRightRadius: model.name === "vibrant" ? 16 : control.checked ? 16 : 8

                                                        color: control.checked
                                                            ? Appearance.colors.cPrimary
                                                            : Appearance.colors.cSurfaceContainerHighest
                                                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                                                        implicitHeight: 32
                                                        implicitWidth: chipLabel.implicitWidth + 10
                                                    }

                                                    implicitWidth: chipBackground.implicitWidth
                                                    implicitHeight: chipBackground.implicitHeight

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor

                                                        onClicked: control.checked = true

                                                        onPressed: parent.scale = 0.985
                                                        onReleased: parent.scale = 1.0
                                                    }
                                                }
                                            }
                                        }

                                        Item {
                                            implicitWidth: parent.width
                                            implicitHeight: 400
                                            ColumnLayout {
                                                width: parent.width
                                                spacing: 8

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    height: 48
                                                    radius: 12
                                                    color: Appearance.colors.cSurfaceContainerHighest
                                                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                                                    Rectangle {
                                                        id: themeselector
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
                                                                        return darkMouseArea.containsMouse ?
                                                                            ColorModifier.colorWithLightness(Appearance.colors.cOnPrimary, Qt.color(Appearance.colors.cOnPrimary).hslLightness + 0.1) :
                                                                            Appearance.colors.cOnPrimary
                                                                    } else {
                                                                        return darkMouseArea.containsMouse ?
                                                                            Appearance.colors.cPrimary :
                                                                            Appearance.colors.cOnSurface
                                                                    }
                                                                }
                                                                font.weight: Appearance.isDark ? Font.Medium : Font.Normal
                                                                z: 2
                                                                Behavior on color {
                                                                    ColorAnimation {
                                                                        duration: 150
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
                                                                        return lightMouseArea.containsMouse ?
                                                                            ColorModifier.colorWithLightness(Appearance.colors.cOnPrimary, Qt.color(Appearance.colors.cOnPrimary).hslLightness + 0.1) :
                                                                            Appearance.colors.cOnPrimary
                                                                    } else {
                                                                        return lightMouseArea.containsMouse ?
                                                                            Appearance.colors.cPrimary :
                                                                            Appearance.colors.cOnSurface
                                                                    }
                                                                }
                                                                font.weight: !Appearance.isDark ? Font.Medium : Font.Normal
                                                                z: 2
                                                                Behavior on color {
                                                                    ColorAnimation {
                                                                        duration: 150
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

                            // Bar Tab
                            Rectangle {
                                color: Appearance.colors.cSurfaceContainer
                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                                radius: 8
                                Layout.fillWidth: true

                                Item {
                                    anchors.margins: 16
                                    anchors.fill: parent

                                    Column {
                                        id: barColumn
                                        width: parent.width
                                        spacing: 20

                                        ListModel {
                                            id: barStyleModel
                                            ListElement { name: "floating" }
                                            ListElement { name: "default" }
                                        }

                                        Column {
                                            width: parent.width
                                            spacing: 8

                                            StyledText {
                                                text: "Bar Style"
                                                color: Appearance.colors.cOnSurface
                                                font.pixelSize: 16
                                                padding: 4
                                            }

                                            Flow {
                                                id: barStyleFlow
                                                width: parent.width
                                                spacing: 6
                                                flow: Flow.LeftToRight

                                                Repeater {
                                                    model: barStyleModel

                                                    RadioButton {
                                                        id: styleControl
                                                        text: model.name.charAt(0).toUpperCase() + model.name.slice(1)

                                                        property bool initialised: false
                                                        Component.onCompleted: initialised = true

                                                        checked: Appearance.barType === model.name
                                                        onCheckedChanged: {
                                                            if (!initialised)
                                                                return
                                                            if (!settingsWindow.allowChanges)
                                                                return
                                                            if (!checked)
                                                                return

                                                            Appearance.barType = model.name
                                                        }

                                                        indicator: Item {}

                                                        contentItem: StyledText {
                                                            id: styleChipLabel
                                                            text: styleControl.text
                                                            color: styleControl.checked
                                                                ? Appearance.colors.cOnPrimary
                                                                : Appearance.colors.cOnSurface
                                                            font.pixelSize: 16
                                                            font.weight: Font.Medium
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                        }

                                                        background: Rectangle {
                                                            id: styleChipBackground
                                                            radius: styleControl.checked ? 16 : 8
                                                            topLeftRadius: model.name === "floating" ? 16 : styleControl.checked ? 16 : 8
                                                            bottomLeftRadius: model.name === "floating" ? 16 : styleControl.checked ? 16 : 8
                                                            topRightRadius: model.name === "default" ? 16 : styleControl.checked ? 16 : 8
                                                            bottomRightRadius: model.name === "default" ? 16 : styleControl.checked ? 16 : 8

                                                            color: styleControl.checked
                                                                ? Appearance.colors.cPrimary
                                                                : Appearance.colors.cSurfaceContainerHighest
                                                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                                                            implicitHeight: 32
                                                            implicitWidth: styleChipLabel.implicitWidth + 10
                                                        }

                                                        implicitWidth: styleChipBackground.implicitWidth
                                                        implicitHeight: styleChipBackground.implicitHeight

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor

                                                            onClicked: styleControl.checked = true

                                                            onPressed: parent.scale = 0.985
                                                            onReleased: parent.scale = 1.0
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Column {
                                            width: parent.width
                                            spacing: 8

                                            StyledText {
                                                text: "Bar Background"
                                                color: Appearance.colors.cOnSurface
                                                font.pixelSize: 16
                                                padding: 4
                                            }

                                            Rectangle {
                                                width: parent.width
                                                height: 48
                                                radius: 12
                                                color: Appearance.colors.cSurfaceContainerHighest
                                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                                                Rectangle {
                                                    id: barBgSelector
                                                    height: parent.height - 8
                                                    width: parent.width / 2 - 6
                                                    radius: 10
                                                    color: Appearance.colors.cPrimary
                                                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                                                    y: 4
                                                    x: Appearance.barBgEnabled ? 4 : parent.width / 2 + 2
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
                                                            id: enabledMouseArea
                                                            anchors.fill: parent
                                                            cursorShape: Qt.PointingHandCursor
                                                            hoverEnabled: true
                                                            onClicked: {
                                                                if (settingsWindow.allowChanges) {
                                                                    Appearance.barBgEnabled = true
                                                                }
                                                            }
                                                        }

                                                        StyledText {
                                                            anchors.centerIn: parent
                                                            text: "Enabled"
                                                            font.pixelSize: 16
                                                            color: {
                                                                if (Appearance.barBgEnabled) {
                                                                    return enabledMouseArea.containsMouse ?
                                                                        ColorModifier.colorWithLightness(Appearance.colors.cOnPrimary, Qt.color(Appearance.colors.cOnPrimary).hslLightness + 0.1) :
                                                                        Appearance.colors.cOnPrimary
                                                                } else {
                                                                    return enabledMouseArea.containsMouse ?
                                                                        Appearance.colors.cPrimary :
                                                                        Appearance.colors.cOnSurface
                                                                }
                                                            }
                                                            font.weight: Appearance.barBgEnabled ? Font.Medium : Font.Normal
                                                            z: 2
                                                            Behavior on color {
                                                                ColorAnimation {
                                                                    duration: 150
                                                                    easing.type: Easing.InOutQuad
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        width: parent.width / 2
                                                        height: parent.height

                                                        MouseArea {
                                                            id: disabledMouseArea
                                                            anchors.fill: parent
                                                            cursorShape: Qt.PointingHandCursor
                                                            hoverEnabled: true
                                                            onClicked: {
                                                                if (settingsWindow.allowChanges) {
                                                                    Appearance.barBgEnabled = false
                                                                }
                                                            }
                                                        }

                                                        StyledText {
                                                            anchors.centerIn: parent
                                                            text: "Disabled"
                                                            font.pixelSize: 16
                                                            color: {
                                                                if (!Appearance.barBgEnabled) {
                                                                    return disabledMouseArea.containsMouse ?
                                                                        ColorModifier.colorWithLightness(Appearance.colors.cOnPrimary, Qt.color(Appearance.colors.cOnPrimary).hslLightness + 0.1) :
                                                                        Appearance.colors.cOnPrimary
                                                                } else {
                                                                    return disabledMouseArea.containsMouse ?
                                                                        Appearance.colors.cPrimary :
                                                                        Appearance.colors.cOnSurface
                                                                }
                                                            }
                                                            font.weight: !Appearance.barBgEnabled ? Font.Medium : Font.Normal
                                                            z: 2
                                                            Behavior on color {
                                                                ColorAnimation {
                                                                    duration: 150
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
    }

    IpcHandler {
        id: ipc
        target: "settings"

        function toggle() {
            settingsWindow.visible = !settingsWindow.visible
            if (settingsWindow.visible) {
                try { settingsWindow.requestActivate() } catch(e) {}
            }
        }

        function open() {
            settingsWindow.visible = true
            try { settingsWindow.requestActivate() } catch(e) {}
        }

        function close() {
            settingsWindow.visible = false
        }
    }
}
