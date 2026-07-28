#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
sources="$root_dir/references/sources.md"
repository_root="$(cd "$root_dir/../../.." && pwd)"
readme=""
if [[ "$root_dir" == \
    "$repository_root/skills/apple-development/apple-platform-design" &&
    -f "$repository_root/README.md" &&
    -f "$repository_root/install.sh" ]]; then
  readme="$repository_root/README.md"
fi

fail() {
  printf 'apple-platform-design check failed: %s\n' "$1" >&2
  exit 1
}

references=(
  00-design-principles
  01-information-architecture-and-navigation
  02-layout-and-visual-hierarchy
  03-components-and-patterns
  04-color-typography-and-materials
  05-writing-and-naming
  06-onboarding-and-discoverability
  07-motion-feedback-and-haptics
  08-accessibility-inclusion-and-privacy
  09-implementation-handoff
  10-design-review-checklist
  sources
)

[[ -f "$skill_file" ]] || fail "SKILL.md is missing"
[[ -f "$metadata" ]] || fail "agents/openai.yaml is missing"
[[ -f "$sources" ]] || fail "references/sources.md is missing"
[[ -x "$root_dir/scripts/check_skill.sh" ]] ||
  fail "scripts/check_skill.sh must be executable"

[[ "$(sed -n '1p' "$skill_file")" == "---" ]] ||
  fail "SKILL.md frontmatter must start on line 1"
[[ "$(sed -n '4p' "$skill_file")" == "---" ]] ||
  fail "SKILL.md frontmatter must contain only name and description"
[[ "$(grep -c '^---$' "$skill_file")" -eq 2 ]] ||
  fail "SKILL.md must contain exactly two frontmatter delimiters"
grep -q '^name: apple-platform-design$' "$skill_file" ||
  fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" ||
  fail "description must start with 'Use when'"
[[ "$(basename "$root_dir")" == "apple-platform-design" ]] ||
  fail "folder name must match the skill name"

description_length="$(
  sed -n 's/^description: //p' "$skill_file" |
    LC_ALL=C wc -c |
    tr -d ' '
)"
[[ "$description_length" -le 1025 ]] ||
  fail "description exceeds the 1024-character content limit"

skill_lines="$(wc -l < "$skill_file" | tr -d ' ')"
[[ "$skill_lines" -le 200 ]] ||
  fail "SKILL.md has $skill_lines lines; move details into references/"

for reference in "${references[@]}"; do
  path="$root_dir/references/$reference.md"
  [[ -f "$path" ]] || fail "references/$reference.md is missing"
  grep -Fq "references/$reference.md" "$skill_file" ||
    fail "SKILL.md does not route to references/$reference.md"

  reference_lines="$(wc -l < "$path" | tr -d ' ')"
  if [[ "$reference_lines" -gt 100 ]]; then
    grep -Fq '## Contents' "$path" ||
      fail "references/$reference.md needs a Contents section"
  fi
done

