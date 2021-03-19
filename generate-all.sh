#!/usr/bin/env bash
set -euo pipefail

echo "Generating fonts..."
./generate-fonts.sh

echo "Generating sprites..."
./generate-sprites.sh

echo "Completed!"
