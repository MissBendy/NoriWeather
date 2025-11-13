// QML item representing the left panel of a weather display
// Showing current location, temperature, and weather info
import QtQuick
import org.kde.kirigami as Kirigami
import QtQuick.Controls as Controls

Item {
    // Margins and spacing for layout adjustments
    property int leftPanelMargin: 0
    property int topPanelMargin: 0
    property int exedentHight: 0
    property int spacingElements: 5

    // Dynamic width of left panel based on weather icon and temperature text
    // Dynamic width of left panel
    property int minLeftPanelWidth: 120
    property int widthOfLeftPanel: {
        const baseWidth = logo.width + text.implicitWidth + 20
        const availableWidth = baseWidth - 15
        const calculatedWidth = textDo.implicitWidth > availableWidth ? baseWidth + 12 : baseWidth
        return Math.max(calculatedWidth, minLeftPanelWidth)
    }

    // Left panel background container
    LeftPanel {
        id: leftPanel
        anchors.left: parent.left
        anchors.leftMargin: -leftPanelMargin
        anchors.top: parent.top
        anchors.topMargin: -topPanelMargin
        width: parent.widthOfLeftPanel
        height: parent.height + exedentHight
    }

    // Main content container inside left panel
    Item {
        width: leftPanel.width
        anchors.top: parent.top

        // City name heading
        Kirigami.Heading {
            id: city
            width: parent.width - leftPanel.marginLeftReal
            text: wrapper.location
            color: Kirigami.Theme.textColor
            level: 1
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        // Row showing current weather icon and temperature
        Row {
            id: current
            width: parent.width - leftPanel.marginLeftReal
            anchors.top: city.bottom
            anchors.topMargin: spacingElements
            height: text.implicitHeight
            spacing: 5

            // Current weather icon
            Kirigami.Icon {
                id: logo
                source: wrapper.currentIcon
                width: Kirigami.Units.iconSizes.large
                height: width
                anchors.verticalCenter: parent.verticalCenter
            }

            // Current temperature label
            Controls.Label {
                id: text
                width: implicitWidth
                text: wrapper.currentTemp + "°"
                color: Kirigami.Theme.textColor
                font.weight: Font.Normal
                font.pixelSize: 38
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Column displaying current weather description and max/min temperature
        Column {
            anchors.top: current.bottom
            width: current.width
            height: textDo.implicitHeight * 2
            anchors.topMargin: spacingElements
            opacity: 0.85

            // Weather description
            Kirigami.Heading {
                id: textDo
                width: parent.width - leftPanel.marginLeftReal
                text: wrapper.longWeather
                color: Kirigami.Theme.textColor
                level: 5
                font.weight: Font.Medium
                wrapMode: Text.WordWrap
            }

            // Max/Min temperature
            Kirigami.Heading {
                width: parent.width - leftPanel.marginLeftReal
                text: wrapper.currentMaxMin
                color: Kirigami.Theme.textColor
                level: 5
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
        }
    }

    // Footer link to open-meteo.com
    Item {
        width: link.implicitWidth
        height: link.implicitHeight
        anchors.bottom: parent.bottom

        Kirigami.Heading {
            id: link
            width: parent.width
            text: "open-meteo.com"
            color: Kirigami.Theme.textColor
            level: 5
            font.underline: true
            opacity: 0.4
            elide: Text.ElideRight
        }

        // Make the link clickable
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.openUrlExternally("https://open-meteo.com")
        }
    }
}
