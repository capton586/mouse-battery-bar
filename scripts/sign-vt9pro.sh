#!/bin/sh
# Sign the already-built VT9PRO installer and write its feed alongside it.
set -eu
cd "$(dirname "$0")/.."
tools=build/sparkle-2.10.1/bin
account=capton586.mouse-battery-bar.vt9pro
out=build/vt9pro
plist="$out/Mouse Battery Bar.app/Contents/Info.plist"
value() { /usr/libexec/PlistBuddy -c "Print :$1" "$plist"; }
version=$(value CFBundleShortVersionString)
build=$(value CFBundleVersion)
file="MouseBatteryBar-VT9PRO-$version.dmg"
test "$(value SUPublicEDKey)" = "$("$tools/generate_keys" --account "$account" -p)"
if ! signature=$("$tools/sign_update" --account "$account" -p "$out/$file"); then
    printf '%s\n' "$signature" >&2
    exit 1
fi
"$tools/sign_update" --account "$account" --verify "$out/$file" "$signature"
size=$(stat -f %z "$out/$file")
cat > "$out/vt9pro.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel><title>Mouse Battery Bar · VT9PRO</title>
    <item><title>VT9PRO $version</title>
      <sparkle:version>$build</sparkle:version>
      <sparkle:shortVersionString>$version</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
      <enclosure url="https://github.com/capton586/mouse-battery-bar/releases/download/v$version/$file" length="$size" type="application/octet-stream" sparkle:edSignature="$signature"/>
    </item>
  </channel>
</rss>
XML
"$tools/sign_update" --account "$account" "$out/vt9pro.xml"
"$tools/sign_update" --account "$account" --verify "$out/vt9pro.xml"
