import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import Quickshell.Hyprland

Scope {
    id: root
    
    
    Connections {
        target: PolkitService
    }
    
    Loader {
        active: PolkitService.interactionAvailable && PolkitService.flow !== null
        
        
        sourceComponent: Variants {
            model: Quickshell.screens
            
            delegate: PanelWindow {
                id: panelWindow
                required property var modelData
                screen: {
                    const activeMonitor = Hyprland.focusedMonitor?.name
                    return Quickshell.screens.find(s => s.name === activeMonitor) || Quickshell.screens[0]
                }
                
                
                visible: true
                
                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }
                
                color: "transparent"
                WlrLayershell.namespace: "quickshell:polkit"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
                WlrLayershell.layer: WlrLayer.Overlay
                exclusionMode: ExclusionMode.Ignore
                
                PolkitDialog {
                    anchors.fill: parent
                }
            }
        }
    }
}