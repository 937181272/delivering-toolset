#-*- coding:utf-8 -*-
# 运行此脚本之前需要现在脚本所在目录下创建一个list.txt,在里边加入要重跑的病例号和血管名称，eg：P00593738T20180503R110033 RCA
import os
import sys

if len(sys.argv) < 3:
    print 'please enter parameter, eg: python dotest.py <case_list> <dstfolder>'
    sys.exit(1)

case_list = sys.argv[1]
dstfolder = sys.argv[2]

baseout = "/data0/rundata/cta_srv_output" 

if False == os.path.exists(dstfolder):
    os.system('mkdir -p ' + dstfolder)
else:
	os.system('rm -rf ' + dstfolder + '/*')


os.system('find ' + baseout + ' -type d -mindepth 1 -maxdepth 1 > folder.lst')


for line in open(case_list):
    
    line = line[:-1]

    case_id = line.split(' ')[0]
    vessel_name = line.split(' ')[1]

    save_folder = os.path.join(dstfolder, case_id + "_" + vessel_name)
    os.system('mkdir -p ' + save_folder)

    
    os.system('cp -r ' + os.path.join(baseout, case_id + '/cpr/' + vessel_name + '/* ') + save_folder)
    os.system('cp -r ' + os.path.join(baseout, case_id + '/narrow_list/* ') + save_folder)





