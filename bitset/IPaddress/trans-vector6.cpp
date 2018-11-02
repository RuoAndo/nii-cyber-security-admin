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

    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

        // Data = new MyString[N];

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    std::string srcIP = rec[4];
	    std::string destIP = rec[7];

	    for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
	      srcIP.erase(c,1);
	    }

	    for(size_t c = destIP.find_first_of("\""); c != string::npos; c = c = destIP.find_first_of("\"")){
	      destIP.erase(c,1);
	    }
	    
	    char del = '.';

	    std::string stringIP;
	    std::string IPstring;
	    stringIP = srcIP;
	    
	    for (const auto subStr : split_string_2(stringIP, del)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atoi(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      IPstring = IPstring + trans_string;
	    }

	    stringIP = destIP;
	    
	    for (const auto subStr : split_string_2(stringIP, del)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atoi(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      IPstring = IPstring + trans_string;
	    }

	    sourceIP.push_back(srcIP);
	    destinationIP.push_back(destIP);
	    
	    // string pair_string = stringIP;
	    std:cout << IPstring << endl;
	    sv.push_back(IPstring);	    
	  }
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}

	counter = 0;
	for(auto itr = sv.begin(); itr != sv.end(); ++itr) {
	     std::string tmp_string = *itr;
	     std::bitset<64> trans_tmp (tmp_string);
	     unsigned long long int n = bitset<64>(tmp_string).to_ullong();
	     // std::cout << srcIP << "," << destIP << "," << tmp_string << "," << n << endl;
	     std::cout << sourceIP[counter] << "," << destinationIP[counter] << "," << tmp_string << "," << n << endl;
	     counter = counter + 1;
	}
	
        utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}