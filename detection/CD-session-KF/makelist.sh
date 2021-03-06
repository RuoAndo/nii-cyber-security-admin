#!/bin/sh

date14=`date --date '14 day ago' +%Y%m%d`
date13=`date --date '13 day ago' +%Y%m%d`
date12=`date --date '12 day ago' +%Y%m%d`
date11=`date --date '11 day ago' +%Y%m%d`
date10=`date --date '10 day ago' +%Y%m%d`
date9=`date --date '9 day ago' +%Y%m%d`
date8=`date --date '8 day ago' +%Y%m%d`
date7=`date --date '7 day ago' +%Y%m%d`
date6=`date --date '6 day ago' +%Y%m%d`
date5=`date --date '5 day ago' +%Y%m%d`
date4=`date --date '4 day ago' +%Y%m%d`
date3=`date --date '3 day ago' +%Y%m%d`
date2=`date --date '2 day ago' +%Y%m%d`
date1=`date --date '1 day ago' +%Y%m%d`

rm -rf in_*
rm -rf out_*
rm -rf lstm_*

rm -rf list
touch list

tree -d | grep 201 | cut -d " " -f2 > list0
cat list0

# modfiy this for interval setting

grep $date14 list0 >> list
grep $date13 list0 >> list
grep $date12 list0 >> list
grep $date11 list0 >> list
grep $date10 list0 >> list
grep $date9 list0 >> list
grep $date8 list0 >> list
grep $date7 list0 >> list
grep $date6 list0 >> list
grep $date5 list0 >> list
grep $date4 list0 >> list
grep $date3 list0 >> list
grep $date2 list0 >> list
grep $date1 list0 >> list

cat list
