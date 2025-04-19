#!/bin/bash

# Title: update_changelog_for_tag.sh
#
# Description:

set -euo pipefail

# =========================
# Parameters:
# =========================

# =========================
# Main script
# =========================

# Ensure required files exist
if [ ! -f "CHANGELOG.md" ]; then
    echo "❌ CHANGELOG.md not found. Aborting."
    exit 1
fi

# Find the GitLab repository URL fr

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0)
PREVIOUS_TAG=$(git describe --tags --abbrev=0 $LATEST_TAG^)

echo "📌 Processing tag: $LATEST_TAG"
DATE_NOW=$(date +%Y-%m-%d)

echo "🔄 Updating Unreleased section to $LATEST_TAG..."
# Replace "## [Unreleased]" with new tag section
sed -i "s/## \[Unreleased\]/## \[$LATEST_TAG\] - $DATE_NOW/" CHANGELOG.md

if [ ! -z "$REPO_URL" ]; then
    echo "📎 Found repository URL: $REPO_URL"
    # Update the Unreleased link and add new link for this version

    # Check if [Unreleased]: link exists, if so update it
    if grep -q "\[Unreleased\]:" CHANGELOG.md; then
        # Replace Unreleased link
        sed -i "s|\[Unreleased\]: .*$|\[Unreleased\]: $REPO_URL/compare/$LATEST_TAG...HEAD\n\[$LATEST_TAG\]: $REPO_URL/compare/$PREVIOUS_TAG...$LATEST_TAG|" CHANGELOG.md
    else
        # Add Unreleased link at the end of the file
        echo -e "\n[Unreleased]: $REPO_URL/compare/$LATEST_TAG...HEAD" >>CHANGELOG.md
        echo "[$LATEST_TAG]: $REPO_URL/compare/$PREVIOUS_TAG...$LATEST_TAG" >>CHANGELOG.md
    fi
fi

# Add new Unreleased section at the top
sed -i "1,/## \[$LATEST_TAG\]/{s/## \[$LATEST_TAG\]/## [Unreleased]\n\n## [$LATEST_TAG]/}" CHANGELOG.md

echo "✅ CHANGELOG.md updated with tag $LATEST_TAG"
