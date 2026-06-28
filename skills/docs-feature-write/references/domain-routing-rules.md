# Domain Routing Rules

Decide where a feature's documentation belongs before writing it.

## Detect The Taxonomy First

- Look for an existing domain structure: `docs/ai/domains/`, a documented docs
  store, domain folders, or `AGENTS.md` files that name areas of the system.
- Reuse existing domain names exactly. Do not rename or re-bucket established
  domains.

## Route Each Touched Domain

For each `touched_domains` entry in the evidence bundle:

- Map it to an existing domain when one fits.
- Create a new domain page only when no existing domain fits, and record why.
- When confidence is low, keep the routing but note it as an open question in
  the feature dossier.

## Multi-Domain Features

- A feature may update several domain references and one feature dossier.
- Put cross-cutting explanation in the feature dossier; put domain-specific
  durable facts in each domain's reference page.

## Record Rationale

In the feature dossier, record the routing decision and its evidence so a future
agent follows the same taxonomy instead of inventing new buckets.
