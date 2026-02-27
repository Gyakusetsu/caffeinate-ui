#!/bin/bash
set -euo pipefail

APP_NAME="Caffeinate UI"
BUNDLE_DIR=".build/release/${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"

echo "Building release..."
swift build -c release

echo "Creating app bundle..."
rm -rf "${BUNDLE_DIR}"
mkdir -p "${MACOS_DIR}"

cp .build/release/CaffeinateUI "${MACOS_DIR}/CaffeinateUI"
cp Resources/Info.plist "${CONTENTS_DIR}/Info.plist"

echo "Built: ${BUNDLE_DIR}"
echo "Run with: open \"${BUNDLE_DIR}\""
