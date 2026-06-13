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
   - launch one fresh worker subagent;
   - prompt it with the handoff path and worker-rules path only;
   - wait for completion;
   - read the handoff;
   - stop if `complete: true`, `status: blocked`, or the round limit is reached.
9. After the loop, inspect current `git status --short` and summarize only the
   loop result, changed files, verification, and blockers.

## Worker Prompt

Use a concise prompt like:

```markdown
Read `<path-to-agent-autonomous-loop>/references/worker-rules.md`.
Then work according to `.agent-autonomous-loop/projects/<slug>/HANDOFF.md`.
```

Use the real installed skill path for `<path-to-agent-autonomous-loop>`. Do not
paste the control protocol into the worker prompt unless subagent tooling cannot
access repository files.

## Stop Conditions

Stop the loop when:

- the handoff frontmatter has `complete: true`;
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
