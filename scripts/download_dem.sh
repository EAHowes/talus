#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <min_lon> <min_lat> <max_lon> <max_lat> [output_dir]"
    echo "Example: $0 -85.75 35.05 -85.55 35.25 ./dem"
    exit 1
fi

MIN_LON=$1
MIN_LAT=$2
MAX_LON=$3
MAX_LAT=$4
OUTPUT_DIR=${5:-./dem}

LAT=$(echo "$MAX_LAT" | awk '{print int ($1)+1}')
LON=$(echo "$MIN_LON" | awk '{printf "%03d", -$1}')

TILE="n${LAT}w${LON}"
FILENAME="USGS_13_${TILE}.tif"
URL="https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/TIFF/current/${TILE}/${FILENAME}"

mkdir -p "$OUTPUT_DIR"

echo "Tile: $TILE"
echo "URL:  $URL"
echo "Dest: $OUTPUT_DIR/$FILENAME"
echo ""

if [ -f "$OUTPUT_DIR/$FILENAME" ]; then
    echo "Already exists, skipping download."
    exit 0
fi

curl -L --progress-bar -o "$OUTPUT_DIR/$FILENAME" "$URL"
echo "Done: $OUTPUT_DIR/$FILENAME"
