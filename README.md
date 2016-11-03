# nii-cyber-security-admin

# K-means 
  <pre>
   -bash-4.1# python km.py test.txt 
   0 739.828002664 
   1 364.390406921 
   2 361.377450751 
   3 359.252127268 
   4 355.706047096 
   5 349.6218553
   6 346.753583962 
   7 346.018573918
   8 345.671668541
   9 345.170391332 
   10 344.946493745

   calculating distance ...
   data:0:[ 0.82706862 -0.76446403]
    mean:0:[-0.92139629  0.18107609]
     distance:1.98775643847
　　mean:1:[ 0.77916733 -0.15312475]
     distance:0.613213055326

</pre>

diff = 100000<br>
<img src="diff-100000.png" width="70%"> <br>

diff = 10000<br>
<img src="diff-10000.png" width="70%"> <br>

diff = 1000<br>
<img src="diff-1000.png" width="70%"> <br>

diff = 10<br>
<img src="diff-10.png" width="70%"> <br>

diff = 0.1<br>
<img src="diff-01.png" width="70%"> <br>

diff = 0.01 (default)<br>
<img src="diff-001.png" width="70%"> <br>

# Changepoint detection
  <pre>
  -bash-4.1# apt-get install scipy
  -bash-4.1# easy_install cython
  -bash-4.1# easy_install pandas
  -bash-4.1# easy_install -U statsmodels
  -bash-4.1# python cpd.py
  </pre>
  
  <img src="changepoint-detection-1.png">
  <img src="changepoint-detection-2.png">

# K-means with pylab plots
  <pre>
  -bash-4.1# apt-get install python-matplotlib
  -bash-4.1# python km2.py test.txt
  </pre>
  
  <img src="kmeans-1.png">
  
# one-class SVM

<pre>
# git clone https://github.com/cjlin1/libsvm

Cloning into 'libsvm'...
remote: Counting objects: 3485, done.
remote: Total 3485 (delta 0), reused 0 (delta 0), pack-reused 3485
Receiving objects: 100% (3485/3485), 5.85 MiB | 189.00 KiB/s, done.
Resolving deltas: 100% (1857/1857), done.
Checking connectivity... done.

# cd libsvm/
~/libsvm# make
g++ -Wall -Wconversion -O3 -fPIC -c svm.cpp
g++ -Wall -Wconversion -O3 -fPIC svm-train.c svm.o -o svm-train -lm
g++ -Wall -Wconversion -O3 -fPIC svm-predict.c svm.o -o svm-predict -lm
g++ -Wall -Wconversion -O3 -fPIC svm-scale.c -o svm-scale

~/libsvm# cat test.cpp
~/libsvm# g++ test.cpp svm.cpp
~/libsvm# ./a.out

..*...*
optimization finished, #iter = 20
obj = 1.646537, rho = 1.646558
nSV = 4, nBSV = 0

2 2 2 2 2 1 2 2 2 2
2 2 1 1 1 1 1 1 2 2
2 1 1 1 1 1 1 1 1 2
2 1 1 1 1 1 1 1 1 2
2 1 1 1 1 1 1 1 1 1
2 1 1 1 1 1 1 1 1 1
2 1 1 1 1 1 1 1 1 2
2 1 1 1 1 1 1 1 1 2
2 2 1 1 1 1 1 1 2 2
2 2 2 2 1 1 2 2 2 2

</pre>


SMO algorithm

<pre>

(gdb) r                                                                                                                     
(gdb) bt
#0  Solver::Solve (this=0x7fffffffe0c0, l=4, Q=..., p_=0x62ba30, y_=0x62ba60 "\001\001\001\001", alpha_=0x62ba00, Cp=1, Cn=1, eps=0.001, si=0x7fffffffe210, shrinking=1) at svm.cpp:508
#1  0x0000000000407163 in solve_one_class (prob=0x7fffffffe490, param=0x7fffffffe3e0, alpha=0x62ba00, si=0x7fffffffe210) at svm.cpp:1556
#2  0x0000000000407a03 in svm_train_one (prob=0x7fffffffe490, param=0x7fffffffe3e0, Cp=0, Cn=0) at svm.cpp:1662
#3  0x0000000000409c3b in svm_train (prob=0x7fffffffe490, param=0x7fffffffe3e0) at svm.cpp:2117
#4  0x0000000000401b22 in main () at test.cpp:77

375// An SMO algorithm in Fan et al., JMLR 6(2005), p. 1889--1918                                                        376// Solves:
378//      min 0.5(\alpha^T Q \alpha) + p^T \alpha                                                                       379//                                                                                                                    380//              y^T \alpha = \delta
381//              y_i = +1 or -1                                                                                        382//              0 <= alpha_i <= Cp for y_i = 1                                                                        383//              0 <= alpha_i <= Cn for y_i = -1                                                                       384//                                                                                                                    385// Given:                                                                                                             386//                                                                                                                    387//      Q, p, y, Cp, Cn, and an initial feasible point \alpha                                                         388//      l is the size of vectors and matrices                                                                         389//      eps is the stopping tolerance
390//                                                                                                                    391// solution will be put in \alpha, objective value will be put in obj                                                 392//                                                                                                                    393class Solver {                                                                                                        394public:                             

504void Solver::Solve(int l, const QMatrix& Q, const double *p_, const schar *y_,                                        505                   double *alpha_, double Cp, double Cn, double eps,                                                  506                   SolutionInfo* si, int shrinking)                          

</pre>

# PostgreSQL driver

<pre>
postgres@flare:~$ psql sample
psql (9.6.0, サーバー 9.5.4)
"help" でヘルプを表示します.

sample=# create TABLE "test"(id INT, name varchar(40));
CREATE TABLE
bash# python pg1.py

</pre>

<pre>

postgres=# CREATE TABLE test (id int, name test);
postgres=# SELECT * FROM pg_stat_database WHERE datname = 'test';
postgres=# INSERT INTO test (id, name) VALUES (2, 'taro');
INSERT 0 1

postgres=# select * from test;
 id | name
 ----+------
   1 | taro
   2 | taro
   (2 行)

postgres=# SELECT * FROM pg_stat_database WHERE datname = 'sample';
 datid | datname | numbackends | xact_commit | xact_rollback | blks_read | blks_hit | tup_returned | tup_fetched | tup_inserted | tup_updated | tup_deleted | conflicts | temp_files | temp_bytes | deadlocks | blk_read_time | blk_write_time |          stats_reset
 -------+---------+-------------+-------------+---------------+-----------+----------+--------------+-------------+--------------+-------------+-------------+-----------+------------+------------+-----------+---------------+----------------+-------------------------------
  16384 | sample  |           0 |       22921 |            85 |       447 |   902708 |     11376251 |      150222 |           59 |          12 |          13 |         0 |          0 |          0 |         0 |             0 |              0 | 2016-10-26 18:05:04.122336+09
  (1 行)

</pre>

# chagepoint detection 2016-11-03

data
<img src="cpd-2016-11-03-01.png">

score
<img src="cpd-2016-11-03-02.png">

norm
<img src="cpd-2016-11-03-03.png">