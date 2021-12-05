#!/bin/bash

# This script combines the PNG frames into a video
# and then converts the video to a GIF

ROOT="$(dirname "$(realpath -s "$0")")"
VIDEO=${ROOT}/example.mp4
GIF=${ROOT}/example.gif

# Set the path to frames directory
FRAMES=${ROOT}/frames/png

# Create the video
echo "> Creating the video..."
ffmpeg -y -loop 1 -i "${FRAMES}/0.png" \
  -start_number 1 -i "${FRAMES}/%d.png" \
  -c:v libx264 -crf 17 \
  -filter_complex "drawbox=c=white:t=fill[bg];
                   [bg][0]overlay[st];
                   [st][1]overlay=shortest=1" \
  "${VIDEO}" >/dev/null 2>&1

# Set the path to the palette
PALETTE="${ROOT}/temp/palette.png"

# Set the filters
FILTERS="scale=900:-1:flags=lanczos"

# Create the GIF
echo "> Creating the GIF..."
ffmpeg -i "${VIDEO}" -vf "${FILTERS},palettegen" -y "${PALETTE}" >/dev/null 2>&1
ffmpeg -i "${VIDEO}" -i "${PALETTE}" -lavfi "${FILTERS} [x]; [x][1:v] paletteuse" -y "${GIF}" >/dev/null 2>&1
