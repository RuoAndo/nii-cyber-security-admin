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
//  #include "tbb/tbb_allocator.hz"
#include "utility.h"

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>
#include "util.h" 

// #include <thrust/host_vector.h>
// #include <thrust/device_vector.h>
// #include <thrust/copy.h>
// #include <thrust/sort.h>
#include <thrust/functional.h>
#include <iostream>
#include <iterator>

#include "csv.hpp"
typedef std::basic_string<char,std::char_traits<char>,tbb::tbb_allocator<char> > MyString;

using namespace tbb;
using namespace std;

static bool verbose = false;
static bool silent = false;

// const int size_factor = 2;
// typedef concurrent_hash_map<MyString,int> StringTable;
typedef concurrent_hash_map<MyString,std::vector<string>> StringTable;
std::vector<string> v_pair;
std::vector<string> v_count;
static MyString* Data;

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

  // int counter = 0;
  int N = atoi(argv[2]);  
 
  try {
    tbb::tick_count mainStartTime = tbb::tick_count::now();
    srand(2);
    
    utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

    if ( silent ) verbose = false;

    Data = new MyString[N];

    const string csv_file = std::string(argv[1]); 
    vector<vector<string>> data; 

    /*
    thrust::host_vector<int> key_in(N);
    thrust::host_vector<int> value_in(N);      
    */

    /*
    thrust::device_vector<int> dkey_in;
    thrust::device_vector<int> dvalue_in;
    */

    long key[N];
    long value[N];   
    
    try {
      Csv objCsv(csv_file);
      if (!objCsv.getCsv(data)) {
	cout << "read ERROR" << endl;
	return 1;
      }

	 std::remove("tmp");
	 ofstream outputfile("tmp");
      
      	  for (int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    std::string timestamp = rec[0];

	    for(size_t c = timestamp.find_first_of("\""); c != string::npos; c = c = timestamp.find_first_of("\"")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of("."); c != string::npos; c = c = timestamp.find_first_of(".")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of(" "); c != string::npos; c = c = timestamp.find_first_of(" ")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of(":"); c != string::npos; c = c = timestamp.find_first_of(":")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of("/"); c != string::npos; c = c = timestamp.find_first_of("/")){
	      timestamp.erase(c,1);
	    }

	    // 2018 09 20 00 00 00 133
	    timestamp.pop_back();
	    timestamp.pop_back();
	    timestamp.pop_back();

	    /*
	    key_in.push_back(atoi(timestamp.c_str()));
	    value_in.push_back(1);
	    */

	    // std::cout << timestamp << endl;
	    key[row] = std::atol(timestamp.c_str());
	    // std::cout << key[row] << endl;
	    value[row] = 1;
	    
	    // outputfile << timestamp << std::endl;

	  }

	  /*
	  for(int i = 0; i<10; i++)
	  	  std::cout << key[i] << endl;
          */

          //thrust::host_vector<int> host_input{5, 1, 9, 3, 7};
	  //thrust::device_vector<int> device_vec(5);

	  // thrust::copy(host_input.begin(), host_input.end(), device_vec.begin());

	  // 昇順でソートする
	  // thrust::sort(device_vec.begin(), device_vec.end());
	  
	  thrust::device_vector<long> key_in(key, key + N);
	  thrust::device_vector<long> value_in(value, value + N);   
	  
	  // thrust::sort(key_in.begin(), key_in.end(),thrust::greater<int>());
	  thrust::sort(key_in.begin(), key_in.end());

	  thrust::device_vector<long> dkey_out(N,0);
	  thrust::device_vector<long> dvalue_out(N,0);
	  
	  auto new_end = thrust::reduce_by_key(key_in.begin(),
					       key_in.end(),
					       value_in.begin(),
					       dkey_out.begin(),
	  				       dvalue_out.begin());

	  long new_size = new_end.first - dkey_out.begin();

	  for(long i=0; i <new_size; i++)
	    {
	      // std::cout << dkey_out[i] << "," << dvalue_out[i] << endl;
	      outputfile << dkey_out[i] << "," << dvalue_out[i] << endl;
	    }
	  std::cout << std::endl;

	  /*
	  for(long i=0; i < 10;i++)
	    {
	      std::cout << dvalue_out[i] << ","; // << std::endl;
	    }
	  std::cout << std::endl;     
	  */
	  
	  outputfile.close();
    }
    catch (...) {
      cout << "EXCEPTION!" << endl;
      return 1;
    }
    
    delete[] Data;
    utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
    return 0;
	
  } catch(std::exception& e) {
    std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
  }
}
