#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Public certificate fingerprint; its private key stays in the publisher's keychain.
IDENTITY="E9E284C4A5B5337E77AEEBE7AE9B7A5B9C7BABC0"
if ! security find-identity -v -p codesigning | awk -v identity="$IDENTITY" '$2 == identity { found=1 } END { exit !found }'; then
    echo "The persistent yabai-cert signing identity is unavailable; restore it before publishing." >&2
    exit 1
fi

make install
REQUIREMENT="designated => identifier \"com.asmvik.yabai\" and certificate leaf = H\"$IDENTITY\""
codesign --force --sign "$IDENTITY" --identifier com.asmvik.yabai \
    --options runtime --timestamp=none --requirements "=$REQUIREMENT" bin/yabai
codesign --verify --strict bin/yabai

VERSION="$(bin/yabai --version)"
STAGING="$(mktemp -d "${TMPDIR:-/tmp}/yabai-release.XXXXXX")"
trap 'rm -rf "$STAGING"' EXIT
mkdir -p "$STAGING/archive/bin" "$STAGING/archive/doc" "$STAGING/archive/examples"
cp bin/yabai "$STAGING/archive/bin/"
cp doc/yabai.1 "$STAGING/archive/doc/"
cp examples/yabairc examples/skhdrc "$STAGING/archive/examples/"
cp LICENSE.txt "$STAGING/archive/"
printf 'Source: %s\nSigning certificate SHA1: %s\nSigning: self-signed Code Signing, no Apple notarization\n' \
    "$(git rev-parse HEAD)" "$IDENTITY" > "$STAGING/archive/BUILD.txt"
tar -czf "bin/${VERSION}.tar.gz" -C "$STAGING" archive
(cd bin && shasum -a 256 "${VERSION}.tar.gz" > "${VERSION}.tar.gz.sha256")
echo "Created bin/${VERSION}.tar.gz with the persistent signing identity."
