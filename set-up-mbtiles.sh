#!/usr/bin/env bash
set -euo pipefail

if ! command -v curl >/dev/null; then
    >&2 echo "Please install 'curl' to run this script!"
fi

# Scrape for the last updated date metadata
# Change if broken
TAG=$(curl https://download.geofabrik.de/asia/malaysia-singapore-brunei.html \
    | grep malaysia-singapore-brunei-latest.osm.pbf \
    | grep -oP '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z')

# Copy required config
awk -v TAG="${TAG}" '{ sub(/\{\{ TAG }}/, TAG); print $0 }' template/config.json > app/config.json

# Need to be in the context of the directory
VENDOR_DIR=vendor/openmaptiles
pushd "${VENDOR_DIR}"

DATA_DIR=data
mkdir -p "${DATA_DIR}"

# This is to match the expected file path to prevent a download
# https://github.com/openmaptiles/openmaptiles/blob/f591f2e28efd377f529cfbae3a89e55c0d0bff2c/quickstart.sh#L138
if [[ ! -f "${DATA_DIR}/singapore.osm.pbf" ]]; then
    curl -fL \
        -o "${DATA_DIR}/singapore.osm.pbf" \
        https://download.geofabrik.de/asia/malaysia-singapore-brunei-latest.osm.pbf
fi

# Modification of generation env vars for our purpose
BBOX_VAL=103.062,0.807,104.545,1.823
MIN_ZOOM_VAL=0
MAX_ZOOM_VAL=18

awk -v BBOX_VAL="${BBOX_VAL}" -v MIN_ZOOM_VAL="${MIN_ZOOM_VAL}" -v MAX_ZOOM_VAL="${MAX_ZOOM_VAL}" '{
    sub(/BBOX=.*/, "BBOX=" BBOX_VAL);
    sub(/MIN_ZOOM=.*/, "MIN_ZOOM=" MIN_ZOOM_VAL);
    sub(/MAX_ZOOM=.*/, "MAX_ZOOM=" MAX_ZOOM_VAL);
    print $0
}' .env > .env_modified

mv .env .env.bak
mv .env_modified .env

# Run the generation
./quickstart.sh singapore

# Restore back original file
mv .env.bak .env

popd

# Extract the built mbtiles out
mv "${VENDOR_DIR}/${DATA_DIR}/tiles.mbtiles" tiles/singapore_${TAG}.mbtiles
