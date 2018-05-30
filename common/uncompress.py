# !/usr/bin/python
# coding:utf-8
import os,time,sys
#接受用户输入的参数并判断：
args = sys.argv[1:]
if len(args) != 3:
    print "please enter parameter, eg: python compress.py <source_path> <dest_path> <file_type>"
    exit(1)
src_path = str(args[0])
dest_path = str(args[1])
file_type = str(args[2])
#判断用户输入的目录首尾是否包含"/"，若不包含则追加：
if not src_path.startswith("/"):
    src_path = "/" + src_path
if not src_path.endswith("/"):
    src_path = src_path + "/"
if not dest_path.startswith("/"):
    dest_path = "/" + dest_path
if not dest_path.endswith("/"):
    dest_path = dest_path + "/"
print "source dir is " + src_path
print "destination dir is " + dest_path
print "file type is" + file_type

#定义将目录中的文件分组的方法，其中it代表要分组的list，step代表每个文件夹里内容的条数：
dirs = os.listdir(src_path)
print dirs
print "number of will be uncompressed files: " + str(len(dirs))
#输出开始压缩的时间：
print str(time.strftime('%Y%m%d%H%M%S'))
#解压tar格式的压缩包：
if file_type == "tar":
    for i in dirs:
        if i.endswith(".tar"):
            j = i.split(".")[0]
            if not os.path.isdir(dest_path + j):
                os.makedirs(dest_path + j)
            os.system("tar -xzvf " + src_path + i + " -C " + dest_path + j)
#解压tar.gz格式的压缩包：
if file_type == "tar.gz":
    for i in dirs:
        if i.endswith(".tar.gz"):
            j = i.split(".")[0]
            if not os.path.isdir(dest_path + j):
                os.makedirs(dest_path + j)
            os.system("tar -xzvf " + src_path + i + " -C " + dest_path + j)
#解压gz格式的压缩包：
if file_type == "gz":
    for i in dirs:
        if i.endswith(".gz"):
            j = i.split(".")[0]
            if not os.path.isdir(dest_path + j):
                os.makedirs(dest_path + j)
            os.system("gunzip " + src_path + i + " -C " + dest_path + j)
#解压bz2格式的压缩包：
if file_type == "bz2":
    for i in dirs:
        if i.endswith(".bz2"):
            j = i.split(".")[0]
            if not os.path.isdir(dest_path + j):
                os.makedirs(dest_path + j)
            os.system("bunzip2 " + src_path + i + " -C " + dest_path + j)
#解压tar.bz2格式的压缩包：
if file_type == "tar.bz2":
    for i in dirs:
        if i.endswith(".tar.bz2"):
            j = i.split(".")[0]
            if not os.path.isdir(dest_path + j):
                os.makedirs(dest_path + j)
            os.system("tar -jxvf " + src_path + i + " -C " + dest_path + j)
#解压zip格式的压缩包：
if file_type == "zip":
    for i in dirs:
        if i.endswith(".zip"):
            j = i.split(".")[0]
            if not os.path.isdir(dest_path + j):
                os.makedirs(dest_path + j)
            os.system("unzip -n " + src_path + i + " -d " + dest_path + j)
#解压rar格式的压缩包：
if file_type == "rar":
    for i in dirs:
        if i.endswith(".rar"):
            j = i.split(".")[0]
            if not os.path.isdir(dest_path + j):
                os.makedirs(dest_path + j)
            os.system("rar x -ep2 " + src_path + i + " " + dest_path + j)
#输出压缩结束时间：
print str(time.strftime('%Y%m%d%H%M%S'))





