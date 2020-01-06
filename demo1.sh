#set ff=unix

path0=/pardata/EDADATA/INTERFACE/BSS/BACKUP/

path1=/pardata/EDADATA/INTERFACE/BSS/REALDATA/BAKCUP/

path2=/pardata/EDADATA/INTERFACE/BSS/BACKUP/real.txt

#Ų���ļ� ����¼
Record0() { 
        cd ${path0}${1}
        search=$(more $path2 |grep ${2})
        if [[ ! -n "$search" ]] || [[ "$search" == "" ]]; then
           mv ${2} ${path1}
           touch ${2}
           echo ${2} >> ${path2}
        fi
        echo "===================================Record Function is Executed! ================================="
}

# ����Ŀ¼�е��ļ������ƶ�
Movefile() { 
		cd ${path0}${1}
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

#����ļ���С
getSize(){
  sizestr=$(du -b ${1})
  arr=(${sizestr// /})
  size=${arr[0]}
  echo "${size}"
  return $size
}


#�ϲ�������У���ļ�
Builder() {
#1.����bss/backupĿ¼
cd ${path0}
#2.��ȡ��ǰ�����ַ���
cur_date=`date -d "-1 day" +%Y%m%d`
verf="s_"${cur_date}"_${1}_00.verf"
res=$(find . -type f -name "${verf}")
echo "================${res}"
if [[ ! -n "$res" ]] || [[ "$res" == "" ]]; then  #���û���ҵ�
 echo "0 not find verf file!"
else                  #����ҵ�
 cd ${path0}${1}  #����${1}��Ŀ¼
 iscur=$(find . -type f -name "${cur_date}_${1}.dat")
 if [[ ! -n "$iscur" ]] || [[ "$iscur" == "" ]];  then  #�����ǰ���ڵ��ļ�û���ҵ�
    rm -rf *
    cd ${path0}        #�ٴν���bss/backupĿ¼
    cat s_${cur_date}_${1}_00_*dat > ./${1}/${cur_date}_${1}.dat #���кϲ��ļ�
    cd ${1}                                        #�ٴν���${1}
    name=${cur_date}_${1}.dat
    size=$(getSize ${path0}${1}/$name)
    echo "$name $size" > dir.bos_${1}_s${cur_date}
    #ls ${cur_date}_${1}.dat > dir.bos_${1}_s${cur_date}
    echo "process ${1} file finished !"                    #��ʾ��Ϣ
 else
                echo "process ${1} file exist !"                    #��ʾ��Ϣ
 fi
fi
echo "================process ${1} done================" 
echo "===================================Builder Function is Executed! ================================="
}


# ִ������
while : 
do
  log_date=$(date "+%Y-%m-%d %H:%M:%S")
  echo "${log_date} start........"
  Builder 30005
	Movefile 30005
	
	Builder 30004
	Movefile 30004
	
	Builder 30003
	Movefile 30003
	
	Builder 30002
	Movefile 30002
	
	Builder 30001
	Movefile 30001
	
	log_date=$(date "+%Y-%m-%d %H:%M:%S")
  echo "${log_date} end........"
  
	sleep 1800
done

