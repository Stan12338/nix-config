import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.services.niri
import qs.services
import qs.config
import qs.widgets

Item {
    implicitWidth: backgroundPill.width
    implicitHeight: backgroundPill.height
    Layout.alignment: Qt.AlignVCenter

    QtObject {
        id: compositor

        readonly property bool isHyprland: Compositor.compositor === "hyprland"
        readonly property var workspaces: isHyprland
            ? Hyprland.workspaces
            : Niri.workspaces
        readonly property var focusedWorkspace: isHyprland
            ? Hyprland.focusedWorkspace
            : Niri.focusedWorkspace

        function activateWorkspace(id) {
            if (isHyprland) {
                Hyprland.dispatch("workspace " + id)
            } else {
                Niri.activateWorkspace(id)
            }
        }
    }

    Rectangle {
        id: backgroundPill

        implicitHeight: 32
        implicitWidth: workspaceRow.width + 16
        radius: height / 2
        color: Appearance.colors.cSurfaceContainer

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                model: compositor.workspaces

                Rectangle {
                    id: workspace

                    required property var modelData
                    required property int index

                    readonly property bool isFocused:
                        compositor.focusedWorkspace
                        && modelData.workspaceId !== undefined
                            ? modelData.workspaceId === compositor.focusedWorkspace.workspaceId
                            : modelData.id === compositor.focusedWorkspace?.id

                    implicitWidth: isFocused ? 48 : 16
                    implicitHeight: 16
                    radius: 20

                    property bool isHovered: false

                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }

                    color: {
                        if (isFocused)
                            return Appearance.colors.cPrimary
                        else if (isHovered)
                            return Qt.lighter(Appearance.colors.cPrimary, 1.2)
                        else
                            return Appearance.isDark
                                ? Appearance.colors.cSurfaceVariant
                                : Appearance.colors.cSurfaceDim
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: modelData.id ?? modelData.workspaceId
                        font.pixelSize: 10
                        font.bold: isFocused
                        color: Appearance.colors.cOnPrimary
                        visible: isFocused
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            const id = modelData.id ?? modelData.workspaceId
                            if (id !== undefined) {
                                compositor.activateWorkspace(id)
                            }
                        }

                        onEntered: workspace.isHovered = true
                        onExited: workspace.isHovered = false
                    }
                }
            }
        }
    }
}
