if [ "$1" = "" ]
then
    echo "./auto.sh nThread nDimensions nClusters nItems"
    exit
fi

date=`date --date '2 day ago' +%Y%m%d`
echo $date

date_now=`date "+%Y%m%d-%H%M%S"`
date_start=`date "+%s"`

echo "started at:"$date_now 
echo "started at:"$date_now > procTime

#time ./first.sh all-${date} $1 $2 $3
#time ./second.sh all-${date} $1 $2 $3 $4

time ./first-ws.sh all $1 $2 $3
time ./second-ws.sh all $1 $2 $3 $4 
sleep 5s

date_now=`date "+%Y%m%d-%H%M%S"`
echo "finished at:"$date_now
echo "finished at:"$date_now >> procTime
date_end=`date "+%s"`

#echo $date_start
#echo $date_end

diff=`echo $((date_end-date_start))`
div=`echo $((diff/60))`

echo "proc time:"$diff"sec" 
echo "proc time:"$div"min" 

echo "proc time:"$diff"sec" >> procTime
echo "proc time:"$div"min" >> procTime

