# Feature Docs Write Handoff

After the evidence bundle is complete, invoke `feature-docs-write` and pass
the bundle as input.

## What To Pass

- The full normalized evidence bundle (see `evidence-schema.md`).
- The user's original request and language.
- Any project documentation convention already observed (for example an
  existing `docs/ai/` tree or a documented docs store).

Invoke `feature-docs-write` once, after evidence collection is finished; do
not hand off a partial bundle.

## What The Core Does

`feature-docs-write` will:

1. Route the feature to one or more domains.
2. Write or update durable docs (domain pages, a feature dossier, ADRs, and a
   changelog entry) under the detected docs convention, defaulting to
   `docs/ai/`.
3. Update the agent-facing instruction surface when warranted.
4. Optionally normalize style via `feature-docs-style`.

## Boundary

This adapter does not choose document structure, domain placement, or wording.
It provides evidence. `feature-docs-write` owns all documentation decisions.
Do not pre-write documentation pages here.
