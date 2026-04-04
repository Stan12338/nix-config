pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Singleton {
    id: root
    property var ignoredAppRegexes: []
    property string dataFilePath: Quickshell.stateDir + "/taskbar_data.json"
    property bool dataLoaded: false
    property var runtimeOrder: []

    Timer {
        id: fileWriteTimer
        interval: 100
        repeat: false
        onTriggered: fileView.writeAdapter()
    }

    FileView {
        id: fileView
        path: root.dataFilePath
        watchChanges: false
        onLoaded: {
            root.runtimeOrder = jsonAdapter.data.pinnedOrder ?? []
            root.dataLoaded = true
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                jsonAdapter.data = { pinnedApps: [], pinnedOrder: [] }
                fileView.writeAdapter()
            }
            root.runtimeOrder = []
            root.dataLoaded = true
        }
        JsonAdapter {
            id: jsonAdapter
            property var data: ({ pinnedApps: [], pinnedOrder: [] })
        }
    }

    function save() {
        const pinned = jsonAdapter.data.pinnedApps ?? []
        const pinnedOnly = runtimeOrder.filter(id =>
            pinned.some(p => p.toLowerCase() === id.toLowerCase())
        )
        jsonAdapter.data = Object.assign({}, jsonAdapter.data, { pinnedOrder: pinnedOnly })
        jsonAdapter.data = jsonAdapter.data
        fileWriteTimer.restart()
    }

    function isPinned(appId) {
        if (!appId) return false
        const pinned = jsonAdapter.data.pinnedApps ?? []
        return pinned.some(p => p.toLowerCase() === appId.toLowerCase())
    }

    function findDesktopEntry(appId) {
        if (!appId) return null

        const direct = DesktopEntries.byId(appId)
        if (direct) {
            return direct
        }

        const lowerAppId = appId.toLowerCase()
        for (const entry of DesktopEntries.applications.values) {
            if (entry.id.toLowerCase() === lowerAppId) {
                return entry
            }
        }
        return null
    }

    function togglePin(appId) {
        const currentData = jsonAdapter.data
        let pinned = currentData.pinnedApps ?? []
        const isCurrentlyPinned = pinned.some(p => p.toLowerCase() === appId.toLowerCase())
        let newPinned = []

        if (isCurrentlyPinned) {
            newPinned = pinned.filter(p => p.toLowerCase() !== appId.toLowerCase())
        } else {
            const entry = findDesktopEntry(appId)
            const canonicalId = entry ? entry.id : appId
            newPinned = [...pinned, canonicalId]
        }

        jsonAdapter.data = Object.assign({}, currentData, { pinnedApps: newPinned })
        save()
    }

    function move(fromIndex, toIndex) {
        if (fromIndex === toIndex) return

        const fromEntry = entries[fromIndex]
        const toEntry = entries[toIndex]
        if (!fromEntry || !toEntry) return

        const fromId = fromEntry.appId
        const toId = toEntry.appId

        let order = [...runtimeOrder]

        let fromOrderIndex = order.findIndex(id => id.toLowerCase() === fromId.toLowerCase())
        let toOrderIndex = order.findIndex(id => id.toLowerCase() === toId.toLowerCase())

        if (fromOrderIndex === -1) {
            order.push(fromId)
            fromOrderIndex = order.length - 1
        }

        if (toOrderIndex === -1) {
            order.push(toId)
            toOrderIndex = order.length - 1
        }

        const [item] = order.splice(fromOrderIndex, 1)
        order.splice(toOrderIndex, 0, item)

        root.runtimeOrder = order

        if (fromEntry.pinned || toEntry.pinned) {
            save()
        }
    }

    property list<var> entries: {
        const pinned = jsonAdapter.data.pinnedApps ?? []

        var map = new Map()

        for (const appId of pinned) {
            const key = appId.toLowerCase()
            if (!map.has(key)) {
                const entry = findDesktopEntry(appId)
                const canonicalId = entry ? entry.id : appId
                const iconName = entry?.icon ?? ""
                map.set(key, { originalAppId: canonicalId, pinned: true, toplevels: [], iconName: iconName })
            }
        }

        var aliasToMapKey = new Map()
        for (const [key, value] of map) {
            aliasToMapKey.set(key, key)

            const entry = DesktopEntries.byId(value.originalAppId)
            if (entry) {
                aliasToMapKey.set(entry.id.toLowerCase(), key)
                const parts = entry.id.split(".")
                if (parts.length > 1)
                    aliasToMapKey.set(parts[parts.length - 1].toLowerCase(), key)
            }
        }

        const ignoredRegexes = ignoredAppRegexes.map(p => new RegExp(p, "i"))
        for (const toplevel of ToplevelManager.toplevels.values) {
            if (ignoredRegexes.some(re => re.test(toplevel.appId))) continue

            const toplevelKey = toplevel.appId.toLowerCase()

            if (map.has(toplevelKey)) {
                map.get(toplevelKey).originalAppId = toplevel.appId
                map.get(toplevelKey).toplevels.push(toplevel)
                continue
            }

            const resolvedKey = aliasToMapKey.get(toplevelKey)
            if (resolvedKey && map.has(resolvedKey)) {
                map.get(resolvedKey).toplevels.push(toplevel)
                continue
            }

            const toplevelEntry = DesktopEntries.byId(toplevel.appId)
            if (toplevelEntry) {
                const entryIdKey = toplevelEntry.id.toLowerCase()
                if (map.has(entryIdKey)) {
                    map.get(entryIdKey).toplevels.push(toplevel)
                    continue
                }
                const resolvedViaEntry = aliasToMapKey.get(entryIdKey)
                if (resolvedViaEntry && map.has(resolvedViaEntry)) {
                    map.get(resolvedViaEntry).toplevels.push(toplevel)
                    continue
                }
            }

            map.set(toplevelKey, { originalAppId: toplevel.appId, pinned: false, toplevels: [toplevel], iconName: "" })
        }

        var result = []
        for (const [key, value] of map) {
            let iconName = value.iconName
            if (!iconName) {
                const desktopEntry = findDesktopEntry(value.originalAppId)
                iconName = desktopEntry?.icon ?? ""
            }

            result.push(appEntryComp.createObject(null, {
                appId: value.originalAppId,
                toplevels: value.toplevels,
                pinned: value.pinned,
                iconName: iconName
            }))
        }

        const order = runtimeOrder
        if (order.length > 0) {
            result.sort((a, b) => {
                const ai = order.findIndex(id => id.toLowerCase() === a.appId.toLowerCase())
                const bi = order.findIndex(id => id.toLowerCase() === b.appId.toLowerCase())
                return (ai === -1 ? 99999 : ai) - (bi === -1 ? 99999 : bi)
            })
        }

        return result
    }

    component TaskbarAppEntry: QtObject {
        required property string appId
        required property list<var> toplevels
        required property bool pinned
        property bool isSeparator: false
        property string iconName: ""
    }

    Component {
        id: appEntryComp
        TaskbarAppEntry {}
    }
}
