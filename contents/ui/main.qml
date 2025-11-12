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
    property string location: weatherData.city
    property string weather: weatherData.weatherShottext
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

    // Returns an array of next 5 forecast hours
    function getNextForecastHours() {
        const now = new Date()
        const nextHour = now.getMinutes() === 0 ? now.getHours() : now.getHours() + 1
        const hours = []

        for (let i = 0; i < 5; i++) {
            hours.push((nextHour + i) % 24)  // wrap around 24h
        }

        return hours
    }

    // Populate hourly forecast model
    function hoursForecast() {
        const forecastHoursArr = getNextForecastHours()
        hoursWeatherModel.clear()
        for (let i = 0; i < 5; i++) {
            hoursWeatherModel.append({
                icon: icons[i],
                temp: temps[i],
                hours: forecastHoursArr[i]
            })
        }
    }

    // Update hourly forecast model with new values
    function hoursForecastUpdate() {
        const forecastHoursArr = getNextForecastHours()
        for (let i = 0; i < hoursWeatherModel.count; i++) {
            hoursWeatherModel.set(i, { "icon": icons[i], "temp": parseFloat(temps[i]), "hours": forecastHoursArr[i] })
        }
    }

    // Update temperature units in all models
    function updateUnitsTempe() {
        const Maxs = [
            weatherData.twoMax,
            weatherData.threeMax,
            weatherData.fourMax,
            weatherData.fiveMax
        ];
        const Mins = [
            weatherData.twoMin,
            weatherData.threeMin,
            weatherData.fourMin,
            weatherData.fiveMin
        ];

        for (let i = 0; i < forecastModel.count; i++) {
            forecastModel.set(i, { "maxTemp": Maxs[i], "minTemp": Mins[i] })
        }

        for (let i = 0; i < hoursWeatherModel.count; i++) {
            hoursWeatherModel.set(i, { "temp": parseFloat(temps[i]) })
        }
    }

    // Timer to check for outdated weather data and trigger refresh
    Timer {
        id: checkUpdateTimer
        interval: 5000
        repeat: true
        running: true
        onTriggered: {
            if (weatherData.lastUpdate !== "") {
                const now = new Date()
                const lastUpdateDate = new Date(weatherData.lastUpdate)
                const diffMinutes = (now - lastUpdateDate) / 60000
                if (diffMinutes > 5) forms()
            }
        }
    }

    // Populate daily forecast model
    function updateForecastModel() {
        const iconsArr = [
            weatherData.twoIcon,
            weatherData.threeIcon,
            weatherData.fourIcon,
            weatherData.fiveIcon
        ];
        const Maxs = [
            weatherData.twoMax,
            weatherData.threeMax,
            weatherData.fourMax,
            weatherData.fiveMax
        ];
        const Mins = [
            weatherData.twoMin,
            weatherData.threeMin,
            weatherData.fourMin,
            weatherData.fiveMin
        ];

        forecastModel.clear();

        // Start at 0, but use getTranslatedDayInitial(i + 1) to make first item "tomorrow"
        for (let i = 0; i < 3; i++) {
            forecastModel.append({
                date: getTranslatedDayInitial(i + 1), // tomorrow, day after, etc.
                                 icon: iconsArr[i],
                                 maxTemp: Maxs[i],
                                 minTemp: Mins[i]
            });
        }
    }

    // Refresh all forecast data and mark as updated
    function forms() {
        currentDateTime = new Date()
        if (isUpdate) {
            hoursForecastUpdate()
            updateForecastModel()
        } else {
            hoursForecast()
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
