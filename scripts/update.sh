#!/usr/bin/env bash
set -euo pipefail

REPO="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
VERSION_FILE="$(cd "$(dirname "$0")/../pkgs/claude-code" && pwd)/version.json"

# Determine target version
if [[ $# -ge 1 ]]; then
  NEW_VERSION="$1"
else
  NEW_VERSION=$(npm view @anthropic-ai/claude-code version 2>/dev/null)
fi

# Check current version
OLD_VERSION=$(jq -r '.version' "$VERSION_FILE")
if [[ "$OLD_VERSION" == "$NEW_VERSION" ]]; then
  echo "claude-code: already at $NEW_VERSION"
  exit 0
fi

# Fetch manifest
MANIFEST=$(curl -fsSL "$REPO/$NEW_VERSION/manifest.json")

# Platform mapping: manifest name → Nix system
declare -A PLAT_TO_SYSTEM=(
  ["linux-x64"]="x86_64-linux"
  ["linux-arm64"]="aarch64-linux"
  ["darwin-x64"]="x86_64-darwin"
  ["darwin-arm64"]="aarch64-darwin"
)

# Build hashes object
HASHES="{}"
for plat in linux-x64 linux-arm64 darwin-x64 darwin-arm64; do
  hex=$(jq -r ".platforms[\"$plat\"].checksum" <<< "$MANIFEST")
  sri=$(nix hash convert --hash-algo sha256 --to sri "$hex")
  system="${PLAT_TO_SYSTEM[$plat]}"
  HASHES=$(jq --arg sys "$system" --arg sri "$sri" '.[$sys] = $sri' <<< "$HASHES")
done

# Write version.json
jq -n --arg ver "$NEW_VERSION" --argjson hashes "$HASHES" \
  '{ version: $ver, hashes: $hashes }' > "$VERSION_FILE"

echo "claude-code: $OLD_VERSION → $NEW_VERSION"
