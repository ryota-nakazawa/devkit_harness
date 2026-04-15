#!/usr/bin/env bash
# history/index.jsonl に1エントリを追記する。
#
# 使い方:
#   ./scripts/append-history.sh <id> <project_name> <template> <title> <purpose> <style> <spec_path> <output_path> <summary> [based_on]

set -u

if [ "$#" -lt 9 ]; then
  echo "Usage: $0 <id> <project_name> <template> <title> <purpose> <style> <spec_path> <output_path> <summary> [based_on]"
  exit 1
fi

ID="$1"
PROJECT_NAME="$2"
TEMPLATE="$3"
TITLE="$4"
PURPOSE="$5"
STYLE="$6"
SPEC_PATH="$7"
OUTPUT_PATH="$8"
SUMMARY="$9"
BASED_ON="${10:-}"

CREATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# JSON エスケープ（最低限：ダブルクォートとバックスラッシュ）
esc() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

HISTORY_FILE="history/index.jsonl"
mkdir -p "$(dirname "$HISTORY_FILE")"
touch "$HISTORY_FILE"

ENTRY='{"id":"'"$(esc "$ID")"'","project_name":"'"$(esc "$PROJECT_NAME")"'","template":"'"$(esc "$TEMPLATE")"'","title":"'"$(esc "$TITLE")"'","purpose":"'"$(esc "$PURPOSE")"'","style":"'"$(esc "$STYLE")"'","spec_path":"'"$(esc "$SPEC_PATH")"'","output_path":"'"$(esc "$OUTPUT_PATH")"'","created_at":"'"$CREATED_AT"'","summary":"'"$(esc "$SUMMARY")"'"'

if [ -n "$BASED_ON" ]; then
  ENTRY="$ENTRY"',"based_on":"'"$(esc "$BASED_ON")"'"'
fi

ENTRY="$ENTRY"'}'

echo "$ENTRY" >> "$HISTORY_FILE"
echo "✓ Appended to $HISTORY_FILE"
