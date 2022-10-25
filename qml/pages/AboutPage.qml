import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"


Page {
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + Theme.paddingLarge + buttonsColumn.height
        Column {
            id: mainColumn
            spacing: Theme.paddingMedium
            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
            PageHeader {
                title: qsTr("About")
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                sourceSize.width: 240; sourceSize.height: 240
                fillMode: Image.PreserveAspectFit
                source: "../../img/icon.svg"
            }

            Column {
                anchors.left: parent.left; anchors.right: parent.right
                spacing: Theme.paddingSmall
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeHuge
                    text: qsTr("Yrttipiha")
                }
            }
            AboutLabelSmall {
                anchors.left: undefined; anchors.right: undefined
                anchors.horizontalCenter: parent.horizontalCenter
                text: "v0.3.3"
            }
            AboutLabel {
                text: qsTr("This app is based on material from <a href=\"http://yrttitarha.fi\">Yrttitarha</a> herb database by Osara Agricultural College, and published under their permission.")
                onLinkActivated: Qt.openUrlExternally("http://yrttitarha.fi")
            }
            AboutLabel {
                text: qsTr("Yrttipiha was developed by Jussi Tiira and published under the <a href=\"https://github.com/juhi24/yrttipiha/blob/master/LICENSE\">MIT License</a>.")
                onLinkActivated: Qt.openUrlExternally("https://github.com/juhi24/yrttipiha/blob/master/LICENSE")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Source code")
                onClicked: Qt.openUrlExternally("https://github.com/juhi24/yrttipiha")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("About Yrttitarha")
                onClicked: Qt.openUrlExternally("http://yrttitarha.fi/info/")
            }
        }

        Column {
            id: buttonsColumn
            anchors {
                top: mainColumn.bottom
                topMargin: Theme.paddingLarge
                left: parent.left
                right: parent.right
            }

            //            BackgroundItem {
            //                anchors.left: parent.left; anchors.right: parent.right
            //                onClicked: pageStack.push(Qt.resolvedUrl("ChangeLogPage.qml"))
            //                Label {
            //                    anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
            //                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
            //                    anchors.verticalCenter: parent.verticalCenter
            //                    //: Caption of a button that leads to the changelog
            //                    text: qsTr("Changelog")
            //                }
            //            }
        }

        VerticalScrollDecorator {}
    }
}
