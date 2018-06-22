import QtQuick 2.7
import QtQuick.Controls 2.0

Page {
    width: 720
    height: 1280
    property alias bartMap: bartMap
    title: qsTr("BARTist Map")

    header: Label {
        text: qsTr("BARTist")
        // TODO magic number?
        font.pointSize: 20
        padding: 10
    }

    MapImage {
        id: bartMap
    }
}
