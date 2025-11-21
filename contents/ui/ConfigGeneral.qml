// QML configuration panel for weather plasmoid settings
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root

    // Signal emitted when any configuration changes
    signal configurationChanged

    // Helper objects to store values for temperature unit, font size, and time format
    QtObject { id: fontsizeValue; property var value }
    QtObject { id: unitWeatherValue; property var value }
    QtObject { id: timeFormatValue; property var value }
    QtObject { id: weatherModel; property var value }

    // Configuration property aliases connected to UI controls
    property alias cfg_coordinatesIP: coordinatesIP.checked
    property alias cfg_displayWeatherInPanel: displayWeather.checked
    property alias cfg_manualLatitude: latitude.text
    property alias cfg_manualLongitude: longitude.text
    property alias cfg_temperatureUnit: unitWeatherValue.value
    property alias cfg_weatherModel: weatherModel.value
    property alias cfg_timeFormat: timeFormatValue.value
    property alias cfg_sizeFontConfig: fontsizeValue.value
    property alias cfg_fontBoldWeather: boldWeather.checked

    // Main vertical layout
    ColumnLayout {
        id: mainColumn
        spacing: Kirigami.Units.largeSpacing
        Layout.fillWidth: true

        // Grid layout for individual settings
        GridLayout {
            id: settingsGrid
            columns: 2

            // Use IP-based coordinates
            Label {
                id: useIPlocation
                Layout.minimumWidth: root.width / 2
                text: i18n("Use geographical coordinates from the IP") + ":"
                horizontalAlignment: Label.AlignRight
            }
            CheckBox { id: coordinatesIP }

            // Manual latitude input (shown if IP coordinates not used)
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Latitude") + ":"
                visible: !coordinatesIP.checked
                horizontalAlignment: Label.AlignRight
            }
            TextField { id: latitude; visible: !coordinatesIP.checked; width: 110 }

            // Manual longitude input (shown if IP coordinates not used)
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Longitude") + ":"
                visible: !coordinatesIP.checked
                horizontalAlignment: Label.AlignRight
            }
            TextField { id: longitude; visible: !coordinatesIP.checked; width: 110 }

            // Display weather on panel
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Display weather conditions on the panel") + ":"
                horizontalAlignment: Label.AlignRight
            }
            CheckBox { id: displayWeather }

            // Bold weather text option
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Bold weather conditions on the panel") + ":"
                horizontalAlignment: Label.AlignRight
            }
            CheckBox { id: boldWeather }

            // Time format selection
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Time format") + ":"
                horizontalAlignment: Label.AlignRight
            }
            ComboBox {
                id: timeFormatComboBox
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: i18n("12-hour"), value: 12 },
                    { text: i18n("24-hour"), value: 24 }
                ]
                onActivated: timeFormatValue.value = currentValue
                Component.onCompleted: currentIndex = indexOfValue(timeFormatValue.value)
            }

            // Temperature unit selection
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Temperature unit") + ":"
                horizontalAlignment: Label.AlignRight
            }
            ComboBox {
                id: unitComboBox
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: i18n("Celsius (°C)"), value: 0 },
                    { text: i18n("Fahrenheit (°F)"), value: 1 }
                ]
                onActivated: unitWeatherValue.value = currentValue
                Component.onCompleted: currentIndex = indexOfValue(unitWeatherValue.value)
            }

            // Weather model selection
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Weather Model") + ":"
                horizontalAlignment: Label.AlignRight
            }
            ComboBox {
                id: weatherModelComboBox
                textRole: "text"
                valueRole: "value"

                model: [
                    // Best match
                    { text: i18n("Best Match"), value: 1 },
                    // ECMWF
                    { text: i18n("ECMWF IFS 0.25°"), value: 2 },
                    { text: i18n("ECMWF IFS HRES 9km"), value: 3 },
                    // NOAA NCEP
                    { text: i18n("NCEP GFS Seamless"), value: 4 },
                    { text: i18n("NCEP GFS Global 0.11°/0.25°"), value: 5 },
                    { text: i18n("NCEP NBM U.S. Conus"), value: 6 },
                    // UK Met Office
                    { text: i18n("UK Met Office Seamless"), value: 7 },
                    { text: i18n("UK Met Office Global 10km"), value: 8 },
                ]

                onActivated: weatherModel.value = currentValue
                Component.onCompleted: currentIndex = indexOfValue(weatherModel.value)
            }

            // Font size selection
            Label {
                Layout.minimumWidth: root.width / 2
                text: i18n("Font Size") + ":"
                horizontalAlignment: Label.AlignRight
            }
            ComboBox {
                id: valueForSizeFont
                textRole: "text"
                valueRole: "value"
                width: 32
                model: [
                    { text: i18n("8"), value: 8 },
                    { text: i18n("9"), value: 9 },
                    { text: i18n("10"), value: 10 },
                    { text: i18n("11"), value: 11 },
                    { text: i18n("12"), value: 12 },
                    { text: i18n("13"), value: 13 },
                    { text: i18n("14"), value: 14 },
                    { text: i18n("15"), value: 15 },
                    { text: i18n("16"), value: 16 },
                    { text: i18n("17"), value: 17 },
                    { text: i18n("18"), value: 18 }
                ]
                onActivated: fontsizeValue.value = currentValue
                Component.onCompleted: currentIndex = indexOfValue(fontsizeValue.value)
            }
        }
    }

    // Bottom-pinned note
    Label {
        id: bottomNote
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Kirigami.Units.largeSpacing
        wrapMode: Text.WordWrap
        text: i18n("Note:\nThe default weather model 'Best Match' provides the best forecast for any given location worldwide.\nSeamless combines all models from a given provider into a seamless prediction.")
        font.italic: true
        horizontalAlignment: Text.AlignLeft
    }
}
