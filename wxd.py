#!/usr/bin/python
# -*- coding: utf-8 -*-
import ftplib
import Jobject as jt
import os
import re

conf_path='conf_group.txt'
dst_file_path='/pardata/EDADATA/JT_SOURCE/TEMP/DATA'

#连接ftp
def connect():
    connstr0=['10.254.173.122','ftp862','ftp862#$!%@']

    ftp=ftplib.FTP(connstr0[0])
    ftp.login(connstr0[1],connstr0[2])
    return ftp

#加载配置文件
def load_conf():
    conf=[]
    with open(conf_path, 'r') as f:
        for line in f.readlines():
            line = line.strip('\n')
            conf.append(line)
    f.close()

    objs=[]
    for t in conf:
        tmp=t.split(',')
        objs.append(jt.Jobject(tmp[0],tmp[1],tmp[2],tmp[3],tmp[4],tmp[5]))

    return objs
    
    
def download():
    buffer_size = 10240  # 默认是8192

    ftp=connect()
    ftp.cwd('/')
    file_list = ftp.nlst('/')
    for file in file_list:
        ftp_file = os.path.join('/', file)
        if isdown(file)==1:
            write_file = os.path.join(dst_file_path, ftp_file)
            #with open(write_file, "wb") as f:
            #    ftp.retrbinary('RETR {0}'.format(ftp_file), f.write, buffer_size)
            #    f.close()

    ftp.quit()
    ftp.close()


def isdown(fileName):
    objs = load_conf()
    flag=0
    for obj in objs:
    	  print obj.name,'------',fileName
        if re.match(obj.name,fileName).span():
            flag=1
            break
    return flag


if __name__ == '__main__':
    download()
