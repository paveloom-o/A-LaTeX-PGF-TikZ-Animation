#!/bin/bash

# This script converts PDFs to PNGs

ROOT="$(dirname "$(realpath -s "$0")")"

# Set the paths to frames directories
FRAMES_PDF=${ROOT}/frames/pdf
FRAMES_PNG=${ROOT}/frames/png
mkdir -p "${FRAMES_PNG}"

# Get the files and count the total amount
FILES=("${FRAMES_PDF}"/*.pdf)
N=${#FILES[@]}

# Expect the first argument to be the density
if [ "${1}" = "" ]; then
  echo "Provide density as an argument to the script (e.g. 550)."
  exit
fi

echo
for ((i = 0; i < N; i++)); do
  echo -e "\e[1A\e[KConverting PDFs to PNGs... ($((i + 1))/${N})"
  PDF=${FILES[${i}]}
  PNG="${FRAMES_PNG}"/$(basename "${PDF}" .pdf).png
  convert -density "${1}" "${PDF}" -quality 100 "${PNG}" || break
  if [ "${i}" == 0 ] || [ "${i}" == 1 ]; then
    W=$(identify -format '%w' "${PNG}")
    H=$(identify -format '%h' "${PNG}")
    if [ $((W % 2)) != 0 ] || [ $((H % 2)) != 0 ]; then
      echo "One of the dimensions (${W}x${H}) isn't divisible by 2. Aborting."
      exit
    fi
  fi
done
