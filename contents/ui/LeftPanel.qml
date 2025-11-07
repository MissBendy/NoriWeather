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

                // ensure nextEventTime is in the future
                if (nextEventTime <= now) {
                    nextEventTime = new Date(nextEventTime.getTime() + 24*60*60*1000)
                }

                let interval = nextEventTime - now
                if (interval < 0) interval = 0

                    nextEventTimer.interval = interval
                    nextEventTimer.start()
        }
    }

    Component.onCompleted: {
        GeoCoordinates.obtenerCoordenadas(function(result) {
            const coords = result.split(" ")
            latitude = coords[0]
            longitude = coords[1]

            if (latitude && longitude) {
                determinateDay.update() // fetch sunrise/sunset and compute isDay
            }
        })
    }

    Timer {
        id: nextEventTimer
        running: false
        repeat: false
        onTriggered: determinateDay.update() // recompute day/night at sunrise/sunset
    }
}
