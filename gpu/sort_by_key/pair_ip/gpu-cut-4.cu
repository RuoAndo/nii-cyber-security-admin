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

	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  thrust::host_vector<const char *> h_vec_1(data.size());
          thrust::host_vector<int> h_vec_2(data.size());

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    std::string pair = rec[1] + "," + rec[2];
	    
	    char* cstr = new char[pair.size() + 1]; 
	    std::strcpy(cstr, pair.c_str());        

	    Data[row] += cstr;

	    v_pair.push_back(pair.c_str());
	    v_count.push_back(rec[4].c_str());

	    h_vec_1.push_back(pair.c_str());
	    h_vec_2.push_back(atoi(rec[4].c_str()));
	    
	    delete[] cstr; 
	  }

	  thrust::device_vector<const char *> d_vec_1 = h_vec_1;
    	  thrust::device_vector<int> d_vec_2 = h_vec_2;

	  for(int i=0; i<10; i++)
      	   std::cout << h_vec_1[i] << "," << h_vec_2[i] << endl;

	  thrust::sort_by_key(d_vec_2.begin(), d_vec_2.end(), d_vec_1.begin(), thrust::greater<int>());

          thrust::copy(d_vec_1.begin(), d_vec_1.end(), h_vec_1.begin());
          thrust::copy(d_vec_2.begin(), d_vec_2.end(), h_vec_2.begin());

          std::cout << "sorted:" << endl;

          ofstream outputfile("tmp");  

          for(int i=0; i< h_vec_2.size(); i++)
	  {
	   std::string tmp_str = std::string(h_vec_1[i]);
	   
	   if (tmp_str.find("usr") == std::string::npos) 
	      	  outputfile << h_vec_2[i] << "," << tmp_str << endl;
          }

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
