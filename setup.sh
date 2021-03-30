#!/usr/bin/env bash
set -euo pipefail

# Get this script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="${DIR}"

echo "Download external mbtiles..."
"${ROOT_DIR}/setup-scripts/download-mbtiles.sh"

echo "Generating fonts..."
"${ROOT_DIR}/setup-scripts/generate-fonts.sh"

echo "Generating sprites..."
"${ROOT_DIR}/setup-scripts/generate-sprites.sh"

echo "Generating styles..."
"${ROOT_DIR}/setup-scripts/generate-styles.sh"

echo "Completed!"
