#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
./scripts/build.sh
stage=$(mktemp -d build/dmg.XXXXXX)
trap 'rm -rf "$stage"' EXIT
mkdir "$stage/root"
ditto "build/Mouse Battery Bar.app" "$stage/root/Mouse Battery Bar.app"
ln -s /Applications "$stage/root/Applications"
version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Info.plist)
out="build/MouseBatteryBar-$version.dmg"
hdiutil create -quiet -volname "Mouse Battery Bar" -srcfolder "$stage/root" \
    -fs HFS+ -format UDZO "$stage/package.dmg"
hdiutil verify "$stage/package.dmg"
mv -f "$stage/package.dmg" "$out"
shasum -a 256 "$out"
