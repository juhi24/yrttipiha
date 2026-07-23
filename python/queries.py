# coding: utf-8
"""Read-only SQLite backend for the Yrttipiha QML frontend.

The bundled database is generated (never written at runtime) by the Yrttikanta
project, so this module only reads. The schema is a stable contract:
herbs, families, alt_names, herb_names, sections, section_titles.
"""

import sqlite3
from contextlib import closing
from glob import glob
from os import path

_HERE = path.dirname(path.abspath(__file__))

# Resolve the data dir for both the deployed layout (python/yrttikanta/data)
# and the repository layout (python/yrttikanta/yrttikanta/data).
DATA_DIR = next(
    d for d in (
        path.join(_HERE, 'yrttikanta', 'data'),
        path.join(_HERE, 'yrttikanta', 'yrttikanta', 'data'),
    ) if path.isdir(d)
)
_DB_PATH = path.join(DATA_DIR, 'yrttikanta.db')
_DB_URI = 'file:{}?mode=ro'.format(_DB_PATH)


def _connect():
    """Open a read-only connection with dict-like row access."""
    conn = sqlite3.connect(_DB_URI, uri=True)
    conn.row_factory = sqlite3.Row
    return conn


def _herb_list(rows):
    """Shape herb rows into the {id, name} dicts the search list consumes."""
    return [{'id': r['id'], 'name': r['name'].capitalize()} for r in rows]


def _img_paths(name):
    """Full paths to a herb's images, matched by ASCII-folded name."""
    ascii_name = name.replace('ö', 'o').replace('ä', 'a')
    name_glob = '{}_*.jpg'.format(ascii_name)
    return sorted(glob(path.join(DATA_DIR, 'img', name_glob)))


def ls_all_herbs():
    """List all herbs in the database, ordered by name."""
    with closing(_connect()) as conn:
        rows = conn.execute('SELECT id, name FROM herbs ORDER BY name').fetchall()
    return _herb_list(rows)


def search_herb(search_str):
    """Search herbs by name or alternative name in a single query."""
    like = '%{}%'.format(search_str.lower())
    sql = '''
        SELECT DISTINCT h.id, h.name
        FROM herbs h
        LEFT JOIN herb_names hn ON hn.herb_id = h.id
        LEFT JOIN alt_names a ON a.id = hn.name_id
        WHERE h.name LIKE :like OR a.name LIKE :like
        ORDER BY h.name
    '''
    with closing(_connect()) as conn:
        rows = conn.execute(sql, {'like': like}).fetchall()
    return _herb_list(rows)


def herb_page_data(hid):
    """Full detail-page payload for a herb id.

    Returns exactly the dict Herb.qml consumes:
    {name, name_latin, alt_names, family, family_fi, html, img_paths}.
    """
    with closing(_connect()) as conn:
        herb = conn.execute(
            'SELECT id, name, name_latin, family_id FROM herbs WHERE id = ?',
            (hid,)).fetchone()
        family = conn.execute(
            'SELECT name, name_fi FROM families WHERE id = ?',
            (herb['family_id'],)).fetchone()
        alts = conn.execute(
            '''SELECT a.name FROM alt_names a
               JOIN herb_names hn ON hn.name_id = a.id
               WHERE hn.herb_id = ?
               ORDER BY a.name''',
            (hid,)).fetchall()
        sections = conn.execute(
            '''SELECT st.name AS title, s.text AS text
               FROM sections s
               JOIN section_titles st ON st.id = s.title_id
               WHERE s.herb_id = ?
               ORDER BY st.priority''',
            (hid,)).fetchall()

    html = ''.join('<h2>{}</h2>{}'.format(s['title'], s['text']) for s in sections)
    return dict(
        name=herb['name'].capitalize(),
        name_latin=herb['name_latin'].capitalize(),
        alt_names=[a['name'] for a in alts],
        family=family['name'],
        family_fi=family['name_fi'],
        html=html,
        img_paths=_img_paths(herb['name']),
    )
