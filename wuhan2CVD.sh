:<<!
PNEUMONIA_INT4_WUHAN_15_DETAIL >>	TB_WUHAN_TXT4
PNEUMONIA_INT5_HUBEI_15_DETAIL >>	TB_WUHAN_TXT5
PNEUMONIA_INT7_CLOSE_CONTACTS >>	TB_WUHAN_TXT7
PNEUMONIA_INT11_ROAMING_BACK >>	TB_ROAMING_BACK
PNEUMONIA_LABEL12_ABROAD_RESIDENT >>	TB_PNEUMONIA_LABEL12
#TB_PNEUMONIA_LABEL12.20200317.20200316.862.001.DAT
#TB_PNEUMONIA_LABEL12.20200327.20200326.00.000.000.862.CHECK
!

. /pardata/EDASCRIPT/publisher0/g2eda/lib/goodjob

path_data=/pardata/EDADATA/SHARE/EDW/
find_word=('PNEUMONIA_INT4_WUHAN_15_DETAIL' 'PNEUMONIA_INT5_HUBEI_15_DETAIL' 'PNEUMONIA_INT7_CLOSE_CONTACTS' 'PNEUMONIA_INT11_ROAMING_BACK' 'PNEUMONIA_LABEL12_ABROAD_RESIDENT')

readdir(){
        cd $1
        count=0
        files=()
        for sword in ${find_word[*]}
		do
			for file in `ls *.TXT |grep ${sword}`
			do
				dname=$(rename_dat $file)
				create_check ${dname}
				create_val ${dname}
			done
		done
}

#txt--dat
rename_dat(){
   cur_date=`date -d "-1 day" +%Y%m%d`
   txt_name=$1
   
        dat_name=${txt_name//_/.}
		
		if [[ $(find_str $txt_name 'PNEUMONIA_INT4_WUHAN_15_DETAIL') == 'Y' ]]
		then
			dat_name=${dat_name//PNEUMONIA.INT4.WUHAN.15.DETAIL/TB_WUHAN_TXT4}
		elif [[ $(find_str $txt_name 'PNEUMONIA_INT5_HUBEI_15_DETAIL') == 'Y' ]]
		then
		    dat_name=${dat_name//PNEUMONIA.INT5.HUBEI.15.DETAIL/TB_WUHAN_TXT5}
		elif [[ $(find_str $txt_name 'PNEUMONIA_INT7_CLOSE_CONTACTS') == 'Y' ]]
		then
		    dat_name=${dat_name//PNEUMONIA.INT7.CLOSE.CONTACTS/TB_WUHAN_TXT7}
		elif [[ $(find_str $txt_name 'PNEUMONIA_INT11_ROAMING_BACK') == 'Y' ]]
		then
		    dat_name=${dat_name//PNEUMONIA.INT11.ROAMING.BACK/TB_ROAMING_BACK}
		elif [[ $(find_str $txt_name 'PNEUMONIA_LABEL12_ABROAD_RESIDENT') == 'Y' ]]
		then
		    dat_name=${dat_name//PNEUMONIA.LABEL12.ABROAD.RESIDENT/TB_PNEUMONIA_LABEL12}			
		fi
	
	dat_name=${dat_name//.TXT/.DAT}

	mv ${path_data}${txt_name}  ${path_data}${dat_name}
	echo $dat_name 
}


create_check(){
   dat_name=$1
   arr=(${dat_name//./ })
   check_name="${arr[0]}.${arr[1]}.${arr[2]}.00.000.000.862.CHECK"
   touch ${path_data}${check_name}
   echo ${dat_name} >> ${path_data}${check_name}
   echo "${check_name} Finish..."
}

create_val(){
   dat_name=$1
   arr=(${dat_name//./ })
   val_name="${arr[0]}.${arr[1]}.${arr[2]}.00.001.${arr[4]}.862.VAL"
   touch ${path_data}${val_name}
   valstr=$(valstr ${path_data} ${dat_name})
   echo ${valstr} > ${path_data}${val_name}
   echo "${val_name} Finish..."
}

# execute block

while : 
do
	msg "Start..."
	readdir ${path_data}
	msg "End..."
	sleep 3600
done
