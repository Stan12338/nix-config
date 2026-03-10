//@ pragma IconTheme Papirus
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.modules.launcher
import qs.modules.bar
import qs.modules.wallpaperSwitcher
import qs.widgets
import qs.modules.controlPanel
import qs.modules.polkit
import qs.modules.overlays
// import qs.modules.appLauncher
// import qs.modules.clipboard
// replaced by unified launcher
import qs.modules.powerMenu
import qs.modules.settings
import qs.modules.mpris
import qs.modules.background


ShellRoot {
    Corners {}
    Bar {}
    LazyLoader {
        loading: true

        Launcher {}
    }
    WallpaperSwitcher {}

    ControlPanel {}
    PolkitWindow {}
    VolumeOsd {}
    NotificationOsd {}
    PowerMenu {}
    // replaced by unified launcher
    // AppLauncher {}
    // Clipboard {}
    MprisPanel {}
    Settings {}

    Wallpaper {}


}
