cur_date=`date -d "-1 day" +%Y%m%d`
cd /pardata/EDADATA/INTERFACE/BSS/BACKUP
awk '{sum +=$3}END {print sum}'  s_${cur_date}_30005_00.verf
cd 30005
wc -l ${cur_date}_30005.dat
cd ..
awk '{sum +=$3}END {print sum}'  s_${cur_date}_30004_00.verf
cd 30004
wc -l ${cur_date}_30004.dat
cd ..
awk '{sum +=$3}END {print sum}'  s_${cur_date}_30003_00.verf
cd 30003
wc -l ${cur_date}_30003.dat
cd ..
awk '{sum +=$3}END {print sum}'  s_${cur_date}_30002_00.verf
cd 30002
wc -l ${cur_date}_30002.dat
cd ..
awk '{sum +=$3}END {print sum}'  s_${cur_date}_30001_00.verf
cd 30001
wc -l ${cur_date}_30001.dat