rm -rf pig_*
rm -rf tmp-osg
hadoop fs -rmr tmp-ad
pig -param SRCS=$1 pair-ranking-3.pig
hadoop fs -get tmp-osg
