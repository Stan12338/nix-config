pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool sloppySearch: false
    property real scoreThreshold: 0.2

    property string usageFilePath: Quickshell.stateDir + "/app_usage.json"
    property bool usageDataLoaded: false

    property alias usageData: jsonAdapter.usage

    Timer {
        id: fileWriteTimer
        interval: 100
        repeat: false
        onTriggered: {
            usageFileView.writeAdapter()
        }
    }

    FileView {
        id: usageFileView
        path: root.usageFilePath
        watchChanges: false

        onLoaded: root.usageDataLoaded = true
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                console.log("App usage file not found, will create it on first launch.")
            }
            root.usageDataLoaded = true
        }

        JsonAdapter {
            id: jsonAdapter
            property var usage: ({})
        }
    }

    property var substitutions: ({
        "sober": "org.vinegarhq.Sober",
        "code-url-handler": "visual-studio-code",
        "Code": "visual-studio-code",
        "gnome-tweaks": "org.gnome.tweaks",
        "pavucontrol-qt": "pavucontrol",
        "wps": "wps-office2019-kprometheus",
        "wpsoffice": "wps-office2019-kprometheus",
        "footclient": "foot",
    })

    property var regexSubstitutions: [
        {
            "regex": /^steam_app_(\d+)$/,
            "replace": "steam_icon_$1"
        },

        {
            "regex": /Minecraft.*/,
            "replace": "minecraft"
        },
        {
            "regex": /.*polkit.*/,
            "replace": "system-lock-screen"
        },
        {
            "regex": /gcr.prompter/,
            "replace": "system-lock-screen"
        }
    ]


    readonly property list<DesktopEntry> appList: Array.from(DesktopEntries.applications.values)
        .filter((app, index, self) =>
            index === self.findIndex((t) => (
                t.id === app.id
            ))
        )

    function trackAppLaunch(appId) {
        if (!appId) return;
        var now = Date.now();

        if (!root.usageData[appId]) {
            root.usageData[appId] = {
                count: 0,
                lastUsed: 0,
                firstUsed: now
            };
        }

        root.usageData[appId].count++;
        root.usageData[appId].lastUsed = now;
        jsonAdapter.usage = jsonAdapter.usage;

        // Debounce the write operation
        fileWriteTimer.restart();
    }

    function getUsageScore(appId) {
        if (!appId || !root.usageData[appId]) return 0;
        var data = root.usageData[appId];
        var now = Date.now();

        var countScore = Math.log(data.count + 1) * 100;
        var daysSinceUse = (now - data.lastUsed) / (1000 * 60 * 60 * 24);
        var recencyScore = 0;

        if (daysSinceUse < 1) {
            recencyScore = 200;
        } else if (daysSinceUse < 7) {
            recencyScore = 100;
        } else if (daysSinceUse < 30) {
            recencyScore = 50;
        } else {
            recencyScore = 20;
        }

        return countScore + recencyScore;
    }

    function calculateFuzzyScore(text, query) {
        if (!query || query.length === 0) return 10000;
        text = text.toLowerCase();
        query = query.toLowerCase();

        var score = 0;
        var textIndex = 0;
        var queryIndex = 0;
        var consecutive = 0;
        var matchedIndices = [];

        while (textIndex < text.length && queryIndex < query.length) {
            if (text[textIndex] === query[queryIndex]) {
                // Base score for character match
                score += 10;
                // Bonus for consecutive matches
                score += (consecutive * 5);
                // Bonus for matches at word boundaries
                if (textIndex === 0 || text[textIndex - 1] === ' ' || text[textIndex - 1] === '-') {
                    score += 30;
                }

                // Bonus for exact prefix match
                if (textIndex === queryIndex) {
                    score += 15;
                }

                matchedIndices.push(textIndex);
                consecutive++;
                queryIndex++;
            } else {
                consecutive = 0;
                score -= 1;
            }
            textIndex++;
        }

        if (queryIndex !== query.length) {
            return -1;
        }
        var lengthRatio = query.length / text.length;
        score += Math.floor(lengthRatio * 20);

        if (matchedIndices.length > 0) {
            var avgPosition = matchedIndices.reduce((a, b) => a + b, 0) / matchedIndices.length;
            score += Math.floor((1 - (avgPosition / text.length)) * 10);
        }

        return score;
    }

    function fuzzyQuery(search) {
        if (!search || search.length === 0) {
            var sortedApps = root.appList.slice();
            sortedApps.sort((a, b) => {
                var usageA = getUsageScore(a.id);
                var usageB = getUsageScore(b.id);
                if (usageB !== usageA) {
                    return usageB - usageA;
                }

                var nameA = a.name.toLowerCase();
                var nameB = b.name.toLowerCase();
                return nameA.localeCompare(nameB);
            });
            return sortedApps;
        }

        var results = [];
        var searchLower = search.toLowerCase();
        for (var i = 0; i < root.appList.length; i++) {
            var app = root.appList[i];
            var nameScore = calculateFuzzyScore(app.name, search);
            var genericScore = app.genericName ? calculateFuzzyScore(app.genericName, search) : -1;
            var commentScore = app.comment ? calculateFuzzyScore(app.comment, search) : -1;
            var execScore = app.exec ? calculateFuzzyScore(app.exec, search) : -1;

            var bestScore = Math.max(nameScore, genericScore, commentScore, execScore);
            if (nameScore > -1) {
                bestScore = nameScore + 50;
            } else if (genericScore > -1) {
                bestScore = genericScore + 25;
            }

            var nameLower = app.name.toLowerCase();
            if (nameLower.indexOf(searchLower) === 0) {
                bestScore += 1000;
            } else if (nameLower.indexOf(searchLower) > -1) {
                bestScore += 500;
            }

            if (bestScore > -1) {
                var usageBonus = getUsageScore(app.id);
                results.push({
                    entry: app,
                    score: bestScore + usageBonus,
                    name: app.name.toLowerCase()
                });
            }
        }

        results.sort((a, b) => {
            if (b.score !== a.score) {
                return b.score - a.score;
            }

            return a.name.localeCompare(b.name);
        });
        return results.map(item => item.entry);
    }


    function getReverseDomainNameAppName(str) {
        var parts = str.split('.');
        return parts.slice(-1)[0];
    }

    function getKebabNormalizedAppName(str) {
        return str.toLowerCase().replace(/\s+/g, "-");
    }

    function getUndescoreToKebabAppName(str) {
        return str.toLowerCase().replace(/_/g, "-");
    }

    function iconExists(iconName) {
        if (!iconName || iconName.length === 0) return false;
        return (Quickshell.iconPath(iconName, true).length > 0)
            && !iconName.includes("image-missing");
    }

    function guessIcon(str) {
        if (!str || str.length === 0) return "image-missing";
        const entry = DesktopEntries.byId(str);
        if (entry && iconExists(entry.icon)) return entry.icon;

        if (root.substitutions[str] && iconExists(root.substitutions[str])) return root.substitutions[str];
        if (root.substitutions[str.toLowerCase()] && iconExists(root.substitutions[str.toLowerCase()])) return root.substitutions[str.toLowerCase()];

        for (var i = 0; i < root.regexSubstitutions.length; i++) {
            const substitution = root.regexSubstitutions[i];
            const replacedName = str.replace(
                substitution.regex,
                substitution.replace,
            );
            if (replacedName !== str && iconExists(replacedName)) return replacedName;
        }

        if (iconExists(str)) return str;
        const lowercased = str.toLowerCase();
        if (iconExists(lowercased)) return lowercased;

        const reverseDomainNameAppName = getReverseDomainNameAppName(str);
        if (iconExists(reverseDomainNameAppName)) return reverseDomainNameAppName;

        const lowercasedDomainNameAppName = reverseDomainNameAppName.toLowerCase();
        if (iconExists(lowercasedDomainNameAppName)) return lowercasedDomainNameAppName;

        const kebabNormalizedGuess = getKebabNormalizedAppName(str);
        if (iconExists(kebabNormalizedGuess)) return kebabNormalizedGuess;

        const undescoreToKebabGuess = getUndescoreToKebabAppName(str);
        if (iconExists(undescoreToKebabGuess)) return undescoreToKebabGuess;
        const nameSearchResults = root.fuzzyQuery(str);
        if (nameSearchResults.length > 0) {
            const guess = nameSearchResults[0].icon
            if (iconExists(guess)) return guess;
        }
        const heuristicEntry = DesktopEntries.heuristicLookup(str);
        if (heuristicEntry && iconExists(heuristicEntry.icon)) return heuristicEntry.icon;
        return "application-x-executable";
    }
}
