# Documentation Model

## Three Tiers

- Domain documents: stable orientation per area (boundaries, ownership,
  glossary, links). Mostly explanation, some reference.
- Feature dossiers: durable per-feature records for large work.
- Changelog deltas: small-task records that attach durable effects back into
  domain or feature docs to avoid documentation spam.

## Output Tree

Detect an existing AI-docs location first; otherwise default to `docs/ai/`:

```text
docs/ai/
  domains/
    <domain>/
      overview.md          # explanation
      reference.md         # reference
      how-to-<task>.md     # how-to
      AGENTS.md            # optional agent context for the domain
  features/
    <YYYY-MM-feature-slug>/
      overview.md
      reference.md
      operations.md
      surprises-and-caveats.md
      linked-artifacts.md
  adrs/
    ADR-XXXX-<slug>.md
  changelog/
    <YYYY>/<YYYY-MM-DD-task-id-slug>.md
```

## Diataxis Mapping

- overview.md -> explanation: what it is, why it exists, boundaries.
- reference.md -> reference: where things live, formats, stable facts.
- how-to-*.md / operations.md -> how-to: operate or modify safely.
- ADR -> decision record: context, options, decision, consequences.

## Convention Detection

- If the project already has an established AI-docs location (for example an
  existing `docs/ai/` tree, or a docs store explicitly designated for
  AI-generated docs), use it unchanged.
- Otherwise default to `docs/ai/`. Do not route generated docs into a
  human-curated docs store, even when the project documents one.

## Segregation Rule

All generated documentation is AI-authored, so it stays under `docs/ai/` (or the
detected AI-docs location) and never lands in a human-curated `docs/` root by
default. Agent-context edits to operational files are gated separately; see
`agent-context-update.md`.

## Small Tasks

For small changes, write only a changelog entry and update the affected domain
or feature reference. Do not create a full feature dossier for every small task.
