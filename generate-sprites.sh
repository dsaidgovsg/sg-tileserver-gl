#!/usr/bin/env bash
set -euo pipefail

VENDOR_DIR="vendor"
SPRITES_DIR="app/sprites"

declare -A STYLES=(
    ["dark-matter"]="dark-matter-gl-style/icons"
    ["fiord-color"]="fiord-color-gl-style/icons"
    ["basic"]="maptiler-basic-gl-style/icons"
    ["toner"]="maptiler-toner-gl-style/icons"
    ["osm-bright"]="osm-bright-gl-style/icons"
    ["osm-liberty"]="osm-liberty/svgs/svgs_iconset"
    ["positron"]="positron-gl-style/icons"
)

for STYLE in "${!STYLES[@]}"; do
    echo "> Generating sprites for ${STYLE}..."
    ./node_modules/.bin/spritezero "${SPRITES_DIR}/${STYLE}" "${VENDOR_DIR}/${STYLES[$STYLE]}"
    ./node_modules/.bin/spritezero --retina "${SPRITES_DIR}/${STYLE}@2x" "${VENDOR_DIR}/${STYLES[$STYLE]}"
done
