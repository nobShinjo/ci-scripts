#!/bin/bash
set -euo pipefail

# Configurations
DRAFT_FILE=".changelog_draft.md"
CHANGELOG_FILE="CHANGELOG.md"
TMP_FILE=".changelog_merged.tmp.md"

if [ ! -f "$DRAFT_FILE" ]; then
    echo "❌ $DRAFT_FILE is not found."
    exit 1
fi
if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "❌ $CHANGELOG_FILE is not found."
    exit 1
fi

# Get UNRELEASED section from the draft file.
DRAFT=$(awk '/^## [Unreleased]/{ print; exit }' "$DRAFT_FILE")

# Split CHANGELOG.md into HEADER, and TAIL sections.
# HEADER is everything before the first version section.
# TAIL is everything after the first version section.
HEADER=$(awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/{exit} { print }' "$CHANGELOG_FILE")
TAIL=$(awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/{ print; exit }' "$CHANGELOG_FILE")

# Merge the Unreleased section from the draft into the CHANGELOG.md
{
    echo "$HEADER"
    echo ""
    echo "$DRAFT"
    echo ""
    echo "$TAIL"
} >"$TMP_FILE"

mv "$TMP_FILE" "$CHANGELOG_FILE"
echo "✅ Merged $DRAFT_FILE into $CHANGELOG_FILE."
