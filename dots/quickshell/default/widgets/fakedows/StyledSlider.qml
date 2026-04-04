pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config

Slider {
    id: root

    property real trackHeightDiff: 15
    property real handleGap: 6
    property bool useAnim: true

    property color colorPrimary: Appearance.colors.cPrimary
    property color colorTrackBg: Appearance.colors.cPrimaryContainer
    property color colorHandle: colorPrimary

    Layout.fillWidth: true
    implicitWidth: 200
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
            id: sliderBg
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left

            width: root.handleGap
                   + (root.visualPosition * (root.width - root.handleGap * 2))
                   - ((root.pressed ? 1.5 : 3) / 2 + root.handleGap)
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            height: root.height - root.trackHeightDiff
            color: root.colorPrimary
            radius: 10
            topRightRadius: 2
            bottomRightRadius: 2

            Behavior on width {
                NumberAnimation {
                    duration: root.useAnim ? 120 : 0
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            width: root.handleGap
                   + ((1 - root.visualPosition) * (root.width - root.handleGap * 2))
                   - ((root.pressed ? 1.5 : 3) / 2 + root.handleGap)

            height: root.height - root.trackHeightDiff
            color: root.colorTrackBg
            radius: 10
            topLeftRadius: 2
            bottomLeftRadius: 2

            Behavior on width {
                NumberAnimation {
                    duration: root.useAnim ? 120 : 0
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    handle: Rectangle {
        width: 5
        height: root.height
        radius: width / 2
        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        x: root.handleGap + (root.visualPosition * (root.width - root.handleGap * 2)) - width / 2
        anchors.verticalCenter: parent.verticalCenter

        color: root.colorHandle

        Behavior on x {
            NumberAnimation {
                duration: root.useAnim ? 120 : 0
                easing.type: Easing.InOutQuad
            }
        }
    }
}
