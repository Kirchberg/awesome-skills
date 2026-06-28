# Feature Documentation Skill Pack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a self-contained pack of three composable agent skills that turn tracker/PR evidence into durable, domain-structured documentation under `docs/ai/`.

**Architecture:** Three skills mirror this repo's adapter→core precedent: `feature-docs-collect` (read-only evidence adapter) hands off to `feature-docs-write` (core: route → write → update agent context), which optionally calls `feature-docs-style` (graceful-degradation style utility). Each skill is independently installable; the pack depends on no other repo skill.

**Tech Stack:** Markdown skill files (`SKILL.md` + one-level `references/` + `assets/`), `agents/openai.yaml` metadata, and POSIX/bash 3.2-compatible `scripts/check_skill.sh` validators that serve as the tests.

---

## Conventions for this plan

- The branch `feature-documentation-skill-pack` already exists and is checked out.
- The design spec lives at `docs/superpowers/specs/2026-06-27-feature-documentation-skill-pack-design.md`.
- Each `scripts/*.sh` validator is the "test": write it first, run it red, then green after the skill files exist.
- Bash must stay 3.2-compatible (macOS default). Do **not** use `globstar`; use `find -print0`.
- Every commit message ends with the trailer:
  `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`

## File structure

```text
skills/
  feature-docs-write/            # core engine
    SKILL.md
    agents/openai.yaml
    references/
      evidence-schema.md            # canonical shared bundle contract
      domain-routing-rules.md
      doc-model.md
      feature-doc-template.md
      agent-context-update.md
      completion-checklist.md
    scripts/
      check_docs.sh                 # structural check of generated docs
      check_skill.sh                # validator (test)
  feature-docs-collect/          # read-only evidence adapter
    SKILL.md
    agents/openai.yaml
    references/
      evidence-collection.md
      evidence-schema.md            # exact copy of the core canonical file
      feature-docs-write-handoff.md
    scripts/
      check_skill.sh                # validator (test)
  feature-docs-style/              # style/normalization utility
    SKILL.md
    agents/openai.yaml
    references/
      style-rules.md
      tooling.md
    assets/
      vale/.vale.ini
      vale/styles/config/vocabularies/Project/accept.txt
      vale/styles/config/vocabularies/Project/reject.txt
      markdownlint/.markdownlint.jsonc
    scripts/
      check_skill.sh                # validator (test)
README.md                           # add 3 skills to Skills/Layout/Navigation
```

Responsibilities: the adapter only gathers evidence; the core owns every documentation decision and output location; the utility only normalizes style. `evidence-schema.md` is authored once in the core and copied byte-identically into the adapter so both install independently.

---

## Task 1: feature-docs-write (core engine)

**Files:**
- Create: `skills/feature-docs-write/scripts/check_skill.sh`
- Create: `skills/feature-docs-write/scripts/check_docs.sh`
- Create: `skills/feature-docs-write/SKILL.md`
- Create: `skills/feature-docs-write/agents/openai.yaml`
- Create: `skills/feature-docs-write/references/evidence-schema.md`
- Create: `skills/feature-docs-write/references/domain-routing-rules.md`
- Create: `skills/feature-docs-write/references/doc-model.md`
- Create: `skills/feature-docs-write/references/feature-doc-template.md`
- Create: `skills/feature-docs-write/references/agent-context-update.md`
- Create: `skills/feature-docs-write/references/completion-checklist.md`

- [ ] **Step 1: Write the validator (test) `scripts/check_skill.sh`**

````bash
#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "feature-docs-write check failed: $*" >&2
  exit 1
}

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$skill_dir/SKILL.md"
metadata="$skill_dir/agents/openai.yaml"
docs_check="$skill_dir/scripts/check_docs.sh"

refs=(
  evidence-schema.md
  domain-routing-rules.md
  doc-model.md
  feature-doc-template.md
  agent-context-update.md
  completion-checklist.md
)

test -f "$skill_file" || fail "SKILL.md is missing"
test -f "$metadata" || fail "agents/openai.yaml is missing"
test -f "$docs_check" || fail "scripts/check_docs.sh is missing"
test -x "$docs_check" || fail "scripts/check_docs.sh is not executable"

