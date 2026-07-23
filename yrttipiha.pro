# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-yrttipiha

CONFIG += sailfishapp_qml

DISTFILES += \
    qml/components/MultilineLabel.qml \
    qml/components/CoverImage.qml \
    qml/cover/CoverPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/SearchPage.qml \
    qml/pages/Herb.qml \
    qml/harbour-yrttipiha.qml \
    python/queries.py \
    rpm/harbour-yrttipiha.changes.in \
    rpm/harbour-yrttipiha.changes.run.in \
    rpm/harbour-yrttipiha.spec \
    rpm/harbour-yrttipiha.yaml \
    translations/*.ts \
    harbour-yrttipiha.desktop

DEPLOYMENT_PATH = /usr/share/$${TARGET}

# The runtime backend is pure stdlib sqlite3 (see python/queries.py); only the
# query module and the yrttikanta data package (DB + images) are deployed.
python.files = python/queries.py
python.files += python/yrttikanta/yrttikanta
python.path = $${DEPLOYMENT_PATH}/python
INSTALLS += python

img.files = img
img.path = $${DEPLOYMENT_PATH}
INSTALLS += img

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# The app is Finnish-only; strings live in translations/.
TRANSLATIONS += translations/harbour-yrttipiha-fi.ts
