REGISTER date.jar;

session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:chararray,dest_university_name:chararray);

P = FOREACH session GENERATE      
		   session_id as sid,
		   capture_time as ct,                             
	   	   destination_ip as dip,
		   source_ip as sip,
		   bytes as bytes;

-- dump P;
PF = FILTER P BY (sip MATCHES '.\\d+\\.\\d+\\.\\d+\\.\\d+') OR (dip MATCHES '.\\d+\\.\\d+\\.\\d+\\.\\d+'); 

--dump PF;
STORE PF INTO 'tuple-PF' USING PigStorage(',');

--STEP2

PF_2 = LOAD 'tuple-PF' USING PigStorage(',') AS (sid:long, ct:chararray,dip:chararray, sip:chararray, bytes:long);

Q = FOREACH PF_2 GENERATE
      sid as sid,
      date.DATE(ct) as ct,
      dip as dip,
      sip as sip,
      bytes as bytes;

--dump Q;

STORE Q INTO 'tuple-Q' USING PigStorage(',');

--STEP3
Q_2 = LOAD 'tuple-Q' USING PigStorage(',') AS (sid:long, ct:long ,dip:chararray, sip:chararray, bytes:long);

QG = GROUP Q_2 by sip;
QGF = FOREACH QG GENERATE
      	      group as label,
	      FLATTEN(Q_2.sid),
	      FLATTEN(Q_2.ct),
	      FLATTEN(Q_2.dip);	      
dump QGF;



