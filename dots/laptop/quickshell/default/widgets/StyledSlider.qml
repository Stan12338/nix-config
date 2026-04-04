pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config

Slider {
    id: root
    property real trackHeight: 4
    property real handleSize: 20
    property real handleInnerSize: 10
    property real handleGap: 6
    property bool useAnim: false
    property color colorPrimary: "#a6a5a1" //"#454545"
    property color colorTrackBg: "#454545" //"#a6a5a1"
    property color colorHandle: colorTrackBg
    property color colorHandleInner: "#a6a5a1"

    Layout.fillWidth: true
    implicitWidth: 240
    implicitHeight: 40
    from: 0
    to: 100
    value: 0

    MouseArea {
        anchors.fill: parent
        onPressed: function(mouse) { mouse.accepted = false }
        cursorShape: root.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
    }

    background: Item {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: parent.height

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.trackHeight
            color: root.colorTrackBg
            radius: root.trackHeight / 2

            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
        }

        Rectangle {
            id: filledTrack
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            height: root.trackHeight
            width: root.handleGap
                   + (root.visualPosition * (root.width - root.handleGap * 2))
                   - root.handleSize / 3
            color: root.colorPrimary
            radius: root.trackHeight / 2

            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Behavior on width {
                NumberAnimation {
                    duration: root.useAnim ? 120 : 0
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    handle: Item {
        width: root.handleSize
        height: root.handleSize
        x: root.handleGap + (root.visualPosition * (root.width - root.handleGap * 2)) - root.handleSize / 2
        anchors.verticalCenter: parent.verticalCenter

        Behavior on x {
            NumberAnimation {
                duration: root.useAnim ? 120 : 0
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            id: outerCircle
            anchors.centerIn: parent
            width: root.handleSize
            height: root.handleSize
            radius: root.handleSize / 2
            color: root.colorHandle
            scale: root.pressed ? 0.85 : (root.hovered ? 1.1 : 1.0)

            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Behavior on scale {
                NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: root.handleInnerSize
            height: root.handleInnerSize
            radius: root.handleInnerSize / 2
            color: root.colorHandleInner

            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
        }
    }
}
