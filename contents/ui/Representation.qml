/*
 *  SPDX-FileCopyrightText: zayronxio
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
//import QtQuick.Controls 2.15
//import QtQuick.Effects

Item {
    id: main

    // Properties to hold plasmoid dimensions
    property int plasmoidWidV: 0
    property int plasmoidWidH: 0

    // Toggle visibility of the popup when main item's visibility changes
    onVisibleChanged: {
        root.visible = !root.visible
    }

    // Background SVG for the popup, initially hidden
    KSvg.FrameSvgItem {
        id: backgroundSvg
        visible: false
        imagePath: "dialogs/background"
    }

    // Update plasmoid status based on popup visibility
    Plasmoid.status: root.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    // The floating dialog that acts as the popup
    PlasmaCore.Dialog {
        id: root
        objectName: "popupWindow"
        flags: Qt.WindowStaysOnTopHint
        location: PlasmaCore.Types.Floating
        hideOnWindowDeactivate: true

        // Update position when size changes
        onHeightChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }
        onWidthChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        // Toggle popup visibility
        function toggle() {
            main.visible = !main.visible;
        }

        // Position the popup based on screen and panel location
        onVisibleChanged: {
            if (visible) {
                var pos = popupPosition(width, height);
                x = pos.x;
                y = pos.y;
            }
        }

        // Calculate popup position based on plasmoid edge and screen bounds
        function popupPosition(width, height) {
            var screen = Qt.application.primaryScreen ? Qt.application.primaryScreen.virtualGeometry : wrapper.screenGeometry;
            var panelH = wrapper.height;
            var panelW = wrapper.width;
            var appletTopLeft = parent.mapToGlobal(0, 0);

            // Helper to create a point
            function calculatePosition(x, y) {
                return Qt.point(x, y);
            }

            // Clamp value to min/max
            function clamp(value, min, max) {
                return Math.min(Math.max(value, min), max);
            }

            var sidePadding = Kirigami.Units.gridUnit * 0.3; // adjust this for more/less padding

            // fallback values
            var x = 0;
            var y = 0;

            // Determine position based on plasmoid edge
            switch (plasmoid.location) {
                case PlasmaCore.Types.BottomEdge:
                    if (appletTopLeft.x < (screen.width - width / 2 + (backgroundSvg.margins ? backgroundSvg.margins.left : 0) + Kirigami.Units.gridUnit)) {
                        if (appletTopLeft.x < ((width / 2) + (backgroundSvg.margins ? backgroundSvg.margins.left : 0))) {
                            x = Kirigami.Units.gridUnit - ((backgroundSvg.margins ? backgroundSvg.margins.left : 0));
                        } else {
                            x = appletTopLeft.x - width / 2;
                        }
                    } else {
                        x = screen.width - (width - ((backgroundSvg.margins ? backgroundSvg.margins.left : 0) * 2)) - Kirigami.Units.gridUnit;
                    }
                    y = appletTopLeft.y - height - 0.5 * Kirigami.Units.gridUnit;
                    break;

                case PlasmaCore.Types.TopEdge:
                    var leftMargin = backgroundSvg.margins ? backgroundSvg.margins.left : 0;
                    if (appletTopLeft.x < width / 2 + leftMargin + Kirigami.Units.gridUnit) {
                        x = leftMargin;
                    } else if (appletTopLeft.x > screen.width - (width / 2) - leftMargin - Kirigami.Units.gridUnit) {
                        x = screen.width - width - leftMargin;
                    } else {
                        x = appletTopLeft.x - width / 2 - leftMargin;
                    }
                    y = appletTopLeft.y + panelH + Kirigami.Units.gridUnit;
                    break;

                case PlasmaCore.Types.LeftEdge:
                    x = appletTopLeft.x + panelW + Kirigami.Units.gridUnit / 2;
                    y = (appletTopLeft.y + height > screen.height)
                    ? screen.height - height
                    : appletTopLeft.y;
                    break;

                case PlasmaCore.Types.RightEdge:
                    x = appletTopLeft.x - width - Kirigami.Units.gridUnit / 2;
                    y = (appletTopLeft.y + height > screen.height)
                    ? screen.height - height - Kirigami.Units.gridUnit / 5
                    : appletTopLeft.y;
                    break;

                default:
                    x = 0;
                    y = 0;
            }

            // Clamp to screen bounds with side padding
            x = clamp(x, screen.x + sidePadding, screen.x + screen.width - width - sidePadding);
            y = clamp(y, screen.y, screen.y + screen.height - height);

            return calculatePosition(x, y);
        }

        FocusScope {
            id: rootItem
            // Set minimum and maximum dimensions for the popup
            Layout.minimumWidth:  Kirigami.Units.gridUnit * 20
            Layout.maximumWidth:  Kirigami.Units.gridUnit * 20
            Layout.minimumHeight: Kirigami.Units.gridUnit * 10.25
            Layout.maximumHeight: Kirigami.Units.gridUnit * 10.25
            focus: true

            FullContainer {
                id: fullContainer
                // Set margins and height adjustments
                leftPanelMargin: backgroundSvg.margins.left
                topPanelMargin: backgroundSvg.margins.top
                exedentHight: backgroundSvg.margins.top + backgroundSvg.margins.bottom
                width: widthOfLeftPanel
                height: parent.height
            }
            // Forecast item panel next to the full container
            ItemForecasts {
                width: parent.width - fullContainer.width
                height: parent.height
                anchors.left: fullContainer.right
            }
        }
    }
}
