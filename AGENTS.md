# AGENTS.md

This file provides guidance to coding agents working with code in this repository.

## Overview

Yrttipiha is a **Sailfish OS** mobile app: a searchable database of ~130 wild and cultivated Finnish herbs, based on the Yrttitarha project. All user-facing content is Finnish-only. Source is MIT-licensed; herb content is © Osara työryhmä and used with permission.

## Architecture

The app is a QML/Silica frontend with a Python backend bridged by **PyOtherSide** (`io.thp.pyotherside`). There is no C++ — it uses the `sailfishapp_qml` build mode, so the app runs via the `sailfish-qml` launcher.

**QML ↔ Python bridge.** QML pages that need data embed a `Python { }` element and, in `Component.onCompleted`, register the import paths and import the `queries` module:

```qml
addImportPath(Qt.resolvedUrl('../../python'));
addImportPath(Qt.resolvedUrl('../../python/yrttikanta'));
importModule('queries', function () { ... });
call('queries.some_function', [args], function(result) { ... });
```

- [python/queries.py](python/queries.py) is the entire backend API surface. Its module-level functions (`ls_all_herbs`, `search_herb`, `herb_page_data`) are what QML calls by name. Each opens a `yrttikanta.Session()`, queries, and closes it. Note that the `{id, name}` dicts returned to the search list are built here (`_q_result_herbs`), **not** by the ORM's `as_dict()`.
- Data model and DB live in the **`yrttikanta` git submodule** ([python/yrttikanta/](python/yrttikanta/)): a SQLite DB at `yrttikanta/data/yrttikanta.db`, the `Session` factory ([__init__.py](python/yrttikanta/yrttikanta/__init__.py)), and the ORM in [tables.py](python/yrttikanta/yrttikanta/tables.py). Entities: `Herb`, `Family` (with Finnish `name_fi`), `AltName` (many-to-many with Herb), `Section` + `SectionTitle` (priority-ordered text blocks). `Herb.as_dict()` produces exactly `{name, name_latin, alt_names, family, family_fi, html, img_paths}` — that dict *is* the contract [Herb.qml](qml/pages/Herb.qml) consumes; changing keys there breaks the detail page. Section HTML is assembled as `<h2>{title}</h2>{text}` by `sections_html()`.
- **Image lookup is filesystem glob, not DB.** `Herb.img_paths()` ASCII-folds the herb name (`ö→o`, `ä→a`) and globs `data/img/{ascii_name}_*.jpg`. Images therefore must be named `<asciiname>_photo.jpg` / `<asciiname>_drawing.jpg`; slideshow order follows glob order, not an explicit sort.
- The SQLite DB is generated (not hand-edited) by scraper scripts in [python/yrttikanta/scripts/](python/yrttikanta/scripts/) (`scr_soup.py`, `scr_db.py`).
- SQLAlchemy itself is vendored as a **second submodule** ([python/sqlalchemy/](python/sqlalchemy/)) and only its `lib/sqlalchemy` is deployed. Both submodules must be checked out (`git submodule update --init`) — they are empty on a fresh clone and nothing will run without them.

**`ON_DEVICE` debug flag** ([python/queries.py:6-11](python/queries.py#L6-L11)): PyOtherSide import failure flips the module into off-device debug mode, so `queries.py` can be exercised in a plain Python REPL without the Sailfish runtime. The `pyotherside.send(...)` diagnostic calls are guarded by this flag.

**QML structure** ([qml/](qml/)):
- [qml/harbour-yrttipiha.qml](qml/harbour-yrttipiha.qml) — `ApplicationWindow`; `initialPage` is `SearchPage`, plus the cover.
- [qml/pages/SearchPage.qml](qml/pages/SearchPage.qml) — live search. A `changeCounter` tracks in-flight queries so the pulldown busy indicator clears only when all pending searches resolve. Empty query lists all herbs. Alt-name search is known-slow (see the `TODO` in `search_herb`).
- [qml/pages/Herb.qml](qml/pages/Herb.qml) — detail page keyed by `hid`; image slideshow via `PagedView` with tap-to-zoom (view locks while zoomed).
- [qml/components/](qml/components/) — `MultilineLabel`, `CoverImage`; [qml/cover/](qml/cover/) — `CoverPage`.

## Build & Deploy

Built with the **Sailfish SDK** (qmake + the Sailfish build engine), not standard desktop Qt. [yrttipiha.pro](yrttipiha.pro) drives the build; RPM packaging metadata is in [rpm/](rpm/) ([rpm/harbour-yrttipiha.yaml](rpm/harbour-yrttipiha.yaml) is the spectacle spec source). Normal workflow is to build/deploy from the Sailfish IDE or `sfdk build`. There is no automated test suite.

**When renaming the app** (`TARGET` in the `.pro`): the QML entry filename, desktop file, desktop `Icon=`/`Exec=`, and translation filenames must all be renamed to match — see the header comment in [yrttipiha.pro](yrttipiha.pro).

**Deployed Python payload** is explicit in the `.pro` (`python.files`): only `queries.py`, `python/yrttikanta/yrttikanta`, and `python/sqlalchemy/lib/sqlalchemy`. New backend files must be added there to reach the device.

## Translations & Versioning

- Strings use `qsTr(...)`; translation sources are in [translations/](translations/) (`sailfishapp_i18n`). Despite the boilerplate German comments in the `.pro`/`.desktop`, the app is Finnish-only.
- App version lives in [rpm/harbour-yrttipiha.yaml](rpm/harbour-yrttipiha.yaml) (`Version:`) and is also shown on the About page — keep them in sync when bumping.
