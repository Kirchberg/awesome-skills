#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
sources="$root_dir/references/sources.md"
repository_root="$(cd "$root_dir/../../.." && pwd)"
readme=""
if [[ "$root_dir" == \
    "$repository_root/skills/apple-development/swift-uikit-components" &&
    -f "$repository_root/README.md" &&
    -x "$repository_root/install.sh" ]]; then
  readme="$repository_root/README.md"
fi

fail() {
  printf 'swift-uikit-components check failed: %s\n' "$1" >&2
  exit 1
}

references=(
  methodology
  views-lifecycle-and-state
  layout-and-adaptivity
  controls-actions-and-input
  controllers-and-presentation
  lists-and-collections
  swiftui-interoperability
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
grep -q '^name: swift-uikit-components$' "$skill_file" ||
  fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" ||
  fail "description must start with 'Use when'"
[[ "$(basename "$root_dir")" == "swift-uikit-components" ]] ||
  fail "folder name must match the skill name"

description_length="$(
  sed -n 's/^description: //p' "$skill_file" |
    LC_ALL=C wc -c |
    tr -d ' '
)"
[[ "$description_length" -le 1025 ]] ||
  fail "description exceeds the 1024-character content limit"
if sed -n 's/^description: //p' "$skill_file" | grep -Eq '[<>]'; then
  fail "description contains unsupported angle brackets"
fi

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
  '  display_name: "Swift UIKit Components"' ]] ||
  fail "display name is stale or malformed"
[[ "$(sed -n '3p' "$metadata")" == \
  '  short_description: "Build robust, adaptive UIKit components"' ]] ||
  fail "short description is stale or malformed"
[[ "$(sed -n '4p' "$metadata")" == \
  '  default_prompt: "Use $swift-uikit-components to design or improve this UIKit component with system-first APIs, correct lifecycle and layout, and proportionate verification."' ]] ||
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
  'Separate one-time hierarchy and constraint construction from repeatable state' \
  'Do not equate modern UIKit with replacing every `UITableView`' \
  'Use the full parent-child view-controller containment sequence' \
  'Treat `UIHostingConfiguration` as cell content' \
  'Never raise the deployment target' \
  'runtime component verification pending'

require_in "$root_dir/references/methodology.md" \
  '**Repository fact**' \
  '**Platform fact**' \
  'generated SDK interfaces' \
  'Separate fixes from migrations'

require_in "$root_dir/references/views-lifecycle-and-state.md" \
  '`loadView()`' \
  '`updateConfiguration(using:)`' \
  '`UIContentConfiguration`' \
  'Make every configuration pass' \
  'stand alone.'

require_in "$root_dir/references/layout-and-adaptivity.md" \
  '`UIScreen.main.bounds`' \
  'automatic trait tracking only in methods and closures documented to support' \
  '`UIKeyboardLayoutGuide`' \
  'accessibility content sizes'

require_in "$root_dir/references/controls-actions-and-input.md" \
  '`UIButton.Configuration`' \
  '`UIContentUnavailableConfiguration`' \
  'responder chain' \
  'do not describe it as a universal' \
  'replacement for camera capture'

require_in "$root_dir/references/controllers-and-presentation.md" \
  'Call `addChild(_:)` before adding the child view.' \
  '`didMove(toParent:)`' \
  '`UISheetPresentationController`' \
  'valid `sourceView` and `sourceRect`'

require_in "$root_dir/references/lists-and-collections.md" \
  'Keep an existing `UITableView`' \
  'stable, unique section and item identifiers' \
  '`reconfigureItems(_:)`' \
  'captured cell or persistent index path'

require_in "$root_dir/references/swiftui-interoperability.md" \
  'Decide which framework owns navigation' \
  '`UIHostingController`' \
  '`UIHostingConfiguration`' \
  '`UIViewRepresentable`'

require_in "$root_dir/references/testing-and-evidence.md" \
  'Treat snapshots as change detectors' \
  'oldest supported OS' \
  'physical hardware' \
  '`runtime component verification pending`'

source_urls="$(
  sed -nE 's#^- \[[^]]+\]\((https://[^)]*)\)$#\1#p' "$sources"
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
[[ "$source_count" -ge 35 ]] ||
  fail "sources.md lists only $source_count primary sources"
[[ "$unique_source_count" -eq "$source_count" ]] ||
  fail "sources.md contains duplicate URLs"

if printf '%s\n' "$source_urls" | grep -Evq \
    '^https://developer\.apple\.com/'; then
  fail "sources.md contains a non-Apple URL"
fi
if printf '%s\n' "$source_urls" | grep -Eq '[?&](utm_|changes=|language=)'; then
  fail "sources.md contains tracking or presentation query parameters"
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

require_in "$sources" \
  'WWDC26 material describes the' \
  'current prerelease platform' \
  'generated SDK interface' \
  'Archived documentation'

if [[ -n "$readme" ]]; then
  require_in "$readme" \
    '[`swift-uikit-components`](skills/apple-development/swift-uikit-components/)' \
    '    swift-uikit-components/' \
    './install.sh swift-uikit-components' \
    '### Apple development / `swift-uikit-components`'

  for reference in "${references[@]}"; do
    grep -Fq \
      "skills/apple-development/swift-uikit-components/references/$reference.md" \
      "$readme" ||
      fail "README.md does not link references/$reference.md"
  done
  grep -Fq \
    'skills/apple-development/swift-uikit-components/scripts/check_skill.sh' \
    "$readme" || fail "README.md does not link scripts/check_skill.sh"
fi

printf 'swift-uikit-components check passed\n'
