// implementation for io.c (input / output)

#include "include/io.h"
#include <stdio.h>
#include <stdlib.h>

// read binary float32 from disk
RasterData ReadDEM(const char *path) {

    // init for error returns
    RasterData empty = {NULL, 0};

    FILE *file = fopen(path, "rb");
    if (file == NULL) {
	perror("Error opening file");
	return empty;
    }

    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);
    size_t count = file_size / sizeof(float);

    // fill buffer with raster data
    float *buffer = malloc(count * sizeof(float));

    // reading error check
    size_t elements_read = fread(buffer, sizeof(float), count, file);
    if (elements_read != count) {
	free(buffer);
	fclose(file);
	return empty;
    }

    RasterData result = {buffer, count};

    fclose(file);
    return result;
}

// write float 32 arr to disk
void WriteDEM(const float *data, size_t count, const char *outpath) {

    FILE *file = fopen(outpath, "wb");
    if (file == NULL) {
	perror("Error opening file");
	return;
    }

    size_t elements_written = fwrite(data, sizeof(float), count, file);
    if (elements_written != count) {
	perror("Error writing to file");
	fclose(file);
	return;
    }

    fclose(file);
}

void FreeRasterData(RasterData *raster) {
    free(raster->data);
    raster->data = NULL;
    raster->valuesRead = 0;
}
