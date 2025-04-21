#!/bin/bash

# Title: changelog/merge.sh
#
# Description:
#   This script merges the draft changelog file into the main CHANGELOG.md file.
#   It ensures that the Unreleased section is updated with the latest changes from the draft.

# set -euo pipefail: Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# =========================
# Configurations
# =========================
DRAFT_FILE=".changelog_draft.md"
CHANGELOG_FILE="CHANGELOG.md"
TMP_FILE=".changelog_merged.tmp.md"

# =========================
# Main script
# =========================
echo "🔄 Merging draft into existing $CHANGELOG_FILE..."

if [ ! -f "$DRAFT_FILE" ]; then
    echo "❌ $DRAFT_FILE is not found."
    exit 1
fi

if [ ! -f "$CHANGELOG_FILE" ] || [ ! -s "$CHANGELOG_FILE" ]; then
    echo "⚠️ $CHANGELOG_FILE does not exist or is empty. Creating new $CHANGELOG_FILE from draft."

    cp .changelog_draft.md $CHANGELOG_FILE
    exit 0
fi

# Get UNRELEASED section from the draft file.
DRAFT=$(awk '/^## \[Unreleased\]/, /^---$/' "$DRAFT_FILE")
DRAFT=$(sed "s/^## \[Unreleased\]/## \[Draft\]/" <<<"$DRAFT")
# Get the one line "[Unreleased]: "
DRAFT_LINK=$(awk '/^\[Unreleased\]:/{ print; exit }' "$DRAFT_FILE")
DRAFT_LINK=$(sed "s/\[Unreleased\]:/\[Draft\]:/" <<<"$DRAFT_LINK")

# Split CHANGELOG.md into HEADER, and BODY sections.
# HEADER is everything before the first version section.
# BODY is everything after the first version section.
HEADER=$(awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/{exit} { print }' "$CHANGELOG_FILE")
BODY=$(awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/{ print; exit }' "$CHANGELOG_FILE")
UNRELEASED_LINK=$(awk '/^\[Unreleased\]:/{ print; exit }' "$CHANGELOG_FILE")
LINK=$(awk '/^\[[0-9]+\.[0-9]+\.[0-9]+\]:/{flag=1} flag' "$CHANGELOG_FILE")

# Merge the Unreleased section from the draft into the CHANGELOG.md
{
    echo "$HEADER"
    echo ""
    echo "$DRAFT"
    echo ""
    echo "$BODY"
    echo ""
    echo "$UNRELEASED_LINK"
    echo "$DRAFT_LINK"
    echo "$LINK"
} >"$TMP_FILE"

mv "$TMP_FILE" "$CHANGELOG_FILE"
echo "✅ Merged $DRAFT_FILE into $CHANGELOG_FILE."
