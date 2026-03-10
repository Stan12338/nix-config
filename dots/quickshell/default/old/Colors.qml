pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: colors
    
    property color cPrimary: "#ffffff"
    property color cOn_primary: "#000000"
    property color cPrimary_container: "#444444"
    property color cOn_primary_container: "#ffffff"
    property color cPrimary_fixed: "#b7eaff"
    property color cPrimary_fixed_dim: "#5cd5fb"
    property color cOn_primary_fixed: "#001f28"
    property color cOn_primary_fixed_variant: "#004e60"
    property color cSecondary: "#888888"
    property color cOn_secondary: "#000000"
    property color cSecondary_container: "#555555"
    property color cOn_secondary_container: "#ffffff"
    property color cSecondary_fixed: "#cfe6f1" 
    property color cSecondary_fixed_dim: "#b3cad4"
    property color cOn_secondary_fixed: "#071e26"
    property color cOn_secondary_fixed_variant: "#344a52"
    property color cTertiary: "#999999"
    property color cOn_tertiary: "#000000"
    property color cTertiary_container: "#555555"
    property color cOn_tertiary_container: "#ffffff"
    property color cTertiary_fixed: "#e0e0ff"
    property color cTertiary_fixed_dim: "#c3c3eb"
    property color cOn_tertiary_fixed: "#171937"
    property color cOn_tertiary_fixed_variant: "#424465"
    property color cError: "#ff0000"
    property color cOn_error: "#ffffff"
    property color cError_container: "#550000"
    property color cOn_error_container: "#ffdddd"
    property color cBackground: "#111111"
    property color cOn_background: "#ffffff"
    property color cSurface: "#111111"
    property color cSurface_dim: "#131313"
    property color cSurface_bright: "#393939"
    property color cSurface_container_lowest: "#0e0e0e"
    property color cSurface_container_low: "#1b1b1b"
    property color cSurface_container: "#1f1f1f"
    property color cSurface_container_high: "#2a2a2a"
    property color cSurface_container_highest: "#353535"
    property color cOn_surface: "#ffffff"
    property color cSurface_variant: "#333333"
    property color cOn_surface_variant: "#bbbbbb"
    property color cSurface_tint: "#5cd5fb"
    property color cOutline: "#666666"
    property color cOutline_variant: "#474747"
    property color cShadow: "#000000"
    property color cScrim: "#000000"
    property color cInverse_surface: "#eeeeee"
    property color cInverse_on_surface: "#222222"
    property color cInverse_primary: "#66cc66"
    property color cSource_color: "#00ff00"
    
    FileView {
        id: jsonFile
        path: Quickshell.env("HOME") + "/.config/quickshell/default/config/colors.json"
        watchChanges: true 
        blockLoading: true
        onLoaded: updateColors()
        onFileChanged: updateColors()
        
        function updateColors() {
            try {
                var raw = jsonFile.text()
                if (!raw) return
   
                var data = JSON.parse(raw) 
                if (!data.colors) return
                
                for (var key in data.colors) {
                    var prefixedKey = 'c' + key.charAt(0).toUpperCase() + key.slice(1);
                    
                    if (colors.hasOwnProperty(prefixedKey)) {
                       colors[prefixedKey] = data.colors[key]
                    } else if (colors.hasOwnProperty(key)) { 
                        colors[key] = data.colors[key]
                    }
                }
            } catch (e) {
                console.error("Failed to update colors:", e)
            }
        }
    }
}