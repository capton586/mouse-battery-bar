#!/bin/sh
# Run from the repository root. Both build and signing use this exact distribution.
set -eu
version=2.10.1
sha=1a856d2a9edb8e628de88121d7be04cf0e2167f8641650b78fca00b14244cf27
root="build/sparkle-$version"
if [ -d "$root/Sparkle.framework" ] && [ -x "$root/bin/sign_update" ]; then exit 0; fi
mkdir -p build
tmp=$(mktemp -d build/sparkle-fetch.XXXXXX)
trap 'rm -rf "$tmp"' EXIT
archive="Sparkle-$version.tar.xz"
curl --fail --location --retry 3 --output "$tmp/$archive" \
    "https://github.com/sparkle-project/Sparkle/releases/download/$version/$archive"
(cd "$tmp" && printf '%s  %s\n' "$sha" "$archive" | shasum -a 256 -c -)
mkdir "$tmp/distribution"
tar -xf "$tmp/$archive" -C "$tmp/distribution"
mv "$tmp/distribution" "$root"
