# Compact Development Plan Template

Use for bounded medium work. Keep the plan near 60-120 lines when evidence
permits, remove unused optional sections, replace every placeholder, and do not
wrap a saved plan in an outer code fence.

```markdown
# <Task> Development Plan

<What will change, why, and the high-level approach in 1-3 sentences.>

- Mode: compact
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

## Execution rules

- Work one action at a time and record what changed.
- Mark `[x]` only after the action is implemented and its check passes.
- Fix and re-run relevant failures before continuing.
- Classify pre-existing, flaky, unavailable, or unrelated checks with evidence;
  never label them passed.
- This plan records work but does not authorize actions outside user scope.

## Actions

### 1. <Verb-first action>

- Expected: <observable result>
- [ ] <one to three implementation items>
- Check: <command, test, inspection, or manual validation>
- Evidence: <fill after implementation>

### 2. <Verb-first action>

- Expected: <observable result>
- [ ] <one to three implementation items>
- Check: <command, test, inspection, or manual validation>
- Evidence: <fill after implementation>

## Validation and quality gate

- [ ] <targeted build, typecheck, lint, test, or manual check>
- [ ] Done when is demonstrated without a relevant regression.
- [ ] Every unresolved check is classified with evidence and impact.

If the gate fails, keep affected work unchecked, apply the smallest safe fix or
re-plan, and re-run affected checks.

## Subagent strategy

- Mode: <none | read-only exploration | parallel verification | disjoint implementation slices>
- Ownership: <scopes, access, expected outputs, or why none>

## Risks and recovery

- <risk or edge case>: <mitigation, rollback/recovery, and check>

## Final Definition of Done

- [ ] In-scope actions and validation passed.
- [ ] Relevant regressions are fixed and re-verified.
- [ ] Unresolved checks and accepted risks remain explicitly documented.
- [ ] Saved-plan status and lifecycle path reflect the real outcome.

## Open questions

- <include only meaningful blockers or decisions>
```
