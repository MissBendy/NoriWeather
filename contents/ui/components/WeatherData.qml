import QtQuick 2.15
import QtQuick.Controls 2.15
import "../js/translator.js" as Translate
import "../js/GetInfoApi.js" as GetInfoApi
import "../js/geoCoordinates.js" as GeoCoordinates
import "../js/GetCity.js" as GetCity
import "../js/GetModelWeather.js" as GetModelWeather

Item {
  id: root
  signal dataChanged // Define the signal here
  signal simpleDataReady // Define the signal here

  function obtain(text, index) {
    var words = text.split(/\s+/); // Divide the text into words using space as a separator
    return words[index - 1]; // The index is -1 because indexes start from 0 in JavaScript
  }

  function temperature(temp) {
    if (Number(temperatureUnit) === 0) {
      return Math.round(temp)    // round Celsius values
    } else {
      return Math.round((temp * 9 / 5) + 32)
    }
  }

  property color dayColor: "#3DAAE4"
  property color nightColor: "#0D1B2A"
  property color leftPanelColor: isDay ? dayColor : nightColor

  property bool isUpdate: false
  property string lastUpdate: "0"
  property int hoursC: 0
  property int sunriseTime: 0
  property int sunsetTime: 0
  property string newValuesWeather: "0"
  property string newValuesForeWeather: "0"
  property bool active: plasmoid.configuration.weatheCardActive !== undefined ? plasmoid.configuration.weatheCardActive : false
  property bool isInExecution:  false
  property string useCoordinatesIp: plasmoid.configuration.coordinatesIP
  property string latitudeC: plasmoid.configuration.manualLatitude
  property string longitudeC: plasmoid.configuration.manualLongitude
  property string temperatureUnit: plasmoid.configuration.temperatureUnit
  property int timeFormat: plasmoid.configuration.timeFormat  // 12 or 24

  property string latitude: (useCoordinatesIp === "true") ? latitudeIP : (latitudeC === "0") ? latitudeIP : latitudeC
  property string longitud: (useCoordinatesIp === "true") ? longitudIP : (longitudeC === "0") ? longitudIP : longitudeC

  property var observerCoordenates: latitude + longitud

  property int currentTime: Number(Qt.formatDateTime(new Date(), "h"))

  property string dataweather: "0"
  property string forecastWeather: "0"
  property string observer: dataweather + forecastWeather
  property int retrysCity: 0

  property string oneIcon: assignIcon(safeString(forecastWeather, 1), true)
  property string twoIcon: assignIcon(safeString(forecastWeather, 2), true)
  property string threeIcon: assignIcon(safeString(forecastWeather, 3), true)
  property string fourIcon: assignIcon(safeString(forecastWeather, 4), true)
  property string fiveIcon: assignIcon(safeString(forecastWeather, 5), true)
  property string sixIcon: assignIcon(safeString(forecastWeather, 6), true)
  property string sevenIcon: assignIcon(safeString(forecastWeather, 7), true)
  property int oneMax: temperature(safeInt(forecastWeather, 8))
  property int twoMax: temperature(safeInt(forecastWeather, 9))
  property int threeMax: temperature(safeInt(forecastWeather, 10))
  property int fourMax: temperature(safeInt(forecastWeather, 11))
  property int fiveMax: temperature(safeInt(forecastWeather, 12))
  property int sixMax: temperature(safeInt(forecastWeather, 13))
  property int sevenMax: temperature(safeInt(forecastWeather, 14))
  property int oneMin: temperature(safeInt(forecastWeather, 15))
  property int twoMin: temperature(safeInt(forecastWeather, 16))
  property int threeMin: temperature(safeInt(forecastWeather, 17))
  property int fourMin: temperature(safeInt(forecastWeather, 18))
  property int fiveMin: temperature(safeInt(forecastWeather, 19))
  property int sixMin: temperature(safeInt(forecastWeather, 20))
  property int sevenMin: temperature(safeInt(forecastWeather, 21))

  property string day: (Qt.formatDateTime(new Date(), "yyyy-MM-dd"))
  property string targetDay: Qt.formatDateTime(new Date(new Date().getTime() + (numberOfDays * 24 * 60 * 60 * 1000)), "yyyy-MM-dd")

  property string nextDay: Qt.formatDateTime(new Date(new Date().getTime() + (1 * 24 * 60 * 60 * 1000)), "yyyy-MM-dd")

  property int numberOfDays: 6
  property string currentTemperature: "?"
  property string languageCode: ((Qt.locale().name)[0] + (Qt.locale().name)[1])
  property string codeweather: safeString(dataweather, 4)
  property string codeweatherTomorrow: safeString(forecastWeather, 2)
  property string codeweatherDayAftertomorrow: safeString(forecastWeather, 3)
  property string codeweatherTwoDaysAfterTomorrow: safeString(forecastWeather, 4)
  property string minweatherCurrent: temperature(safeString(dataweather, 2))
  property string maxweatherCurrent: temperature(safeString(dataweather, 3))

  property var tempHours: [
    temperature(safeInt(dataweather, 9)),
    temperature(safeInt(dataweather, 10)),
    temperature(safeInt(dataweather, 11)),
    temperature(safeInt(dataweather, 12)),
    temperature(safeInt(dataweather, 13))
  ]


  property var iconHours: []
  property string minweatherTomorrow: twoMin
  property string maxweatherTomorrow: twoMax
  property string minweatherDayAftertomorrow: threeMin
  property string maxweatherDayAftertomorrow: threeMax
  property string minweatherTwoDaysAfterTomorrow: fourMin
  property string maxweatherTwoDaysAfterTomorrow: fourMax
  property string iconWeatherCurrent
  property string uvindex: uvIndexLevelAssignment(obtain(dataweather, 7))
  property string windSpeed: safeString(dataweather, 6)

  property string weatherLongtext: i18n(textWeather(codeweather))
  property string weatherShottext: i18n(shortTextWeather(codeweather))

  property string probabilidadDeLLuvia: safeString(dataweather, 5)
  property string textProbability: Translate.rainProbabilityText(languageCode)

  property string completeCoordinates: ""
  property string oldCompleteCoordinates: "1"
  property string latitudeIP: completeCoordinates.substring(0, (completeCoordinates.indexOf(' ')) - 1)
  property string longitudIP: completeCoordinates.substring(completeCoordinates.indexOf(' ') + 1)

  property string uvtext: Translate.uvRadiationText(languageCode)
  property string windSpeedText: Translate.windSpeedText(languageCode)
  property bool isDay: determinateDay.isday
  property string city: "unk"
  property string prefixIcon: determinateDay.isDayForHour(new Date().getHours()) ? "" : "-night"

  Component.onCompleted: {
    updateWeather(1); // initial fetch of weather and coordinates
  }

  // Day/night tracker
  DayOrNight {
    id: determinateDay
    latitud: root.latitude
    longitud: root.longitud
  }

  // UV index helper
  function uvIndexLevelAssignment(level) {
    if (level < 3) return level + " " + Translate.levelUV(languageCode, 0);
    if (level < 6) return level + " " + Translate.levelUV(languageCode, 1);
    if (level < 8) return level + " " + Translate.levelUV(languageCode, 2);
    if (level < 11) return level + " " + Translate.levelUV(languageCode, 3);
    return level + " " + Translate.levelUV(languageCode, 4);
  }

  // Fetch coordinates via IP
  function getCoordinatesWithIp() {
    GeoCoordinates.obtainCoordinates(function(result) {
      completeCoordinates = result;
      retryCoordinate.start();
    });
  }

  // Watch for coordinate changes
  onObserverCoordenatesChanged: {
    console.log("Coordinates changed, updating weather");
    if (latitude && longitud && latitude !== "0" && longitud !== "0") {
      updateWeather(2);
      getCityFunction();
    } else {
      console.warn("Invalid coordinates, retrying...");
      retryCoordinate.start();
    }
  }

  // City lookup
  function getCityFunction() {
    if (!latitude || !longitud || latitude === "0" || longitud === "0") {
      console.error("Invalid coordinates for city request");
      return;
    }
    GetCity.getNameCity(latitude, longitud, languageCode, function(result) {
      city = result;
      retrycity.start();
    });
  }

  // Weather API
  function getWeatherApi() {
    GetInfoApi.getWeatherData(latitude, longitud, day, nextDay, currentTime, function(result) {
      if (isUpdate) newValuesWeather = result;
      else dataweather = result;

      updateIcons(); // <-- refresh immediately, no delay
      getForecastWeather();
      retry.start();
    });
  }

  // Forecast
  function getForecastWeather() {
    GetModelWeather.GetForecastWeather(latitude, longitud, day, targetDay, function(result) {
      if (isUpdate) newValuesForeWeather = result;
      else forecastWeather = result;
    });
  }

  // Icon assignment
  function assignIcon(code, isDay = null) {
    const wmocodes = {
      0: "clear",
      1: "few-clouds",
      2: "few-clouds",
      3: "clouds",
      51: "showers-scattered",
      53: "showers-scattered",
      55: "showers-scattered",
      56: "showers-scattered",
      57: "showers-scattered",
      61: "showers",
      63: "showers",
      65: "showers",
      66: "showers-scattered",
      67: "showers",
      71: "snow-scattered",
      73: "snow",
      75: "snow",
      77: "hail",
      80: "showers",
      81: "showers",
      82: "showers",
      85: "snow-scattered",
      86: "snow",
      95: "storm",
      96: "storm",
      99: "storm"
    };
    let iconName = "weather-" + (wmocodes[code] || "unknown");

    // Use explicit isDay if provided; otherwise rely on DayOrNight component
    const dayStatus = (isDay !== null) ? isDay : determinateDay.isday;
    return iconName + (dayStatus ? "" : "-night");
  }

  // Update icons
  function updateIcons() {
    function safeString(data, index) {
      if (!data || data === "0") return 0;
      let value = obtain(data, index);
      return value !== undefined ? value : 0;
    }

    const now = new Date();
    const currentHour = now.getHours();

    // Update current weather icon using DayOrNight
    iconWeatherCurrent = assignIcon(codeweather || 0, determinateDay.isDayForHour(currentHour));

    // Update leftPanelColor based on current day/night
    root.isDay = determinateDay.isDayForHour(currentHour); // update property
    root.leftPanelColor = root.isDay ? root.dayColor : root.nightColor;

    // Update next 5 hourly forecast icons
    iconHours = [];
    for (let i = 0; i < 5; i++) {
      const forecastTime = new Date(now.getTime());
      forecastTime.setHours(currentHour + i + 1, 0, 0, 0); // next hours
      const isDayAtTime = determinateDay.isDayForHour(forecastTime.getHours());
      const code = safeString(dataweather, 14 + i); // adjust index if necessary
      iconHours.push(assignIcon(code, isDayAtTime) || "weather-unknown");
    }

    // Update current temperature when icons refresh
    if (dataweather && dataweather !== "0") {
      currentTemperature = temperature(obtain(dataweather, 1));
    }
  }

  function safeString(data, index) {
    if (!data || data === "0") return "0";
    let value = obtain(data, index);
    return value !== undefined ? value : "0";
  }

  function safeBool(data, index) {
    if (!data || data === "0") return false;
    let value = obtain(data, index);
    return value !== undefined ? Boolean(value) : false;
  }

  function safeInt(data, index) {
    if (!data || data === "0") return 0; // default integer
    let value = obtain(data, index);
    return value !== undefined ? Number(value) : 0;
  }


  function textWeather(x) {
    let text = {
      0: "Clear",
      1: "Mainly clear",
      2: "Partly cloudy",
      3: "Overcast",
      51: "Drizzle light intensity",
      53: "Drizzle moderate intensity",
      55: "Drizzle dense intensity",
      56: "Freezing Drizzle light intensity",
      57: "Freezing Drizzle dense intensity",
      61: "Rain slight intensity",
      63: "Rain moderate intensity",
      65: "Rain heavy intensity",
      66: "Freezing Rain light intensity",
      67: "Freezing Rain heavy intensity",
      71: "Snowfall slight intensity",
      73: "Snowfall moderate intensity",
      75: "Snowfall heavy intensity",
      77: "Snow grains",
      80: "Rain showers slight",
      81: "Rain showers moderate",
      82: "Rain showers violent",
      85: "Snow showers slight",
      86: "Snow showers heavy",
      95: "Thunderstorm",
      96: "Thunderstorm with slight hail"
    };
    return text[x]
  }

  function shortTextWeather(x) {
    let text = {
      0: "Clear",
      1: "Clear",
      2: "Cloudy",
      3: "Cloudy",
      51: "Drizzle",
      53: "Drizzle",
      55: "Drizzle",
      56: "Drizzle",
      57: "Drizzle",
      61: "Rain",
      63: "Rain",
      65: "Rain",
      66: "Rain",
      67: "Rain",
      71: "Snow",
      73: "Snow",
      75: "Snow",
      77: "Hail",
      80: "Showers",
      81: "Showers",
      82: "Showers",
      85: "Showers",
      86: "Showers",
      95: "Storm",
      96: "Storm",
      99: "Storm"
    };
    return text[x]
  }

  function updateWeather(x) {
    if (x === 1) {
      if (useCoordinatesIp === "true") {
        getCoordinatesWithIp();
      } else {
        if (latitudeC === "0" || longitudC === "0") {
          getCoordinatesWithIp();
        } else {
          getWeatherApi()
          determinateDay.update()
        }
      }
    }

    if (x === 2) {
      getWeatherApi();
      determinateDay.update()
    }
  }



  onObserverChanged: {
    if (forecastWeather.length > 3) {
      lastUpdate = new Date()
      dataChanged();
    }
  }

  onNewValuesForeWeatherChanged: {
    if (newValuesForeWeather.length > 3) {
      dataweather = newValuesWeather;
      forecastWeather = newValuesForeWeather;
      newValuesWeather = "0";
      newValuesForeWeather= "0";
    }
  }

  Timer {
    id: retryCoordinate
    interval: 5000
    running: false
    repeat: false
    onTriggered: {
      if (completeCoordinates === "") {
        getCoordinatesWithIp();
      } else {
        if (isUpdate) {
          veri.start()
        }
      }

    }
  }
  Timer {
    id: retrycity
    interval: 6000
    running: false
    repeat: false
    onTriggered: {
      if (city === "unk" && retrysCity < 5) {
        retrysCity = retrysCity + 1
        getCityFuncion();
      }
    }
  }
  Timer {
    id: retry
    interval: 5000
    running: false
    repeat: false
    onTriggered: {
      if (dataweather === "0") {
        getWeatherApi();
      }
    }
  }

  Timer {
    id: weatherUpdateTimer
    running: false // start stopped
    repeat: true
    interval: 1000 // check every second

    property int lastFrequentSecond: -1
    property int lastMinuteUpdated: -1
    property int lastHourUpdated: -1

    onTriggered: {
      const now = new Date()
      const seconds = now.getSeconds()
      const currentMinute = now.getMinutes()
      const currentHour = now.getHours()

      // -----------------------------
      // 30-second refresh
      // -----------------------------
      if ((seconds % 30 === 0) && seconds !== lastFrequentSecond) {
        lastFrequentSecond = seconds
        console.log("30-second refresh triggered")
        updateWeather(2)
        determinateDay.update()
        if (dataweather && dataweather !== "0") {
          currentTemperature = temperature(obtain(dataweather, 1))
          console.log("Updated temperature:", currentTemperature)
        }
      }

      // -----------------------------
      // Current Day/Night icon update
      // -----------------------------
      if (currentMinute !== lastMinuteUpdated) {
        lastMinuteUpdated = currentMinute

        const isDayNow = determinateDay.isday
        console.log("Checking day/night status:", isDayNow ? "Day" : "Night")

        iconWeatherCurrent = assignIcon(codeweather || 0, isDayNow)
        root.isDay = isDayNow
        root.leftPanelColor = isDayNow ? root.dayColor : root.nightColor

        console.log("Updated current icon to:", iconWeatherCurrent)
        console.log("Updated left panel to:", root.leftPanelColor === root.dayColor ? "dayColor" : "nightColor")
      }

      // -----------------------------
      // Update hourly forecast icons at top of the hour
      // -----------------------------
      if (currentHour !== lastHourUpdated) {
        console.log("Updating hourly forecast icons:")
        iconHours = []
        for (let i = 0; i < 5; i++) {
          const forecastTime = new Date(now.getTime())
          forecastTime.setHours(currentHour + i + 1, 0, 0, 0)
            const isDayAtTime = determinateDay.isDayForHour(forecastTime.getHours())
            const code = safeString(dataweather, 14 + i)
            iconHours.push(assignIcon(code, isDayAtTime) || "weather-unknown")
        }

        lastHourUpdated = currentHour

        // Log each hourly icon individually
        iconHours.forEach((icon, index) => {
          console.log(`Hourly icon ${index + 1}:`, icon)
        })
      }
    }
  }

  // Start the timer once dataweather is ready
  onDataweatherChanged: {
    if (dataweather && dataweather !== "0" && !weatherUpdateTimer.running) {
      console.log("dataweather ready, starting weather timer")
      weatherUpdateTimer.start()
    }
  }


  onUseCoordinatesIpChanged: {
    if (active) {
      updateWeather(1);
      isInExecution = true
    }
  }

  onTemperatureUnitChanged: {
    if (dataweather && dataweather !== "0") {
      currentTemperature = temperature(obtain(dataweather, 1))
    }
  }
}
