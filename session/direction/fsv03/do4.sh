#if __linux__ && defined(__INTEL_COMPILER)
#define __sync_fetch_and_add(ptr,addend) _InterlockedExchangeAdd(const_cast<void*>(reinterpret_cast<volatile void*>(ptr)), addend)
#endif
#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>   

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"
// #include "tbb/tbb_allocator.hz"
#include "utility.h"

#include "csv.hpp"

using namespace std;

std::vector<string> sv;
std::vector<string> sourceIP;
std::vector<string> destinationIP;
std::vector<string> timestamp;

std::vector<string> IPstring_src;
std::vector<string> IPstring_dst;

typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_timestamp_ingress;
static iTbb_timestamp_ingress TbbVec_timestamp_ingress; 

typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_timestamp_egress;
static iTbb_timestamp_egress TbbVec_timestamp_egress; 

std::vector<std::string> split_string_2(std::string str, char del) {
  int first = 0;
  int last = str.find_first_of(del);

  std::vector<std::string> result;

  while (first < str.size()) {
    std::string subStr(str, first, last - first);

    result.push_back(subStr);

    first = last + 1;
    last = str.find_first_of(del, first);

    if (last == std::string::npos) {
      last = str.size();
    }
  }

  return result;
}

int main( int argc, char* argv[] ) {

  int counter = 0;
  
  int N = atoi(argv[3]);  
  int netmask;

  std::map <int,int> found_flag;
  
    try {

	const string list_file = std::string(argv[1]); 
	vector<vector<string>> list_data; 
	
	const string session_file = std::string(argv[2]); 
	vector<vector<string>> session_data; 
	
	try {
	  Csv objCsv(list_file);
	  if (!objCsv.getCsv(list_data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }
	}
	catch (...) {
            cout << "EXCEPTION (session)" << endl;
	    return 1;
	}
  
	try {
	  Csv objCsv(session_file);
	  if (!objCsv.getCsv(session_data)) {
	    cout << "read ERROR" << endl;
		return 1;
	  }
	}
	catch (...) {
            cout << "EXCEPTION (session)" << endl;
	    return 1;
	}

	// init map
	  for(int i=0; i<N; i++)
	    found_flag[i] = 0;
	
	  counter = 0;
	  for (unsigned int row = 0; row < list_data.size(); row++) {

	    vector<string> rec = list_data[row];
	    // std::cout << rec[0] << std::endl;

	    const string argIP = rec[0]; 
	    std::string argIPstring;

	    netmask = atoi(rec[1].c_str());
	    
	    std::cout << argIP << "/" << netmask << std::endl;
	    
	    char del2 = '.';
	    
	    for (const auto subStr : split_string_2(argIP, del2)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atol(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      argIPstring = argIPstring + trans_string;
	    }
	    
	    // std::cout << "BITSET(arg):" << argIPstring << std::endl;


	      for (unsigned int row2 = 0; row2 < session_data.size(); row2++) {
		vector<string> rec2 = session_data[row2];
		std::string srcIP = rec2[4];

		for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
		  srcIP.erase(c,1);
		}
		
		// std::cout << srcIP << std::endl;
		
		std::string sessionIPstring;
		for (const auto subStr : split_string_2(srcIP, del2)) {
		  unsigned long ipaddr_src;
		  ipaddr_src = atol(subStr.c_str());
		  std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
		  std::string trans_string = trans.to_string();
		  sessionIPstring = sessionIPstring + trans_string;
		}
		
		// std::cout << "BITSET(session):" << sessionIPstring << std::endl;

	        // std::bitset<32> bit_argIP = std::bitset<32>(argIPstring);
	        // std::bitset<32> bit_sessionIP = std::bitset<32>(sessionIPstring);

		std::bitset<32> bit_argIP(argIPstring);
		std::bitset<32> bit_sessionIP(sessionIPstring);
		
		// std::cout << "BITSET(session):" << bit_sessionIP << std::endl;
		
		std::bitset<32> trans2(0xFFFFFFFF);
		trans2 <<= netmask;
		bit_sessionIP &= trans2;

		// std::cout << "BITSET(session*):" << bit_sessionIP << std::endl;
		// std::cout << "BITSET(list):" << bit_argIP << std::endl;
		
	        if(bit_sessionIP == bit_argIP)
		  {
		    // std::cout << "HIT" << std::endl;
		    std::string all_line;
		    all_line = "1";
		    // counter = 0;
		    for(auto itr = rec2.begin(); itr != rec2.end(); ++itr) {
		      // if(counter==0)
		      //	all_line = rec[0];
		      // else
		      all_line = all_line + "," + *itr;
		      // counter = counter + 1;
		    }
		    // std::cout << all_line << endl;
		    found_flag[row2] = 1;
		  }
		else
		  {
		    // found_flag[row2] = 0;
		    /*
		    std::string all_line;
		    counter = 0;
		    for(auto itr = rec.begin(); itr != rec.end(); ++itr) {
		      if(counter==0)
			all_line = rec[0];
		      else
			all_line = all_line + "," + *itr;
		      counter = counter + 1;
		    }
		    std::cout << all_line << endl;
		    */
		  }
	      }	     
	  }

	      /*
	      for (const auto& [key, value] : found_flag){
		if(value==1)
		  {
		    // std::cout << key << " => " << value << "\n";
		  counter = counter + 1;
		  }
	      }
	      */

	      for(auto itr = found_flag.begin(); itr != found_flag.end(); ++itr) {
		if(itr->second==1)
		  counter = counter + 1;
		// else
		//  counter = counter + 1;
	      }

	      std::cout << counter << "," << found_flag.size() << "," << session_data.size() << std::endl;
	      
	      const string file_rendered_outward = "rendered_outward_" + session_file;
	      ofstream outputfile_outward(file_rendered_outward);

	      const string file_rendered_inward = "rendered_inward_" + session_file;
	      ofstream outputfile_inward(file_rendered_inward);
	  
	      for (unsigned int row3 = 0; row3 < session_data.size(); row3++) {
		vector<string> rec3 = session_data[row3];
		if(found_flag[row3]==1)
		  {
		    std::string all_line;
		    all_line = "1";
		    for(auto itr = rec3.begin(); itr != rec3.end(); ++itr) {
		      all_line = all_line + "," + *itr;
		    }
		    // std::cout << all_line << std::endl;
		    outputfile_outward << all_line << std::endl;
		  }
		else
		  {
		    std::string all_line;
		    all_line = "0";
		    for(auto itr = rec3.begin(); itr != rec3.end(); ++itr) {
		      all_line = all_line + "," + *itr;
		    }
		    // std::cout << all_line << std::endl;
		    outputfile_inward << all_line << std::endl;
		  }	
	      }

	      outputfile_inward.close();
	      outputfile_outward.close();
	
              const string file_rendered_2 = "directed_msec_outward_" + session_file;
	      ofstream outputfile2(file_rendered_2);
	
              const string file_rendered_3 = "directed_msec_inward_" + session_file;
	      ofstream outputfile3(file_rendered_3);

	      outputfile3 << "date, sourceIP" << endl;
	      outputfile2 << "date, destIP" << endl;
	      
	      for (unsigned int row3 = 0; row3 < session_data.size(); row3++) {
		vector<string> rec3 = session_data[row3];
		if(found_flag[row3]==1)
		  {
		    std::string all_line;

		    std::string tms_org = rec3[0];
		    std::string tms = rec3[0];
		    std::string destIP = rec3[7];

		    for(size_t c = tms_org.find_first_of("\""); c != string::npos; c = c = tms_org.find_first_of("\"")){
		      tms_org.erase(c,1);
		    }
		    
		    for(size_t c = destIP.find_first_of("\""); c != string::npos; c = c = destIP.find_first_of("\"")){
		      destIP.erase(c,1);
		    }
		    
		    for(size_t c = tms.find_first_of("\""); c != string::npos; c = c = tms.find_first_of("\"")){
		      tms.erase(c,1);
		    }

		    for(size_t c = tms.find_first_of("/"); c != string::npos; c = c = tms.find_first_of("/")){
		      tms.erase(c,1);
		    }

		    for(size_t c = tms.find_first_of("."); c != string::npos; c = c = tms.find_first_of(".")){
		      tms.erase(c,1);
		    }

		    for(size_t c = tms.find_first_of(" "); c != string::npos; c = c = tms.find_first_of(" ")){
		      tms.erase(c,1);
		    }

		    for(size_t c = tms.find_first_of(":"); c != string::npos; c = c = tms.find_first_of(":")){
		      tms.erase(c,1);
		    }
		    
		    iTbb_timestamp_egress::accessor t;
		    TbbVec_timestamp_egress.insert(t, stoull(tms));
		    t->second += 1;

		    all_line = tms_org + "," + destIP;
		    outputfile2 << all_line << std::endl;
		}
		else
		  {
		    std::string all_line;

		    std::string tms_org = rec3[0];
		    std::string tms = rec3[0];
		    std::string sourceIP = rec3[4];

		    for(size_t c = tms_org.find_first_of("\""); c != string::npos; c = c = tms_org.find_first_of("\"")){
		      tms_org.erase(c,1);
		    }
		    
		    for(size_t c = sourceIP.find_first_of("\""); c != string::npos; c = c = sourceIP.find_first_of("\"")){
		      sourceIP.erase(c,1);
		    }
		    
		    for(size_t c = tms.find_first_of("\""); c != string::npos; c = c = tms.find_first_of("\"")){
		      tms.erase(c,1);
		    }

		    for(size_t c = tms.find_first_of("/"); c != string::npos; c = c = tms.find_first_of("/")){
		      tms.erase(c,1);
		    }

		    for(size_t c = tms.find_first_of("."); c != string::npos; c = c = tms.find_first_of(".")){
		      tms.erase(c,1);
		    }

		    for(size_t c = tms.find_first_of(" "); c != string::npos; c = c = tms.find_first_of(" ")){
		      tms.erase(c,1);
		    }

		    for(size_t c = tms.find_first_of(":"); c != string::npos; c = c = tms.find_first_of(":")){
		      tms.erase(c,1);
		    }

		    all_line = tms_org + "," + sourceIP;

		    iTbb_timestamp_ingress::accessor t;
		    TbbVec_timestamp_ingress.insert(t, stoull(tms));
		    t->second += 1;
		    
		    // std::cout << all_line << std::endl;
		    outputfile3 << all_line << std::endl;
		  }	

	      }

	      outputfile2.close();
	      outputfile3.close();

	      /*
	      typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_timestamp_ingress;
	      static iTbb_timestamp_ingress TbbVec_timestamp_ingress;
	      */

              const string file_rendered_4 = "directed_reduced_inward_" + session_file;
	      ofstream outputfile4(file_rendered_4);

	      for(auto itr = TbbVec_timestamp_ingress.begin(); itr != TbbVec_timestamp_ingress.end(); ++itr) {

		std::string timestamp = to_string(itr->first);                                                 
		outputfile4 << timestamp.substr(0,4) << "-" << timestamp.substr(4,2) << "-" 
			    << timestamp.substr(6,2) << " " << timestamp.substr(8,2) << ":" 
			    << timestamp.substr(10,2) << ":" << timestamp.substr(12,2) << "." 
			    << timestamp.substr(14,3) << "," << (long)itr->second << endl;                  
	      }	      

	      outputfile4.close();

              const string file_rendered_5 = "directed_reduced_outward_" + session_file;
	      ofstream outputfile5(file_rendered_5);

	      for(auto itr = TbbVec_timestamp_egress.begin(); itr != TbbVec_timestamp_egress.end(); ++itr) {

		std::string timestamp = to_string(itr->first);                                                 
		outputfile5 << timestamp.substr(0,4) << "-" << timestamp.substr(4,2) << "-" 
			    << timestamp.substr(6,2) << " " << timestamp.substr(8,2) << ":" 
			    << timestamp.substr(10,2) << ":" << timestamp.substr(12,2) << "." 
			    << timestamp.substr(14,3) << "," << (long)itr->second << endl;                  
	      }	      

	      outputfile5.close();


        return 0;
    }
    
    catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
