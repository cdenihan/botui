#!/usr/bin/env bash
set -e

BUILD_NUMBER="${BUILD_NUMBER:-0}"

dart pub get
dart run build_runner build -d
flutterpi_tool build --arch=arm64 --cpu=pi3 --release
