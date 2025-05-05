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
ls -l
for file in ${FILES}; do
    DEST="$CI_PROJECT_DIR/$(basename "${file}")"
    cp "${file}" "${DEST}"
    git add "${DEST}"
done
git status
if ! git diff --staged --quiet; then
    echo "✏️ Committing changes to ${BRANCH_NAME}..."
    git commit -m "chore(coding-style): Update coding style files [ci skip]"
    git push origin "${BRANCH_NAME}"
else
    echo "ℹ️ No changes to commit for branch ${BRANCH_NAME}, skipping..."
fi
