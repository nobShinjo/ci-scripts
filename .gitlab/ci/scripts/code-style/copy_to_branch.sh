#!/bin/bash

# Title: copy_to_branch.sh
#
# Description:
#   This script copies files to a specified branch in a Git repository.
#
# Arguments:
#   - $1: The branch name to copy files to.
#   - $2: The files to be copied.

# set -euo pipefail: Exit immediately if a command exits with a non-zero status.
set -euxo pipefail

# =========================
# Parameters:
# =========================
BRANCH_NAME=$1
shift
FILES_TO_COPY=("$@")

# Switch to the specified branch
git switch "$BRANCH_NAME"
for file in "${FILES_TO_COPY[@]}"; do
   if [ ! -f "$file" ]; then
      echo "File $file does not exist. Skipping."
      continue
   fi
   cp "$file" .
   git add "$file"
done

# Commit changes if there are any
if git diff --staged --quiet; then
   echo "ℹ️ No changes detected on $branch_name. Skipping commit."
   exit 0
fi

echo "✏️ Committing changes to $BRANCH_NAME"
git commit -m "chore(coding-style): Update coding style files [ci skip]"
git push origin "$BRANCH_NAME"
echo "✅ Changes pushed to $BRANCH_NAME"
