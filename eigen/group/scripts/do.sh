./build.sh group6

ls 2017* > list

while read line; do
    echo $line
    mkdir dir_${line}
    split -l 1000000 $line $line-out
    mv $line-out* ./dir_${line}/
    cp group6.cpp ./dir_${line}/
    cp timer.h ./dir_${line}/
    cp rename_and_do.sh ./dir_${line}/
done < list
