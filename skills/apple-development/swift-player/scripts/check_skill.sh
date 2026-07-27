#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
sources="$root_dir/references/sources.md"

fail() {
  printf 'swift-player check failed: %s\n' "$1" >&2
  exit 1
}

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
grep -q '^name: swift-player$' "$skill_file" ||
  fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" ||
  fail "description must start with 'Use when'"
[[ "$(basename "$root_dir")" == "swift-player" ]] ||
  fail "folder name must match the skill name"

description_length="$(
  sed -n 's/^description: //p' "$skill_file" | LC_ALL=C wc -c | tr -d ' '
)"
[[ "$description_length" -le 1025 ]] ||
  fail "description exceeds the 1024-character content limit"

skill_lines="$(wc -l < "$skill_file" | tr -d ' ')"
[[ "$skill_lines" -le 200 ]] ||
  fail "SKILL.md has $skill_lines lines; move details into references/"

references=(
  architecture-and-state
  lifecycle-and-transport
  presentation-and-system-integration
  streaming-and-multiview
  diagnostics-and-testing
  sources
)

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
[[ "$(sed -n '2p' "$metadata")" == '  display_name: "Swift Player"' ]] ||
  fail "display name is stale or malformed"
[[ "$(sed -n '3p' "$metadata")" == \
  '  short_description: "Build resilient Apple media playback"' ]] ||
  fail "short description is stale or malformed"
[[ "$(sed -n '4p' "$metadata")" == \
  '  default_prompt: "Use $swift-player to design or review this AVFoundation playback flow for correct ownership, state, teardown, buffering, system integration, and measurable reliability."' ]] ||
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
  'one explicit session owner' \
  'iOS, iPadOS, tvOS, visionOS, macOS, or Mac Catalyst' \
  'initial delivery' \
  'rate == 0'

require_in "$root_dir/references/architecture-and-state.md" \
  'MainActor' \
  'AVPlayer.isObservationEnabled' \
  'timeControlStatus' \
  'reasonForWaitingToPlay' \
  'isReadyForDisplay'

require_in "$root_dir/references/lifecycle-and-transport.md" \
  'removeTimeObserver' \
  'cancelPendingSeeks' \
  'cancelPendingPrerolls' \
  'request generation' \
  "KVO's \`.initial\` option"

require_in "$root_dir/references/presentation-and-system-integration.md" \
  'AVPlayerView' \
  'AVAudioSession' \
  'watchOS playback as outside' \
  "AVKit's automatic Now Playing publication" \
  'do not create an' \
  'exactly one publication and command stack' \
  'undefined behavior' \
  'MPNowPlayingSession' \
  'MPRemoteCommandCenter' \
  'automaticallyPublishesNowPlayingInfo' \
  'AVPlayerItem.nowPlayingInfo' \
  "Do not write to the session's" \
  'before writing the session'

require_in "$root_dir/references/streaming-and-multiview.md" \
  'AVContentKeySession' \
  'FairPlay key loading through' \
  'AVAssetDownloadConfiguration' \
  'AVPlaybackCoordinationMedium' \
  'AVRoutingPlaybackArbiter' \
  'networkResourcePriority' \
  'AVPlayerLooper' \
  'preferredForwardBufferDuration' \
  'mediastreamvalidator'

require_in "$root_dir/references/diagnostics-and-testing.md" \
  'AVMetrics' \
  'synchronous `accessLog()`' \
  '50 open/close'

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

if grep -Eiq 'utm_|[?](ref|source|language)=' "$root_dir"/references/*.md; then
  fail "source links contain tracking or presentation query parameters"
fi

non_apple_urls="$(
  grep -Eo 'https://[^) >]+' "$sources" |
    grep -Ev '^https://developer\.apple\.com/' || true
)"
[[ -z "$non_apple_urls" ]] ||
  fail "sources.md contains non-Apple URLs: $non_apple_urls"

repo_root="$(cd "$root_dir/../../.." && pwd)"
if [[ -d "$repo_root/.git" &&
      -f "$repo_root/skills/apple-development/swift-player/SKILL.md" &&
      -f "$repo_root/README.md" &&
      -x "$repo_root/install.sh" ]]; then
  readme="$repo_root/README.md"
  grep -Fq '[`swift-player`](skills/apple-development/swift-player/)' "$readme" ||
    fail "repository README skill catalog entry is missing"
  grep -Fq '### Apple development / `swift-player`' "$readme" ||
    fail "repository README navigation section is missing"
  grep -Fq './install.sh swift-player' "$readme" ||
    fail "repository README installation example is missing"
  grep -Fq \
    'Use $swift-player to design or review this AVFoundation playback flow for correct ownership, state, teardown, buffering, system integration, and measurable reliability.' \
    "$readme" ||
    fail "repository README default prompt is stale"
  grep -Fq 'skills/apple-development/swift-player/SKILL.md' "$readme" ||
    fail "repository README does not link SKILL.md"
  grep -Fq \
    'skills/apple-development/swift-player/scripts/check_skill.sh' \
    "$readme" ||
    fail "repository README does not link scripts/check_skill.sh"

  for reference in "${references[@]}"; do
    grep -Fq \
      "skills/apple-development/swift-player/references/$reference.md" \
      "$readme" ||
      fail "repository README does not link references/$reference.md"
  done
fi

printf 'swift-player check passed\n'
