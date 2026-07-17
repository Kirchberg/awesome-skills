#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
rules_ref="$root_dir/references/core-planning-rules.md"
compact_template="$root_dir/references/compact-plan-template.md"
full_template="$root_dir/references/full-plan-template.md"
long_addendum="$root_dir/references/long-running-addendum.md"
metadata="$root_dir/agents/openai.yaml"

fail() {
  printf 'development-plan check failed: %s\n' "$1" >&2
  exit 1
}

for file in "$skill_file" "$rules_ref" "$compact_template" "$full_template" \
  "$long_addendum" "$metadata"; do
  [[ -f "$file" ]] || fail "required file is missing: $file"
done
[[ ! -e "$root_dir/references/plan-template.md" ]] \
  || fail "monolithic plan-template.md should stay split by planning mode"

lines="$(wc -l < "$skill_file" | tr -d ' ')"
[[ "$lines" -le 200 ]] \
  || fail "$skill_file has $lines lines; move details into references/"

grep -q '^name: development-plan$' "$skill_file" \
  || fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" \
  || fail "description must include the invocation trigger"
grep -q 'references/core-planning-rules.md' "$skill_file" \
  || fail "core rules routing is missing"
for reference in compact-plan-template full-plan-template long-running-addendum; do
  grep -q "references/$reference.md" "$skill_file" \
    || fail "$reference routing is missing"
done

for mode in Compact Full Long-running; do
  grep -q "\*\*$mode\*\*" "$skill_file" \
    || fail "$mode mode selection is missing"
done

grep -q 'least detailed mode' "$skill_file" \
  || fail "adaptive-depth principle is missing"
grep -q 'For plan-only requests, do not edit source or implementation files' "$skill_file" \
  || fail "plan-only source-write guard is missing"
grep -q '`Status: proposed`' "$skill_file" \
  || fail "plan-only proposed status is missing"
grep -q 'plan records intended work; it does not grant new authority' "$skill_file" \
  || fail "authority boundary is missing"
grep -q 'completed/' "$skill_file" \
  || fail "completed-plan lifecycle is missing"
grep -q 'abandoned/' "$skill_file" \
  || fail "abandoned-plan lifecycle is missing"
grep -q 'allow_implicit_invocation: true' "$metadata" \
  || fail "implicit invocation must stay enabled"
grep -q 'short_description: "Create adaptive, verifiable implementation plans"' "$metadata" \
  || fail "OpenAI short description is stale"
grep -q 'default_prompt: "Use \$development-plan to choose the right planning depth' "$metadata" \
  || fail "OpenAI default prompt is stale"

grep -q '^## Contents$' "$rules_ref" \
  || fail "core rules table of contents is missing"
grep -q 'Touching multiple files alone does not require full mode' "$rules_ref" \
  || fail "medium-task over-planning guard is missing"
grep -q 'roughly 60-120 total lines' "$rules_ref" \
  || fail "compact-plan clarity budget is missing"
grep -q '^## Check Outcome Classification$' "$rules_ref" \
  || fail "check classification section is missing"
for outcome in 'Pre-existing failure' Flaky Unavailable 'Unrelated failure'; do
  grep -q "\*\*$outcome:\*\*" "$rules_ref" \
    || fail "$outcome handling is missing"
done
grep -q 'accepted risk is still not a pass' "$rules_ref" \
  || fail "accepted-risk integrity rule is missing"
grep -q 'not grant permission' "$rules_ref" \
  || fail "subagent ownership authority guard is missing"

grep -q 'Mode: compact' "$compact_template" \
  || fail "compact template mode is missing"
grep -q 'Status: <proposed | active | completed | abandoned>' "$compact_template" \
  || fail "compact template status lifecycle is incomplete"
grep -q 'Mode: <full | long-running>' "$full_template" \
  || fail "full template mode is missing"
grep -q '^## Contents$' "$full_template" \
  || fail "full template table of contents is missing"
grep -q 'Status: <proposed | active | completed | abandoned>' "$full_template" \
  || fail "full template status lifecycle is incomplete"
grep -q '^## Completion and Abandonment$' "$long_addendum" \
  || fail "plan lifecycle template guidance is missing"
for template in "$compact_template" "$full_template" "$long_addendum"; do
  if grep -q '^### Immediate fix loop$' "$template"; then
    fail "template repeats generic fix-loop boilerplate: $template"
  fi
done

printf 'development-plan check passed\n'
