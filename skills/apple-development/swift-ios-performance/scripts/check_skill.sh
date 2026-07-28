#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
source_map="$root_dir/references/ranked-sources.md"

fail() {
  printf 'swift-ios-performance check failed: %s\n' "$1" >&2
  exit 1
}

references=(
  methodology
  cost-model-and-compiler
  ownership-and-memory
  collections-algorithms-and-text
  concurrency-costs
  benchmarking
  low-level-and-accelerated
  ranked-sources
)

[[ -f "$skill_file" ]] || fail "SKILL.md is missing"
[[ -f "$metadata" ]] || fail "agents/openai.yaml is missing"
[[ -f "$source_map" ]] || fail "references/ranked-sources.md is missing"
[[ "$(sed -n '1p' "$skill_file")" == "---" ]] \
  || fail "SKILL.md frontmatter must start on line 1"
[[ "$(sed -n '4p' "$skill_file")" == "---" ]] \
  || fail "SKILL.md frontmatter must contain only name and description"
[[ "$(grep -c '^---$' "$skill_file")" -eq 2 ]] \
  || fail "SKILL.md must contain exactly two frontmatter delimiters"

for reference in "${references[@]}"; do
  reference_file="$root_dir/references/$reference.md"
  [[ -f "$reference_file" ]] \
    || fail "references/$reference.md is missing"
  grep -q "references/$reference.md" "$skill_file" \
    || fail "SKILL.md does not route to references/$reference.md"
done

lines="$(wc -l < "$skill_file" | tr -d ' ')"
[[ "$lines" -le 200 ]] \
  || fail "SKILL.md has $lines lines; move details into references/"

description_length="$(
  sed -n 's/^description: //p' "$skill_file" | LC_ALL=C wc -c | tr -d ' '
)"
[[ "$description_length" -le 1025 ]] \
  || fail "description exceeds the 1024-character content limit"

grep -q '^name: swift-ios-performance$' "$skill_file" \
  || fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" \
  || fail "description must start with 'Use when'"
grep -q 'stored `static let`' "$skill_file" \
  || fail "stored static let guidance is missing"
grep -q 'computed' "$skill_file" \
  || fail "stored-versus-computed guidance is missing"
grep -q 'allocation' "$skill_file" \
  || fail "allocation coverage is missing"
grep -q 'ARC' "$skill_file" \
  || fail "ARC coverage is missing"
grep -q 'dispatch' "$skill_file" \
  || fail "dispatch coverage is missing"
grep -q 'baseline and candidate' "$skill_file" \
  || fail "before-and-after evidence gate is missing"
grep -q 'Label an unmeasured recommendation as a hypothesis' "$skill_file" \
  || fail "unmeasured-claim guardrail is missing"
grep -q 'Do not require a profiler, chart, Simulator' "$skill_file" \
  || fail "source-proven correction action rule is missing"
grep -q 'Do not claim that `static let` is inherently faster' "$skill_file" \
  || fail "blanket-rule guardrail is missing"
grep -q 'rank the most useful sources from 0 to 100' "$skill_file" \
  || fail "source-ranking contract is missing"
grep -q '\$app-performance' "$skill_file" \
  || fail "app-performance routing is missing"
grep -q '\$swiftui-optimization' "$skill_file" \
  || fail "swiftui-optimization routing is missing"
grep -q '\$swift-concurrency' "$skill_file" \
  || fail "swift-concurrency routing is missing"

grep -q 'allow_implicit_invocation: true' "$metadata" \
  || fail "implicit invocation policy is missing"
grep -q 'default_prompt: "Use \$swift-ios-performance ' "$metadata" \
  || fail "default prompt is stale"

if find "$root_dir" -type f \
  \( -name '*.md' -o -name '*.yaml' -o -name '*.sh' \) \
  ! -path "$root_dir/scripts/check_skill.sh" \
  -exec grep -E -i -l \
    '(^|[^[:alnum:]_])(TODO|TBD|FIXME|PLACEHOLDER)([^[:alnum:]_]|$)' {} + \
  | grep -q .; then
  fail "placeholder content remains"
fi

source_lines="$(
  grep -E '^- \*\*[0-9]{2,3}/100\*\* — \[' "$source_map"
)"
source_count="$(
  printf '%s\n' "$source_lines" | sed '/^$/d' | wc -l | tr -d ' '
)"
source_urls="$(
  printf '%s\n' "$source_lines" \
    | sed -E 's#.*\((https://[^)]*)\).*#\1#'
)"
unique_source_count="$(
  printf '%s\n' "$source_urls" | sed '/^$/d' | sort -u | wc -l | tr -d ' '
)"

[[ "$source_count" -eq 48 ]] \
  || fail "ranked source map lists $source_count entries instead of 48"
[[ "$unique_source_count" -eq 48 ]] \
  || fail "ranked source map lists $unique_source_count unique URLs instead of 48"
if printf '%s\n' "$source_urls" \
  | grep -Ev \
    '^https://(developer\.apple\.com/|docs\.swift\.org/|www\.swift\.org/|github\.com/(swiftlang|apple)/|forums\.swift\.org/)' \
  >/dev/null; then
  fail "ranked source map contains an unapproved source domain"
fi

grep -q '^Last reviewed: 2026-07-27\.$' "$source_map" \
  || fail "source review date is missing or stale"
grep -q 'Instruments 27 features are preview' "$source_map" \
  || fail "WWDC26 preview caveat is missing"
grep -q 'not the latest release' "$source_map" \
  || fail "Swift 6.2 version caveat is missing"
grep -q 'repeated small reservations can defeat geometric growth' "$source_map" \
  || fail "reserveCapacity caveat is missing"
grep -q 'similar efficiency to `Array` for structs and enums' "$source_map" \
  || fail "ContiguousArray caveat is missing"

printf 'swift-ios-performance check passed\n'
