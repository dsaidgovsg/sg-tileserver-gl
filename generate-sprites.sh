#!/usr/bin/env bash
set -euo pipefail

VENDOR_DIR="vendor"
SPRITES_DIR="app/sprites"

declare -A STYLES=(
    ["basic"]="maptiler-basic-gl-style/icons"
    ["bright"]="osm-bright-gl-style/icons"
    ["dark_matter"]="dark-matter-gl-style/icons"
    ["fiord_color"]="fiord-color-gl-style/icons"
    ["osm_liberty"]="osm-liberty/svgs/svgs_iconset"
    ["positron"]="positron-gl-style/icons"
    ["toner"]="maptiler-toner-gl-style/icons"
)

for STYLE in "${!STYLES[@]}"; do
    echo "> Generating sprites for ${STYLE}..."
    ./node_modules/.bin/spritezero "${SPRITES_DIR}/${STYLE}" "${VENDOR_DIR}/${STYLES[$STYLE]}"
    ./node_modules/.bin/spritezero --retina "${SPRITES_DIR}/${STYLE}@2x" "${VENDOR_DIR}/${STYLES[$STYLE]}"
done
