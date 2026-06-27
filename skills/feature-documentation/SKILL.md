---
name: feature-documentation
description: Use when the user wants durable documentation for a finished or in-progress feature, written for both humans and agents. Routes the feature to a domain, writes Diataxis-style docs (explanation, reference, how-to) plus an ADR for major decisions under docs/ai/, and updates agent context. Accepts an evidence bundle or collects evidence inline.
---

# Feature Documentation

## Purpose

Convert feature evidence into durable, domain-structured documentation for
humans and agents. Produce explanation, reference, and how-to pages, an ADR for
major decisions, and a changelog entry, then update the agent-facing surface.

## Operating Mode

- Accept a normalized evidence bundle from `tracker-feature-handoff`, or collect
  evidence inline when invoked directly.
- Treat tracker/PR material as evidence, not as documentation. Output a domain-
  structured knowledge base, not a stitched-together timeline.
- Write documentation into the active project, never into this skill library.
- Ask at most three blocking questions; otherwise state assumptions and proceed.
- Write documentation in the same language as the user's request.

## Reference Routing

Read these one-level references as needed:

- `references/evidence-schema.md`: the evidence bundle contract. Read first.
- `references/domain-routing-rules.md`: read before placing docs. Decides the
  target domain from the project taxonomy.
- `references/doc-model.md`: read before writing. Defines the three-tier model,
  the `docs/ai/` tree, Diataxis mapping, convention detection, and the rule that
  AI output stays segregated from human docs.
- `references/feature-doc-template.md`: read when writing pages. Templates for
  domain pages, feature dossiers, ADRs, and changelog entries.
- `references/agent-context-update.md`: read before touching any AGENTS.md or
  path-scoped instruction file.
- `references/completion-checklist.md`: read before claiming the pass is done.

## Output Location

Detect the project's documentation convention first. If an AI-docs location
already exists (for example a `docs/ai/` tree), use it. Otherwise default to a
`docs/ai/` tree in the active project. Never write generated documentation into
a human-curated `docs/` root by default.

## Workflow

1. Obtain evidence: ingest the bundle, or collect it inline against
   `references/evidence-schema.md`.
2. Read `references/domain-routing-rules.md` and route the feature to one or
   more domains.
3. Read `references/doc-model.md` and resolve the output location.
4. Read `references/feature-doc-template.md` and write or update: domain pages,
   the feature dossier, an ADR for each major decision, and a changelog entry.
5. Read `references/agent-context-update.md` and update the agent surface.
6. Read `references/completion-checklist.md` and verify the pass.
7. Optionally apply `docs-style-enforcer` to normalize style.
8. Run `scripts/check_docs.sh` against the output directory.

## Avoid

- Do not append everything to one endless wiki page; route by domain and intent.
- Do not invent domains, decisions, files, or operational facts.
- Do not write generated docs into a human `docs/` root by default.
- Do not edit a pre-existing operational AGENTS.md unless the project already
  uses that convention; otherwise write agent context under `docs/ai/`.
- Do not depend on other skills in this repository; this pack is self-contained.
