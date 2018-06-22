import QtQuick 2.7
import QtQuick.Controls 2.0

Flickable {
    id: bartMap
    anchors.fill: parent
    clip: true

    contentWidth: parent.width
      contentHeight: parent.height

      PinchArea {
          width: Math.max(bartMap.contentWidth, bartMap.width)
          height: Math.max(bartMap.contentHeight, bartMap.height)

          property real initialWidth
          property real initialHeight
          onPinchStarted: {
              initialWidth = bartMap.contentWidth
              initialHeight = bartMap.contentHeight
          }

          onPinchUpdated: {
              // adjust content pos due to drag
              bartMap.contentX += pinch.previousCenter.x - pinch.center.x
              bartMap.contentY += pinch.previousCenter.y - pinch.center.y

              // resize content
              bartMap.resizeContent(initialWidth * pinch.scale, initialHeight * pinch.scale, pinch.center)
          }

          onPinchFinished: {
              // Move its content within bounds.
              bartMap.returnToBounds()
          }

          Rectangle {
              width: bartMap.contentWidth
              height: bartMap.contentHeight
              color: "white"
              Image {
                  anchors.fill: parent
                  source: "BART_cc_map.png"
                  fillMode: Image.PreserveAspectFit
                  MouseArea {
                      anchors.fill: parent
                      onDoubleClicked: {
                          bartMap.contentWidth = bartMap.parent.width
                          bartMap.contentHeight = bartMap.parent.height
                      }
                  }
              }
          }
      }
}
