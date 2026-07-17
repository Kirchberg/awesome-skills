# Development Plan Skill Improvements

Raise `development-plan` from the reviewed 85/100 baseline to a target 96/100
by making planning depth adaptive, preserving verification integrity under
imperfect checks, and adding deterministic validation plus independent
forward-tests.

- Mode: full
- Status: completed
- Saved plan:
  `docs/plans/completed/2026-07-17-development-plan-skill-improvements.md`

## Task intake

- Goal: improve the skill, publish the work from a dedicated branch, and open a
  pull request.
- Context: `skills/development-plan/`, repository navigation in `README.md`,
  existing `check_skill.sh` conventions, and `skill-creator` guidance.
- Constraints: preserve progressive disclosure, stay project-agnostic, avoid
  granting authority through a plan, keep `SKILL.md` concise, and retain
  evidence-based completion.
- Done when: adaptive modes, check classifications, lifecycle, and authority
  boundaries are documented; validators and forward-tests pass; the branch is
  pushed and a draft PR targets `main`.

## Scope

In scope:

- [x] Add compact, full, and long-running planning modes.
- [x] Handle pre-existing, flaky, unavailable, unrelated, and relevant checks.
- [x] Add plan completion and abandonment lifecycle.
- [x] Clarify that plans and ownership do not grant new authority.
- [x] Add deterministic skill validation and update repository navigation.
- [x] Complete final routing smoke tests.
- [x] Publish the branch and PR.

Out of scope:

- Rewriting unrelated skills.
- Adding runtime dependencies.
- Changing installation behavior outside validation of this skill.
- Merging the pull request.

## Assumptions

- Compact mode is the default for bounded medium tasks.
- Full mode remains appropriate for risky, ambiguous, or cross-boundary work.
- Long-running mode extends full mode with resumable state and recovery.
- The authenticated GitHub connector can create the PR; local Git remains the
  preferred commit and push path.

## Execution protocol

For each step, confirm the expected result, edit only that scope, record the
change, run checks, fix relevant failures or re-plan, re-run affected checks,
classify unresolved outcomes, and record evidence. Mark `[x]` only after
implementation and verification pass.

## Step 1: Establish branch and baseline

### Objective and expected result

Start from current `main` with an isolated branch and a saved plan created
before skill source edits.

### Actions

- [x] Clone `Kirchberg/awesome-skills` and inspect repository conventions.
- [x] Create `agent/improve-development-plan-skill` from `ff91d85`.
- [x] Save this plan before editing the skill.
- [x] Fetch `origin/main` and confirm it still points to `ff91d85`.

### Verification

- [x] `git status -sb`, `git log`, `git rev-parse origin/main`, and repository
  inspection confirmed the expected baseline and clean starting scope.

### Quality gate and failure response

- Gate: branch, base commit, and saved-plan ordering are evidenced.
- If it fails: isolate the work on the correct branch and update the plan before
  source edits.

### Completion evidence

- Implemented: dedicated branch and saved plan.
- Verified by: local Git inspection and refreshed `origin/main`.
- Check outcomes: passed.
- Fixes or re-planning: none.

## Step 2: Make planning depth adaptive and context-efficient

### Objective and expected result

Keep ordinary medium plans compact while retaining step-local gates and
resumability where risk requires them.

### Actions

- [x] Define deterministic compact, full, and long-running selection tests.
- [x] Add a compact clarity budget and `proposed` status for plan-only output.
- [x] Replace the monolithic template with mode-specific one-level references.
- [x] Preserve a shared evidence loop while removing repeated fix-loop
  boilerplate.

### Verification

- [x] `SKILL.md` remains under 200 lines (141 after the final mode changes).
- [x] Medium CLI forward-test selected compact mode with four actions,
  `Status: proposed`, shared validation, and no invented repository paths.
- [x] Full debugging forward-test selected full mode and used step-local gates.
- [x] Migration forward-test selected long-running mode and produced resumable
  release windows, recovery, decisions, and `Status: proposed`.

### Quality gate and failure response

- Gate: each task shape selects a defensible mode, and compact output remains
  independently executable without full-mode ceremony.
- If it fails: tighten mode selection or the selected template and repeat only
  the affected scenario with a fresh agent.

### Completion evidence

- Implemented: adaptive modes and progressive template routing.
- Verified by: static assertions plus fresh medium, debugging, and migration
  forward-tests.
- Check outcomes: passed after tightening plan-only status and compactness.
- Fixes or re-planning: added explicit `Status: proposed`, 3-5 action guidance,
  a 60-120 line clarity budget, and split reference loading.

## Step 3: Preserve operational truth and lifecycle

### Objective and expected result

Prevent check deadlocks, false success, stale active plans, and accidental
authority expansion.

### Actions

- [x] Classify passed, relevant, pre-existing, flaky, unavailable, and unrelated
  outcomes with evidence requirements.
- [x] Keep accepted risk unresolved instead of converting it to a pass.
- [x] Add `active → completed/abandoned` fallback lifecycle rules.
- [x] State that plans, parent ownership, and agent assignment do not authorize
  commits, pushes, deployments, destructive actions, or external mutations.

### Verification

- [x] The debugging forward-test reproduced the reported export failure on the
  planned baseline, kept the full suite failed, and required an independent
  login regression gate.
