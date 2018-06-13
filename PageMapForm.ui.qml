import QtQuick 2.7
import QtQuick.Controls 2.0

Page {
    width: 600
    height: 400

    header: Label {
        text: qsTr("Page 2")
        font.pointSize: Qt.application.pointSize * 2
        padding: 10
    }

    Label {
        text: qsTr("You are on Page 2.")
        anchors.centerIn: parent
    }
}
