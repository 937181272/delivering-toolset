# -*- coding:utf-8 -*-

from enum import Enum

class Result(Enum):
    SUCCESS = 0
    TIMEOUT = 1
    ERROR = 2


class ProcedureException(Exception):
    def __init__(self, message):
        Exception.__init__(self, message)