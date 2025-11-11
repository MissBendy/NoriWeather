// QML item displaying hourly and daily weather forecasts using Kirigami components
import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    // Stores the maximum width needed for forecast text labels
    property int widthTxt: 0

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
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                    }

                    // Weather icon for the hour
                    Kirigami.Icon {
                        source: model.icon
                        width: Kirigami.Units.iconSizes.mediumLarge
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Temperature label for the hour
                    Kirigami.Heading {
                        text: " " + model.temp + "°"
                        color: Kirigami.Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        level: 5
                    }
                }
            }
        }
    }

    // Bottom half: daily forecast
    Column {
        width: parent.width
        height: parent.height / 2
        anchors.top: hourlyForecast.bottom

        // Repeat for each daily forecast entry
        Repeater {
            model: forecastFullModel
            delegate: Row {
                height: parent.height / 3
                width: parent.width
                spacing: 6

                // Day label
                Kirigami.Heading {
                    id: day
                    width: parent.width - logo.width - widthTxt - 16
                    height: parent.height
                    text: " " + model.date
                    color: Kirigami.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    level: 5
                }

                // Daily weather icon
                Kirigami.Icon {
                    id: logo
                    width: Kirigami.Units.iconSizes.medium
                    height: width
                    source: model.icon
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Max/Min temperature label
                Kirigami.Heading {
                    id: forecastText
                    width: widthTxt
                    height: parent.height
                    text: model.maxTemp + "° / " + model.minTemp + "°"
                    color: Kirigami.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    level: 5
                }

                // Adjust widthTxt to fit the widest temperature text
                Component.onCompleted: {
                    if (forecastText.implicitWidth > widthTxt) {
                        widthTxt = forecastText.implicitWidth
                    }
                }
            }
        }
    }
}
