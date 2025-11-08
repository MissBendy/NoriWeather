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
    if (temperatureUnit == 0) {
      return temp;
    } else {
      return Math.round((temp * 9 / 5) + 32);
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
  property bool active: plasmoid.configuration.weatheCardActive
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

  property string oneIcon: assignIcon(obtain(forecastWeather, 1), true)
  property string twoIcon: assignIcon(obtain(forecastWeather, 2), true)
  property string threeIcon: assignIcon(obtain(forecastWeather, 3), true)
  property string fourIcon: assignIcon(obtain(forecastWeather, 4), true)
  property string fiveIcon: assignIcon(obtain(forecastWeather, 5), true)
  property string sixIcon: assignIcon(obtain(forecastWeather, 6), true)
  property string sevenIcon: assignIcon(obtain(forecastWeather, 7), true)
  property int oneMax: temperature(obtain(forecastWeather, 8))
  property int twoMax: temperature(obtain(forecastWeather, 9))
  property int threeMax: temperature(obtain(forecastWeather, 10))
  property int fourMax: temperature(obtain(forecastWeather, 11))
  property int fiveMax: temperature(obtain(forecastWeather, 12))
  property int sixMax: temperature(obtain(forecastWeather, 13))
  property int sevenMax: temperature(obtain(forecastWeather, 14))
  property int oneMin: temperature(obtain(forecastWeather, 15))
  property int twoMin: temperature(obtain(forecastWeather, 16))
  property int threeMin: temperature(obtain(forecastWeather, 17))
  property int fourMin: temperature(obtain(forecastWeather, 18))
  property int fiveMin: temperature(obtain(forecastWeather, 19))
  property int sixMin: temperature(obtain(forecastWeather, 20))
  property int sevenMin: temperature(obtain(forecastWeather, 21))

  property string day: (Qt.formatDateTime(new Date(), "yyyy-MM-dd"))
  property string therday: Qt.formatDateTime(new Date(new Date().getTime() + (numberOfDays * 24 * 60 * 60 * 1000)), "yyyy-MM-dd")

  property string finDay: Qt.formatDateTime(new Date(new Date().getTime() + (1 * 24 * 60 * 60 * 1000)), "yyyy-MM-dd")

  property int numberOfDays: 6
  property string currentTemperature: dataweather !== "0" ? temperature(obtain(dataweather, 1)) : "?"
  property string languageCode: ((Qt.locale().name)[0] + (Qt.locale().name)[1])
  property string codeweather: obtain(dataweather, 4)
  property string codeweatherTomorrow: obtain(forecastWeather, 2)
  property string codeweatherDayAftertomorrow: obtain(forecastWeather, 3)
  property string codeweatherTwoDaysAfterTomorrow: obtain(forecastWeather, 4)
  property string minweatherCurrent: temperature(obtain(dataweather, 2))
  property string maxweatherCurrent: temperature(obtain(dataweather, 3))

  property var tempHours: [
    temperature(obtain(dataweather, 9)),
    temperature(obtain(dataweather, 10)),
    temperature(obtain(dataweather, 11)),
    temperature(obtain(dataweather, 12)),
    temperature(obtain(dataweather, 13))
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
  property string windSpeed: obtain(dataweather, 6)

  property string weatherLongtext: i18n(textWeather(codeweather))
  property string weatherShottext: i18n(shortTextWeather(codeweather))

  property string probabilidadDeLLuvia: obtain(dataweather, 5)
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

    onIsdayChanged: {
      updateIcons(); // refresh current icon immediately

      // Optionally refresh weather if needed
      if (fullCoordinates) updateWeather(2);

      // Schedule next update at sunrise or sunset
      if (nextEventTimer.running) nextEventTimer.stop();
      let now = new Date();
      let nextEvent = isday ? new Date(sunsetTime) : new Date(sunriseTime);
      if (nextEvent <= now) nextEvent = new Date(nextEvent.getTime() + 24*60*60*1000);
      nextEventTimer.start(nextEvent - now);
    }
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
    GetInfoApi.getWeatherData(latitude, longitud, day, finDay, currentTime, function(result) {
      if (isUpdate) newValuesWeather = result;
      else dataweather = result;

      updateIcons(); // <-- refresh immediately, no delay
      getForecastWeather();
      retry.start();
    });
  }

  // Forecast
  function getForecastWeather() {
    GetModelWeather.GetForecastWeather(latitude, longitud, day, therday, function(result) {
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
    function safeobtain(data, index) {
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
      const code = safeobtain(dataweather, 14 + i); // adjust index if necessary
      iconHours.push(assignIcon(code, isDayAtTime) || "weather-unknown");
    }
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
          updateIcons()
        }
      }
    }
///
    if (x === 2) {
      getWeatherApi();
      determinateDay.update()
      updateIcons()
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
      updateIcons()
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
    running: true
    repeat: true
    interval: 0

    onTriggered: {
      // Regular 15-minute background update
      isUpdate = true
      oldCompleteCoordinates = completeCoordinates
      getCoordinatesWithIp()
      determinateDay.update()

      // Hourly full refresh (exactly 1 second after the new hour)
      const now = new Date()
      const minutes = now.getMinutes()
      const seconds = now.getSeconds()

      // Run hourly refresh if within first few seconds of the new hour
      if (minutes === 0 && seconds <= 2) {
        updateWeather(1)
        updateIcons()
        determinateDay.update()
        console.log("Hourly weather refresh triggered")
      }

      // Determine next trigger interval:
      // if we’re inside the hour mark window, jump to next 15min slot,
      // else maintain the 15min cycle
      let nextHour = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours() + 1, 0, 1)
      let nextQuarter = new Date(now.getTime() + 15 * 60 * 1000)
      interval = Math.min(nextHour - now, 15 * 60 * 1000)

      start()
    }
  }


  Timer {
    id: nextEventTimer
    running: false
    repeat: false
    onTriggered: {
      determinateDay.update();  // recompute isDay
      updateIcons();            // refresh current icon at sunrise/sunset
    }
  }

  // Timer to check hour rollover
  Timer {
    id: hourlyIconRefresh
    interval: 1000 // check every 10 seconds
    running: true
    repeat: true
    property int lastHour: new Date().getHours()
    onTriggered: {
      const currentHour = new Date().getHours();
      if (currentHour !== lastHour) {
        lastHour = currentHour;
        // recompute day/night and icons
        determinateDay.update();
        Qt.callLater(() => updateIcons()); // ensures DayOrNight is ready
      }
    }
  }

  Timer {
    id: observateHours
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      hoursC = Qt.formatDateTime(new Date(), "h")
    }
  }

  Timer {
    id: veri
    interval: 4000
    running: false
    repeat: false
    onTriggered: {
      //newValuesWeather = "0"
     if (oldCompleteCoordinates === completeCoordinates) {
       updateWeather(2)
    }
    }
  }


  onUseCoordinatesIpChanged: {
    if (active) {
      updateWeather(1);
      isInExecution = true
    }
  }
}

