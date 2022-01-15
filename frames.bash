#!/bin/bash

# This script typesets PDF frames

ROOT="$(dirname "$(realpath -s "$0")")"
DATA="${ROOT}"/template/data.dat
TEMPLATE="${ROOT}"/template/template.tex
TEMP_TEX="${ROOT}"/temp/temp.tex
TEMP_PDF="${ROOT}"/temp/temp.pdf
FRAMES="${ROOT}"/frames/pdf

# Set the time difference between the points
DELTA=25

# Expect the first argument to be a typesetting engine specification
if [ "${1}" = "--tectonic" ]; then
  compile() {
    tectonic -X compile "${TEMP_TEX}" >/dev/null 2>&1
  }
elif [ "${1}" = "--xelatex" ]; then
  compile() {
    xelatex -halt-on-error -output-directory="${ROOT}/temp" "${TEMP_TEX}" >/dev/null 2>&1
  }
elif [ "${1}" = "--pdflatex" ]; then
  compile() {
    pdflatex -halt-on-error -output-directory="${ROOT}/temp" "${TEMP_TEX}" >/dev/null 2>&1
  }
else
  echo -e "Choose between the following typesetting engines:" \
    "\`--tectonic\`, \`--xelatex\`, or \`--pdflatex\`."
  exit
fi

# Prepare the frames directory
mkdir -p "${FRAMES}"
# Copy the data file
cp "${DATA}" "${ROOT}"/temp/data.dat

# Put all lines of the data file in a Bash array
# (apparently, using `LINES` as the name is broken)
mapfile -t _LINES < <(cat "${DATA}")
# Get the number of lines
N=${#_LINES[@]}

# For each index
echo
for ((i = -1; i < N - 1; i++)); do
  echo -e "\e[1A\e[K> Typesetting... ($((i + 2))/${N})"
  # If it's the special case of `-1`,
  if [ "${i}" == -1 ]; then
    # Copy the template
    cp "${TEMPLATE}" "${TEMP_TEX}"
    # Don't plot the points
    sed -i 's|\\addplot\[mark=\*|% \\addplot\[mark=*|g' "${TEMP_TEX}"
  # Otherwise,
  else
    # Copy the template
    cp "${TEMPLATE}" "${TEMP_TEX}"
    # Hide the text
    sed -i 's|\\node|\\node\[opacity=0\]|g' "${TEMP_TEX}"
    # Hide the trajectory
    sed -i 's|color=safety_orange|color=orange, opacity=0|g' "${TEMP_TEX}"
    # Replace the coordinates
    sed -i "46s|0.229753, 0.000000|${_LINES[${i}]}|" "${TEMP_TEX}"
    sed -i "47s|0.652919, 0.943822|${_LINES[$(((i + DELTA) % (N - 1)))]}|" "${TEMP_TEX}"
    sed -i "48s|-0.767796, -0.199687|${_LINES[$(((i + 2 * DELTA) % (N - 1)))]}|" "${TEMP_TEX}"
    sed -i "49s|-0.767796, 0.199687|${_LINES[$(((i + 3 * DELTA) % (N - 1)))]}|" "${TEMP_TEX}"
    sed -i "50s|0.652919, -0.943822|${_LINES[$(((i + 4 * DELTA) % (N - 1)))]}|" "${TEMP_TEX}"
  fi
  # Typeset the frame
  compile || break
  # Move the PDF to the frames directory
  mv "${TEMP_PDF}" "${FRAMES}"/$((i + 1)).pdf
done
