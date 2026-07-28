#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
sources="$root_dir/references/sources.md"

fail() {
  printf 'apple-product-marketing check failed: %s\n' "$1" >&2
  exit 1
}

references=(
  methodology
  positioning-and-messaging
  app-store-discovery
  conversion-and-experiments
  localization-and-transcreation
  launch-and-communications
  apple-ads
  analytics-and-attribution
  web-seo-and-automation
  deliverables
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
grep -q '^name: apple-product-marketing$' "$skill_file" ||
  fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" ||
  fail "description must start with 'Use when'"
[[ "$(basename "$root_dir")" == "apple-product-marketing" ]] ||
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
  '  display_name: "Apple Product Marketing"' ]] ||
  fail "display name is stale or malformed"
[[ "$(sed -n '3p' "$metadata")" == \
  '  short_description: "Position and promote apps across Apple channels"' ]] ||
  fail "short description is stale or malformed"
[[ "$(sed -n '4p' "$metadata")" == \
  '  default_prompt: "Use $apple-product-marketing to position this app and build a compliant, measurable App Store growth plan."' ]] ||
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
  'Define positioning before optimizing copy or keywords' \
  'Keep App Store ASO separate from web SEO' \
  'Check live Apple documentation' \
  'Treat undocumented ranking behavior' \
  'Do not silently turn an audit' \
  'draft pending product or market validation'

require_in "$root_dir/references/methodology.md" \
  '**Verified fact**' \
  'End-to-end workflow' \
  'Decision and completion gates'

require_in "$root_dir/references/positioning-and-messaging.md" \
  'current alternatives' \
  'claim ledger' \
  'Goal'

require_in "$root_dir/references/app-store-discovery.md" \
  'up to 70 additional Custom Product Pages' \
  'fall 2026' \
  'United States' \
  '`en_US` metadata' \
  'price terms in keyword metadata' \
  'common-task evidence'

require_in "$root_dir/references/conversion-and-experiments.md" \
  'native treatments support app icons' \
  'subtitle, description' \
  'Do not declare a winner'

require_in "$root_dir/references/localization-and-transcreation.md" \
  '**Keyword research**' \
  'Do not invent search volume' \
  'qualified human review'

require_in "$root_dir/references/launch-and-communications.md" \
  'Do not recommend pre-order' \
  'never imply guaranteed selection'

require_in "$root_dir/references/apple-ads.md" \
  'Brand, Category, Competitor, and Discovery' \
  'download versus first app open' \
  'Do not optimize CPI'

require_in "$root_dir/references/analytics-and-attribution.md" \
  'unique impressions and total downloads' \
  'App Store search source alone' \
  'Do not call the difference “lost users”'

require_in "$root_dir/references/web-seo-and-automation.md" \
  '`hreflang`' \
  'Universal Links' \
  'Generate a dry-run or explicit diff'

require_in "$root_dir/references/deliverables.md" \
  'ready to execute' \
  'Authorization boundary'

source_urls="$(
  grep -Eho 'https://[^) >]+' "$sources" |
    sort -u
)"
unique_source_count="$(
  printf '%s\n' "$source_urls" |
    sed '/^$/d' |
    wc -l |
    tr -d ' '
)"
[[ "$unique_source_count" -eq 83 ]] ||
  fail "sources.md lists $unique_source_count unique sources instead of 83"

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

if grep -Eiq 'utm_|[?](ref|source|language)=' "$sources"; then
  fail "source links contain tracking or presentation query parameters"
fi

repo_root="$(cd "$root_dir/../../.." && pwd)"
repo_skill_dir="$repo_root/skills/apple-development/apple-product-marketing"
if [[ "$root_dir" == "$repo_skill_dir" &&
      -e "$repo_root/.git" &&
      -f "$repo_root/README.md" &&
      -x "$repo_root/install.sh" ]]; then
  readme="$repo_root/README.md"
  grep -Fq \
    '[`apple-product-marketing`](skills/apple-development/apple-product-marketing/)' \
    "$readme" ||
    fail "repository README skill catalog entry is missing"
  grep -Fq '### Apple development / `apple-product-marketing`' "$readme" ||
    fail "repository README navigation section is missing"
  grep -Fq './install.sh apple-product-marketing' "$readme" ||
    fail "repository README installation example is missing"
  grep -Fq \
    'Use $apple-product-marketing to position this app and build a compliant, measurable App Store growth plan.' \
    "$readme" ||
    fail "repository README default prompt is stale"
  grep -Fq \
    'skills/apple-development/apple-product-marketing/SKILL.md' \
    "$readme" ||
    fail "repository README does not link SKILL.md"
  grep -Fq \
    'skills/apple-development/apple-product-marketing/scripts/check_skill.sh' \
    "$readme" ||
    fail "repository README does not link scripts/check_skill.sh"

  for reference in "${references[@]}"; do
    grep -Fq \
      "skills/apple-development/apple-product-marketing/references/$reference.md" \
      "$readme" ||
      fail "repository README does not link references/$reference.md"
  done
fi

printf 'apple-product-marketing check passed\n'
