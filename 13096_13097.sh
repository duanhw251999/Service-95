path=/pardata/EDADATA/INTERFACE/OTHER/DATA/
path2=/pardata/EDADATA/INTERFACE/OTHER/BACKUP/
cd  $path

remote_files=("WUHAN_PNEUMONIA_OUT" "Itms_hg")

matching(){
  file0=${1}
  for f in ${remote_files[*]}
  do
    rep="${str/$pat/}"    
		if [ "$rep" == "$str" ]  
		then  
		    echo "Not Contains"  
		else  
		    echo "Contains"  
		fi  
		
  done
}

readdir() {
 count=0
 files=()
 
 for file in `ls |grep -i .txt`
 do 
 	 files[$count]=$file
 	 ((count++))
 done 
 
 msg "scan ${#files[@]} files "
 
 arrsize=${#files[@]}
 
 
if [ ${arrsize} > 0 ] ;then
	for f in ${files[*]}
	do 
	  for fx in ${remote_files[*]}
    do
    rep="${f/$fx/}"    
		if [ "$rep" != "$f" ]  
		then  
		     execute_fun ${f}
		     `mv ${path}${f} ${path2}`
		fi  
    done
	done
fi
}

execute_fun(){
  f=${1}
  fhead=${f:0:4}
  dat=""
  verf=""
  name=""
  size=""
  datestr=""
  if [[ "$fhead" == "Itms" ]];then
     dat=$(convert_dat ${f})
     verf="i_${f:8:8}_13096_00.verf"
     name=${dat}
     datestr=${f:8:8}
  fi
  
  if [[ "$fhead" == "WUHA" ]];then
     dat=$(convert_dat ${f})
     verf="s_${f:29:8}_13097_00.verf"
     name=${dat}
     datestr=${f:29:8}
  fi
  
  size=$(getSize ${path}${dat})
  rows=`sed -n '$=' ${path}${dat}`
  write2verf ${name} ${size} ${rows} ${datestr} ${verf}
}

convert_dat(){
  file0=${1}
  dat_name=""
  fhead=${file0:0:4}
  if [[ "$fhead" == "Itms" ]];then
     dat_name="i_${file0:8:8}_13096_00_001.dat"
  fi
  
  if [[ "$fhead" == "WUHA" ]];then
     dat_name="s_${file0:29:8}_13097_00_001.dat"
  fi
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
  printf '%-40s%-20s%-20s%-20s' ${1} ${2} ${3} ${4}${cur_dateTime0} >${5}
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