# -*- coding:utf-8 -*-

import time
from random import randint
from mystruct import Result, ProcedureException


def retry(max_retries=3, max_wait_interval=10, period=1, rand=False):
    def _retry(func):
        def __retry(*args, **kwargs):
            MAX_RETRIES = max_retries
            MAX_WAIT_INTERVAL = max_wait_interval
            PERIOD = period
            RAND = rand

            retries = 0
            error = None
            while retries < MAX_RETRIES:
                try:
                    result = func(*args, **kwargs)
                    if result.code == Result.ERROR:
                        raise ProcedureException("procedure occur error")
                    if result.code == Result.TIMEOUT:
                        raise ProcedureException("procedure request time out")
                    if result.code == Result.SUCCESS:
                        return result
                except Exception, ex:
                    error = ex
                finally:
                    sleep_time = min(2 ** retries * PERIOD if not RAND else randint(0, 2 ** retries) * PERIOD, MAX_WAIT_INTERVAL)
                    time.sleep(sleep_time)
                    retries += 1
                    print "第", retries, "次重试, ", "等待" , sleep_time, "秒"
            if retries == MAX_RETRIES:
                if error:
                    raise error
                else:
                    raise ProcedureException("unknown")
        return __retry
    return _retry
