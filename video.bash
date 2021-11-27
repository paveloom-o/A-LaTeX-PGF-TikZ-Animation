#!/bin/bash

# This script combines the PNG frames into a video
# and then converts the video to a GIF

SCRIPT_PATH="$(dirname "$(realpath -s "$0")")"
VIDEO=${SCRIPT_PATH}/example.mp4
GIF=${SCRIPT_PATH}/example.gif

# Set the path to frames directory
FRAMES=${SCRIPT_PATH}/frames/png

# Create the video
echo "> Creating a video..."
ffmpeg -y -loop 1 -i "${FRAMES}/0.png" \
          -start_number 1 -i "${FRAMES}/%d.png" \
          -c:v libx264 -crf 17 \
          -filter_complex overlay=shortest=1 \
          ${VIDEO} >/dev/null 2>&1

# Set the path to the palette
PALETTE="${SCRIPT_PATH}/temp/palette.png"

# Set the filters
FILTERS="scale=900:-1:flags=lanczos"

# Create a GIF
echo "> Creating a GIF..."
ffmpeg -i ${VIDEO} -vf "${FILTERS},palettegen" -y ${PALETTE} >/dev/null 2>&1
ffmpeg -i ${VIDEO} -i ${PALETTE} -lavfi "${FILTERS} [x]; [x][1:v] paletteuse" -y ${GIF} >/dev/null 2>&1
