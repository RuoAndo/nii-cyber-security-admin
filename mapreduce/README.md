# streaming API

<pre>
# hadoop jar /usr/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-2.6.0.jar -input palo -output palo.out -mapper /usr/local/hadoop/mapper.py -reducer /usr/local/hadoop/reducer.py -file /usr/local/hadoop/mapper.py /usr/local/hadoop/reducer.py                                                                             
17/02/23 22:58:46 WARN streaming.StreamJob: -file option is deprecated, please use generic option -files instead.
packageJobJar: [/usr/local/hadoop/mapper.py, /usr/local/hadoop/reducer.py] [] /tmp/streamjob15038804099611948.jar tmpDir=null
17/02/23 22:58:47 INFO Configuration.deprecation: session.id is deprecated. Instead, use dfs.metrics.session-id
17/02/23 22:58:47 INFO jvm.JvmMetrics: Initializing JVM Metrics with processName=JobTracker, sessionId=
17/02/23 22:58:47 INFO jvm.JvmMetrics: Cannot initialize JVM Metrics with processName=JobTracker, sessionId= - already initialized
17/02/23 22:58:47 INFO mapred.FileInputFormat: Total input paths to process : 1
17/02/23 22:58:47 INFO mapreduce.JobSubmitter: number of splits:1
17/02/23 22:58:47 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_local229265404_0001
17/02/23 22:58:47 INFO mapred.LocalDistributedCacheManager: Localized file:/usr/local/hadoop/mapper.py as file:/tmp/hadoop-root/mapred/local/1487858327354/mapper.py
17/02/23 22:58:47 INFO mapred.LocalDistributedCacheManager: Localized file:/usr/local/hadoop/reducer.py as file:/tmp/hadoop-root/mapred/local/1487858327355/reducer.py
17/02/23 22:58:47 INFO mapreduce.Job: The url to track the job: http://localhost:8080/
17/02/23 22:58:47 INFO mapred.LocalJobRunner: OutputCommitter set in config null
17/02/23 22:58:47 INFO mapreduce.Job: Running job: job_local229265404_0001
17/02/23 22:58:47 INFO mapred.LocalJobRunner: OutputCommitter is org.apache.hadoop.mapred.FileOutputCommitter
17/02/23 22:58:47 INFO mapred.LocalJobRunner: Waiting for map tasks
17/02/23 22:58:47 INFO mapred.LocalJobRunner: Starting task: attempt_local229265404_0001_m_000000_0
17/02/23 22:58:47 INFO mapred.Task:  Using ResourceCalculatorProcessTree : [ ]
17/02/23 22:58:47 INFO mapred.MapTask: Processing split: hdfs://localhost:9000/user/root/palo:0+23647491
17/02/23 22:58:47 INFO mapred.MapTask: numReduceTasks: 1
17/02/23 22:58:47 INFO mapred.MapTask: (EQUATOR) 0 kvi 26214396(104857584)
17/02/23 22:58:47 INFO mapred.MapTask: mapreduce.task.io.sort.mb: 100
17/02/23 22:58:47 INFO mapred.MapTask: soft limit at 83886080
17/02/23 22:58:47 INFO mapred.MapTask: bufstart = 0; bufvoid = 104857600
17/02/23 22:58:47 INFO mapred.MapTask: kvstart = 26214396; length = 6553600
17/02/23 22:58:47 INFO mapred.MapTask: Map output collector class = org.apache.hadoop.mapred.MapTask$MapOutputBuffer
17/02/23 22:58:47 INFO streaming.PipeMapRed: PipeMapRed exec [/usr/local/hadoop/./mapper.py]
17/02/23 22:58:47 INFO Configuration.deprecation: mapred.tip.id is deprecated. Instead, use mapreduce.task.id
17/02/23 22:58:47 INFO Configuration.deprecation: mapred.local.dir is deprecated. Instead, use mapreduce.cluster.local.dir
17/02/23 22:58:47 INFO Configuration.deprecation: map.input.file is deprecated. Instead, use mapreduce.map.input.file
17/02/23 22:58:47 INFO Configuration.deprecation: mapred.skip.on is deprecated. Instead, use mapreduce.job.skiprecords
17/02/23 22:58:47 INFO Configuration.deprecation: map.input.length is deprecated. Instead, use mapreduce.map.input.length
17/02/23 22:58:47 INFO Configuration.deprecation: mapred.work.output.dir is deprecated. Instead, use mapreduce.task.output.dir
17/02/23 22:58:47 INFO Configuration.deprecation: map.input.start is deprecated. Instead, use mapreduce.map.input.start
17/02/23 22:58:47 INFO Configuration.deprecation: mapred.job.id is deprecated. Instead, use mapreduce.job.id
17/02/23 22:58:47 INFO Configuration.deprecation: user.name is deprecated. Instead, use mapreduce.job.user.name
17/02/23 22:58:47 INFO Configuration.deprecation: mapred.task.is.map is deprecated. Instead, use mapreduce.task.ismap
17/02/23 22:58:47 INFO Configuration.deprecation: mapred.task.id is deprecated. Instead, use mapreduce.task.attempt.id
17/02/23 22:58:47 INFO Configuration.deprecation: mapred.task.partition is deprecated. Instead, use mapreduce.task.partition
17/02/23 22:58:47 INFO streaming.PipeMapRed: R/W/S=1/0/0 in:NA [rec/s] out:NA [rec/s]
17/02/23 22:58:47 INFO streaming.PipeMapRed: R/W/S=10/0/0 in:NA [rec/s] out:NA [rec/s]
17/02/23 22:58:47 INFO streaming.PipeMapRed: R/W/S=100/0/0 in:NA [rec/s] out:NA [rec/s]
17/02/23 22:58:47 INFO streaming.PipeMapRed: R/W/S=1000/0/0 in:NA [rec/s] out:NA [rec/s]
17/02/23 22:58:47 INFO streaming.PipeMapRed: Records R/W=1316/1
17/02/23 22:58:47 INFO streaming.PipeMapRed: R/W/S=10000/9214/0 in:NA [rec/s] out:NA [rec/s]
17/02/23 22:58:47 INFO streaming.PipeMapRed: MRErrorThread done
17/02/23 22:58:47 INFO streaming.PipeMapRed: mapRedFinished
17/02/23 22:58:47 INFO mapred.LocalJobRunner: 
17/02/23 22:58:47 INFO mapred.MapTask: Starting flush of map output
17/02/23 22:58:47 INFO mapred.MapTask: Spilling map output
17/02/23 22:58:47 INFO mapred.MapTask: bufstart = 0; bufend = 262137; bufvoid = 104857600
17/02/23 22:58:47 INFO mapred.MapTask: kvstart = 26214396(104857584); kvend = 25952268(103809072); length = 262129/6553600
17/02/23 22:58:48 INFO mapred.MapTask: Finished spill 0
17/02/23 22:58:48 INFO mapred.Task: Task:attempt_local229265404_0001_m_000000_0 is done. And is in the process of committing
17/02/23 22:58:48 INFO mapred.LocalJobRunner: Records R/W=1316/1
17/02/23 22:58:48 INFO mapred.Task: Task 'attempt_local229265404_0001_m_000000_0' done.
17/02/23 22:58:48 INFO mapred.LocalJobRunner: Finishing task: attempt_local229265404_0001_m_000000_0
17/02/23 22:58:48 INFO mapred.LocalJobRunner: map task executor complete.
17/02/23 22:58:48 INFO mapred.LocalJobRunner: Waiting for reduce tasks
17/02/23 22:58:48 INFO mapred.LocalJobRunner: Starting task: attempt_local229265404_0001_r_000000_0
17/02/23 22:58:48 INFO mapred.Task:  Using ResourceCalculatorProcessTree : [ ]
17/02/23 22:58:48 INFO mapred.ReduceTask: Using ShuffleConsumerPlugin: org.apache.hadoop.mapreduce.task.reduce.Shuffle@1522e807
17/02/23 22:58:48 INFO reduce.MergeManagerImpl: MergerManager: memoryLimit=334338464, maxSingleShuffleLimit=83584616, mergeThreshold=220663392, ioSortFactor=10, memToMemMergeOutputsThreshold=10
17/02/23 22:58:48 INFO reduce.EventFetcher: attempt_local229265404_0001_r_000000_0 Thread started: EventFetcher for fetching Map Completion Events
17/02/23 22:58:48 INFO reduce.LocalFetcher: localfetcher#1 about to shuffle output of map attempt_local229265404_0001_m_000000_0 decomp: 393205 len: 393209 to MEMORY
17/02/23 22:58:48 INFO reduce.InMemoryMapOutput: Read 393205 bytes from map-output for attempt_local229265404_0001_m_000000_0
17/02/23 22:58:48 INFO reduce.MergeManagerImpl: closeInMemoryFile -> map-output of size: 393205, inMemoryMapOutputs.size() -> 1, commitMemory -> 0, usedMemory ->393205
17/02/23 22:58:48 INFO reduce.EventFetcher: EventFetcher is interrupted.. Returning
17/02/23 22:58:48 INFO mapred.LocalJobRunner: 1 / 1 copied.
17/02/23 22:58:48 INFO reduce.MergeManagerImpl: finalMerge called with 1 in-memory map-outputs and 0 on-disk map-outputs
17/02/23 22:58:48 INFO mapred.Merger: Merging 1 sorted segments
17/02/23 22:58:48 INFO mapred.Merger: Down to the last merge-pass, with 1 segments left of total size: 393201 bytes
17/02/23 22:58:48 INFO reduce.MergeManagerImpl: Merged 1 segments, 393205 bytes to disk to satisfy reduce memory limit
17/02/23 22:58:48 INFO reduce.MergeManagerImpl: Merging 1 files, 393209 bytes from disk
17/02/23 22:58:48 INFO reduce.MergeManagerImpl: Merging 0 segments, 0 bytes from memory into reduce
17/02/23 22:58:48 INFO mapred.Merger: Merging 1 sorted segments
17/02/23 22:58:48 INFO mapred.Merger: Down to the last merge-pass, with 1 segments left of total size: 393201 bytes
17/02/23 22:58:48 INFO mapred.LocalJobRunner: 1 / 1 copied.
17/02/23 22:58:48 INFO streaming.PipeMapRed: PipeMapRed exec [/usr/local/hadoop/./reducer.py]
17/02/23 22:58:48 INFO Configuration.deprecation: mapred.job.tracker is deprecated. Instead, use mapreduce.jobtracker.address
17/02/23 22:58:48 INFO Configuration.deprecation: mapred.map.tasks is deprecated. Instead, use mapreduce.job.maps
17/02/23 22:58:48 INFO streaming.PipeMapRed: R/W/S=1/0/0 in:NA [rec/s] out:NA [rec/s]
17/02/23 22:58:48 INFO streaming.PipeMapRed: R/W/S=10/0/0 in:NA [rec/s] out:NA [rec/s]
17/02/23 22:58:48 INFO streaming.PipeMapRed: R/W/S=100/0/0 in:NA [rec/s] out:NA [rec/s]
17/02/23 22:58:48 INFO streaming.PipeMapRed: R/W/S=1000/0/0 in:NA [rec/s] out:NA [rec/s]
17/02/23 22:58:48 INFO streaming.PipeMapRed: R/W/S=10000/0/0 in:NA [rec/s] out:NA [rec/s]
17/02/23 22:58:48 INFO streaming.PipeMapRed: MRErrorThread done
17/02/23 22:58:48 INFO streaming.PipeMapRed: Records R/W=65533/1
17/02/23 22:58:48 INFO streaming.PipeMapRed: mapRedFinished
17/02/23 22:58:48 INFO mapred.Task: Task:attempt_local229265404_0001_r_000000_0 is done. And is in the process of committing
17/02/23 22:58:48 INFO mapred.LocalJobRunner: 1 / 1 copied.
17/02/23 22:58:48 INFO mapred.Task: Task attempt_local229265404_0001_r_000000_0 is allowed to commit now
17/02/23 22:58:48 INFO output.FileOutputCommitter: Saved output of task 'attempt_local229265404_0001_r_000000_0' to hdfs://localhost:9000/user/root/palo.out/_temporary/0/task_local229265404_0001_r_000000
17/02/23 22:58:48 INFO mapred.LocalJobRunner: Records R/W=65533/1 > reduce
17/02/23 22:58:48 INFO mapred.Task: Task 'attempt_local229265404_0001_r_000000_0' done.
17/02/23 22:58:48 INFO mapred.LocalJobRunner: Finishing task: attempt_local229265404_0001_r_000000_0
17/02/23 22:58:48 INFO mapred.LocalJobRunner: reduce task executor complete.
17/02/23 22:58:48 INFO mapreduce.Job: Job job_local229265404_0001 running in uber mode : false
17/02/23 22:58:48 INFO mapreduce.Job:  map 100% reduce 100%
17/02/23 22:58:48 INFO mapreduce.Job: Job job_local229265404_0001 completed successfully
17/02/23 22:58:48 INFO mapreduce.Job: Counters: 38
        File System Counters
                FILE: Number of bytes read=789256
                FILE: Number of bytes written=1693627
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=47294982
                HDFS: Number of bytes written=17
                HDFS: Number of read operations=13
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=4
        Map-Reduce Framework
                Map input records=65533
                Map output records=65533
                Map output bytes=262137
                Map output materialized bytes=393209
                Input split bytes=88
                Combine input records=0
                Combine output records=0
                Reduce input groups=2
                Reduce shuffle bytes=393209
                Reduce input records=65533
                Reduce output records=2
                Spilled Records=131066
                Shuffled Maps =1
                Failed Shuffles=0
                Merged Map outputs=1
                GC time elapsed (ms)=4
                CPU time spent (ms)=0
                Physical memory (bytes) snapshot=0
                Virtual memory (bytes) snapshot=0
                Total committed heap usage (bytes)=497549312
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters 
                Bytes Read=23647491
        File Output Format Counters 
                Bytes Written=17
