#include <algorithm>
#include <cfloat>
#include <chrono>
#include <random>
#include <vector>

#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>
#include <random>

#include "csv.hpp"
using namespace std;

// A small data structure to do RAII for a dataset of 2-dimensional points.
struct Data {
  explicit Data(int size) : size(size), bytes(size * sizeof(float)) {
    cudaMalloc(&x, bytes);
    cudaMalloc(&y, bytes);
  }

  Data(int size, std::vector<float>& h_x, std::vector<float>& h_y)
  : size(size), bytes(size * sizeof(float)) {
    cudaMalloc(&x, bytes);
    cudaMalloc(&y, bytes);
    cudaMemcpy(x, h_x.data(), bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(y, h_y.data(), bytes, cudaMemcpyHostToDevice);
  }

  ~Data() {
    cudaFree(x);
    cudaFree(y);
  }

  void clear() {
    cudaMemset(x, 0, bytes);
    cudaMemset(y, 0, bytes);
  }

  float* x{nullptr};
  float* y{nullptr};
  int size{0};
  int bytes{0};
};

__device__ float
squared_l2_distance(float x_1, float y_1, float x_2, float y_2) {
  return (x_1 - x_2) * (x_1 - x_2) + (y_1 - y_2) * (y_1 - y_2);
}

// In the assignment step, each point (thread) computes its distance to each
// cluster centroid and adds its x and y values to the sum of its closest
// centroid, as well as incrementing that centroid's count of assigned points.
__global__ void assign_clusters(const float* __restrict__ data_x,
                                const float* __restrict__ data_y,
                                int data_size,
                                const float* __restrict__ means_x,
                                const float* __restrict__ means_y,
                                float* __restrict__ new_sums_x,
                                float* __restrict__ new_sums_y,
                                int k,
                                int* __restrict__ counts,
				int* clusterNo) {
  const int index = blockIdx.x * blockDim.x + threadIdx.x;
  if (index >= data_size) return;

  // printf("data_size %d \n", data_size);

  // Make global loads once.
  const float x = data_x[index];
  const float y = data_y[index];

  float best_distance = FLT_MAX;
  int best_cluster = 0;
  for (int cluster = 0; cluster < k; ++cluster) {
    const float distance =
        squared_l2_distance(x, y, means_x[cluster], means_y[cluster]);
    if (distance < best_distance) {
      best_distance = distance;
      best_cluster = cluster;
      // printf("best_cluster %d \n", cluster);
      clusterNo[index] = cluster;
    }
  }

  // Slow but simple.
  atomicAdd(&new_sums_x[best_cluster], x);
  atomicAdd(&new_sums_y[best_cluster], y);
  atomicAdd(&counts[best_cluster], 1);
}

// Each thread is one cluster, which just recomputes its coordinates as the mean
// of all points assigned to it.
__global__ void compute_new_means(float* __restrict__ means_x,
                                  float* __restrict__ means_y,
                                  const float* __restrict__ new_sum_x,
                                  const float* __restrict__ new_sum_y,
                                  const int* __restrict__ counts) {
  const int cluster = threadIdx.x;
  // Threshold count to turn 0/0 into 0/1.
  const int count = max(1, counts[cluster]);
  means_x[cluster] = new_sum_x[cluster] / count;
  means_y[cluster] = new_sum_y[cluster] / count;
}

int main(int argc, const char* argv[]) {

  // std::vector<float> h_x;
  // std::vector<float> h_y;

  // Load x and y into host vectors ... (omitted)

  int SHIFT = atoi(argv[1]);
  int k = 4;
  int number_of_iterations = 1000;

  // default = 10
  int N = 1024 << SHIFT;
  cout << N << endl;
  
  std::vector<float> h_x(N);
  std::vector<float> h_y(N);
 
  std::random_device rnd;
  std::mt19937 mt(rnd());
  std::uniform_int_distribution<> rand100(0, 99);
  std::uniform_int_distribution<> rand200(100, 199);
  std::uniform_int_distribution<> rand300(200, 299);
  std::uniform_int_distribution<> rand400(300, 399);  

  for(int i = 0; i < N; i++)
  {
	if (i % 4 == 0)
		h_x[i] = rand100(mt);
	if (i % 4 == 1)
		h_x[i] = rand200(mt);
	if (i % 4 == 2)
		h_x[i] = rand300(mt);
	if (i % 4 == 3)
		h_x[i] = rand400(mt);
		
	if (i % 4 == 0)
		h_y[i] = rand100(mt);
	if (i % 4 == 1)
		h_y[i] = rand200(mt);
	if (i % 4 == 2)
		h_y[i] = rand300(mt);
	if (i % 4 == 3)
		h_y[i] = rand400(mt);
  }

  /*
  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data2; 

  Csv objCsv(csv_file);
  if (!objCsv.getCsv(data2)) {
     cout << "read ERROR" << endl;
     return 1;
  }

  for (int row = 0; row < 1024; row++) {
      vector<string> rec = data2[row]; 
      h_x.push_back(std::stof(rec[0]));
      h_y.push_back(std::stof(rec[1]));
  }
  */

  const size_t number_of_elements = h_x.size();
  Data d_data(number_of_elements, h_x, h_y);

  // Random shuffle the data and pick the first
  // k points (i.e. k random points).
  std::random_device seed;
  std::mt19937 rng(seed());
  std::shuffle(h_x.begin(), h_x.end(), rng);
  std::shuffle(h_y.begin(), h_y.end(), rng);
  Data d_means(k, h_x, h_y);
  Data d_sums(k);

  int* d_counts;
  cudaMalloc(&d_counts, k * sizeof(int));
  cudaMemset(d_counts, 0, k * sizeof(int));

  int* h_counts;
  h_counts = (int *)malloc(k * sizeof(int));

  int* h_clusterNo;
  h_clusterNo = (int *)malloc(N * sizeof(int)); 

  int* d_clusterNo;
  cudaMalloc(&d_clusterNo, N * sizeof(int));
  cudaMemset(d_clusterNo, 0, N * sizeof(int));

  const int threads = 1024;
  const int blocks = (number_of_elements + threads - 1) / threads;

  for (size_t iteration = 0; iteration < number_of_iterations; ++iteration) {
    cudaMemset(d_counts, 0, k * sizeof(int));
    d_sums.clear();

    assign_clusters<<<blocks, threads>>>(d_data.x,
                                         d_data.y,
                                         d_data.size,
                                         d_means.x,
                                         d_means.y,
                                         d_sums.x,
                                         d_sums.y,
                                         k,
                                         d_counts,
					 d_clusterNo);
    cudaDeviceSynchronize();

    compute_new_means<<<1, k>>>(d_means.x,
                                d_means.y,
                                d_sums.x,
                                d_sums.y,
                                d_counts);
    cudaDeviceSynchronize();
  }

  cudaMemcpy(h_clusterNo, d_clusterNo, N * sizeof(int), cudaMemcpyDeviceToHost);

  std::remove("tmp");
  ofstream outputfile("tmp"); 

  for(int i=0; i < N; i++)
  {
	outputfile << h_x[i] << "," << h_y[i] << "," << h_clusterNo[i] << std::endl;
  	// std::cout << h_x[i] << "," << h_y[i] << "," << h_clusterNo[i] << std::endl;
  }

}
