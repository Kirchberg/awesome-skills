# Development Plan Core Planning Rules

## Contents

- [Task Intake](#task-intake)
- [Mode Selection Tests](#mode-selection-tests)
- [Universal Plan Content](#universal-plan-content)
- [Compact Mode Requirements](#compact-mode-requirements)
- [Full Mode Requirements](#full-mode-requirements)
- [Long-Running Addendum](#long-running-addendum)
- [Execution Protocol Requirements](#execution-protocol-requirements)
- [Check Outcome Classification](#check-outcome-classification)
- [Subagent Planning Rules](#subagent-planning-rules)
- [Template Adaptation Rules](#template-adaptation-rules)
- [Quality Gate Examples](#quality-gate-examples)
- [Avoid Planning Theater](#avoid-planning-theater)

## Task Intake

Normalize every request into four inputs before planning:

- **Goal:** the concrete change, bug, migration, integration, or investigation.
- **Context:** relevant files, docs, examples, errors, issues, logs, and systems.
- **Constraints:** architecture, product, security, testing, localization,
  dependency, platform, workflow, and authority boundaries.
- **Done when:** observable completion criteria and the checks that demonstrate
  them.

Infer missing inputs from repository evidence when safe. Ask a follow-up only
when the answer changes the responsible plan materially. Carry `Done when`
through validation and the Final Definition of Done.

## Mode Selection Tests

Use the least detailed mode that answers the strongest applicable test.

### Compact mode

Use compact mode when all of these are true:

- the change is bounded and likely to finish in one session;
- architecture, ownership, and implementation path are reasonably familiar;
- rollback is straightforward or the change is low-to-moderate risk;
- one shared execution protocol and final quality gate are sufficient;
- the plan remains executable with roughly 3-5 top-level actions; use 6-7 only
  when they remain tightly bounded and a full plan would add no safety.

Touching multiple files alone does not require full mode.

### Full mode

Use full mode when any of these materially affects the work:

- cross-service, cross-module, or public-contract coordination;
- architecture, persistent data, permissions, deployment, rollout, or backward
  compatibility changes;
- ambiguous debugging that needs evidence-gathering before a fix can be chosen;
- risky or partially reversible operations;
- substantial research, external dependencies, or multiple independent
  verification boundaries;
- a need to resume safely at a specific step even within one session.

Full mode normally uses 4-9 top-level steps. Use fewer or more when the work
itself demands it; do not manufacture steps to meet a count.

### Long-running mode

Extend full mode when any of these are likely:

- work spans multiple sessions or several hours;
- a newcomer may need to continue from the plan and current working tree;
- multiple product areas, phases, or rollout windows are involved;
- feasibility is uncertain enough to require a prototype milestone;
- idempotence, retry, rollback, or recovery needs durable explanation.

If risk or ambiguity increases during execution, update the saved plan and
escalate its mode. Do not silently downgrade a full or long-running plan merely
to shorten it.

## Universal Plan Content

Every mode includes:

- a short intent summary;
- mode and status (`proposed` for plan-only output and `active` for saved
  execution plans);
- Goal, Context, Constraints, and Done when;
- saved plan path when a file is used;
- in-scope and out-of-scope boundaries;
- assumptions that materially affect implementation;
- concrete, verb-first actions in dependency order;
- expected results and verification for each action or step;
- a validation plan and quality gate;
- risks, edge cases, and relevant recovery or rollback notes;
- subagent strategy: `none`, `read-only exploration`, `parallel verification`,
  or `disjoint implementation slices`;
- Final Definition of Done;
- at most three open questions, only when meaningful.

Use unchecked boxes only for work that can become complete. List non-goals as
plain bullets rather than incomplete tasks.

## Compact Mode Requirements

Keep compact plans short enough to scan as an execution dashboard:

- State one shared execution protocol and one final quality gate.
- For each action, include its expected result, concrete checklist, check, and a
  place to record evidence. Combine these fields when one line is sufficient.
- Prefer 1-3 checklist items per action and roughly 60-120 total lines for an
  ordinary medium plan. Treat this as a clarity budget, not permission to omit
  essential evidence; escalate to full mode if compact structure cannot fit.
- Use step-local failure conditions only where they differ from the shared
  protocol.
- Omit empty sections, repeated boilerplate, and speculative file lists.
- Split an action when it contains independent outcomes or verification gates;
  do not split it merely to increase detail.

## Full Mode Requirements

For every top-level step include:

- objective and observable expected result;
- implementation checklist and meaningful sub-steps when needed;
- concrete verification;
- a step-specific quality gate;
- the failure condition and immediate correction or re-plan response;
- completion evidence to record after implementation.

State the execution protocol once near the start of the plan. Do not repeat a
generic fix-loop checklist under every step. Repeat only step-specific facts.

## Long-Running Addendum

Long-running plans also include and maintain:

- **Purpose / Big Picture:** user-visible or operational value and how to
  observe it;
- **Progress:** timestamped completed, incomplete, and split items;
- **Surprises & Discoveries:** unexpected facts with concise evidence;
- **Decision Log:** material decisions, rationale, date, and author;
- **Outcomes & Retrospective:** results, gaps, and lessons at milestones and
  completion;
- **Context and Orientation:** repository paths, modules, commands, and terms
  needed by a newcomer;
- **Idempotence and Recovery:** safe retries, cleanup, rollback, and recovery;
- **Interfaces and Dependencies:** contracts and cross-boundary assumptions.

Use labeled prototype milestones when feasibility is uncertain. Keep the plan
self-contained enough to resume without relying on chat history.

## Execution Protocol Requirements

The plan must require this evidence loop:

1. Define the expected result before implementation.
2. Implement only the current action or step.
3. Record what was actually changed.
4. Run concrete checks.
5. Compare results with the quality gate and baseline when relevant.
6. Fix relevant failures immediately or re-plan if the expected approach is
   disproven.
7. Re-run affected checks after a fix.
8. Classify unresolved checks honestly.
9. Mark `[x]` only after implementation and verification both pass.

Compact mode applies this loop to each action with a shared gate. Full and
long-running modes apply it to each top-level step with step-local gates.

## Check Outcome Classification

Record enough evidence to distinguish these outcomes:

- **Passed:** the planned check ran in the relevant environment and met its
  acceptance condition.
- **Relevant failure:** the change caused, worsened, or may conceal the failure.
  Keep the item unchecked, fix or re-plan, and re-run the check.
- **Pre-existing failure:** reproduce it on the baseline or provide equivalent
  historical evidence. Record the exact command, relevant output, baseline
  reference, and why the change did not worsen it.
- **Flaky:** record multiple observations or the repository's accepted retry
  evidence. A later pass does not erase the flake; report both outcomes and
  assess relevance.
- **Unavailable:** record why the check could not run, what was attempted, and
  the strongest safe alternative. Do not mark the original check passed.
- **Unrelated failure:** identify the failing owner/path/system and show why it
  cannot be caused or masked by the current change. Record any follow-up owner
  or issue when known.

A pre-existing, flaky, unavailable, or unrelated classification may allow work
to continue only when evidence shows the failure is not a relevant regression.
It remains unresolved in the final summary. If a required relevant check cannot
be completed, report partial or blocked status unless the user explicitly
accepts the risk; accepted risk is still not a pass.

## Subagent Planning Rules

Use subagents only when they reduce context load or wall-clock time without
creating coordination risk. Good candidates are independent read-only
exploration, issue or PR analysis, parallel verification, and disjoint writes
with explicit ownership.

Do not recommend subagents for small tasks, sequential migrations, overlapping
edits, or polish loops that require one continuous rendered context. The parent
retains final architecture and product decisions, integration, and user
communication. This ownership statement coordinates responsibility; it does
not grant permission for commits, pushes, PR mutations, deployments, or other
actions outside the user's authorized scope.

## Template Adaptation Rules

- Read only the selected mode's template routed from `SKILL.md`; add the
  long-running reference only when that mode applies.
- Keep placeholders out of the produced plan.
- Omit `Open questions` when none are meaningful.
- If no command is identifiable, include a discovery action instead of an
  invented command.
- Do not pre-check future work because repository inspection suggests it may
  already exist; record the evidence and verify before marking it complete.
- Align `Done when`, validation, quality gates, and Final Definition of Done.
- Update saved-plan status, checkboxes, evidence, and path as execution changes.
- Follow repository plan lifecycle conventions. Otherwise use `active/`,
  `completed/`, and `abandoned/` as defined in `SKILL.md`.
- Do not add a separate `PLANS.md` convention unless the repository adopts it.

## Quality Gate Examples

- **Data migration:** schema and data order are safe, existing rows are handled,
  rollback or irreversibility is explicit, and dry-run or migration checks pass.
- **API:** request/response contracts and errors follow project conventions,
  tests cover them, and existing clients remain compatible.
- **UI:** target flows render at relevant breakpoints, interactive and error
  states work, accessibility basics hold, and browser/manual checks pass.
- **Refactor:** public behavior is unchanged, tests pass, and removed paths have
  no remaining references.
- **Debugging:** evidence proves or disproves the suspected cause, the fix
  targets the confirmed cause, and a regression check fails before the fix when
  practical.

## Avoid Planning Theater

- Do not repeat objective, expected result, and checklist when they say the same
  thing; combine them.
- Do not copy irrelevant validation categories into every plan.
- Do not turn non-goals, ownership notes, or process reminders into incomplete
  checkboxes.
- Do not record a quality gate as passed without named evidence.
- Do not preserve an `active` plan after work is completed or abandoned unless
  repository convention requires in-place status.
- Do not mark plan-only output `active`; use `proposed` until execution begins.
