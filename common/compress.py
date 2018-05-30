# !/usr/bin/python3
# coding:utf-8
import os,time,shutil,errno,tarfile,sys
from itertools import groupby, count
#对参数进行判断
#接受用户输入的三个参数：
args = sys.argv[1:]
if len(args) != 2:
    print "please enter parameter, eg: python compress.py <source_path> <dest_path>"
    exit(1)

print "start time: " + str(time.strftime('%Y%m%d%H%M%S'))
src_path = str(args[0])
dest_path = str(args[1])

if not src_path.startswith("/"):
    src_path = "/" + src_path
if not src_path.endswith("/"):
    src_path = src_path + "/"
if not dest_path.startswith("/"):
    dest_path = "/" + dest_path
if not dest_path.endswith("/"):
    dest_path = dest_path + "/"
if src_path == dest_path:
    print "parameters error,please enter two different parameter:"
    exit(1)

print "source dir is: " + src_path
print "destination dir is: " + dest_path

#定义将目录中的文件分组的方法，其中it代表要分组的list，step代表每个文件夹里内容的条数：
dirs = os.listdir(src_path)
print "number of will be compressed files: " + str(len(dirs))

def make_targz(tarfile_name, source_dir):
    with tarfile.open(tarfile_name, "w:gz") as tar:
        if os.path.isdir(source_dir) is True:
            files = os.listdir(source_dir)
            for f in files:
                if f.endswith(".dcm"):
                    f_path = os.path.join(source_dir,f)
                    #print f_path
                    tar.add(f_path, arcname=f)
        else:
            print source_dir + " is not a dir, skip"
        tar.close()

#判断目标路径是否存在，不存在则新建路径：
if os.path.exists(dest_path) is not True:
    os.makedirs(dest_path)

#将复制过来的所有文件分组，每个文件夹放置一定数目的文件或文件夹
count = 1
for i in dirs:
    tarfile_name = dest_path + i + ".tar.gz"
    src_file = src_path + i
    print str(count) + " tar file is " + tarfile_name
    make_targz(tarfile_name, src_file)
    count = count + 1

print "end time: " + str(time.strftime('%Y%m%d%H%M%S'))

