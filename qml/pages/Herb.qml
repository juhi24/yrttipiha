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
            anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
            PageHeader {
                id: pagetitle
            }
            SlideshowView {
                id: imageSlides
                width: page.width
                itemWidth: width
                height: 500
                clip: true
                orientation: Qt.Horizontal
                model: ListModel {
                    id: figsModel
                }
                delegate: Image {
                    id: fig
                    width: imageSlides.itemWidth
                    fillMode: Image.PreserveAspectFit
                    source: src
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
