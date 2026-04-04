pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

// modifed from https://github.com/end-4/dots-hyprland
Singleton {
    id: root

    property string emojiScriptPath: Quickshell.shellDir + "/scripts/emoji.sh"

    property string lineBeforeData: "### DATA ###"

    property var list: []

    function load() {
        emojiFileView.reload()
    }

    function fuzzyQuery(search) {
        if (!search || search.trim() === "")
            return list

        const query = search.toLowerCase()

        return list
            .map(entry => ({
                entry,
                score: fuzzyScore(entry.toLowerCase(), query)
            }))
            .filter(item => item.score >= 0)
            .sort((a, b) => b.score - a.score)
            .map(item => item.entry)
    }

    function fuzzyScore(text, pattern) {
        // 1. Exact match bonus (Highest priority)
        if (text === pattern) return 1000

        let score = 0

        // 2. Exact word match bonus (e.g. "rose" in "🌹 rose")
        // Checks if the pattern exists as a standalone word in the text
        const words = text.split(" ")
        if (words.includes(pattern)) score += 500

        // 3. Start of string bonus
        if (text.startsWith(pattern)) score += 100

        let ti = 0
        let lastTi = -1
        let consecutive = 0

        for (let pi = 0; pi < pattern.length; pi++) {
            const ch = pattern[pi]
            ti = text.indexOf(ch, ti)

            if (ti === -1) return -1

            score += 10

            // 4. Consecutive character bonus
            if (ti === lastTi + 1) {
                consecutive++
                score += (5 * consecutive)
            } else {
                consecutive = 0
            }

            // 5. Word boundary bonus (match starts at index 0 or after a space)
            if (ti === 0 || text[ti - 1] === ' ') {
                score += 25
            }

            lastTi = ti
            ti++
        }

        // Penalty for length (prefer shorter matches)
        return score - (text.length * 0.1)
    }

    function updateEmojis(fileContent) {
        const lines = fileContent.split("\n")
        const dataIndex = lines.indexOf(lineBeforeData)

        if (dataIndex === -1) {
            list = []
            return
        }

        list = lines
            .slice(dataIndex + 1)
            .map(l => l.trim())
            .filter(l => l.length > 0)
    }

    FileView {
        id: emojiFileView
        path: Qt.resolvedUrl(root.emojiScriptPath)

        onLoadedChanged: {
            if (!loaded)
                return
            root.updateEmojis(text())
        }
    }
}
