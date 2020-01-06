import ftplib,os,Helper,re,operator
import time
from mylog import spider_say

'''
   1. 95连接97
   2.读取realdata目录
   3.扫描verf文件
   4.读取verf文件
   5.检查dat文件是否存在，不存在，不下载
   6.下载dat文件到95，下载后将dat文件挪入bss/backup目录
   7.下载verf文件

'''

conStr={
    "host":"135.149.64.97",
    "user":"GETDATA_EDA",
    "password":"Get(3369)edA",
    "remotedir":"/BSS/REALDATA/BAKCUP/",
    "temp":"E:/BILLDATA/BILLTEST/TMP/",
    "localdir":"E:/BILLDATA/BILLTEST/",
    "backup":"/BSS/BACKUP/",
    "receive":"E:/ETL/DATA/receive/"
}


def ftpconnect():
    ftpobj=None
    try:
        ftpobj=ftplib.FTP(conStr['host'])
        ftpobj.login(conStr['user'],conStr['password'])
        msg=ftpobj.getwelcome()
        spider_say(msg)

    except Exception as e:
        spider_say(e)
    return ftpobj


def ftp_download(ftpobj,file_remote,file_local):
    if ftpobj is not None:
        #获取当前路径
        ftpobj.cwd(conStr["remotedir"])
        bufsize = 2048  # 设置缓冲器大小
        fp = open(file_local, 'wb')
        ftpobj.retrbinary('RETR ' + file_remote, fp.write, bufsize) #接收服务器上文件并写入本地文件
        ftpobj.set_debuglevel(0)
        fp.close()


def readRemote(ftpobj):
    if ftpobj is not None:
        rp=conStr["remotedir"]
        lp=conStr['temp']
        bp=conStr['backup']
        files=getremotefiles(ftpobj)
        if files is not None:
            for f in files:
                if os.path.splitext(f)[1] == '.verf':
                    filename=os.path.split(f)[1]
                    if filename.split('_')[2]!="30001":#如果是30001的校验文件不下载
                        ftp_download(ftpobj,rp+filename,lp+filename)
                        spider_say("已将"+filename+"下载到95TMP目录")
                    else:
                        ftpobj.rename(rp+filename,bp+filename)
                if os.path.splitext(f)[1] == '.dat':
                    filename=os.path.split(f)[1]
                    if filename.split('_')[2]=="30001":#如果是30001的校验文件不下载
                        ftpobj.rename(rp+filename,bp+filename)
    spider_say("校验文件搜索结束")

def remote_process(ftpobj):
    files=os.listdir(conStr['temp'])
    rp=conStr["remotedir"]
    lp=conStr['temp']
    bp=conStr['backup']
    if len(files)!=0:
        for file in files:
            with open(conStr['temp']+file,'r') as f:
                list1=readVerf(f)
                list2=readDat(ftpobj,file)
                if len(list1)==len(list2):
                   list3=[x for x in list1 if x in list2]
                   list4=[y for y in (list1+list2) if y not in list3]
                   if(len(list4)==0):
                       spider_say("校验文件内容与数据文件名称匹配，即将下载")
                       for filename in list2:
                            ftp_download(ftpobj,rp+filename,lp+filename)
                            ftpobj.rename(rp+filename,bp+filename)
                            #spider_say(filename+"已下载，且已备份到97备份目录")
                       ftpobj.rename(rp+file,bp+file)
                   else:
                       spider_say("校验文件与数据文件文件名称不匹配")
                else:
                    spider_say(file+"校验文件"+str(len(list1))+"数据文件"+str(len(list2))+"文件数目不匹配")
    spider_say("服务器远程操作完毕......")



def local_process():
    tp=conStr['temp']
    lp=conStr['localdir']

    vlist=[]
    files=os.listdir(tp)
    if len(files)!=0:
    #先找到verf
         for f in files:
                if f.split('.')[1]=="verf":
                    vlist.append(f) #获取verf文件

         if(len(vlist)!=0):
            for v in vlist:
                vfile=v.split('.')[0]
                count=0
                for f in files:
                    if f.split('.')[1]=="dat":
                        if re.match(vfile,f) is not None:
                            Helper.move(tp+f,lp)
                            count=count+1
                if(count>0):
                    Helper.move(tp+v,lp)
         spider_say("本地操作完毕,"+v+"相关文件全部处理完毕......")
    else:
         spider_say(conStr['temp']+"目录是空目录，没有需要处理的文件......")

def readVerf(f):
    list1=[]
    for line in f.readlines():
        list1.append(line.strip().split(' ')[0])#.split('_')[4].split('.')[0]
    return list1

def readDat(ftpobj,file):
    datfiles=getremotefiles(ftpobj)
    list2=[]
    patten=file.split('.')[0]
    if datfiles is not None:
       for f in datfiles:
           if os.path.splitext(f)[1] == '.dat':
              if re.match(patten,os.path.split(f)[1]) is not None:
                    list2.append(os.path.split(f)[1])#.split('_')[4]
    return list2

def getremotefiles(ftpobj):
     if ftpobj is not None:
         rp=conStr["remotedir"]
         ftpobj.cwd(rp)
         files=ftpobj.nlst(rp)
         return files
     else:
         return None

def init():
    Helper.mkdir0(conStr['temp'])

#20190926_30005.dat dir.bos_30005_s20190926
def catch0105():
    rp=conStr["remotedir"]
    bp=conStr['backup']
    receive=conStr['receive']
    files=getremotefiles(ftpobj)
    if files is not None:
       for f in files:
            filename=os.path.split(f)[1]
            if len(filename.split('_'))==2:
               ftp_download(ftpobj,rp+filename,receive+filename)
               ftpobj.delete(rp+filename)
               print("delete "+filename+"\n")
    files=getremotefiles(ftpobj)
    if files is not None:
       for f in files:
            filename=os.path.split(f)[1]
            if len(filename.split('_'))==3:
               ftp_download(ftpobj,rp+filename,receive+filename)
               ftpobj.delete(rp+filename)
               print("delete "+filename+"\n")



if __name__ == '__main__':
  while True:
    ftpobj=ftpconnect()
    try:
        init()
        catch0105()
        readRemote(ftpobj)
        remote_process(ftpobj)
        local_process()
    except Exception as e:
        spider_say(e)
    finally:
        ftpobj.quit()
        print("3分钟后，继续扫描......")
        time.sleep(3*60)

