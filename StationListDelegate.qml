import QtQuick 2.0

Item {
    property real itemWidth
    x: 5
    width: itemWidth
    height: 40
    Row {
        width: parent.width
        Text {
            text: name
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                stationsListView.currentIndex = index
                selectorFrom.stationIndex = index
                trainFetcher.fetchTrainsForStation(stationFetcher.getCode(index))
                stationsColumn.visible = false
            }
        }

        spacing: 10
    }
}
