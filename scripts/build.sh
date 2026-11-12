#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
app="build/Mouse Battery Bar.app"
mkdir -p "$app/Contents/MacOS"
cp Info.plist "$app/Contents/Info.plist"
xcrun clang -arch arm64 -arch x86_64 -mmacosx-version-min=13.0 -fobjc-arc \
  -Os -Wall -Wextra -Wno-unused-parameter -Werror -Wl,-dead_strip \
  -framework Carbon -framework ServiceManagement -framework Cocoa -framework IOKit src/Menu.m src/MouseProfile.m \
  -o "$app/Contents/MacOS/MouseBatteryBar"
strip -x "$app/Contents/MacOS/MouseBatteryBar"
codesign --force --sign - "$app"
codesign --verify --strict "$app"
printf '%s\n' "$app"
