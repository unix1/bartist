import QtQuick 2.7
import QtQuick.Controls 2.0

Page {
    width: 720
    height: 1280
    title: qsTr("BARTist Map")

    header: Label {
        text: qsTr("BARTist")
        // TODO magic number?
        font.pointSize: 20
        padding: 10
    }

    Image {
        id: image
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        source: "BART_cc_map.png"
    }
}
