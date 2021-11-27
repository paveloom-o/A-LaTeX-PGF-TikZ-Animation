#!/bin/bash

# This script converts PDFs to PNGs

SCRIPT_PATH="$(dirname "$(realpath -s "$0")")"

# Set the paths to frames directories
FRAMES_PDF=${SCRIPT_PATH}/frames/pdf
FRAMES_PNG=${SCRIPT_PATH}/frames/png
mkdir -p ${FRAMES_PNG}

# Get the files and count the total amount
FILES=(${FRAMES_PDF}/*.pdf)
TOTAL=${#FILES[@]}

# Initialize the file counter
i=0

echo "Converting PDFs to PNGs... (${i}/${TOTAL})"
for file in "${FILES[@]}"; do
    i=$(( i + 1 ))
    echo -e "\e[1A\e[KConverting PDFs to PNGs... (${i}/${TOTAL})"
    name=`basename ${file} .pdf`
    convert -density 550 ${file} -quality 100 ${FRAMES_PNG}/${name}.png || break
done
