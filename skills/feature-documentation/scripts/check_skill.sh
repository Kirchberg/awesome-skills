#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "feature-documentation check failed: $*" >&2
  exit 1
}

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$skill_dir/SKILL.md"
metadata="$skill_dir/agents/openai.yaml"
docs_check="$skill_dir/scripts/check_docs.sh"

refs=(
  evidence-schema.md
  domain-routing-rules.md
  doc-model.md
  feature-doc-template.md
  agent-context-update.md
  completion-checklist.md
)

test -f "$skill_file" || fail "SKILL.md is missing"
test -f "$metadata" || fail "agents/openai.yaml is missing"
test -f "$docs_check" || fail "scripts/check_docs.sh is missing"
test -x "$docs_check" || fail "scripts/check_docs.sh is not executable"

for r in "${refs[@]}"; do
  test -f "$skill_dir/references/$r" || fail "reference $r is missing"
  grep -q "references/$r" "$skill_file" || fail "routing for $r is missing"
done

lines="$(wc -l < "$skill_file" | tr -d ' ')"
if [[ "$lines" -gt 200 ]]; then
  fail "$skill_file has $lines lines; split details into references/"
fi

grep -q '^name: feature-documentation$' "$skill_file" || fail "skill name changed"
grep -q 'docs/ai/' "$skill_file" || fail "docs/ai default output is missing"
grep -q 'docs/ai/' "$skill_dir/references/doc-model.md" || fail "doc-model docs/ai tree is missing"
grep -q 'Segregation Rule' "$skill_dir/references/doc-model.md" || fail "segregation rule is missing"
grep -q 'scripts/check_docs.sh' "$skill_file" || fail "check_docs routing is missing"
grep -q 'docs-style-enforcer' "$skill_file" || fail "style enforcer handoff is missing"
grep -q 'self-contained' "$skill_file" || fail "self-contained statement is missing"
grep -q 'allow_implicit_invocation: true' "$metadata" || fail "implicit invocation policy is missing"

echo "feature-documentation check passed"
