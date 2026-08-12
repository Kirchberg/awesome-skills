#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
source_map="$root_dir/references/sources.md"

fail() {
  printf 'swift-uikit-collections-performance check failed: %s\n' "$1" >&2
  exit 1
}

references=(
  methodology
  data-and-updates
  cells-and-layout
  images-and-prefetching
  profiling-and-testing
  sources
)

[[ -f "$skill_file" ]] || fail "SKILL.md is missing"
[[ -f "$metadata" ]] || fail "agents/openai.yaml is missing"
[[ -f "$source_map" ]] || fail "references/sources.md is missing"
[[ -x "$root_dir/scripts/check_skill.sh" ]] \
  || fail "scripts/check_skill.sh must be executable"
[[ ! -f "$root_dir/README.md" ]] || fail "skill-local README.md is not allowed"

[[ "$(sed -n '1p' "$skill_file")" == "---" ]] \
  || fail "SKILL.md frontmatter must start on line 1"
[[ "$(sed -n '4p' "$skill_file")" == "---" ]] \
  || fail "SKILL.md frontmatter must contain only name and description"
[[ "$(grep -c '^---$' "$skill_file")" -eq 2 ]] \
  || fail "SKILL.md must contain exactly two frontmatter delimiters"
grep -q '^name: swift-uikit-collections-performance$' "$skill_file" \
  || fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" \
  || fail "description must start with 'Use when'"

folder_name="$(basename "$root_dir")"
frontmatter_name="$(sed -n 's/^name: //p' "$skill_file")"
[[ "$folder_name" == "$frontmatter_name" ]] \
  || fail "folder name and frontmatter name differ"

skill_lines="$(wc -l < "$skill_file" | tr -d ' ')"
[[ "$skill_lines" -le 200 ]] \
  || fail "SKILL.md has $skill_lines lines; move details into references/"

description_length="$({
  sed -n 's/^description: //p' "$skill_file" | LC_ALL=C wc -c
} | tr -d ' ')"
[[ "$description_length" -le 1025 ]] \
  || fail "description exceeds the 1024-character content limit"

for reference in "${references[@]}"; do
  reference_file="$root_dir/references/$reference.md"
  [[ -f "$reference_file" ]] \
    || fail "references/$reference.md is missing"
  grep -q "references/$reference.md" "$skill_file" \
    || fail "SKILL.md does not route to references/$reference.md"

  reference_lines="$(wc -l < "$reference_file" | tr -d ' ')"
  if [[ "$reference_lines" -gt 100 ]]; then
    grep -q '^## Contents$' "$reference_file" \
      || fail "references/$reference.md needs a Contents section"
  fi
done

reference_count="$(find "$root_dir/references" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
[[ "$reference_count" -eq "${#references[@]}" ]] \
  || fail "references/ contains an unexpected markdown file"

expected_metadata='interface:
  display_name: "Swift UIKit Collections Performance"
  short_description: "Build and tune smooth UIKit collections"
  default_prompt: "Use $swift-uikit-collections-performance to diagnose and improve this UITableView or UICollectionView with evidence-backed updates, reuse, layout, image, and hitch guidance."

policy:
  allow_implicit_invocation: true'
[[ "$(cat "$metadata")" == "$expected_metadata" ]] \
  || fail "agents/openai.yaml is missing or stale"

grep -q 'Never apply an asynchronous result to a captured cell' "$skill_file" \
  || fail "captured-cell guardrail is missing"
grep -q 'Create each cell and supplementary registration once' "$skill_file" \
  || fail "registration lifetime guardrail is missing"
grep -q 'reconfigureItems' "$skill_file" \
  || fail "reconfiguration guidance is missing"
grep -q 'Treat prefetch callbacks as speculative and optional' "$skill_file" \
  || fail "prefetch fallback guardrail is missing"
grep -q 'self-sizing constraints' "$skill_file" \
  || fail "self-sizing guidance is missing"
grep -q 'Never call a visually smoother Simulator run' "$skill_file" \
  || fail "unmeasured claim guardrail is missing"
grep -q '\$app-performance' "$skill_file" \
  || fail "app-performance routing is missing"
grep -q '\$swift-ios-performance' "$skill_file" \
  || fail "swift-ios-performance routing is missing"
grep -q '\$swiftui-optimization' "$skill_file" \
  || fail "swiftui-optimization routing is missing"
grep -q '\$swift-concurrency' "$skill_file" \
  || fail "swift-concurrency routing is missing"

if find "$root_dir" -type f \
  \( -name '*.md' -o -name '*.yaml' -o -name '*.sh' \) \
  ! -path "$root_dir/scripts/check_skill.sh" \
  -exec grep -E -i -l \
    '(^|[^[:alnum:]_])(TODO|TBD|FIXME)([^[:alnum:]_]|$)' {} + \
  | grep -q .; then
  fail "placeholder content remains"
fi

source_lines="$(grep -E '^- \*\*[0-9]{2,3}/100\*\* — \[' "$source_map")"
source_count="$(printf '%s\n' "$source_lines" | sed '/^$/d' | wc -l | tr -d ' ')"
source_urls="$({
  printf '%s\n' "$source_lines" \
    | sed -E 's#.*\((https://.*)\) — .*#\1#'
})"
unique_source_count="$(printf '%s\n' "$source_urls" | sed '/^$/d' | sort -u | wc -l | tr -d ' ')"

[[ "$source_count" -eq 48 ]] \
  || fail "source map lists $source_count entries instead of 48"
[[ "$unique_source_count" -eq 48 ]] \
  || fail "source map lists $unique_source_count unique URLs instead of 48"
if printf '%s\n' "$source_urls" \
  | grep -Ev '^https://developer\.apple\.com/' >/dev/null; then
  fail "source map contains a non-Apple source domain"
fi
if printf '%s\n' "$source_urls" | grep -Eq '[?#]|utm_'; then
  fail "source map URLs must be canonical and tracking-free"
fi

grep -q '^Last reviewed: 2026-08-13\.$' "$source_map" \
  || fail "source review date is missing or stale"
grep -q 'Verify every API against the project' "$source_map" \
  || fail "API availability caveat is missing"
grep -q 'Tool names, hitch tracks' "$source_map" \
  || fail "tool-version caveat is missing"
grep -q 'may remain' "$source_map" \
  || fail "WWDC26 prerelease caveat is missing"

printf 'swift-uikit-collections-performance check passed\n'
