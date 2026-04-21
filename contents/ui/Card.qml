// Left panel background using a rounded Rectangle to match the popup chrome
import QtQuick
import org.kde.ksvg as KSvg
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

Item {
    property int marginLeft: 0
    property color leftColor: "cyan"

    // Derive corner radius from the actual dialogs/background SVG so it always
    // matches the popup chrome — falls back to 6px if margins are unavailable.
    readonly property int cornerRadius: {
        var m = backgroundSvg.margins
        if (m && m.left > 0) return m.left
        return 6
    }

    // Which panel edge are we sitting on?
    readonly property bool onBottomEdge: plasmoid.location === PlasmaCore.Types.BottomEdge
    readonly property bool onTopEdge:    plasmoid.location === PlasmaCore.Types.TopEdge

    // Hidden SVG used only to read the theme's corner radius
    KSvg.FrameSvgItem {
        id: backgroundSvg
        visible: false
        imagePath: "dialogs/background"
    }

    clip: true

    Rectangle {
        anchors.fill: parent
        color: leftColor
        radius: cornerRadius

        // Always square off the right-side corners (left panel never has right-side rounding)
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: cornerRadius
            color: parent.color
        }

        // On a bottom panel: square off the bottom-left corner so it sits flush
        // against the panel edge. The top-left corner stays rounded.
        Rectangle {
            visible: onBottomEdge
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: cornerRadius
            color: parent.color
        }

        // On a top panel: square off the top-left corner so it sits flush
        // against the panel edge. The bottom-left corner stays rounded.
        Rectangle {
            visible: onTopEdge
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: cornerRadius
            color: parent.color
        }
    }

    // Vertical divider line on the right edge
    KSvg.SvgItem {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        imagePath: "widgets/line"
        elementId: "vertical-line"
        width: 1
    }
}
