import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4


Page {
    id: searchPage
    allowedOrientations: Orientation.All

    property string searchString
    property int changeCounter
    onSearchStringChanged: {
        changeCounter++;
        searchPullDown.busy = true;
        console.log('Pending searches: ' + changeCounter);
        searchPy.updateSearchQuery();
    }

    SilicaListView {
        id: searchListView

        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            id: searchPullDown
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }

        header: Column{
            id: headerContainer
            width: searchPage.width

            PageHeader {
                title: qsTr("Search")
            }

            SearchField {
                id: field
                width: parent.width
                placeholderText: qsTr("Herb name")

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false

                Binding {
                    target: searchPage
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
                id: herbName
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
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
            searchPage.changeCounter++;
            getAllHerbs();
        }

        function updateSearchQuery() {
            if (searchString) {
                call('queries.search_herb', [searchString], function(result) {
                    searchModel.clear();
                    console.log('Begin search: ' + searchString);
                    for (var i=0; i<result.length; i++) {
                        searchModel.append(result[i]);
                    }
                    checkBusy();
                })
            } else {
                getAllHerbs();
            }
        }

        function checkBusy() {
            searchPage.changeCounter--;
            if (changeCounter < 1) {
                searchPullDown.busy = false;
            }
        }

        function getAllHerbs() {
            call('queries.ls_all_herbs', [], function(result) {
                searchModel.clear();
                for (var i=0; i<result.length; i++) {
                    searchModel.append(result[i]);
                }
                checkBusy();
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
