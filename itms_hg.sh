path=/pardata/EDADATA/INTERFACE/OTHER/DATA/
path2=/pardata/EDADATA/INTERFACE/OTHER/BACKUP/
cd  $path


readdir() {
 count=0
 files=()
 
 for file in `ls Itms_hg_*`
 do 
 	 files[$count]=$file
 	 ((count++))
 done 
 
 msg "scan ${#files[@]} files "
 
 arrsize=${#files[@]}
 
 
if [ ${arrsize} > 0 ] ;then
	for f in ${files[*]}
	do 
		execute_fun ${f}
		`mv ${path}${f} ${path2}`
	done
fi
}

execute_fun(){
    f=${1}
    dat=$(convert_dat ${f})
	verf="i_${f:8:8}_13096_00.verf"
	echo ${verf}"++++++++"
	name=${dat}
	size=$(getSize ${path}${f})
	rows=`sed -n '$=' ${path}${f}`
	datestr=${f:8:8}
	write2verf ${name} ${size} ${rows} ${datestr} ${verf}
}

convert_dat(){
  file0=${1}
  dat_name="i_${file0:8:8}_13096_00_001.dat"
  `cp ${path}${file0} ${path}${dat_name}`
  echo ${dat_name}
}

convert_verf(){
   file0=${1}
   verf_name="i_${file0:8:8}_13096_00.verf"
   `touch ${path}$verf_name`
   echo ${path}${verf_name}
}

getSize(){
  sizestr=$(du -b ${1})
  arr=(${sizestr// /})
  size=${arr[0]}
  echo "${size}"
  return $size
}

write2verf(){
        cur_dateTime0="`date +%Y%m%d%H%m%s`"  
	#name=`printf '%-40s' ${1}`
	#size=`printf '%-40s' ${2}`
	#rows=`printf '%-40s' ${3}`
	#timestamp=`printf '%-40s' ${4}${cur_dateTime0}`
	#echo ${name}${size}${rows}${timestamp} > ${5}
	#echo ${name}${size}${rows}${timestamp}
	#`printf '%-40s%-40s%-20s%-20s' ${1}${2}${3}${4}${cur_dateTime0}`
        printf '%-40s%-20s%-20s%-20s' ${1} ${2} ${3} ${4}${cur_dateTime0} > ${5}
}

msg(){
  cur_dateTime="`date +%Y%m%d,%H:%m:%s`"  
  PID=$$
  echo "[${cur_dateTime}] $PID " ${1}
}

#execute block
#execute block
while : 
do
	msg "Start..."
	readdir
	msg "End..."
	sleep 1800
done
