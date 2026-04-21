/*
 *  SPDX-FileCopyrightText: zayronxio
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmaExtras.Representation {
    id: fullRep

    Layout.preferredWidth:  370
    Layout.preferredHeight: 190
    Layout.minimumWidth:    370
    Layout.minimumHeight:   190
    Layout.maximumWidth:    370
    Layout.maximumHeight:   190

    collapseMarginsHint: true

    FocusScope {
        anchors.fill: parent
        focus: true

        FullContainer {
            id: fullContainer
            width:  widthOfLeftPanel
            height: parent.height
        }

        ItemForecasts {
            width:  parent.width - fullContainer.width
            height: parent.height
            anchors.left: fullContainer.right
        }
    }
}
