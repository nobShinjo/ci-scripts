#!/bin/bash

set -euxo pipefail

# ==========================
# Parameters:
# ==========================
BRANCH_NAME=$1
FILES=$2

# ==========================
# Main
# ==========================
echo "🔄 Switch to branch ${BRANCH_NAME}…"
if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
    git checkout "${BRANCH_NAME}"
else
    git checkout -b "${BRANCH_NAME}" "origin/${BRANCH_NAME}"
fi
echo "📋 Copying files to branch ${BRANCH_NAME}..."
for file in ${FILES}; do
    cp "${file}" .
    git add "$(basename "$file")"
done
if git diff --staged --quiet; then
    echo "ℹ️ No changes to commit for branch ${BRANCH_NAME}, skipping..."
else
    echo "✏️ Committing changes to ${BRANCH_NAME}..."
    git commit -m "chore(coding-style): Update coding style files [ci skip]"
    git push origin "${BRANCH_NAME}"
fi
