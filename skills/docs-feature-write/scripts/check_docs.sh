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

# Count level-1 ATX headings outside fenced code blocks. Capture the opening
# fence's marker character (``` or ~~~) AND its length, and close only on a
# same-marker run of at least that length followed by whitespace. This keeps a
# longer fence (e.g. four backticks) wrapping a shorter example (three
# backticks) from ending early and miscounting comment lines as headings.
count_h1() {
  awk '
    {
      if (match($0, /^[ ]*(`+|~+)/)) {
        seg = substr($0, RSTART, RLENGTH)
        sub(/^[ ]+/, "", seg)
        ch = substr(seg, 1, 1)
        len = length(seg)
        rest = substr($0, RSTART + RLENGTH)
        if (len >= 3) {
          if (!in_fence) { in_fence = 1; fence_ch = ch; fence_len = len; next }
          if (ch == fence_ch && len >= fence_len && rest ~ /^[ \t]*$/) { in_fence = 0; fence_ch = ""; fence_len = 0; next }
        }
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
