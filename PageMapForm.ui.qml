import QtQuick 2.7
import QtQuick.Controls 2.0

Page {
    width: 720
    height: 1280

    header: Label {
        text: qsTr("BARTist")
        // TODO magic number?
        font.pointSize: 20
        padding: 10
    }

    Label {
        text: qsTr("You are on Page 2.")
        anchors.centerIn: parent
    }
}
