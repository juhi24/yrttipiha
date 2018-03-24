import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4


Page {
    id: searchPage
    allowedOrientations: Orientation.All

    property string searchString
    onSearchStringChanged: {
        searchPy.update()
    }

    BusyIndicator {
        id: searchBusy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: true
    }

    SilicaListView {
        id: searchListView

        anchors.fill: parent

        header: Column{
            id: headerContainer
            width: page.width

            PageHeader {
                title: qsTr("Search")
            }

            SearchField {
                id: field
                width: parent.width
                placeholderText: qsTr("Name or symptom")

                Binding {
                    target: page
                    property: "searchString"
                    value: field.text.toLowerCase().trim()
                }
            }
            Component.onCompleted: field.forceActiveFocus()
        }

        // prevent newly added list delegates from stealing focus away from the search field
        currentIndex: -1

        model: ListModel {
            id: searchModel
        }

        delegate: ListItem {
            id: delegate

            Label {
                x: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                color: searchString.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                                               : (highlighted ? Theme.highlightColor : Theme.primaryColor)
                textFormat: Text.StyledText
                text: Theme.highlightText(model.name, searchString, Theme.highlightColor)
            }
            onClicked: {
                console.log("Clicked " + id)
                pageStack.push(Qt.resolvedUrl("Herb.qml"), {"hid": id})
            }
        }
        VerticalScrollDecorator {}
    }
    Python {
        id: searchPy
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../python'));
            addImportPath(Qt.resolvedUrl('../../python/yrttikanta'));
            importModule('queries', function () {});
            function update() {
                call('queries.search_herb', [searchString], function(result) {
                    searchBusy.running = true
                    searchModel.clear()
                    for (var i=0; i<result.length; i++) {
                        searchModel.append(result[i])
                    }
                    searchBusy.running = false
                })
            }
            onError: {
                console.log('python error: ' + traceback);
            }
            onReceived: {
                console.log('message from python: ' + data);
            }
        }
    }
}
