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
from yrttikanta.tables import Herb


def hello():
    pyotherside.send('greeting', 'Hello from python!')


def ls_all_herbs():
    session = yrttikanta.Session()
    q = session.query(Herb.id, Herb.name).order_by(Herb.name)
    result = list(map(lambda tup: {'id': tup[0],
                                   'name': tup[1].capitalize()}, q.all()))
    session.close()
    return result


def herb_page_data(hid):
    """herb page data by herb id"""
    session = yrttikanta.Session()
    if ON_DEVICE:
        pyotherside.send('hid', str(hid))
    herb = session.query(Herb).get(hid)
    data = herb.as_dict()
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


db = Database()
