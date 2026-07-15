#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$root_dir/SKILL.md"
state_ref="$root_dir/references/pr-state-and-checks.md"
fix_ref="$root_dir/references/fix-validate-review.md"
metadata="$root_dir/agents/openai.yaml"

fail() {
  printf 'github-pr-codex-review-monitor check failed: %s\n' "$1" >&2
  exit 1
}

[[ -f "$skill_file" ]] || fail "SKILL.md is missing"
[[ -f "$state_ref" ]] || fail "state/checks reference is missing"
[[ -f "$fix_ref" ]] || fail "fix/validate reference is missing"
[[ -f "$metadata" ]] || fail "agents/openai.yaml is missing"

lines="$(wc -l < "$skill_file" | tr -d ' ')"
if [[ "$lines" -gt 200 ]]; then
  fail "$skill_file has $lines lines; split details into references/"
fi

grep -q '^---$' "$skill_file" || fail "frontmatter delimiter is missing"
grep -q '^name: github-pr-codex-review-monitor$' "$skill_file" || fail "skill name is missing or changed"
grep -q '^description: Use when ' "$skill_file" || fail "description must start with Use when"
grep -q 'references/pr-state-and-checks.md' "$skill_file" || fail "PR state reference routing is missing"
grep -q 'references/fix-validate-review.md' "$skill_file" || fail "fix/validate reference routing is missing"
grep -q 'chatgpt-codex-connector' "$state_ref" || fail "connector identity detection is missing"
grep -q 'git rev-parse --git-path codex-pr-review-monitor-state.json' "$state_ref" || fail "worktree-safe state path is missing"
grep -q 'sleep 600' "$skill_file" || fail "10-minute monitor cadence is missing"
grep -q 'Codex App Thread Automations' "$state_ref" || fail "thread automation section is missing"
grep -q 'heartbeat automation' "$state_ref" || fail "heartbeat automation guidance is missing"
grep -q 'PR Check Detection' "$state_ref" || fail "PR check detection section is missing"
grep -q 'gh pr checks "$PR_NUMBER"' "$state_ref" || fail "PR checks command is missing"
grep -q 'required/current PR checks pass' "$skill_file" || fail "passing checks stop condition is missing"
grep -q 'failing checks' "$skill_file" || fail "failing check handling is missing"
grep -q 'gh run rerun <run_id>' "$fix_ref" || fail "flaky check rerun guidance is missing"
grep -q 'Subagent Strategy' "$fix_ref" || fail "subagent strategy section is missing"
grep -q 'Keep subagents read-only by default' "$skill_file" || fail "subagent safety rule is missing"
grep -q 'pr_explorer' "$fix_ref" || fail "PR explorer subagent role is missing"
grep -q 'ci_investigator' "$fix_ref" || fail "CI investigator subagent role is missing"
grep -q 'no subagent will' "$fix_ref" || fail "subagent GitHub mutation guard is missing"
grep -q 'gh pr comment "$PR_NUMBER" --body "@codex review"' "$fix_ref" || fail "review request command is missing"
grep -q 'newer than the last `@codex review` request timestamp' "$state_ref" || fail "current-cycle terminal success guard is missing"
grep -q 'git reset --hard' "$skill_file" || fail "forbidden destructive command guardrail is missing"
grep -q 'Do not create a new Codex session while waiting' "$skill_file" || fail "session persistence rule is missing"
grep -q 'Codex review monitoring complete' "$skill_file" || fail "completion summary is missing"
grep -q '60 minutes' "$skill_file" || fail "bounded Connector silence timeout is missing"
grep -q '^## Bounded Connector Silence$' "$state_ref" || fail "Connector silence policy is missing"
grep -q 'Do not create an evidence/no-op commit' "$state_ref" || fail "silence retry guard is missing"
grep -q 'Resume only' "$skill_file" || fail "explicit resume guard is missing"
grep -q 'explicit service error' "$fix_ref" || fail "Connector service error stop is missing"

printf 'github-pr-codex-review-monitor check passed\n'
