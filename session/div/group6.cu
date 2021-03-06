#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <pthread.h>

#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <bitset>

// #include <eigen3/Eigen/Dense>
// #include <eigen3/Eigen/Core>
// #include <eigen3/Eigen/SVD>

#include <random>
#include <map>

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>
// #include "util.h"
#include "timer.h" 

#include <cstdio>
#include <cctype>
#include <iostream>
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"

using namespace tbb;
using namespace std;

#define THREAD_NUM 60

// using namespace Eigen;
using namespace std;

struct HashCompare {
    static size_t hash( const char& x ) {
        return (size_t)x;
    }
    static bool equal( const char& x, const char& y ) {
        return x==y;
    }
};

// typedef concurrent_hash_map<unsigned long, unsigned long, HashCompare> CharTable;
// typedef concurrent_hash_map<unsigned long, unsigned long> CharTable;
typedef concurrent_hash_map<unsigned long, std::vector<unsigned long>> CharTable;
// typedef concurrent_hash_map<MyString,std::vector<string>> StringTable; 
static CharTable table;

typedef struct _thread_arg {
    int id;
} thread_arg_t;

typedef struct _result {
  map<long, long> m;
  pthread_mutex_t mutex;
} result_t;
result_t result;

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

void *thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int i, j, k;
    int label = 0;
    unsigned int key = 0;
    unsigned int value = 0;
    int counter = 0;
    string src;
    string dst;
    int progress = 0;

    string fname;

    if(std::to_string(targ->id).length()==1)
        fname = "x0" + std::to_string(targ->id);

    if(std::to_string(targ->id).length()==2)
        fname = "x" + std::to_string(targ->id);
	
    // string fname = std::to_string(targ->id);
    std::cout << "thread ID: " << targ->id << " - start." << std::endl;

    ifstream ifs(fname);
 
    string str;
    while(getline(ifs,str)){
      string token;
      istringstream stream(str);
      counter = 0;
      while(getline(stream,token,',')){
	
	if(counter==0)
	  src = token;

	if(counter==4)
	  dst = token;

        counter = counter + 1;
       }

	string tmp_string_first = src;
	string tmp_string_second = dst;

	for(size_t c = tmp_string_first.find_first_of("\""); c != string::npos; c = c = tmp_string_first.find_first_of("\"")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_first.find_first_of(":"); c != string::npos; c = c = tmp_string_first.find_first_of(":")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_first.find_first_of(" "); c != string::npos; c = c = tmp_string_first.find_first_of(" ")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_first.find_first_of("/"); c != string::npos; c = c = tmp_string_first.find_first_of("/")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_first.find_first_of("\""); c != string::npos; c = c = tmp_string_first.find_first_of("\"")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_first.find_first_of("."); c != string::npos; c = c = tmp_string_first.find_first_of(".")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_second.find_first_of("\""); c != string::npos; c = c = tmp_string_second.find_first_of("\"")){
	      tmp_string_second.erase(c,1);
	}

	char del = '.';

	std::string stringIP;
	std::string IPstring;
	    	    
        stringIP = tmp_string_second;
	for (const auto subStr : split_string_2(stringIP, del)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atoi(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      IPstring = IPstring + trans_string;
	}  

	unsigned long n = bitset<64>(IPstring).to_ullong();
	long m = atol(tmp_string_first.c_str());
	
	// cout << src << "," << n << "," << dst << "," << m << endl;

	CharTable::accessor a;
	table.insert(a, m);
	// table.insert(a, n);
	a->second.push_back(n);
	// a->second.push_back( n );

	/*
	pthread_mutex_lock(&result.mutex);
	result.m.insert(pair<long, long>(m,n));
	pthread_mutex_unlock(&result.mutex);
	*/
    
	if(progress%100000==0)
	{
		cout <<  "progress count:" << targ->id << "," << progress << "," << table.size() << endl;
		// cout <<  "progress count:" << targ->id << "," << progress << "," << endl;
        }
	progress = progress + 1;
	/*
	for( CharTable::iterator i=table.begin(); i!=table.end(); ++i )
             cout << i->first << "," << i->second;
        cout << endl;
	*/
    }

    /*    
    for( CharTable::iterator i=table.begin(); i!=table.end(); ++i )
        cout << i->first << "(" << i->second << ") ";
    cout << endl;
    */

    std::cout << "thread ID: " << targ->id << " - done." << std::endl;
    return;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];

    string tmp_string_first;
    string tmp_string_second;

    unsigned int t, travdirtime;   

    int i;
    int counter;

    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        pthread_create(&handle[i], NULL, thread_func, (void*)&targ[i]);
	// pthread_create(&handle[i], NULL, thread_func, (void*)&targ[i]);
    }

    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    // std::remove("tmp");
    // ofstream outputfile("tmp");

    thrust::host_vector<long> h_vec_1(table.size());
    thrust::host_vector<long> h_vec_2(table.size());

    counter = 0;
    for( CharTable::iterator i=table.begin(); i!=table.end(); ++i )
    {

      for(auto itr = i->second.begin(); itr != i->second.end(); ++itr) {
      	       // outputfile << i->first << "," << *itr << endl;
	       h_vec_1[counter] = long(i->first);
   	       h_vec_2[counter] = long(*itr);
      }
      
      if(counter%1000000==0)
      {
	std::cout << "counter:" << counter << endl;
      }
      
      counter = counter + 1;
    }

    for(i=0; i<10; i++)
    {
	cout << h_vec_1[i] << "," << h_vec_2[i] << endl;
    }

    start_timer(&t);

    thrust::device_vector<long> d_vec_1 = h_vec_1;
    thrust::device_vector<long> d_vec_2 = h_vec_2;
    thrust::sort_by_key(d_vec_1.begin(), d_vec_1.end(), d_vec_2.begin());

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    for(i=0; i<10; i++)
    {
	cout << d_vec_1[i] << "," << d_vec_2[i] << endl;
    }      

    // outputfile.close();

   // std::cout << "map size() is " << result.m.size() << std::endl;
}
