pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool barBgEnabled: true
    property string barType: "default"
    property bool barEdges: barBgEnabled && barType === "default"
    property bool isDark: true
    property string scheme: "scheme-tonal-spot"
    property string wallpaper: ""
    property var colors: JSON.parse(colorsJsonFile.text()).colors[isDark ? "dark" : "light"]
    property string configFilePath: Quickshell.stateDir + "/config.json"
    property bool configDataLoaded: false
    property bool isUpdatingConfig: false
    property alias configData: configJsonAdapter.config

    property int lastMatugenTime: 0
    property int matugenCooldown: 100

    property bool isLoadingFromFile: false
    property bool isFromMatugenIPC: false

    Timer {
        id: configWriteTimer
        interval: 100
        repeat: false
        onTriggered: {
            configFileView.writeAdapter()
        }
    }

    FileView {
        id: configFileView
        path: root.configFilePath
        watchChanges: false

        onLoaded: {
            isLoadingFromFile = true

            if (configJsonAdapter.config.wallpaper !== undefined && configJsonAdapter.config.wallpaper !== "") {
                root.wallpaper = configJsonAdapter.config.wallpaper
            }

            if (configJsonAdapter.config.isDark !== undefined) {
                root.isDark = configJsonAdapter.config.isDark
            }
            if (configJsonAdapter.config.scheme !== undefined && configJsonAdapter.config.scheme !== "") {
                root.scheme = configJsonAdapter.config.scheme
            } else {
                root.scheme = "scheme-tonal-spot"
            }

            if (configJsonAdapter.config.barType !== undefined && configJsonAdapter.config.barType !== "") {
                root.barType = configJsonAdapter.config.barType
            }

            if (configJsonAdapter.config.barBgEnabled !== undefined) {
                root.barBgEnabled = configJsonAdapter.config.barBgEnabled
            }

            root.configDataLoaded = true
            isLoadingFromFile = false
        }

        onLoadFailed: error => {
            root.configDataLoaded = true
            isLoadingFromFile = false
            saveConfig()
        }

        JsonAdapter {
            id: configJsonAdapter
            property var config: ({
                wallpaper: "",
                isDark: true,
                scheme: "scheme-tonal-spot",
                barType: "floating",
                barBgEnabled: true
            })
        }
    }

    readonly property bool readyToSave: configDataLoaded && !isUpdatingConfig && !isLoadingFromFile

    onIsDarkChanged: if (readyToSave) saveConfig()
    onSchemeChanged: if (readyToSave) saveConfig()
    onBarTypeChanged: if (readyToSave) saveConfig()
    onBarBgEnabledChanged: if (readyToSave) saveConfig()

    onWallpaperChanged: {
        if (readyToSave && !isFromMatugenIPC && root.wallpaper !== configJsonAdapter.config.wallpaper) {
            saveConfig()
        }
    }

    function saveConfig() {
        configJsonAdapter.config = {
            wallpaper: root.wallpaper,
            isDark: root.isDark,
            scheme: root.scheme,
            barType: root.barType,
            barBgEnabled: root.barBgEnabled
        }

        configWriteTimer.restart()
    }

    FileView {
        id: colorsJsonFile
        path: Quickshell.shellDir + "/config/colors.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: {
            reload()
        }
    }

    Process {
        id: matugenProcess
    }

    function canRunMatugen() {
        var currentTime = Date.now()
        var canRun = (currentTime - lastMatugenTime) >= matugenCooldown
        return canRun
    }

    property string lastMatugenWallpaper: ""

    function runMatugen(imagePath, mode, schemeName) {
        if (!canRunMatugen()) {
            return false
        }

        lastMatugenWallpaper = imagePath
        lastMatugenTime = Date.now()
        matugenProcess.command = [
            "matugen", "image", imagePath,
            "-m", mode,
            "-t", schemeName
        ]
        matugenProcess.running = true
        return true
    }

    function setTheme(mode) {
        root.isDark = (mode === "dark")

        if (root.wallpaper) {
            runMatugen(root.wallpaper, mode, root.scheme)
        }

        if (configDataLoaded) saveConfig()
    }

    function setScheme(schemeName, mode) {
        isUpdatingConfig = true
        root.scheme = schemeName

        var finalMode = (mode === "dark" || mode === "light") ? mode : (root.isDark ? "dark" : "light")

        root.isDark = (finalMode === "dark")
        isUpdatingConfig = false

        if (configDataLoaded) {
            saveConfig()
        }

        if (root.wallpaper) {
            runMatugen(root.wallpaper, finalMode, schemeName)
        }
    }

    // for when called not from ipc
    function setWallpaper(path) {
        if (root.wallpaper === path) {
            return
        }

        isUpdatingConfig = true
        root.wallpaper = path
        isUpdatingConfig = false

        if (configDataLoaded) {
            saveConfig()
        }

        if (path && !isFromMatugenIPC) {
            runMatugen(path, root.isDark ? "dark" : "light", root.scheme)
        }
    }

    // when the qs ipc is called from matugen or somewhere else idk
    function setWallpaperFromMatugen(path) {
        isFromMatugenIPC = true
        setWallpaper(path)
        isFromMatugenIPC = false
    }
}
