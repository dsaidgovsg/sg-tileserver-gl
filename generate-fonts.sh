#!/usr/bin/env bash
set -euo pipefail

if ! command -v npm >/dev/null; then
    >&2 echo "Please install 'npm' to run this script!"
fi

if ! command -v node >/dev/null; then
    >&2 echo "Please install 'node' to run this script!"
fi

pushd vendor/openmaptiles-fonts
npm --cache /tmp/npm-cache install
npm cache clean --force
rm package-lock.json
node ./generate.js
popd

cp -r vendor/openmaptiles-fonts/_output/* app/fonts/
