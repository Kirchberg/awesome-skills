#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
sources="$root_dir/references/sources.md"
repository_root="$(cd "$root_dir/../../.." && pwd)"
readme=""
if [[ "$root_dir" == \
    "$repository_root/skills/apple-development/ios-liquid-glass" &&
    -f "$repository_root/README.md" &&
    -x "$repository_root/install.sh" ]]; then
  readme="$repository_root/README.md"
fi

fail() {
  printf 'ios-liquid-glass check failed: %s\n' "$1" >&2
  exit 1
}

references=(
  00-current-platform-state
  01-design-principles-and-hig
  02-audit-and-migration
  03-swiftui-system-components
  04-swiftui-custom-glass
  05-uikit-and-hybrid
  06-accessibility
  07-performance
  08-testing-and-evidence
  09-current-beta
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
grep -q '^name: ios-liquid-glass$' "$skill_file" ||
  fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" ||
  fail "description must start with 'Use when'"
[[ "$(basename "$root_dir")" == "ios-liquid-glass" ]] ||
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
  '  display_name: "iOS Liquid Glass"' ]] ||
  fail "display name is stale or malformed"
[[ "$(sed -n '3p' "$metadata")" == \
  '  short_description: "Adopt and review native Liquid Glass interfaces"' ]] ||
  fail "short description is stale or malformed"
[[ "$(sed -n '4p' "$metadata")" == \
  '  default_prompt: "Use $ios-liquid-glass to audit and implement this Apple interface with native Liquid Glass, safe fallbacks, accessibility, and measured validation."' ]] ||
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

