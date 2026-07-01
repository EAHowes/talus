// header file for io.c (input / output)
// reads a float32 binary raster from disk into a host-side array
// writes float32 arrays back to disk as binary files with slope, aspect, curvature, and TRI outputs

#pragma once
#include <stddef.h>

typedef struct {
    float *data;
    size_t valuesRead;
} RasterData;

// read binary float32 from disk
RasterData ReadDEM(const char *path);

// write float 32 arr to disk
void WriteDEM(const float *data, size_t count, const char *outpath);

// destructor
void FreeRasterData(RasterData *raster);
