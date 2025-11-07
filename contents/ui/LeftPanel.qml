import QtQuick
import "js/geoCoordinates.js" as GeoCoordinates
import "components" as Components

Item {
    id: root

    property color dayColor: "#3DAAE4"
    property color nightColor: "#0D1B2A"
    property color leftPanelColor: dayColor
    property string latitude: ""
    property string longitude: ""
    property bool previousIsDay: false
    property int marginLeftReal: card.marginLeft

    Card {
        id: card
        leftColor: root.leftPanelColor
        width: parent.width
        height: parent.height
    }

    Components.DayOrNight {
        id: determinateDay
        latitud: root.latitude
        longitud: root.longitude

        onIsdayChanged: {
            root.leftPanelColor = isday ? dayColor : nightColor
            if (isday !== previousIsDay) {
                previousIsDay = isday
                console.log("DayOrNight:", isday ? "Day" : "Night")
            }
            scheduleNextEvent()
        }

        function scheduleNextEvent() {
            if (!(sunrise && sunset)) return

                let now = new Date()
                let nextEventTime = isday ? new Date(sunset) : new Date(sunrise)

                if (nextEventTime <= now)
                    nextEventTime = new Date(nextEventTime.getTime() + 24 * 60 * 60 * 1000)

                    let interval = Math.max(0, nextEventTime - now)
                    nextEventTimer.interval = interval
                    nextEventTimer.start()
        }
    }

    function refreshDayState() {
        determinateDay.update()
        root.leftPanelColor = determinateDay.isday ? dayColor : nightColor
    }

    Component.onCompleted: {
        GeoCoordinates.obtenerCoordenadas(function(result) {
            const coords = result.split(" ")
            latitude = coords[0]
            longitude = coords[1]
            if (latitude && longitude) {
                determinateDay.update()
                refreshDayState()
                hourlySync.start()
                hourCheck.start()
            }
        })
    }

    // Fires at sunrise/sunset
    Timer {
        id: nextEventTimer
        running: false
        repeat: false
        onTriggered: determinateDay.update()
    }

    // Refresh one second after each new hour
    Timer {
        id: hourlySync
        interval: 0
        running: true
        repeat: true
        onTriggered: {
            refreshDayState()
            let now = new Date()
            let nextHour = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours() + 1, 0, 1)
            interval = nextHour - now
            start()
        }
    }

    // Detects hour rollover in case of clock drift or lag
    Timer {
        id: hourCheck
        interval: 10000
        running: true
        repeat: true
        property int lastHour: new Date().getHours()
        onTriggered: {
            const currentHour = new Date().getHours()
            if (currentHour !== lastHour) {
                lastHour = currentHour
                Qt.callLater(() => refreshDayState())
            }
        }
    }
}
