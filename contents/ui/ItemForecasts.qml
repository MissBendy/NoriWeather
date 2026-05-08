// QML item displaying hourly and daily weather forecasts using Kirigami components
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    // Stores the maximum width needed for forecast text labels
    property int widthTxt: 0
    property string fontfamily: plasmoid.configuration.fontFamily

    // Top half: hourly forecast — 14px literal margins on left and right
    Item {
        id: hourlyForecast
        height: 80
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5

        Item {
            anchors.fill: parent

            Repeater {
                model: forecastHours
                delegate: Item {
                    x: Math.round(index * (parent.width / 5))
                    width: Math.round((index + 1) * (parent.width / 5)) - x
                    height: parent.height

                    Column {
                        width: parent.width
                        y: Math.round((parent.height - height) / 2)
                        x: 0
                        spacing: Math.round(Kirigami.Units.iconSizes.small / 3)

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
                            level: 5
                            font.family: fontfamily !== "" ? fontfamily : font.family
                            width: parent.width
                        }
                    }
                }
            }
        }
    }

    // Bottom half: daily forecast — 10px literal margins on left and right
    Item {
        id: dailyForecast
        anchors.top: hourlyForecast.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5

        Column {
            anchors.fill: parent
            spacing: 2

            Repeater {
                model: forecastFullModel
                delegate: Item {
                    width: parent.width
                    height: Kirigami.Units.iconSizes.medium

                    // Day label — anchored to left edge of delegate (margins already applied by parent)
                    Kirigami.Heading {
                        id: day
                        text: model.date
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * 0.4
                        color: Kirigami.Theme.textColor
                        level: 5
                        font.family: fontfamily !== "" ? fontfamily : font.family
                    }

                    // Icon — centered in the delegate
                    Kirigami.Icon {
                        source: model.icon
                        width: Kirigami.Units.iconSizes.medium
                        height: width
                        roundToIconSize: false
                        anchors.centerIn: parent
                    }

                    // Temperature — slash is the anchor reference, max to its left, min to its right
                    Item {
                        id: tempRow
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: slash.implicitWidth + maxTemp.implicitWidth + minTemp.implicitWidth + 8
                        height: slash.implicitHeight

                        Kirigami.Heading {
                            id: maxTemp
                            text: model.maxTemp + "°"
                            level: 5
                            horizontalAlignment: Text.AlignRight
                            font.family: fontfamily !== "" ? fontfamily : font.family
                            anchors.right: slash.left
                            anchors.rightMargin: 4
                            anchors.baseline: slash.baseline
                        }

                        Kirigami.Heading {
                            id: slash
                            text: "/"
                            level: 5
                            horizontalAlignment: Text.AlignHCenter
                            font.family: fontfamily !== "" ? fontfamily : font.family
                            anchors.right: parent.right
                            anchors.rightMargin: minTemp.implicitWidth + 4
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Kirigami.Heading {
                            id: minTemp
                            text: model.minTemp + "°"
                            level: 5
                            horizontalAlignment: Text.AlignLeft
                            font.family: fontfamily !== "" ? fontfamily : font.family
                            anchors.left: slash.right
                            anchors.leftMargin: 4
                            anchors.baseline: slash.baseline
                        }
                    }
                }
            }
        }
    }
}
