// QML item creating a composite SVG mask with color fill and optional graphical effects
import QtQuick
import org.kde.ksvg 1.0 as KSvg
import Qt5Compat.GraphicalEffects

Item {
    // Left margin based on top-left SVG width
    property int marginLeft: maskSvg2.marg
    // Base color used for masked rectangles
    property color leftColor: "cyan"

    // Grid to arrange the SVG components of the background
    Grid {
        id: maskSvg2
        width: parent.width
        height: parent.height
        columns: 2
        property var marg: topleft2.implicitWidth

        // Top-left corner of the background
        KSvg.SvgItem {
            id: topleft2
            imagePath: "dialogs/background"
            elementId: "topleft"
        }

        // Top edge spanning the remaining width
        KSvg.SvgItem {
            id: top2
            imagePath: "dialogs/background"
            elementId: "top"
            width: parent.width - topleft2.implicitWidth
        }

        // Left edge spanning the remaining height
        KSvg.SvgItem {
            id: left2
            imagePath: "dialogs/background"
            elementId: "left"
            height: parent.height - topleft2.implicitHeight * 2
        }

        // Center area between edges
        KSvg.SvgItem {
            imagePath: "dialogs/background"
            elementId: "center"
            height: parent.height - topleft2.implicitHeight * 2
            width: top2.width
        }

        // Bottom-left corner
        KSvg.SvgItem {
            id: bottomleft2
            imagePath: "dialogs/background"
            elementId: "bottomleft"
        }

        // Bottom edge spanning remaining width
        KSvg.SvgItem {
            id: bottom2
            imagePath: "dialogs/background"
            elementId: "bottom"
            width: parent.width - bottomleft2.implicitWidth
        }
    }

    // Rectangle filled with leftColor, masked by the composed SVG grid
    Rectangle {
        color: leftColor
        width: maskSvg2.width
        height: maskSvg2.height
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: maskSvg2
        }
    }

    // Duplicate rectangle with the same mask (can be used for layered effects)
    Rectangle {
        color: leftColor
        width: maskSvg2.width
        height: maskSvg2.height
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: maskSvg2
        }
    }

    // Vertical line SVG aligned to the right of the grid
    KSvg.SvgItem {
        anchors.right: maskSvg2.right
        imagePath: "widgets/line"
        elementId: "vertical-line"
        height: parent.height
    }
}
