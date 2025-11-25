// Simple QML item containing a Card component with dynamic left margin and color
import QtQuick
import "components"

Item {
    id: root

    // Property reflecting the left margin of the Card
    property int marginLeftReal: card.marginLeft

    // Card component filling the parent, with dynamic left panel color
    Card {
        id: card
        leftColor: weatherData.leftPanelColor
        width: parent.width
        height: parent.height
    }
}
