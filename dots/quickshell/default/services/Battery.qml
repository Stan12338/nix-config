pragma Singleton
import Quickshell.Services.UPower
import Quickshell
import QtQuick

Singleton {
    property bool charging: !UPower.onBattery
    property real percentage: UPower.displayDevice.percentage * 100
    property real timeToFull: UPower.displayDevice.timeToFull
    property real timeToEmpty: UPower.displayDevice.timeToEmpty

    property string capacity:
        percentage >= 95 ? "full" :
        percentage >= 80 ? "medium-high" :
        percentage >= 60 ? "medium" :
        percentage >= 40 ? "medium-low" :
        percentage >= 20 ? "low" :
        percentage > 0  ? "lowest" :
                           "empty"
}
