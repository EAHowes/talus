# Sobel Filter Concept and Math

A Solbel Filter is a 3x3 convolution kernel that estimates the gradient of elevation in the x (east-west) and y (north-south) directions. For every cell in the DEM, the kernel takes its 8 immediate neighbors and applies the following two 3x3 weight matricies:

```
Sobel X (east-west gradient):    Sobel Y (north-south gradient):
-1  0  +1                         +1  +2  +1
-2  0  +2                         0   0   0
-1  0  +1                         -1  -2  -1
```

> Horizontal / vertical neighbors are weighted more because they are closer in proximity to the center than diagionals (by a factor of √2).

From these two gradients, Slope and Aspect can be computed via:

```
slope = atan(sqrt(gx² + gy²) / cell_size) × (180 / π)
aspect = atan2(gy, -gx) × (180 / π)
```

> Slope is in degrees and Aspect is in compass bearing (0 = North)