unexpected_references=()
for path in "$root_dir"/references/*.md; do
  name="$(basename "$path" .md)"
  known=0
  for reference in "${references[@]}"; do
    if [[ "$name" == "$reference" ]]; then
      known=1
      break
    fi
  done
  [[ "$known" -eq 1 ]] || unexpected_references+=("$name")
done
[[ "${#unexpected_references[@]}" -eq 0 ]] ||
  fail "unrouted reference files: ${unexpected_references[*]}"

[[ "$(wc -l < "$metadata" | tr -d ' ')" -eq 7 ]] ||
  fail "agents/openai.yaml must contain only the expected interface and policy"
[[ "$(sed -n '1p' "$metadata")" == "interface:" ]] ||
  fail "agents/openai.yaml interface mapping is malformed"
[[ "$(sed -n '2p' "$metadata")" == \
  '  display_name: "Apple Platform Design"' ]] ||
  fail "display name is stale or malformed"
[[ "$(sed -n '3p' "$metadata")" == \
  '  short_description: "Design and review native Apple interfaces"' ]] ||
  fail "short description is stale or malformed"
[[ "$(sed -n '4p' "$metadata")" == \
  '  default_prompt: "Use $apple-platform-design to design or review this Apple interface from user goals through native patterns, states, accessibility, and implementation guidance."' ]] ||
  fail "default prompt is stale or malformed"
[[ -z "$(sed -n '5p' "$metadata")" ]] ||
  fail "agents/openai.yaml mappings must be separated by one blank line"
[[ "$(sed -n '6p' "$metadata")" == "policy:" ]] ||
  fail "agents/openai.yaml policy mapping is malformed"
[[ "$(sed -n '7p' "$metadata")" == \
  '  allow_implicit_invocation: true' ]] ||
  fail "implicit invocation policy is missing or malformed"

if grep -Enq '\b(TODO|TBD|FIXME|PLACEHOLDER)\b' \
  "$skill_file" "$metadata" "$root_dir"/references/*.md; then
  fail "unfinished placeholder text remains"
fi

require_in() {
  local path="$1"
  shift
  local required
  for required in "$@"; do
    grep -Fq "$required" "$path" ||
      fail "$(basename "$path") is missing required guidance: $required"
  done
}

require_in "$skill_file" \
  'Turn a user goal' \
  'initial`, `loading`, `content`, `empty`' \
  'Prefer system patterns' \
  'Liquid Glass' \
  'eligibility, frequency, and invalidation' \
  'Review twice' \
  'runtime design verification pending'

require_in "$root_dir/references/00-design-principles.md" \
  '**Purpose:**' \
  '**Agency:**' \
  '**Responsibility:**' \
  '**Familiarity:**' \
  '**Flexibility:**' \
  '**Simplicity:**' \
  '**Craft:**' \
  '**Delight:**'

require_in "$root_dir/references/03-components-and-patterns.md" \
  'Use the component decision ladder' \
  'Admit custom components deliberately' \
  'Reject custom UI that passes screenshot review'

require_in "$root_dir/references/06-onboarding-and-discoverability.md" \
  'Correct the component, hierarchy, or timing first' \
  'For TipKit' \
  'Do not show a tip to someone who already'

require_in "$root_dir/references/07-motion-feedback-and-haptics.md" \
  '**Causality**' \
  '**Harmony**' \
  '**Utility**' \
  'Reduce Motion' \
  'Core Haptics'

require_in "$root_dir/references/08-accessibility-inclusion-and-privacy.md" \
  'Never encode status, selection, validity, or priority by color alone' \
  'Minimize collection, retention, exposure, and sharing' \
  'runtime verification pending'

require_in "$root_dir/references/09-implementation-handoff.md" \
  'deployment targets' \
  'Do not emulate a newer material' \
  'redistribute them in a skill or repository' \
  'A screenshot is a reference'

require_in "$root_dir/references/10-design-review-checklist.md" \
  'Pass 1: purpose, structure, and comprehension' \
  'Pass 2: presentation, interaction, and craft' \
  '**Evidence**' \
  '**Blocker**'

source_urls="$(
  sed -nE \
    's#^- \[[^]]+\]\((https://[^)]*)\)$#\1#p' \
    "$sources"
)"
source_count="$(
  printf '%s\n' "$source_urls" |
    sed '/^$/d' |
    wc -l |
    tr -d ' '
)"
unique_source_count="$(
  printf '%s\n' "$source_urls" |
    sed '/^$/d' |
    sort -u |
    wc -l |
    tr -d ' '
)"
apple_source_count="$(
  printf '%s\n' "$source_urls" |
    grep -c '^https://developer\.apple\.com/' ||
    true
)"

[[ "$source_count" -eq 70 ]] ||
  fail "sources.md lists $source_count sources instead of 70"
[[ "$unique_source_count" -eq "$source_count" ]] ||
  fail "sources.md contains duplicate source URLs"

apple_source_percent="$((apple_source_count * 100 / source_count))"
[[ "$apple_source_percent" -ge 85 && "$apple_source_percent" -le 90 ]] ||
  fail "Apple sources are $apple_source_percent%; expected 85-90%"

unexpected_domains="$(
  printf '%s\n' "$source_urls" |
    grep -Ev \
      '^https://(developer\.apple\.com|www\.nngroup\.com|jnd\.org)/' ||
    true
)"
[[ -z "$unexpected_domains" ]] ||
  fail "sources.md contains unexpected domains: $unexpected_domains"

if grep -Eiq 'utm_|[?&](changes|language|ref|source|time)=' "$sources"; then
  fail "source links contain tracking or presentation query parameters"
fi

review_date="$(
  sed -n 's/^Last reviewed: \([0-9][0-9-]*\)\.$/\1/p' "$sources"
)"
[[ "$review_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] ||
  fail "source review date is missing or malformed"

if review_epoch="$(
  date -j -f '%Y-%m-%d' "$review_date" '+%s' 2>/dev/null
)"; then
  :
elif review_epoch="$(date -d "$review_date" '+%s' 2>/dev/null)"; then
  :
else
  fail "source review date cannot be parsed"
fi

now_epoch="$(date '+%s')"
review_age_seconds="$((now_epoch - review_epoch))"
max_review_age_seconds="$((366 * 24 * 60 * 60))"
[[ "$review_age_seconds" -ge -86400 ]] ||
  fail "source review date is unexpectedly in the future"
[[ "$review_age_seconds" -le "$max_review_age_seconds" ]] ||
  fail "source review is more than 366 days old"

if [[ -n "$readme" ]]; then
  grep -Fq \
    '[`apple-platform-design`](skills/apple-development/apple-platform-design/)' \
    "$readme" || fail "README skill catalog entry is missing"
  grep -Fq '    apple-platform-design/' "$readme" ||
    fail "README repository layout entry is missing"
  grep -Fq './install.sh apple-platform-design' "$readme" ||
    fail "README install example is missing"
  grep -Fq '### Apple development / `apple-platform-design`' "$readme" ||
    fail "README detail section is missing"

  for reference in "${references[@]}"; do
    grep -Fq \
      "skills/apple-development/apple-platform-design/references/$reference.md" \
      "$readme" ||
      fail "README does not link references/$reference.md"
  done

  grep -Fq \
    'skills/apple-development/apple-platform-design/scripts/check_skill.sh' \
    "$readme" ||
    fail "README does not link scripts/check_skill.sh"
fi

printf 'apple-platform-design check passed\n'
