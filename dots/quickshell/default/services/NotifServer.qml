pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    property string dataFilePath: Quickshell.shellDir + "/generated/notifications.json"
    property list<NotifEntry> data: []
    property list<NotifEntry> popups: data.filter(n => n !== null && n !== undefined && n.popup)
    readonly property int unreadCount: data.filter(n => n !== null && n !== undefined && !n.read).length

    property int autoClearDays: Appearance.autoClearDays

    Timer {
        id: fileWriteTimer
        interval: 100
        repeat: false
        onTriggered: {
            fileView.writeAdapter()
        }
    }
    Timer {
        id: autoClearTimer
        interval: 86400000
        repeat: true
        running: root.autoClearDays > 0
        onTriggered: root.cleanupOldEntries()
    }

    function cleanupOldEntries() {
        if (root.autoClearDays <= 0) return
        const cutoff = Date.now() - root.autoClearDays * 86400000
        const before = root.data.length
        root.data = root.data.filter(n => n !== null && n !== undefined && n.time.getTime() >= cutoff)
        if (root.data.length !== before) root.save()
    }

    FileView {
        id: fileView
        path: root.dataFilePath
        watchChanges: false
        onLoaded: {
            const saved = jsonAdapter.data.notifications ?? []
            for (const n of saved) {
                root.data.push(entryComp.createObject(root, {
                    popup: false,
                    read: n.read ?? false,
                    summary: n.summary ?? "",
                    body: n.body ?? "",
                    appIcon: n.appIcon ?? "",
                    appName: n.appName ?? "",
                    image: n.image ?? "",
                    urgency: n.urgency ?? 1,
                    time: new Date(n.time ?? Date.now()),
                    notifId: n.id ?? 0
                }))
            }
            root.data = root.data
            root.cleanupOldEntries()
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                jsonAdapter.data = { notifications: [] }
                fileView.writeAdapter()
            }
        }
        JsonAdapter {
            id: jsonAdapter
            property var data: ({ notifications: [] })
        }
    }

    function save() {
        const serialized = root.data.filter(n => n !== null && n !== undefined).map(n => ({
            id: n.notifId,
            summary: n.summary,
            body: n.body,
            appIcon: n.appIcon,
            appName: n.appName,
            image: n.image,
            urgency: n.urgency,
            time: n.time.getTime(),
            read: n.read
        }))
        jsonAdapter.data = { notifications: serialized }
        fileWriteTimer.restart()
    }

    NotificationServer {
        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        onNotification: notif => {
            notif.tracked = true
            const entry = entryComp.createObject(root, {
                popup: true,
                read: false,
                summary: notif.summary ?? "",
                body: notif.body ?? "",
                appIcon: notif.appIcon ?? "",
                appName: notif.appName ?? "",
                image: notif.image ?? "",
                urgency: notif.urgency ?? 1,
                time: new Date(),
                notifId: notif.id ?? 0,
                liveNotif: notif
            })
            root.data.unshift(entry)
            if (root.data.length > 200) root.data = root.data.slice(0, 200)
            root.data = root.data
            root.save()
        }
    }

    function removeById(id) {
        const i = data.findIndex(n => n.notifId === id)
        if (i >= 0) {
            data.splice(i, 1)
            root.data = root.data
            save()
        }
    }

    function clearAll() {
        root.data = []
        save()
    }

    function markAllRead() {
        root.data.forEach(n => n.read = true)
        root.data = root.data
        save()
    }

    component NotifEntry: QtObject {
        id: entry
        property bool popup: false
        property bool read: false
        property string summary: ""
        property string body: ""
        property string appIcon: ""
        property string appName: ""
        property string image: ""
        property int urgency: 1
        property date time: new Date()
        property int notifId: 0
        property var liveNotif: null
        readonly property list<NotificationAction> actions: liveNotif ? liveNotif.actions : []
        readonly property string timeStr: {
            const diff = Time.date.getTime() - time.getTime()
            const m = Math.floor(diff / 60000)
            const h = Math.floor(m / 60)
            const d = Math.floor(h / 24)
            if (h < 1 && m < 1) return "now"
            if (h < 1) return `${m}m`
            if (d < 1) return `${h}h`
            return `${d}d`
        }

        readonly property Timer popupTimer: Timer {
            running: entry.popup
            interval: (entry.liveNotif && entry.liveNotif.expireTimeout > 0) ? entry.liveNotif.expireTimeout : 5000
            onTriggered: {
                entry.popup = false
                root.data = root.data
            }
        }

        readonly property Connections liveConnections: Connections {
            target: entry.liveNotif
            function onClosed(reason) {
                const idx = root.data.indexOf(entry)
                if (idx >= 0) {
                    root.data.splice(idx, 1)
                    root.data = root.data
                    root.save()
                }
            }
        }
    }

    Component {
        id: entryComp
        NotifEntry {}
    }
}
