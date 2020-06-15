# -*- coding: utf-8 -*-
import ftplib
import os
import datetime
import time

conStr={"host":'10.235.243.13',"user":'gansu',"password":'knMX$b*1'
        ,"host97":'135.149.64.97',"user97":'PUTDATA_TISS',"password97":'Put(1715)Tiss'}

pathArray={"local_12046":'/root/temp/12046/',"local_12047":'/root/temp/12047/'}

def ftpconnect(host,user,password):
    ftpobj=None
    try:
        ftpobj=ftplib.FTP(host)
        ftpobj.login(user,password)
        msg=ftpobj.getwelcome()
        print(msg)
    except Exception as e:
        print(e)
    return ftpobj

#从ftp下载文件
def downloadfile(ftp, remotepath, localpath):
    # 设置的缓冲区大小
    bufsize = 1024
    fp = open(localpath, 'wb')
    ftp.retrbinary('RETR ' + remotepath, fp.write, bufsize)
    ftp.set_debuglevel(0)# 参数为0，关闭调试模式
    fp.close()

def ftp_upload(ftpobj,file_remote,file_local):
    '''以二进制形式上传文件'''
    if ftpobj is not None:
        #获取当前路径
        ftpobj.cwd("/")
        bufsize = 1024  # 设置缓冲器大小
        fp = open(file_local, 'rb')
        ftpobj.storbinary('STOR ' + file_remote, fp, bufsize)
        ftpobj.set_debuglevel(0)
        fp.close()

def processTime(pos):
    daystr = (datetime.datetime.now() + datetime.timedelta(days=pos)).strftime("%Y%m%d")
    return daystr

def recordfile(file,findStr=""):
    flag="non-exist"
    with open(file, mode="a+") as f:
        for line in f:
            if findStr == line.strip():
                flag = "exist"
                break


    if flag=="non-exist":
        with open(file, mode="a+") as f:
            f.write(findStr+"\n")
            flag="written"
    return flag


def loopdir(remotepath,localpath):
    ftpobj=ftpconnect(conStr['host'],conStr['user'],conStr['password'])
    ftpobj.cwd(remotepath)
    files=ftpobj.nlst()
    for f in files:
        suffix=os.path.splitext(f)[1]
        if suffix==".txt" :
            if str(f).find(processTime(0))>=0 :

                flag=recordfile("record.txt",f)
                if flag=="written":
                    ant_say(f + " is down")
                    downloadfile(ftpobj,remotepath+f,localpath+f)
                else:
                    ant_say(f + " is exist")



def ant_say(msg):
    timestr=(datetime.datetime.now() + datetime.timedelta(days=0)).strftime("%Y-%m-%d %H:%M:%S")
    print("\n\n%s %s" %(timestr,msg))

def transDat(path):
    files = os.listdir(path)
    if len(files)>0 :
        for f in files:
            if os.path.splitext(f)[1]==".txt":
                if str(f).find(processTime(0)) >= 0:
                    if str(f).find("SMSVOLTE")>= 0:
                        datName = "s_%s_%s_00_001.dat" % (processTime(-1), "12047")
                    else:
                        datName = "s_%s_%s_00_001.dat" % (processTime(-1), "12046")
                    os.rename(path + f, path + datName)

def builderVerf(path) :
    files = os.listdir(path)
    if len(files) > 0:
        for f in files:
            if os.path.splitext(f)[1] == ".dat":
                verfName=f[0:19]+".verf"
                if os.path.exists(path+verfName)==False:
                    name = f
                    size = os.stat(path + f).st_size
                    row = len(open(path + f, 'rU').readlines())
                    datadate = f[2:10]
                    ctime = (datetime.datetime.now() + datetime.timedelta(days=0)).strftime("%Y%m%d%H%M%S")
                    verfContent = "%-40s%-20s%-20s%-20s%-20s" % (name, size, row, datadate, ctime)
                    with open(path + verfName, "a+") as f:
                        f.write(verfContent + "\n")


def upload97(path,stuffx):
    ftpobj = ftpconnect(conStr['host97'], conStr['user97'], conStr['password97'])
    files = os.listdir(path)
    if len(files) > 0:
        for f in files:
            if os.path.splitext(f)[1] == stuffx:
                print("-------------" +processTime(-1))
                if str(f).find(processTime(-1)) >= 0:

                    flag = recordfile("upload.txt", f)
                    if flag == "written":
                        ant_say(f + " is uploading")
                        ftp_upload(ftpobj,"/"+f,path+f)
                    else:
                        ant_say(f + " is uploaded")



def process_down():
    loopdir("/",pathArray['local_12046'])
    loopdir("/SMSVOLTE/",pathArray['local_12047'])
    ant_say("download End...")

def process_trans():
    transDat(pathArray['local_12046'])
    transDat(pathArray['local_12047'])
    ant_say("convert dat file End...")
    builderVerf(pathArray['local_12046'])
    builderVerf(pathArray['local_12047'])
    ant_say("convert verf file End...")

def process_upload297():
    upload97(pathArray['local_12046'],".dat")
    upload97(pathArray['local_12046'], ".verf")
    upload97(pathArray['local_12047'],".dat")
    upload97(pathArray['local_12047'], ".verf")
    ant_say("upload 97 Server End...")

def boom():
    ant_say(str(os.getpid())+" Start......")
    process_down()
    process_trans()
    process_upload297()
    ant_say(str(os.getpid()) + " End......")



if __name__ == '__main__':
    while True:
        boom()
        time.sleep(3600)

'''
    while True:
        boom()
        time.sleep(3600)
s_20200606_12046_00.verf
s_20200606_12046_00_001.dat
SMSVOLTE_20200615_127875.txt
20200615_116770.txt
'''
