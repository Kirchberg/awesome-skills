---
name: feature-docs-collect
description: Use when the user wants to document a finished, shipped, or merged feature from a tracker item, task, project, change request, or pull request. Collects read-only evidence from tracker and source control, normalizes it, then hands off to feature-docs-write. Do not use for writing code or mutating tracker state.
---

# Feature Docs Collect

## Purpose

Turn a finished feature's tracker and source-control history into a normalized
evidence bundle, then produce durable documentation through
`feature-docs-write`. This skill is a read-only evidence adapter: it gathers
and normalizes facts; it does not write documentation itself.

**REQUIRED SUB-SKILL:** Use `feature-docs-write` after the evidence bundle is
prepared.

## Operating Mode

Default to read-only evidence collection.

- Use this skill when the latest request is to document a feature starting from
  a tracker item, change request, or PR. If the request is to implement, fix,
  refactor, or otherwise change code, do not run this skill.
- Do not modify source files while collecting evidence.
- Do not edit, comment on, label, close, assign, or otherwise mutate tracker or
  change-request state.
- Treat tracker history, change requests, commits, and comments as evidence,
  not as documentation.
- Ask at most three blocking questions, and only when the feature source cannot
  be resolved.
- Produce the evidence bundle in the same language as the user's request.

## Reference Routing

Read these one-level references before handing off:

- `references/evidence-collection.md`: required. Defines what evidence to
  gather, conflict resolution, and read-only subagent guidance.
- `references/evidence-schema.md`: required. Defines the normalized evidence
  bundle shape that `feature-docs-write` consumes.
- `references/feature-docs-write-handoff.md`: required before invoking
  `feature-docs-write`. Defines how to pass the bundle and what the core
  expects.

## Source Resolution

Resolve the feature source before collecting evidence. Sources are abstract:

- `tracker`: an issue, task, story, or project in any tracker.
- `change request`: a pull request, merge request, or changelist.
- `source control`: merged commits and history.

Prefer a connected tracker or source-control app/connector when available. Use
command-line fallbacks (for example `gh`) only when no connector covers the
needed fields, and only for read access.

If the source cannot be resolved, report what was attempted and ask for the
missing reference or access.

## Workflow

1. Resolve the feature source (tracker item, change request, or PR).
2. Read `references/evidence-collection.md`.
3. Gather evidence read-only: summary, touched domains, linked artifacts,
   decisions, operational facts, caveats, unresolved questions.
4. Read `references/evidence-schema.md` and normalize evidence into the bundle.
5. Read `references/feature-docs-write-handoff.md`.
6. Read and apply `feature-docs-write`, passing the evidence bundle.
7. Return the documentation result, not a raw timeline.

## Avoid

- Do not document from the tracker title alone when the body, change requests,
  commits, or comments are accessible.
- Do not treat every comment as a requirement; identify authority.
- Do not invent artifacts, decisions, or operational facts.
- Do not mutate tracker, change-request, or source-control state.
- Do not write documentation in this skill; `feature-docs-write` owns that.
- Do not depend on other skills in this repository; this pack is self-contained.
