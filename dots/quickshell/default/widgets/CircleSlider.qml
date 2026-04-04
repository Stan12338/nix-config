import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.config
Item {
    id: root
    property real size: 160
    property real value: 0.5
    property color trackColor:   Appearance.colors.cPrimaryContainer
    property color fillColor:    Appearance.colors.cPrimary
    property color innerColor:   Appearance.colors.cSurfaceContainer
    property real ringWidth:     size * 0.075
    property real innerScale:    0.65
    property string centerText:  Math.round(value * 100) + "%"
    property string subText:     ""
    property string extraText:   ""

    property real centerTextSize: root.size * 0.14
    property real subTextSize:    root.size * 0.09
    property real extraTextSize:  root.size * 0.08

    readonly property real _r:   (size - ringWidth) / 2
    readonly property real _cx:  size / 2
    readonly property real _cy:  size / 2
    readonly property real _circumference: 2 * Math.PI * _r
    implicitWidth:  size
    implicitHeight: size
    Shape {
        anchors.fill: parent
        ShapePath {
            strokeColor:   root.trackColor
            strokeWidth:   root.ringWidth
            fillColor:     "transparent"
            capStyle:      ShapePath.RoundCap
            PathAngleArc {
                centerX:        root._cx
                centerY:        root._cy
                radiusX:        root._r
                radiusY:        root._r
                startAngle:     0
                sweepAngle:     360
            }
        }
    }
    Shape {
        anchors.fill: parent
        layer.enabled: true
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeColor:   root.fillColor
            strokeWidth:   root.ringWidth
            fillColor:     "transparent"
            capStyle:      ShapePath.RoundCap
            PathAngleArc {
                centerX:        root._cx
                centerY:        root._cy
                radiusX:        root._r
                radiusY:        root._r
                startAngle:     -90
                sweepAngle:     360 * root.value
                Behavior on sweepAngle {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }
        }
    }
    Rectangle {
        id: innerCircle
        anchors.centerIn: parent
        width:  root.size * root.innerScale
        height: root.size * root.innerScale
        radius: width / 2
        color:  root.innerColor
        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Column {
            anchors.centerIn: parent
            spacing: 2
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:  root.centerText
                color: Appearance.colors.cOnSurface
                font.pixelSize: root.centerTextSize
                font.weight: Font.Medium
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:    root.subText
                visible: root.subText !== ""
                color:   Appearance.colors.cOnSurfaceVariant
                font.pixelSize: root.subTextSize
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:    root.extraText
                visible: root.extraText !== ""
                color:   Appearance.colors.cOutline
                font.pixelSize: root.extraTextSize
            }
        }
    }
}
