#!/usr/bin/env python3
# coding: utf-8
import sys.path
import threading
try:
    import pyotherside
    DEBUG = False
except ModuleNotFoundError:
    print('PyOtherSide not found. Entering debug mode.')
    DEBUG = True


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
