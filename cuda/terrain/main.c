#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include "include/io.h"
#include "include/kernels.h"

int main(int argc, char *argv[]) {

    if (argc != 10) {
	fprintf(stderr, "Usage: terrain <input> <slope> <aspect> <plan> <profile> <tri> <rows> <cols> <cell_size>\n");
	return 1;
    }

    const char *input_path = argv[1];
    const char *slope_path = argv[2];
    const char *aspect_path = argv[3];
    const char *plan_path = argv[4];
    const char *profile_path = argv[5];
    const char *tri_path = argv[6];
    int rows = atoi(argv[7]);
    int cols = atoi(argv[8]);
    float cell_size = (float)atof(argv[9]);

    RasterData dem = ReadDEM(input_path);

    if (dem.data == NULL) {
	fprintf(stderr, "Error: failed to read DEM from %s\n", input_path);
	return 1;
    }

    // Allocate space for arrays
    float *slope = malloc(dem.valuesRead * sizeof(float));
    float *aspect = malloc(dem.valuesRead * sizeof(float));
    float *plan = malloc(dem.valuesRead * sizeof(float));
    float *profile = malloc(dem.valuesRead * sizeof(float));
    float *tri = malloc(dem.valuesRead * sizeof(float));

    if (!slope || !aspect || !plan || !profile || !tri) {
	fprintf(stderr, "Error: failed to allocate output arrays \n");
	return 1;
    }

    // kernel launching and timing
    // slope aspect
    cudaEvent_t gpu_start, gpu_stop;
    cudaEventCreate(&gpu_start);
    cudaEventCreate(&gpu_stop);

    cudaEventRecord(gpu_start);
    run_slope_aspect(dem.data, slope, aspect, rows, cols, cell_size);
    cudaEventRecord(gpu_stop);
    cudaEventSynchronize(gpu_stop);

    float gpu_time_ms_slope_aspect;
    cudaEventElapsedTime(&gpu_time_ms_slope_aspect, gpu_start, gpu_stop);

    // cpu run + timer
    clock_t cpu_start = clock();
    slope_aspect_cpu(dem.data, slope, aspect, rows, cols, cell_size);
    clock_t cpu_end = clock();
    float cpu_time_ms_slope_aspect = (float)(cpu_end - cpu_start) / CLOCKS_PER_SEC * 1000.0f;



    // curvature
    cudaEventRecord(gpu_start);
    run_curvature(dem.data, plan, profile, rows, cols, cell_size);
    cudaEventRecord(gpu_stop);
    cudaEventSynchronize(gpu_stop);

    float gpu_time_ms_curvature;
    cudaEventElapsedTime(&gpu_time_ms_curvature, gpu_start, gpu_stop);

    cpu_start = clock();
    curvature_cpu(dem.data, plan, profile, rows, cols, cell_size);
    cpu_end = clock();
    float cpu_time_ms_curvature = (float)(cpu_end - cpu_start) / CLOCKS_PER_SEC * 1000.0f;



    // tri
    cudaEventRecord(gpu_start);
    run_tri(dem.data, tri, rows, cols);
    cudaEventRecord(gpu_stop);
    cudaEventSynchronize(gpu_stop);

    float gpu_time_ms_tri;
    cudaEventElapsedTime(&gpu_time_ms_tri, gpu_start, gpu_stop);

    cpu_start = clock();
    tri_cpu(dem.data, tri, rows, cols);
    cpu_end = clock();
    float cpu_time_ms_tri = (float)(cpu_end - cpu_start) / CLOCKS_PER_SEC * 1000.0f;

    cudaEventDestroy(gpu_start);
    cudaEventDestroy(gpu_stop);


    // save output rasters
    WriteDEM(slope, dem.valuesRead, slope_path);
    WriteDEM(aspect, dem.valuesRead, aspect_path);
    WriteDEM(plan, dem.valuesRead, plan_path);
    WriteDEM(profile, dem.valuesRead, profile_path);
    WriteDEM(tri, dem.valuesRead, tri_path);

    
    printf("gpu_time_ms_slope_aspect=%f\n", gpu_time_ms_slope_aspect);
    printf("cpu_time_ms_slope_aspect=%f\n", cpu_time_ms_slope_aspect);

    printf("gpu_time_ms_curvature=%f\n", gpu_time_ms_curvature);
    printf("cpu_time_ms_curvature=%f\n", cpu_time_ms_curvature);

    printf("gpu_time_ms_tri=%f\n", gpu_time_ms_tri);
    printf("cpu_time_ms_tri=%f\n", cpu_time_ms_tri);

    free(slope);
    free(aspect);
    free(plan);
    free(profile);
    free(tri);

    FreeRasterData(&dem);
    return 0;

}

