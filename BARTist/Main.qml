import QtQuick 2.4
import QtQuick.XmlListModel 2.0
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
            width: parent.width

            anchors {
                margins: root.margins
                top: pageHeader.bottom
                left: pageHeader.left
                bottom: parent.bottom
                topMargin: units.gu(2)
            }
            height: parent.height

            spacing: units.gu(1)

            Row {
                id: selectFromRow
                spacing: units.gu(1)
                Button {
                    id: selectorFrom
                    objectName: "selectorFrom"
                    property int stationIndex: 0
                    text: stations.getStation(stationIndex)
                    onClicked: PopupUtils.open(stationSelector, selectorFrom)
                }
            }

            Row {
                spacing: units.gu(1)
                // TODO remove? This not used.
                Component {
                    id: trainDelegate
                    Item {
                        Column {
                            Text {
                                text: destination + " in " + minutes + " minutes (" + length + " cars)"
                            }
                        }
                    }
                }

                ListView {
                    id: trainsList
                    objectName: "trainsList"
                    height: 1000
                    width: pageLayout.width
                    clip: true
                    model: trainFetcher
//                    delegate: trainDelegate
                    delegate: Text {
                        text: destination + " in " + minutes + " minutes (" + length + " cars)"
                    }
                    PullToRefresh {
                        refreshing: trainFetcher.status === XmlListModel.Loading
                        onRefresh: trainFetcher.reload()
                    }
                }
            }
        }
    }

    ListModel {
        id: stations

        function getStation(idx) {
            return (idx >= 0 && idx < count) ? get(idx).name: ""
        }

        function getCode(idx) {
            return (idx >= 0 && idx < count) ? get(idx).code: ""
        }
    }

    /// NOTE stationsTest is for testing only
    ListModel {
        id: stationsTest
        ListElement { code: "12TH"; name: "12th St Oakland" }
        ListElement { code: "16TH"; name: "16th St SF" }
        ListElement { code: "24TH"; name: "24th St SF" }
        ListElement { code: "ASHB"; name: "Ashby" }
        ListElement { code: "BRKL"; name: "Downtown Berkeley" }
        ListElement { code: "COLM"; name: "Colma" }
        ListElement { code: "DBLN"; name: "Dublin/Pleasanton" }
        ListElement { code: "EMBC"; name: "Embarcadero" }
        ListElement { code: "GLNP"; name: "Glen Park" }
        ListElement { code: "LKMT"; name: "Lake Meritt" }
        ListElement { code: "MACR"; name: "Macarthur" }
        ListElement { code: "MONT"; name: "Montgomery" }
        ListElement { code: "ORND"; name: "Orinda" }
        ListElement { code: "PTSB"; name: "Pittsburg/Bay Point" }
        ListElement { code: "POWL"; name: "Powell" }
        ListElement { code: "ROCK"; name: "Rockridge" }
        ListElement { code: "WNTC"; name: "Walnut Creek" }
        function getStation(idx) {
            return (idx >= 0 && idx < count) ? get(idx).name: ""
        }

        function getCode(idx) {
            return (idx >= 0 && idx < count) ? get(idx).code: ""
        }
    }

    /// NOTE trainsTest is for testing only
    ListModel {
        id: trainsTest
        ListElement {
            destination: "test station 1"
            minutes: "1"
            length: "1"
        }
        ListElement {
            destination: "test station 2"
            minutes: "2"
            length: "2"
        }
    }

    XmlListModel {
        id: stationFetcher
        source: "https://api.bart.gov/api/stn.aspx?cmd=stns&key=MW9S-E7SL-26DU-VV8V"
        query: "/root/stations/station"

        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                for (var i = 0; i < count; i++)
                    stations.append({"code": get(i).code, "name": get(i).name})
            }
        }

        XmlRole { name: "name"; query: "name/string()" }
        XmlRole { name: "code"; query: "abbr/string()" }
    }

    XmlListModel {
        id: trainFetcher
        property string stationCode: "12TH"
        source: "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=" + stationCode + "&key=MW9S-E7SL-26DU-VV8V"
        query: "/root/station/etd"

        XmlRole { name: "destination"; query: "destination/string()" }
        XmlRole { name: "minutes"; query: "estimate[1]/minutes/string()" }
        XmlRole { name: "length"; query: "estimate[1]/length/string()" }

        function refresh() {
            stationCode = stations.getCode(selectorFrom.stationIndex)
            reload()
        }
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
                    model: stations
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
                    onCurrentItemChanged: {console.log('current item changed to ' + stations.getCode(listStations.currentIndex))}
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
