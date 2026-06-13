# Development Plan Handoff

## Use Development Plan

After the planning brief is complete:

1. Read and apply `development-plan`.
2. Feed the normalized GitHub issue brief into that skill as the user's
   technical description.
3. Produce the final answer using the `development-plan` output structure.
4. Include the issue URL, title, state, and any important labels in the plan
   summary or assumptions.
5. Map issue requirements to concrete in-scope checklist items.
6. Map issue acceptance criteria to verification checks, quality gates, and the
   Final Definition of Done.
7. Include the issue-derived subagent recommendation in the `development-plan`
   Subagent strategy section.
8. Keep every implementation step unchecked unless there is evidence it has
   already been implemented and verified.

The final output should be a development plan, not an issue summary. Include
only the issue context needed to justify the plan.

## Handling Common Issue Shapes

Bug issue:

- Preserve reproduction steps and expected/actual behavior.
- Include a step to prove or disprove the suspected root cause before fixing.
- Include a regression test or explicit manual regression check.

Feature issue:

- Extract user-facing behavior, data/contracts, states, permissions, and rollout
  boundaries.
- Include product-facing validation and edge cases.

Refactor issue:

- Preserve existing behavior as a quality gate.
- Include reference checks for removed or moved paths.
- Include rollback or compatibility notes when public APIs, data, or build paths
  are touched.

Migration issue:

- Include data/backfill order, compatibility windows, rollback expectations, and
  dry-run checks when applicable.
- Include verification before and after the migration boundary.
