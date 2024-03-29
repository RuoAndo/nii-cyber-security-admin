time ./do.sh $1 $2 
grep tbb log | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3},[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d ":" -f 2 | cut -d "," -f 1 | sort | uniq -c  | awk '{print $2,$1}' | sort -t " " -k 2n > result.${2}.${1}

grep tbb log | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3},[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d ":" -f 2 | cut -d "," -f 1 | sort | uniq -c  | awk '{print $2","$1}' | sort -t "," -k 2n > csv.${2}.${1}

./trans.sh csv.${2}.${1} > plot.${2}.${1}  

rm -rf tmp
touch tmp

echo "lat,lng,count" > tmp 

while read line; do
    #echo $line
    ip=`echo $line | cut -d " " -f 1`
    count=`echo $line | cut -d " " -f 2`
    #echo $ip
    latlng=`python geoip-test.py $ip`

    echo $latlng","$count | tee -a tmp
    #echo $count","$latlng
    
done < result.${2}.${1}

python heatmap2.py ${2} ${1}
