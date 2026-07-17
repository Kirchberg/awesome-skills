---
name: development-plan
description: Use when an agent is asked to plan or execute a medium or large coding task, feature, refactor, migration, debugging task, integration, or multi-step implementation. Selects compact, full, or long-running planning depth, saves execution plans before source edits, and requires verification evidence.
---

# Development Plan Skill

## Purpose

Turn non-trivial engineering requests into executable plans with the smallest
responsible amount of structure. Preserve observable acceptance, verification
evidence, recovery guidance, and resumability without forcing large-plan
ceremony onto ordinary medium work.

## Operating Mode

- Use this skill for medium or large coding tasks even when the user asks to
  implement, fix, debug, refactor, connect, or migrate immediately.
- For plan-only requests, do not edit source or implementation files and use
  `Status: proposed`. Return the plan in chat unless the user explicitly
  requests a saved artifact; in that case, write only the plan. Do not label an
  inline plan `active` merely because its work is not implemented.
- For medium or large execution requests, create or update a saved plan before
  changing source files, then keep it current during implementation.
- Skip the saved-plan workflow for clearly small, low-risk work such as a typo,
  an isolated config value, or a focused single-file edit with an obvious
  check. Also skip it when the user explicitly asks not to create a plan.
- Ask at most three follow-up questions, and only when missing information
  blocks responsible planning.
- Write the plan in the same language as the user's request.

## Select Planning Depth

Choose the least detailed mode that preserves safe execution and honest
verification. Escalate the mode if new risk or ambiguity appears.

- **Compact** — default for bounded medium work that is likely to finish in one
  session, has familiar architecture, and does not need independent step-level
  recovery. Use concise actions with expected results and checks plus one shared
  execution protocol and final quality gate. Prefer 3-5 actions and 1-3
  implementation bullets per action.
- **Full** — use when work crosses system boundaries, changes architecture or
  data flow, involves ambiguous debugging, migrations, rollout or compatibility
  risk, substantial research, or benefits from step-local quality gates and
  completion evidence.
- **Long-running** — extend full mode when work may span multiple sessions or
  hours, multiple product areas, a major refactor or migration, or needs a
  durable handoff record, decision log, and recovery instructions.

Read `references/core-planning-rules.md` for exact selection tests and required
content for each mode.

## Reference Routing

- Read `references/core-planning-rules.md` before drafting any plan. It defines
  task intake, mode requirements, check classification, subagent guidance, and
  quality gates.
- Read `references/compact-plan-template.md` only for compact mode.
- Read `references/full-plan-template.md` for full and long-running modes.
- Also read `references/long-running-addendum.md` only for long-running mode.

## Inspect Repository Context

When repository context is available, inspect relevant files before writing the
plan. Prefer:

- `README.md`, `AGENTS.md`, `AGENT.md`, `CLAUDE.md`, and similar instructions;
- package, build, dependency, framework, test, and CI configuration;
- `docs/`, architecture docs, ADRs, and implementation notes;
- relevant source modules, routes, services, models, components, jobs,
  migrations, scripts, tests, and entrypoints.

Use that evidence to infer likely files, commands, constraints, risks, and
implementation order. Name a category or discovery action instead of inventing
an unsupported file, command, service, or architecture detail.

## Saved Plan Workflow

- Follow the repository's planning convention when one exists. Otherwise save
  active plans under `docs/plans/active/` as
  `YYYY-MM-DD-short-task-slug.md`. For a split plan, use
  `docs/plans/active/YYYY-MM-DD-short-task-slug/PLAN.md` plus phase files.
- Do not wrap a saved plan in an outer Markdown code fence.
- Keep the plan current before stopping, handing off, changing direction, or
  giving a final answer.
- Mark `[x]` only after implementation and verification both pass. Split partly
  completed items; do not round them up to complete.
- Record the command, inspection, test, or manual check that proves completion.
- On successful completion, follow the repository convention or move the plan
  from `active/` to `completed/` and record the outcome. If work is stopped
  without completion, move it to `abandoned/` and record why, what remains, and
  how to resume. When moves are not appropriate, record `Status: completed` or
  `Status: abandoned` in place.

## Verification Integrity

- A new or relevant failure blocks the affected step and final completion until
  it is fixed and re-verified.
- Never mark a pre-existing, flaky, unavailable, or unrelated check as passed.
  Classify it with evidence and follow the rules in
  `references/core-planning-rules.md`.
- If a required check remains unresolved, report the result as partial or
  blocked unless the user explicitly accepts the risk. Accepted risk remains an
  unresolved check; it does not become a pass.

## Authority Boundaries

A plan records intended work; it does not grant new authority. Commits, pushes,
deployments, destructive operations, external messages, issue or PR mutations,
and other consequential actions remain limited by the user's request and host
policy. Describing work as parent-owned or assigning it to an agent does not
authorize that work.

## Execution Loop

For each current action or full-mode step:

1. Confirm the expected result.
2. Implement only the current scope.
3. Record what changed.
4. Run the planned checks.
5. Fix relevant failures immediately, or re-plan when evidence disproves the
   approach, then re-run affected checks.
6. Classify any unresolved check without claiming it passed.
7. Record completion evidence and update the plan.
8. Continue only when the current quality gate permits it.

Compact mode may use one shared quality gate. Full and long-running modes use
step-local gates. Long-running plans also keep `Progress`,
`Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective`
current.

## Avoid

- Do not produce vague actions such as "do backend" or "handle auth".
- Do not duplicate the shared execution protocol under every compact action.
- Do not expand a compact plan merely to fill a template.
- Do not label a plan-only response `active`; use `proposed`.
- Do not treat skipped, unavailable, or accepted-risk checks as successful.
- Do not proceed past a relevant regression because another check passed.
- Do not recommend overlapping write-heavy subagents.
