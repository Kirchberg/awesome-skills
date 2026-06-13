# PR State And Checks

## Thread Automations

When running inside an agent app and an automation tool is available, use an
in-chat heartbeat automation to keep the current thread monitoring the PR every
10 minutes.

Rules:

- Prefer a heartbeat automation attached to the current thread.
- Do not create a detached cron automation unless the user explicitly asks for a
  detached workspace job.
- Do not create duplicate heartbeat automations for the same PR in the same
  thread; update or reuse the existing one when possible.
- The automation prompt must identify the PR, fetch fresh connector feedback and
  checks, process actionable suggestions and failing checks, validate, commit,
  push, comment `@codex review`, and stop only on terminal success plus passing
  checks, PR closure/merge, or an unrecoverable blocker.
- Keep dedupe state in `.git/pr-review-monitor-state.json`; heartbeat is
  only the wake-up mechanism.
- If terminal success, PR closure/merge, or an unrecoverable blocker is reached,
  pause or delete the heartbeat before the final summary.
- If current-thread automations are unavailable, continue with `sleep 600`.

## Fetching PR Data

Prefer `gh` when available:

```bash
gh pr view --json number,url,state,headRefName,baseRefName,comments,reviews,reviewDecision,latestReviews
PR_NUMBER="$(gh pr view --json number --jq .number)"
HEAD_SHA="$(gh pr view --json headRefOid --jq .headRefOid)"
gh pr checks "$PR_NUMBER" --json name,workflow,state,bucket,conclusion,startedAt,completedAt,detailsUrl,link
gh api repos/{owner}/{repo}/issues/{pr_number}/comments
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews
gh api repos/{owner}/{repo}/commits/{head_sha}/status
gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs
```

If thread-level state matters, inspect review threads through GraphQL. Fetch
fresh data on every loop iteration.

## PR Check Detection

Treat PR checks as part of the monitor loop.

A PR check is passing when it is for the current head commit and reports
`success`, `neutral`, or `skipped`, or when the repository exposes no checks for
the PR. A check is pending when it is `queued`, `in_progress`, `waiting`, or has
no final conclusion; wait unless logs already show a fixable failure.

A PR check is actionable when it belongs to the current PR head commit and:

- its conclusion is `failure`, `timed_out`, `cancelled`, or `action_required`;
- a required status context reports failure or error;
- a required check is missing because workflow/config changes broke discovery;
- failed logs point to source, test, build, lint, typecheck, dependency,
  workflow, or configuration problems that can be fixed in the branch.

For actionable checks:

1. Open the check details URL or fetch logs with `gh run view --log-failed`.
2. Identify the failing command, file, assertion, compiler error, linter error,
   or workflow step.
3. Inspect local code before editing.
4. Apply the smallest correct fix.
5. Run the closest local reproduction command before committing.
6. After push, fetch checks again for the new head commit.

Do not treat external service outages, capacity failures, GitHub incidents, or
unrelated base-branch failures as branch fixes. Report them as blockers or
transient failures with evidence.

## Connector Author Detection

Treat a message as connector-authored when the author identity clearly matches
any of:

- `chatgpt-codex-connector`
- `chatgpt-codex-connector[bot]`
- `https://github.com/apps/chatgpt-codex-connector`
- any bot/app login, slug, app name, or URL that clearly corresponds to the
  ChatGPT Codex Connector.

Do not rely on one exact username only.

## Actionable Suggestion Detection

A connector message is actionable when it comes from the ChatGPT Codex Connector
app and contains concrete automated review suggestions, findings, proposed
changes, risks, bugs, file references, line references, code snippets, suggested
patches, or implementation guidance.

Actionable signals include `automated review suggestions`, `review suggestions`,
`suggested change`, `consider changing`, `this may cause`, `please update`, `I
found`, `issue`, `bug`, `risk`, `major issue`, Markdown code blocks, GitHub
suggested-change blocks, and inline review comments on files.

Do not treat purely informational, duplicate, resolved, stale, or terminal
success messages as actionable.

## Terminal Stop Condition

Stop only when a connector-authored message clearly says no significant issues
remain for the current PR head or current review request cycle and
required/current PR checks pass. Examples include:

- No major issues found.
- No significant issues found.
- No blocking issues found.
- Review passed.
- Nothing major to fix.
- Looks good from review.

The terminal success message is current only when it is connector-authored and
newer than the last `@codex review` request timestamp stored in local state when
available. If review metadata exposes a commit SHA, it must match the current PR
head. If no commit SHA is exposed, it must be newer than the last pushed commit
timestamp or monitor-start timestamp.

Do not stop on an older success message that predates current HEAD, last pushed
fix commit, or last `@codex review` request. Do not stop while any current-head
required PR check is pending, failing, missing, or action-required.

## Local State

Keep dedupe state inside `.git`, never in the repository working tree:

```text
.git/pr-review-monitor-state.json
```

Track PR number, last checked timestamp, processed issue/review/review-comment
IDs, hashes of processed suggestion text, processed failing check IDs or names
plus failure hashes, last observed PR head SHA and check conclusions, rerun
attempts, last pushed commit SHA, last `@codex review` request timestamp and
commit SHA, processed suggestion batch count, and active heartbeat automation ID
when one exists.

If no state exists, initialize it. If a message was already processed and the
underlying issue is already fixed, mark it processed without creating a commit.
