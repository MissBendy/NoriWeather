import QtQuick
import org.kde.kirigami as Kirigami
import QtQuick.Controls as Controls

Item {
    property int leftPanelMargin: 0
    property int topPanelMargin: 0
    property int exedentHight: 0
    property int spacingElements: 5

    // dynamic width based on temperature text + icon + padding
    property int widthOfLeftPanel: logo.width + text.implicitWidth + 20

    LeftPanel {
        id: leftPanel
        anchors.left: parent.left
        anchors.leftMargin: -leftPanelMargin
        anchors.top: parent.top
        anchors.topMargin: -topPanelMargin
        width: parent.widthOfLeftPanel
        height: parent.height + exedentHight
    }

    Item {
        width: leftPanel.width
        anchors.top: parent.top

        Kirigami.Heading {
            id: city
            width: parent.width - leftPanel.marginLeftReal
            text: wrapper.location
            color: Kirigami.Theme.highlightedTextColor
            level: 1
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        Row {
            id: current
            width: parent.width - leftPanel.marginLeftReal
            anchors.top: city.bottom
            anchors.topMargin: spacingElements
            height: text.implicitHeight
            spacing: 5

            Kirigami.Icon {
                id: logo
                source: wrapper.currentIcon
                width: Kirigami.Units.iconSizes.large
                height: width
                color: Kirigami.Theme.highlightedTextColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Controls.Label {
                id: text
                width: implicitWidth  // use implicitWidth for dynamic sizing
                text: wrapper.currentTemp + "°"
                color: Kirigami.Theme.highlightedTextColor
                font.weight: Font.Normal
                font.pixelSize: 38
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Column {
            anchors.top: current.bottom
            width: current.width
            height: textDo.implicitHeight * 2
            anchors.topMargin: spacingElements
            opacity: 0.85

            Kirigami.Heading {
                id: textDo
                width: parent.width - leftPanel.marginLeftReal
                text: wrapper.weather
                color: Kirigami.Theme.highlightedTextColor
                level: 5
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Kirigami.Heading {
                width: parent.width - leftPanel.marginLeftReal
                text: wrapper.currentMaxMin.replace("/", " / ")
                color: Kirigami.Theme.highlightedTextColor
                level: 5
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
        }
    }

    Item {
        width: link.implicitWidth
        height: link.implicitHeight
        anchors.bottom: parent.bottom

        Kirigami.Heading {
            id: link
            width: parent.width
            text: "open-meteo.com"
            color: Kirigami.Theme.highlightedTextColor
            level: 5
            font.underline: true
            opacity: 0.4
            elide: Text.ElideRight
        }

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.openUrlExternally("https://open-meteo.com")
        }
    }
}
