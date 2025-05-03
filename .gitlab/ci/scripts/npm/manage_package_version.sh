#!/bin/bash

# Title: npm/manage_package_version.sh
#
# Description:
#   This script manages the versioning of a package in a package.json file.
#   It checks if the package is published in a GitLab registry and compares the local version with the published version.
#   If the package is published with the same version, it bumps the version based on the provided versionBumpHint.
#   If the package is not published, it uses the local version.
#   If the local version is older than the published version, it aborts the publish to avoid version conflicts.
#   If the local version is newer than the published version, it updates the package.json with the local version.

# set -euo pipefail: Exit immediately if a command exits with a non-zero status.
set -euxo pipefail

# =========================
# Parameters:
# =========================
PACKAGE_JSON=$1
DIST_DIR=$2
REGISTRY_URL=$3
NPM_TOKEN=$4
NEXT_VERSION_FILE=".next_version"

# =========================
# Functions
# =========================

# Title: update_package_json
# Description:
#   This function updates the version in the package.json file.
# Arguments:
#   $1: The path to the package.json file.
#   $2: The new version to set.
# Returns:
#   0: Success
#   1: Failure
# Usage:
#   update_package_json <package_json> <new_version>
# Example:
#   update_package_json "package.json" "1.0.1"
function update_package_json() {
    local package_json=$1
    local next_version=$2

    if [[ ! -f "$package_json" ]]; then
        echo "❌ Error: $package_json not found."
        return 1
    fi
    if [[ -z "$next_version" ]]; then
        echo "❌ Error: No version provided."
        return 1
    fi
    jq --arg version "$next_version" '.version = $version | del(.versionBumpHint)' "$package_json" >"${package_json}.tmp"
    mv "${package_json}.tmp" "$package_json"
}

# =========================
# Main script
# =========================

# Get the package name and version from the package.json file.
echo "🔍 Reading package info..."
PACKAGE_NAME=$(jq -r .name "$PACKAGE_JSON")
CURRENT_VERSION=$(jq -r .version "$PACKAGE_JSON")
BUMP_TYPE=$(jq -r '.versionBumpHint // "patch"' "$PACKAGE_JSON")
echo "📦 $PACKAGE_NAME @ $CURRENT_VERSION ($BUMP_TYPE)"

# Encode the package name for the GitLab registry URL.
# GitLab requires @scope/package-name as %40scope%2Fpackage-name
# - '%40' is the URL-encoded version of '@'
# - '%2F' is the URL-encoded version of '/'
ENCODED_NAME=$(echo "$PACKAGE_NAME" | sed 's/@/%40/' | sed 's/\//%2F/')
PACKAGE_INFO_URL="${REGISTRY_URL%-*}/npm/${ENCODED_NAME}"

# Get the published version from the GitLab registry.
echo "🌐 Registry: $PACKAGE_INFO_URL"
PUBLISHED_VERSION=$(curl -s --header "PRIVATE-TOKEN: ${NPM_TOKEN}" "$PACKAGE_INFO_URL" | jq -r '.versions | keys | last')

# Adopt the version based on the published version and the local version.
if [[ -z "$PUBLISHED_VERSION" ]]; then
    # If the package is not published, use the local version.
    echo "🆕 Not published. Using local version."
    echo "$CURRENT_VERSION" >"$NEXT_VERSION_FILE"
    update_package_json "$PACKAGE_JSON" "$CURRENT_VERSION" || {
        echo "❌ Failed to update package.json"
        exit 1
    }
    echo "📝 Adopted version: $CURRENT_VERSION (initial publish)"
elif [[ "$PUBLISHED_VERSION" == "$CURRENT_VERSION" ]]; then
    # If the package is already published with the same version, bump the version.
    echo "🔁 Already published. Bumping $BUMP_TYPE..."
    NEXT_VERSION=$(npm --no-git-tag-version version "$BUMP_TYPE" --prefix "$DIST_DIR" | sed 's/v//')
    update_package_json "$PACKAGE_JSON" "$NEXT_VERSION" || {
        echo "❌ Failed to update package.json"
        exit 1
    }
    echo "$NEXT_VERSION" >"$NEXT_VERSION_FILE"
    echo "📝 Adopted version: $NEXT_VERSION (bumped from $CURRENT_VERSION)"
elif [[ "$(printf '%s\n' "$PUBLISHED_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)" == "$CURRENT_VERSION" ]]; then
    # If the local version is older than the published version, abort the publish.
    echo "⚠️ Local version ($CURRENT_VERSION) is older than published version ($PUBLISHED_VERSION)."
    echo "🚫 Aborting publish to avoid version conflict."
    exit 1
else
    # If the local version is newer than the published version, update the package.json.
    echo "✅ Local version ($CURRENT_VERSION) is newer than published version ($PUBLISHED_VERSION)."
    update_package_json "$PACKAGE_JSON" "$CURRENT_VERSION" || {
        echo "❌ Failed to update package.json"
        exit 1
    }
    echo "$CURRENT_VERSION" >"$NEXT_VERSION_FILE"
    echo "📝 Adopted version: $CURRENT_VERSION (ahead of registry)"
fi
