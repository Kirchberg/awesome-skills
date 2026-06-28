#!/usr/bin/env bash
set -euo pipefail

# Structural sanity check for generated feature documentation.
# Usage: check_docs.sh [docs-dir]   (defaults to docs/ai)

target="${1:-docs/ai}"

fail() {
  echo "check_docs failed: $*" >&2
  exit 1
}

test -d "$target" || fail "docs directory '$target' does not exist"

md_files=()
while IFS= read -r -d '' f; do
  md_files+=("$f")
done < <(find "$target" -type f -name '*.md' -print0)

if [[ "${#md_files[@]}" -eq 0 ]]; then
  fail "no markdown files found under '$target'"
fi

# Count level-1 ATX headings outside fenced code blocks. Track the opening
# fence marker (``` or ~~~) and only close on a matching marker, so a snippet
# that shows one fence style inside the other does not end the block early and
# cause comment lines to be miscounted as headings.
count_h1() {
  awk '
    {
      marker = ""
      if ($0 ~ /^[ ]*```/) marker = "`"
      if (marker == "" && $0 ~ /^[ ]*~~~/) marker = "~"
      if (marker != "") {
        if (!in_fence) { in_fence = 1; fence = marker; next }
        if (marker == fence) { in_fence = 0; fence = ""; next }
      }
      if (!in_fence && $0 ~ /^# /) n++
    }
    END { print n + 0 }
  ' "$1"
}

status=0
for f in "${md_files[@]}"; do
  h1_count="$(count_h1 "$f")"
  if [[ "$h1_count" -ne 1 ]]; then
    echo "check_docs: $f has $h1_count level-1 headings outside code fences (expected 1)" >&2
    status=1
  fi
  if [[ ! -s "$f" ]]; then
    echo "check_docs: $f is empty" >&2
    status=1
  fi
done

[[ "$status" -eq 0 ]] || fail "one or more documents failed structural checks"

echo "check_docs passed for '$target'"
