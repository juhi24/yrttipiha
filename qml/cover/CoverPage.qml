import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

CoverBackground {
    id: cover
    signal searchActionTriggered()
    CoverImage {
        id: backgroundImageTop
        source: "../../img/cover_top.svg"
    }
    CoverImage {
        id: backgroundImageBottom
        source: "../../img/cover_bottom.svg"
    }
    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: {
                cover.searchActionTriggered();
            }
        }
    }
}

