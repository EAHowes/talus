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
