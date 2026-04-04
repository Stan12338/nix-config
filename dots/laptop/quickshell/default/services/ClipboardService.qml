pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string cliphistBinary: "cliphist"
    property list<string> entries: []

    function fuzzyQuery(search) {
        if (search.trim() === "") {
            return entries;
        }
        const query = search.toLowerCase()
        return entries.filter(entry =>
            entry.toLowerCase().includes(query)
        )
    }

    function refresh() {
        readProc.buffer = []
        readProc.running = true
    }

    function copy(entry) {
        const escaped = entry.replace(/'/g, "'\\''")
        Quickshell.execDetached(["bash", "-c", `printf '%s' '${escaped}' | ${cliphistBinary} decode | wl-copy`]);
    }
    function copyRaw(text) {
        const escaped = text.replace(/'/g, "'\\''")
        Quickshell.execDetached(["bash", "-c", `printf '%s' '${escaped}' | wl-copy`]);
    }

    function deleteEntry(entry) {
        deleteProc.entry = entry;
        deleteProc.running = true;
    }

    function wipe() {
        wipeProc.running = true;
    }

    Process {
        id: deleteProc
        property string entry: ""
        command: {
            if (entry === "") return []
            const escaped = entry.replace(/'/g, "'\\''")
            return ["bash", "-c", `echo '${escaped}' | ${root.cliphistBinary} delete`]
        }
        onExited: {
            root.refresh();
            deleteProc.entry = "";
        }
    }

    Process {
        id: wipeProc
        command: [root.cliphistBinary, "wipe"]
        onExited: {
            root.refresh();
        }
    }

    Process {
        id: readProc
        property list<string> buffer: []
        command: [root.cliphistBinary, "list"]

        stdout: SplitParser {
            onRead: (line) => {
                readProc.buffer.push(line)
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.entries = readProc.buffer
            } else {
                console.error("[Clipboard] Failed to refresh with code", exitCode)
            }
        }
    }

    IpcHandler {
        target: "cliphistService"

        function update() {
            root.refresh()
        }
    }

    Component.onCompleted: {
        refresh()
    }
}
