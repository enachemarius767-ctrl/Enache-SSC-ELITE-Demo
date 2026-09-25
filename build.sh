#!/bin/bash
set -euo pipefail

SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
OUT="build/Payload/SSCEliteDemo.app"

rm -rf build
mkdir -p "$OUT"

xcrun clang \
  -target arm64-apple-ios16.0 \
  -isysroot "$SDK" \
  -fobjc-arc \
  -fmodules \
  main.m \
  -framework UIKit \
  -framework Foundation \
  -framework QuartzCore \
  -o "$OUT/SSCEliteDemo"

cp Info.plist "$OUT/Info.plist"

echo "Binary:"
file "$OUT/SSCEliteDemo"

echo "Minimum OS / load commands:"
xcrun vtool -show-build "$OUT/SSCEliteDemo" || true

(
  cd build
  zip -qry SSC-ELITE-Demo-unsigned.ipa Payload
)

echo
echo "Created: build/SSC-ELITE-Demo-unsigned.ipa"
