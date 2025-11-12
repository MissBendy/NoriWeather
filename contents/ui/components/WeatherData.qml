import QtQuick 2.15
import QtQuick.Controls 2.15
import "../js/translator.js" as Translate
import "../js/GetWeather.js" as GetInfoApi
import "../js/geoCoordinates.js" as GeoCoordinates
import "../js/GetCity.js" as GetCity

Item {
  id: root
  signal dataChanged
  signal simpleDataReady

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
  property color leftPanelColor: isDay ? dayColor : nightColor

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

  // Determine final coordinates (manual or IP-based)
  property string latitude: (useCoordinatesIp === "true") ? latitudeIP : (latitudeC === "0") ? latitudeIP : latitudeC
  property string longitud: (useCoordinatesIp === "true") ? longitudIP : (longitudeC === "0") ? longitudIP : longitudeC
  property var observerCoordenates: latitude + longitud

  // Track current local hour for display
  property int currentTime: Number(Qt.formatDateTime(new Date(), "h"))

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
  property string minweatherCurrent: "?"
  property string maxweatherCurrent: "?"
  property string minweatherTomorrow: "?"
  property string maxweatherTomorrow: "?"
  property string minweatherDayAftertomorrow: "?"
  property string maxweatherDayAftertomorrow: "?"
  property string minweatherTwoDaysAfterTomorrow: "?"
  property string maxweatherTwoDaysAfterTomorrow: "?"

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
  property string weatherLongtext: i18n(textWeather(codeweatherCurrent))
  property string weatherShottext: i18n(shortTextWeather(codeweatherCurrent))
  // Coordinate handling from IP lookup
  property string completeCoordinates: ""
  property string oldCompleteCoordinates: "1"
  property string latitudeIP: completeCoordinates.substring(0, (completeCoordinates.indexOf(' ')) - 1)
  property string longitudIP: completeCoordinates.substring(completeCoordinates.indexOf(' ') + 1)
  // Day/night state and city name
  property bool isDay: determinateDay.isDayForHour(new Date().getHours())
  property string city: "unk"
  property string prefixIcon: determinateDay.isDayForHour(new Date().getHours()) ? "" : "-night"

  // Initialize component
  Component.onCompleted: {
    updateWeather(1); // initial fetch of weather and coordinates
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
      updateWeather(2);
      getCityFunction();
    } else {
      // console.warn("Invalid coordinates, retrying...");
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
      retrycity.start();
    });
  }

  // Fetch current weather data
  function getWeatherApi() {
    GetInfoApi.getWeatherData(latitude, longitud, 5, function(result) { // '5' = next 5 hours
      if (isUpdate) newValuesWeather = result;
      else dataweather = result;

      const now = new Date();
      const currentHour = now.getHours();
      const isDayNow = determinateDay.isDayForHour(currentHour);

      // Current temperature and weather code
      tempCurrent = temperature(safeInt(dataweather, 1));
      iconCurrent = assignIcon(safeInt(dataweather, 16), isDayNow);
      // Daily temperatures min/max
      minweatherCurrent = temperature(safeInt(dataweather, 2));
      maxweatherCurrent = temperature(safeInt(dataweather, 9));
      minweatherTomorrow = temperature(safeInt(dataweather, 3));
      maxweatherTomorrow = temperature(safeInt(dataweather, 10));
      minweatherDayAftertomorrow = temperature(safeInt(dataweather, 4));
      maxweatherDayAftertomorrow = temperature(safeInt(dataweather, 11));
      minweatherTwoDaysAfterTomorrow = temperature(safeInt(dataweather, 5));
      maxweatherTwoDaysAfterTomorrow = temperature(safeInt(dataweather, 12));
      // Daily weather icons
      codeweatherCurrent = safeString(dataweather, 16)
      codeweatherTomorrow = safeString(dataweather, 28);
      codeweatherDayAftertomorrow = safeString(dataweather, 29);
      codeweatherTwoDaysAfterTomorrow = safeString(dataweather, 30);

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

      // Update UI panel colors and day/night state
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

  // Detailed text for weather condition
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

  // Short label for weather condition
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

  // Main weather update logic
  function updateWeather(x) {
    if (x === 1) {
      if (useCoordinatesIp === "true") {
        getCoordinatesWithIp();
      } else {
        if (latitudeC === "0" || longitudC === "0") {
          getCoordinatesWithIp();
        } else {
          getWeatherApi()
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
    interval: 1000

    property int lastMinuteUpdated: -1
    property int lastHourUpdated: -1

    onTriggered: {
      const timeInfo = getCurrentTimeInfo();
      const { now, currentMinute, currentHour } = timeInfo;

      let hourUpdatedThisCycle = false;

      // Hourly update
      if (currentHour !== lastHourUpdated) {
        lastHourUpdated = currentHour;
        hourUpdatedThisCycle = true;
        console.log("Full weather data update triggered");
        updateWeather(2);

        iconHours = [];
        tempHours = [];

        if (dataweather && dataweather !== "0") {
          console.log("Updating weather forecast...");

          for (let i = 0; i < 5; i++) {
            const forecastTime = new Date(now.getTime());
            forecastTime.setHours(currentHour + i + 1, 0, 0, 0);

            const temp = safeInt(dataweather, 17 + i);
            const code = safeInt(dataweather, 22 + i);
            const isDayAtTime = determinateDay.isDayForHour(forecastTime.getHours());

            tempHours.push(temperature(temp));
            iconHours.push(assignIcon(code, isDayAtTime) || "weather-unknown");

            console.log(
              `Hourly data +${i + 1}h => temp=${tempHours[i]}, icon=${iconHours[i]}`);
          }

          // Daily temperature updates
          minweatherCurrent = temperature(safeInt(dataweather, 2));
          maxweatherCurrent = temperature(safeInt(dataweather, 9));
          minweatherTomorrow = temperature(safeInt(dataweather, 3));
          maxweatherTomorrow = temperature(safeInt(dataweather, 10));
          minweatherDayAftertomorrow = temperature(safeInt(dataweather, 4));
          maxweatherDayAftertomorrow = temperature(safeInt(dataweather, 11));
          minweatherTwoDaysAfterTomorrow = temperature(safeInt(dataweather, 5));
          maxweatherTwoDaysAfterTomorrow = temperature(safeInt(dataweather, 12));

          console.log(
            `Updated daily min/max for today: ${minweatherCurrent}/${maxweatherCurrent}`);
          console.log(
            `Updated daily min/max for tomorrow: ${minweatherTomorrow}/${maxweatherTomorrow}`);
          console.log(
            `Updated daily min/max for day after tomorrow: ${minweatherDayAftertomorrow}/${maxweatherDayAftertomorrow}`);

          // Weather codes for coming days
          codeweatherTomorrow = safeString(dataweather, 28);
          codeweatherDayAftertomorrow = safeString(dataweather, 29);
          codeweatherTwoDaysAfterTomorrow = safeString(dataweather, 30);

          console.log(
            `Updated forecast icon for tomorrow: ${assignIcon(safeInt(dataweather, 28), true)}`);
          console.log(
            `Updated forecast icon for day after tomorrow: ${assignIcon(safeInt(dataweather, 29), true)}`);
          console.log(
            `Updated forecast icon for two days after tomorrow: ${assignIcon(safeInt(dataweather, 30), true)}`);
        } else {
          console.warn("Forecast update skipped: dataweather unavailable");
        }
      }

      // Minute refresh (skip weather fetch if hour just refreshed)
      if (currentMinute !== lastMinuteUpdated) {
        lastMinuteUpdated = currentMinute;

        if (!hourUpdatedThisCycle) {
          console.log("Current weather update triggered");
          updateWeather(2);
        } else {
          console.log("Current weather refresh skipped, already updated");
        }

        if (dataweather && dataweather !== "0") {
          tempCurrent = temperature(safeInt(dataweather, 1));
          console.log("Updated current temperature:", tempCurrent);

          determinateDay.fetchSunData();

          const now = new Date();
          const currentHour = now.getHours();
          const isDayNow = determinateDay.isDayForHour(currentHour);
          console.log("Checking day/night status:", isDayNow ? "Day" : "Night");

          const currentCode = safeInt(dataweather, 16);
          iconCurrent = assignIcon(currentCode, isDayNow);
          console.log("Updated current icon to:", iconCurrent);

          root.isDay = isDayNow;
          root.leftPanelColor = isDayNow ? root.dayColor : root.nightColor;
          console.log(
            "Updated left panel to:",
            root.leftPanelColor === root.dayColor ? "dayColor" : "nightColor"
          );
        } else {
          console.warn("Current weather update skipped: no dataweather available");
        }
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

  // Recalculate displayed temperature when unit preference changes
  onTemperatureUnitChanged: {
    if (dataweather && dataweather !== "0") {
      // Update current temperature
      tempCurrent = temperature(safeInt(dataweather, 1));

      // Recalculate min/max for current day
      minweatherCurrent = temperature(safeInt(dataweather, 2));
      maxweatherCurrent = temperature(safeInt(dataweather, 9));

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