</pre>

# MapReduce 2

<pre>

# python mapper2.py < input2.txt | python reducer.py
a       1
b       2
c       3

</pre>

# setting up Hadoop

<pre>
Do not try this with root account.

【0】Java installation
sudo apt-get install openjdk-8-jdk 

【1】ダウンロード
wget https://archive.apache.org/dist/hadoop/core/hadoop-2.6.0/hadoop-2.6.0.tar.gz
//wget http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz

# 展開
tar xf hadoop-2.6.0.tar.gz
sudo mv hadoop-2.6.0 /usr/local/hadoop

# パスを通す
echo 'export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin' >> .bashrc
source .bashrc

【2】JAVA_HOMEの設定

$ vim ~/.bashrc

#一番下へ↓4行を追加

JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
export JAVA_HOME
PATH=$PATH:$JAVA_HOME/bin
export PATH

$ source ~/.bashrc

/usr/local/hadoop/etc/hadoop/hadoop-env.shの修正

#ファイルに追記
JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
export JAVA_HOME
PATH=$PATH:$JAVA_HOME/bin
export PATH

【3】sshの設定

# すでに鍵があるなら不要。ないならつくる。
mkdir -p ~/.ssh
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

【4】/usr/local/hadoop/etc/hadoop/core-site.xmlの設定

</pre>

<p>

<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
<property>
   <name>fs.default.name</name>
   <value>hdfs://localhost:9000</value>
</property>
</configuration>

</p>


<pre>

起動
root@ip-10-0-1-132:~# hostname localhost
# start-dfs.sh

【ファイルシステムの用意】

# hadoop fs -mkdir /user/
# hadoop fs -mkdir /user/root
# hadoop fs -ls


# time hadoop jar /usr/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-2.6.0.jar -mapper mapper4.py -reducer reducer4.py -file mapper4.py reducer4.py -input /user/root/input.txt -output /user/root/output/

real    0m5.015s
user    0m11.340s
sys     0m0.576s

</pre>

# hadoop pig

<pre>

# 公開鍵の追加
curl -s http://archive.cloudera.com/debian/archive.key | sudo apt-key add -

# ソースリストの記述
sudo vim /etc/apt/sources.list.d/cdh3.list
# deb     http://archive.cloudera.com/debian squeeze-cdh3 contrib
#　deb-src http://archive.cloudera.com/debian squeeze-cdh3 contrib

sudo apt-get update
sudo apt-get install hadoop-pig

</pre>
