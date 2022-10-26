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
    qml/cover/CoverPage.qml \
    rpm/harbour-yrttipiha.changes.in \
    rpm/harbour-yrttipiha.changes.run.in \
    translations/*.ts \
    qml/pages/AboutPage.qml \
    qml/pages/AllHerbs.qml \
    rpm/harbour-yrttipiha.spec \
    rpm/harbour-yrttipiha.yaml \
    harbour-yrttipiha.desktop \
    qml/harbour-yrttipiha.qml \
    qml/components/CoverImage.qml

DEPLOYMENT_PATH = /usr/share/$${TARGET}

python.files = python/sqlalchemy/lib/sqlalchemy python/queries.py
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

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-yrttipiha-fi.ts
