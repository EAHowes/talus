package zones

import (
	"encoding/binary"
	"fmt"
	"math"
	"os"

	"github.com/eahowes/talus/internal/store/models"
)

type cluster struct {
	cells []int
}

func readRaster(path string) ([]float32, error) {

	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("failed to read raster %s: %w", path, err)
	}

	// convert raw bytes to float32 slice
    	floats := make([]float32, len(data)/4)
	for i := range floats {
		bits := binary.LittleEndian.Uint32(data[i*4 : i*4+4])
		floats[i] = math.Float32frombits(bits)
	}
	return floats, nil
}

func findClusters(slope, plan, tri []float32, rows, cols int, slopeThresh, triThresh float64) []cluster {

	visited := make([]bool, rows*cols)
	var clusters []cluster

	for i := 0; i < rows*cols; i++ {
		if float64(slope[i]) > slopeThresh && plan[i] > 0 && float64(tri[i]) > triThresh && !visited[i] {
			var c cluster
			queue:= []int{i}
			visited[i] = true

			for len(queue) > 0 {
				j := queue[0]
				queue = queue[1:]

				c.cells = append(c.cells, j)

				row := j / cols
				col := j % cols

				var neighbors []int

				// do not include boarders in cluster creation
				if row > 0 {
					neighbors = append(neighbors, (row-1)*cols+col)
				}
				if row < rows - 1 {
					neighbors = append(neighbors, (row+1)*cols+col)
				}
				if col > 0 {
					neighbors = append(neighbors, row*cols+(col-1))
				}
				if col < cols - 1 {
					neighbors = append(neighbors, row*cols+(col+1))
				}

				for _, n := range neighbors {
					if n >= 0 && n < rows*cols && 
					!visited[n] && 
					float64(slope[n]) > slopeThresh && 
					plan[n] > 0 && 
					float64(tri[n]) > triThresh {
						visited[n] = true
						queue = append(queue, n)
					}

				}

			}
			clusters = append(clusters, c)

		}
	}
	return clusters
}













