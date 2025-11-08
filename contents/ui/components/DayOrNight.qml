import QtQuick

Item {
    property string latitud
    property string longitud
    readonly property bool fullCoordinates: latitud !== "" && longitud !== ""

    property int sunrise: 0
    property int sunset: 0
    property bool isday: true

    property string apiUrlFinal: "https://api.sunrise-sunset.org/json?lat=" + latitud + "&lng=" + longitud + "&formatted=0"

    signal update

    // -------------------
    // Cache
    // -------------------
    property string cacheDate: ""
    property int cacheSunrise: 0
    property int cacheSunset: 0
    property string cacheLat: ""
    property string cacheLng: ""
    property var lastFetchTime: new Date(0)  // track last fetch timestamp

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
        interval: 2 * 60 * 60 * 1000  // 2 hours in milliseconds
        running: true
        repeat: true
        onTriggered: fetchSunData
    }

    function minutesOfDayLocal(dateStr) {
        var d = new Date(dateStr)
        return d.getHours() * 60 + d.getMinutes()
    }

    function fetchSunData() {
        var now = new Date()
        // Use cache if same location and same day, AND last fetch less than 2 hours ago
        if (cacheLat === latitud && cacheLng === longitud && (now - lastFetchTime) < 2*60*60*1000) {
            sunrise = cacheSunrise
            sunset  = cacheSunset
            updateDayStatus()
            console.log("Using cached sunrise/sunset:", sunrise, sunset)
            return
        }

        var xhr = new XMLHttpRequest()
        xhr.open("GET", apiUrlFinal, true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText)
                if (response.status === "OK") {
                    sunrise = minutesOfDayLocal(response.results.sunrise)
                    sunset  = minutesOfDayLocal(response.results.sunset)

                    if (sunset < sunrise) sunset += 1440

                        // Store in cache
                        cacheLat = latitud
                        cacheLng = longitud
                        cacheSunrise = sunrise
                        cacheSunset = sunset
                        lastFetchTime = new Date()

                        updateDayStatus()
                        console.log("Fetched sunrise/sunset:", sunrise, sunset)
                } else {
                    console.log("Sun API error:", response.status)
                }
            }
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

    onLatitudChanged: delayFetchTimer.restart()
    onLongitudChanged: delayFetchTimer.restart()
    onUpdate: {
        if (fullCoordinates) fetchSunData()
    }
}
