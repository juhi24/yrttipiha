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
    Column {
        id: column
        width: page.width
        spacing: Theme.paddingMedium
        PageHeader {
            id: pagetitle
        }
        Label {
            id: familylabel
            color: Theme.secondaryHighlightColor
            x: Theme.horizontalPageMargin
        }
    }
    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../python'));
            addImportPath(Qt.resolvedUrl('../../python/yrttikanta'));
            importModule('queries', function () {
                call('queries.herb_page_data', [page.hid], function(herb) {
                    pagetitle.title = herb.name
                    familylabel.text = herb.family + ", " + herb.family_fi
                })
            })
        }
        onError: console.log('Python error: ' + traceback)
    }
}
