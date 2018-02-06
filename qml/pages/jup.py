#!/usr/bin/env python3
# coding: utf-8
import sys
import threading
from os import path
pymodules_path = path.realpath('../../pymodules')
sys.path.append(pymodules_path)
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
try:
    import pyotherside
    DEBUG = False
except ModuleNotFoundError:
    print('PyOtherSide not found. Entering debug mode.')
    DEBUG = True

engine = create_engine('sqlite:///../../data/yrttibase.db', echo=False)
Session = sessionmaker(bind=engine)
session = Session()


def hello():
    pyotherside.send('greeting', 'Hello from python!')


class Database:
    """Database connection and queries"""
    def __init__(self):
        # Set bgthread to a finished thread so we never
        # have to check if it is None.
        self.bgthread = threading.Thread()
        self.bgthread.start()

    def hello(self):
        self.bgthread = threading.Thread(target=hello)
        self.bgthread.start()


db = Database()
