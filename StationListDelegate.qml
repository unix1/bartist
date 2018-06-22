import QtQuick 2.0

Item {
    property real itemWidth
    x: 5
    width: itemWidth
    // TODO magic number?
    height: 40
    Rectangle {
        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            Text {
               text: name
               font.family: "Verdana"
               font.pointSize: 20
               //font.bold: true
            }
            onClicked: {
                stationsListView.currentIndex = index
                selectFromButton.stationIndex = index
                trainFetcher.fetchTrainsForStation(stationFetcher.getCode(index))
                stack.pop()
            }
        }
    }
}
