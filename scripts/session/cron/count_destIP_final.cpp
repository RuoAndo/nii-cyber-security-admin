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

using namespace tbb;
using namespace std;

static bool verbose = false;
static bool silent = false;

const int size_factor = 2;

std::vector<int> v_bytes;
std::vector<int> v_sent;
std::vector<int> v_recv; 

/* first */
std::vector<string> all_pair;
/* second */
std::vector<int> all_count;
std::vector<int> all_bytes;

typedef concurrent_hash_map<MyString,int> StringTable;

/* count */
struct Tally {
    StringTable& table;
    Tally( StringTable& table_ ) : table(table_) {}
    void operator()( const blocked_range<MyString*> range ) const {
      int counter = 0;
        for( MyString* p=range.begin(); p!=range.end(); ++p ) {
            StringTable::accessor a;
            table.insert( a, *p );
            a->second += 1;
	    //a->second += v[counter];
	    counter = counter + 1;
        }
    }
};

/* bytes */
struct Tally_bytes {
    StringTable& table;
    Tally_bytes( StringTable& table_ ) : table(table_) {}
    void operator()( const blocked_range<MyString*> range ) const {
      int counter = 0;
        for( MyString* p=range.begin(); p!=range.end(); ++p ) {
            StringTable::accessor a;
            table.insert( a, *p );
	    a->second += v_bytes[counter];
	    // v_bytes.push_back(std::atoi(rec[2].c_str())); 
	    counter = counter + 1;
        }
    }
};

/* sent */
/*
struct Tally_sent {
    StringTable& table;
    Tally_sent( StringTable& table_ ) : table(table_) {}
    void operator()( const blocked_range<MyString*> range ) const {
      int counter = 0;
        for( MyString* p=range.begin(); p!=range.end(); ++p ) {
            StringTable::accessor a;
            table.insert( a, *p );
            // a->second += 1;
	    a->second += v_sent[counter];
	    counter = counter + 1;
        }
    }
};
*/

/* recv */
/*
struct Tally_recv {
    StringTable& table;
    Tally_recv( StringTable& table_ ) : table(table_) {}
    void operator()( const blocked_range<MyString*> range ) const {
      int counter = 0;
        for( MyString* p=range.begin(); p!=range.end(); ++p ) {
            StringTable::accessor a;
            table.insert( a, *p );
            // a->second += 1;
	    a->second += v_recv[counter];
	    counter = counter + 1;
        }
    }
};
*/

static MyString* Data;

static void CountOccurrences(int nthreads, int N) {

    int count_max;
  
    StringTable table;    
    tick_count t0 = tick_count::now();
    parallel_for( blocked_range<MyString*>( Data, Data+N, N ), Tally(table) );
    tick_count t1 = tick_count::now();

    StringTable table2;    
    tick_count t2 = tick_count::now();
    parallel_for( blocked_range<MyString*>( Data, Data+N, N ), Tally_bytes(table2) );
    tick_count t3 = tick_count::now();

    unsigned long n = 0;
    for( StringTable::iterator i=table.begin(); i!=table.end(); ++i ) {
        if( verbose && nthreads )
            printf("%s,%d\n",i->first.c_str(),i->second);
	all_count.push_back(i->second);
    	all_pair.push_back(i->first.c_str());
        n += i->second;	
    }

    count_max = unsigned(table.size());
    printf("1 total = %10lu  unique = %u  time = %g\n", n, unsigned(table.size()), (t1-t0).seconds());

    /* all_counts */
    n = 0;
    for( StringTable::iterator i=table2.begin(); i!=table2.end(); ++i ) {
        if( verbose && nthreads )
            printf("%s,%d\n",i->first.c_str(),i->second);
	all_bytes.push_back(i->second);	
        n += i->second;	
    }
    printf("2 total = %10lu  unique = %u  time = %g\n", n, unsigned(table2.size()), (t3-t2).seconds());

    printf("writing file with %d \n", count_max);
    
    int i;
    ofstream outputfile("destIP_final");  
    for(i=0; i< count_max-1 ; i++)
      {
	outputfile << all_pair[i] << "," << all_count[i] << "," << all_bytes[i] << std::endl;
      }
    
    outputfile.close();
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
	// const string csv_file = "all-500000000"; 
	vector<vector<string>> data; 

	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 

	    // std::string pair = rec[0] + "," + rec[1]; // + "," + rec[7];
	    std::string pair = rec[1]; 
	    
	    char* cstr = new char[pair.size() + 1]; 
	    std::strcpy(cstr, pair.c_str());        
	
	    Data[row] += cstr;

	    v_bytes.push_back(std::atoi(rec[2].c_str()));

	    delete[] cstr; 
	  }
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}
	
        if ( threads.first ) {
            for(int p = threads.first;  p <= threads.last; p = threads.step(p)) {
	        // if ( !silent )
		printf("threads = %d  ", p );
                task_scheduler_init init( p );
                CountOccurrences( p, N );
            }
        } else { // Number of threads wasn't set explicitly. Run serial and parallel version
            { // serial run
	      /*
                if ( !silent ) printf("serial run   ");
                task_scheduler_init init_serial(1);
                CountOccurrences(1);
	      */
            }
            { // parallel run (number of threads is selected automatically)
                if ( !silent ) printf("parallel run \n");
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
