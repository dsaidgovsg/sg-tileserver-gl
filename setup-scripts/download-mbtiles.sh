#!/usr/bin/env bash
set -euo pipefail

# Get this script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="${DIR}/.."

TEMPLATE_DIR="${ROOT_DIR}/template"
DATA_DIR="${ROOT_DIR}/data"
DATA_MBTILES_DIR="${DATA_DIR}/mbtiles"

# Env vars to override
MBTILES_TAG="${MBTILES_TAG:-}"
MBTILES_SKIP_DOWNLOAD="${MBTILES_SKIP_DOWNLOAD:-false}"

if ! command -v curl >/dev/null; then
    >&2 echo "Please install 'curl' to run this script!"
    exit 1
fi

if [[ -z "${MBTILES_TAG}" ]]; then
    >&2 echo "Please specify 'MBTILES_TAG' to target the mbtiles file to download (e.g. 0-18_20240612T202043Z)"
    exit 1
fi

# Clean up previous files
find "${DATA_MBTILES_DIR}" -type f -not -name '.gitkeep' -not -name "singapore_${MBTILES_TAG}.mbtiles" -exec rm {} \;
rm -f "${DATA_DIR}/config.json"

# Download the externally uploaded mbtiles
if [[ -f "${DATA_MBTILES_DIR}/singapore_${MBTILES_TAG}.mbtiles" ]]; then
    echo "singapore_${MBTILES_TAG}.mbtiles exists, skipping download"
elif [[ "${MBTILES_SKIP_DOWNLOAD}" == "true" ]]; then
    echo "MBTILES_SKIP_DOWNLOAD is set to true, skipping download"
else
    curl -fLO "https://github.com/dsaidgovsg/sg-tileserver-gl/releases/download/mbtiles/singapore_${MBTILES_TAG}.mbtiles"
    mv "singapore_${MBTILES_TAG}.mbtiles" "${DATA_MBTILES_DIR}/"
fi

# Copy required config
awk -v TAG="${MBTILES_TAG}" '{ sub(/\{\{ TAG }}/, TAG); print $0 }' "${TEMPLATE_DIR}/config.json" > "${DATA_DIR}/config.json"
