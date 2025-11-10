import QtQuick
import QtQuick.Layouts 1.1
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
//import org.kde.plasma.plasma5support as Plasma5Support


Item {
    id: iconAndTemp

    Layout.minimumWidth: widthReal
    Layout.minimumHeight: heightReal

    property QtObject dashWindow: null

    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    property string undefanchors: activeweathershottext ? undefined : parent.verticalCenter
    property bool textweather: Plasmoid.configuration.displayWeatherInPanel
    property bool boldconditions: Plasmoid.configuration.fontBoldWeather
    property bool activeweathershottext: heightH > 34
    property int fonssizes: Plasmoid.configuration.sizeFontConfig
    property int heightH: wrapper.height
    property var widthWidget: activeweathershottext ? temperatureRow.implicitWidth : temperatureRow.implicitWidth + wrapper_weathertext.width
    property var widthReal: isVertical ? wrapper.width : initial.implicitWidth
    property var hVerti: wrapper_vertical.implicitHeight
    property var heightReal: isVertical ? hVerti : wrapper.height


    MouseArea {
        id: compactMouseArea
        anchors.fill: parent

        hoverEnabled: true

        onClicked: {

            dashWindow.visible = !dashWindow.visible;

        }
    }
    RowLayout {
        id: initial
        width: icon.width + weatherInfoColumn.width + icon.width * 0.3
        height: parent.height
        spacing: icon.width / 5
        visible: !isVertical
        Kirigami.Icon {
            id: icon
            width: root.height < 17 ? 16 : root.height < 24 ? 22 : 24
            height: width
            source: wrapper.currentIcon
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            roundToIconSize: false
        }
        Column {
            id: weatherInfoColumn
            width: widthWidget
            height: temperatureRow.implicitHeight
            anchors.verticalCenter: parent.verticalCenter
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
                    horizontalAlignment: Text.AlignLeft
                    font.weight: boldconditions ? Font.DemiBold : Font.Medium
                    font.pixelSize: fonssizes
                    color: PlasmaCore.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Item {
                id: wrapper_weathertext
                height: shortweathertext.implicitHeight
                width: shortweathertext.implicitWidth
                visible: activeweathershottext & textweather
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
    ColumnLayout {
        id: wrapper_vertical
        width: root.width
        height: icon_vertical.height +  tempValue_vertical.implicitHeight
        spacing: 2
        visible: isVertical
        Kirigami.Icon {
            id: icon_vertical
            width: wrapper.width < 17 ? 16 : wrapper.width < 24 ? 22 : 24
            height: wrapper.width < 17 ? 16 : wrapper.width < 24 ? 22 : 24
            source: wrapper.currentIcon
            anchors.left: parent.left
            anchors.right: parent.right
            roundToIconSize: false
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
        dashWindow = Qt.createQmlObject("Representation {}", wrapper);
        plasmoid.activated.connect(function() {
            dashWindow.plasmoidWidV = widthReal
            dashWindow.plasmoidWidH = heightReal
            dashWindow.visible = !dashWindow.visible;
        });

    }

}
