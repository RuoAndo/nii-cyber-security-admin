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
#include "utility.h"

#include "csv.hpp"

#include <boost/spirit/include/qi.hpp>
#include <boost/spirit/include/phoenix.hpp>

using namespace boost::spirit;
using namespace boost;
using namespace std;

int main( int argc, char* argv[] ) {

  int counter = 0;
  
  int N = atoi(argv[2]);  
  double result;
  
  const string sfile = std::string(argv[1]); 
  vector<vector<string>> sdata; 
	  
  try {
    Csv objCsv(sfile);
    if (!objCsv.getCsv(sdata)) {
      cout << "read ERROR" << endl;
      return 1;
    }
  }
  catch (...) {
    cout << "EXCEPTION (READ)" << endl;
    return 1;
  }

  for (unsigned int row = 0; row < sdata.size(); row++) {
    vector<string> rec = sdata[row];

    std::string line_string = "0";
    for(auto itr = rec.begin(); itr != rec.end(); ++itr) {
      // line_string = line_string + "," + string(*itr);
      std::string tmp_rec = string(*itr);
      
      for(size_t c = tmp_rec.find_first_of("\""); c != string::npos; c = c = tmp_rec.find_first_of("\"")){
	tmp_rec.erase(c,1);
      }

      string::const_iterator iter = tmp_rec.begin(), end = tmp_rec.end();            
      bool success = qi::phrase_parse(iter, end, qi::double_, ',', result); 

      if (success && iter == end) {
	cout << "[success] " << result << ",";
      } else {
	cout << "* " << tmp_rec << ",";
      }
      
    }

    std::cout << endl;
    
  }    
    
  return 0;
}
