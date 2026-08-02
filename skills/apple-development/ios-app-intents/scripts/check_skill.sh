#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
sources="$root_dir/references/sources.md"
repository_root="$(cd "$root_dir/../../.." && pwd)"
readme=""

if [[ "$root_dir" == \
    "$repository_root/skills/apple-development/ios-app-intents" &&
    -d "$repository_root/.git" &&
    -f "$repository_root/README.md" &&
    -x "$repository_root/install.sh" ]]; then
  readme="$repository_root/README.md"
fi

fail() {
  printf 'ios-app-intents check failed: %s\n' "$1" >&2
  exit 1
}

references=(
  first-pass-audit
  intent-design
  entities-and-queries
  runtime-and-routing
  dependencies-and-modules
  app-shortcuts-and-localization
  spotlight-and-donations
  surfaces-and-snippets
  migration-and-versioning
  testing-and-evidence
  code-patterns
  beta-and-version-boundaries
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
grep -q '^name: ios-app-intents$' "$skill_file" ||
  fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" ||
  fail "description must start with 'Use when'"
[[ "$(basename "$root_dir")" == "ios-app-intents" ]] ||
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
  '  display_name: "iOS App Intents"' ]] ||
  fail "display name is stale or malformed"
[[ "$(sed -n '3p' "$metadata")" == \
  '  short_description: "Design and ship production-ready App Intents"' ]] ||
  fail "short description is stale or malformed"
[[ "$(sed -n '4p' "$metadata")" == \
  '  default_prompt: "Use $ios-app-intents to audit this Apple-platform app and implement a production-ready App Intents integration with stable entities, explicit execution modes, routing, and verification."' ]] ||
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

grep -Fq 'AppEntity' "$root_dir/references/entities-and-queries.md" ||
  fail "AppEntity guidance is missing from entities-and-queries.md"
grep -Eiq 'stable (entity )?(IDs?|identifiers?)' \
  "$root_dir/references/entities-and-queries.md" ||
  fail "stable entity identifier guardrail is missing"
grep -Fq 'AppShortcutsProvider' \
  "$root_dir/references/app-shortcuts-and-localization.md" ||
  fail "AppShortcutsProvider guidance is missing"
grep -Fq 'supportedModes' "$root_dir/references/runtime-and-routing.md" ||
  fail "supportedModes guidance is missing"
grep -Fq 'openAppWhenRun' \
  "$root_dir/references/runtime-and-routing.md" \
  "$root_dir/references/migration-and-versioning.md" \
  "$root_dir/references/beta-and-version-boundaries.md" ||
  fail "openAppWhenRun migration guidance is missing"
grep -Eiq 'deprecat|legacy|obsolete' \
  "$root_dir/references/runtime-and-routing.md" \
  "$root_dir/references/migration-and-versioning.md" \
  "$root_dir/references/beta-and-version-boundaries.md" ||
  fail "openAppWhenRun must be treated as a deprecated or legacy API"

beta_reference="$root_dir/references/beta-and-version-boundaries.md"
grep -Eiq '\bstable\b' "$beta_reference" ||
  fail "stable-version guidance is missing from beta-and-version-boundaries.md"
grep -Eiq '\b(beta|prerelease|pre-release)\b' "$beta_reference" ||
  fail "beta-version guidance is missing from beta-and-version-boundaries.md"
grep -Eiq 'separat|split|distinct|do not mix' "$beta_reference" ||
  fail "stable and beta guidance must be explicitly separated"
grep -Eiq 'availability|version[- ]gat|guard' "$beta_reference" ||
  fail "beta APIs must require availability or version gating"

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

reference_urls="$(
  grep -Eho 'https://[^) >]+' "$root_dir"/references/*.md || true
)"
[[ -n "$reference_urls" ]] || fail "references contain no source URLs"

non_apple_urls="$(
  printf '%s\n' "$reference_urls" |
    grep -Ev '^https://developer\.apple\.com/' ||
    true
)"
[[ -z "$non_apple_urls" ]] ||
  fail "references contain non-Apple URLs: $non_apple_urls"

if grep -Eiq \
  'utm_|[?&](campaign|changes|language|medium|ref|source|time)=' \
  "$root_dir"/references/*.md; then
  fail "source links contain tracking or presentation query parameters"
fi

source_urls="$(grep -Eo 'https://[^) >]+' "$sources" || true)"
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
[[ "$source_count" -gt 0 ]] || fail "sources.md contains no source URLs"
[[ "$unique_source_count" -eq "$source_count" ]] ||
  fail "sources.md contains duplicate source URLs"

if [[ -n "$readme" ]]; then
  grep -Fq \
    '[`ios-app-intents`](skills/apple-development/ios-app-intents/)' \
    "$readme" || fail "README skill catalog entry is missing"
  grep -Fq '    ios-app-intents/' "$readme" ||
    fail "README repository layout entry is missing"
  grep -Fq './install.sh ios-app-intents' "$readme" ||
    fail "README install example is missing"
  grep -Fq '### Apple development / `ios-app-intents`' "$readme" ||
    fail "README navigation section is missing"
  grep -Fq \
    'Use $ios-app-intents to audit this Apple-platform app and implement a production-ready App Intents integration with stable entities, explicit execution modes, routing, and verification.' \
    "$readme" || fail "README default prompt is stale"
  grep -Fq 'skills/apple-development/ios-app-intents/SKILL.md' "$readme" ||
    fail "README does not link SKILL.md"
  grep -Fq \
    'skills/apple-development/ios-app-intents/scripts/check_skill.sh' \
    "$readme" || fail "README does not link scripts/check_skill.sh"

  for reference in "${references[@]}"; do
    grep -Fq \
      "skills/apple-development/ios-app-intents/references/$reference.md" \
      "$readme" || fail "README does not link references/$reference.md"
  done
fi

printf 'ios-app-intents check passed\n'
