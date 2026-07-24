#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
metadata="$root_dir/agents/openai.yaml"

fail() {
  printf 'swiftui-optimization check failed: %s\n' "$1" >&2
  exit 1
}

[[ -f "$skill_file" ]] || fail "SKILL.md is missing"
[[ -f "$metadata" ]] || fail "agents/openai.yaml is missing"

for reference in data-flow-and-diffing observation construction-patterns profiling source-notes; do
  [[ -f "$root_dir/references/$reference.md" ]] ||
    fail "references/$reference.md is missing"
  grep -q "references/$reference.md" "$skill_file" ||
    fail "SKILL.md does not route to references/$reference.md"
done

lines="$(wc -l < "$skill_file" | tr -d ' ')"
[[ "$lines" -le 200 ]] ||
  fail "SKILL.md has $lines lines; move details into references/"

grep -q '^name: swiftui-optimization$' "$skill_file" ||
  fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" ||
  fail "description must start with 'Use when'"
grep -q 'Self._printChanges()' "$skill_file" ||
  fail "debug update guidance is missing"
grep -q 'custom macros' "$skill_file" ||
  fail "Airbnb macro caveat is missing"
grep -q 'Do not claim completion from fewer `body` logs alone' "$skill_file" ||
  fail "measurement completion gate is missing"
grep -q '\$swiftui-optimization' "$metadata" ||
  fail "default prompt does not reference the skill"

if rg -n 'TO''DO|PLACE''HOLDER' "$root_dir" >/dev/null; then
  fail "placeholder content remains"
fi

printf 'swiftui-optimization check passed\n'
