import os

#解密
def decryption(pwd,user):
	jm2="IceCode.exe -d "+pwd+" "+user
	f2=os.popen(jm2)
	data2=f2.readlines()
	f2.close()
	return data2[0]
	
#加密
def encryption(pwd,user):
        jm2="IceCode.exe -e "+pwd+" "+user
        f2=os.popen(jm2)
        data2=f2.readlines()
        f2.close()
        return data2[0]


if __name__=='__main__':
       msg= decryption("61b8cf08e78dc41d0e4e7a35db849a7f","JtODSuser")
       print(msg)
