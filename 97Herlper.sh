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

valstr(){
  name=$2
  size=$(getSize $1$2)
  row=$(getRow $1$2)
  cur_date=`date -d "-1 day" +%Y%m%d`
  timestamp="`date +%Y%m%d%H%m%s`"
  printf '%-40s%-20s%-20s%-20s' ${name} ${size} ${row} ${cur_date}${timestamp}  
}

getRow(){
  row=`sed -n '$=' ${1}`
  echo $row
}

getSize(){
  sizestr=$(du -b ${1})
  arr=(${sizestr// /})
  size=${arr[0]}
  echo "${size}"
  return $size
}

echo $(valstr '/pardata/EDADATA/SHARE/BIGDATA/' 'PNEUMONIA_INT11_ROAMING_BACK_20200326_20200325_862_001.TXT')
