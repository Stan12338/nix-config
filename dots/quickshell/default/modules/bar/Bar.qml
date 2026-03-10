import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.modules.bar.widgets
import qs.widgets
import qs.services
import qs.functions
import Quickshell.Hyprland

Scope {
    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {

                property color mColor: Appearance.colors.cSurfaceContainerLowest
                required property var modelData
                screen: modelData
                anchors {
                    top: true
                    right: true
                    left: true
                }
                implicitHeight: Appearance.barEdges ? 40 : 48
                Behavior on implicitHeight {NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                color: "transparent"

                Rectangle {
                    id: barBg
                    anchors.fill: parent
                    anchors {
                        topMargin: Appearance.barEdges ? 0 : 8

                        leftMargin: Appearance.barEdges ? 0 : 8
                        rightMargin: Appearance.barEdges ? 0 : 8
                    }
                    Behavior on anchors.topMargin {NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    Behavior on anchors.leftMargin {NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    Behavior on anchors.rightMargin {NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    radius: Appearance.barEdges ? 0 : 20
                    Behavior on radius {NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    color: Appearance.barBgEnabled
                        ? Appearance.colors.cSurfaceContainerLowest
                        : Qt.rgba(
                            Qt.rgba(
                                Appearance.colors.cPrimary.r,
                                Appearance.colors.cPrimary.g,
                                Appearance.colors.cPrimary.b,
                                1
                            ).r,
                            Qt.rgba(
                                Appearance.colors.cPrimary.r,
                                Appearance.colors.cPrimary.g,
                                Appearance.colors.cPrimary.b,
                                1
                            ).g,
                            Qt.rgba(
                                Appearance.colors.cPrimary.r,
                                Appearance.colors.cPrimary.g,
                                Appearance.colors.cPrimary.b,
                                1
                            ).b,
                            0.1
                        )
                        Row {
                            id: leftRow
                            anchors.left: parent.left
                            anchors.leftMargin: Appearance.barEdges ? 32 : 4
                            Behavior on anchors.leftMargin {NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            AppLauncherButton {}
                            Date {}


                        }


                        Row {
                            id: centerRow
                            anchors.centerIn: parent
                            spacing: 8
                            OpenWallpaperSwitcher {}
                            Loader {
                                id: workspacesLoader
                                active: true

                                sourceComponent:
                                    Compositor.compositor === "hyprland" ? workspacesHypr
                                  : Compositor.compositor === "niri"     ? workspacesNiri
                                  : null
                            }


                            Component {
                                id: workspacesHypr
                                HyprlandWorkspaces {}
                            }

                            Component {
                                id: workspacesNiri
                                NiriWorkspaces { screen: modelData }
                            }

                            OpenSettings {}

                        }

                        Row {
                            id: rightRow
                            anchors.right: parent.right
                            anchors.rightMargin: Appearance.barEdges ? 32 : 4
                            Behavior on anchors.rightMargin {NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            PlayerControls {}
                            OpenControlPanel {}
                            PowerButton {}


                        }
                }




            }

        }

    }
}
