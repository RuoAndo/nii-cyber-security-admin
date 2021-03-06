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
//  #include "tbb/tbb_allocator.hz"
#include "utility.h"

#include "csv.hpp"

using namespace tbb;
using namespace std;

concurrent_vector < string > IPpair;
std::vector<string> sv;
std::vector<string> sourceIP;
std::vector<string> destinationIP;
std::vector<string> timestamp;

std::vector<string> IPstring_src;
std::vector<string> IPstring_dst;

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
  int N = atoi(argv[2]);  
  int netmask = atoi(argv[4]);
  int loop_flag;
  
  struct in_addr inaddr;
  char *some_addr;
  
    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	// IP to convert
	const string argIP = std::string(argv[3]); 
       
	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  for (unsigned int row = 0; row < data.size(); row++) {

	    // unsigned long long to string
	    
	    vector<string> rec = data[row];

	    // std::cout << "DIR:" << rec[0] << endl;

	    // std::string dir_flag = rec[0];
	    // std::cout << atoi(dir_flag.c_str()) << endl;
	    // if(atoi(dir_flag.c_str())==1)
	    if(rec[0] == "1")
	      {
		// std::cout << "HIT:" << rec[0] << std::endl; 
		std::string all_line = "1";
		counter = 0;
	      	for(auto itr = rec.begin(); itr != rec.end(); ++itr) {
		  if(counter > 0)
		    all_line = all_line + "," + *itr;
		  counter = counter + 1;
		 }
		 std::cout << all_line << std::endl;
	       continue;
	      }

	    else {
	    
	    std::string srcIP = rec[5];

	    // std::cout << rec[4] << std::endl;

	    for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
	      srcIP.erase(c,1);
	    }
	    
	    /*
	    unsigned long srcIP_long = std::atol(srcIP.c_str());

            inaddr = { htonl(srcIP_long) };
	    some_addr = inet_ntoa(inaddr);
	    string src_string = string(some_addr);
	    */
	    
	    std::string stringIP;
	    std::string argIPstring;
	    std::string address_per_line;
	    
	    char del2 = '.';

	    // converting argIP to bitset
	    
	    for (const auto subStr : split_string_2(argIP, del2)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atol(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      argIPstring = argIPstring + trans_string;
	    }
	    // std::cout << "BITSET:arg:" << argIPstring << std::endl;
	    
	    for (const auto subStr : split_string_2(srcIP, del2)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atol(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      address_per_line = address_per_line + trans_string;
	    }
	    // std::cout << "BITSET:per_line:" << address_per_line << std::endl;

	    // std::cout << endl;
	    // std::cout << "T:" << argIP << "/" << netmask << endl; 	

	    // argIP
	    unsigned long s = bitset<32>(argIPstring).to_ullong();
	    // std::cout << "T:" << IPstring << endl;
	    // argIP (bitset) 
	    std::bitset<32> bs2(argIPstring);
	    // std::cout << "T:" << bs2 << endl; 	

	    // address per line
	    // s = bitset<32>(address_per_line).to_ullong();
	    // std::cout << "C:" << src_string << "/" << netmask << endl;
	    std::bitset<32> trans =  std::bitset<32>(address_per_line);
	    // std::cout << "C:" << trans << endl;
	    
	    std::bitset<32> trans2(0xFFFFFFFF);
	    trans2 <<= netmask;
	    trans &= trans2;
	    // std::cout << "C:" << trans << std::endl; 

	    std::string all_line;
	    for(auto itr = rec.begin(); itr != rec.end(); ++itr) {
	      all_line = all_line + "," + *itr;
	    }

	    if(trans==bs2)
	      {
		// std::cout << "HIT" << std::endl;
		std::string all_line;
		all_line = "1";
		counter = 0;
		for(auto itr = rec.begin(); itr != rec.end(); ++itr) {
		  if(counter>0)
		    all_line = all_line + "," + *itr;
		  counter = counter + 1;
		}
		std::cout << all_line << endl;
	      }
	    else
	      {
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
	      } 
	    } // else
	  }
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}
	
        // utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
