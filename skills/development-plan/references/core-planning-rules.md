# Development Plan Core Planning Rules

## Task Intake

Before writing the plan, normalize the request into four inputs:

- Goal: the concrete change, bug, migration, integration, or investigation the
  user wants.
- Context: relevant files, folders, docs, examples, errors, issues, logs, or
  repository areas that shape the work.
- Constraints: architecture, product, security, testing, localization, style,
  dependency, platform, or workflow requirements the plan must respect.
- Done when: observable completion criteria, including tests/checks that should
  pass, behavior that should change, or bugs that should no longer reproduce.

If the user did not provide one of these inputs, infer it from repository
context when safe. Ask a follow-up question only when the missing input blocks
responsible planning. Carry `Done when` through the validation plan and Final
Definition of Done.

## Planning Rules

- Use concrete, verb-first checklist items.
- Prefer 5-9 top-level steps unless the task is very small or very large.
- Avoid excessive micro-steps, but make every step implementable.
- Mention likely files, modules, and commands when they can be inferred.
- Include at least one validation/testing step.
- Include edge cases, failure modes, or regressions when applicable.
- Make quality gates step-specific.
- Make fix loops mandatory, not optional.
- Make the plan useful for both a human developer and an agent executing it
  later.
- Keep open questions to a maximum of 3 and include them only when meaningful.
- Include subagent strategy only when independent read-heavy, verification, or
  non-overlapping implementation tracks exist.

## Long-Running Plan Mode

Use long-running plan mode when the work is likely to take multiple hours, span
more than one session, touch multiple product areas, require a major refactor or
migration, depend on substantial research, or need a resumable implementation
record.

Long-running plans must:

- be self-contained enough for a newcomer to continue from the plan and current
  working tree;
- anchor acceptance in commands, screens, API calls, logs, test names, or output
  snippets;
- require progress, discoveries, decisions, and outcomes to be updated whenever
  work stops, changes direction, or reaches a milestone;
- include idempotence and recovery guidance for risky or repeatable steps;
- use labeled prototyping milestones when feasibility is uncertain;
- prefer narrative milestone summaries plus concise progress checklists.

## Subagent Planning Rules

Use subagents only when they reduce context load or wall-clock time without
creating coordination risk.

Recommend subagents for:

- read-only codebase exploration across independent areas;
- GitHub issue or PR triage where comments, checks, logs, and code paths can be
  analyzed separately;
- parallel verification;
- disjoint implementation slices with explicitly non-overlapping write scopes.

Do not recommend subagents for small tasks, sequential migrations, overlapping
file edits, or UI polish loops that depend on one continuous rendered context.

Parent agent owns final architecture/product decisions, integration of findings,
file edits unless a bounded write scope is approved, commits, pushes, PR
comments, and final user summary.

## Required Plan Content

Every generated plan must include:

- task intake summary with Goal, Context, Constraints, and Done when;
- saved plan path when using the saved-plan workflow;
- short intent summary;
- scope with in-scope and out-of-scope items;
- assumptions;
- strict execution protocol;
- hierarchical checklist with top-level steps and sub-steps;
- for every top-level step: objective, expected result, implementation
  checklist, sub-steps, verification checklist, quality gate, immediate fix
  loop, and completion evidence to record;
- validation plan;
- subagent strategy with one of `none`, `read-only exploration`,
  `parallel verification`, or `disjoint implementation slices`;
- risks and edge cases;
- Final Definition of Done;
- open questions only when meaningful.

Long-running plans must also include Purpose / Big Picture, Progress, Surprises
& Discoveries, Decision Log, Outcomes & Retrospective, Context and Orientation,
Idempotence and Recovery, and Interfaces and Dependencies.

## Execution Protocol Requirements

The plan must explicitly require this loop for each implementation step:

1. Define the expected result before implementation.
2. Implement only the current step.
3. After implementation, record what was actually done.
4. Verify the result with concrete checks.
5. Run a quality gate for the step.
6. If the quality gate fails, immediately fix the issue.
7. Re-run verification after the fix.
8. Do not proceed until the current step passes.
9. Mark `[x]` only after implementation and verification both pass.

## Template Adaptation Rules

- Repeat the full top-level step structure for each planned step.
- Number sub-steps under each top-level step, such as `2.1`, `2.2`, and `2.3`.
- Omit the `Open questions` section only when there are no meaningful open
  questions.
- Keep placeholders out of the final plan.
- If no command is identifiable, state the likely check to discover or run.
- When the repository shows that part of the work is complete, include evidence
  in assumptions or completion guidance, but do not mark future implementation
  checkboxes as completed.
- Use `Recommended mode: none` for small or tightly coupled tasks.
- Keep `Done when` aligned with validation and Final Definition of Done.
- For saved plans, update checkboxes and completion evidence as work proceeds.
- Use long-running plan mode only when the task warrants a durable execution
  record.
- Do not add a separate `PLANS.md` convention unless the repository explicitly
  adopts it.

## Quality Gate Examples

- Data migration: schema change is reversible or explicitly justified, existing
  rows are handled, and migration tests or dry-run checks pass.
- API: request/response contract is covered by tests, error responses match
  project conventions, and existing clients are not broken.
- UI: target flows render at relevant breakpoints, interactive states work,
  accessibility basics are preserved, and browser/manual checks pass.
- Refactor: public behavior is unchanged, existing tests still pass, and
  removed paths have no remaining references.
- Debugging: suspected cause is proven or disproven with evidence, the fix
  targets the confirmed cause, and a regression test fails before the fix when
  practical.
