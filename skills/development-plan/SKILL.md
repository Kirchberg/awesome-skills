---
name: development-plan
description: Use when an agent is asked to plan or execute a medium/large coding task, feature, refactor, migration, debugging task, integration, or multi-step implementation; also use when the user asks for an implementation plan before code.
---

# Development Plan Skill

## Purpose

Turn technical feature, refactor, debugging, migration, integration, or
implementation requests into structured, executable development plans. For
medium/large execution work, create a saved plan before source edits and keep it
current while implementing.

## Operating Mode

Default to saved-plan workflow for medium and large implementation work, and to
read-only planning mode for plan-only requests.

- Use this skill by default for medium or large coding tasks even when the user
  asks to implement, fix, debug, refactor, connect, migrate, or otherwise act
  now. Do not wait for the word "plan" when the task is non-trivial.
- Treat a task as medium or large when it is likely to touch multiple files or
  modules, cross system boundaries, change architecture or data flow, require
  research, involve ambiguous debugging, alter user-visible behavior, need
  careful verification, or take more than one focused step.
- Skip the saved-plan workflow only for clearly small, low-risk work such as a
  tiny single-file edit, a simple docs typo, an isolated config tweak, or when
  the user explicitly asks not to create a plan.
- For plan-only requests, stay read-only and do not produce implementation code
  unless the user explicitly asks for code.
- For medium/large execution requests, create or update the saved plan before
  changing source files, then execute one step at a time.
- Do not mark any implementation step complete unless there is evidence that it
  has been implemented and verified.
- Ask follow-up questions only when the missing answer blocks responsible
  planning; ask at most three.
- Write the plan in the same language as the user's request.

## Reference Routing

Read these one-level references as needed:

- `references/core-planning-rules.md`: read before drafting any plan. It defines
  task intake, planning rules, long-running mode, subagent guidance, required
  content, execution protocol, quality gates, and pitfalls.
- `references/plan-template.md`: read whenever creating or updating a saved
  plan file, or when the user asks for a full implementation plan.

## Repository Context Inspection

When repository context is available, inspect relevant files before writing the
plan. Stay read-only while planning unless this is a medium/large execution task
and the saved plan has already been created.

Prefer inspecting:

- `README.md`;
- `AGENTS.md`, `AGENT.md`, `CLAUDE.md`, or similar agent instructions;
- package, build, dependency, and framework config files;
- `docs/`;
- architecture docs, ADRs, and implementation notes;
- test setup and test helpers;
- CI configuration;
- relevant source modules, routes, services, models, components, jobs,
  migrations, scripts, or entrypoints.

Use context to infer likely files, commands, constraints, test layers, risks,
and implementation order. If a command or file cannot be identified
confidently, name the category instead of inventing details.

## Saved Plan Workflow

For medium and large execution tasks:

- Save the plan in the repository before code changes. Use the repository's
  existing planning convention when one exists. Otherwise create a plain
  Markdown file under `docs/plans/active/` using a dated descriptive name such
  as `YYYY-MM-DD-short-task-slug.md`. For split multi-phase work, use
  `docs/plans/active/YYYY-MM-DD-short-task-slug/PLAN.md` plus phase files.
- Do not wrap a saved plan file in an outer Markdown code fence.
- Keep the saved plan current while implementing. Before stopping, handing off,
  or giving a final answer, update the plan to reflect the real current state.
- Mark checklist items with `[x]` only after the item is both implemented and
  verified. If implementation is done but verification is pending, leave the
  item unchecked and add a short note such as `implemented; verification
  pending: <check>`.
- If a checklist item is partly complete, split it into completed and remaining
  items instead of marking the original item done.
- Record verification evidence in the step's completion evidence, the progress
  section, or both. Evidence should name the command, inspection, test, or
  manual check that proves the item.
- If a quality gate fails, keep the relevant checkbox unchecked, run the
  immediate fix loop, re-run verification, and update the plan with the result.
- At final completion, every required in-scope checklist item should be checked
  or explicitly moved to a documented follow-up/out-of-scope item with
  rationale.

## Execution Loop

For each implementation step in a saved plan:

1. Confirm the expected result.
2. Implement only the current step.
3. Record what changed.
4. Run the verification checklist.
5. Run the quality gate.
6. If anything fails, fix it immediately.
7. Re-run failed checks.
8. Mark completed checklist items `[x]` only after implementation and
   verification both pass.
9. Proceed only after the step passes.

For long-running plans, keep `Progress`, `Surprises & Discoveries`,
`Decision Log`, and `Outcomes & Retrospective` current whenever stopping,
changing direction, or completing a milestone.

## Avoid

- Do not produce vague planning items like "do backend" or "handle auth".
- Do not skip verification or treat quality checks as optional.
- Do not move to the next step after a failed check.
- Do not invent files, commands, services, or architecture details when
  repository context does not support them.
- Do not recommend parallel write-heavy subagents without non-overlapping file
  ownership.
