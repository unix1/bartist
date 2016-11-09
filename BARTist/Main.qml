import QtQuick 2.4
import QtQuick.XmlListModel 2.0
import Qt.labs.settings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Popups 1.3

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: root
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "bartist.bump"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    width: units.gu(50)
    height: units.gu(75)

    property real margins: units.gu(2)
    property real buttonWidth: units.gu(9)

    // BART API configuration
    property string bartApiKey: "MW9S-E7SL-26DU-VV8V"
    property string bartApiUriBase: "https://api.bart.gov/api/"
    property string bartApiUriStations: bartApiUriBase + "stn.aspx?cmd=stns&key=" + bartApiKey
    property string bartApiUriEtd: bartApiUriBase + "etd.aspx?cmd=etd&key=" + bartApiKey
    property string defaultStationCode: "12TH"

    // Used for testing in offline mode, loads data from XML files in test directory
    property bool offline: false

    Settings {
        property alias stagionIndex: selectorFrom.stationIndex
        property alias stationCode: trainFetcher.stationCode
    }

    Page {
        header: PageHeader {
            id: pageHeader
            title: i18n.tr("BARTist")
        }
        anchors {
            fill: parent
        }

        Column {
            id: pageLayout

            anchors {
                margins: root.margins
                top: pageHeader.bottom
                left: pageHeader.left
                right: pageHeader.right
                bottom: parent.bottom
                topMargin: units.gu(2)
            }

            spacing: units.gu(1)

            Row {
                id: selectFromRow
                spacing: units.gu(1)
                Button {
                    id: selectorFrom
                    objectName: "selectorFrom"
                    property int stationIndex: 0
                    text: stationFetcher.getStation(stationIndex)
                    onClicked: PopupUtils.open(stationSelector, selectorFrom)
                }
            }

            Row {
                spacing: units.gu(1)
                width: parent.width
                ListView {
                    id: destinationList
                    objectName: "destinationList"
                    height: 1000
                    width: parent.width
                    clip: true
                    model: destinations
                    delegate: Row {
                        spacing: units.gu(3)
                        width: parent.width
                        Column {
                            width: units.gu(6)
                            Text { text: code }
                        }
                        Repeater {
                            model: trains
                            delegate: Column {
                                Text { text: length + "-car\n" +
                                             ((minutes === "Leaving") ? "leaving now" : "in " + minutes + " min") }
                            }
                        }
                    }
                    PullToRefresh {
                        refreshing: trainFetcher.status === XmlListModel.Loading
                        onRefresh: trainFetcher.reload()
                    }
                }
            }
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
                    /*
                    get(i).minutes2 ? trains[trains.length] = {"minutes": get(i).minutes2, "length": get(i).length2} : null;
                    get(i).minutes3 ? trains[trains.length] = {"minutes": get(i).minutes3, "length": get(i).length3} : null;
                    get(i).minutes4 ? trains[trains.length] = {"minutes": get(i).minutes4, "length": get(i).length4} : null;
                    */
                    if (get(i).minutes2) {
                        trains[trains.length] = {"minutes": get(i).minutes2, "length": get(i).length2};
                    }
                    if (get(i).minutes3) {
                        trains[trains.length] = {"minutes": get(i).minutes3, "length": get(i).length3};
                    }
                    if (get(i).minutes4) {
                        trains[trains.length] = {"minutes": get(i).minutes4, "length": get(i).length4};
                    }

                    var destination = { "name": get(i).destination, "code": get(i).code, "trains": trains }
                    destinations.append(destination)
                }
            }
        }

        function refresh() {
            stationCode = stationFetcher.getCode(selectorFrom.stationIndex)
            reload()
        }
    }

    ListModel {
        id: destinations
    }

    ActivityIndicator {
        objectName: "activityIndicator"
        anchors.right: parent.right
        running: stationFetcher.status === XmlListModel.Loading || trainFetcher.status === XmlListModel.Loading
    }

    Component {
        id: stationSelector
        Popover {
            id: popStationSelector
            Column {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: root.height
                Header {
                    id: header
                    text: i18n.tr("Select station")
                }
                ListView {
                    id: listStations
                    clip: true
                    width: parent.width
                    height: parent.height - header.height
                    model: stationFetcher
                    delegate: Standard {
                        objectName: "popoverStationSelector"
                        text: name
                        onClicked: {
                            console.log('click event started')
                            listStations.currentIndex = index
                            console.log('current index set to ' + index)
                            caller.stationIndex = index
                            trainFetcher.refresh()
                            hide()
                        }
                    }
                    onCurrentItemChanged: {console.log('current item changed to ' + stationFetcher.getCode(listStations.currentIndex))}
                }
            }
            ParallelAnimation {
                running: true
                NumberAnimation { target: popStationSelector; property: "x"; to: 10; duration: 200 }
                NumberAnimation { target: popStationSelector; property: "y"; to: 10; duration: 200 }
            }
        }
    }

}
