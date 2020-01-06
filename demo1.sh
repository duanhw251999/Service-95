#set ff=unix

path0=/pardata/EDADATA/INTERFACE/BSS/BACKUP/

path1=/pardata/EDADATA/INTERFACE/BSS/REALDATA/BAKCUP/

path2=/pardata/EDADATA/INTERFACE/BSS/BACKUP/real.txt

#挪动文件 并记录
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

# 对子目录中的文件进行移动
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

#获得文件大小
getSize(){
  sizestr=$(du -b ${1})
  arr=(${sizestr// /})
  size=${arr[0]}
  echo "${size}"
  return $size
}


#合并且生成校验文件
Builder() {
#1.进入bss/backup目录
cd ${path0}
#2.获取当前日期字符串
cur_date=`date -d "-1 day" +%Y%m%d`
verf="s_"${cur_date}"_${1}_00.verf"
res=$(find . -type f -name "${verf}")
echo "================${res}"
if [[ ! -n "$res" ]] || [[ "$res" == "" ]]; then  #如果没有找到
 echo "0 not find verf file!"
else                  #如果找到
 cd ${path0}${1}  #进入${1}子目录
 iscur=$(find . -type f -name "${cur_date}_${1}.dat")
 if [[ ! -n "$iscur" ]] || [[ "$iscur" == "" ]];  then  #如果当前日期的文件没有找到
    rm -rf *
    cd ${path0}        #再次进入bss/backup目录
    cat s_${cur_date}_${1}_00_*dat > ./${1}/${cur_date}_${1}.dat #进行合并文件
    cd ${1}                                        #再次进入${1}
    name=${cur_date}_${1}.dat
    size=$(getSize ${path0}${1}/$name)
    echo "$name $size" > dir.bos_${1}_s${cur_date}
    #ls ${cur_date}_${1}.dat > dir.bos_${1}_s${cur_date}
    echo "process ${1} file finished !"                    #提示信息
 else
                echo "process ${1} file exist !"                    #提示信息
 fi
fi
echo "================process ${1} done================" 
echo "===================================Builder Function is Executed! ================================="
}


# 执行区域
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

