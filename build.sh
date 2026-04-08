#!/usr/bin/env bash
set -e

BUILD_NUMBER="${BUILD_NUMBER:-0}"

# Use fvm prefix when available, fall back to plain flutter/dart in CI
if command -v fvm &>/dev/null; then
  FLUTTER="fvm flutter"
  DART="fvm dart"
else
  FLUTTER="flutter"
  DART="dart"
fi

$FLUTTER pub get
$FLUTTER pub run build_runner build -d
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FVM_VERSION=$(python3 -c "import json; print(json.load(open('$SCRIPT_DIR/.fvmrc'))['flutter'])" 2>/dev/null || true)
FVM_CACHE="${FVM_HOME:-$HOME/fvm}/versions"
if [ -n "$FVM_VERSION" ] && [ -d "$FVM_CACHE/$FVM_VERSION/bin" ]; then
  export PATH="$FVM_CACHE/$FVM_VERSION/bin:$PATH"
fi
$DART pub global activate flutterpi_tool
flutterpi_tool build --arch=arm64 --cpu=pi3 --release
