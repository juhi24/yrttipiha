# AGENTS.md

This file provides guidance to coding agents working with code in this repository.

## Overview

Yrttipiha is a **Sailfish OS** mobile app: a searchable database of ~130 wild and cultivated Finnish herbs, based on the Yrttitarha project. All user-facing content is Finnish-only. Source is MIT-licensed; herb content is © Osara työryhmä and used with permission.

## Generic SFOS app development

Documentation is at https://docs.sailfishos.org/Develop/Apps/

## Architecture

The app is a QML/Silica frontend with a Python backend bridged by **PyOtherSide** (`io.thp.pyotherside`). There is no C++ — it uses the `sailfishapp_qml` build mode, so the app runs via the `sailfish-qml` launcher.

**QML ↔ Python bridge.** QML pages that need data embed a `Python { }` element and, in `Component.onCompleted`, register the import path and import the `queries` module:

```qml
addImportPath(Qt.resolvedUrl('../../python'));
importModule('queries', function () { ... });
call('queries.some_function', [args], function(result) { ... });
```

- [python/queries.py](python/queries.py) is the entire backend API surface. Its module-level functions (`ls_all_herbs`, `search_herb`, `herb_page_data`) are what QML calls by name. It is **pure stdlib `sqlite3`** — no SQLAlchemy, no `yrttikanta` import at runtime. Each function opens a **read-only** connection (`file:...?mode=ro`) to the bundled DB, runs raw SQL, and closes it. `search_herb` matches names and alt-names in one `LEFT JOIN` query. `herb_page_data` returns exactly `{name, name_latin, alt_names, family, family_fi, html, img_paths}` — that dict *is* the contract [Herb.qml](qml/pages/Herb.qml) consumes; changing keys there breaks the detail page. Section HTML is assembled as `<h2>{title}</h2>{text}`, ordered by `section_titles.priority`.
- The **SQLite schema is a stable contract** now that `queries.py` reads it with raw SQL. Tables: `herbs`, `families` (Finnish `name_fi`), `alt_names` + `herb_names` (many-to-many), `sections` + `section_titles` (priority-ordered text blocks). `queries.py` resolves the DB/image dir for both the deployed layout (`python/yrttikanta/data`) and the repo layout (`python/yrttikanta/yrttikanta/data`).
- **Image lookup is filesystem glob, not DB.** `queries._img_paths()` ASCII-folds the herb name (`ö→o`, `ä→a`) and globs `data/img/{ascii_name}_*.jpg`, sorted. Images must be named `<asciiname>_photo.jpg` / `<asciiname>_drawing.jpg`.
- The DB and images live in the **`yrttikanta` git submodule** ([python/yrttikanta/](python/yrttikanta/)) at `yrttikanta/data/`. At runtime the app only reads those *data files*; the submodule's ORM ([tables.py](python/yrttikanta/yrttikanta/tables.py)) and SQLAlchemy are used **only by the build-time scraper** (`scr_soup.py`, `scr_db.py`) that generates the DB — not by the app. The submodule must be checked out (`git submodule update --init`) or the DB/images are missing.

**Sailjail sandbox** ([harbour-yrttipiha.desktop](harbour-yrttipiha.desktop)): the `[X-Sailjail]` section declares `OrganizationName=fi.j24`, `ApplicationName=Yrttipiha`, and empty `Permissions=` — the app reads only its own bundled data and opens external links via the system browser, so it needs no special permissions.

**QML structure** ([qml/](qml/)):
- [qml/harbour-yrttipiha.qml](qml/harbour-yrttipiha.qml) — `ApplicationWindow`; `initialPage` is `SearchPage`, plus the cover.
- [qml/pages/SearchPage.qml](qml/pages/SearchPage.qml) — live search. A `changeCounter` tracks in-flight queries so the pulldown busy indicator clears only when all pending searches resolve. Empty query lists all herbs. Alt-name search is known-slow (see the `TODO` in `search_herb`).
- [qml/pages/Herb.qml](qml/pages/Herb.qml) — detail page keyed by `hid`; image slideshow via `PagedView` with tap-to-zoom (view locks while zoomed).
- [qml/components/](qml/components/) — `MultilineLabel`, `CoverImage`; [qml/cover/](qml/cover/) — `CoverPage`.

## Build & Deploy

Built with the **Sailfish SDK** (qmake + the Sailfish build engine), not standard desktop Qt. [yrttipiha.pro](yrttipiha.pro) drives the build; RPM packaging metadata is in [rpm/](rpm/) ([rpm/harbour-yrttipiha.yaml](rpm/harbour-yrttipiha.yaml) is the spectacle spec source). Normal workflow is to build/deploy from the Sailfish IDE or `sfdk build`. There is no automated test suite.

**When renaming the app** (`TARGET` in the `.pro`): the QML entry filename, desktop file, desktop `Icon=`/`Exec=`, and translation filenames must all be renamed to match — see the header comment in [yrttipiha.pro](yrttipiha.pro).

**Deployed Python payload** is explicit in the `.pro` (`python.files`): only `queries.py` and the `python/yrttikanta/yrttikanta` data package (DB + images). No third-party Python is shipped — the backend is stdlib-only. New backend files must be added there to reach the device.

## Translations & Versioning

- Strings use `qsTr(...)`; translation sources are in [translations/](translations/) (`sailfishapp_i18n`). Despite the boilerplate German comments in the `.pro`/`.desktop`, the app is Finnish-only.
- App version lives in [rpm/harbour-yrttipiha.yaml](rpm/harbour-yrttipiha.yaml) (`Version:`) and is also shown on the About page — keep them in sync when bumping.
