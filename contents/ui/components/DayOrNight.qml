import QtQuick

Item {
    property string latitud
    property string longitud
    readonly property bool fullCoordinates: latitud !== "" && longitud !== ""

    property int sunrise: 0
    property int sunset: 0
    property bool isday: true

    // -------------------
    // Time format
    // -------------------
    property int timeFormat: plasmoid.configuration.timeFormat  // 12 or 24
    property string sunriseText: minutesToTimeString(sunrise)
    property string sunsetText: minutesToTimeString(sunset)

    signal update

    // -------------------
    // Cache
    // -------------------
    property string cacheDate: ""
    property int cacheSunrise: 0
    property int cacheSunset: 0
    property string cacheLat: ""
    property string cacheLng: ""
    property var lastFetchTime: new Date(0)

    Timer {
        id: delayFetchTimer
        interval: 50
        repeat: false
        onTriggered: {
            if (fullCoordinates) fetchSunData()
        }
    }

    Timer {
        id: twoHourTimer
        interval: 2 * 60 * 60 * 1000
        running: true
        repeat: true
        onTriggered: fetchSunData
    }

    // Convert UTC ISO string to local minutes since midnight
    function minutesOfDayUTCtoLocal(dateStr) {
        var d = new Date(dateStr)            // UTC
        var minutesUTC = d.getUTCHours() * 60 + d.getUTCMinutes()
        var offset = d.getTimezoneOffset()   // minutes behind UTC
        var localMinutes = minutesUTC - offset
        if (localMinutes < 0) localMinutes += 1440
            if (localMinutes >= 1440) localMinutes -= 1440
                return localMinutes
    }

    function apiUrl() {
        var today = new Date().toISOString().slice(0, 10)
        return "https://api.sunrise-sunset.org/json?lat=" + latitud +
        "&lng=" + longitud +
        "&date=" + today +
        "&formatted=0" // UTC times
    }

    function fetchSunData() {
        if (!fullCoordinates) return

            var now = new Date()
            var todayStr = now.toISOString().slice(0,10)

            if (cacheLat === latitud && cacheLng === longitud && cacheDate === todayStr && (now - lastFetchTime) < 2*60*60*1000) {
                sunrise = cacheSunrise
                sunset  = cacheSunset
                updateDayStatus()
                console.log("Using cached sunrise/sunset:", sunriseText, sunsetText)
                return
            }

            var xhr = new XMLHttpRequest()
            xhr.open("GET", apiUrl(), true)
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    if (response.status === "OK") {
                        sunrise = minutesOfDayUTCtoLocal(response.results.sunrise)
                        sunset  = minutesOfDayUTCtoLocal(response.results.sunset)

                        // Handle sunsets past midnight
                        if (sunset < sunrise) sunset += 1440

                            // Store in cache
                            cacheLat = latitud
                            cacheLng = longitud
                            cacheDate = todayStr
                            cacheSunrise = sunrise
                            cacheSunset = sunset
                            lastFetchTime = new Date()

                            updateDayStatus()
                            console.log("Fetched sunrise/sunset:", sunriseText, sunsetText)
                    } else {
                        console.log("Sun API error:", response.status)
                    }
                }
            }
            xhr.onerror = function() {
                console.log("Network error fetching sun data")
            }
            xhr.send()
    }

    function updateDayStatus() {
        var now = new Date()
        var localMinutesNow = now.getHours() * 60 + now.getMinutes()
        var adjustedNow = localMinutesNow
        if (localMinutesNow < sunrise && now.getHours() < 3) adjustedNow += 1440
            isday = adjustedNow >= sunrise && adjustedNow < sunset
    }

    function isDayForHour(hour) {
        if (sunrise === 0 && sunset === 0) return true
            var minutes = hour * 60
            var adjSunset = sunset
            if (sunset < sunrise) adjSunset += 1440
                return minutes >= sunrise && minutes < adjSunset
    }

    function minutesToTimeString(minutes) {
        var hours = Math.floor(minutes / 60)
        var mins = minutes % 60

        if (timeFormat === 12) {
            var suffix = hours >= 12 ? "PM" : "AM"
            var displayHour = hours % 12
            if (displayHour === 0) displayHour = 12
                return displayHour + ":" + (mins < 10 ? "0" + mins : mins) + " " + suffix
        } else { // 24-hour
            return (hours < 10 ? "0" + hours : hours) + ":" + (mins < 10 ? "0" + mins : mins)
        }
    }

    // Update formatted strings when values or time format change
    onSunriseChanged: sunriseText = minutesToTimeString(sunrise)
    onSunsetChanged:  sunsetText  = minutesToTimeString(sunset)
    onTimeFormatChanged: {
        sunriseText = minutesToTimeString(sunrise)
        sunsetText  = minutesToTimeString(sunset)
    }

    onLatitudChanged: delayFetchTimer.restart()
    onLongitudChanged: delayFetchTimer.restart()
    onUpdate: {
        if (fullCoordinates) fetchSunData()
    }
}
