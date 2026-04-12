// QML configuration panel for weather plasmoid settings
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import Qt.labs.platform as Platform

Item {
    id: root

    signal configurationChanged

    QtObject { id: unitWeatherValue; property var value }
    QtObject { id: timeFormatValue; property var value }
    QtObject { id: weatherModel; property var value }

    QtObject {
        id: fontFamilyValue
        property string value: ""
    }

    QtObject {
        id: fontsizeValue
        property var value: Qt.application.font.pointSize
    }

    QtObject {
        id: fontWeightValue
        property var value: Qt.application.font.weight
    }

    property alias cfg_coordinatesIP: coordinatesIP.checked
    property alias cfg_displayWeatherInPanel: displayWeather.checked
    property alias cfg_manualLatitude: latitude.text
    property alias cfg_manualLongitude: longitude.text
    property alias cfg_temperatureUnit: unitWeatherValue.value
    property alias cfg_weatherModel: weatherModel.value
    property alias cfg_timeFormat: timeFormatValue.value
    property alias cfg_sizeFontConfig: fontsizeValue.value
    property alias cfg_fontFamily: fontFamilyValue.value
    property alias cfg_fontWeight: fontWeightValue.value

    Platform.FontDialog {
        id: fontDialog
        title: i18n("Choose a Font")
        modality: Qt.WindowModal
        parentWindow: root.Window.window

        property font fontChosen: Qt.font({
            family: fontFamilyValue.value !== ""
            ? fontFamilyValue.value
            : Qt.application.font.family,
            pointSize: fontsizeValue.value > 0
            ? fontsizeValue.value
            : Qt.application.font.pointSize,
            weight: fontWeightValue.value > 0
            ? fontWeightValue.value
            : Qt.application.font.weight
        })

        onAccepted: {
            fontFamilyValue.value = font.family
            fontsizeValue.value = font.pointSize
            fontWeightValue.value = font.weight
            root.configurationChanged()
        }
    }

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing

        GridLayout {
            id: settingsGrid
            columns: 2
            Layout.fillWidth: true

            Label {
                text: i18n("Use geographical coordinates from the IP") + ":"
                Layout.minimumWidth: root.width / 2
                horizontalAlignment: Text.AlignRight
            }
            CheckBox { id: coordinatesIP }

            Label {
                text: i18n("Latitude") + ":"
                Layout.minimumWidth: root.width / 2
                horizontalAlignment: Text.AlignRight
                visible: !coordinatesIP.checked
            }
            TextField {
                id: latitude
                visible: !coordinatesIP.checked
                width: 110
            }

            Label {
                text: i18n("Longitude") + ":"
                Layout.minimumWidth: root.width / 2
                horizontalAlignment: Text.AlignRight
                visible: !coordinatesIP.checked
            }
            TextField {
                id: longitude
                visible: !coordinatesIP.checked
                width: 110
            }

            Label {
                text: i18n("Display weather conditions on the panel") + ":"
                Layout.minimumWidth: root.width / 2
                horizontalAlignment: Text.AlignRight
            }
            CheckBox { id: displayWeather }

            Label {
                text: i18n("Time format") + ":"
                Layout.minimumWidth: root.width / 2
                horizontalAlignment: Text.AlignRight
            }
            ComboBox {
                id: timeFormatComboBox
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: i18n("12-hour"), value: 12 },
                    { text: i18n("24-hour"), value: 24 }
                ]
                onActivated: timeFormatValue.value = currentValue
                Component.onCompleted: currentIndex = indexOfValue(timeFormatValue.value)
            }

            Label {
                text: i18n("Temperature unit") + ":"
                Layout.minimumWidth: root.width / 2
                horizontalAlignment: Text.AlignRight
            }
            ComboBox {
                id: unitComboBox
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: i18n("Celsius (°C)"), value: 0 },
                    { text: i18n("Fahrenheit (°F)"), value: 1 }
                ]
                onActivated: unitWeatherValue.value = currentValue
                Component.onCompleted: currentIndex = indexOfValue(unitWeatherValue.value)
            }

            Label {
                text: i18n("Weather Model") + ":"
                Layout.minimumWidth: root.width / 2
                horizontalAlignment: Text.AlignRight
            }
            ComboBox {
                id: weatherModelComboBox
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: i18n("Best Match"), value: 1 },
                    { text: i18n("ECMWF IFS 0.25°"), value: 2 },
                    { text: i18n("ECMWF IFS HRES 9km"), value: 3 },
                    { text: i18n("NCEP GFS Seamless"), value: 4 },
                    { text: i18n("NCEP GFS Global 0.11°/0.25°"), value: 5 },
                    { text: i18n("NCEP NBM U.S. Conus"), value: 6 },
                    { text: i18n("UK Met Office Seamless"), value: 7 },
                    { text: i18n("UK Met Office Global 10km"), value: 8 }
                ]
                onActivated: weatherModel.value = currentValue
                Component.onCompleted: currentIndex = indexOfValue(weatherModel.value)
            }

            Label {
                text: i18n("Font") + ":"
                Layout.minimumWidth: root.width / 2
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignTop
                Layout.alignment: Qt.AlignTop
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Button {
                        text: i18n("Choose Style…")
                        icon.name: "settings-configure"
                        onClicked: {
                            fontDialog.fontChosen = Qt.font({
                                family: fontFamilyValue.value !== ""
                                ? fontFamilyValue.value
                                : Qt.application.font.family,
                                pointSize: fontsizeValue.value > 0
                                ? fontsizeValue.value
                                : Qt.application.font.pointSize,
                                weight: fontWeightValue.value > 0
                                ? fontWeightValue.value
                                : Qt.application.font.weight
                            })

                            fontDialog.currentFont = fontDialog.fontChosen
                            fontDialog.open()
                        }
                    }

                    Button {
                        text: i18n("Reset")
                        enabled: fontFamilyValue.value !== ""
                        || fontsizeValue.value !== Qt.application.font.pointSize
                        || fontWeightValue.value !== Qt.application.font.weight

                        onClicked: {
                            fontFamilyValue.value = ""
                            fontsizeValue.value = Qt.application.font.pointSize
                            fontWeightValue.value = Qt.application.font.weight
                            root.configurationChanged()
                        }
                    }
                }

                Label {
                    text: {
                        const fam = fontFamilyValue.value !== ""
                        ? fontFamilyValue.value
                        : Qt.application.font.family

                        const sz = fontsizeValue.value > 0
                        ? fontsizeValue.value
                        : Qt.application.font.pointSize

                        return i18n("%1pt %2", sz, fam)
                    }

                    textFormat: Text.PlainText

                    font.family: fontFamilyValue.value !== ""
                    ? fontFamilyValue.value
                    : Qt.application.font.family

                    font.pointSize: fontsizeValue.value > 0
                    ? fontsizeValue.value
                    : Qt.application.font.pointSize

                    font.weight: fontWeightValue.value > 0
                    ? fontWeightValue.value
                    : Qt.application.font.weight

                    wrapMode: Text.Wrap
                }

                Label {
                    text: i18n("Note: size may be reduced if the panel is not thick enough.")
                    font: Kirigami.Theme.smallFont
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    // Bottom-pinned note (OUTSIDE ColumnLayout)
    Label {
        id: bottomNote
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Kirigami.Units.largeSpacing

        wrapMode: Text.WordWrap
        text: i18n("Note:\nThe default weather model 'Best Match' provides the best forecast for any given location worldwide.\nSeamless combines all models from a given provider into a seamless prediction.")

        font.italic: true
        horizontalAlignment: Text.AlignLeft
    }
}
