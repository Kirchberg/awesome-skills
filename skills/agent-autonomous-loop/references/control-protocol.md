# Agent Autonomous Loop Control Protocol

Use this reference after the `agent-autonomous-loop` skill is explicitly
invoked. The parent agent is the orchestrator. Worker subagents execute task
rounds.

## Task Fit

Proceed only when the request has a durable target:

- an implementation plan, issue, spec, or clear acceptance criteria;
- a bounded repo area or explicit set of files;
- verification commands or checks that can prove progress.

Stop before launching workers when the task needs interactive product choices,
visual review from the user, production mutation, secrets, destructive Git
operations, or a scope decision that cannot be inferred safely.

## Parameters

Accept parameters from the user message when present:

- `rounds=N`: number of worker rounds, default `4`, maximum `6`.
- `resume=<handoff-path>`: resume an existing handoff file.
- `commits=allowed`: workers may create commits after verified milestones.

If omitted, use defaults. Do not ask parameter questions unless the answer is
required for safety.

## Handoff Location

Create handoff files under:

```text
.agent-autonomous-loop/projects/YYYY-MM-DD-short-slug/HANDOFF.md
```

Create KB notes only under:

```text
.agent-autonomous-loop/kb/
```

These files are runtime state. They must stay ignored and uncommitted.

## Handoff Shape

Use this shape for new handoffs:

```markdown
---
status: initial
complete: false
rounds_run: 0
max_rounds: 4
git_start: <sha-or-empty>
commits_allowed: false
review_passed: false
latest_change_round: 0
last_review_round: 0
---

# Overall Goal

<Self-contained user request. Preserve the user's original wording where useful.>

## Important Context And Constraints

- <Relevant prior-turn context not already in repository instructions>

## Acceptance Criteria

- <Observable completion criterion>

## Dirty Worktree At Start

<Output summary from git status or "not checked: <reason>">

## In Progress

## Todo

- [ ] <Concrete task>

## Done

## Verification Evidence

## Review Findings

## Decisions And Discoveries

## Blockers
```

Never rewrite `Overall Goal` after creation. Append clarifications under
`Decisions And Discoveries`.

## Parent Workflow

1. Confirm the explicit trigger and task fit.
2. Read `references/worker-rules.md`.
3. Resolve `rounds`, `resume`, and `commits_allowed`.
4. Capture `git rev-parse HEAD` when available.
5. Capture `git status --short` and preserve it in the handoff.
6. Create or reopen the handoff.
7. Tell the user the handoff path and planned round count.
8. For each round:
   - choose `implementation` or `review-only` mode;
   - update `rounds_run` to the current round number before launch;
   - launch one fresh worker subagent;
   - prompt it with the handoff path, worker-rules path, and round mode only;
   - wait for completion;
   - read the handoff;
   - stop if the review gate passed, `status: blocked`, or the round limit is
     reached.
9. After the loop, inspect current `git status --short` and summarize only the
   loop result, changed files, verification, and blockers.

## Round Scheduling And Review Gate

- Use implementation rounds while `Todo` or `In Progress` contains work.
- Run a fresh `review-only` worker before declaring completion.
- A review-only worker may inspect diffs, run checks, and update the handoff,
  but must not make source changes.
- If review records concrete gaps and round budget remains, launch a repair
  implementation worker next.
- After any repair/source change, require another fresh review-only worker
  before completion.
- With default `rounds=4`, prefer implementation, implementation/reconciliation,
  review-only, then repair or final review depending on review findings.
- Completion requires `complete: true`, `review_passed: true`, and a
  `last_review_round` that is greater than or equal to `latest_change_round`.
- If budget ends after repair without a later passing review, report round limit
  reached rather than complete.

## Worker Prompt

Use a concise prompt like:

```markdown
Read `<path-to-agent-autonomous-loop>/references/worker-rules.md`.
Then work in `<implementation|review-only>` mode according to
`.agent-autonomous-loop/projects/<slug>/HANDOFF.md`.
```

Use the real installed skill path for `<path-to-agent-autonomous-loop>`. Do not
paste the control protocol into the worker prompt unless subagent tooling cannot
access repository files.

## Stop Conditions

Stop the loop when:

- the handoff frontmatter has `complete: true`, `review_passed: true`, and
  `last_review_round >= latest_change_round`;
- the handoff frontmatter has `status: blocked`;
- the configured round limit has been reached;
- worker execution fails repeatedly and cannot be resumed safely;
- the parent detects a safety problem such as unexpected destructive changes,
  secret exposure, or unowned dirty-file conflicts.

## Final Report

Report in the user's language:

- total rounds run;
- final state: complete, blocked, or round limit reached;
- handoff path;
- changed files from current Git status;
- verification commands/checks run and result;
- blockers, limitations, or follow-ups.

Do not claim tests passed unless the handoff or parent verification records the
exact passing check.
