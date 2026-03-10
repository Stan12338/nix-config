pragma Singleton
import QtQuick
import Quickshell
import qs.functions
import Quickshell.Io

Singleton {
    id: root

    property bool barBgEnabled: true

    readonly property QtObject mColors: QtObject {
        readonly property color mBackground: Colors.cBackground
        readonly property color mSurface: Colors.cSurface
        readonly property color mSurfaceDim: Colors.cSurface_dim
        readonly property color mSurfaceBright: Colors.cSurface_bright
        readonly property color mSurfaceContainerLowest: Colors.cSurface_container_lowest
        readonly property color mSurfaceContainerLow: Colors.cSurface_container_low
 
        readonly property color mSurfaceContainer: Colors.cSurface_container
        readonly property color mSurfaceContainerHigh: Colors.cSurface_container_high
        readonly property color mSurfaceContainerHighest: Colors.cSurface_container_highest
        readonly property color mSurfaceVariant: Colors.cSurface_variant
        readonly property color mOnSurface: Colors.cOn_surface
        readonly property color mOnSurfaceVariant: Colors.cOn_surface_variant
        readonly property color mInverseSurface: Colors.cInverse_surface
        readonly property color mInverseOnSurface: Colors.cInverse_on_surface
     
        readonly property color mOutline: Colors.cOutline
        readonly property color mOutlineVariant: Colors.cOutline_variant
        readonly property color mShadow: Colors.cShadow

        readonly property color mPrimary: Colors.cPrimary
        readonly property color mOnPrimary: Colors.cOn_primary
        readonly property color mPrimaryContainer: Colors.cPrimary_container
        readonly property color mOnPrimaryContainer: Colors.cOn_primary_container

        readonly property color mSecondary: Colors.cSecondary
        readonly property color mSecondaryContainer: Colors.cSecondary_container
        readonly property color mOnSecondaryContainer: Colors.cOn_secondary_container

        readonly property color mTertiary: Colors.cTertiary
        readonly property color mTertiaryContainer: Colors.cTertiary_container
        readonly property color mOnTertiaryContainer: Colors.cOn_tertiary_container

        readonly property color mInversePrimary: Colors.cInverse_primary
    }


    readonly property QtObject colors: QtObject {
        property color colSubtext: mColors.mOutline

        property color colLayer0: mColors.mBackground
  
        property color colLayer0Border: ColorModifier.mix(mColors.mOutlineVariant, colLayer0, 0.4)

        property color colLayer1: mColors.mSurfaceContainerLow
        property color colOnLayer1: mColors.mOnSurfaceVariant
        property color colOnLayer1Inactive: ColorModifier.mix(colOnLayer1, colLayer1, 0.45)
        property color colLayer1Hover: ColorModifier.mix(colLayer1, colOnLayer1, 0.92)
        property color colLayer1Active: ColorModifier.mix(colLayer1, colOnLayer1, 0.85)

        property color colLayer2: mColors.mSurfaceContainer
        property color colOnLayer2: mColors.mOnSurface
      
        property color colLayer2Hover: ColorModifier.mix(colLayer2, colOnLayer2, 0.90)
        property color colLayer2Active: ColorModifier.mix(colLayer2, colOnLayer2, 0.80)

        property color colLayer3: mColors.mSurfaceContainerHigh
        property color colLayer4: mColors.mSurfaceContainerHighest
        property color colLayer5: mColors.mSurfaceBright

        property color colPrimary: mColors.mPrimary
        property color colOnPrimary: mColors.mOnPrimary

        property color colSecondary: mColors.mSecondary
        property color colSecondaryContainer: mColors.mSecondaryContainer
   
        property color colOnSecondaryContainer: mColors.mOnSecondaryContainer

        property color colTertiary: mColors.mTertiary
        property color colTertiaryContainer: mColors.mTertiaryContainer
        property color colOnTertiaryContainer: mColors.mOnTertiaryContainer

        property color colTooltip: mColors.mInverseSurface
        property color colOnTooltip: mColors.mInverseOnSurface

        property color colShadow: ColorModifier.transparentize(mColors.mShadow, 0.7)
        property color colOutline: mColors.mOutline
    }

    property bool isDark: {
        const bg = Colors.cBackground
        const fg = Colors.cOn_background
        
        const bgLum = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b
        const fgLum = 0.299 * fg.r + 0.587 * fg.g + 0.114 * fg.b
        
        const isDifferent = Math.abs(bgLum - fgLum) > 0.1
        
        return isDifferent && bgLum < fgLum
    }

    Process {
        id: getWallpaperProcess
        property string pendingMode: ""
        property string wallpaperPath: ""
        
        stdout: SplitParser {
            id: wallpaperParser
            
            
            onRead: data => {
                console.log("Wallpaper query output:", data)
                getWallpaperProcess.wallpaperPath = data
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            console.log("Wallpaper query exited:", exitCode, exitStatus)
    
            const wallpaper = wallpaperPath.trim()
            console.log("Wallpaper path:", wallpaper)
            
            if (wallpaper && pendingMode) {
                console.log("Running matugen with mode:", pendingMode)
                matugenProcess.command = ["matugen", "image", wallpaper, "-m", pendingMode]
     
                matugenProcess.running = true
            }
        }
    }

    Process {
        id: matugenProcess
        
        onStarted: () => {
            console.log("Matugen process started")
        }
        
 
        onExited: (exitCode, exitStatus) => {
            console.log("Matugen exited:", exitCode, exitStatus)
        }
    }

    function setTheme(mode) {
        console.log("setTheme called with mode:", mode)
        getWallpaperProcess.pendingMode = mode
        getWallpaperProcess.command = ["sh", "-c", "swww query | head -n 1 | grep -oP 'image: \\K.*'"]
        getWallpaperProcess.running = true
    }

}