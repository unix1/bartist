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
               font.bold: true
            }
            onClicked: {
                stationsListView.currentIndex = index
                selectorFrom.stationIndex = index
                trainFetcher.fetchTrainsForStation(stationFetcher.getCode(index))
                stack.pop()
            }
        }
    }
}
