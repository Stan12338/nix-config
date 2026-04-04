pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    /* ---------- Adapter ---------- */
    readonly property var adapter: Bluetooth.defaultAdapter ?? null
    readonly property bool available: Bluetooth.adapters.values.length > 0
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    /* ---------- Devices ---------- */
    readonly property list<BluetoothDevice> devices:
        Bluetooth.devices.values

    readonly property BluetoothDevice firstActiveDevice:
        devices.find(d => d.connected) ?? null

    readonly property int activeDeviceCount:
        devices.filter(d => d.connected).length

    readonly property bool connected:
        devices.some(d => d.connected)

    /* ---------- Sorting ---------- */
    function sortFunction(a, b) {
        const macRegex = /^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$/;
        const aIsMac = macRegex.test(a.name);
        const bIsMac = macRegex.test(b.name);

        if (aIsMac !== bIsMac)
            return aIsMac ? 1 : -1;

        return (a.name || "").localeCompare(b.name || "");
    }

    /* ---------- Categorised lists (REACTIVE) ---------- */
    readonly property list<BluetoothDevice> connectedDevices:
        devices.filter(d => d.connected).sort(sortFunction)

    readonly property list<BluetoothDevice> pairedButNotConnectedDevices:
        devices.filter(d => d.paired && !d.connected).sort(sortFunction)

    readonly property list<BluetoothDevice> unpairedDevices:
        devices.filter(d => !d.paired && !d.connected).sort(sortFunction)

    readonly property list<BluetoothDevice> friendlyDeviceList: [
        ...connectedDevices,
        ...pairedButNotConnectedDevices,
        ...unpairedDevices
    ]

    /* ---------- Actions ---------- */
    function togglePower() {
        if (!adapter) return;
        adapter.enabled = !adapter.enabled;
        if (!adapter.enabled)
            adapter.discovering = false;
    }

    function toggleDiscovery() {
        if (!adapter || !adapter.enabled) return;
        adapter.discovering = !adapter.discovering;
    }

    function forgetDevice(device) {
        if (!adapter || !device) return;
        adapter.removeDevice(device.address);
    }
}
