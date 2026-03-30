//@ pragma IconTheme Papirus
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.modules.bar
import qs.modules.background
import qs.modules.startMenu
import qs.modules.controlPanel

ShellRoot {
    Bar {}
    Wallpaper {}
    StartMenu {}
    ControlPanel {}

}
