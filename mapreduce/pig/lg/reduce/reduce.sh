hadoop fs -rmr $1
hadoop fs -put $1

hadoop fs -rmr reduce-PF
pig -param SRCS=$1 reduce.pig

rm -rf reduce-PF
hadoop fs -get reduce-PF
