#!/usr/bin/env python3
# coding: utf-8
import sys
from os import path
pkg_root = path.dirname(path.dirname(path.dirname(__file__)))
pymodules_path = path.join(pkg_root, 'python')
import threading
try:
    import pyotherside
    DEBUG = False
except ModuleNotFoundError:
    print('PyOtherSide not found. Entering debug mode.')
    DEBUG = True
import yrttikanta
from yrttikanta.tables import Herb


def hello():
    pyotherside.send('greeting', 'Hello from python!')


def all_herb_names():
    session = yrttikanta.Session()
    q = session.query(Herb.name).order_by(Herb.name)
    return list(map(lambda tup: {'name': tup[0].capitalize()}, q.all()))


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
        return self.threaded_call(all_herb_names)


db = Database()
