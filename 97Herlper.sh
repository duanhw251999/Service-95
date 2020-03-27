find_str(){
 STRING_A=$1
 STRING_B=$2
 if [[ ${STRING_A/${STRING_B}//} == $STRING_A ]]
     then
         ## is not substring.
         echo N
         return 0
     else
         ## is substring.
         echo Y
         return 1
     fi
}

valstr2(){
  name=$2
  size=$(getSize $1$2)
  row=$(getRow $1$2)
  cur_date=`date -d "-1 day" +%Y%m%d`
  timestamp="`date +%Y%m%d%H%m%s`"
  printf '%-60s%-20s%-20s%-20s%-20s' ${name} ${size} ${row} ${cur_date} ${timestamp}
}

getRow(){
  file=${1}${2}
  row=`sed -n '$=' ${file}`
  if [[ -z  "$row" ]]
  then
     row=0
  fi
  echo $row
}

getSize(){
  sizestr=$(du -b ${1})
  arr=(${sizestr// /})
  size=${arr[0]}
  echo "${size}"
}

valstr(){
  name=$2
  size=$(getSize $1$2)
  row=$(getRow $1$2)
  cur_date=`date -d "-1 day" +%Y%m%d`
  timestamp="`date +%Y%m%d%H%m%s`"
  #printf '%-40s%-20s%-20s%-20s-20s' ${name} ${size} ${row} ${cur_date} ${timestamp}
  echo "${name}|${size}|${row}|${cur_date}|${timestamp} "
}



msg(){
  cur_dateTime="`date +%Y%m%d,%H:%m:%s`"
  PID=$$
  echo "[${cur_dateTime}] $PID " ${1}
}

