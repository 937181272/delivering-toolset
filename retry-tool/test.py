# -*- coding:utf-8 -*-

import sys
import time
import subprocess

def retry_start(max_retries=100, max_wait_interval=3600, period=10, rand=False, p_cmd=None):
    print "retry start ", p_cmd
    MAX_RETRIES = max_retries
    MAX_WAIT_INTERVAL = max_wait_interval
    PERIOD = period
    RAND = rand

    retries = 0
    error = None
    success = False
    while retries < MAX_RETRIES and success is False:
        try:
            returncode = subprocess.call(p_cmd, shell=True)
            if returncode == 0:
                success = True
        except Exception, ex:
            error = ex
        finally:
            if success is not True:
                sleep_time = min(2 ** retries * PERIOD if not RAND else randint(0, 2 ** retries) * PERIOD, MAX_WAIT_INTERVAL)
                time.sleep(sleep_time)
                retries += 1
                print "第", retries, "次重试, ", "等待" , sleep_time, "秒"
            else:
                break
    if retries == MAX_RETRIES:
        if error:
            raise error
        else:
            raise ProcedureException("unknown")

def monitor_process(p_name_pattern):
    p1 = subprocess.Popen(['ps', '-ef'], stdout=subprocess.PIPE)
    p2 = subprocess.Popen(['grep', p_name_pattern], stdin=p1.stdout, stdout=subprocess.PIPE)
    p3 = subprocess.Popen(['grep', '-v', 'grep'], stdin=p2.stdout, stdout=subprocess.PIPE)
    lines = p3.stdout.readlines()
    if len(lines) > 0:
        sys.stdout.write('process[%s] is running\n' % p_name_pattern)
        return True
    sys.stderr.write('process[%s] is lost\n' % p_name_pattern)
    return False
    
if __name__ == '__main__':
    p_name_pattern="t_shell"
    p_cmd="nohup ./t_shell.sh &"
    while True:
        monitor_result = monitor_process(p_name_pattern)
        if monitor_result is True:
            time.sleep(10)
        else:
            try:
                retry_start(max_retries=100, max_wait_interval=3600, period=2, rand=False, p_cmd=p_cmd)
            except Exception as e:
                break

            