// kernels.h
#pragma once

void run_slope_aspect(const float *dem, float *slope, float *aspect, int rows, int cols, float cell_size);

void run_curvature(const float *dem, float *plan, float *profile, int rows, int cols, float cell_size);
