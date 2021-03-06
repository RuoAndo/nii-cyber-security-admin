#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>
#include <bitset>
#include <iterator> 

#include "util.h"
#include "csv.hpp"

using namespace std;

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
  std::vector<string> sv;
  thrust::host_vector<char*> hv;  

  // typedef vector::iterator Iterator; 

    try {
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

	    std::string sourceIP;
	    
	    for (const auto subStr : split_string_2(srcIP, del)) {
	      unsigned long ipaddr;
	      // std::cout << subStr << endl;
	      ipaddr = atoi(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr);
	      std::string trans_string = trans.to_string();
	      sourceIP = sourceIP + trans_string;
	    }

	    std::string destinationIP;
	    
	    for (const auto subStr : split_string_2(destIP, del)) {
	      unsigned long ipaddr;
	      // std::cout << subStr << endl;
	      ipaddr = atoi(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr);
	      std::string trans_string = trans.to_string();
	      destinationIP = destinationIP + trans_string;
	    }

            string pair_string = sourceIP + destinationIP;
	    // string pair_string = srcIP + destIP;

	    sv.push_back(pair_string);
	    // hv.push_back(pair_string);
	    // char cstr[];
	    // pair_string.copy(cstr, 10);

	    char* cstr = new char[pair_string.size() + 1]; 
	    std::char_traits<char>::copy(cstr, pair_string.c_str(), pair_string.size() + 1);
	    hv.push_back(cstr);
	    delete[] cstr; 

	    // char* cstr = new char[IPpair.size() + 1]; 
	    // std::strcpy(cstr, IPpair.c_str());        
	    //delete[] cstr; 
	  }
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}

	int size = sv.size();
	std::cout << "size:" << size << std::endl;

	// thrust::device_vector<int> flags(1000);
	// std::unique(sv.begin(), sv.end());

	std::sort(sv.begin(), sv.end());
	sv.erase(std::unique(sv.begin(), sv.end()), sv.end());

	int counter = 0;
	for(auto itr = sv.begin(); itr != sv.end(); ++itr) {
		 if(counter%100000==0)
		 	     std::cout << *itr << endl;
	         counter = counter + 1;
	}

	size = sv.size();
	std::cout << "size:" << size << std::endl;

	thrust::device_vector<char*> d_vec = hv;
	
	// thrust::device_vector<char*> d_vec_unique(hv.size());
	// thrust::device_vector<char*> d_vec;
	// thrust::copy(hv.begin(), hv.end(), d_vec.begin());

	size = d_vec.size();
	std::cout << "d_vec size:" << size << std::endl;
	
	auto new_vec = thrust::unique(d_vec.begin(),d_vec.end());
	
	size = 0;
	for(; new_vec != d_vec.end(); ++new_vec) {
		    std::cout << *new_vec << std::endl;
		    size++;
	}


	/*
	thrust::device_vector<char*> flags(hv.size());
	auto new_end = thrust::unique_by_key(d_vec.begin(),d_vec.end(),flags.begin());

	size = new_end.first - d_vec.begin();
	*/
	
	/*
	size = 0;
	for(auto itr = new_end.first; itr != flags.begin(); ++itr) {
        	 size++;
		 std::cout << *itr << std::endl;
	}
	*/

	// size = new_end.first - new_end.last;
	// thrust::device_vector<char*> d_vec_unique;
	// thrust::unique_copy(d_vec.begin(), d_vec.end(), d_vec_unique.begin()); 

	/*
	size = 0;
	for(auto itr = d_vec_unique.begin(); itr != d_vec_unique.end(); ++itr) {
        	 size++;
	}
	*/

	// size = d_vec_unique.size();
	std::cout << "size:" << size << std::endl;

        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
