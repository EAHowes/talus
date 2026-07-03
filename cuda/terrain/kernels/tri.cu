#include <math.h>
#include <stdio.h>
#include "../include/io.h"
#include "include/kernels.h"

// TRI = (|e-a| + |e-b| + |e-c| + |e-d| + |e-f| + |e-g| + |e-h| + |e-i|) / 8

// 3x3 matrix variable assignment
// 	     a b c
// 	     d e f
// 	     g h i

void tri_cpu(const float *dem, float *tri, int rows, int cols) {

    for (int row = 0; row < rows; row++) {
	for (int col = 0; col < cols; col++) {

	    if (row == 0 || row == rows - 1 || col == 0 || col == cols - 1) {
		tri[row * cols + col] = -9999;
		continue;
	    }

	    float a = dem[(row-1) * cols + (col-1)];
	    float b = dem[(row-1) * cols + col];
	    float c = dem[(row-1) * cols + (col+1)];
	    float d = dem[row * cols + (col-1)];
	    float e = dem[row * cols + col];
	    float f = dem[row * cols + (col+1)];
	    float g = dem[(row+1) * cols + (col-1)];
	    float h = dem[(row+1) * cols + col];
	    float i = dem[(row+1) * cols + (col+1)];

	    tri[row * cols + col] = (fabsf(e-a) + fabsf(e-b) + fabsf(e-c) + fabsf(e-d) + fabsf(e-f) + fabsf(e-g) + fabsf(e-h) + fabsf(e-i)) / 8.0f;

	}
    }
}

__global__ void tri_kernel(const float *dem, float *tri, int rows, int cols) {

    // thread index calculation
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    // check if thread is in bounds
    if (row >= rows || col >= cols) return;

    // set boarder rows to inf since the filter wont have weights
    if (row == 0 || row == rows - 1 || col == 0 || col == cols - 1) {
	tri[row * cols + col] = -9999;
	return;
    }   

    float a = dem[(row-1) * cols + (col-1)];
    float b = dem[(row-1) * cols + col];
    float c = dem[(row-1) * cols + (col+1)];
    float d = dem[row * cols + (col-1)];
    float e = dem[row * cols + col];
    float f = dem[row * cols + (col+1)];
    float g = dem[(row+1) * cols + (col-1)];
    float h = dem[(row+1) * cols + col];
    float i = dem[(row+1) * cols + (col+1)];

    tri[row * cols + col] = (fabsf(e-a) + fabsf(e-b) + fabsf(e-c) + fabsf(e-d) + fabsf(e-f) + fabsf(e-g) + fabsf(e-h) + fabsf(e-i)) / 8.0f;
}


void run_tri(const float *dem, float *tri, int rows, int cols) {
    float *d_dem;
    float *d_tri;

    size_t count = rows * cols;

    // create buffers and copy data to GPU
    cudaMalloc((void**)&d_dem, count * sizeof(float));
    cudaMemcpy(d_dem, dem, count * sizeof(float), cudaMemcpyHostToDevice);

    cudaMalloc((void**)&d_tri, count * sizeof(float));
    
    dim3 block (16,16);
    dim3 grid((cols + 15) / 16, (rows + 15) / 16);

    tri_kernel<<<grid, block>>>(d_dem, d_tri, rows, cols);
    cudaDeviceSynchronize();

    // copy data back to cpu from GPU
    cudaMemcpy(tri, d_tri, count * sizeof(float), cudaMemcpyDeviceToHost);

    cudaFree(d_dem);
    cudaFree(d_tri);
}
