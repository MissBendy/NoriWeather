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

    Layout.minimumWidth: widthReal
    Layout.minimumHeight: heightReal

    property QtObject dashWindow: null
    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // Conditional alignment toggle
    property var undefanchors: activeweatherShortText ? undefined : null

    property bool textweather: Plasmoid.configuration.displayWeatherInPanel
    property bool boldconditions: Plasmoid.configuration.fontBoldWeather
    property int fonssizes: Plasmoid.configuration.sizeFontConfig

    property bool activeweatherShortText: heightH > 34
    property int heightH: wrapper.height
    property var widthWidget: activeweatherShortText ? temperatureRow.implicitWidth : temperatureRow.implicitWidth + wrapper_weathertext.width
    property var widthReal: isVertical ? wrapper.width : initial.implicitWidth
    property var hVerti: wrapper_vertical.implicitHeight
    property var heightReal: isVertical ? hVerti : wrapper.height
    property int computedWidth: icon.implicitWidth + weatherInfoColumn.implicitWidth + icon.implicitWidth * 0.3
    property int computedHeight: icon_vertical.implicitHeight + tempValue_vertical.implicitHeight

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
        height: parent.height
        spacing: icon.implicitWidth / 5
        visible: !isVertical

        Kirigami.Icon {
            id: icon
            width: iconAndTemp.height < 17 ? 16 : iconAndTemp.height < 24 ? 22 : 24
            height: width
            source: wrapper.currentIcon
            roundToIconSize: false
            Layout.alignment: Qt.AlignVCenter
        }

        Column {
            id: weatherInfoColumn
            width: widthWidget
            height: temperatureRow.implicitHeight
            Layout.alignment: Qt.AlignVCenter

            Row {
                id: temperatureRow
                width: tempValue.implicitWidth + tempUnit.implicitWidth
                height: tempValue.implicitHeight
                Layout.alignment: Qt.AlignVCenter

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

            Item {
                id: wrapper_weathertext
                height: shortweathertext.implicitHeight
                width: shortweathertext.implicitWidth
                visible: activeweatherShortText && textweather

                Label {
                    id: shortweathertext
                    text: wrapper.shortWeather
                    font.pixelSize: fonssizes
                    font.weight: boldconditions ? Font.DemiBold : Font.Medium
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // Vertical layout
    ColumnLayout {
        id: wrapper_vertical
        width: iconAndTemp.width
        height: computedHeight
        spacing: 2
        visible: isVertical
        Kirigami.Icon {
            id: icon_vertical
            width: wrapper.width < 17 ? 16 : wrapper.width < 24 ? 22 : 24
            height: wrapper.width < 17 ? 16 : wrapper.width < 24 ? 22 : 24
            source: wrapper.currentIcon
            roundToIconSize: false
            Layout.alignment: Qt.AlignHCenter
        }

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

    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("Representation {}", wrapper)
        plasmoid.activated.connect(function() {
            dashWindow.plasmoidWidV = widthReal
            dashWindow.plasmoidWidH = heightReal
            dashWindow.visible = !dashWindow.visible
        })
    }
}
