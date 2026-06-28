# Completion Checklist

A feature documentation pass is done only when:

- [ ] Evidence was obtained (bundle ingested or collected inline) with sources.
- [ ] The feature was routed to one or more domains with recorded rationale.
- [ ] The output location was resolved (detected convention or `docs/ai/`).
- [ ] Durable docs were written or updated: relevant domain pages, the feature
      dossier (for large work), and a changelog entry.
- [ ] An ADR was created for each major decision flagged in the evidence.
- [ ] The agent surface was updated (in place when the convention exists, else
      under `docs/ai/`), reported explicitly.
- [ ] Links between domain pages, the feature dossier, ADRs, and changelog are
      present and resolve where checkable.
- [ ] Style was normalized (via `docs-feature-style` or manually).
- [ ] `scripts/check_docs.sh` passed against the output directory.

Report changed files, the output location, the domains touched, and any open
questions in the final summary.
