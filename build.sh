#!/usr/bin/env bash
set -e

BUILD_NUMBER="${BUILD_NUMBER:-0}"

fvm flutter pub get
fvm flutter pub run build_runner build -d
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FVM_VERSION=$(python3 -c "import json; print(json.load(open('$SCRIPT_DIR/.fvmrc'))['flutter'])" 2>/dev/null || true)
FVM_CACHE="${FVM_HOME:-$HOME/fvm}/versions"
if [ -n "$FVM_VERSION" ] && [ -d "$FVM_CACHE/$FVM_VERSION/bin" ]; then
  export PATH="$FVM_CACHE/$FVM_VERSION/bin:$PATH"
fi
fvm dart pub global activate flutterpi_tool
flutterpi_tool build --arch=arm64 --cpu=pi3 --release
