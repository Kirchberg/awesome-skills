#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
source_map="$root_dir/references/source-map.md"

fail() {
  printf 'voice-over-accessibility check failed: %s\n' "$1" >&2
  exit 1
}

references=(
  methodology
  semantics-and-navigation
  swiftui-and-uikit
  testing-and-evidence
  source-map
)

[[ -f "$skill_file" ]] || fail "SKILL.md is missing"
[[ -f "$metadata" ]] || fail "agents/openai.yaml is missing"
[[ -x "$root_dir/scripts/check_skill.sh" ]] \
  || fail "scripts/check_skill.sh is not executable"
[[ "$(sed -n '1p' "$skill_file")" == "---" ]] \
  || fail "SKILL.md frontmatter must start on line 1"
[[ "$(sed -n '4p' "$skill_file")" == "---" ]] \
  || fail "SKILL.md frontmatter must contain only name and description"
[[ "$(grep -c '^---$' "$skill_file")" -eq 2 ]] \
  || fail "SKILL.md must contain exactly two frontmatter delimiters"

for reference in "${references[@]}"; do
  reference_file="$root_dir/references/$reference.md"
  [[ -f "$reference_file" ]] || fail "references/$reference.md is missing"
  grep -Fq "references/$reference.md" "$skill_file" \
    || fail "SKILL.md does not route to references/$reference.md"
done

lines="$(wc -l < "$skill_file" | tr -d ' ')"
[[ "$lines" -le 200 ]] \
  || fail "SKILL.md has $lines lines; move details into references/"

grep -q '^name: voice-over-accessibility$' "$skill_file" \
  || fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" \
  || fail "description must start with 'Use when'"
grep -q 'This first version is VoiceOver-only' "$skill_file" \
  || fail "VoiceOver-only scope is missing"
grep -q 'common tasks' "$skill_file" \
  || fail "common-task gate is missing"
grep -q 'every supported device type' "$skill_file" \
  || fail "supported-device gate is missing"
grep -q 'name, role, value or state, actions' "$skill_file" \
  || fail "semantic contract is missing"
grep -q 'Group related content to reduce noise without hiding independent actions' \
  "$skill_file" || fail "grouping guardrail is missing"
grep -q 'Make the default activation match the ordinary tap' "$skill_file" \
  || fail "equivalent activation rule is missing"
grep -q 'VoiceOver on a physical device' "$skill_file" \
  || fail "physical-device testing gate is missing"
grep -q 'zero automated-audit findings' "$skill_file" \
  || fail "automated-audit limitation is missing"
grep -q 'manual VoiceOver verification pending' "$skill_file" \
  || fail "truthful incomplete-status wording is missing"

grep -q 'default_prompt: "Use \$voice-over-accessibility ' "$metadata" \
  || fail "default prompt is stale"
grep -q 'allow_implicit_invocation: true' "$metadata" \
  || fail "implicit invocation policy is missing"

if find "$root_dir" -type f \
  \( -name '*.md' -o -name '*.yaml' -o -name '*.sh' \) \
  ! -path "$root_dir/scripts/check_skill.sh" \
  -exec grep -E -i -l \
    '(^|[^[:alnum:]_])(TODO|TBD|FIXME)([^[:alnum:]_]|$)' {} + \
  | grep -q .; then
  fail "placeholder content remains"
fi

source_urls="$(
  sed -nE 's#^- \[[^]]+\]\((https://[^)]*)\).*#\1#p' "$source_map"
)"
source_count="$(
  printf '%s\n' "$source_urls" | sed '/^$/d' | wc -l | tr -d ' '
)"
unique_source_count="$(
  printf '%s\n' "$source_urls" \
    | sed '/^$/d' \
    | sort -u \
    | wc -l \
    | tr -d ' '
)"
[[ "$source_count" -eq 40 ]] \
  || fail "source map lists $source_count sources instead of 40"
[[ "$unique_source_count" -eq 40 ]] \
  || fail "source map lists $unique_source_count unique sources instead of 40"

for rank in $(seq 1 40); do
  grep -q "^- \\[$rank · " "$source_map" \
    || fail "source map is missing priority rank $rank"
done

grep -q '^Last reviewed: 2026-07-27\.$' "$source_map" \
  || fail "source review date is missing or stale"
grep -Fq \
  'https://developer.apple.com/help/app-store-connect/manage-app-accessibility/voiceover-evaluation-criteria/' \
  "$source_map" || fail "Apple evaluation criteria source is missing"
grep -Fq 'https://developer.apple.com/videos/play/wwdc2026/220/' \
  "$source_map" || fail "WWDC26 custom-control source is missing"
grep -Fq 'https://rubanov.dev/a11y-book/' "$source_map" \
  || fail "Rubanov first-hand source is missing"
grep -Fq \
  'https://github.com/cvs-health/ios-swiftui-accessibility-techniques' \
  "$source_map" || fail "CVS practical source is missing"

printf 'voice-over-accessibility check passed\n'
