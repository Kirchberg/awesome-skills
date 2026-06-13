# Development Plan Template

Use this structure for generated plans. Replace placeholders with task-specific
content and repeat the step structure for all remaining steps.

```markdown
# Development Plan

<1-3 sentences describing what will be built or changed, why, and the
high-level approach.>

## Task intake

- Goal:
- Context:
- Constraints:
- Done when:
- Saved plan:

## Scope

### In scope

- [ ] <Concrete scope item>

### Out of scope

- [ ] <Concrete non-goal>

## Assumptions

- <Assumption 1>
- <Assumption 2>

## Execution protocol

For every step below:

1. Confirm the expected result.
2. Implement only the current step.
3. Record what was changed.
4. Run the verification checklist.
5. Run the quality gate.
6. If anything fails, fix it immediately.
7. Re-run the failed checks.
8. Mark completed checklist items `[x]` only after implementation and
   verification both pass.
9. Proceed only after the step passes.

For long-running plans, also keep these sections current:

- `Progress`: timestamp every completed, incomplete, or split item.
- `Surprises & Discoveries`: record unexpected facts with concise evidence.
- `Decision Log`: record every material decision and rationale.
- `Outcomes & Retrospective`: summarize outcomes at major milestones and final
  completion.

## Step 1: <Verb-first step title>

### Objective

<What this step accomplishes.>

### Expected result

<What should be true after this step is implemented.>

### Implementation checklist

- [ ] <Action>
- [ ] <Action>
- [ ] <Action>

### Sub-steps

#### 1.1 <Sub-step title>

Expected result:
<Specific expected result.>

Checklist:

- [ ] <Action>
- [ ] <Action>

Verification:

- [ ] <Concrete check, command, test, or inspection>

Fix condition:

- If <failure condition>, immediately <fix action> and re-run <check>.

### Verification checklist

- [ ] <Check>
- [ ] <Check>
- [ ] <Check>

### Quality gate

This step is complete only if:

- [ ] Expected result is achieved.
- [ ] Relevant tests/checks pass.
- [ ] No obvious regression is introduced.
- [ ] Edge cases for this step are covered or explicitly deferred with
  rationale.

### Immediate fix loop

If the quality gate fails:

- [ ] Identify the failing condition.
- [ ] Apply the smallest safe fix.
- [ ] Re-run the verification checklist.
- [ ] Update the completion evidence.
- [ ] Do not continue to the next step until this step passes.

### Completion evidence

Record after implementation:

- Expected:
- Implemented:
- Verified by:
- Quality result:
- Fixes applied:

Repeat the same structure for all remaining steps.

## Validation plan

- [ ] Typecheck/build:
- [ ] Lint/static analysis:
- [ ] Unit tests:
- [ ] Integration tests:
- [ ] E2E/manual checks:
- [ ] Regression checks:

## Long-running execution record

Include this section only for long-running plans.

### Purpose / Big Picture

<What someone gains after the change and how to observe it working.>

### Progress

- [ ] (<timestamp>) <Current granular status item>

### Surprises & Discoveries

- Observation:
  Evidence:

### Decision Log

- Decision:
  Rationale:
  Date/Author:

### Outcomes & Retrospective

- Outcome:
  Gaps:
  Lessons:

### Context and Orientation

<Self-contained repository context, relevant paths, modules, commands, and term
definitions.>

### Idempotence and Recovery

<Which steps can be repeated safely, how to retry failed steps, and how to clean
up or back out risky work.>

### Interfaces and Dependencies

<Contracts, public functions, services, external libraries, or cross-module
boundaries that must exist or remain stable.>

## Subagent strategy

Recommended mode: <none | read-only exploration | parallel verification |
disjoint implementation slices>

Candidate subagents:

- `<name>`: scope `<scope>`, access `<read-only|non-overlapping write>`,
  expected output `<summary/artifact/check result>`

Parent-owned work:

- [ ] Final architecture and product decisions.
- [ ] Integration of findings and code changes.
- [ ] Commits, pushes, PR comments, and final user summary.

## Risks and edge cases

- [ ] <Risk or edge case>
  - Mitigation:
  - Verification:

## Final Definition of Done

The implementation is done only when:

- [ ] All step-level quality gates passed.
- [ ] All mandatory fixes were applied and re-verified.
- [ ] The validation plan passed.
- [ ] The final behavior matches the original user request.
- [ ] Any remaining limitations are explicitly documented.

## Open questions

- <Question 1>
- <Question 2>
- <Question 3>
```
