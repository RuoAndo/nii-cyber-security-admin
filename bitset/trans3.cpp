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
//  #include "tbb/tbb_allocator.hz"
#include "utility.h"

#include "csv.hpp"
typedef std::basic_string<char,std::char_traits<char>,tbb::tbb_allocator<char> > MyString;
// typedef std::string<char,std::char_traits<char>,tbb::tbb_allocator<char> > MyString;

using namespace tbb;
using namespace std;

static bool verbose = false;
static bool silent = false;

struct hashCompare {
  return 1;
};

const int size_factor = 2;

// typedef concurrent_hash_map<MyString,string> StringTable;
typedef concurrent_hash_map<MyString,string> hashCompare;

template <typename List>
void split_string(const std::string& s, const std::string& delim, List& result)
{
  result.clear();

  using string = std::string;
  string::size_type pos = 0;

  while(pos != string::npos )
    {
      string::size_type p = s.find(delim, pos);

      if(p == string::npos)
	{
	  result.push_back(s.substr(pos));
	  break;
	}
      else {
	// std::cout << s.substr(pos, p - pos) << endl;
	result.push_back(s.substr(pos, p - pos));
	// result.push_back(";");
      }

      pos = p + delim.size();
    }
}

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

struct Tally {
    StringTable& table;
    Tally( StringTable& table_ ) : table(table_) {}
    void operator()( const blocked_range<MyString*> range ) const {
        for( MyString* p=range.begin(); p!=range.end(); ++p ) {
            StringTable::accessor a;
            table.insert( a, *p );
            // a->second += 1;
	    
	    // std::cout << a->first << std::endl;
	    std::string tmp_string =  p->c_str();

	    /*
	    for(size_t c = tmp_string.find_first_of("."); c != string::npos; c = c = tmp_string.find_first_of(".")){
	      tmp_string.erase(c,1);
	    }
	    */
	    
	    for(size_t c = tmp_string.find_first_of("\""); c != string::npos; c = c = tmp_string.find_first_of("\"")){
	      tmp_string.erase(c,1);
	    }
	    
	    /*
	    std::vector<string> result;
	    split_string(tmp_string, "/.", result);
	    */

	    char del = '.';

	    std::string ip_address;
	    
	    for (const auto subStr : split_string_2(tmp_string, del)) {
	      // std::cout << subStr << '\n';

	      unsigned long ipaddr;
	      ipaddr = atoi(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr);
	      std::string trans_string = trans.to_string();
	      // std::cout << subStr << ": " << trans_string << std::endl;     
	      ip_address = ip_address + "." + trans_string;
	    }
	    // std::cout << ip_address << std::endl;
	    
	    a->second = ip_address; 
	    
	    // std::list<string>::iterator itr;
	    // for (itr = result.begin(); itr != result.end(); itr++){
	    //  cout << *itr << " ";
	    // }
	    // cout << endl;
	    	    
	    /*
	    unsigned long ipaddr;
	    ipaddr = atoi(tmp_string.c_str());
	    std::bitset<32> trans =  std::bitset<32>(ipaddr);
	    std::string trans_string = trans.to_string();
	    std::cout << trans_string << std::endl;     
	    a->second = tmp_string; 
	    */
        }
    }
};

static MyString* Data;

static void CountOccurrences(int nthreads, int N) {
    StringTable table;

    tick_count t0 = tick_count::now();
    parallel_for( blocked_range<MyString*>( Data, Data+N, 1000 ), Tally(table) );
    tick_count t1 = tick_count::now();

    ofstream outputfile("transip");  
    
    int n = 0;
    for( StringTable::iterator i=table.begin(); i!=table.end(); ++i ) {
	outputfile << i->first.c_str() << "," << i->second << endl;	
        // n += i->second;
    }
    outputfile.close();
    
    printf("total = %d  unique = %u  time = %g\n", n, unsigned(table.size()), (t1-t0).seconds());
}

int main( int argc, char* argv[] ) {

  int counter = 0;
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

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    std::string pair = rec[4];
	    
	    char* cstr = new char[pair.size() + 1]; 
	    std::strcpy(cstr, pair.c_str());        
	
	    Data[row] += cstr;
	    delete[] cstr; 
	  }
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}
	
        if ( threads.first ) {
            for(int p = threads.first;  p <= threads.last; p = threads.step(p)) {
                if ( !silent ) printf("threads = %d  ", p );
                task_scheduler_init init( p );
                CountOccurrences( p, N );
            }
        } else { // Number of threads wasn't set explicitly. Run serial and parallel version
            { // serial run
	      // if ( !silent ) printf("serial run   ");
	      //task_scheduler_init init_serial(1);
              //  CountOccurrences(1);
            }
            { // parallel run (number of threads is selected automatically)
                if ( !silent ) printf("parallel run ");
                task_scheduler_init init_parallel;
                CountOccurrences(0, N);
            }
        }

        delete[] Data;

        utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
