rm -rf addrpair-avg-$1
hadoop fs -rmr addrpair-avg-$1
pig -x local -param OUTPUTDIR=addrpair-avg-$1 addrpair-avg.pig
hadoop fs -get addrpair-avg-$1
