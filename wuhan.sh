path=/pardata/EDADATA/INTERFACE/OTHER/DATA/
path2=/pardata/EDADATA/INTERFACE/OTHER/BACKUP/
path3=/pardata/EDADATA/SHARE/
cd ${path}
share=('BONC' 'EDW' 'TYDK')

readdir(){
	count=0
	files=()

	for file in `ls *.TXT |grep PNEUMONIA`
	do 
	  files[$count]=$file
	  ((count++))
	done
	
	msg "scan ${#files[@]} files "
 
    arrsize=${#files[@]}
	
	if [ ${arrsize} > 0 ] ;then
		for f in ${files[*]}
		do 
		  clonefile ${path}$f
		  backup ${path}$f
		done
    fi
}

clonefile(){
  file=${1}
  for s in ${share[*]}
  do 
    `cp ${file} ${path3}$s/`
  done

}

backup(){
  file=${1}
  `mv  ${file} ${path2}`
}

msg(){
  cur_dateTime="`date +%Y%m%d,%H:%m:%s`"  
  PID=$$
  echo "[${cur_dateTime}] $PID " ${1}
}

while : 
do
	msg "Start..."
	readdir
	msg "End..."
	sleep 600
done
