pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import qs.config
import Quickshell

//taken from quickshell discord and i applied a few modifications

Scope {
  id: root

  Variants {
    model: Quickshell.screens
    delegate: Component {
      PanelWindow {

        id: root
        property color mColor: Appearance.colors.cSurfaceContainerLowest
        required property var modelData
        screen: modelData

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}


        anchors {
          left: true
          top: true
          right: true
          bottom: true
        }

        Rectangle {
            id: left
            implicitWidth: Appearance.barEdges ? 12 : 0
            Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            implicitHeight: QsWindow.window.height
            color: root.mColor
            visible: Appearance.barEdges
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        Rectangle {
            id: right
            implicitWidth: Appearance.barEdges ? 12 : 0
            Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            implicitHeight: QsWindow.window.height
            color: root.mColor
            anchors.right: parent.right
            visible: Appearance.barEdges
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        Rectangle {
            id: bottom
            implicitWidth: QsWindow?.window.width
            implicitHeight: Appearance.barEdges ? 12 : 0
            Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            color: root.mColor
            anchors.bottom: parent.bottom
            visible: Appearance.barEdges
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }


        Corner {
            id: leftTopCorner
            x: left.implicitWidth
            y: 40
            visible: Appearance.barEdges
        }

        Corner {
            id: leftBottomCorner
            x: left.implicitWidth
            y: QsWindow?.window.height - (radius + bottom.implicitHeight)
            rotation: -90
            visible: Appearance.barEdges
        }

        Corner {
            x: QsWindow?.window.width - (radius + bottom.implicitHeight)
            y: 40
            rotation: 90
            visible: Appearance.barEdges
        }

        Corner {
            x: QsWindow?.window.width - (radius + bottom.implicitHeight)
            y: QsWindow?.window.height - (radius + bottom.implicitHeight)
            rotation: 180
            visible: Appearance.barEdges
        }


        component Corner: Shape {
          id: corner
          preferredRendererType: Shape.CurveRenderer

          property real radius: 28

          ShapePath {
            strokeWidth: 0
            fillColor: root.mColor
            Behavior on fillColor { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            startX: corner.radius

            PathArc {
              relativeX: -corner.radius
              relativeY: corner.radius
              radiusX: corner.radius
              radiusY: corner.radius
              direction: PathArc.Counterclockwise
            }

            PathLine {
              relativeX: 0
              relativeY: -corner.radius
            }

            PathLine {
              relativeX: corner.radius
              relativeY: 0
            }
          }
        }

        Scope {
          PanelWindow {
            screen: modelData
            anchors.left: true
            color: "transparent"
            // implicitWidth: left.implicitWidth
            implicitWidth: Appearance.barEdges ? 12 : 0
            implicitHeight: 0
            visible: Appearance.barEdges
          }

          // PanelWindow {
          //   anchors.top: true
          //   implicitWidth: 0
          //   implicitHeight: top.implicitHeight
          // }

          PanelWindow {
            screen: modelData
            anchors.right: true
            color: "transparent"
            // implicitWidth: right.implicitWidth
            implicitWidth: Appearance.barEdges ? 12 : 0
            implicitHeight: 0
            visible: Appearance.barEdges
          }

          PanelWindow {
            screen: modelData
            anchors.bottom: true
            color: "transparent"
            implicitWidth: 0
            //implicitHeight: bottom.implicitHeight
            implicitHeight: Appearance.barEdges ? 12 : 0
            visible: Appearance.barEdges
          }
        }
      }
    }
  }
}
