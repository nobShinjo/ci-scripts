#!/bin/bash

# Title: release/generate_release_note.sh
#
# Description:
#   This script generates a release note file from the changelog file.
#   It extracts the first version section from the changelog file and saves it to the release note file.
#   The release note file is used for generating release notes for the project.

# set -euo pipefail: Exit immediately if a command exits with a non-zero status.
set -euxo pipefail

# =========================
# Parameters:
# =========================
CHANGELOG_FILE=$1
RELEASE_NOTE_FILE=$2

# =========================
# Main script
# =========================
if [[ ! -f "$CHANGELOG_FILE" ]]; then
    echo "❌ Error: $CHANGELOG_FILE not found."
    exit 1
fi
echo "🔄 Generating $RELEASE_NOTE_FILE from $CHANGELOG_FILE"

# Remove the first line of the $RELEASE_NOTE_FILE
rm -f "$RELEASE_NOTE_FILE" || true

# Extract the first version section from the changelog file.
awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/{flag=1} flag' "$CHANGELOG_FILE" |
    awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/{flag=0} flag' >"$RELEASE_NOTE_FILE"

echo "✅ $RELEASE_NOTE_FILE generated successfully."
