#!/bin/bash

# Title: manage-version.sh
#
# Description:
# This script is used to manage versioning for a project.
# It reads the current version from VERSION.yml, increments it based on the specified type (major, minor, patch),
# and updates the VERSION.yml file with the new version.
# It also initializes VERSION.yml if it does not exist.

# set -euo pipefail: Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# =========================
# Parameters:
# =========================
VERSION_FILE=$1
NEXT_VERSION_FILE=".next_version"

# =========================
# Functions:
# =========================

# Title: update_version
#
# Description:
#   This function updates the version based on the specified bump type.
# Arguments:
#   $1: The current version (e.g., "1.0.0").
#   $2: The bump type (major, minor, patch).
# Returns:
#   The new version as a string (e.g., "1.0.1").
# Usage:
#   update_version "1.0.0" "minor"
function update_version() {
    local version=$1
    local bump_type=$2

    # Split the version into major, minor, and patch components
    IFS='.' read -r major minor patch <<<"$version"

    case "$bump_type" in
    major)
        major=$((major + 1))
        minor=0
        patch=0
        ;;
    minor)
        minor=$((minor + 1))
        patch=0
        ;;
    patch | *)
        patch=$((patch + 1))
        ;;
    esac
    echo "$major.$minor.$patch"
}

# Title: update_version_in_yaml
#
# Description:
#   This function updates the version in the specified file.
# Arguments:
#   $1: The new version (e.g., "1.0.0").
#   $2: The file to update (e.g., "VERSION.yml").
# Returns:
#   None
# Usage:
#   update_version_in_yaml "1.0.0" "VERSION.yml"
function update_version_in_yaml() {
    local version=$1
    local next_version_file=$2

    # Update the version in the file
    sed -i "s/^version: .*/version: $version/" "$next_version_file"
    sed -i "s/^version_bump_hint: .*/version_bump_hint: patch/" "$next_version_file"

}

# Title: write_next_version
#
# Description:
#   This function writes the next version to a file.
# Arguments:
#   $1: The next version (e.g., "1.0.0").
# Returns:
#   None
# Usage:
#   write_next_version "1.0.0"
function write_next_version() {
    local version=$1
    echo "$version" >"$NEXT_VERSION_FILE"
}

# =========================
# Main script
# =========================
if [ ! -f "$VERSION_FILE" ]; then
    echo "📝 Initialize $VERSION_FILE"
    echo "version: 0.0.0" >"$VERSION_FILE"
    echo "version_bump_hint: major" >>"$VERSION_FILE"
fi

# Read the current version and type from "$VERSION_FILE"
VERSION=$(grep 'version:' "$VERSION_FILE" | awk '{print $2}')
BUMP_TYPE=$(grep 'version_bump_hint:' "$VERSION_FILE" | awk '{print $2}')
if [ -z "$VERSION" ]; then
    echo "❌ Error: No version found in $VERSION_FILE."
    exit 1
fi
if [ -z "$BUMP_TYPE" ]; then
    BUMP_TYPE="patch"
fi

IFS='.' read -r MAJOR MINOR PATCH <<<"$VERSION"

# Check if the new version is valid
if ! [[ "$MAJOR" =~ ^[0-9]+$ && "$MINOR" =~ ^[0-9]+$ && "$PATCH" =~ ^[0-9]+$ ]]; then
    echo "❌ Error: Invalid version format."
    exit 1
fi

# Get the latest git tag.
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
TAG_VERSION=${LATEST_TAG#v}
IFS='.' read -r TAG_MAJOR TAG_MINOR TAG_PATCH <<<"$TAG_VERSION"

# Check if the new version is the same as the current version.
if [[ "$VERSION" == "$TAG_VERSION" ]]; then
    # If the local version is already released with the same version,
    # bump the version based on the specified type.
    echo "🔁 Already released. Bumping $BUMP_TYPE..."
    NEXT_VERSION=$(update_version "$VERSION" "$BUMP_TYPE")
    update_version_in_yaml "$NEXT_VERSION" "$VERSION_FILE"
    write_next_version "$NEXT_VERSION"
    echo "📝 Adopted version: $VERSION (bumped from $TAG_VERSION)"
elif ((MAJOR < TAG_MAJOR)) || ((MAJOR == TAG_MAJOR && MINOR < TAG_MINOR)) || ((MAJOR == TAG_MAJOR && MINOR == TAG_MINOR && PATCH <= TAG_PATCH)); then
    # If the local version is older than the released version, do not allow the version bump.
    echo "⚠️Local version ($VERSION) is older than the released version ($TAG_VERSION)."
    echo "🚫 Aborting release to avoid version conflict."
    exit 1
else
    # If the local version is newer than the released version, allow the version bump.
    echo "🔁 Bumping $BUMP_TYPE..."
    NEXT_VERSION=$(update_version "$VERSION" "$BUMP_TYPE")
    update_version_in_yaml "$NEXT_VERSION" "$VERSION_FILE"
    write_next_version "$NEXT_VERSION"
    echo "📝 Adopted version: $VERSION (bumped from $TAG_VERSION)"
fi
