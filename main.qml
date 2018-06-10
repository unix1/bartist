import QtQuick 2.7
import QtQuick.Controls 2.0
import Qt.labs.settings 1.0
import QtQuick.XmlListModel 2.0

ApplicationWindow {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Tabs")

    // BART API configuration
    property string bartApiKey: "MW9S-E7SL-26DU-VV8V"
    property string bartApiUriBase: "https://api.bart.gov/api/"
    property string bartApiUriStations: bartApiUriBase + "stn.aspx?cmd=stns&key=" + bartApiKey
    property string bartApiUriEtd: bartApiUriBase + "etd.aspx?cmd=etd&key=" + bartApiKey
    property string defaultStationCode: "12TH"

    property real margins: 10

    // Used for testing in offline mode, loads data from XML files in test directory
    property bool offline: false

    // TODO add settings
    //Settings {
    //    property alias stationIndex: selectorFrom.stationIndex
    //    property alias stationCode: trainFetcher.stationCode
    //}

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        PageTrainsForm {
            selectorFrom.text: stationFetcher.getStation(selectorFrom.stationIndex)
            selectorFrom.onClicked: {
                console.log("button clicked")
                stationsColumn.visible = true
            }
        }

        PageMapForm {
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton {
            text: qsTr("Trains")
        }
        TabButton {
            text: qsTr("Map")
        }
    }

    XmlListModel {
        id: stationFetcher
        source: root.offline ? "tests/stations.xml" : root.bartApiUriStations
        query: "/root/stations/station"

        XmlRole { name: "name"; query: "name/string()" }
        XmlRole { name: "code"; query: "abbr/string()" }

        function getStation(idx) {
            return (idx >= 0 && idx < count) ? get(idx).name: ""
        }

        function getCode(idx) {
            return (idx >= 0 && idx < count) ? get(idx).code: ""
        }
    }

    XmlListModel {
        id: trainFetcher
        property string stationCode: root.defaultStationCode
        source: root.offline ? "tests/trains.xml"
                             : root.bartApiUriEtd + "&orig=" + stationCode
        query: "/root/station/etd"

        XmlRole { name: "destination"; query: "destination/string()" }
        XmlRole { name: "code"; query: "abbreviation/string()" }
        XmlRole { name: "minutes"; query: "estimate[1]/minutes/string()" }
        XmlRole { name: "length"; query: "estimate[1]/length/string()" }
        XmlRole { name: "minutes2"; query: "estimate[2]/minutes/string()" }
        XmlRole { name: "length2"; query: "estimate[2]/length/string()" }
        XmlRole { name: "minutes3"; query: "estimate[3]/minutes/string()" }
        XmlRole { name: "length3"; query: "estimate[3]/length/string()" }
        XmlRole { name: "minutes4"; query: "estimate[4]/minutes/string()" }
        XmlRole { name: "length4"; query: "estimate[4]/length/string()" }

        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                destinations.clear()
                for (var i = 0; i < count; i++) {
                    var trains = [{"minutes": get(i).minutes, "length": get(i).length}]
                    get(i).minutes2 ? trains[trains.length] = {"minutes": get(i).minutes2, "length": get(i).length2} : null;
                    get(i).minutes3 ? trains[trains.length] = {"minutes": get(i).minutes3, "length": get(i).length3} : null;
                    get(i).minutes4 ? trains[trains.length] = {"minutes": get(i).minutes4, "length": get(i).length4} : null;

                    var destination = { "name": get(i).destination, "code": get(i).code, "trains": trains }
                    destinations.append(destination)
                }
            }
        }

        function fetchTrainsForStation(code) {
            stationCode = code
            reload()
        }
    }

    ListModel {
        id: destinations
    }

    BusyIndicator {
        anchors.right: parent.right
        running: stationFetcher.status === XmlListModel.Loading || trainFetcher.status === XmlListModel.Loading
    }
}
