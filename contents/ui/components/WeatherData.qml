import QtQuick 2.15
import QtQuick.Controls 2.15
import "../js/traductor.js" as Traduc
import "../js/GetInfoApi.js" as GetInfoApi
import "../js/geoCoordinates.js" as GeoCoordinates
import "../js/GetCity.js" as GetCity
import "../js/GetModelWeather.js" as GetModelWeather

Item {
  id: root
  signal dataChanged // Definir el signal aquí
  signal simpleDataReady // Definir el signal aquí

  function obtener(texto, indice) {
    var palabras = texto.split(/\s+/); // Divide the text into words using space as a separator
    return palabras[indice - 1]; // The index is -1 because indices start from 0 in JavaScript
  }

  function fahrenheit(temp) {
    if (temperatureUnit == 0) {
      return temp;
    } else {
      return Math.round((temp * 9 / 5) + 32);
    }
  }

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

  property string latitude: (useCoordinatesIp === "true") ? latitudeIP : (latitudeC === "0") ? latitudeIP : latitudeC
  property string longitud: (useCoordinatesIp === "true") ? longitudIP : (longitudeC === "0") ? longitudIP : longitudeC

  property var observerCoordenates: latitude + longitud

  property int currentTime: Number(Qt.formatDateTime(new Date(), "h"))

  property string datosweather: "0"
  property string forecastWeather: "0"
  property string observer: datosweather + forecastWeather
  property int retrysCity: 0

  property string oneIcon: asingicon(obtener(forecastWeather, 1))
  property string twoIcon: asingicon(obtener(forecastWeather, 2))
  property string threeIcon: asingicon(obtener(forecastWeather, 3))
  property string fourIcon: asingicon(obtener(forecastWeather, 4))
  property string fiveIcon: asingicon(obtener(forecastWeather, 5))
  property string sixIcon: asingicon(obtener(forecastWeather, 6))
  property string sevenIcon: asingicon(obtener(forecastWeather, 7))
  property int oneMax: fahrenheit(obtener(forecastWeather, 8))
  property int twoMax: fahrenheit(obtener(forecastWeather, 9))
  property int threeMax: fahrenheit(obtener(forecastWeather, 10))
  property int fourMax: fahrenheit(obtener(forecastWeather, 11))
  property int fiveMax: fahrenheit(obtener(forecastWeather, 12))
  property int sixMax: fahrenheit(obtener(forecastWeather, 13))
  property int sevenMax: fahrenheit(obtener(forecastWeather, 14))
  property int oneMin: fahrenheit(obtener(forecastWeather, 15))
  property int twoMin: fahrenheit(obtener(forecastWeather, 16))
  property int threeMin: fahrenheit(obtener(forecastWeather, 17))
  property int fourMin: fahrenheit(obtener(forecastWeather, 18))
  property int fiveMin: fahrenheit(obtener(forecastWeather, 19))
  property int sixMin: fahrenheit(obtener(forecastWeather, 20))
  property int sevenMin: fahrenheit(obtener(forecastWeather, 21))

  property string day: (Qt.formatDateTime(new Date(), "yyyy-MM-dd"))
  property string therday: Qt.formatDateTime(new Date(new Date().getTime() + (numberOfDays * 24 * 60 * 60 * 1000)), "yyyy-MM-dd")

  property string finDay: Qt.formatDateTime(new Date(new Date().getTime() + (1 * 24 * 60 * 60 * 1000)), "yyyy-MM-dd")

  property int numberOfDays: 6
  property string currentTemperature: datosweather !== "0" ? fahrenheit(obtener(datosweather, 1)) : "?"
  property string codeleng: ((Qt.locale().name)[0] + (Qt.locale().name)[1])
  property string codeweather: obtener(datosweather, 4)
  property string codeweatherTomorrow: obtener(forecastWeather, 2)
  property string codeweatherDayAftertomorrow: obtener(forecastWeather, 3)
  property string codeweatherTwoDaysAfterTomorrow: obtener(forecastWeather, 4)
  property string minweatherCurrent: fahrenheit(obtener(datosweather, 2))
  property string maxweatherCurrent: fahrenheit(obtener(datosweather, 3))

  property var tempHours: [
    fahrenheit(obtener(datosweather, 9)),
    fahrenheit(obtener(datosweather, 10)),
    fahrenheit(obtener(datosweather, 11)),
    fahrenheit(obtener(datosweather, 12)),
    fahrenheit(obtener(datosweather, 13))
  ]


  property var iconHours: []
  property string minweatherTomorrow: twoMin
  property string maxweatherTomorrow: twoMax
  property string minweatherDayAftertomorrow: threeMin
  property string maxweatherDayAftertomorrow: threeMax
  property string minweatherTwoDaysAfterTomorrow: fourMax
  property string maxweatherTwoDaysAfterTomorrow: fourMax
  property string iconWeatherCurrent
  property string uvindex: uvIndexLevelAssignment(obtener(datosweather, 7))
  property string windSpeed: obtener(datosweather, 6)

  property string weatherLongtext: i18n(textWeather(codeweather))
  property string weatherShottext: i18n(shortTextWeather(codeweather))

  property string probabilidadDeLLuvia: obtener(datosweather, 5)
  property string textProbability: Traduc.rainProbabilityText(codeleng)

  property string completeCoordinates: ""
  property string oldCompleteCoordinates: "1"
  property string latitudeIP: completeCoordinates.substring(0, (completeCoordinates.indexOf(' ')) - 1)
  property string longitudIP: completeCoordinates.substring(completeCoordinates.indexOf(' ') + 1)

  property string uvtext: Traduc.uvRadiationText(codeleng)
  property string windSpeedText: Traduc.windSpeedText(codeleng)
  property int isDay: obtener(datosweather, 8)
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
      // Only update icons when sunrise/sunset are ready
      if (sunrise && sunset) {
        updateIcons();
        if (fullCoordinates) updateWeather(2); // refresh weather after day/night data
      }
    }
  }

  // UV index helper
  function uvIndexLevelAssignment(nivel) {
    if (nivel < 3) return nivel + " " + Traduc.lavelUV(codeleng, 0);
    if (nivel < 6) return nivel + " " + Traduc.lavelUV(codeleng, 1);
    if (nivel < 8) return nivel + " " + Traduc.lavelUV(codeleng, 2);
    if (nivel < 11) return nivel + " " + Traduc.lavelUV(codeleng, 3);
    return nivel + " " + Traduc.lavelUV(codeleng, 4);
  }

  // Fetch coordinates via IP
  function getCoordinatesWithIp() {
    GeoCoordinates.obtenerCoordenadas(function(result) {
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
    GetCity.getNameCity(latitude, longitud, codeleng, function(result) {
      city = result;
      retrycity.start();
    });
  }

  // Weather API
  function getWeatherApi() {
    GetInfoApi.obtenerDatosClimaticos(latitude, longitud, day, finDay, currentTime, function(result) {
      if (isUpdate) newValuesWeather = result;
      else datosweather = result;

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
  function asingicon(code, isDay = null) {
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
    if (isDay !== null) return iconName + (isDay ? "" : "-night");
    return iconName + (determinateDay.isday ? "" : "-night");
  }

  // Update icons
  function updateIcons() {
    function safeObtener(data, index) {
      if (!data || data === "0") return 0
        let value = obtener(data, index)
        return value !== undefined ? value : 0
    }

    iconWeatherCurrent = asingicon(codeweather || 0)
    iconHours = []

    const now = new Date()
    const sunrise = determinateDay.sunrise // in minutes
    let sunset  = determinateDay.sunset    // in minutes

    if (sunset < sunrise) sunset += 1440 // handle sunset past midnight

      // Determine day/night for any Date
      function isDayAtTime(time) {
        let minutesOfDay = time.getHours() * 60 + time.getMinutes()
        if (minutesOfDay < sunrise) minutesOfDay += 1440
          return minutesOfDay >= sunrise && minutesOfDay < sunset
      }

      // Forecast hours start at the next full hour
      const nextHour = now.getMinutes() === 0 ? now.getHours() : now.getHours() + 1

      for (let i = 0; i < 5; i++) {
        const code = safeObtener(datosweather, 14 + i)
        const forecastTime = new Date(now.getTime())
        forecastTime.setHours(nextHour + i, 0, 0, 0) // next full hour
          iconHours.push(asingicon(code, isDayAtTime(forecastTime)) || "weather-unknown")
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
      datosweather = newValuesWeather;
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
      if (datosweather === "0") {
        getWeatherApi();
      }
    }
  }

  Timer {
    id: weatherupdate
    interval: 900000
    running: true
    repeat: true
    onTriggered: {
      isUpdate = true
      oldCompleteCoordinates = completeCoordinates
      getCoordinatesWithIp()
      determinateDay.update()
      //updateWeather(1);
      //veri.start()
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

