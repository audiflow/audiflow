#!/bin/bash
set -euo pipefail

# PostToolUse hook: Auto-format Dart files after Write/Edit operations
# This hook runs after Write or Edit tools complete successfully

input=$(cat)

# Exit immediately if STDIN was empty
if [ -z "$input" ]; then
  exit 0
fi

# Extract the file path from tool input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.filePath // empty')

# Exit early if no file path found
if [ -z "$file_path" ]; then
  exit 0
fi

# Only format Dart files
if [[ ! "$file_path" == *.dart ]]; then
  exit 0
fi

# Check if file exists
if [ ! -f "$file_path" ]; then
  exit 0
fi

# Format the file
if dart format "$file_path" 2>/dev/null; then
  echo "{\"systemMessage\": \"Auto-formatted: $(basename "$file_path")\"}"
fi

exit 0
