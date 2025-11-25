import QtQuick 2.15
import QtQuick.Controls 2.15
import "../js/translator.js" as Translate
import "../js/GetWeather.js" as GetInfoApi
import "../js/geoCoordinates.js" as GeoCoordinates
import "../js/GetCity.js" as GetCity

Item {
  id: root
  signal dataChanged
  signal weatherSynced

  // Extract a word by position from a string
  function obtain(text, index) {
    let words = text.split(/\s+/); // Divide the text into words using space as a separator
    return words[index - 1]; // The index is -1 because indexes start from 0 in JavaScript
  }

  // Convert and round temperature to selected unit
  function temperature(temp) {
    if (!temp) return 0;  // guard

    // Ensure the string is treated correctly
    const unit = Number(temperatureUnit);
    if (unit === 1) { // Fahrenheit
      return Math.round((temp * 9 / 5) + 32);
    } else { // Celsius, just round
      return Math.round(temp);
    }
  }

  // UI color scheme for day and night
  property color dayColor: "#3DAAE4"
  property color nightColor: "#0D1B2A"
  property color leftPanelColor: true ? dayColor : nightColor

  // General state and configuration properties
  property bool isUpdate: false
  property string lastUpdate: "0"
  property int hoursC: 0
  property int sunriseTime: 0
  property int sunsetTime: 0
  property string newValuesWeather: "0"
  property bool active: plasmoid.configuration.weatheCardActive !== undefined ? plasmoid.configuration.weatheCardActive : false
  property bool isInExecution:  false
  property string useCoordinatesIp: plasmoid.configuration.coordinatesIP
  property string latitudeC: plasmoid.configuration.manualLatitude
  property string longitudeC: plasmoid.configuration.manualLongitude
  property string temperatureUnit: plasmoid.configuration.temperatureUnit
  property int timeFormat: plasmoid.configuration.timeFormat  // 12 or 24
  property int weatherModel: plasmoid.configuration.weatherModel
  property string apiModel: ""

  // Determine final coordinates (manual or IP-based)
  property string latitude: (useCoordinatesIp === "true") ? latitudeIP : (latitudeC === "0") ? latitudeIP : latitudeC
  property string longitud: (useCoordinatesIp === "true") ? longitudIP : (longitudeC === "0") ? longitudIP : longitudeC
  property var observerCoordenates: latitude + longitud

  // Track current local hour for display
  property int currentTime: Number(Qt.formatDateTime(new Date(), "h"))
  property var nextHours: []

  // Core weather data and update triggers
  property string dataweather: "0"
  property string observer: dataweather
  property int retrysCity: 0

  // Date tracking for current and upcoming forecasts
  property int numberOfDays: 7

  property string day: (Qt.formatDateTime(new Date(), "yyyy-MM-dd"))

  property string nextDay: {
    const d = new Date()
    d.setDate(d.getDate() + 1)
    return Qt.formatDateTime(d, "yyyy-MM-dd")
  }

  property string targetDay: {
    const d = new Date()
    d.setDate(d.getDate() + numberOfDays)
    return Qt.formatDateTime(d, "yyyy-MM-dd")
  }

  // Range and temperature storage
  property string tempCurrent: "?" // index 1
  property string mintempToday: "?"
  property string maxtempToday: "?"
  property string mintempTomorrow: "?"
  property string maxtempTomorrow: "?"
  property string mintempDayAftertomorrow: "?"
  property string maxtempDayAftertomorrow: "?"
  property string mintempTwoDaysAfterTomorrow: "?"
  property string maxtempTwoDaysAfterTomorrow: "?"

  // Forecast icons and temperatures
  property int oneMin: temperature(safeInt(dataweather, 2))
  property int twoMin: temperature(safeInt(dataweather, 3))
  property int threeMin: temperature(safeInt(dataweather, 4))
  property int fourMin: temperature(safeInt(dataweather, 5))
  property int fiveMin: temperature(safeInt(dataweather, 6))
  property int sixMin: temperature(safeInt(dataweather, 7))
  property int sevenMin: temperature(safeInt(dataweather, 8))
  property int oneMax: temperature(safeInt(dataweather, 9))
  property int twoMax: temperature(safeInt(dataweather, 10))
  property int threeMax: temperature(safeInt(dataweather, 11))
  property int fourMax: temperature(safeInt(dataweather, 12))
  property int fiveMax: temperature(safeInt(dataweather, 13))
  property int sixMax: temperature(safeInt(dataweather, 14))
  property int sevenMax: temperature(safeInt(dataweather, 15))
  property string iconCurrent: assignIcon(safeInt(dataweather, 16), true);
  property var tempHours: [17, 18, 19, 20, 21]
  property var iconHours: [22, 23, 24, 25, 26]
  property string oneIcon: assignIcon(safeString(dataweather, 27), true)
  property string twoIcon: assignIcon(safeString(dataweather, 28), true)
  property string threeIcon: assignIcon(safeString(dataweather, 29), true)
  property string fourIcon: assignIcon(safeString(dataweather, 30), true)
  property string fiveIcon: assignIcon(safeString(dataweather, 31), true)
  property string sixIcon: assignIcon(safeString(dataweather, 32), true)
  property string sevenIcon: assignIcon(safeString(dataweather, 33), true)

  // Current/Daily weather icons
  property string codeweatherCurrent: "0"
  property string codeweatherTomorrow: "0"
  property string codeweatherDayAftertomorrow: "0"
  property string codeweatherTwoDaysAfterTomorrow: "0"

  // Translated text for weather condition
  property string languageCode: ((Qt.locale().name)[0] + (Qt.locale().name)[1])
  property string weatherLongText: i18n(textWeather(codeweatherCurrent))
  property string weatherShortText: i18n(shortTextWeather(codeweatherCurrent))
  // Coordinate handling from IP lookup
  property string completeCoordinates: ""
  property string oldCompleteCoordinates: "1"
  property string latitudeIP: completeCoordinates.substring(0, (completeCoordinates.indexOf(' ')) - 1)
  property string longitudIP: completeCoordinates.substring(completeCoordinates.indexOf(' ') + 1)
  // Day/night state and city name
  property bool isDay: determinateDay.isDayForHour(new Date().getHours())
  property string city: "unk"
  property string prefixIcon: determinateDay.isDayForHour(new Date().getHours()) ? "" : "-night"

  Timer {
    id: onlineRetryTimer
    interval: 5000   // retry every 5 seconds
    running: false
    repeat: true
    onTriggered: checkOnlineAndUpdate()
  }

  function checkOnlineAndUpdate() {
    var req = new XMLHttpRequest()
    req.open("GET", "https://www.google.com/generate_204", true)
    req.onreadystatechange = function () {
      if (req.readyState === XMLHttpRequest.DONE) {
        if (req.status >= 200 && req.status < 400) {
          console.log("Network online, fetching weather")
          updateWeather(1)           // fetch weather
          onlineRetryTimer.stop()    // stop retrying once successful
        } else {
          console.log("Network Offline, will retry in 5s")
          if (!onlineRetryTimer.running) onlineRetryTimer.start()
        }
      }
    }
    req.send()
  }

  Component.onCompleted: {
    checkOnlineAndUpdate()   // first attempt immediately
  }

  // Day/night tracker
  DayOrNight {
    id: determinateDay
    latitud: root.latitude
    longitud: root.longitud
  }

  // Fetch coordinates via IP service
  function getCoordinatesWithIp() {
    GeoCoordinates.obtainCoordinates(function(result) {
      completeCoordinates = result;
      retryCoordinate.start();
    });
  }

  // React to coordinate changes and refresh data
  onObserverCoordenatesChanged: {
    if (latitude && longitud && latitude !== "0" && longitud !== "0") {
      // Only fetch city if coordinates changed
      if (latitude + longitud !== oldCompleteCoordinates) {
        oldCompleteCoordinates = latitude + longitud;
        getCityFunction();
      }
      updateWeather(2);
    } else {
      retryCoordinate.start();
    }
  }

  // Resolve city name from coordinates
  function getCityFunction() {
    if (!latitude || !longitud || latitude === "0" || longitud === "0") {
      console.error("Invalid coordinates for city request");
      return;
    }
    GetCity.getNameCity(latitude, longitud, languageCode, function(result) {
      city = result;
      getWeatherApi();
      retrycity.start();
    });
  }

  // Fetch current weather data
  function getWeatherApi() {
    // Map integer to API string
    switch (weatherModel) {

      // Best
      case 1:
        apiModel = "best_match";
        break;
        // ECMWF
      case 2:
        apiModel = "ecmwf_ifs025";
        break;
      case 3:
        apiModel = "ecmwf_ifs";
        break;
        // NOAA NCEP
      case 4:
        apiModel = "gfs_seamless";
        break;
      case 5:
        apiModel = "gfs_global";
        break;
      case 6:
        apiModel = "ncep_nbm_conus";
        break;
        // UK Met Office
      case 7:
        apiModel = "ukmo_seamless";
        break;
      case 8:
        apiModel = "ukmo_global_deterministic_10km";
        break;

      default:
        console.error("Invalid weather model:", weatherModel);
        return;
    }
     // console.log("Weather model:", apiModel);

     if (!latitude || !longitud || latitude === "0" || longitud === "0") {
       // console.warn("Coordinates invalid, will retry");
       retryCoordinate.start();
       return;
     }

    GetInfoApi.getWeatherData(latitude, longitud, 5, apiModel, function(result) { // '5' = next 5 hours
      if (isUpdate) newValuesWeather = result;
      else dataweather = result;

      const now = new Date();
      const currentHour = now.getHours();
      const currentMinute = now.getMinutes();

      // total minutes since midnight
      const currentMinutesTotal = currentHour * 60 + currentMinute;

      // exact day/night using sunrise/sunset
      const isDayNow = (currentMinutesTotal >= determinateDay.sunrise &&
      currentMinutesTotal < determinateDay.sunset);

      // Current temperature and weather code
      tempCurrent = temperature(safeInt(dataweather, 1));
      iconCurrent = assignIcon(safeInt(dataweather, 16), isDayNow);

      // Daily temperatures min/max
      mintempToday = temperature(safeInt(dataweather, 2));
      maxtempToday = temperature(safeInt(dataweather, 9));
      mintempTomorrow = temperature(safeInt(dataweather, 3));
      maxtempTomorrow = temperature(safeInt(dataweather, 10));
      mintempDayAftertomorrow = temperature(safeInt(dataweather, 4));
      maxtempDayAftertomorrow = temperature(safeInt(dataweather, 11));
      mintempTwoDaysAfterTomorrow = temperature(safeInt(dataweather, 5));
      maxtempTwoDaysAfterTomorrow = temperature(safeInt(dataweather, 12));

      // Daily weather icons
      codeweatherCurrent = safeString(dataweather, 16)
      codeweatherTomorrow = safeString(dataweather, 28);
      codeweatherDayAftertomorrow = safeString(dataweather, 29);
      codeweatherTwoDaysAfterTomorrow = safeString(dataweather, 30);

      // Compute upcoming forecast hours
      const forecastHoursArr = [];
      const nextHour = (currentMinute === 0 ? currentHour : currentHour + 1) % 24;
      for (let i = 0; i < 5; i++) {
        forecastHoursArr.push((nextHour + i) % 24);
      }
      nextHours = forecastHoursArr;

      // Hourly temperatures (next 5 hours)
      tempHours = [];
      iconHours = [];
      for (let i = 0; i < 5; i++) {
        const temp = safeInt(dataweather, 17 + i);  // 17–21 = hourly temps
        const code = safeInt(dataweather, 22 + i);  // 22–26 = hourly codes

        tempHours.push(temperature(temp));

        const forecastTime = new Date(now.getTime());
        forecastTime.setHours(currentHour + i + 1, 0, 0, 0);

        iconHours.push(assignIcon(code, determinateDay.isDayForHour(forecastTime.getHours())));
      }

      // Update left panel color with day/night state
      root.isDay = isDayNow;
      root.leftPanelColor = isDayNow ? root.dayColor : root.nightColor;

      retry.start();
    });
  }

  // Keep track of time
  function getCurrentTimeInfo() {
    const now = new Date();
    return {
      now: now,
      seconds: now.getSeconds(),
      currentMinute: now.getMinutes(),
      currentHour: now.getHours()
    };
  }

  // Safe conversion: return string at position (1-based index)
  function safeString(data, index) {
    if (!data || data === "0") return "0";

    let words = data.split(/\s+/);
    // Ensure index is within bounds (1-based)
    if (index < 1 || index > words.length) return "0";

    return words[index - 1];
  }

  // Safe conversion: return number at position (1-based index)
  function safeInt(data, index) {
    if (!data || data === "0") return 0;

    let words = data.split(/\s+/);
    if (index < 1 || index > words.length) return 0;

    let value = Number(words[index - 1]);
    return isNaN(value) ? 0 : value;
  }

  // Map WMO weather codes to icons
  function assignIcon(code, isDay = null) {
    const wmocodes = {
      0:  "clear",
      1:  "few-clouds",
      2:  "clouds",
      3:  "many-clouds",
      45: "overcast",
      48: "overcast",
      51: "showers-scattered",
      53: "showers-scattered",
      55: "showers-scattered",
      56: "freezing-rain",
      57: "freezing-rain",
      61: "showers",
      63: "showers",
      65: "showers",
      66: "freezing-rain",
      67: "freezing-rain",
      71: "snow-scattered",
      73: "snow",
      75: "snow",
      77: "snow-rain",
      80: "showers",
      81: "showers",
      82: "showers",
      85: "snow-scattered",
      86: "snow",
      95: "storm",
      96: "storm",
      99: "storm"
    };

    // Icons that never use day/night variants
    const baseIcons = new Set([
      "showers-scattered",
      "showers",
      "snow-scattered",
      "snow-rain",
      "snow",
      "storm",
      "freezing-rain",
      "overcast",
      "hail",
      "many-clouds",
    ]);

    let iconName = wmocodes[code] || "unknown";

    const dayStatus = (isDay !== null) ? isDay : determinateDay.isday;

    // Append -night only if allowed and a night variant exists
    if (!dayStatus && ["clear", "few-clouds", "clouds"].includes(iconName)) {
      iconName += "-night";
    }

    return "weather-" + iconName;
  }


  // Detailed text for weather condition
  function textWeather(x) {
    let text = {
      0: "Clear",
      1: "Mostly Clear",
      2: "Partly Cloudy",
      3: "Overcast",
      45: "Fog",
      48: "Icy Fog",
      51: "Light Drizzle",
      53: "Drizzle",
      55: "Heavy Drizzle",
      56: "Light Freezing Drizzle",
      57: "Freezing Drizzle",
      61: "Light Rain",
      63: "Rain",
      65: "Heavy Rain",
      66: "Light Freezing Rain",
      67: "Freezing Rain",
      71: "Light Snow",
      73: "Snow",
      75: "Heavy Snow",
      77: "Snow Grains",
      80: "Light Showers",
      81: "Showers",
      82: "Heavy Showers",
      85: "Light Snow Showers",
      86: "Snow Showers",
      95: "Thunderstorm",
      96: "Light Thunderstorm With Hail",
      99: "Thunderstorm With Hail"
    };
    return text[x]
  }

  // Short label for weather condition
  function shortTextWeather(x) {
    let text = {
      0: "Clear",
      1: "Clear",
      2: "Cloudy",
      3: "Overcast",
      45: "Fog",
      48: "Icy Fog",
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
      77: "Snow",
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

  // Main weather update logic
  function updateWeather(x) {
    if (x === 1) {
      if (useCoordinatesIp === "true") {
        getCoordinatesWithIp();
      } else {
        if (latitudeC === "0" || longitudeC === "0") {
          getCoordinatesWithIp();
        } else {
          getCityFunction()
        }
      }
    }

    if (x === 2) {
      getWeatherApi();
    }
  }

  // Trigger to start weather update timer
  function isWeatherReady() {
    return dataweather && dataweather !== "0";
  }

  // Detect forecast updates and trigger change signal
  onObserverChanged: {
    if (dataweather.length > 3) {
      lastUpdate = new Date()
      dataChanged();
    }
  }

  // Apply new fetched values after update cycle
  onNewValuesWeatherChanged: {
    if (newValuesWeather.length > 3) {
        dataweather = newValuesWeather;
        newValuesWeather = "0";
    }
  }

  // Retry getting coordinates if missing
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

  // Retry getting city name on failure
  Timer {
    id: retrycity
    interval: 6000
    running: false
    repeat: false
    onTriggered: {
      if (city === "unk" && retrysCity < 5) {
        retrysCity = retrysCity + 1
        getCityFunction();
      }
    }
  }

  // Retry fetching weather data if missing
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

  // Timer for frequent automatic weather and icon updates
  Timer {
    id: weatherUpdateTimer
    running: false
    repeat: true
    interval: 1000 // 1 minute

    property int lastMinuteUpdated: -1

    onTriggered: {
      const now = new Date();
      const currentMinute = now.getMinutes();
      const currentHour = now.getHours();

      if (currentMinute === lastMinuteUpdated) return;
      lastMinuteUpdated = currentMinute;

      console.log("Weather update triggered");

      if (dataweather && dataweather !== "0") {
        updateWeather(2);

        //day and night UI updates
        determinateDay.fetchSunData();

        // total minutes since midnight
        const currentMinutesTotal = currentHour * 60 + currentMinute;

        // exact day/night using sunrise/sunset
        const isDayNow = (currentMinutesTotal >= determinateDay.sunrise &&
        currentMinutesTotal < determinateDay.sunset);

        // update only if day/night changed
        root.isDay = isDayNow;
        root.leftPanelColor = isDayNow ? root.dayColor : root.nightColor;

        // update current weather icon
        const currentCode = safeInt(dataweather, 16);
        iconCurrent = assignIcon(currentCode, isDayNow);

        console.log("Day/night status updated:", isDayNow ? "Day" : "Night");
        console.log("Updated left panel to:",root.leftPanelColor === root.dayColor ? "dayColor" : "nightColor");
        console.log("Current icon:", iconCurrent);

        // Current weather
        tempCurrent = temperature(safeInt(dataweather, 1));
        console.log("Updated current temperature:", tempCurrent);

        // Compute next forecast hours before emitting sync
        const forecastHoursArr = [];
        const nextHour = (now.getMinutes() === 0 ? currentHour : currentHour + 1) % 24;
        for (let i = 0; i < 5; i++) {
          forecastHoursArr.push((nextHour + i) % 24);
        }

        nextHours = forecastHoursArr;

        // Log formatted hours
        const formattedHours = forecastHoursArr.map(hour => {
          if (timeFormat === 12) {
            const h = hour % 12;
            return (h === 0 ? 12 : h) + (hour < 12 ? " AM" : " PM");
          } else {
            return hour.toString().padStart(2, "0");
          }
        });
        console.log("Next forecast hours:", formattedHours.join(", "));

        // Hourly forecast
        iconHours = [];
        tempHours = [];

        for (let i = 0; i < 5; i++) {
          const forecastTime = new Date(now.getTime());
          forecastTime.setHours(currentHour + i + 1, 0, 0, 0);

          const temp = safeInt(dataweather, 17 + i);
          const code = safeInt(dataweather, 22 + i);
          const isDayAtTime = determinateDay.isDayForHour(forecastTime.getHours());

          tempHours.push(temperature(temp));
          iconHours.push(assignIcon(code, isDayAtTime) || "weather-unknown");

          console.log(`Hourly data +${i + 1}h => temp=${tempHours[i]}, icon=${iconHours[i]}`);
        }

        // Temperatures for coming days
        oneMin: temperature(safeInt(dataweather, 2))
        twoMin: temperature(safeInt(dataweather, 3))
        threeMin: temperature(safeInt(dataweather, 4))
        fourMin: temperature(safeInt(dataweather, 5))
        fiveMin: temperature(safeInt(dataweather, 6))
        sixMin: temperature(safeInt(dataweather, 7))
        sevenMin: temperature(safeInt(dataweather, 8))
        oneMax: temperature(safeInt(dataweather, 9))
        twoMax: temperature(safeInt(dataweather, 10))
        threeMax: temperature(safeInt(dataweather, 11))
        fourMax: temperature(safeInt(dataweather, 12))
        fiveMax: temperature(safeInt(dataweather, 13))
        sixMax: temperature(safeInt(dataweather, 14))
        sevenMax: temperature(safeInt(dataweather, 15))

        // Actual daily temperature shown
        mintempToday = temperature(safeInt(dataweather, 2));
        maxtempToday = temperature(safeInt(dataweather, 9));
        mintempTomorrow = temperature(safeInt(dataweather, 3));
        maxtempTomorrow = temperature(safeInt(dataweather, 10));
        mintempDayAftertomorrow = temperature(safeInt(dataweather, 4));
        maxtempDayAftertomorrow = temperature(safeInt(dataweather, 11));
        mintempTwoDaysAfterTomorrow = temperature(safeInt(dataweather, 5));
        maxtempTwoDaysAfterTomorrow = temperature(safeInt(dataweather, 12));

        console.log(
          `Updated daily min/max for today: ${mintempToday}/${maxtempToday}`);
        console.log(
          `Updated daily min/max for tomorrow: ${mintempTomorrow}/${maxtempTomorrow}`);
        console.log(
          `Updated daily min/max for day after tomorrow: ${mintempDayAftertomorrow}/${maxtempDayAftertomorrow}`);

        // Weather codes for coming days
        oneIcon = assignIcon(safeInt(dataweather, 27), true);
        twoIcon = assignIcon(safeInt(dataweather, 28), true);
        threeIcon = assignIcon(safeInt(dataweather, 29), true);
        fourIcon = assignIcon(safeInt(dataweather, 30), true);
        fiveIcon = assignIcon(safeInt(dataweather, 31), true);
        sixIcon = assignIcon(safeInt(dataweather, 32), true);
        sevenIcon = assignIcon(safeInt(dataweather, 33), true);

        // Actual daily icons shown
        codeweatherTomorrow = safeString(dataweather, 28);
        codeweatherDayAftertomorrow = safeString(dataweather, 29);
        codeweatherTwoDaysAfterTomorrow = safeString(dataweather, 30);


        console.log(
          `Updated daily icon for tomorrow: ${assignIcon(safeInt(dataweather, 28), true)}`);
        console.log(
          `Updated daily icon for day after tomorrow: ${assignIcon(safeInt(dataweather, 29), true)}`);
        console.log(
          `Updated daily icon for two days after tomorrow: ${assignIcon(safeInt(dataweather, 30), true)}`);

        // signal to main.qml for sync
        weatherSynced()

      } else {
        console.warn("Weather update skipped: no dataweather available");
      }
    }
  }

  // Trigger when current weather changes
  onDataweatherChanged: {
    if (isWeatherReady() && !weatherUpdateTimer.running) {
      console.log("Weather and forecast ready, starting timer");
      weatherUpdateTimer.start();
    }
  }

  // When coordinates change, run full update
  onUseCoordinatesIpChanged: {
    if (active) {
      updateWeather(1);
      isInExecution = true
    }
  }

  // update apiModel if weather model changes
  onWeatherModelChanged: {
    getWeatherApi()
  }

  // Recalculate displayed temperature when unit preference changes
  onTemperatureUnitChanged: {
    if (dataweather && dataweather !== "0") {
      // Update current temperature
      tempCurrent = temperature(safeInt(dataweather, 1));

      // Recalculate min/max for current day
      mintempToday = temperature(safeInt(dataweather, 2));
      maxtempToday = temperature(safeInt(dataweather, 9));

      // Recalculate hourly temperatures
      const words = dataweather.split(/\s+/);
      tempHours = [];
      for (let i = 0; i < 5; i++) {
        let temp = safeInt(dataweather, 17 + i);
        tempHours.push(temperature(temp));
      }
    }
  }
}
