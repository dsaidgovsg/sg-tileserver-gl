#!/usr/bin/env bash
set -euo pipefail

# Get this script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="${DIR}/.."

VENDOR_DIR="${ROOT_DIR}/vendor"
SPRITES_DIR="${ROOT_DIR}/data/sprites"
NODE_MODULES_BIN_DIR="${ROOT_DIR}/node_modules/.bin"

declare -A STYLES=(
    ["basic"]="maptiler-basic-gl-style/icons"
    ["bright"]="osm-bright-gl-style/icons"
    ["dark_matter"]="dark-matter-gl-style/icons"
    ["fiord_color"]="fiord-color-gl-style/icons"
    ["osm_liberty"]="osm-liberty/svgs/svgs_iconset"
    ["positron"]="positron-gl-style/icons"
    ["toner"]="maptiler-toner-gl-style/icons"
)

# Clean up previous files
find "${SPRITES_DIR}" -type f -not -name '.gitkeep' -exec rm {} \;

for STYLE in "${!STYLES[@]}"; do
    echo "> Generating sprites for ${STYLE}..."
    "${NODE_MODULES_BIN_DIR}/spritezero" "${SPRITES_DIR}/${STYLE}" "${VENDOR_DIR}/${STYLES[$STYLE]}"
    "${NODE_MODULES_BIN_DIR}/spritezero" --retina "${SPRITES_DIR}/${STYLE}@2x" "${VENDOR_DIR}/${STYLES[$STYLE]}"
done
