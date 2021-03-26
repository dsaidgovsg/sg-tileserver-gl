#!/usr/bin/env bash
set -euo pipefail

# Get this script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="${DIR}"

VENDOR_DIR="${ROOT_DIR}/vendor/openmaptiles"
VENDOR_REL_DATA_DIR="data"
BUILD_TILES_DIR="${ROOT_DIR}/build/mbtiles"

# Modification of generation env vars for our purpose
MIN_ZOOM="${MIN_ZOOM:-0}"
MAX_ZOOM="${MAX_ZOOM:-14}"  # Max zoom 14 takes ~30 hours. Every +1 doubles the time required.

if ! command -v curl >/dev/null; then
    >&2 echo "Please install 'curl' to run this script!"
fi

# Scrape for the last updated date metadata
# To be changed if the webpage ever changes format
# Remove dashes and colons because release assets cannot accept colons
DATETIME=$(curl https://download.geofabrik.de/asia/malaysia-singapore-brunei.html \
    | grep malaysia-singapore-brunei-latest.osm.pbf \
    | grep -oP '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z' \
    | tr -d '-' \
    | tr -d ':')

TAG="${MIN_ZOOM}-${MAX_ZOOM}_${DATETIME}"

# Need to be in the context of the directory
pushd "${VENDOR_DIR}"

mkdir -p "${VENDOR_REL_DATA_DIR}"

# Prevent redownload if the pbf of the expected datetime already exists
if [[ ! -f "${VENDOR_REL_DATA_DIR}/singapore_${DATETIME}.osm.pbf" ]]; then
    curl -fL \
        -o "${VENDOR_REL_DATA_DIR}/singapore_${DATETIME}.osm.pbf" \
        https://download.geofabrik.de/asia/malaysia-singapore-brunei-latest.osm.pbf
fi

# Because the creation script expects singapore.osm.pbf, we create symbolic link for it
# https://github.com/openmaptiles/openmaptiles/blob/f591f2e28efd377f529cfbae3a89e55c0d0bff2c/quickstart.sh#L138
if [[ -L "${VENDOR_REL_DATA_DIR}/singapore.osm.pbf" ]]; then
    unlink "${VENDOR_REL_DATA_DIR}/singapore.osm.pbf"
fi

ln -s "singapore_${DATETIME}.osm.pbf" "${VENDOR_REL_DATA_DIR}/singapore.osm.pbf"

# Fixed value
BBOX="103.062,0.807,104.545,1.823"

awk -v BBOX="${BBOX}" -v MIN_ZOOM="${MIN_ZOOM}" -v MAX_ZOOM="${MAX_ZOOM}" '{
    sub(/BBOX=.*/, "BBOX=" BBOX);
    sub(/MIN_ZOOM=.*/, "MIN_ZOOM=" MIN_ZOOM);
    sub(/MAX_ZOOM=.*/, "MAX_ZOOM=" MAX_ZOOM);
    print $0
}' .env > .env_modified

mv .env .env.bak
mv .env_modified .env

# Run the generation, be prepared to wait
./quickstart.sh singapore

# Restore back original file
mv .env.bak .env

popd

# Place created mbtiles into build directory
mkdir -p "${BUILD_TILES_DIR}"
mv "${VENDOR_DIR}/${VENDOR_REL_DATA_DIR}/tiles.mbtiles" "${BUILD_TILES_DIR}/singapore_${TAG}.mbtiles"
