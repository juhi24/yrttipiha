import QtQuick 2.2
import Sailfish.Silica 1.0

Image {
    anchors {
        verticalCenter: parent.verticalCenter
        bottom: parent.bottom
        bottomMargin: Theme.paddingMedium
        right: parent.right
        rightMargin: -2*Theme.paddingLarge
        left: parent.left
        leftMargin: -Theme.paddingLarge
    }
    fillMode: Image.PreserveAspectFit
    opacity: 0.1
}
