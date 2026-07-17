# Full Development Plan Template

Use for large, high-risk, ambiguous, or cross-boundary work. State shared rules
once; repeat only facts specific to each step. Remove unused optional sections,
replace every placeholder, and do not wrap a saved plan in an outer code fence.

## Contents

- Task intake and scope
- Shared execution protocol
- Repeatable step structure
- Validation and unresolved checks
- Subagent strategy
- Risks, recovery, and Final Definition of Done

```markdown
# <Task> Development Plan

<What will change, why, and the high-level approach in 1-3 sentences.>

- Mode: <full | long-running>
- Status: <proposed | active | completed | abandoned>
- Saved plan: <path, or omit for an inline plan>

## Task intake

- Goal: <concrete outcome>
- Context: <relevant repository evidence>
- Constraints: <material technical, product, workflow, and authority limits>
- Done when: <observable acceptance and checks>

## Scope

In scope:

- [ ] <deliverable>

Out of scope:

- <non-goal>

## Assumptions

- <material assumption>

## Execution protocol

For each current step: confirm its expected result, implement only that scope,
record changes, run checks, fix relevant failures or re-plan, re-run affected
checks, classify unresolved outcomes, and record evidence. Mark `[x]` only after
implementation and verification pass. Do not continue when the step's quality
gate blocks progress. This plan does not authorize actions outside user scope.

## Step 1: <Verb-first title>

### Objective and expected result

<What this step accomplishes and what will be observably true.>

### Actions

- [ ] <concrete action>
- [ ] <concrete action>

### Verification

- [ ] <command, test, inspection, or manual check>

### Quality gate and failure response

- Gate: <step-specific conditions required to continue>
- If it fails: <smallest safe correction, re-plan trigger, and checks to rerun>

### Completion evidence

- Implemented:
- Verified by:
- Check outcomes:
- Fixes or re-planning:

## Step 2: <Repeat the same step structure>

## Validation plan

- [ ] <only relevant build/typecheck/lint/test/integration/manual checks>
- [ ] <end-to-end Done when demonstration>
- [ ] <regression or compatibility checks>

## Unresolved check record

- Check: <command or inspection>
- Classification: <pre-existing | flaky | unavailable | unrelated>
- Evidence: <baseline, attempts, output, and relevance assessment>
- Impact/follow-up: <remaining risk, owner, issue, or accepted-risk decision>

## Subagent strategy

- Mode: <none | read-only exploration | parallel verification | disjoint implementation slices>
- Candidate: <scope, access, expected output>
- Parent-owned integration: <decisions and integration responsibilities>

## Risks, edge cases, and recovery

- <risk or edge case>
  - Mitigation:
  - Recovery/rollback:
  - Verification:

## Final Definition of Done

- [ ] Every in-scope step passed its quality gate.
- [ ] The validation plan demonstrates Done when.
- [ ] Relevant regressions were fixed and re-verified.
- [ ] Unresolved checks and accepted risks remain explicitly documented.
- [ ] The saved plan records the outcome and follows its lifecycle convention.

## Open questions

- <include only meaningful blockers or decisions>
```
