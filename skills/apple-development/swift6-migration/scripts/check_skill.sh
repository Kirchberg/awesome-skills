#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"

fail() {
  printf 'swift6-migration check failed: %s\n' "$1" >&2
  exit 1
}

[[ -f "$skill_file" ]] || fail "SKILL.md is missing"
[[ -f "$metadata" ]] || fail "agents/openai.yaml is missing"

for reference in methodology tooling conversion-guide recipes state-schema; do
  [[ -f "$root_dir/references/$reference.md" ]] || fail "references/$reference.md is missing"
  grep -q "references/$reference.md" "$skill_file" || fail "SKILL.md does not route to references/$reference.md"
done

lines="$(wc -l < "$skill_file" | tr -d ' ')"
[[ "$lines" -le 200 ]] || fail "SKILL.md has $lines lines; move details into references/"

grep -q '^name: swift6-migration$' "$skill_file" || fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" || fail "description must start with 'Use when'"
grep -q 'SWIFT_VERSION = 6' "$skill_file" || fail "Swift 6 Xcode setting is missing"
grep -q 'swift-tools-version' "$skill_file" || fail "SwiftPM compatibility guidance is missing"
grep -q '@unchecked Sendable' "$skill_file" || fail "unsafe Sendable guardrail is missing"
grep -q 'MainActor.assumeIsolated' "$skill_file" || fail "dynamic isolation guardrail is missing"
grep -q 'MIGRATION_REPORT.md' "$skill_file" || fail "completion report is missing"

printf 'swift6-migration check passed\n'
