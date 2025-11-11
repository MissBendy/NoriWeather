// QML item displaying weather icon and temperature, adapting to horizontal or vertical plasmoid layouts
import QtQuick
import QtQuick.Layouts 1.1
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: iconAndTemp

    // Minimum layout sizes based on calculated width and height
    Layout.minimumWidth: widthReal
    Layout.minimumHeight: heightReal

    // Reference to dashboard popup window
    property QtObject dashWindow: null

    // Determine if plasmoid is vertical
    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // Conditional vertical alignment if weather text is inactive
    property string undefanchors: activeweathershottext ? undefined : parent.verticalCenter

    // Configuration options from plasmoid
    property bool textweather: Plasmoid.configuration.displayWeatherInPanel
    property bool boldconditions: Plasmoid.configuration.fontBoldWeather
    property int fonssizes: Plasmoid.configuration.sizeFontConfig

    // Dynamic measurements and flags
    property bool activeweathershottext: heightH > 34
    property int heightH: wrapper.height
    property var widthWidget: activeweathershottext ? temperatureRow.implicitWidth : temperatureRow.implicitWidth + wrapper_weathertext.width
    property var widthReal: isVertical ? wrapper.width : initial.implicitWidth
    property var hVerti: wrapper_vertical.implicitHeight
    property var heightReal: isVertical ? hVerti : wrapper.height

    // Mouse area to toggle popup dashboard
    MouseArea {
        id: compactMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            dashWindow.visible = !dashWindow.visible;
        }
    }

    // Horizontal layout for non-vertical plasmoid
    RowLayout {
        id: initial
        width: icon.width + weatherInfoColumn.width + icon.width * 0.3
        height: parent.height
        spacing: icon.width / 5
        visible: !isVertical

        // Weather icon
        Kirigami.Icon {
            id: icon
            width: root.height < 17 ? 16 : root.height < 24 ? 22 : 24
            height: width
            source: wrapper.currentIcon
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            roundToIconSize: false
        }

        // Column for temperature and optional weather text
        Column {
            id: weatherInfoColumn
            width: widthWidget
            height: temperatureRow.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            // Row showing temperature value and unit
            Row {
                id: temperatureRow
                width: tempValue.implicitWidth + tempUnit.implicitWidth
                height: tempValue.implicitHeight
                anchors.verticalCenter: undefanchors

                Label {
                    id: tempValue
                    height: parent.height
                    width: parent.width - tempUnit.implicitWidth
                    text: wrapper.currentTemp
                    font.weight: boldconditions ? Font.DemiBold : Font.Medium
                    color: PlasmaCore.Theme.textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
                Label {
                    id: tempUnit
                    height: parent.height
                    width: parent.width - tempValue.implicitWidth
                    text: (wrapper.unitsTemperature === "0") ? "°C" : "°F"
                    font.weight: boldconditions ? Font.DemiBold : Font.Medium
                    font.pixelSize: fonssizes
                    color: PlasmaCore.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }
            }

            // Optional short weather description below temperature
            Item {
                id: wrapper_weathertext
                height: shortweathertext.implicitHeight
                width: shortweathertext.implicitWidth
                visible: activeweathershottext && textweather

                Label {
                    id: shortweathertext
                    text: wrapper.weather
                    font.pixelSize: fonssizes
                    font.weight: boldconditions ? Font.DemiBold : Font.Medium
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // Vertical layout for vertical plasmoid
    ColumnLayout {
        id: wrapper_vertical
        width: root.width
        height: icon_vertical.height + tempValue_vertical.implicitHeight
        spacing: 2
        visible: isVertical

        // Vertical weather icon
        Kirigami.Icon {
            id: icon_vertical
            width: wrapper.width < 17 ? 16 : wrapper.width < 24 ? 22 : 24
            height: wrapper.width < 17 ? 16 : wrapper.width < 24 ? 22 : 24
            source: wrapper.currentIcon
            anchors.left: parent.left
            anchors.right: parent.right
            roundToIconSize: false
        }

        // Row showing temperature value and unit vertically
        Row {
            id: temperatureRow_vertical
            width: tempValue_vertical.implicitWidth + tempUnit_vertical.implicitWidth
            height: tempValue_vertical.implicitHeight
            Layout.alignment: Qt.AlignHCenter

            Label {
                id: tempValue_vertical
                height: parent.height
                text: wrapper.currentTemp
                font.weight: boldconditions ? Font.DemiBold : Font.Medium
                font.pixelSize: fonssizes
                color: PlasmaCore.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
            }
            Label {
                id: tempUnit_vertical
                height: parent.height
                text: (wrapper.unitsTemperature === "0") ? " °C" : " °F"
                font.weight: boldconditions ? Font.DemiBold : Font.Medium
                font.pixelSize: fonssizes
                color: PlasmaCore.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // Create popup dashboard representation on completion
    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("Representation {}", wrapper);
        plasmoid.activated.connect(function() {
            dashWindow.plasmoidWidV = widthReal
            dashWindow.plasmoidWidH = heightReal
            dashWindow.visible = !dashWindow.visible;
        });
    }
}
