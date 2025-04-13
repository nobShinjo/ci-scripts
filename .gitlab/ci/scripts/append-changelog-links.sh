#!/bin/bash

# append-changelog-links.sh
# This script appends links to the CHANGELOG.md file for the latest tag and the previous tag.

set -euo pipefail

# Configurations
REPO_URL="https://gitlab.local/your-group/your-project/-/compare"
CHANGELOG_FILE="CHANGELOG.md"
TMP_FILE=".changelog_final.tmp.md"

NEW_TAG=$(git describe --tags --abbrev=0)
PREV_TAG=$(git tag --sort=-creatordate | grep -B1 "$NEW_TAG" | head -n1 || true)

LINK_BLOCK="
---

### Links
"

if [[ -n "$PREV_TAG" && "$PREV_TAG" != "$NEW_TAG" ]]; then
  LINK_BLOCK+="
- [Compare $PREV_TAG...$NEW_TAG]($REPO_URL/$PREV_TAG...$NEW_TAG)"
fi

LINK_BLOCK+="
- [Compare $NEW_TAG...HEAD]($REPO_URL/$NEW_TAG...main)
"

cat "$CHANGELOG_FILE" >"$TMP_FILE"
echo "$LINK_BLOCK" >>"$TMP_FILE"
mv "$TMP_FILE" "$CHANGELOG_FILE"

echo "✅ CHANGELOG.md に差分リンクを追加しました。"
