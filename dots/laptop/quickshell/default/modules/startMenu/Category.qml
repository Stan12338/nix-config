import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.widgets


Item {
    property string category: "empty"
    Layout.fillWidth: true
    Layout.preferredHeight: width + 32
    ColumnLayout {
        anchors.fill: parent
        Rectangle {

            radius: 6
            Layout.fillWidth: true
            implicitHeight: width
            color: "#2c2c2c"
            border {
                width: 1
                color: "#202020"
            }
            Loader {
                id: contentLoader
                anchors.fill: parent

                sourceComponent: {
                    switch(category) {
                        case "Browsers": return browser
                        case "Coding": return coding
                        case "System": return system
                        case "Creativity": return creativity
                        case "Games": return games
                        case "Other": return other
                        default: return empty
                    }
                }
            }


        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            StyledText {
                text: category
                color: "white"
                anchors.centerIn: parent
                font.weight: 650
                font.pixelSize: 11
            }
        }

    }

    Component {
        id: empty
        GridLayout {
            anchors.fill:parent
            anchors.margins: 8
            columns: 2
            rows: 2
            rowSpacing: 8
            columnSpacing: 8
            CategoryApp {}
            CategoryApp {}
            CategoryApp {}
            CategoryApp {}
        }

    }

    Component {
        id: browser
        GridLayout {
            anchors.fill:parent
            anchors.margins: 8
            columns: 2
            rows: 2
            rowSpacing: 8
            columnSpacing: 8
            CategoryApp {
                icon: "image://icon/zen"
                command: ["zen"]
            }
            CategoryApp {
                icon: "image://icon/brave"
                command: ["brave"]
            }
            CategoryApp {
                icon: "image://icon/firefox"
                command: ["firefox"]
            }
            CategoryApp {
                icon: "image://icon/microsoft-edge"
                command: ["microsoft-edge"]
            }
        }

    }
    Component {
        id: coding
        GridLayout {
            anchors.fill:parent
            anchors.margins: 8
            columns: 2
            rows: 2
            rowSpacing: 8
            columnSpacing: 8
            CategoryApp {
                icon: "image://icon/zed"
                command: ["zeditor"]
            }
            CategoryApp {
                icon: "image://icon/code"
                command: ["code"]
            }
            CategoryApp {
                icon: "image://icon/kate"
                command: ["kate"]
            }
            CategoryApp {
                icon: "../../images/icons/powershell.png"
                command: ["ghostty"]
            }
        }

    }
    Component {
        id: system
        GridLayout {
            anchors.fill:parent
            anchors.margins: 8
            columns: 2
            rows: 2
            rowSpacing: 8
            columnSpacing: 8
            CategoryApp {
                icon: "../../images/icons/settings.png"
            }
            CategoryApp {
                icon: "../../images/icons/powershell.png"
                command: ["ghostty"]
            }
            CategoryApp {
                icon: "../../images/icons/controlpanel.webp"
            }
            CategoryApp {
                icon: "../../images/icons/file_explorer.webp"
                command: ["nemo"]
            }
        }

    }
    Component {
        id: creativity
        GridLayout {
            anchors.fill:parent
            anchors.margins: 8
            columns: 2
            rows: 2
            rowSpacing: 8
            columnSpacing: 8
            CategoryApp {
                icon: "../../images/icons/photos.png"
                command: ["gwenview"]
            }
            CategoryApp {
                icon: "../../images/icons/camera.png"
            }
            CategoryApp {
                icon: "../../images/icons/paint.svg"
            }
            CategoryApp {
            }
        }

    }
    Component {
        id: games
        GridLayout {
            anchors.fill:parent
            anchors.margins: 8
            columns: 2
            rows: 2
            rowSpacing: 8
            columnSpacing: 8
            CategoryApp {
                icon: "image://icon/steam"
                command: ["steam"]
            }
            CategoryApp {
                icon: "image://icon/org.vinegarhq.Sober"
                command: ["flatpak", "run", "org.vinegarhq.Sober"]
            }
            CategoryApp {
                icon: "image://icon/com.modrinth.ModrinthApp"
                command: ["flatpak", "run", "com.modrinth.ModrinthApp"]
            }
            CategoryApp {
            }
        }

    }
    Component {
        id: other
        GridLayout {
            anchors.fill:parent
            anchors.margins: 8
            columns: 2
            rows: 2
            rowSpacing: 8
            columnSpacing: 8
            CategoryApp {
                icon: "../../images/icons/notepad.png"
                command: ["kwrite"]
            }
            CategoryApp {
                icon: "../../images/icons/gitbash.png"
            }
            CategoryApp {
                icon: "../../images/icons/msys2.png"
            }
            CategoryApp {
            }
        }

    }

}
