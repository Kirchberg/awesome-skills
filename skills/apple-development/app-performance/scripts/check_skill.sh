#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
source_map="$root_dir/references/apple-source-map.md"

fail() {
  printf 'app-performance check failed: %s\n' "$1" >&2
  exit 1
}

references=(
  methodology
  tools-and-evidence
  responsiveness
  cpu-memory-size
  power-storage-network
  graphics
  apple-source-map
)

[[ -f "$skill_file" ]] || fail "SKILL.md is missing"
[[ -f "$metadata" ]] || fail "agents/openai.yaml is missing"
[[ "$(sed -n '1p' "$skill_file")" == "---" ]] \
  || fail "SKILL.md frontmatter must start on line 1"
[[ "$(sed -n '4p' "$skill_file")" == "---" ]] \
  || fail "SKILL.md frontmatter must contain only name and description"
[[ "$(grep -c '^---$' "$skill_file")" -eq 2 ]] \
  || fail "SKILL.md must contain exactly two frontmatter delimiters"

for reference in "${references[@]}"; do
  reference_file="$root_dir/references/$reference.md"
  [[ -f "$reference_file" ]] || fail "references/$reference.md is missing"
  grep -q "references/$reference.md" "$skill_file" \
    || fail "SKILL.md does not route to references/$reference.md"
done

lines="$(wc -l < "$skill_file" | tr -d ' ')"
[[ "$lines" -le 200 ]] \
  || fail "SKILL.md has $lines lines; move details into references/"

grep -q '^name: app-performance$' "$skill_file" \
  || fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" \
  || fail "description must start with 'Use when'"
grep -q 'physical device' "$skill_file" \
  || fail "physical-device evidence rule is missing"
grep -q 'separate a busy main thread' "$skill_file" \
  || fail "busy-versus-blocked routing is missing"
grep -q 'Do not invent a universal memory ceiling' "$skill_file" \
  || fail "contextual-threshold guardrail is missing"
grep -q 'baseline and candidate' "$skill_file" \
  || fail "before-and-after reporting gate is missing"
grep -q 'allow_implicit_invocation: true' "$metadata" \
  || fail "implicit invocation policy is missing"
grep -q 'default_prompt: "Use \$app-performance ' "$metadata" \
  || fail "default prompt is stale"

if find "$root_dir" -type f \
  \( -name '*.md' -o -name '*.yaml' -o -name '*.sh' \) \
  ! -path "$root_dir/scripts/check_skill.sh" \
  -exec grep -E -i -l \
    '(^|[^[:alnum:]_])(TODO|TBD|FIXME)([^[:alnum:]_]|$)' {} + \
  | grep -q .; then
  fail "TODO placeholder remains"
fi

source_urls="$(
  grep '^- \[' "$source_map" \
    | sed -E 's#.*\((https://developer\.apple\.com/[^)]*)\).*#\1#'
)"
source_count="$(printf '%s\n' "$source_urls" | sed '/^$/d' | wc -l | tr -d ' ')"
unique_source_count="$(
  printf '%s\n' "$source_urls" | sed '/^$/d' | sort -u | wc -l | tr -d ' '
)"
[[ "$source_count" -eq 48 ]] \
  || fail "source map lists $source_count pages instead of 48"
[[ "$unique_source_count" -eq 48 ]] \
  || fail "source map lists $unique_source_count unique pages instead of 48"
if printf '%s\n' "$source_urls" \
  | grep -Ev '^https://developer\.apple\.com/(documentation|tutorials)/' \
  >/dev/null; then
  fail "source map contains a noncanonical Apple documentation URL"
fi
grep -q 'all 28 entries listed directly' "$source_map" \
  || fail "direct collection coverage statement is missing"
grep -q 'all 13' "$source_map" \
  || fail "nested collection link coverage statement is missing"
grep -q 'add 12' "$source_map" \
  || fail "nested collection unique-page statement is missing"
grep -q 'all 8 chapters' "$source_map" \
  || fail "Instruments tutorial coverage statement is missing"

printf 'app-performance check passed\n'