if grep -Fq 'glassEffect(_:in:isEnabled:)' \
  "$skill_file" "$root_dir"/references/*.md; then
  fail "unsupported glassEffect(_:in:isEnabled:) signature is present"
fi
if grep -Fq 'scrollExtensionMode(.underSidebar)' \
  "$skill_file" "$root_dir"/references/*.md; then
  fail "unverified scrollExtensionMode(.underSidebar) guidance is present"
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
  'Treat Liquid Glass as a system-mediated interface material' \
  'Do not assume every existing translucent surface should become Liquid Glass.' \
  'Use the component decision ladder' \
  'Avoid glass-on-glass.' \
  'Do not invent a universal maximum number of effects.' \
  'performance verification pending'

require_in "$root_dir/references/00-current-platform-state.md" \
  'iOS 26' \
  '26.1' \
  'Confirm the compiler knows the symbol.' \
  'Xcode 27' \
  'visionOS `glassBackgroundEffect`'

require_in "$root_dir/references/01-design-principles-and-hig.md" \
  '**Content layer**' \
  '**Functional layer**' \
  'Reserve clear glass' \
  'Do not mix regular and clear variants' \
  'Reject a surface'

require_in "$root_dir/references/02-audit-and-migration.md" \
  '`UIVisualEffectView`' \
  '`UINavigationBarAppearance`' \
  '`UIDesignRequiresCompatibility`' \
  'Use an evidence-driven agent workflow'

require_in "$root_dir/references/03-swiftui-system-components.md" \
  '`NavigationStack`' \
  '`tabBarMinimizeBehavior`' \
  '`backgroundExtensionEffect`' \
  '`safeAreaBar`' \
  '`ToolbarSpacer`'

require_in "$root_dir/references/04-swiftui-custom-glass.md" \
  '`glassEffect(_:in:)`' \
  '`GlassEffectContainer`' \
  '`glassEffectUnion(id:namespace:)`' \
  '`glassEffectID(_:in:)`' \
  '`glassEffectTransition(_:)`' \
  'later 26.x availability' \
  '`#available` cannot parse an unknown symbol'

require_in "$root_dir/references/05-uikit-and-hybrid.md" \
  '`UIGlassEffect`' \
  '`UIGlassContainerEffect`' \
  '`UIButton.Configuration.glass()`' \
  '`UIBackgroundExtensionView`' \
  '`UIScrollEdgeElementContainerInteraction`' \
  '`navigationItem`' \
  'Choose exactly one framework to own'

require_in "$root_dir/references/06-accessibility.md" \
  'Reduce Transparency' \
  'Increase Contrast' \
  'Reduce Motion' \
  'Voice Control' \
  'production VoiceOver readiness'

require_in "$root_dir/references/07-performance.md" \
  'commit-side work' \
  'render-side work' \
  'Apple provides no universal maximum' \
  'Release-like build' \
  'measured hitch, power, or memory improvement'

require_in "$root_dir/references/08-testing-and-evidence.md" \
  '**Oldest supported OS below iOS 26**' \
  '**Stable iOS 26 family**' \
  '**Current prerelease OS**' \
  'screenshot tests as change detectors' \
  'performance verification pending'

require_in "$root_dir/references/09-current-beta.md" \
  'Snapshot: 2026-08-02. Beta-only.' \
  '`toolbarMinimizeBehavior`' \
  '`toolbarMinimizationBehavior`' \
  'An `if #available` check cannot make an API known to an older compiler.' \
  'Label beta findings provisional'

stable_references=(
  00-current-platform-state
  01-design-principles-and-hig
  02-audit-and-migration
  03-swiftui-system-components
  04-swiftui-custom-glass
  05-uikit-and-hybrid
  06-accessibility
  07-performance
  08-testing-and-evidence
)
for reference in "${stable_references[@]}"; do
  if grep -Eq \
    'ToolbarOverflowMenu|topBarPinnedTrailing|toolbarMinimizationBehavior' \
    "$root_dir/references/$reference.md"; then
    fail "beta-only toolbar guidance leaked into references/$reference.md"
  fi
done

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
apple_source_count="$(
  printf '%s\n' "$source_urls" |
    grep -c '^https://developer\.apple\.com/' ||
    true
)"

[[ "$source_count" -eq 50 ]] ||
  fail "sources.md lists $source_count sources instead of 50"
[[ "$unique_source_count" -eq "$source_count" ]] ||
  fail "sources.md contains duplicate source URLs"
for rank in $(seq 1 50); do
  grep -q "^- \[$rank · " "$sources" ||
    fail "sources.md is missing source number $rank"
done

apple_source_percent="$((apple_source_count * 100 / source_count))"
[[ "$apple_source_percent" -ge 90 ]] ||
  fail "Apple sources are only $apple_source_percent%; expected at least 90%"

unexpected_domains="$(
  printf '%s\n' "$source_urls" |
    grep -Ev \
      '^https://(developer\.apple\.com|learn\.chatgpt\.com|github\.com/openai)/' ||
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

grep -Fq '## Prerelease sources' "$sources" ||
  fail "sources.md does not isolate prerelease sources"
grep -Fq 'Xcode 27 release notes' "$sources" ||
  fail "sources.md is missing the Xcode 27 beta source"
grep -Fq 'iOS and iPadOS 27 release notes' "$sources" ||
  fail "sources.md is missing the iOS and iPadOS 27 beta source"

if [[ -n "$readme" ]]; then
  grep -Fq \
    '[`ios-liquid-glass`](skills/apple-development/ios-liquid-glass/)' \
    "$readme" ||
    fail "repository README skill catalog entry is missing"
  grep -Fq 'ios-liquid-glass/' "$readme" ||
    fail "repository README layout entry is missing"
  grep -Fq './install.sh ios-liquid-glass' "$readme" ||
    fail "repository README installation example is missing"
  grep -Fq '### Apple development / `ios-liquid-glass`' "$readme" ||
    fail "repository README navigation section is missing"
  grep -Fq \
    'Use $ios-liquid-glass to audit and implement this Apple interface with native Liquid Glass, safe fallbacks, accessibility, and measured validation.' \
    "$readme" ||
    fail "repository README default prompt is stale"
  grep -Fq 'skills/apple-development/ios-liquid-glass/SKILL.md' "$readme" ||
    fail "repository README does not link SKILL.md"
  grep -Fq \
    'skills/apple-development/ios-liquid-glass/scripts/check_skill.sh' \
    "$readme" ||
    fail "repository README does not link scripts/check_skill.sh"

  for reference in "${references[@]}"; do
    grep -Fq \
      "skills/apple-development/ios-liquid-glass/references/$reference.md" \
      "$readme" ||
      fail "repository README does not link references/$reference.md"
  done
fi

printf 'ios-liquid-glass check passed\n'
