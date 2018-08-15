#!/usr/bin/env python3
# coding: utf-8
from os import path
pkg_root = path.dirname(path.dirname(path.dirname(__file__)))
pymodules_path = path.join(pkg_root, 'python')
import threading
try:
    import pyotherside
    ON_DEVICE = True
except ModuleNotFoundError:
    print('PyOtherSide not found. Entering debug mode.')
    ON_DEVICE = False
import yrttikanta
from yrttikanta.tables import Herb, AltName


def hello():
    pyotherside.send('greeting', 'Hello from python!')


def _q_result_herbs(herbs):
    """all results of a query as a dictionary"""
    return list(map(lambda h: {'id': h.id,
                               'name': h.name.capitalize()}, herbs))


def _q_result_alts(alts):
    """all results of an alt name query as dict"""
    herbs = []
    for alt in alts:
        herbs.extend(alt.herbs)
    return _q_result_herbs(herbs)


def ls_all_herbs():
    """List all herbs in database."""
    session = yrttikanta.Session()
    q = session.query(Herb).order_by(Herb.name)
    result = _q_result_herbs(q)
    session.close()
    return result


def search_herb(search_str):
    """Search herb from database."""
    session = yrttikanta.Session()
    qstr = '%{}%'.format(search_str.lower())
    cond = Herb.name.like(qstr)
    cond_alt = AltName.name.like(qstr)
    q = session.query(Herb).filter(cond).order_by(Herb.name)
    # TODO: fix slow alt search
    q_alt = session.query(AltName).filter(cond_alt).order_by(AltName.name)
    result = _q_result_herbs(q.all())
    result.extend(_q_result_alts(q_alt.all()))
    session.close()
    return list({v['id']:v for v in result}.values()) # unique ids


def herb_page_data(hid):
    """herb page data by herb id"""
    session = yrttikanta.Session()
    if ON_DEVICE:
        pyotherside.send('hid', str(hid))
    herb = session.query(Herb).get(hid)
    data = herb.as_dict()
    if ON_DEVICE:
        pyotherside.send('keys', str(data.keys()))
        pyotherside.send('urls', str(data['img_paths']))
    session.close()
    return data


class Database:
    """Database connection and queries"""
    def __init__(self):
        # Set bgthread to a finished thread so we never
        # have to check if it is None.
        self.bgthread = threading.Thread()
        self.bgthread.start()
        self.session = yrttikanta.Session()

    def threaded_call(self, fun):
        self.bgthread = threading.Thread(target=fun, args=(self.session,))
        self.bgthread.start()

    def all_herb_names(self):
        return self.threaded_call(ls_all_herbs)


#db = Database()
