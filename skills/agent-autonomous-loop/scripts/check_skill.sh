#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "agent-autonomous-loop check failed: $*" >&2
  exit 1
}

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$skill_dir/SKILL.md"
control_ref="$skill_dir/references/control-protocol.md"
worker_ref="$skill_dir/references/worker-rules.md"
metadata="$skill_dir/agents/openai.yaml"

test -f "$skill_file" || fail "SKILL.md is missing"
test -f "$control_ref" || fail "control protocol reference is missing"
test -f "$worker_ref" || fail "worker rules reference is missing"
test -f "$metadata" || fail "agents/openai.yaml is missing"

lines="$(wc -l < "$skill_file" | tr -d ' ')"
if [[ "$lines" -gt 200 ]]; then
  fail "$skill_file has $lines lines; split details into references/"
fi

grep -q '^name: agent-autonomous-loop$' "$skill_file" \
  || fail "skill name changed"
grep -q 'Use only when the user explicitly invokes \$agent-autonomous-loop' "$skill_file" \
  || fail "explicit invocation trigger is missing"
grep -q 'Do not use implicitly' "$skill_file" \
  || fail "implicit-use prohibition is missing"
grep -q 'references/control-protocol.md' "$skill_file" \
  || fail "control protocol routing is missing"
grep -q 'references/worker-rules.md' "$skill_file" \
  || fail "worker rules routing is missing"
grep -q 'allow_implicit_invocation: false' "$metadata" \
  || fail "implicit invocation must be disabled in metadata"
grep -q 'default `4`' "$control_ref" \
  || fail "default round count is missing"
grep -q 'maximum `6`' "$control_ref" \
  || fail "maximum round count is missing"
grep -q '.agent-autonomous-loop/projects' "$control_ref" \
  || fail "handoff path is missing"
grep -q 'review-only' "$control_ref" \
  || fail "review-only scheduling is missing"
grep -q 'last_review_round >= latest_change_round' "$control_ref" \
  || fail "fresh review gate is missing"
grep -q 'Do not create commits unless' "$worker_ref" \
  || fail "commit guardrail is missing"
grep -q 'Preserve pre-existing user changes' "$worker_ref" \
  || fail "dirty worktree guardrail is missing"
grep -q 'review_passed: true' "$worker_ref" \
  || fail "review pass state update is missing"
grep -q 'Implementation workers must not mark `complete: true`' "$worker_ref" \
  || fail "implementation completion guardrail is missing"
grep -q 'follow the repository' "$worker_ref" \
  || fail "repository-generic planning guidance is missing"

echo "agent-autonomous-loop check passed"