for r in "${refs[@]}"; do
  test -f "$skill_dir/references/$r" || fail "reference $r is missing"
  grep -q "references/$r" "$skill_file" || fail "routing for $r is missing"
done

lines="$(wc -l < "$skill_file" | tr -d ' ')"
if [[ "$lines" -gt 200 ]]; then
  fail "$skill_file has $lines lines; split details into references/"
fi

grep -q '^name: feature-docs-write$' "$skill_file" || fail "skill name changed"
grep -q 'docs/ai/' "$skill_file" || fail "docs/ai default output is missing"
grep -q 'docs/ai/' "$skill_dir/references/doc-model.md" || fail "doc-model docs/ai tree is missing"
grep -q 'Segregation Rule' "$skill_dir/references/doc-model.md" || fail "segregation rule is missing"
grep -q 'scripts/check_docs.sh' "$skill_file" || fail "check_docs routing is missing"
grep -q 'feature-docs-style' "$skill_file" || fail "style enforcer handoff is missing"
grep -q 'self-contained' "$skill_file" || fail "self-contained statement is missing"
grep -q 'allow_implicit_invocation: true' "$metadata" || fail "implicit invocation policy is missing"

echo "feature-docs-write check passed"
````

- [ ] **Step 2: Run the validator to verify it fails (red)**

Run: `bash skills/feature-docs-write/scripts/check_skill.sh`
Expected: FAIL with `feature-docs-write check failed: SKILL.md is missing`

- [ ] **Step 3: Write `scripts/check_docs.sh` (bash 3.2-safe, no globstar)**

````bash
#!/usr/bin/env bash
set -euo pipefail

# Structural sanity check for generated feature documentation.
# Usage: check_docs.sh [docs-dir]   (defaults to docs/ai)

target="${1:-docs/ai}"

fail() {
  echo "check_docs failed: $*" >&2
  exit 1
}

test -d "$target" || fail "docs directory '$target' does not exist"

md_files=()
while IFS= read -r -d '' f; do
  md_files+=("$f")
done < <(find "$target" -type f -name '*.md' -print0)

if [[ "${#md_files[@]}" -eq 0 ]]; then
  fail "no markdown files found under '$target'"
fi

status=0
for f in "${md_files[@]}"; do
  # NOTE: counts all lines matching '^# ' including any inside ``` fences.
  # Intended for generated output docs, not for skill template files.
  h1_count="$(grep -c '^# ' "$f" || true)"
  if [[ "$h1_count" -ne 1 ]]; then
    echo "check_docs: $f has $h1_count level-1 headings (expected 1)" >&2
    status=1
  fi
  if [[ ! -s "$f" ]]; then
    echo "check_docs: $f is empty" >&2
    status=1
  fi
done

[[ "$status" -eq 0 ]] || fail "one or more documents failed structural checks"

echo "check_docs passed for '$target'"
````

- [ ] **Step 4: Write `SKILL.md`**

````markdown
---
name: feature-docs-write
description: Use when the user wants durable documentation for a finished or in-progress feature, written for both humans and agents. Routes the feature to a domain, writes Diataxis-style docs (explanation, reference, how-to) plus an ADR for major decisions under docs/ai/, and updates agent context. Accepts an evidence bundle or collects evidence inline.
---

# Feature Docs Write

## Purpose

Convert feature evidence into durable, domain-structured documentation for
humans and agents. Produce explanation, reference, and how-to pages, an ADR for
major decisions, and a changelog entry, then update the agent-facing surface.

## Operating Mode

- Accept a normalized evidence bundle from `feature-docs-collect`, or collect
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
7. Optionally apply `feature-docs-style` to normalize style.
8. Run `scripts/check_docs.sh` against the output directory.

## Avoid

- Do not append everything to one endless wiki page; route by domain and intent.
- Do not invent domains, decisions, files, or operational facts.
- Do not write generated docs into a human `docs/` root by default.
- Do not edit a pre-existing operational AGENTS.md unless the project already
  uses that convention; otherwise write agent context under `docs/ai/`.
- Do not depend on other skills in this repository; this pack is self-contained.
````

- [ ] **Step 5: Write `agents/openai.yaml`**

````yaml
interface:
  display_name: "Feature Docs Write"
  short_description: "Turn feature evidence into durable docs"
  default_prompt: "Use $feature-docs-write to write durable, domain-structured docs for this feature under docs/ai/."

