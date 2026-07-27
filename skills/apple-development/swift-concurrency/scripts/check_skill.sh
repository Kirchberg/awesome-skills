#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"
sources="$root_dir/references/sources.md"

fail() {
  printf 'swift-concurrency check failed: %s\n' "$1" >&2
  exit 1
}

[[ -f "$skill_file" ]] || fail "SKILL.md is missing"
[[ -f "$metadata" ]] || fail "agents/openai.yaml is missing"
[[ "$(sed -n '1p' "$skill_file")" == "---" ]] ||
  fail "SKILL.md frontmatter must start on line 1"
[[ "$(sed -n '4p' "$skill_file")" == "---" ]] ||
  fail "SKILL.md frontmatter must contain only name and description"
[[ "$(grep -c '^---$' "$skill_file")" -eq 2 ]] ||
  fail "SKILL.md must contain exactly two frontmatter delimiters"

references=(
  mental-model
  structured-concurrency
  isolation-and-sendability
  streams-and-bridges
  swiftui-and-mainactor
  performance-and-memory
  testing-and-review
  patterns
  migration-methodology
  migration-tooling
  migration-state
  sources
)

for reference in "${references[@]}"; do
  path="$root_dir/references/$reference.md"
  [[ -f "$path" ]] || fail "references/$reference.md is missing"
  grep -Fq "references/$reference.md" "$skill_file" ||
    fail "SKILL.md does not route to references/$reference.md"
done

lines="$(wc -l < "$skill_file" | tr -d ' ')"
[[ "$lines" -le 220 ]] ||
  fail "SKILL.md has $lines lines; move details into references/"

grep -q '^name: swift-concurrency$' "$skill_file" ||
  fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" ||
  fail "description must start with 'Use when'"

description_length="$(
  sed -n 's/^description: //p' "$skill_file" | LC_ALL=C wc -c | tr -d ' '
)"
[[ "$description_length" -le 1025 ]] ||
  fail "description exceeds the 1024-character content limit"

grep -Fq 'display_name: "Swift Concurrency"' "$metadata" ||
  fail "display name is stale"
grep -Fq 'default_prompt: "Use $swift-concurrency' "$metadata" ||
  fail 'default prompt does not invoke $swift-concurrency'
grep -Fq 'allow_implicit_invocation: true' "$metadata" ||
  fail "implicit invocation policy is missing"

for required in \
  'NonisolatedNonsendingByDefault' \
  '@concurrent' \
  'Task.detached' \
  '@unchecked Sendable' \
  'withTaskCancellationHandler' \
  'profile → isolate → fix → verify'; do
  grep -Fq "$required" "$skill_file" "$root_dir"/references/*.md ||
    fail "required guardrail or concept is missing: $required"
done

core_count="$(
  awk '
    /^## Required core$/ { inside = 1; next }
    inside && /^## / { exit }
    inside && /^[0-9]+\. \*\*/ { count += 1 }
    END { print count + 0 }
  ' "$sources"
)"
[[ "$core_count" -eq 15 ]] ||
  fail "sources.md must contain exactly 15 required core sources"
grep -Fq 'Last reviewed: 2026-07-27.' "$sources" ||
  fail "source review date is missing or stale"
grep -Fq 'Stable baseline: Swift 6.3.3.' "$sources" ||
  fail "stable Swift baseline is missing or stale"

if grep -Eq \
  'utm_source=|github\.com/apple/swift-evolution|swift-evolution/raw/' \
  "$root_dir"/references/*.md; then
  fail "source links contain tracking parameters or obsolete hosts"
fi

grep -Fq '.swift-concurrency/migrations/<task-id>/' \
  "$root_dir/references/migration-state.md" ||
  fail "current migration-state location is missing"

printf 'swift-concurrency check passed\n'
