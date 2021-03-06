# cluster size
nClusters=3
nDimensions=6
nItems=3 # nDimensions-2 / items: src dst n[* * *] 
nThreads=1

nLines=`wc -l 0 | cut -d " " -f 1` 
echo "counting points per cluster..."
time ./count $nLines 1 | tee tmp-all-labeled 
#sleep 2s

echo "calculating centroid..."
rm -rf centroid
time ./avg $nLines $nDimensions #yields centroid
cat centroid
#sleep 2s

echo "filling blank centroid rows..."
python fill2.py tmp-all-labeled centroid $nLines $nDimensions > tmp-centroid
cat tmp-centroid
\cp tmp-centroid centroid
#sleep 4s

echo "relabeling ..."
./relabel centroid $nClusters $nItems $nLines $nDimensions 

\cp 0.rlbl 0.lbl
time ./count $nLines 1 | tee tmp-all-relabeled 
#sleep 2s

echo "calculating SSE..."
time python sse.py centroid tmp-all-relabeled tmp-all-labeled

#./build.sh pickup2; ./pickup2 centroid $nClusters $nItems $nLines $nDimensions | tee tmp
#python reverse.py tmp
