REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();                                                                                     
records = LOAD 'session-1000.txt' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);
filtered_records = FILTER records BY session_end_reason == 'unknown';
-- dump filtered_records
-- STORE filtered_records INTO 'tmp.txt';

filtered_records_all = Group records All;

center = foreach filtered_records_all generate
records.session_id as session_id,
AVG(records.source_port) as sport,
AVG(records.destination_port) as dport,
AVG(records.bytes) as byte;

dump center;

kmeans_cross = cross records, center;
distance = foreach kmeans_cross generate
records::session_id as label,
SQRT(POW(records::source_port - center::sport,2)) as norm;

dump distance;
