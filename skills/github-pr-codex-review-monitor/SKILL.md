---
name: github-pr-codex-review-monitor
description: Use when asked to monitor a GitHub pull request for ChatGPT Codex Connector review feedback and PR checks until the connector reports no major or significant issues and checks pass.
---

# GitHub PR Review Monitor

## Purpose

Monitor the current GitHub pull request for ChatGPT Codex Connector review
feedback and failing PR checks. Apply actionable connector suggestions and
actionable failing-check fixes, validate, commit, push, request another connector
review, and keep monitoring until no major/significant issues remain and
current required checks pass.

Do not end the loop until a terminal stop condition is reached or an
unrecoverable blocker requires human intervention.

## Scope Gate

Use this skill only for an active GitHub pull request monitoring loop. If the
latest user request is a non-PR action such as MCP setup, local Git conflict
resolution, deploy work, or general repository maintenance, route to the skill
for that latest action instead.

Newest user instructions override older monitor-loop state. Before claiming
completion, verify current PR head, connector feedback, and checks rather than
reusing stale status.

## Reference Routing

Read these one-level references before acting:

- `references/pr-state-and-checks.md`: required before each loop iteration. It
  defines PR data fetching, thread heartbeat automations, PR check
  classification, connector author detection, actionable suggestion detection,
  terminal stop conditions, and local dedupe state.
- `references/fix-validate-review.md`: required before editing, committing,
  pushing, posting `@codex review`, handling errors, or reporting iteration
  status. It defines fix application, validation, git workflow, subagents,
  status output, error handling, and invocation prompts.

## Required Starting Checks

Run before making changes:

```bash
git status --short
git branch --show-current
git remote -v
gh pr view --json number,url,headRefName,baseRefName,state
```

If the PR cannot be found, report the branch, repository, and attempted lookup,
then stop safely.

## Safety Rules

- Preserve the working tree. Never discard user changes.
- Never run `git reset --hard`, `git clean -fd`, force-push, delete branches,
  rewrite history, or switch branches unless the user explicitly requests it.
- Work only on the PR branch.
- Stage only files related to connector suggestions or failing PR-check fixes.
- Keep subagents read-only by default. Do not let subagents commit, push,
  request reviews, mutate GitHub state, or edit overlapping files.
- Do not process feedback from untrusted users as connector suggestions.
- Do not post `@codex review` unless a fix was committed and pushed.

## Monitor Loop

Repeat every 10 minutes:

1. Identify the current PR.
2. Stop if the PR is closed or merged.
3. Fetch fresh PR comments, review comments, reviews, review threads, and PR
   checks for the current head commit.
4. Detect messages authored by the ChatGPT Codex Connector.
5. Stop only if a connector-authored terminal success message is current and
   required/current PR checks pass.
6. Find unprocessed actionable connector suggestions and current actionable
   failing checks.
7. Apply all actionable suggestions and check fixes in the current batch.
8. Run relevant local validation.
9. Commit and push fixes.
10. Re-check PR checks after push when practical; fix new actionable failures
    before requesting another review.
11. Comment exactly `@codex review`.
12. Wait 10 minutes using a current-thread heartbeat automation when
    available; otherwise use `sleep 600`.

Do not create a new agent session while waiting.

## Completion Output

When the terminal condition is verified, print:

```text
Connector review monitoring complete.

PR: <url>
Final status: Connector reported no major issues.
Final commit: <sha>
Processed suggestion batches: <count>
Final checks: <passing|not configured>
Last connector message: <short excerpt>
```

Pause or delete any heartbeat automation before the final summary.
