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

status=0
for f in "${md_files[@]}"; do
  # NOTE: counts all lines matching '^# ' including any inside ``` fences.
  # Intended for generated output docs, not for skill template files.
  h1_count="$(grep -c '^# ' "$f" || true)"
  if [[ "$h1_count" -ne 1 ]]; then
    echo "check_docs: $f has $h1_count level-1 headings (expected 1)" >&2
    status=1
  fi
  if [[ ! -s "$f" ]]; then
    echo "check_docs: $f is empty" >&2
    status=1
  fi
done

[[ "$status" -eq 0 ]] || fail "one or more documents failed structural checks"

echo "check_docs passed for '$target'"
