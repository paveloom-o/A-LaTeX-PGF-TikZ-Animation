#!/bin/bash

# This script typesets PDF frames

ROOT="$(dirname "$(realpath -s "$0")")"
DATA="${ROOT}"/template/data.dat
TEMPLATE="${ROOT}"/template/template.tex
TEMP_TEX="${ROOT}"/temp/temp.tex
TEMP_PDF="${ROOT}"/temp/temp.pdf
FRAMES="${ROOT}"/frames/pdf

# Set the time difference between the points
DELTA=37

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
for ((i = -1; i < N; i++)); do
  echo -e "\e[1A\e[KTypesetting... ($((i + 2))/$((N + 1)))"
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
    sed -i 's|color=orange|color=orange, opacity=0|g' "${TEMP_TEX}"
    # Replace the coordinates
    sed -i "s|0.154, -0.0932|${_LINES[${i}]}|g" "${TEMP_TEX}"
    sed -i "s|-0.1712, 0.2586|${_LINES[$(((i + DELTA) % N))]}|g" "${TEMP_TEX}"
    sed -i "s|0.0467, 0.0096|${_LINES[$(((i + 2 * DELTA) % N))]}|g" "${TEMP_TEX}"
  fi
  # Typeset the frame
  compile || break
  # Move the PDF to the frames directory
  mv "${TEMP_PDF}" "${FRAMES}"/$((i + 1)).pdf
done
