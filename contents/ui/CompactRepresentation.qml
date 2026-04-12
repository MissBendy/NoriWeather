import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3

Item {
    id: iconAndTemp
    anchors.fill: parent
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    Layout.minimumWidth: widthReal
    Layout.minimumHeight: heightReal

    property QtObject dashWindow: null

    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    property var undefanchors: activeweatherShortText ? undefined : null

    property bool textweather: Plasmoid.configuration.displayWeatherInPanel

    property int fonssizes: Plasmoid.configuration.sizeFontConfig
    property string fontfamily: Plasmoid.configuration.fontFamily
    property var fontWeightValue: Plasmoid.configuration.fontWeight

    property bool activeweatherShortText: !isVertical

    property int heightH: wrapper.height
    property var widthWidget: temperatureRow.implicitWidth +
    (textweather ? wrapper_weathertext.implicitWidth : 0)

    property var widthReal: isVertical ? wrapper.width : initial.implicitWidth
    property var hVerti: wrapper_vertical.implicitHeight
    property var heightReal: isVertical ? hVerti : wrapper.height

    property int fontWeightResolved: fontWeightValue > 0
    ? fontWeightValue
    : Qt.application.font.weight

    MouseArea {
        id: compactMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: dashWindow.visible = !dashWindow.visible
    }

    RowLayout {
        id: initial
        spacing: icon.implicitWidth / 5
        anchors.centerIn: parent
        visible: !isVertical

        Kirigami.Icon {
            id: icon
            width: Kirigami.Units.iconSizes.medium
            height: width
            source: wrapper.currentIcon
            roundToIconSize: false
            Layout.alignment: Qt.AlignVCenter
        }

        Column {
            id: weatherInfoColumn
            width: widthWidget
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
                    font.pointSize: fonssizes
                    font.weight: fontWeightResolved
                    font.family: fontfamily !== "" ? fontfamily : font.family
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                Label {
                    id: tempUnit
                    height: parent.height
                    width: parent.width - tempValue.implicitWidth
                    text: (wrapper.unitsTemperature === "0") ? "°C" : "°F"
                    font.pointSize: fonssizes
                    font.weight: fontWeightResolved
                    font.family: fontfamily !== "" ? fontfamily : font.family
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
                    font.pointSize: fonssizes
                    font.weight: fontWeightResolved
                    font.family: fontfamily !== "" ? fontfamily : font.family
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    ColumnLayout {
        id: wrapper_vertical
        width: iconAndTemp.width
        anchors.centerIn: parent
        spacing: 2
        visible: isVertical

        Kirigami.Icon {
            id: icon_vertical
            width: Kirigami.Units.iconSizes.medium
            height: width
            source: wrapper.currentIcon
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
                font.pointSize: fonssizes
                font.weight: fontWeightResolved
                font.family: fontfamily !== "" ? fontfamily : font.family
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                id: tempUnit_vertical
                height: parent.height
                text: (wrapper.unitsTemperature === "0") ? " °C" : " °F"
                font.pointSize: fonssizes
                font.weight: fontWeightResolved
                font.family: fontfamily !== "" ? fontfamily : font.family
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
