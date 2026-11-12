#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
out=build
set --
case ${MOUSE_CHANNEL:-local} in
    local) ;;
    vt9pro)
        out=build/vt9pro
        ./scripts/sparkle-tools.sh
        frameworkdir=build/sparkle-2.10.1
        set -- -DVT9PRO_UPDATES=1 -F"$frameworkdir" -framework Sparkle -Wl,-rpath,@executable_path/../Frameworks
        ;;
    *) echo "Unknown MOUSE_CHANNEL" >&2; exit 1 ;;
esac
app="$out/Mouse Battery Bar.app"
mkdir -p "$app/Contents/MacOS"
cp Info.plist "$app/Contents/Info.plist"
if [ "${MOUSE_CHANNEL:-local}" = vt9pro ]; then
    mkdir -p "$app/Contents/Frameworks" "$app/Contents/Resources"
    ditto "$frameworkdir/Sparkle.framework" "$app/Contents/Frameworks/Sparkle.framework"
    cp "$frameworkdir/LICENSE" "$app/Contents/Resources/Sparkle-LICENSE"
    /usr/libexec/PlistBuddy -c 'Merge updates/vt9pro-settings.plist' "$app/Contents/Info.plist"
fi
xcrun clang -arch arm64 -arch x86_64 -mmacosx-version-min=13.0 -fobjc-arc \
  -Os -Wall -Wextra -Wno-unused-parameter -Werror -Wl,-dead_strip "$@" \
  -framework Carbon -framework ServiceManagement -framework Cocoa -framework IOKit src/Menu.m src/MouseProfile.m \
  -o "$app/Contents/MacOS/MouseBatteryBar"
strip -x "$app/Contents/MacOS/MouseBatteryBar"
codesign --force --sign - "$app"
codesign --verify --deep --strict "$app"
printf '%s\n' "$app"