- [x] The migration forward-test kept deployment and contraction separately
  authorized and treated cleanup as an explicit rollback boundary.
- [x] Deterministic assertions lock the classification, lifecycle, and authority
  wording.

### Quality gate and failure response

- Gate: no unresolved check can be labeled passed, relevant regressions still
  block completion, and lifecycle follows repository conventions first.
- If it fails: tighten the ambiguous rule, add a static assertion, and repeat
  the affected forward-test.

### Completion evidence

- Implemented: check taxonomy, evidence rules, lifecycle, and authority guards.
- Verified by: `check_skill.sh` and independent failure/migration scenarios.
- Check outcomes: passed.
- Fixes or re-planning: none after the status clarification in Step 2.

## Step 4: Validate packaging and behavior

### Objective and expected result

Prove the skill is structurally valid, installs cleanly, and routes fresh agents
to the correct mode-specific references.

### Actions

- [x] Add `skills/development-plan/scripts/check_skill.sh`.
- [x] Regenerate and verify `agents/openai.yaml` metadata.
- [x] Run skill-creator validation, Bash syntax, whitespace, and install checks.
- [x] Forward-test medium, debugging, and migration scenarios.
- [x] Complete post-split compact and long-running routing smoke tests.

### Verification

- [x] `quick_validate.py skills/development-plan` reports `Skill is valid!`.
- [x] `skills/development-plan/scripts/check_skill.sh` passes.
- [x] `bash -n skills/development-plan/scripts/check_skill.sh` passes.
- [x] `git diff --check` passes.
- [x] A temporary `install.sh --codex development-plan` install contains only
  the split reference set and passes its post-install check.
- [x] Fresh compact and long-running routing smoke tests use the final split
  reference layout and preserve `Status: proposed`.

### Quality gate and failure response

- Gate: all deterministic checks and final fresh-agent routing scenarios pass.
- If it fails: fix the smallest affected rule or route, rerun deterministic
  checks, and repeat only the affected scenario with a fresh agent.

### Completion evidence

- Implemented: validator, metadata refresh, installation check, and behavioral
  test matrix.
- Verified by: commands and forward-tests listed above.
- Check outcomes: passed. Compact routing selected four bounded actions and a
  shared gate; long-running routing added resumable state, decisions,
  idempotence, recovery, and explicit rollback boundaries.
- Fixes or re-planning: initial validator assertion was corrected to match a
  wrapped authority sentence; validation passed afterward.

## Step 5: Publish the reviewed change

### Objective and expected result

Publish the focused implementation commit from the dedicated branch, open a
draft PR against current `main`, and add this completed lifecycle record.

### Actions

- [x] Finalize validation evidence and move this plan to `completed/`.
- [x] Review and stage only intended files.
- [x] Commit with a concise message and push the tracking branch.
- [x] Open a draft PR through the authenticated GitHub connector.

### Verification

- [x] Staged and committed paths match the reviewed scope.
- [x] Remote implementation head matched commit `d2870e0` after push.
- [x] PR #3 targets `main` and records changes, rationale, impact, and checks.

### Quality gate and failure response

- Gate: pushed commit matches the validated tree and the PR URL is available.
- If it fails: correct branch, commit, push, or PR metadata and re-verify before
  reporting completion.

### Completion evidence

- Implemented: committed the reviewed implementation as `d2870e0`, pushed
  `agent/improve-development-plan-skill`, and opened draft PR #3 against `main`.
- Verified by: explicit staged-diff review, successful `git push -u`, and the
  GitHub connector response reporting base `main` and head `d2870e0`.
- Check outcomes: passed; this completed-plan move is the final bookkeeping
  update to the same PR branch.
- Fixes or re-planning: none.

## Validation plan

- [x] Skill frontmatter and name validation.
- [x] Repository-specific structural assertions.
- [x] Bash syntax and whitespace checks.
- [x] Temporary installation and post-install validation.
- [x] Compact medium-task behavior.
- [x] Full ambiguous-debugging behavior and baseline failure handling.
- [x] Long-running migration behavior and rollback boundaries.
- [x] Final post-split routing smoke tests.
- [x] Final staged-diff and remote-commit verification.

## Subagent strategy

- Mode: parallel verification.
- Candidates: independent compact, full-debugging, long-running migration, and
  final route-smoke planners with read-only access and no expected-answer leak.
- Parent-owned integration: all repository edits, design decisions, validation,
  commit, push, PR creation, and final summary.

## Risks, edge cases, and recovery

- Compact mode becomes vague: retain expected result, check, evidence, global
  gate, and a clarity budget; escalate when compact cannot fit safely.
- Exceptional checks become an escape hatch: require baseline/relevance evidence
  and never convert unresolved outcomes to passes.
- Template splitting breaks routing: lock every reference path in the validator
  and verify a copied installation.
- Publication includes unrelated files: use explicit staging and review the
  cached diff before commit.

## Final Definition of Done

- [x] Every step passed its quality gate.
- [x] All deterministic and behavioral checks passed.
- [x] The completed plan records final evidence at its lifecycle destination.
- [x] The dedicated branch is pushed from the validated commit.
- [x] A draft PR against `main` is open with validation evidence.
