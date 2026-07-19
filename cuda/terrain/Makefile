CC = nvcc

CFLAGS = -I. -lm -arch=sm_61 --compiler-bindir /usr/bin/gcc-12

SRCS = io.cu kernels/slope_aspect.cu kernels/curvature.cu kernels/tri.cu main.cu

all: terrain

terrain: $(SRCS)
	$(CC) $(CFLAGS) $(SRCS) -o terrain

clean:
	rm -f terrain
