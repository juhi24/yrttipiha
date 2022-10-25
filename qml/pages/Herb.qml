import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4

Page {
    id: page
    property int hid
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All
    // Place our content in a Column.  The PageHeader is always placed at the top
    // of the page, followed by our content.
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge
        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium
            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
            PageHeader {
                id: pagetitle
            }
            PagedView {
                id: imageSlides
                z: 50
                width: page.width
                height: 550
                clip: false
                anchors {
                    left: parent.left
                    right: parent.right
                }
                model: ListModel {
                    id: figsModel
                }
                delegate: Image {
                    id: fig
                    property bool isZoomed: false
                    fillMode: Image.PreserveAspectFit
                    source: src
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            figAnimation.start()
                            isZoomed = !isZoomed
                            // Lock while zoomed
                            imageSlides.interactive = !imageSlides.interactive
                        }
                    }
                    ParallelAnimation {
                        id: figAnimation
                        NumberAnimation {
                            id: zoomAnimation
                            target: fig
                            easing.type: Easing.InOutQuad
                            properties: "scale"
                            to: isZoomed ? 1 : 2
                            duration: 200
                        }
                        NumberAnimation {
                            id: moveAnimation
                            target: fig
                            easing.type: Easing.InOutQuad
                            properties: "y"
                            to: isZoomed ? imageSlides.height/2 - fig.height/2 : fig.height/2
                            duration: 200
                        }
                    }
                }
            }
            Label {
                id: latinLabel
                color: Theme.secondaryHighlightColor
            }
            Label {
                id: familyLabel
                color: Theme.secondaryHighlightColor
            }
            Label {
                id: altNamesLabel
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                anchors.left: parent.left; anchors.right: parent.right
            }
            Label {
                id: sections
                textFormat: Text.RichText
                wrapMode: Text.Wrap
                anchors.left: parent.left; anchors.right: parent.right
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
                call('queries.herb_page_data', [page.hid], function(herb) {
                    pagetitle.title = herb.name
                    altNamesLabel.text = herb.alt_names.join(', ')
                    latinLabel.text = herb.name_latin
                    familyLabel.text = herb.family + qsTr(" family (") + herb.family_fi + ")"
                    sections.text = herb.html
                    for (var i=0; i<herb.img_paths.length; i++) {
                        figsModel.append({src: herb.img_paths[i]})
                    }
                })
            })
        }
        onError: console.log('Python error: ' + traceback)
    }
}
