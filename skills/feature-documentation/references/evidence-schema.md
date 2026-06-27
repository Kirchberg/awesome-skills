# Evidence Schema

The normalized feature evidence bundle is the contract between evidence
collection and documentation. Produce it as a single structured object before
writing any documentation. Keep it factual: record evidence, not prose.

## Fields

- `feature_id`: stable identifier from the tracker or source control.
- `title`: human-readable feature name.
- `status`: shipped | merged | in-progress | rolled-back.
- `summary`: 1-3 sentence factual description of what shipped.
- `touched_domains`: list of domains this feature affects. Each entry:
  - `domain`: domain name (matches the project taxonomy when known).
  - `confidence`: high | medium | low.
  - `evidence`: why this domain is implicated (paths, modules, labels).
- `linked_artifacts`: list of artifacts. Each entry:
  - `type`: tracker-item | change-request | commit | doc | release-note | other.
  - `ref`: identifier or URL.
  - `note`: one line on relevance.
- `decisions`: list of notable design/operational decisions. Each entry:
  - `decision`: what was decided.
  - `rationale`: why, if known.
  - `alternatives`: considered options, if known.
  - `adr_candidate`: true | false.
- `operational_facts`: durable how-it-works facts. Each entry:
  - `fact`: e.g. "offer points are stored as JSON under config/offers".
  - `evidence`: source of the fact.
- `unresolved_questions`: open questions a future engineer or agent will hit.
- `caveats`: non-obvious surprises discovered during the work.

## Rules

- Every non-trivial claim carries `evidence` (a path, ref, label, or quote).
- Distinguish facts from assumptions; mark inferred items `inferred: true`.
- When sources conflict, keep the newest authoritative source and note the
  conflict in `unresolved_questions`.
- Do not invent artifacts, decisions, or facts not supported by evidence.
- The bundle is input to `feature-documentation`; it is not itself the docs.
