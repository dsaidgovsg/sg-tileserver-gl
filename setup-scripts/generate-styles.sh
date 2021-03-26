#!/usr/bin/env bash
set -euo pipefail

# Get this script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="${DIR}/.."

VENDOR_DIR="${ROOT_DIR}/vendor"
STYLES_DIR="${ROOT_DIR}/data/styles"
ORIGINAL_FORMATTED_DIR="${ROOT_DIR}/build/styles/original_formatted"
BOUNDARIES_REMOVED_DIR="${ROOT_DIR}/build/styles/boundaries_removed"

mkdir -p "${ORIGINAL_FORMATTED_DIR}"
mkdir -p "${BOUNDARIES_REMOVED_DIR}"

# These layer ids are emperically discovered by using https://maputnik.github.io/editor.
# Open the style.json in the editor, and select the boundary around Singapore to check the layer id
declare -A STYLES=(
    ["basic"]="maptiler-basic-gl-style/style.json|admin_sub"
    ["bright"]="osm-bright-gl-style/style.json|boundary-water"
    ["dark_matter"]="dark-matter-gl-style/style.json|boundary_country_z5-"
    ["fiord_color"]="fiord-color-gl-style/style.json|boundary_country_z5-"
    ["osm_liberty"]="osm-liberty/style.json|boundary_2_z5-"
    ["positron"]="positron-gl-style/style.json|boundary_country_z5-"
    ["toner"]="maptiler-toner-gl-style/style.json|boundary_country_z5-"
)

for STYLE in "${!STYLES[@]}"; do
    echo "> Removing boundary for ${STYLE}..."
    filepath="$(echo ${STYLES[$STYLE]} | cut -d '|' -f 1)"
    layer_id="$(echo ${STYLES[$STYLE]} | cut -d '|' -f 2)"

    # We format the original and immediately dump out to create a control copy for diff comparison
    cat "${VENDOR_DIR}/${filepath}" | jq -r . > "${ORIGINAL_FORMATTED_DIR}/${STYLE}.json"
    cat "${VENDOR_DIR}/${filepath}" | jq -r ".
        | .sources={\"openmaptiles\":.sources.openmaptiles}
        | del(.layers[] | select(.id==\"${layer_id}\" or (.source!=null and .source!=\"openmaptiles\")))
        " > "${BOUNDARIES_REMOVED_DIR}/${STYLE}.json"

    # Change all the URLs to local values
    cat "${BOUNDARIES_REMOVED_DIR}/${STYLE}.json" | jq -r ".
        | .sources.openmaptiles.url=\"mbtiles://{singapore}\"
        | if .sprite? then .sprite=\"${STYLE}\" else . end
        | if .glyphs? then .glyphs=\"{fontstack}/{range}.pbf?key={key}\" else . end
        " > "${STYLES_DIR}/${STYLE}.json"
done
