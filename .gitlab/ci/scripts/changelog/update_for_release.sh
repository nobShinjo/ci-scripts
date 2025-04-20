#!/bin/bash

# Title: changelog/update_for_release.sh
#
# Description:
#   This script updates the changelog file for a new version release.
#   It replaces the draft version with the new version and updates the links accordingly.
#   It also ensures that the changelog file is in the correct format.

# set -euo pipefail: Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# =========================
# Parameters:
# =========================
VERSION=$1
CHANGELOG_FILE=$2
CURRENT_DATE=$(date +'%Y-%m-%d')
REPO_URL=${REPO_URL:-${CI_PROJECT_URL:-"https://gitlab.local/your-group/your-project"}}

# =========================
# Main script
# =========================
echo "🔄 Updating $CHANGELOG_FILE for version: $VERSION"

# Ensure required files exist
if [[ ! -f "$CHANGELOG_FILE" ]]; then
    echo "❌ Error: $CHANGELOG_FILE not found."
    exit 1
fi

# Replace from ## [Draft] to ## [VERSION] - YYYY-MM-DD.
sed -i "s/## \[Draft\]/## [$VERSION] - $CURRENT_DATE/" "$CHANGELOG_FILE"

# e.g) [Draft]: https://.*?/compare/v0.0.1...HEAD → [0.1.0]: https://.*?/compare/v0.0.1...v0.1.0
# e.g) [Unreleased]: https://.*?/compare/v0.0.1...HAED → [Unreleased]: https://.*?/compare/v0.1.0...HEAD
OLD_VERSION=$(awk -F'compare/v' '/compare\/v[0-9.]+/{split($2, a, "..."); print a[1]; exit}' "$CHANGELOG_FILE")

if [[ -z "$OLD_VERSION" ]]; then
    sed -i "s|\[Unreleased\]: .*|[Unreleased]: $REPO_URL/-/compare/v$VERSION...HEAD|g" "$CHANGELOG_FILE"
    sed -i "s|\[Draft\]: .*|[Draft]: $REPO_URL/-/releases/v$VERSION|g" "$CHANGELOG_FILE"
else
    sed -i "s|compare/v$OLD_VERSION...HEAD|compare/v$VERSION...HEAD|g" "$CHANGELOG_FILE"
    sed -i "s|compare/v$OLD_VERSION...v$VERSION|compare/v$OLD_VERSION...v$VERSION|g" "$CHANGELOG_FILE"
fi

echo "✅ $CHANGELOG_FILE updated successfully."
