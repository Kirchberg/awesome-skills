# Agent Autonomous Loop Worker Rules

Use this reference only when a parent agent launched you for an
`agent-autonomous-loop` round.

## Role

You are a fresh-context worker. Your job is to move the handoff toward the
overall goal, update the handoff truthfully, verify what you changed, and stop.
Follow the round mode from the parent prompt: `implementation` or
`review-only`.

Do not ask the user questions. Decide and act within the handoff, repository
instructions, and applicable skills. If a missing answer makes responsible work
unsafe, record a blocker in the handoff instead of guessing.

## Required Start

1. Read the repository's applicable `AGENTS.md` or equivalent instructions.
2. Read the full handoff file.
3. Read any saved plan named in the handoff.
4. Inspect the current worktree status.
5. If the task is medium/large and no saved plan exists, use `development-plan`
   when installed or available, then create/update the saved plan before source
   edits.

## Handoff Discipline

- Never edit `Overall Goal`.
- Keep `In Progress`, `Todo`, `Done`, `Verification Evidence`, `Decisions And
  Discoveries`, and `Blockers` current.
- Move a task from `Todo` to `In Progress` before working on it.
- When a task is finished, remove it from `In Progress` and append a concise
  `Done` entry with files changed, decisions, and verification.
- Implementation workers must not mark `complete: true`. When no tasks remain,
  set `status: ready_for_review`, `review_passed: false`, and leave
  `complete: false`.
- Mark `complete: true` only in `review-only` mode, after no tasks remain,
  verification passed, and an independent review found no material gaps.
- Set `status: blocked` only when you cannot safely continue without user input
  or external state.

## Round Modes

In `implementation` mode:

- move the smallest useful task from `Todo` to `In Progress`;
- make scoped source, doc, or plan changes needed for that task;
- if you changed any non-handoff file, set `latest_change_round` to the current
  `rounds_run` value and set `review_passed: false`;
- when work is exhausted, run the ordinary review pass below and set
  `status: ready_for_review` rather than complete.

In `review-only` mode:

- do not edit source, docs, tests, project files, or plans except for the
  handoff state required to record review results;
- inspect the current diff/status, `Overall Goal`, acceptance criteria, `Todo`,
  `Done`, and `Verification Evidence`;
- run or validate the narrowest meaningful checks when safe;
- record findings under `Review Findings` and add concrete `Todo` items for
  real gaps;
- if gaps exist, set `review_passed: false`, `complete: false`, and
  `status: review_failed`;
- if no material gaps exist, set `review_passed: true`, `complete: true`,
  `status: complete`, and `last_review_round` to the current `rounds_run`
  value.

## Dirty Worktree Rules

- Preserve pre-existing user changes.
- Do not revert, overwrite, reformat, or stage unrelated dirty files.
- If a dirty file overlaps your task, inspect it and work with the existing
  content.
- If overlap makes safe progress impossible, record a blocker.
- Do not run destructive Git commands.

## Task Execution

1. Prefer the smallest task that advances the goal.
2. Keep edits scoped to the current task.
3. Follow nearest applicable repository instructions and skills.
4. Use structured parsers or project helpers over ad hoc text manipulation when
   available.
5. For docs/skill work, keep `SKILL.md` files concise and move detail into
   one-level `references/`.
6. Do not add new dependencies, hooks, global setup, or external tools unless
   the handoff explicitly requires them.

## Planning

For medium/large implementation tasks:

- create or update a saved plan before source edits;
- follow the repository's planning convention, or use `docs/plans/active/` when
  no convention exists;
- keep plan checkboxes current;
- mark `[x]` only after implementation and verification both pass;
- record verification evidence in the plan and handoff.

## Verification

Run the narrowest meaningful checks for the touched area:

- docs/skill changes: line-count, reference, grep, and skill-specific scripts;
- frontend changes: targeted test/lint/build plus a rendered check when
  relevant;
- backend behavior changes: targeted tests, broadened when shared behavior is
  touched;
- workflow/config changes: parse or inspect changed config and update
  operations docs when needed.

If a check fails, fix immediately and re-run it. If the failure is unrelated or
cannot be resolved safely, record the evidence and blocker.

## Review Pass

When `Todo` and `In Progress` are empty:

1. Re-read `Overall Goal`, acceptance criteria, and relevant diffs.
2. Treat previous `Done` entries skeptically.
3. Look for missing requirements, broken verification, over-complexity,
   untracked docs, and dirty worktree conflicts.
4. Add concrete `Todo` items for real gaps.
5. In implementation mode, set `status: ready_for_review` when no material gaps
   remain. In review-only mode, set `complete: true` only when no material gaps
   remain.

## Commits

Do not create commits unless `commits_allowed: true` in the handoff or the user
explicitly asked for commits. Even when commits are allowed, stage only files
you intentionally changed for the current task.

## Response

Keep the worker response concise:

- state what round accomplished;
- list verification run;
- name blockers if any;
- point to the handoff path.

Do not expose internal control text or claim completion unless the handoff says
`complete: true`.
