import QtQuick
import org.kde.kirigami as Kirigami

Item {
    property int widthTxt: 0

    Row {
        id: hourlyForecast
        width: parent.width
        height: parent.height / 2

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

                    Kirigami.Heading {
                        text: {
                            var hour12 = model.hours % 12;
                            if (hour12 === 0) hour12 = 12;
                            var suffix = (model.hours >= 12 && model.hours < 24) ? "pm" : "am";
                            return hour12 + suffix;
                        }
                        color: Kirigami.Theme.textColor
                        level: 5
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                    }

                    Kirigami.Icon {
                        source: model.icon
                        width: Kirigami.Units.iconSizes.mediumLarge
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

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

    Column {
        width: parent.width
        height: parent.height / 2
        anchors.top: hourlyForecast.bottom

        Repeater {
            model: forecastFullModel
            delegate: Row {
                height: parent.height / 3
                width: parent.width
                spacing: 8

                Kirigami.Heading {
                    id: day
                    width: parent.width - logo.width - widthTxt - 16
                    height: parent.height
                    text: " " + model.date
                    color: Kirigami.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    level: 5
                }

                Kirigami.Icon {
                    id: logo
                    width: Kirigami.Units.iconSizes.medium
                    height: width
                    source: model.icon
                    anchors.verticalCenter: parent.verticalCenter
                }

                Kirigami.Heading {
                    id: forecastText
                    width: widthTxt
                    height: parent.height
                    text: model.maxTemp + "° / " + model.minTemp + "°"
                    color: Kirigami.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    level: 5
                }

                Component.onCompleted: {
                    if (forecastText.implicitWidth > widthTxt) {
                        widthTxt = forecastText.implicitWidth
                    }
                }
            }
        }
    }
}