policy:
  allow_implicit_invocation: true
````

- [ ] **Step 6: Write `references/evidence-schema.md` (canonical shared contract)**

````markdown
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
- The bundle is input to `feature-docs-write`; it is not itself the docs.
````

- [ ] **Step 7: Write `references/domain-routing-rules.md`**

````markdown
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
````

- [ ] **Step 8: Write `references/doc-model.md`**

`````markdown
# Documentation Model

## Three Tiers

- Domain documents: stable orientation per area (boundaries, ownership,
  glossary, links). Mostly explanation, some reference.
- Feature dossiers: durable per-feature records for large work.
- Changelog deltas: small-task records that attach durable effects back into
  domain or feature docs to avoid documentation spam.

## Output Tree

Detect an existing convention first; otherwise default to `docs/ai/`:

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

- If the project already has an AI-docs location, use it unchanged.
- If the project documents a docs store, follow it.
- Only when neither exists, create `docs/ai/`.

## Segregation Rule

All generated documentation is AI-authored, so it stays under `docs/ai/` (or the
detected AI-docs location) and never lands in a human-curated `docs/` root by
default. Agent-context edits to operational files are gated separately; see
`agent-context-update.md`.

## Small Tasks

For small changes, write only a changelog entry and update the affected domain
or feature reference. Do not create a full feature dossier for every small task.
`````

- [ ] **Step 9: Write `references/feature-doc-template.md`**

`````markdown
# Feature Doc Templates

Use these templates. Keep exactly one H1 per file. Replace `<...>` placeholders.

## Domain overview (`docs/ai/domains/<domain>/overview.md`)

```markdown
# <Domain> overview

## Purpose and boundaries
<What this domain owns and does not own.>

## Ownership
<Teams or roles, if known.>

## Glossary
- <term>: <definition>

## Related domains and subsystems
- <link>
```

## Domain reference (`docs/ai/domains/<domain>/reference.md`)

```markdown
# <Domain> reference

## Where things live
- <artifact>: <path or location>

## Formats and conventions
- <format or rule>
```

## Domain how-to (`docs/ai/domains/<domain>/how-to-<task>.md`)

```markdown
# How to <task>

## Prerequisites
- <prerequisite>

## Steps
1. <step>

