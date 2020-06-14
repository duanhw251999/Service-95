# -*- coding: utf-8 -*-
import ftplib
import os
import datetime

conStr={"host":'10.235.243.13',"user":'gansu',"password":'knMX$b*1'}

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

def loopdir(dir):
    before_day = (datetime.datetime.now() + datetime.timedelta(days=-1)).strftime("%Y%m%d")
    ftpobj=ftpconnect(conStr['host'],conStr['user'],conStr['password'])
    ftpobj.cwd(dir)
    files=ftpobj.nlst()
    for f in files:
        suffix=os.path.splitext(f)[1]
        if suffix==".txt" :
            if str(f).find(before_day)>=0 :
                print(f)

if __name__ == '__main__':
    loopdir("/SMSVOLTE")
