// QML item displaying hourly and daily weather forecasts using Kirigami components
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    // Stores the maximum width needed for forecast text labels
    property int widthTxt: 0
    property string fontfamily: Plasmoid.configuration.fontFamily

    // Top half: hourly forecast
    Row {
        id: hourlyForecast
        width: parent.width
        height: parent.height / 2

        // Repeat for each hourly forecast entry
        Repeater {
            model: forecastHours
            delegate: Item {
                width: parent.width / 5
                height: parent.height

                Column {
                    width: parent.width
                    height: parent.height
                    spacing: Kirigami.Units.iconSizes.small / 3
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Hour label (12h or 24h format)
                    Kirigami.Heading {
                        text: {
                            if (wrapper.timeFormat === 24) {
                                return model.hours;
                            } else {
                                var hour12 = model.hours % 12;
                                if (hour12 === 0) hour12 = 12;
                                var suffix = (model.hours >= 12) ? "pm" : "am";
                                return hour12 + suffix;
                            }
                        }
                        color: Kirigami.Theme.textColor
                        level: 5
                        font.family: fontfamily !== "" ? fontfamily : font.family
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                    }

                    // Weather icon for the hour
                    Kirigami.Icon {
                        source: model.icon
                        width: Kirigami.Units.iconSizes.medium
                        height: width
                        roundToIconSize: false
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Temperature label for the hour
                    Kirigami.Heading {
                        text: " " + model.temp + "°"
                        color: Kirigami.Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        level: 5
                        font.family: fontfamily !== "" ? fontfamily : font.family
                    }
                }
            }
        }
    }

    // Bottom half: daily forecast
    Column {
        width: parent.width
        anchors.top: hourlyForecast.bottom
        anchors.topMargin: -9
        spacing: 2

        // Repeat for each daily forecast entry
        Repeater {
            model: forecastFullModel
            delegate: Item {
                width: parent.width
                height: Kirigami.Units.iconSizes.medium

                // Day label - left column
                Kirigami.Heading {
                    id: day
                    text: model.date
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * 0.4
                    color: Kirigami.Theme.textColor
                    level: 5
                    font.family: fontfamily !== "" ? fontfamily : font.family
                }

                // Icon - middle column, explicitly centered
                Kirigami.Icon {
                    source: model.icon
                    width: Kirigami.Units.iconSizes.medium
                    height: width
                    roundToIconSize: false
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Temperature - right column
                RowLayout {
                    id: tempRow
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width * 0.04
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Kirigami.Heading {
                        id: maxTempLabel
                        text: model.maxTemp + "°"
                        level: 5
                        horizontalAlignment: Text.AlignRight
                        font.family: fontfamily !== "" ? fontfamily : font.family
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 1
                    }

                    Kirigami.Heading {
                        text: "/"
                        level: 5
                        horizontalAlignment: Text.AlignCenter
                        font.family: fontfamily !== "" ? fontfamily : font.family
                        Layout.preferredWidth: implicitWidth
                    }

                    Kirigami.Heading {
                        id: minTempLabel
                        text: model.minTemp + "°"
                        level: 5
                        horizontalAlignment: Text.AlignLeft
                        font.family: fontfamily !== "" ? fontfamily : font.family
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 1
                    }
                }
            }
        }
    }
}
