import QtQuick
import QtQuick.Layouts 1.1
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: iconAndTemp
    anchors.fill: parent
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    // Set minimum dimensions for the layout
    Layout.minimumWidth: widthReal
    Layout.minimumHeight: heightReal
    // Reference to the dashboard window for toggling
    property QtObject dashWindow: null
    // Determine if the plasmoid is vertical
    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    // Conditional anchor toggle depending on active weather text visibility
    property var undefanchors: activeweatherShortText ? undefined : null
    // User configuration properties
    property bool textweather: Plasmoid.configuration.displayWeatherInPanel
    property bool boldconditions: Plasmoid.configuration.fontBoldWeather
    property int fonssizes: Plasmoid.configuration.sizeFontConfig
    // Determine if short weather text should be active
    property bool activeweatherShortText: !isVertical
    // Heights and widths for layout calculations
    property int heightH: wrapper.height
    property var widthWidget: temperatureRow.implicitWidth +
    (textweather ? wrapper_weathertext.implicitWidth : 0)
    property var widthReal: isVertical ? wrapper.width : initial.implicitWidth
    property var hVerti: wrapper_vertical.implicitHeight
    property var heightReal: isVertical ? hVerti : wrapper.height
    // Computed dimensions for horizontal and vertical layouts
    property int computedWidth: icon.implicitWidth + weatherInfoColumn.implicitWidth + icon.implicitWidth * 0.3
    property int computedHeight: icon_vertical.implicitHeight + tempValue_vertical.implicitHeight

    // Mouse interaction to toggle dashboard window
    MouseArea {
        id: compactMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: dashWindow.visible = !dashWindow.visible
    }

    // Horizontal layout
    RowLayout {
        id: initial
        width: computedWidth
        spacing: icon.implicitWidth / 5
        anchors.centerIn: parent
        visible: !isVertical

        // Weather icon
        Kirigami.Icon {
            id: icon
            width: Kirigami.Units.iconSizes.medium
            height: width
            source: wrapper.currentIcon
            roundToIconSize: false
            Layout.alignment: Qt.AlignVCenter
        }

        // Column holding temperature and optional weather text
        Column {
            id: weatherInfoColumn
            width: widthWidget
            Layout.alignment: Qt.AlignVCenter

            Row {
                id: temperatureRow
                width: tempValue.implicitWidth + tempUnit.implicitWidth
                height: tempValue.implicitHeight
                Layout.alignment: Qt.AlignVCenter

                // Temperature value
                Label {
                    id: tempValue
                    height: parent.height
                    width: parent.width - tempUnit.implicitWidth
                    text: wrapper.currentTemp
                    font.weight: Font.Medium
                    color: PlasmaCore.Theme.textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                // Temperature unit
                Label {
                    id: tempUnit
                    height: parent.height
                    width: parent.width - tempValue.implicitWidth
                    text: (wrapper.unitsTemperature === "0") ? "°C" : "°F"
                    font.weight: Font.Medium
                    font.pixelSize: fonssizes
                    color: PlasmaCore.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }
            }

            // Optional short weather description
            Item {
                id: wrapper_weathertext
                height: shortweathertext.implicitHeight
                width: shortweathertext.implicitWidth
                visible: activeweatherShortText && textweather

                Label {
                    id: shortweathertext
                    text: wrapper.shortWeather
                    font.pixelSize: fonssizes
                    font.weight: boldconditions ? Font.Medium : Font.Normal
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // Vertical layout
    ColumnLayout {
        id: wrapper_vertical
        width: iconAndTemp.width
        anchors.centerIn: parent
        spacing: 2
        visible: isVertical

        // Weather icon
        Kirigami.Icon {
            id: icon_vertical
            width: Kirigami.Units.iconSizes.medium
            height: width
            source: wrapper.currentIcon
            roundToIconSize: false
            Layout.alignment: Qt.AlignHCenter
        }

        Row {
            id: temperatureRow_vertical
            width: tempValue_vertical.implicitWidth + tempUnit_vertical.implicitWidth
            height: tempValue_vertical.implicitHeight
            Layout.alignment: Qt.AlignHCenter

            // Temperature value
            Label {
                id: tempValue_vertical
                height: parent.height
                text: wrapper.currentTemp
                font.weight: boldconditions ? Font.DemiBold : Font.Medium
                font.pixelSize: fonssizes
                color: PlasmaCore.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
            }

            // Temperature unit
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

    // Initialize dashboard window and connect activation signal
    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("Representation {}", wrapper)
        plasmoid.activated.connect(function() {
            dashWindow.plasmoidWidV = widthReal
            dashWindow.plasmoidWidH = heightReal
            dashWindow.visible = !dashWindow.visible
        })
    }
}
