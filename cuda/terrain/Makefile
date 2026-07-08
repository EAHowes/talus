CC = nvcc

CFLAGS = -I. -lm -arch=sm_61

SRCS = io.c kernels/slope_aspect.cu kernels/curvature.cu kernels/tri.cu main.c

all: terrain

terrain: $(SRCS)
	$(CC) $(CFLAGS) $(SRCS) -o terrain

clean:
	rm -f terrain
