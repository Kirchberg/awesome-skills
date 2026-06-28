#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "docs-feature-collect check failed: $*" >&2
  exit 1
}

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$skill_dir/SKILL.md"
collection_ref="$skill_dir/references/evidence-collection.md"
schema_ref="$skill_dir/references/evidence-schema.md"
handoff_ref="$skill_dir/references/docs-feature-write-handoff.md"
metadata="$skill_dir/agents/openai.yaml"

test -f "$skill_file" || fail "SKILL.md is missing"
test -f "$collection_ref" || fail "evidence-collection reference is missing"
test -f "$schema_ref" || fail "evidence-schema reference is missing"
test -f "$handoff_ref" || fail "docs-feature-write handoff reference is missing"
test -f "$metadata" || fail "agents/openai.yaml is missing"

lines="$(wc -l < "$skill_file" | tr -d ' ')"
if [[ "$lines" -gt 200 ]]; then
  fail "$skill_file has $lines lines; split details into references/"
fi

grep -q '^name: docs-feature-collect$' "$skill_file" || fail "skill name changed"
grep -q 'REQUIRED SUB-SKILL' "$skill_file" || fail "required sub-skill declaration is missing"
grep -q 'docs-feature-write' "$skill_file" || fail "docs-feature-write handoff is missing"
grep -q 'read-only' "$skill_file" || fail "read-only operating mode is missing"
grep -q 'references/evidence-collection.md' "$skill_file" || fail "evidence-collection routing is missing"
grep -q 'references/evidence-schema.md' "$skill_file" || fail "evidence-schema routing is missing"
grep -q 'references/docs-feature-write-handoff.md' "$skill_file" || fail "handoff routing is missing"
grep -q 'self-contained' "$skill_file" || fail "self-contained statement is missing"
grep -q 'allow_implicit_invocation: true' "$metadata" || fail "implicit invocation policy is missing"

# Shared evidence schema must match the core skill's copy when both are present.
core_schema="$skill_dir/../docs-feature-write/references/evidence-schema.md"
if [[ -f "$core_schema" ]]; then
  diff -q "$schema_ref" "$core_schema" >/dev/null || fail "evidence-schema.md differs from docs-feature-write copy"
fi

echo "docs-feature-collect check passed"
