import QtQuick

Text {
    font.family: "JetBrains Mono"
    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
}
