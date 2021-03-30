#!/usr/bin/env bash
set -euo pipefail

# Get this script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="${DIR}/.."

VENDOR_FONTS_DIR="${ROOT_DIR}/vendor/openmaptiles-fonts"
DATA_FONTS_DIR="${ROOT_DIR}/data/fonts"
NPM_CACHE_DIR=/tmp/npm-cache

if ! command -v npm >/dev/null; then
    >&2 echo "Please install 'npm' to run this script!"
    exit 1
fi

if ! command -v node >/dev/null; then
    >&2 echo "Please install 'node' to run this script!"
    exit 1
fi

# Clean up previous files
find "${DATA_FONTS_DIR}" -type f -not -name '.gitkeep' -exec rm {} \;

pushd "${VENDOR_FONTS_DIR}"
npm --cache "${NPM_CACHE_DIR}" install
rm -rf "${NPM_CACHE_DIR}"
rm -f package-lock.json
node ./generate.js
popd

cp -r "${VENDOR_FONTS_DIR}/_output/"* "${DATA_FONTS_DIR}/"
