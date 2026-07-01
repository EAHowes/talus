#include <math.h>
#include <stdio.h>
#include "../include/io.h"

// 3x3 matrix variable assignment
// 	     a b c
// 	     d e f
// 	     g h i

// non parallelized sobel filter for benchmarking
void slope_aspect_cpu(const float *dem, float *slope, float *aspect, int rows, int cols, float cell_size) {

    for (int row = 0; row < rows; row++) {
	for (int col = 0; col < cols; col++) {

	    // set boarder rows to inf since the filter wont have weights
	    if (row == 0 || row == rows - 1 || col == 0 || col == cols - 1) {
		slope[row * cols + col] = -9999;
		aspect[row * cols + col] = -9999;
		continue;
	    }

	    // e = dem[row * cols + col]
	    float a = dem[(row-1) * cols + (col-1)];
	    float b = dem[(row-1) * cols + col];
	    float c = dem[(row-1) * cols + (col+1)];
	    float d = dem[row * cols + (col-1)];
	    float f = dem[row * cols + (col+1)];
	    float g = dem[(row+1) * cols + (col-1)];
	    float h = dem[(row+1) * cols + col];
	    float i = dem[(row+1) * cols + (col+1)];

	    float gx = (c - a) + 2*(f - d) + (i - g);
	    float gy = (a - g) + 2*(b - h) + (c - i);

	    slope[row * cols + col] = atanf(sqrtf(gx * gx + gy * gy) / cell_size) * (180.0f / M_PI);

	    // if there is no aspect there is a flat plateau. This is meaningless for this case so set -9999
            if (gx == 0.0f && gy == 0.0f) {
                aspect[row * cols + col] = -9999;
            } else {
		// since atan only ranges from -180 to 180 deg, rotate so 0 indicates north and shift negative vals into 0-360 range
                float asp = 90.0f - atan2f(gy, -gx) * (180.0f / M_PI);
                if (asp < 0.0f) asp += 360.0f;
                aspect[row * cols + col] = asp;
	   }
	}
    }
}
