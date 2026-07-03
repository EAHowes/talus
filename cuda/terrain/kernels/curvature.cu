#include <math.h>
#include <stdio.h>
#include "../include/io.h"
#include "include/kernels.h"

// Plan curvature: curvature perpendicular to the slope direction
// Profile Curvature: Curvature parallel to the slope direction

// plan curvature  = -2 * (d + f - 2*e) / cell_size^2
// profile curvature = -2 * (b + h - 2*e) / cell_size^2

// 3x3 matrix variable assignment
// 	     a b c
// 	     d e f
// 	     g h i

void curvature_cpu(const float *dem, float *plan, float *profile, int rows, int cols, float cell_size) {

    for (int row = 0; row < rows; row++) {
	for (int col = 0; col < cols; col++) {

	    // set boarder rows to inf since the filter wont have weights
	    if (row == 0 || row == rows - 1 || col == 0 || col == cols - 1) {
		plan[row * cols + col] = -9999;
		profile[row * cols + col] = -9999;
		continue;
	    }

	    float b = dem[(row-1) * cols + col];
	    float d = dem[row * cols + (col-1)];
	    float e = dem[row * cols + col];
	    float f = dem[row * cols + (col+1)];
	    float h = dem[(row+1) * cols + col];

	    plan[row * cols + col] = -2 * (d + f - 2*e) / (cell_size * cell_size);
	    profile[row * cols + col] = -2 * (b + h - 2*e) / (cell_size * cell_size);

	}
    }
}


__global__ void curvature_kernel(const float *dem, float *plan, float *profile, int rows, int cols, float cell_size) {

    // thread index calculation
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    // check if thread is in bounds
    if (row >= rows || col >= cols) return;

    // set boarder rows to inf since the filter wont have weights
    if (row == 0 || row == rows - 1 || col == 0 || col == cols - 1) {
	plan[row * cols + col] = -9999;
	profile[row * cols + col] = -9999;
	return;
    }   

    float b = dem[(row-1) * cols + col];
    float d = dem[row * cols + (col-1)];
    float e = dem[row * cols + col];
    float f = dem[row * cols + (col+1)];
    float h = dem[(row+1) * cols + col];

    plan[row * cols + col] = -2 * (d + f - 2*e) / (cell_size * cell_size);
    profile[row * cols + col] = -2 * (b + h - 2*e) / (cell_size * cell_size);
}
