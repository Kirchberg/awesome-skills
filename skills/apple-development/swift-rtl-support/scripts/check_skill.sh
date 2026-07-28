#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
sources="$root_dir/references/sources.md"

fail() {
  printf 'swift-rtl-support check failed: %s\n' "$1" >&2
  exit 1
}

references=(
  methodology
  layout-and-navigation
  text-and-formatting
  swiftui-and-uikit
  assets-and-typography
  testing-and-evidence
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
grep -q '^name: swift-rtl-support$' "$skill_file" ||
  fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" ||
  fail "description must start with 'Use when'"
[[ "$(basename "$root_dir")" == "swift-rtl-support" ]] ||
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
  '  display_name: "Swift RTL Support"' ]] ||
  fail "display name is stale or malformed"
[[ "$(sed -n '3p' "$metadata")" == \
  '  short_description: "Build native RTL support for Swift iOS apps"' ]] ||
  fail "short description is stale or malformed"
[[ "$(sed -n '4p' "$metadata")" == \
  '  default_prompt: "Use $swift-rtl-support to implement or audit this SwiftUI or UIKit flow for native RTL layout, bidi text, localized assets, and regression testing."' ]] ||
  fail "default prompt is stale or malformed"
[[ -z "$(sed -n '5p' "$metadata")" ]] ||
  fail "agents/openai.yaml mappings must be separated by one blank line"
[[ "$(sed -n '6p' "$metadata")" == "policy:" ]] ||
  fail "agents/openai.yaml policy mapping is malformed"
[[ "$(sed -n '7p' "$metadata")" == \
  '  allow_implicit_invocation: true' ]] ||
  fail "implicit invocation policy is missing or malformed"

if grep -Einq '\b(TODO|TBD|FIXME|PLACEHOLDER)\b' \
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
  'reading-flow' \
  '**spatial**' \
  '**playback**' \
  'first choose exactly one direction policy' \
  'Then decide independently' \
  'Right-to-Left Pseudolanguage' \
  'real Arabic and real Hebrew' \
  'implemented; RTL device verification pending'

require_in "$root_dir/references/methodology.md" \
  'Classify direction before changing code' \
  'Time or calendar based' \
  'Content image' \
  'Directional asset' \
  'each claimed language and relevant' \
  'RTL-ready'

require_in "$root_dir/references/layout-and-navigation.md" \
  'LayoutSubviews.layoutDirection' \
  'leadingAnchor' \
  'semanticContentAttribute' \
  'flipsHorizontallyInOppositeLayoutDirection' \
  'Do not reverse the underlying data array'

require_in "$root_dir/references/text-and-formatting.md" \
  'String(localized:)' \
  'FormatStyle' \
  'Unicode Bidirectional Algorithm' \
  'logical storage order' \
  'UITextView.selectedRanges' \
  'textLayoutManager'

require_in "$root_dir/references/swiftui-and-uikit.md" \
  'content-based default writing direction' \
  'NSDirectionalEdgeInsets' \
  'effectiveUserInterfaceLayoutDirection' \
  'TextKit 2'

require_in "$root_dir/references/assets-and-typography.md" \
  '**Fixed**' \
  '**Mirrors**' \
  '**Both**' \
  '`forward` and `backward`' \
  'zero tracking' \
  'Verify Hebrew, Persian, and Urdu independently'

require_in "$root_dir/references/testing-and-evidence.md" \
  'Right-to-Left Pseudolanguage With Right-to-Left Strings' \
  'real Arabic' \
  'real Hebrew' \
  'Dynamic Type' \
  'selectedRanges' \
  'qualified native speaker for each claimed language'

source_urls="$(
  sed -nE \
    's#^- \[[0-9]+ · [^]]+\]\((https://[^)]*)\)$#\1#p' \
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
[[ "$source_count" -eq 40 ]] ||
  fail "sources.md lists $source_count sources instead of 40"
[[ "$unique_source_count" -eq 40 ]] ||
  fail "sources.md lists $unique_source_count unique sources instead of 40"

for rank in $(seq 1 40); do
  grep -q "^- \\[$rank · " "$sources" ||
    fail "sources.md is missing priority rank $rank"
done

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

unexpected_domains="$(
  grep -Eho 'https://[^) >]+' "$root_dir"/references/*.md |
    sort -u |
    grep -Ev \
      '^https://(developer\.apple\.com|www\.unicode\.org|unicode\.org|www\.w3\.org)/' ||
    true
)"
[[ -z "$unexpected_domains" ]] ||
  fail "reference files contain non-primary domains: $unexpected_domains"

if grep -Eiq 'utm_|[?](ref|source|language)=' \
  "$root_dir"/references/*.md; then
  fail "source links contain tracking or presentation query parameters"
fi

repo_root="$(cd "$root_dir/../../.." && pwd)"
if [[ -d "$repo_root/.git" &&
      -f "$repo_root/README.md" &&
      -x "$repo_root/install.sh" ]]; then
  readme="$repo_root/README.md"
  grep -Fq \
    '[`swift-rtl-support`](skills/apple-development/swift-rtl-support/)' \
    "$readme" ||
    fail "repository README skill catalog entry is missing"
  grep -Fq '### Apple development / `swift-rtl-support`' "$readme" ||
    fail "repository README navigation section is missing"
  grep -Fq './install.sh swift-rtl-support' "$readme" ||
    fail "repository README installation example is missing"
  grep -Fq \
    'Use $swift-rtl-support to implement or audit this SwiftUI or UIKit flow for native RTL layout, bidi text, localized assets, and regression testing.' \
    "$readme" ||
    fail "repository README default prompt is stale"
  grep -Fq 'skills/apple-development/swift-rtl-support/SKILL.md' "$readme" ||
    fail "repository README does not link SKILL.md"
  grep -Fq \
    'skills/apple-development/swift-rtl-support/scripts/check_skill.sh' \
    "$readme" ||
    fail "repository README does not link scripts/check_skill.sh"

  for reference in "${references[@]}"; do
    grep -Fq \
      "skills/apple-development/swift-rtl-support/references/$reference.md" \
      "$readme" ||
      fail "repository README does not link references/$reference.md"
  done
fi

printf 'swift-rtl-support check passed\n'
