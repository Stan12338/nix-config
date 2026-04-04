//@ pragma IconTheme Papirus
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.config
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
import qs.fakedows.modules.bar
import qs.fakedows.modules.controlPanel
import qs.fakedows.modules.startMenu

ShellRoot {


    Wallpaper {}
    Loader {
        sourceComponent: Appearance.fakedows ? fakedows : main
    }

    property Component main: Component {
        id: main
        Item {
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
            MprisPanel {}
            Settings {}
        }

    }

    //fun fact i created fakedows to prank my school it

    property Component fakedows: Component {
        Item {
            WBar {}
            WStartMenu {}
            WControlPanel {}
        }

    }


}
