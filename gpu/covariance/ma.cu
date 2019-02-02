#include <thrust/device_vector.h>
#include <thrust/scan.h>
#include <thrust/transform.h>
#include <thrust/functional.h>
#include <thrust/sequence.h>
#include <thrust/random.h>
#include <iostream>
#include <iomanip>

#include "csv.hpp"
using namespace std;

// Efficiently computes the simple moving average (SMA) [1] of a data series
// using a parallel prefix-sum or "scan" operation.
//
// Note: additional numerical precision should be used in the cumulative summing
// stage when computing the SMA of large data series.  The most straightforward 
// remedy is to replace 'float' with 'double'.   Alternatively a Kahan or 
// "compensated" summation algorithm could be applied [2].
//
// [1] http://en.wikipedia.org/wiki/Moving_average#Simple_moving_average
// [2] http://en.wikipedia.org/wiki/Kahan_summation_algorithm


// compute the difference of two positions in the cumumulative sum and
// divide by the SMA window size w.
template <typename T>
struct minus_and_divide : public thrust::binary_function<T,T,T>
{
    T w;

    minus_and_divide(T w) : w(w) {}

    __host__ __device__
    T operator()(const T& a, const T& b) const
    {
        return (a - b) / w;
    }
};

template <typename InputVector, typename OutputVector>
void simple_moving_average(const InputVector& data, size_t w, OutputVector& output)
{
    typedef typename InputVector::value_type T;

    if (data.size() < w)
        return;
    
    // allocate storage for cumulative sum
    thrust::device_vector<T> temp(data.size() + 1);

    // compute cumulative sum
    thrust::exclusive_scan(data.begin(), data.end(), temp.begin());
    temp[data.size()] = data.back() + temp[data.size() - 1];

    // compute moving averages from cumulative sum
    thrust::transform(temp.begin() + w, temp.end(), temp.begin(), output.begin(), minus_and_divide<T>(T(w)));
}

int main( int argc, char* argv[] )
{
  int N = atoi(argv[2]);
  
  thrust::host_vector<float> h_vec_1(N);
  thrust::host_vector<float> h_vec_2(N);   

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data2; 

  Csv objCsv(csv_file);
  if (!objCsv.getCsv(data2)) {
     cout << "read ERROR" << endl;
     return 1;
  }

  for (int row = 0; row < data2.size(); row++) {
      vector<string> rec = data2[row]; 
      std::string timestamp = rec[0];

      h_vec_1.push_back(std::stof(rec[0].c_str()));
      h_vec_2[row] = std::stof(rec[1]);
  }

  // length of data series
  size_t n = N;

  // window size of the moving average
  size_t w = 4;

  // generate random data series
  thrust::device_vector<float> data(n);

  thrust::copy(h_vec_2.begin(), h_vec_2.end(), data.begin());   

  /*
  thrust::default_random_engine rng;
  thrust::uniform_int_distribution<int> dist(0, 10);
  for (size_t i = 0; i < n; i++)
    data[i] = static_cast<float>(dist(rng));
  */

  // allocate storage for averages
  thrust::device_vector<float> averages(data.size() - (w - 1));

  // compute SMA using standard summation
  simple_moving_average(data, w, averages);
 
  // print data series
  /*
  std::cout << "data series: [ ";
  for (size_t i = 0; i < data.size(); i++)
    std::cout << data[i] << " ";
  std::cout << "]" << std::endl;
  */

  // print moving averages
  std::cout << "simple moving averages (window = " << w << ")" << std::endl;
  for (size_t i = 0; i < averages.size(); i++)
  {
    // std::cout << "  [" << std::setw(2) << i << "," << std::setw(2) << (i + w) << ") = " << averages[i] << std::endl;
    std::cout << data[i] << "," << averages[i] << std::endl;
    }
  return 0;
}
