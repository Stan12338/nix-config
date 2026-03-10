import QtQuick
import qs.widgets
import qs.config

Rectangle {
    id: root
    radius: 18
    property bool isSelected: false
    color: isSelected ? Appearance.colors.cPrimary : (mouseArea.containsMouse ? Appearance.colors.cPrimary : Appearance.colors.cSurfaceContainer)
    signal clicked()
    property int iconSize: 48

    transform: Scale {
        id: hoverScale
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: (mouseArea.containsMouse || isSelected) ? 1.07 : 1
        yScale: (mouseArea.containsMouse || isSelected) ? 1.07 : 1
        Behavior on xScale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on yScale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

    StyledText {
        id: icon
        anchors.centerIn: parent
        text: ""
        scale: (mouseArea.containsMouse || isSelected) ? 2 : 1
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        font.pixelSize: root.iconSize
        color: (mouseArea.containsMouse || isSelected) ? Appearance.colors.cOnPrimary : Appearance.colors.cPrimary
        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
