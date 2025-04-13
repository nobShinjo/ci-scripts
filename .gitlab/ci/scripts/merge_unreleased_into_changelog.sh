#!/bin/bash
set -euo pipefail

# Configurations
UNRELEASED_FILE=".changelog_unreleased.md"
CHANGELOG_FILE="CHANGELOG.md"
TMP_FILE=".changelog_merged.tmp.md"

if [[ ! -f "$UNRELEASED_FILE" || ! -f "$CHANGELOG_FILE" ]]; then
    echo "❌ 必要なファイルが見つかりません。"
    exit 1
fi

# CHANGELOG.md を3分割する：
# 1. header（Unreleasedの直前まで）
# 2. unreleased（Unreleasedセクション開始行を含む）
# 3. tail（Unreleased以降の履歴）

HEADER=$(awk '/^## Unreleased/{exit} { print }' "$CHANGELOG_FILE")
UNRELEASED_LINE=$(awk '/^## Unreleased/{ print; exit }' "$CHANGELOG_FILE")
TAIL=$(awk '/^## Unreleased/{p=1; next} p { print }' "$CHANGELOG_FILE")

# 合成する： HEADER + Unreleased Header + .changelog_unreleased.md + TAIL
{
    echo "$HEADER"
    echo "$UNRELEASED_LINE"
    echo ""
    cat "$UNRELEASED_FILE"
    echo ""
    echo "$TAIL"
} >"$TMP_FILE"

mv "$TMP_FILE" "$CHANGELOG_FILE"
echo "✅ CHANGELOG.md に Unreleased を統合しました。"
