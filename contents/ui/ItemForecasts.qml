// QML item displaying hourly and daily weather forecasts using Kirigami components
import QtQuick
import QtQuick.Layouts 1.1
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
                        width: Kirigami.Units.iconSizes.medium
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
        anchors.top: hourlyForecast.bottom
        anchors.topMargin: -9
        spacing: 2

        Repeater {
            model: forecastFullModel
            delegate: RowLayout {
                width: parent.width

                Kirigami.Heading {
                    id: day
                    text: model.date
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.preferredWidth: parent.width * 0.4
                    Layout.leftMargin: 4    // distance from left edge
                    color: Kirigami.Theme.textColor
                    level: 5
                }

                Kirigami.Icon {
                    id: logo
                    width: Kirigami.Units.iconSizes.medium
                    height: width
                    source: model.icon
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }


                Kirigami.Heading {
                    id: forecastText
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.preferredWidth: parent.width * 0.25
                    Layout.rightMargin: 4
                    color: Kirigami.Theme.textColor
                    level: 5

                    RowLayout {
                        id: tempRow
                        anchors.fill: parent
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        Item {
                            Layout.preferredWidth: 20
                            Layout.alignment: Qt.AlignVCenter
                            Kirigami.Heading {
                                text: model.maxTemp + "°"
                                level: 5
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Kirigami.Heading {
                            text: "/"
                            level: 5
                            Layout.preferredWidth: 8
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item {
                            Layout.preferredWidth: 20
                            Layout.alignment: Qt.AlignVCenter
                            Kirigami.Heading {
                                text: model.minTemp + "°"
                                level: 5
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
