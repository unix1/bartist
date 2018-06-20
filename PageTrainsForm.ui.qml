import QtQuick 2.7
import QtQuick.Controls 2.2

Page {
    id: page
    width: 720
    height: 1280
    property alias stationsColumn: stationsColumn
    property alias selectorFrom: selectorFrom
    property alias stack: stack
    title: qsTr("")

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
                height: 50
                Button {
                    id: selectorFrom
                    property int stationIndex: 0
                    text: qsTr("Select a station")
                    // TODO magic number?
                    font.pointSize: 15
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
                        delegate: Row {
                            spacing: 15
                            width: parent.width
                            Column {
                                // TODO magic number?
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