## Verification
- <how to confirm it worked>
```

## Feature dossier (`docs/ai/features/<YYYY-MM-slug>/*`)

```markdown
# <Feature> overview

## What changed
## Why it changed
## Touched domains
```

```markdown
# <Feature> reference

## Where it lives
## Formats and storage
## External artifacts
```

```markdown
# Operating <feature>

## How to change it
## How to verify
```

```markdown
# Surprises and caveats

- <non-obvious caveat with evidence>
```

```markdown
# Linked artifacts

- <type>: <ref> - <note>
```

## ADR (`docs/ai/adrs/ADR-XXXX-<slug>.md`)

```markdown
# ADR-XXXX: <decision title>

## Status
<proposed | accepted | superseded>

## Context
<forces and background>

## Decision
<what was decided>

## Alternatives considered
<options and why rejected>

## Consequences
<trade-offs and follow-ups>
```

## Changelog entry (`docs/ai/changelog/<YYYY>/<YYYY-MM-DD-task-id-slug>.md`)

```markdown
# <task-id>: <short title>

- Date: <YYYY-MM-DD>
- Domains: <domain(s)>
- Durable effects applied to: <domain or feature reference updated>
- Summary: <one or two lines>
```
`````

- [ ] **Step 10: Write `references/agent-context-update.md`**

````markdown
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
````

- [ ] **Step 11: Write `references/completion-checklist.md`**

````markdown
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
- [ ] Style was normalized (via `feature-docs-style` or manually).
- [ ] `scripts/check_docs.sh` passed against the output directory.

Report changed files, the output location, the domains touched, and any open
questions in the final summary.
````

- [ ] **Step 12: Make scripts executable**

Run:
```bash
chmod +x skills/feature-docs-write/scripts/check_skill.sh skills/feature-docs-write/scripts/check_docs.sh
```

- [ ] **Step 13: Run the validator to verify it passes (green)**

Run: `bash skills/feature-docs-write/scripts/check_skill.sh`
Expected: `feature-docs-write check passed`

- [ ] **Step 14: Smoke-test `check_docs.sh` against a scratch directory**

Run:
```bash
tmpdir="$(mktemp -d)"; mkdir -p "$tmpdir/domains/x"
printf '# X overview\n\nbody\n' > "$tmpdir/domains/x/overview.md"
bash skills/feature-docs-write/scripts/check_docs.sh "$tmpdir"; rm -rf "$tmpdir"
```
Expected: `check_docs passed for '<tmpdir>'`

- [ ] **Step 15: Commit**

```bash
git add skills/feature-docs-write
git commit -m "$(printf 'Add feature-docs-write core skill\n\nCo-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>')"
```

---

## Task 2: feature-docs-collect (read-only evidence adapter)

**Files:**
- Create: `skills/feature-docs-collect/scripts/check_skill.sh`
- Create: `skills/feature-docs-collect/SKILL.md`
- Create: `skills/feature-docs-collect/agents/openai.yaml`
- Create: `skills/feature-docs-collect/references/evidence-collection.md`
- Create: `skills/feature-docs-collect/references/evidence-schema.md` (copied from core)
- Create: `skills/feature-docs-collect/references/feature-docs-write-handoff.md`

- [ ] **Step 1: Write the validator (test) `scripts/check_skill.sh`**

````bash
#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "feature-docs-collect check failed: $*" >&2
  exit 1
}

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$skill_dir/SKILL.md"
collection_ref="$skill_dir/references/evidence-collection.md"
schema_ref="$skill_dir/references/evidence-schema.md"
handoff_ref="$skill_dir/references/feature-docs-write-handoff.md"
metadata="$skill_dir/agents/openai.yaml"

test -f "$skill_file" || fail "SKILL.md is missing"
test -f "$collection_ref" || fail "evidence-collection reference is missing"
test -f "$schema_ref" || fail "evidence-schema reference is missing"
test -f "$handoff_ref" || fail "feature-docs-write handoff reference is missing"
test -f "$metadata" || fail "agents/openai.yaml is missing"

lines="$(wc -l < "$skill_file" | tr -d ' ')"
if [[ "$lines" -gt 200 ]]; then
  fail "$skill_file has $lines lines; split details into references/"
fi

grep -q '^name: feature-docs-collect$' "$skill_file" || fail "skill name changed"
grep -q 'REQUIRED SUB-SKILL' "$skill_file" || fail "required sub-skill declaration is missing"
grep -q 'feature-docs-write' "$skill_file" || fail "feature-docs-write handoff is missing"
grep -q 'read-only' "$skill_file" || fail "read-only operating mode is missing"
grep -q 'references/evidence-collection.md' "$skill_file" || fail "evidence-collection routing is missing"
grep -q 'references/evidence-schema.md' "$skill_file" || fail "evidence-schema routing is missing"
grep -q 'references/feature-docs-write-handoff.md' "$skill_file" || fail "handoff routing is missing"
grep -q 'self-contained' "$skill_file" || fail "self-contained statement is missing"
grep -q 'allow_implicit_invocation: true' "$metadata" || fail "implicit invocation policy is missing"

# Shared evidence schema must match the core skill's copy when both are present.
core_schema="$skill_dir/../feature-docs-write/references/evidence-schema.md"
if [[ -f "$core_schema" ]]; then
  diff -q "$schema_ref" "$core_schema" >/dev/null || fail "evidence-schema.md differs from feature-docs-write copy"
fi

echo "feature-docs-collect check passed"
````

- [ ] **Step 2: Run the validator to verify it fails (red)**

Run: `bash skills/feature-docs-collect/scripts/check_skill.sh`
Expected: FAIL with `feature-docs-collect check failed: SKILL.md is missing`

- [ ] **Step 3: Write `SKILL.md`**

````markdown
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
````

- [ ] **Step 4: Write `agents/openai.yaml`**

````yaml
interface:
  display_name: "Feature Docs Collect"
  short_description: "Collect feature evidence, then document it"
  default_prompt: "Use $feature-docs-collect to document a shipped feature from its tracker item and change requests."

policy:
  allow_implicit_invocation: true
````

- [ ] **Step 5: Write `references/evidence-collection.md`**

````markdown
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
````

- [ ] **Step 6: Copy the canonical evidence schema from the core skill**

Run:
```bash
cp skills/feature-docs-write/references/evidence-schema.md skills/feature-docs-collect/references/evidence-schema.md
```

- [ ] **Step 7: Write `references/feature-docs-write-handoff.md`**

````markdown
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
````

- [ ] **Step 8: Make the script executable**

Run:
```bash
chmod +x skills/feature-docs-collect/scripts/check_skill.sh
```

- [ ] **Step 9: Run the validator to verify it passes (green)**

Run: `bash skills/feature-docs-collect/scripts/check_skill.sh`
Expected: `feature-docs-collect check passed`

- [ ] **Step 10: Verify the shared schema is byte-identical**

Run:
```bash
diff -u skills/feature-docs-write/references/evidence-schema.md skills/feature-docs-collect/references/evidence-schema.md && echo "schemas identical"
```
Expected: `schemas identical` (no diff output)

- [ ] **Step 11: Commit**

```bash
git add skills/feature-docs-collect
git commit -m "$(printf 'Add feature-docs-collect adapter skill\n\nCo-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>')"
```

---

## Task 3: feature-docs-style (style/normalization utility)

**Files:**
- Create: `skills/feature-docs-style/scripts/check_skill.sh`
- Create: `skills/feature-docs-style/SKILL.md`
- Create: `skills/feature-docs-style/agents/openai.yaml`
- Create: `skills/feature-docs-style/references/style-rules.md`
- Create: `skills/feature-docs-style/references/tooling.md`
- Create: `skills/feature-docs-style/assets/vale/.vale.ini`
- Create: `skills/feature-docs-style/assets/vale/styles/config/vocabularies/Project/accept.txt`
- Create: `skills/feature-docs-style/assets/vale/styles/config/vocabularies/Project/reject.txt`
- Create: `skills/feature-docs-style/assets/markdownlint/.markdownlint.jsonc`

- [ ] **Step 1: Write the validator (test) `scripts/check_skill.sh`**

````bash
#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "feature-docs-style check failed: $*" >&2
  exit 1
}

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$skill_dir/SKILL.md"
style_ref="$skill_dir/references/style-rules.md"
tooling_ref="$skill_dir/references/tooling.md"
metadata="$skill_dir/agents/openai.yaml"
vale_cfg="$skill_dir/assets/vale/.vale.ini"
mdl_cfg="$skill_dir/assets/markdownlint/.markdownlint.jsonc"

test -f "$skill_file" || fail "SKILL.md is missing"
test -f "$style_ref" || fail "style-rules reference is missing"
test -f "$tooling_ref" || fail "tooling reference is missing"
test -f "$metadata" || fail "agents/openai.yaml is missing"
test -f "$vale_cfg" || fail "example Vale config is missing"
test -f "$mdl_cfg" || fail "example markdownlint config is missing"

lines="$(wc -l < "$skill_file" | tr -d ' ')"
if [[ "$lines" -gt 200 ]]; then
  fail "$skill_file has $lines lines; split details into references/"
fi

grep -q '^name: feature-docs-style$' "$skill_file" || fail "skill name changed"
grep -qi 'graceful degradation' "$skill_file" || fail "graceful degradation mode is missing"
grep -q 'markdownlint' "$skill_file" || fail "markdownlint handling is missing"
grep -qi 'vale' "$skill_file" || fail "vale handling is missing"
grep -q 'references/style-rules.md' "$skill_file" || fail "style-rules routing is missing"
grep -q 'references/tooling.md' "$skill_file" || fail "tooling routing is missing"
grep -q 'self-contained' "$skill_file" || fail "self-contained statement is missing"
grep -q 'allow_implicit_invocation: true' "$metadata" || fail "implicit invocation policy is missing"

echo "feature-docs-style check passed"
````

- [ ] **Step 2: Run the validator to verify it fails (red)**

Run: `bash skills/feature-docs-style/scripts/check_skill.sh`
Expected: FAIL with `feature-docs-style check failed: SKILL.md is missing`

- [ ] **Step 3: Write `SKILL.md`**

````markdown
---
name: feature-docs-style
description: Use when documentation markdown needs style and structure normalization (terminology, typography, heading rules). Runs Vale and markdownlint when installed and applies the same rules manually when they are absent. Usable standalone or as the final step of feature-docs-write.
---

# Feature Docs Style

## Purpose

Normalize documentation style and structure so authors can choose terminology
and typography without hard-coding rules into every workflow. Works on any
markdown, and is the optional final step of `feature-docs-write`.

## Operating Mode

Graceful degradation:

- Detect `vale` and `markdownlint` (or `markdownlint-cli`) on `PATH`.
- When a tool is present, run it using the shipped example config as a starting
  point, then apply fixes.
- When a tool is absent, apply the same rules manually from
  `references/style-rules.md`. Never block on a missing binary.
- Report which tools ran and which rules were applied manually.

## Reference Routing

- `references/style-rules.md`: required. Terminology, typography, and structure
  rules, with configurable examples.
- `references/tooling.md`: required before running or skipping linters. Defines
  detection, invocation, and manual fallback mapping.

## Assets

- `assets/vale/.vale.ini` and `assets/vale/styles/`: example Vale config and a
  sample vocabulary.
- `assets/markdownlint/.markdownlint.jsonc`: example markdownlint config.

Assets are starting points. Copy them into the active project and adapt; do not
treat the examples as mandatory project rules.

## Workflow

1. Read `references/tooling.md`.
2. Detect available linters.
3. Read `references/style-rules.md`.
4. For each target file: run available linters, then apply remaining rules
   manually.
5. Make minimal edits that preserve meaning. Do not rewrite content.
6. Report tools used, rules applied, and files changed.

## Avoid

- Do not require a specific linter to be installed.
- Do not impose example terminology or typography as mandatory rules.
- Do not rewrite or restructure content beyond style and structure fixes.
- Do not depend on other skills in this repository; this pack is self-contained.
````

- [ ] **Step 4: Write `agents/openai.yaml`**

````yaml
interface:
  display_name: "Feature Docs Style"
  short_description: "Normalize documentation style"
  default_prompt: "Use $feature-docs-style to normalize the style and structure of these docs."

policy:
  allow_implicit_invocation: true
````

- [ ] **Step 5: Write `references/style-rules.md`**

````markdown
# Style Rules

These rules are defaults and examples. Adapt per project; do not impose example
terminology on a project that has its own conventions.

## Terminology

- Maintain a project vocabulary of preferred and discouraged terms.
- Replace discouraged terms with preferred ones (configurable; see the Vale
  vocabulary asset for the format).

## Typography (configurable examples)

- Normalize dash usage to the project's convention (for example, avoid stray
  em dashes where the project prefers hyphens).
- Normalize homoglyphs where the project requires it (for example, replacing a
  given letter with its standard counterpart). Treat these as opt-in examples.
- Use straight or curly quotes consistently per project preference.

## Structure

- Exactly one level-1 heading per document.
- Headings increment by one level at a time; no skipped levels.
- Consistent heading style (ATX `#`).
- Unordered list items use a single bullet style, `-` by default
  (configurable; see the `.markdownlint.jsonc` MD004 asset).
- One blank line around headings, lists, and fenced code blocks.
- Trim trailing whitespace; end files with a single newline.

## Application Order

1. Structure fixes first (headings, spacing).
2. Terminology replacements.
3. Typography normalization.

Apply the minimal change that satisfies the rule. Preserve meaning and code
samples exactly.
````

- [ ] **Step 6: Write `references/tooling.md`**

`````markdown
# Tooling

## Detection

Check for linters before using them:

```bash
command -v vale >/dev/null 2>&1 && echo "vale: present" || echo "vale: absent"
(command -v markdownlint >/dev/null 2>&1 \
  || command -v markdownlint-cli >/dev/null 2>&1) \
  && echo "markdownlint: present" || echo "markdownlint: absent"
```

## Running Vale

When present, run Vale with a project config, falling back to the shipped
example as a starting point:

```bash
vale --config .vale.ini <files>
```

## Running markdownlint

```bash
markdownlint --config .markdownlint.jsonc <files>
```

## Manual Fallback

When a tool is absent, apply its rules by hand from `references/style-rules.md`:

- markdownlint -> structure rules (single H1, heading increments, spacing,
  trailing whitespace, final newline).
- Vale -> terminology and typography rules from the vocabulary.

Never block on a missing binary. Always report which path was used.
`````

- [ ] **Step 7: Write `assets/vale/.vale.ini`**

````ini
# Example Vale config. Copy into the active project and adapt.
StylesPath = styles
MinAlertLevel = suggestion
Vocab = Project

[*.{md,markdown}]
BasedOnStyles = Vale
````

- [ ] **Step 8: Write `assets/vale/styles/config/vocabularies/Project/accept.txt`**

````text
docs-as-code
changelog
````

- [ ] **Step 9: Write `assets/vale/styles/config/vocabularies/Project/reject.txt`**

````text
docs as code
change-log
````

- [ ] **Step 10: Write `assets/markdownlint/.markdownlint.jsonc`**

````jsonc
// Example markdownlint config. Copy into the active project and adapt.
{
  "default": true,
  "MD013": false,
  "MD025": true,
  "MD003": { "style": "atx" },
  "MD004": { "style": "dash" }
}
````

- [ ] **Step 11: Make the script executable**

Run:
```bash
chmod +x skills/feature-docs-style/scripts/check_skill.sh
```

- [ ] **Step 12: Run the validator to verify it passes (green)**

Run: `bash skills/feature-docs-style/scripts/check_skill.sh`
Expected: `feature-docs-style check passed`

- [ ] **Step 13: Commit**

```bash
git add skills/feature-docs-style
git commit -m "$(printf 'Add feature-docs-style skill\n\nCo-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>')"
```

---

## Task 4: Document the pack in README and validate the whole pack

**Files:**
- Modify: `README.md` (Skills list, Repository Layout tree, Navigation)

- [ ] **Step 1: Add the three skills to the `## Skills` list**

In `README.md`, after the `github-pr-codex-review-monitor` bullet (the one ending "until the review and checks are clear."), insert these bullets:

````markdown
- [`feature-docs-write`](skills/feature-docs-write/) turns a feature
  evidence bundle into durable, domain-structured documentation under `docs/ai/`
  (explanation, reference, how-to, ADRs, changelog) and updates the agent-facing
  surface. It is the self-contained core of the documentation skill pack.
- [`feature-docs-collect`](skills/feature-docs-collect/) collects
  read-only feature evidence from a tracker item, change request, or PR,
  normalizes it, and hands off to `feature-docs-write`.
- [`feature-docs-style`](skills/feature-docs-style/) normalizes documentation
  style and structure with Vale and markdownlint when present, and applies the
  same rules manually when they are absent.
````

- [ ] **Step 2: Extend the `## Repository Layout` tree**

In the `## Repository Layout` fenced `text` block, before the closing fence, append:

````text
  feature-docs-write/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  feature-docs-collect/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  feature-docs-style/
    SKILL.md
    agents/openai.yaml
    references/
    assets/
    scripts/
````

- [ ] **Step 3: Add `## Navigation` subsections**

After the existing `### github-pr-codex-review-monitor` navigation block (before `## Maintenance Notes`), insert:

`````markdown
### `feature-docs-write`

Use when a finished or in-progress feature needs durable docs for humans and
agents, routed by domain and written under `docs/ai/`.

Default prompt:

```text
Use $feature-docs-write to write durable, domain-structured docs for this feature under docs/ai/.
```

Important files:

- [`skills/feature-docs-write/SKILL.md`](skills/feature-docs-write/SKILL.md)
- [`skills/feature-docs-write/references/doc-model.md`](skills/feature-docs-write/references/doc-model.md)
- [`skills/feature-docs-write/references/feature-doc-template.md`](skills/feature-docs-write/references/feature-doc-template.md)
- [`skills/feature-docs-write/scripts/check_docs.sh`](skills/feature-docs-write/scripts/check_docs.sh)

### `feature-docs-collect`

Use when documentation should start from a tracker item, change request, or PR,
collecting evidence read-only before handing off to `feature-docs-write`.

Default prompt:

```text
Use $feature-docs-collect to document a shipped feature from its tracker item and change requests.
```

Important files:

- [`skills/feature-docs-collect/SKILL.md`](skills/feature-docs-collect/SKILL.md)
- [`skills/feature-docs-collect/references/evidence-collection.md`](skills/feature-docs-collect/references/evidence-collection.md)
- [`skills/feature-docs-collect/references/feature-docs-write-handoff.md`](skills/feature-docs-collect/references/feature-docs-write-handoff.md)

### `feature-docs-style`

Use when documentation markdown needs style and structure normalization, with or
without Vale and markdownlint installed.

Default prompt:

```text
Use $feature-docs-style to normalize the style and structure of these docs.
```

Important files:

- [`skills/feature-docs-style/SKILL.md`](skills/feature-docs-style/SKILL.md)
- [`skills/feature-docs-style/references/style-rules.md`](skills/feature-docs-style/references/style-rules.md)
- [`skills/feature-docs-style/references/tooling.md`](skills/feature-docs-style/references/tooling.md)
`````

- [ ] **Step 4: Run all three validators (pack-wide green check)**

Run:
```bash
for s in feature-docs-write feature-docs-collect feature-docs-style; do
  bash "skills/$s/scripts/check_skill.sh"
done
```
Expected: three lines, each `<skill> check passed`.

- [ ] **Step 5: Re-verify the shared schema identity**

Run:
```bash
diff -q skills/feature-docs-write/references/evidence-schema.md skills/feature-docs-collect/references/evidence-schema.md && echo "schemas identical"
```
Expected: `schemas identical`

- [ ] **Step 6: Confirm no generated docs leaked into this repo**

Run:
```bash
test ! -e docs/ai && echo "no docs/ai in skill library (correct)"
```
Expected: `no docs/ai in skill library (correct)`

- [ ] **Step 7: Commit**

```bash
git add README.md
git commit -m "$(printf 'Document feature-docs-write skill pack in README\n\nCo-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>')"
```

---

## Task 5 (optional): End-to-end dry run acceptance

This task validates the core skill produces sensible output. It writes into a
throwaway scratch directory, never into this repo.

- [ ] **Step 1: Create a scratch project and a synthetic evidence bundle**

Run:
```bash
scratch="$(mktemp -d)"; echo "scratch=$scratch"
```

- [ ] **Step 2: Manually exercise the core skill against the scratch dir**

Invoke `feature-docs-write` (read its SKILL.md and references) with a small
synthetic evidence bundle, writing output under `"$scratch/docs/ai"`. Produce at
least: one domain `overview.md` + `reference.md`, one feature dossier
`overview.md`, and one `adrs/ADR-0001-*.md`, following
`skills/feature-docs-write/references/feature-doc-template.md`.

- [ ] **Step 3: Validate the generated docs**

Run:
```bash
bash skills/feature-docs-write/scripts/check_docs.sh "$scratch/docs/ai"
```
Expected: `check_docs passed for '<scratch>/docs/ai'`

- [ ] **Step 4: Clean up**

Run:
```bash
rm -rf "$scratch"; echo "cleaned"
```
Expected: `cleaned`

---

## Self-review

- **Spec coverage:** full 3-skill pack (Tasks 1-3), adapter→core→utility
  composition (SKILL.md handoffs), `docs/ai/` default + convention detection
  (doc-model.md, SKILL.md Output Location), Diataxis + three-tier model
  (doc-model.md, feature-doc-template.md), agent-context segregation
  (agent-context-update.md), graceful-degradation style (feature-docs-style
  SKILL.md + tooling.md), shared evidence schema with identity check (Task 1
  Step 6 / Task 2 Steps 6,10 / Task 4 Step 5), per-skill validators + check_docs
  (every task), README updates (Task 4), self-contained / no-sibling-dependency
  (every SKILL.md Avoid + validator grep), no generated docs in the library
  (Task 4 Step 6). All spec sections map to a task.
- **Placeholder scan:** none. `<...>` tokens appear only inside doc *templates*
  that are intended to carry placeholders for downstream authors.
- **Type/string consistency:** validator grep strings match the exact text in
  each `SKILL.md`/reference (`self-contained`, `read-only`, `docs/ai/`,
  `Segregation Rule`, `graceful degradation`, `scripts/check_docs.sh`,
  `allow_implicit_invocation: true`, every `references/<file>.md` route).
  `default_prompt` strings match between each `agents/openai.yaml` and the README
  Navigation block. The shared `evidence-schema.md` is authored once and copied,
  enforced by `diff`.
````