import QtQuick

Item {
    property string latitud
    property string longitud
    readonly property bool fullCoordinates: latitud !== "" && longitud !== ""

    // Will hold sunrise/sunset in minutes
    property int sunrise: 0
    property int sunset: 0
    property bool isday: true

    property string apiUrlFinal: "https://api.sunrise-sunset.org/json?lat=" + latitud + "&lng=" + longitud + "&formatted=0"

    signal update

    Timer {
        id: delayFetchTimer
        interval: 50
        repeat: false
        onTriggered: {
            if (fullCoordinates) fetchSunData(apiUrlFinal)
        }
    }

    Timer {
        id: retryUpdate
        interval: 12000
        running: true
        repeat: true
        onTriggered: fetchSunData(apiUrlFinal)
    }

    function minutesOfDayLocal(dateStr) {
        var d = new Date(dateStr)
        return d.getHours() * 60 + d.getMinutes()  // local timezone
    }

    function fetchSunData(url) {
        retryUpdate.stop()
        var now = new Date()
        var localMinutesNow = now.getHours() * 60 + now.getMinutes()

        var xhr = new XMLHttpRequest()
        xhr.open("GET", url, true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText)
                if (response.status === "OK") {
                    sunrise = minutesOfDayLocal(response.results.sunrise)
                    sunset  = minutesOfDayLocal(response.results.sunset)

                    if (sunset < sunrise) sunset += 1440

                        var adjustedNow = localMinutesNow
                        if (localMinutesNow < sunrise && now.getHours() < 3) adjustedNow += 1440

                            isday = adjustedNow >= sunrise && adjustedNow < sunset
                            console.log("Local time minutes:", adjustedNow,
                                        "Sunrise:", sunrise,
                                        "Sunset:", sunset,
                                        "isDay:", isday)
                } else {
                    console.log("Sun API error:", response.status)
                }
            }
        }
        xhr.send()
    }

    function isDayForHour(hour) {
        // hour in 0..23
        if (sunrise === 0 && sunset === 0) return true  // fallback if data not loaded
            var minutes = hour * 60
            var adjSunset = sunset
            if (sunset < sunrise) adjSunset += 1440
                return minutes >= sunrise && minutes < adjSunset
    }

    onLatitudChanged: delayFetchTimer.restart()
    onLongitudChanged: delayFetchTimer.restart()

    onUpdate: {
        if (fullCoordinates) fetchSunData(apiUrlFinal)
            else retryUpdate.start()
    }
}
