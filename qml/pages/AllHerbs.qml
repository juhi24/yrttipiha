import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4


Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    BusyIndicator {
        id: busy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: true
    }

    SilicaListView {
        id: listView
        model: ListModel {
            id: namesModel
        }

        anchors.fill: parent
        header: PageHeader {
            title: qsTr("All herbs")
        }
        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.horizontalPageMargin
                text: name
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: {
                console.log("Clicked " + id)
                pageStack.push(Qt.resolvedUrl("Herb.qml"), {"hid": id})
            }
        }
        VerticalScrollDecorator {}
    }
    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../python'));
            addImportPath(Qt.resolvedUrl('../../python/yrttikanta'));
            importModule('queries', function () {
                call('queries.ls_all_herbs', [], function(result) {
                    for (var i=0; i<result.length; i++) {
                        namesModel.append(result[i])
                    }
                    busy.running = false
                })
            })
        }
    }
}
