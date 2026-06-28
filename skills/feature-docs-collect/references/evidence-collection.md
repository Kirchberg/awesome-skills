# Evidence Collection

## What To Gather

Collect enough evidence to document the feature from the real work, not from the
title alone.

- Feature identity: tracker ID, title, state, owners, dates, labels.
- Full tracker body and the relevant comments: clarifications, acceptance
  criteria, design decisions, rollout notes.
- Linked change requests (PR/MR/CL), merged commits, and their diffs at a high
  level: which areas, modules, and files changed.
- Linked docs, release notes, dashboards, and related tracker items.
- Operational facts: where new data/config lives, in what format, how it is
  changed, and where external artifacts (links, assets) live.
- Decisions with rationale and considered alternatives.
- Caveats and surprises discovered during the work.
- Unresolved questions a future engineer or agent will hit.

## Touched-Domain Inference

Infer which domains the feature affects from changed paths, modules, labels, and
ownership. For each domain, record confidence and the evidence that implicates
it. Prefer the project's existing taxonomy when it is discoverable.

## Conflict Resolution

When sources conflict, prefer the newest authoritative source (for example a
maintainer's final clarification, or the merged change request over an early
comment). Record the conflict as an unresolved question rather than silently
choosing.

## Read-Only Subagents

Use subagents only for independent read-heavy tracks, and only read-only:

- tracker reader: summarize body, comments, acceptance criteria.
- change-request mapper: summarize touched areas and operational facts.
- risk/caveat reviewer: surface migration, rollout, and compatibility caveats.

Each subagent returns a concise evidence summary with sources. The parent agent
owns the final normalized bundle. Subagents must not write files or mutate state.
