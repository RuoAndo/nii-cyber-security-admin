#include "../common/common.h"
#include <stdio.h>
#include <cuda_runtime.h>

__global__ void kernel(float *g_data, float value)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    g_data[idx] = g_data[idx] + value;
}

int main(int argc, char *argv[])
{
    int devID = 0;
    cudaDeviceProp deviceProps;
    CHECK(cudaGetDeviceProperties(&deviceProps, devID));
    //printf("> %s running on", argv[0]);
    printf("CUDA device [%s]\n", deviceProps.name);

    int num = 1 << atoi(argv[1]);
    printf("Vector size %d\n", num);
    int nbytes = num * sizeof(int);
    float value = 10.0f;

    float *host_a = 0;
    CHECK(cudaMallocHost((void **)&host_a, nbytes));
    memset(host_a, 0, nbytes);

    float *device_a = 0;
    CHECK(cudaMalloc((void **)&device_a, nbytes));
    CHECK(cudaMemset(device_a, 255, nbytes));

    dim3 block = dim3(atoi(argv[2]));
    dim3 grid  = dim3((num + block.x - 1) / block.x);

    cudaEvent_t stop;
    CHECK(cudaEventCreate(&stop));
    CHECK(cudaMemcpyAsync(device_a, host_a, nbytes, cudaMemcpyHostToDevice));
    kernel<<<grid, block>>>(device_a, value);
    CHECK(cudaMemcpyAsync(host_a, device_a, nbytes, cudaMemcpyDeviceToHost));
    CHECK(cudaEventRecord(stop, 0));

    unsigned long int counter = 0;
    while (cudaEventQuery(stop) == cudaErrorNotReady) {
        counter++;
    }

    printf("CPU executed %lu iterations while waiting for GPU to finish\n", counter);
    printf("host_a %f \n", *host_a);

    CHECK(cudaEventDestroy(stop));
    CHECK(cudaFreeHost(host_a));
    CHECK(cudaFree(device_a));

    CHECK(cudaDeviceReset());

}
