// Main Plasmoid item managing weather data and forecasts
import QtQuick
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid
import org.kde.plasma.core 2.0 as PlasmaCore
import "components" as Components
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

PlasmoidItem {
    id: wrapper
    anchors.fill: parent

    // Weather data component providing current and forecast info
    Components.WeatherData {
        id: weatherData
    }

    signal reset

    // Properties for binding current weather, temperature units, time format, location, and icons
    property string currentTemp: weatherData.tempCurrent
    property string unitsTemperature: plasmoid.configuration.temperatureUnit
    property int timeFormat: plasmoid.configuration.timeFormat  // 12 or 24
    property int weatherModel: plasmoid.configuration.weatherModel
    property string location: weatherData.city
    property string shortWeather: weatherData.weatherShortText
    property string longWeather: weatherData.weatherLongText
    property string currentIcon: weatherData.iconCurrent
    property string currentMaxMin: weatherData.maxtempToday + "° / " + weatherData.mintempToday + "°"
    property var temps: weatherData.tempHours
    property var icons: weatherData.iconHours
    property alias forecastHours: hoursWeatherModel
    property alias forecastFullModel: forecastModel
    property bool isUpdate: false
    property date currentDateTime: new Date()
    readonly property int currentDayOfWeek: currentDateTime.getDay()

    // Models to hold hourly and daily forecast data
    ListModel {
        id: hoursWeatherModel
    }
    ListModel {
        id: forecastModel
    }

    // Translate day index to localized day name
    function getTranslatedDayInitial(dayIndex) {
        var tempDate = new Date(currentDateTime)
        tempDate.setDate(tempDate.getDate() + dayIndex)
        return tempDate.toLocaleString(Qt.locale(), "dddd")
    }

    // Returns an array of next forecast hours based on weatherData
    function getNextForecastHours() {
        if (!weatherData || !weatherData.tempHours) return []

            const now = new Date()
            const currentHour = now.getHours()

            const nextHours = []

            // Map the weatherData.tempHours array to actual forecast hours
            for (let i = 0; i < weatherData.tempHours.length; i++) {
                // Forecast hour = current hour + index + 1 (or wrap with 24)
                nextHours.push((currentHour + i + 1) % 24)
            }

            return nextHours
    }

    // Populate hourly forecast model using actual weatherData arrays
    function hoursForecast(nextHours) {
        hoursWeatherModel.clear()
        for (let i = 0; i < weatherData.tempHours.length; i++) {
            hoursWeatherModel.append({
                hours: nextHours[i],
                icon: weatherData.iconHours[i],
                temp: weatherData.tempHours[i]
            })
        }
    }

    // Update hourly forecast model with new values using weatherData
    function hoursForecastUpdate(nextHours) {
        for (let i = 0; i < hoursWeatherModel.count; i++) {
            hoursWeatherModel.set(i, {
                hours: nextHours[i],
                icon: weatherData.iconHours[i],
                temp: parseFloat(weatherData.tempHours[i])
            })
        }
    }

    // Update temperature units in all models
    function updateUnitsTempe() {
        const Maxs = [
            weatherData.twoMax,     // Tomorrow
            weatherData.threeMax,  // Day after tomorrow
            weatherData.fourMax,  // Two days after tomorrow
            weatherData.fiveMax, // Three days after tomorrow
            weatherData.sixMax  // Four days after tomorrow
        ];
        const Mins = [
            weatherData.twoMin,     // Tomorrow
            weatherData.threeMin,  // Day after tomorrow
            weatherData.fourMin,  // Two days after tomorrow
            weatherData.fiveMin, // Three days after tomorrow
            weatherData.sixMin  // Four days after tomorrow
        ];

        // Update daily forecast temperatures
        for (let i = 0; i < forecastModel.count; i++) {
            forecastModel.set(i, { "maxTemp": Maxs[i], "minTemp": Mins[i] })
        }

        // Update hourly forecast temperatures
        for (let i = 0; i < hoursWeatherModel.count; i++) {
            hoursWeatherModel.set(i, { "temp": parseFloat(temps[i]) })
        }
    }

    // Sync when WeatherData signals an update
    Connections {
        target: weatherData
        function onWeatherSynced() {
            console.log("Weather update synced")
            forms()
        }
    }

    // Populate daily forecast model
    function updateForecastModel() {
        const iconsArr = [
            weatherData.twoIcon,     // Tomorrow
            weatherData.threeIcon,  // Day after tomorrow
            weatherData.fourIcon,  // Two days after tomorrow
            weatherData.fiveIcon, // Three days after tomorrow
            weatherData.sixIcon  // Four days after tomorrow
        ];
        const Maxs = [
            weatherData.twoMax,     // Tomorrow
            weatherData.threeMax,  // Day after tomorrow
            weatherData.fourMax,  // Two days after tomorrow
            weatherData.fiveMax, // Three days after tomorrow
            weatherData.sixMax  // Four days after tomorrow
        ];
        const Mins = [
            weatherData.twoMin,     // Tomorrow
            weatherData.threeMin,  // Day after tomorrow
            weatherData.fourMin,  // Two days after tomorrow
            weatherData.fiveMin, // Three days after tomorrow
            weatherData.sixMin  // Four days after tomorrow
        ];

        // Clear and append daily forecast
        forecastModel.clear()
            for (let i = 0; i < 3; i++) {
                forecastModel.append({
                    date: getTranslatedDayInitial(i + 1), // tomorrow, day after, etc.
                                     icon: iconsArr[i],
                                     maxTemp: Maxs[i],
                                     minTemp: Mins[i]
                })
            }
    }

    // Refresh all forecast data and mark as updated
    function forms() {
        currentDateTime = new Date()

        // Precompute next forecast hours from weatherData
        const nextHours = getNextForecastHours()

        // Update hourly and daily models
        if (isUpdate) {
            hoursForecastUpdate(nextHours)
            updateForecastModel()
        } else {
            hoursForecast(nextHours)
            updateForecastModel()
            isUpdate = true
        }
    }

    // Update temperature units if configuration changes
    onUnitsTemperatureChanged: {
        updateUnitsTempe()
    }

    // Connect weather data changes to refresh function
    Component.onCompleted: {
        weatherData.dataChanged.connect(() => {
            Qt.callLater(forms)
        })
    }

    // Representations for the plasmoid
    preferredRepresentation: compactRepresentation
    compactRepresentation: compactRepresentation
    fullRepresentation: compactRepresentation

    Component {
        id: compactRepresentation
        CompactRepresentation {}
    }
}
