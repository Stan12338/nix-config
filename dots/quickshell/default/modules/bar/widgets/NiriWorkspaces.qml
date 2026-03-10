import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services.niri
import qs.config
import qs.widgets

Item {
    id: root
    Layout.alignment: Qt.AlignVCenter

    required property ShellScreen screen

    implicitWidth: background.width
    implicitHeight: background.height

    Rectangle {
        id: background
        implicitHeight: 32
        implicitWidth: row.width + 16
        radius: height / 2
        color: Appearance.colors.cSurfaceContainer
        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                model: {
                    let filtered = []
                    for (const ws of Niri.workspaces) {
                        if (ws.output === root.screen?.name) {
                            filtered.push(ws)
                        }
                    }
                    return filtered
                }

                Rectangle {
                    id: ws
                    required property Workspace modelData

                    readonly property bool active: modelData.isFocused
                    readonly property bool occupied: modelData.windows.length > 0

                    implicitWidth: active ? 48 : 16
                    implicitHeight: 16
                    radius: height / 2

                    color: active
                        ? Appearance.colors.cPrimary
                        : occupied
                            ? Appearance.colors.cSurfaceVariant
                            : Appearance.colors.cSurfaceDim

                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: modelData.idx
                        visible: active
                        font.pixelSize: 10
                        font.bold: true
                        color: Appearance.colors.cOnPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Niri.activateWorkspace(modelData.workspaceId)
                    }
                }
            }
        }
    }
}
