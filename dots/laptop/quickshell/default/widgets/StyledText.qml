import QtQuick

Text {
    font.family: "Noto sans"
    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
}
