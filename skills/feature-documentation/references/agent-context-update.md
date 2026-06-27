# Agent Context Update

Update the agent-facing surface so future agents work correctly in the area the
feature changed.

## Decide The Surface

- If the project already maintains operational `AGENTS.md` or path-scoped
  instruction files, you may update them in place. Make the edit explicit,
  minimal, and clearly reported in the final summary.
- If the project has no such convention, do not create new root-level agent
  files. Write agent context under `docs/ai/` instead, for example
  `docs/ai/domains/<domain>/AGENTS.md` or a `docs/ai/agent-index.md`.

## What To Record

- Where the domain's durable docs now live (links into `docs/ai/`).
- New operational rules a future agent must follow in this area.
- Path scope: which directories the guidance applies to, when known.

## Keep It Minimal

- Add only durable, agent-relevant rules. Do not duplicate the full human docs.
- Link to the domain reference and feature dossier rather than restating them.
- Never embed secrets, tokens, or environment-specific credentials.
