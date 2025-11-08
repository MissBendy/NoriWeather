import QtQuick
import "components"

Item {
    id: root

    property int marginLeftReal: card.marginLeft

    Card {
        id: card
        leftColor: weatherData.leftPanelColor
        width: parent.width
        height: parent.height
    }
}
