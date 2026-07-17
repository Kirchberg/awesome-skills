# Long-Running Development Plan Addendum

Integrate these sections into the full template only for long-running mode.
Place Purpose and Progress near task intake, keep discoveries and decisions with
the execution record, and place orientation, recovery, and interfaces before
the Final Definition of Done. Do not duplicate full-template sections.

```markdown
## Purpose / Big Picture

<Value delivered and how a newcomer can observe it working.>

## Progress

- [ ] (<timestamp>) <granular status item>

## Surprises & Discoveries

- Observation:
  Evidence:

## Decision Log

- Decision:
  Rationale:
  Date/Author:

## Outcomes & Retrospective

- Outcome:
- Gaps:
- Lessons:

## Context and Orientation

<Self-contained paths, modules, commands, terms, and current working-tree state.>

## Idempotence and Recovery

<Safe retries, cleanup, rollback, and recovery from partially completed steps.>

## Interfaces and Dependencies

<Contracts, public functions, services, external dependencies, and boundaries.>
```

## Completion and Abandonment

When work finishes, fill evidence, set `Status: completed`, record the outcome,
and follow the repository convention or move the plan from `active/` to
`completed/`. When work stops without completion, set `Status: abandoned`,
record why, what remains, and how to resume, then use the repository convention
or move it to `abandoned/`. Never leave a stale active plan merely because some
implementation occurred.
