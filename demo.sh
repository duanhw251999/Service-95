#set ff=unix

path0=/pardata/EDADATA/INTERFACE/BSS/BACKUP/
path1= /pardata/EDADATA/INTERFACE/BSS/REALDATA/BAKCUP/
path2=/pardata/EDADATA/INTERFACE/BSS/BACKUP/real.txt

#挪动文件 并记录
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


# 对子目录中的文件进行移动
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


 #合并且生成校验文件
Builder() {
#1.进入bss/backup目录
cd /pardata/EDADATA/INTERFACE/BSS/BACKUP
#2.获取当前日期字符串
cur_date=`date -d "-1 day" +%Y%m%d`
verf="s_"${cur_date}"_${1}_00.verf"
res=$(find . -type f -name "${verf}")
echo "================${res}"
if [[ ! -n "$res" ]] || [[ "$res" == "" ]]; then  #如果没有找到
 echo "0 not find verf file!"
else                  #如果找到
 cd /pardata/EDADATA/INTERFACE/BSS/BACKUP/${1}  #进入${1}子目录
 iscur=$(find . -type f -name "${cur_date}_${1}.dat")
 if [[ ! -n "$iscur" ]] || [[ "$iscur" == "" ]];  then  #如果当前日期的文件没有找到
    rm -rf *
                cd /pardata/EDADATA/INTERFACE/BSS/BACKUP        #再次进入bss/backup目录
                cat s_${cur_date}_${1}_00_*dat > ./${1}/${cur_date}_${1}.dat #进行合并文件
                cd ${1}                                        #再次进入${1}
                ls ${cur_date}_${1}.dat > dir.bos_${1}_s${cur_date}
                echo "process ${1} file finished !"                    #提示信息
 else
                echo "process ${1} file exist !"                    #提示信息
 fi
fi
echo "================process ${1} done================" 

echo "===================================Builder Function is Executed! ================================="
}


# 执行区域

Builder 30005
Builder 30002



