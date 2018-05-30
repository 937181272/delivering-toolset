#!/usr/bin/env python
import GPUtil
import time, os, sys
import pydicom, shutil
from config import Config

ds_folder = '/data0/rundata/cta_srv_cases'
output_folder = '/data0/rundata/cta_srv_output'
config_file = Config.load(os.getenv('MEDICALBRAIN_CTA_S_CONFIG') or '/home/devops1/sk/medicalbrain-cta-srv/configs/station.yml')

args = sys.argv[1:]
if len(args) != 1:
    print "please enter parameter, eg: python dotest.py <running_date>"
    exit(1)

print "start time: " + str(time.strftime('%Y%m%d%H%M%S'))
search_date = str(args[0])
search_date.replace('-','')
print search_date

testcases = os.listdir(ds_folder)
testcases = filter(lambda x: search_date in x, testcases)
#testcases = ['00046633','00467286','00482343','00567314','00724084','00889981','00906588','00926060','00971726','00999018','01147487','01341070','01538460','01666057','02067161','02131395','02168537','02371187','02536831','02568263','02699561','02888414','02927777','03004308','03006133','03028705','03029281','03107534','03120391','03156064','03248616','03285447','03471224','03733696','03795306','04873786','04909039','08056031','13164235','13202086','13213191','13237318']
ignore_testcases = []
testcases = filter(lambda x: not x.startswith('.'), testcases)
model_store = '/var/lib/skmodel'



CTA_SEGMENTATION_MAP = {
    'DEFAULT': 0,
    'VESSEL_2D': 0,
    'VESSEL_3D': 1
}

RUNNING_MODE_MAP = {
    'DEFAULT': 0,
    'FULL': 0,
    'STANDARD': 1
}

def getAvailableGPU(maxload, maxmem, check_docker=True):
    ### firsly, get available gpus by resource usage
    availableIDs = GPUtil.getAvailable(order='first', limit=8, maxLoad=maxload, maxMemory=maxmem)
    if len(availableIDs) < 1:
        return None
    elif check_docker:
        ### check available gpus by docker
        tmp_ids = os.popen("docker inspect $(docker ps -q)|grep NVIDIA_VISIBLE_DEVICES").read().replace(
            "NVIDIA_VISIBLE_DEVICES=", "").replace('''"''', "").split()
        print tmp_ids
        try:
            invalid_gpus = map(lambda x: int(x), filter(lambda x: x != '' and x != 'all', list(
                    set(reduce(lambda x, y: x + y, map(lambda x: x.split(','), tmp_ids))))))
        except:
            invalid_gpus = []
        print invalid_gpus
        final_availableIDs = filter(lambda x: x not in invalid_gpus, availableIDs)
        print final_availableIDs
        if len(final_availableIDs) > 0:
            return final_availableIDs.pop()
        return None
    else:
        return availableIDs.pop()

for case in testcases:
    if case in ignore_testcases:
        print "case %s ignored" % case
        continue
    #if os.path.exists(os.path.join(output_folder, case)):
    #    shutil.rmtree(os.path.join(output_folder, case))
    workspace = os.path.join(ds_folder, case)
    #get pixel space and thickness
    if os.path.exists(os.path.join(workspace, "%s_0000.dcm" % case)):
        ds = pydicom.read_file(os.path.join(workspace, "%s_0000.dcm" % case), force=True)
        pixel_space = ds.PixelSpacing[0]
        thickness = ds.SliceThickness
    #else:
    #    pixel_space = 0.35
    #    thickness = 0.75
        print "pixel space: %f, thickness: %.2f" % (pixel_space, thickness)
        print "prepare for testing case: %s" % workspace
        runcmd_jpg = '''docker run --rm -v "%s:/workspace" shukun/dicomer:latest run''' % workspace
        print "run docker cmd:\n%s\n" % runcmd_jpg
        os.system(runcmd_jpg)
        runcmd_ww = '''docker run --rm -v "%s:/workspace" shukun/dicomer:latest run_png 800 300''' % workspace
        print "run docker cmd:\n%s\n" % runcmd_ww
        os.system(runcmd_ww)
        runcmd_ct = '''docker run --rm -v "%s:/workspace" shukun/dicomer:latest run_ct''' % workspace
        print "run docker cmd:\n%s\n" % runcmd_ct
        os.system(runcmd_ct)
        runcmd_npy = '''docker run --rm -v "%s:/workspace" shukun/dicomer:latest run_npy''' % workspace
        print "run docker cmd:\n%s\n" % runcmd_npy
        os.system(runcmd_npy)

        gpuid = getAvailableGPU(0.01, 0.08)
        while gpuid is None:
            print "can not get free gpu, waiting..."
            time.sleep(10)
            gpuid = getAvailableGPU(0.01, 0.08)
        print "get available gpu : %d" % gpuid
        runcmd = '''nvidia-docker run -d --rm -e WINDOW_WIDTH=%d -e WINDOW_LEVEL=%d -e NVIDIA_VISIBLE_DEVICES=%d -v "%s:/workspace" -v "%s:/output" -v "%s:/model" shukun/cta:latest run %f %.2f %s %d %d %d''' % (config_file.WINDOW_WIDTH, config_file.WINDOW_LEVEL, gpuid, workspace, output_folder, model_store, pixel_space, thickness, case, 0, CTA_SEGMENTATION_MAP[config_file.CTA_SEGMENTATION], RUNNING_MODE_MAP[config_file.RUNNING_MODE])
        print "run docker cmd:\n%s\n" % runcmd
        os.system(runcmd)
        time.sleep(5)

print "end time: " + str(time.strftime('%Y%m%d%H%M%S'))
