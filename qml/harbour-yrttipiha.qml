import QtQuick 2.2
import Sailfish.Silica 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: app
    initialPage: Component { SearchPage { } }
    cover: CoverPage {
        id: cover
        onSearchActionTriggered: {
            app.activate()
            // navigate to the first page
            while (pageStack.depth>1) {
                pageStack.navigateBack(PageStackAction.Immediate)
            }
        }
    }
    allowedOrientations: defaultAllowedOrientations
}

