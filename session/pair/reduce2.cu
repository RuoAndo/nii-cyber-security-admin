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

#include "csv.hpp"
typedef std::basic_string<char,std::char_traits<char>,tbb::tbb_allocator<char> > MyString;

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>
#include "util.h"

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

  int counter = 0;
  int N = atoi(argv[2]);
  string datestr = argv[3];

  char* tmpchar;

  struct in_addr inaddr;
  char *some_addr;

  std::string timestamp;

  thrust::host_vector<unsigned long long> h_vec_1(N);
  thrust::host_vector<long> h_vec_2(N);   

    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

        if ( silent ) verbose = false;

        Data = new MyString[N];

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	 std::remove("tmp-pair");
	 ofstream outputfile("tmp-pair");

	 outputfile << "timestamp,pair,counted" << endl;

      	  for (int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    // timestamp = rec[0];
	    // std::string pair = rec[1];

	    h_vec_1[row] = stoull(rec[0]);
	    h_vec_2[row] = stol(rec[1]);
	    }

	  for(long i=0; i <10; i++)
	  	   cout << h_vec_1[i] << "," << h_vec_2[i] << endl;
	  
	  thrust::device_vector<unsigned long long> key_in(N); // = h_vec_1;
	  thrust::device_vector<long> value_in(N); // = h_vec_2; 

	  thrust::copy(h_vec_1.begin(), h_vec_1.end(), key_in.begin());
	  thrust::copy(h_vec_2.begin(), h_vec_2.end(), value_in.begin());

	  thrust::device_vector<unsigned long long> dkey_out(h_vec_1.size());
	  thrust::device_vector<unsigned long long> dvalue_out(h_vec_2.size());

	  thrust::sort(key_in.begin(), key_in.end()); 

	  auto new_end = thrust::reduce_by_key(key_in.begin(),
					       key_in.end(),
					       value_in.begin(),
					       dkey_out.begin(),
	  				       dvalue_out.begin());

	  long new_size = new_end.first - dkey_out.begin();
	  cout << "size:" << key_in.size() << "," << new_size << endl;

	  thrust::host_vector<unsigned long long> hkey_out_2(new_size);
	  thrust::host_vector<long> hvalue_out_2(new_size);

	  for(int i=0;i<new_size;i++)
	  {
		hkey_out_2[i] = dkey_out[i];
		hvalue_out_2[i] = dvalue_out[i];
	  }
	  
          thrust::sort_by_key(hvalue_out_2.begin(), hvalue_out_2.end(), hkey_out_2.begin(), thrust::greater<long>());

	  for(long i=0; i <new_size; i++)
	  {
	    // cout << hkey_out_2[i] << "," << hvalue_out_2[i] << endl;
   	    
	    bitset<64> addr((unsigned long long)hkey_out_2[i]);
	    std::string addr_string = addr.to_string();
	    // cout << addr_string.substr(0,31) << "," << addr_string.substr(32,63) << "," << hvalue_out_2[i] << endl;
	    string addr_src = addr_string.substr(0,32);
	    string addr_dst = addr_string.substr(32,32);

	    bitset<32> bs(addr_src);
	    bitset<32> ds(addr_dst);
	    unsigned long long int s = bs.to_ullong();
	    unsigned long long int d = ds.to_ullong();
	                                                
            inaddr = { htonl(s) };
	    some_addr = inet_ntoa(inaddr);
	    string src_string = string(some_addr);

	    inaddr = { htonl(d) };
	    some_addr = inet_ntoa(inaddr);
	    string dst_string = string(some_addr);

	    std::string tmpstring = datestr;
	    outputfile << tmpstring.substr( 0, 4 )
		<< "-"
	        << tmpstring.substr( 4, 2 ) 
		<< "-"
		<< tmpstring.substr( 6, 2 ) 
		<< " "
		<< "00:00"
		<< ".000,";

	    outputfile << src_string << "," << dst_string << "," << hvalue_out_2[i] << endl;
          }

	  /*
	  thrust::host_vector<long> hkey_out_2(N,0);
	  thrust::host_vector<long> hvalue_out_2(N,0);

	  for(int i=0;i<new_size;i++)
	  {
		hkey_out_2[i] = dkey_out[i];
		hvalue_out_2[i] = dvalue_out[i];
	  }
	  */

	  // thrust::sort_by_key(hvalue_out_2, hvalue_out_2 + (int)new_size, hvalue_out_2);
          // thrust::sort_by_key(hvalue_out_2.begin(), hvalue_out_2.end(), hkey_out_2.begin(), thrust::greater<long>());

	  /*
	  for(long i=0; i <new_size; i++)
	  {
	    outputfile << hkey_out_2[i] << "," << hvalue_out_2[i] << endl;
          }
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
