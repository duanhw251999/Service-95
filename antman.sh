#!/bin/bash
: << !
/pardata/EDADATA/JT_SOURCE/NEIMENG/mainpro/conf
15:52 2020/6/3

cd /usr/share/empty
!

function loopdir()
{
	declare -A dirs
	dirs=(
	[share]='/pardata/EDADATA/SHARE/' 
	[bssbak]='/pardata/EDADATA/INTERFACE/BSS/BACKUP/' 
	[otherbak]='/pardata/EDADATA/INTERFACE/OTHER/BAKCUP/' 
     )

opdate=`date -d "-8 day"  +%Y%m%d`
echo ":::$opdate::::"


for dir in  ${!dirs[@]}
do
  echo "$dir --> ${dirs[$dir]}"

  if [ $dir == "share" ] ; then
      cd ${dirs[$dir]}
	 for file in `find . -type f -name  T_*${opdate}.00* `
	 do 
	   echo $file
	   rm -rf $file
	 done
  fi
  
    if [ $dir == "bssbak" ] ; then
      cd ${dirs[$dir]}
	 for file in `find . -type f -name  "*_${opdate}_*"  `
	 do 
	   echo $file
	   rm -rf $file
	 done
  fi
  
    if [ $dir == "otherbak" ] ; then
      cd ${dirs[$dir]}
	 for file in `find . -type f -name  "*_${opdate}_*" |head -n5 `
	 do 
	   echo $file
	   rm -rf $file
	 done
  fi
  
done
}
while :
do
loopdir
sleep 
done

