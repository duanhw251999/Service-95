import ftplib,os,Helper,re,operator
import time
from mylog import spider_say

conStr={
    "host":"135.149.64.97",
    "user":"GETDATA_EDA",
    "password":"Get(3369)edA",
    "realdata":"/BSS/REALDATA/",
    "remotedir":"/BSS/REALDATA/BAKCUP/",
    "temp":"E:/BILLDATA/BILLTEST/TMP/",
    "localdir":"E:/BILLDATA/BILLTEST/",
    "backup":"/BSS/BACKUP/"
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

def isFile(name):
    flag=False
    if len(name.split('.'))>1:
        if name.split('.')[1]=="dat" or name.split('.')[1]=="verf":
            flag=True
    return flag

def createdir(ftpobj,path):
    try:
        ftpobj.cwd(path)
        ftpobj.cwd('..')
    except Exception as e:
        ftpobj.mkd(path)


def remoteMove(ftpobj):
    rp = conStr["realdata"]
    if ftpobj is not None:
        ftpobj.cwd(rp)
        files = ftpobj.nlst()
        for f in files:
            if isFile(f):
                dirName = f.split('_')[1] + f.split('_')[2] + "/"
                createdir(ftpobj, rp + dirName)
                old = rp + f
                newn = rp + dirName + f
                #print(old + ">>" + newn)
                ftpobj.rename(old, newn)

def checkDir(ftpobj):
    flag=False
    rp = conStr["realdata"]
    if ftpobj is not None:
        ftpobj.cwd(rp) #进入realdata
        files = ftpobj.nlst() #读取realdata所有文件
        for f in files:
            if isFile(f)==False:#如果是目录
                ftpobj.cwd(rp+f)#进入子目录
                files2 = ftpobj.nlst() #读取子目录中的所有文件
                for f2 in files2:
                    if isFile(f2):#如果是文件
                        if f2.split('.')[1]=="verf":#如果是校验文件
                            flag=True #说明计费把该接口文件给全
                            break
                movedat(ftpobj,rp+f)#挪动子目录中的所有dat文件到bakcup目录
                moveverf(ftpobj,rp+f)#挪动子目录中的所有verf文件到bakcup目录
                ftpobj.cwd("..")#进入子目录
                if emptydir(ftpobj,rp+f):
                    ftpobj.rmd(rp+f)#目录删除

def emptydir(ftpobj,path):
    flag=False
    ftpobj.cwd(path)
    files2 = ftpobj.nlst()
    #for f2 in files2:
    #    print("子目录"+f2)
    if len(files2)==0:
        flag=True
    return flag


def movedat(ftp,path):
        files = ftpobj.nlst(path)
        for f in files:
            if os.path.splitext(f)[1] == '.dat':
                filename=os.path.split(f)[1]
                #print(f+">>"+conStr["remotedir"]+filename)
                ftp.rename(f,conStr["remotedir"]+filename)

def moveverf(ftp,path):
        files = ftpobj.nlst(path)
        for f in files:
            if os.path.splitext(f)[1] == '.verf':
                filename=os.path.split(f)[1]
                #print(f+">>"+conStr["remotedir"]+filename)
                ftp.rename(f,conStr["remotedir"]+filename)

########################################################################################################################################################
def mvFile(ftpobj):#根据文件名称，创建目录
    try:
        path=conStr["realdata"]
        ftpobj.cwd(path)
        files=ftpobj.nlst()
        for f in files:
            if isFile(f):
                newdir=f.split('_')[1]+f.split('_')[2]+"/"
                createdir(ftpobj, path + newdir)
                old = path + f
                newn = path + newdir + f
                ftpobj.rename(old, newn)
    except Exception as e:
        print(e)

def isFinish(ftpobj):
    try:
        path=conStr["realdata"]
        bp=conStr["remotedir"]
        ftpobj.cwd(path)
        files=ftpobj.nlst()
        for f in files:
            flag=False
            subdir=path+f+"/"
            ftpobj.cwd(subdir)#进入子目录
            files2 = ftpobj.nlst()
            for f2 in files2:
                if isFile(f2):
                    if f2.split(".")[1]=="verf":
                        flag=True
                        break
            if flag:
                if emptydir(ftpobj,bp):
                       movedat(ftpobj,path+f)#挪动子目录中的所有dat文件到bakcup目录
                       moveverf(ftpobj,path+f)#挪动子目录中的所有verf文件到bakcup目录
    except Exception as e:
        print(e)


def deleteEmpty(ftpobj):#删除空目录
    try:
        path=conStr["realdata"]
        ftpobj.cwd(path)
        files=ftpobj.nlst()
        for f in files:
            if f!="BAKCUP":
                subdir=path+f+"/"
                ftpobj.cwd(subdir)
                if emptydir(ftpobj,subdir):
                    ftpobj.rmd(subdir)#目录删除
    except Exception as e:
        print(e)


if __name__ == '__main__':
    '''
        1.扫描realdata目录
        2.拉取文件列表
        3.将文件移动到固定名称的目录中去，如果目录不存在，根据文件名创建
            如果是dat文件直接移动
            如果是verf文件，说明数据已经给全，将其挪入目录后，将整个目录的文件移动到bakcup目录中
            先挪数据文件，再挪校验文件，最后删除目录
    '''
    while True:
        ftpobj = ftpconnect()
        try:
             mvFile(ftpobj)
             isFinish(ftpobj)
             deleteEmpty(ftpobj)
        except Exception as e:
             spider_say(e)
        finally:
            ftpobj.quit()
            print("3分钟后，继续扫描......")
            time.sleep(3 * 60)
