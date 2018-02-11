import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4

Page {
    id: page
    property int ind
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All
    // Place our content in a Column.  The PageHeader is always placed at the top
    // of the page, followed by our content.
    Column {
        id: column
        width: page.width
        spacing: Theme.paddingLarge
        PageHeader {
            title: herb.name
        }
    }
    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../python'));
            addImportPath(Qt.resolvedUrl('../../python/yrttikanta'));
            importModule('queries', function () {
                call('queries.herb_page_data', [page.ind], function(herb) {
                })
            })
        }
        onError: console.log('Python error: ' + traceback)
    }
}
