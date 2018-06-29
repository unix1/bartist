import QtQuick 2.7
import QtQuick.Controls 2.2

Page {
    id: page
    width: 720
    height: 1280
    padding: 10
    title: qsTr("BARTist Trains")
    property alias stationsColumn: stationsColumn
    property alias selectFromButton: selectFromButton
    property alias stack: stack

    header: Label {
        text: qsTr("BARTist")
        font.pointSize: 20
        padding: 10
    }

    StackView {
        id: stack
        initialItem: trainsColumn
        anchors.fill: parent

        Rectangle {
            id: trainsColumn

            Rectangle {
                id: selectFromRow
                // TODO magic number?
                height: 80
                Button {
                    id: selectFromButton
                    property int stationIndex: 0
                    x: 0
                    text: qsTr("Select a station")
                    font.family: "Verdana"
                    // TODO magic number?
                    font.pointSize: 20
                    font.bold: true
                    height: 60
                }
            }

            Rectangle {
                id: trainsRow
                anchors.top: selectFromRow.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.bottom: parent.bottom

                ScrollView {
                    clip: true
                    anchors.fill: parent
                    ListView {
                        id: listView
                        x: 0
                        y: 0
                        width: parent.width
                        height: parent.height
                        spacing: 20
                        delegate: Row {
                            spacing: 10
                            width: parent.width
                            Column {
                                // TODO magic number?
                                width: 100
                                Text {
                                    text: code
                                    font.family: "Verdana"
                                    font.pointSize: 20
                                }
                            }
                            Repeater {
                                model: trains
                                delegate: Column {
                                    width: 90
                                    Text {
                                        text: length + "-car\n" + ((minutes === "Leaving") ? "leaving now" : "in " + minutes + " min")
                                        font.family: "Verdana"
                                        font.pointSize: 15
                                    }
                                }
                            }
                        }
                        model: destinations
                    }
                }
            }
        }

        Rectangle {
            id: stationsColumn
            Rectangle {
                id: stationsTitleRow
                anchors.top: parent.top
                // TODO magic number?
                height: 50
                Text {
                    // TODO figure out why this text is showing on startup
                    //text: qsTr("Select a station")
                    anchors.fill: parent
                }
            }

            Rectangle {
                id: stationsListRow
                anchors.top: stationsTitleRow.bottom
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left

                ScrollView {
                    clip: true
                    anchors.fill: parent

                    ListView {
                        id: stationsListView
                        spacing: 20
                        anchors.fill: parent
                        delegate: StationListDelegate {
                            itemWidth: stationsListRow.width
                        }
                        model: stationFetcher
                    }
                }
            }
        }
    }
}
