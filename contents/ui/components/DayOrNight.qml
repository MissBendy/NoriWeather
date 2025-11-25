import QtQuick

Item {
    // Geographic coordinates
    property string latitud
    property string longitud
    // True only when both latitude and longitude are provided
    readonly property bool fullCoordinates: latitud !== "" && longitud !== ""
    // Sunrise and sunset times (in minutes since midnight, local)
    property int sunrise: 0
    property int sunset: 0
    // Indicates whether it's currently daytime
    property bool isday: true
    // Time display format (12-hour or 24-hour)
    property int timeFormat: plasmoid.configuration.timeFormat
    // Formatted sunrise time as text based on timeFormat
    property string sunriseText: minutesToTimeString(sunrise)
    property string sunsetText: minutesToTimeString(sunset)

    signal update

    // Cache
    property string cacheDate: ""
    property int cacheSunrise: 0
    property int cacheSunset: 0
    property string cacheLat: ""
    property string cacheLng: ""
    property var lastFetchTime: new Date(0)

    // Delay fetching sun data
    Timer {
        id: delayFetchTimer
        interval: 50
        repeat: false
        onTriggered: {
            if (fullCoordinates) fetchSunData()
        }
    }

    // Run new fetch every two hours
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

    // Build request URL for today's sunrise/sunset data
    function apiUrl() {
        var today = new Date().toISOString().slice(0, 10)
        var url = "https://api.sunrise-sunset.org/json?lat=" + latitud +
        "&lng=" + longitud +
        "&date=" + today +
        "&formatted=0" // UTC times
        // console.log("Generated Sun Data URL:", url) Debug: confirm generated URL
        return url
    }

    // Fetch and update sunrise/sunset times using external API
    function fetchSunData() {
        if (!fullCoordinates) return

            var now = new Date()
            var todayStr = now.toISOString().slice(0,10)

            // Check if cached data is still valid
            if (cacheLat === latitud && cacheLng === longitud && cacheDate === todayStr && (now - lastFetchTime) < 2*60*60*1000) {
                sunrise = cacheSunrise
                sunset  = cacheSunset
                updateDayStatus()
                console.log("Using cached sunrise/sunset:", sunriseText, sunsetText)
                return
            }

            // Request fresh data from API
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

    // Determine whether it's currently day or night
    function updateDayStatus() {
        var now = new Date()
        var localMinutesNow = now.getHours() * 60 + now.getMinutes()
        var adjSunset = sunset
        if (sunset < sunrise)
            adjSunset += 1440

            isday = localMinutesNow >= sunrise && localMinutesNow < adjSunset
    }


    // Check if a given hour (0–23) is during daytime
    function isDayForHour(hour) {
        if (sunrise === 0 && sunset === 0) return true
            var minutes = hour * 60
            var adjSunset = sunset
            if (sunset < sunrise) adjSunset += 1440
                return minutes >= sunrise && minutes < adjSunset
    }

    // Convert minutes to readable time string (12h/24h format)
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

    // Refetch data when coordinates change
    onLatitudChanged: delayFetchTimer.restart()
    onLongitudChanged: delayFetchTimer.restart()

    // Manual update trigger
    onUpdate: {
        if (fullCoordinates) fetchSunData()
    }
}
