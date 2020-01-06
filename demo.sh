#set ff=unix

path0=/pardata/EDADATA/INTERFACE/BSS/BACKUP/
path1= /pardata/EDADATA/INTERFACE/BSS/REALDATA/BAKCUP/
path2=/pardata/EDADATA/INTERFACE/BSS/BACKUP/real.txt

#Ų���ļ� ����¼
Record0() { 

        cd /pardata/EDADATA/INTERFACE/BSS/BACKUP/${1}
        while read line
        do
					if [ $line = ${2} ] ; then
						break
					else
							cp ${2} /pardata/EDADATA/INTERFACE/BSS/REALDATA/BAKCUP/
							echo ${2} >> /pardata/EDADATA/INTERFACE/BSS/BACKUP/real.txt
					fi
        done < /pardata/EDADATA/INTERFACE/BSS/BACKUP/real.txt
        echo "===================================Record Function is Executed! ================================="
}


# ����Ŀ¼�е��ļ������ƶ�
Movefile() { 
		cd /pardata/EDADATA/INTERFACE/BSS/BACKUP/${1}
		files=()
		count=0
		for file in `ls *.*`
		do
		files[$count]=$file
		((count++))
		done

		
		for file2 in ${files[*]}
		do
	     Record0 ${1} $file2
		done	
		
		echo "===================================Movefile Function is Executed! ================================="
}


 #�ϲ�������У���ļ�
Builder() {
#1.����bss/backupĿ¼
cd /pardata/EDADATA/INTERFACE/BSS/BACKUP
#2.��ȡ��ǰ�����ַ���
cur_date=`date -d "-1 day" +%Y%m%d`
verf="s_"${cur_date}"_${1}_00.verf"
res=$(find . -type f -name "${verf}")
echo "================${res}"
if [[ ! -n "$res" ]] || [[ "$res" == "" ]]; then  #���û���ҵ�
 echo "0 not find verf file!"
else                  #����ҵ�
 cd /pardata/EDADATA/INTERFACE/BSS/BACKUP/${1}  #����${1}��Ŀ¼
 iscur=$(find . -type f -name "${cur_date}_${1}.dat")
 if [[ ! -n "$iscur" ]] || [[ "$iscur" == "" ]];  then  #�����ǰ���ڵ��ļ�û���ҵ�
    rm -rf *
                cd /pardata/EDADATA/INTERFACE/BSS/BACKUP        #�ٴν���bss/backupĿ¼
                cat s_${cur_date}_${1}_00_*dat > ./${1}/${cur_date}_${1}.dat #���кϲ��ļ�
                cd ${1}                                        #�ٴν���${1}
                ls ${cur_date}_${1}.dat > dir.bos_${1}_s${cur_date}
                echo "process ${1} file finished !"                    #��ʾ��Ϣ
 else
                echo "process ${1} file exist !"                    #��ʾ��Ϣ
 fi
fi
echo "================process ${1} done================" 

echo "===================================Builder Function is Executed! ================================="
}


# ִ������

Builder 30005
Builder 30002



