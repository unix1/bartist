import QtQuick 2.7
import QtQuick.Controls 2.0

Page {
    id: page
    width: 600
    height: 400
    property alias stationsColumn: stationsColumn
    property alias selectorFrom: selectorFrom
    title: qsTr("")

    header: Label {
        text: qsTr("BARTist")
        font.pixelSize: Qt.application.font.pixelSize * 2
        padding: 10
    }

    Column {
        id: trainsColumn
        anchors.fill: parent

        Row {
            id: selectFromRow
            height: 50
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top

            Button {
                id: selectorFrom
                property int stationIndex: 0
                text: qsTr("")
                anchors.fill: parent
            }
        }

        Row {
            id: trainsRow
            anchors.top: selectFromRow.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left

            ListView {
                id: listView
                x: 0
                y: 0
                width: parent.width
                height: 1000
                delegate: Row {
                    spacing: 15
                    width: parent.width
                    Column {
                        width: 60
                        Text {
                            text: code
                        }
                    }
                    Repeater {
                        model: trains
                        delegate: Column {
                            Text {
                                text: length + "-car\n" + ((minutes === "Leaving") ? "leaving now" : "in " + minutes + " min")
                            }
                        }
                    }
                }
                model: destinations
            }
        }
    }

    Column {
        id: stationsColumn
        anchors.fill: parent
        visible: false
        Row {
            id: stationsTitleRow
            height: 50
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            Text {
                text: qsTr("Select station")
                anchors.fill: parent
            }
        }

        Row {
            id: stationsListRow
            anchors.top: stationsTitleRow.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 0

            ListView {
                id: stationsListView
                anchors.fill: parent
                delegate: StationListDelegate {
                    itemWidth: stationsListRow.width
                }
                model: stationFetcher
            }
        }
    }
}
