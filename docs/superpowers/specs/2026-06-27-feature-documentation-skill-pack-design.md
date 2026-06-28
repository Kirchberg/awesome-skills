# Feature Documentation Skill Pack — Design

## Summary

Add a self-contained pack of three composable agent skills to this skill
library that turns tracker/PR/commit evidence into durable, domain-structured
documentation for both humans and agents. The pack realizes the architecture
recommended in the deep-research report `Agent-Driven Documentation for Feature
Teams`, adapted to this repository's existing conventions (thin `SKILL.md` +
one-level `references/`, `agents/openai.yaml`, `scripts/check_skill.sh`,
project-agnostic abstractions).

The three skills are:

1. `feature-docs-collect` — a read-only evidence adapter.
2. `feature-docs-write` — the core documentation engine.
3. `feature-docs-style` — a style/normalization utility.

## Goals

- Convert feature evidence (tracker issue/task/project, linked change
  requests/PRs, merged commits, comments, rollout notes) into a normalized
  evidence bundle.
- Route durable documentation to the correct domain in a project's taxonomy.
- Generate durable docs using a Diátaxis-derived schema (explanation /
  reference / how-to) plus ADRs for major decisions.
- Update the agent-facing instruction surface (`AGENTS.md` / path-scoped
  instructions) when a feature changes how future agents should work in an area.
- Enforce documentation style (terminology, typography, structure) with Vale
  and markdownlint when available, and with the same rules applied manually when
  the tools are absent.

## Non-goals

- No hard-coded tracker/wiki/source-control vendor (Jira, Confluence, GitHub,
  Arcanum, etc.). Concrete tools appear only as optional fallbacks/examples.
- No dependency on the other skills already in this repository
  (`development-plan`, `agent-autonomous-loop`, `github-*`). The pack is
  self-contained.
- No runtime state, generated docs, or linter binaries committed into this skill
  library. Generated docs land in the *active project*, not here.
- No publishing pipeline (GitBook/Mintlify/Backstage). The pack is repo-first;
  publishing is out of scope.

## Confirmed decisions

- **Scope:** full three-skill pack.
- **Style tooling:** graceful degradation. Ship example Vale + markdownlint
  config as assets and a rules reference; run linters when on `PATH`, otherwise
  apply the same rules manually from the reference.
- **Output root:** because all output is AI-generated, the pack writes durable
  documentation under `docs/ai/` by default (never directly into a
  human-curated `docs/` root), unless the active project already has an
  established AI-docs location, which is detected and reused.
- **Self-contained composition:** the three skills compose only with each
  other; they never require the sibling skills in this repo.

## Architecture

Composition mirrors this repo's existing `github-issue-development-plan →
development-plan` adapter→core precedent, extended with a downstream utility:

```text
feature-docs-collect   (read-only adapter: evidence in)
        │  REQUIRED SUB-SKILL
        ▼
feature-docs-write     (core: route → write → update agent context)
        │  OPTIONAL final step
        ▼
feature-docs-style       (utility: normalize style; also usable standalone)
```

- `feature-docs-collect` collects and normalizes evidence, then hands off to
  `feature-docs-write`. It never writes docs itself.
- `feature-docs-write` is the core. It can also run directly (collect
  evidence inline) when no tracker handoff is used. It internally realizes the
  report's *domain-router*, *feature-doc-writer*, and *agent-context-updater*
  components as workflow phases backed by references. It optionally invokes
  `feature-docs-style` as its final step.
- `feature-docs-style` is independently usable on any markdown and is also the
  core's final normalization step.

The report's five conceptual components map onto the three skills as:

| Report component          | Where it lives                                   |
| ------------------------- | ------------------------------------------------ |
| feature-evidence-collector | `feature-docs-collect` (+ inline in core)    |
| domain-router             | `feature-docs-write` phase + reference        |
| feature-doc-writer        | `feature-docs-write` phase + reference        |
| agent-context-updater     | `feature-docs-write` phase + reference        |
| feature-docs-style       | `feature-docs-style` skill                      |

## Project-agnostic boundary

The reusable core defines abstractions and leaves concrete adapters out:

- Abstractions: **tracker** (issue/task/project), **change request** (PR/MR/CL),
  **source control**, **wiki/docs store**, **feature ID**, **domain**, **ADR**.
- Concrete tools (Jira, Confluence, GitHub `gh`, Arcanum, GitLab, Linear) are
  named only as optional fallbacks, exactly as `github-issue-development-plan`
  names `gh`.
- Examples from the report (SAFTDEV/SAFTIOS, storefront/promo-block/acquisition)
  are illustrative only; no product-specific names are baked into rules.

## Documentation output model

Convention-detection first, fallback second. The core:

1. Detects an existing AI-docs location in the active project (for example an
   existing `docs/ai/` tree, or a docs store explicitly designated for
   AI-generated docs). If found, it uses it. It does not route generated docs
   into a human-curated docs store, even when the project documents one.
2. Otherwise defaults to a `docs/ai/` tree in the active project:

```text
docs/ai/
  domains/
    <domain>/
      overview.md          # explanation: boundaries, ownership, glossary, links
      reference.md         # reference: stable facts (where things live, formats)
      how-to-*.md          # how-to: operate/modify within the domain
      AGENTS.md            # OPTIONAL agent-context for the domain (see below)
  features/
    <YYYY-MM-feature-slug>/
      overview.md          # what/why
      reference.md         # where it lives, formats, external artifacts
      operations.md        # how to operate or modify
      surprises-and-caveats.md
      linked-artifacts.md
  adrs/
    ADR-XXXX-<slug>.md     # decision, context, options, consequences
  changelog/
    <YYYY>/<YYYY-MM-DD-task-id-slug>.md   # small-task deltas
```

Three-tier intent: **domains** = durable orientation; **features** = durable
per-feature dossiers for large work; **changelog** = small deltas that attach
their durable effects back into domain/feature docs to avoid documentation spam.

Agent-context rule (respecting "AI output stays segregated"):

- If the active project already maintains operational `AGENTS.md` or
  path-scoped instruction files, the core may update them in place, but only as
  an explicit, convention-gated edit that is clearly reported.
- If no such convention exists, the core does **not** scatter new root-level
  agent files. It writes agent-facing context under `docs/ai/` (e.g.
  `docs/ai/domains/<domain>/AGENTS.md` or a `docs/ai/agent-index.md`).

## Skill specifications

### 1. `skills/feature-docs-collect/`

Read-only evidence adapter. Default operating mode: read-only; never mutates
tracker state or source files.

Files:

- `SKILL.md` — frontmatter `name: feature-docs-collect`; description triggers
  on "document a finished/shipped feature from a tracker item / PR / change
  request". Sections: Purpose, Operating Mode (read-only), Reference Routing,
  Source Resolution (abstract tracker/change-request sources; optional
  `gh`/connector fallbacks), Workflow (resolve → gather → normalize → hand off),
  Avoid. Declares `feature-docs-write` as REQUIRED SUB-SKILL. Stays under the
  200-line budget.
- `references/evidence-collection.md` — what to gather (summary, touched
  domains, linked artifacts, decisions, unresolved questions, operational
  facts), conflict resolution (prefer newest authoritative clarification),
  read-only subagent guidance.
- `references/evidence-schema.md` — the normalized evidence-bundle shape (shared
  contract with the core; the core ships an identical copy so each skill is
  independently installable).
- `references/feature-docs-write-handoff.md` — how to pass the bundle to the
  core and what the core expects.
- `agents/openai.yaml` — interface + `allow_implicit_invocation: true`.
- `scripts/check_skill.sh` — validator.

### 2. `skills/feature-docs-write/`

Core engine. Default operating mode: writes durable docs into the active
project's docs store (under `docs/ai/` by default).

Files:

- `SKILL.md` — frontmatter `name: feature-docs-write`; description triggers
  on "create/update durable feature documentation", "document this feature for
  humans and agents". Sections: Purpose, Operating Mode, Reference Routing,
  Workflow (ingest-or-collect evidence → route to domain → write docs → update
  agent context → optional style pass), Output Location (detect convention,
  else `docs/ai/`), Avoid. Under 200 lines.
- `references/evidence-schema.md` — identical shared bundle shape.
- `references/domain-routing-rules.md` — how to choose the target domain;
  detect the project's taxonomy first; create a new domain page only when none
  fits; record routing rationale.
- `references/doc-model.md` — the three-tier model and the `docs/ai/` tree;
  Diátaxis mapping; convention-detection rules; the segregation rule for
  agent-context.
- `references/feature-doc-template.md` — concrete templates for domain pages,
  the feature dossier, ADRs, and changelog entries.
- `references/agent-context-update.md` — when/how to update `AGENTS.md` /
  path-scoped instructions vs. writing under `docs/ai/`.
- `references/completion-checklist.md` — definition of done for a feature
  documentation pass (human surface + agent surface + style + links updated).
- `scripts/check_docs.sh` — structural sanity check for generated docs
  (required pages exist, one H1 per file, links resolve where checkable).
- `scripts/check_skill.sh` — validator.
- `agents/openai.yaml` — interface + `allow_implicit_invocation: true`.

### 3. `skills/feature-docs-style/`

Style/normalization utility with graceful degradation.

Files:

- `SKILL.md` — frontmatter `name: feature-docs-style`; description triggers on
  "normalize/lint documentation style". Sections: Purpose, Operating Mode
  (detect `vale`/`markdownlint`; run if present; else apply rules manually),
  Reference Routing, Workflow, Avoid. Under 200 lines.
- `references/style-rules.md` — terminology, typography (e.g. dash and
  homoglyph normalization as *configurable examples*, not mandates), and
  structural rules (heading order, single H1, spacing).
- `references/tooling.md` — how to detect, run, and skip Vale/markdownlint and
  how to map their rules to manual application.
- `assets/vale/.vale.ini` + `assets/vale/styles/` — minimal example Vale config
  and a sample vocabulary.
- `assets/markdownlint/.markdownlint.jsonc` — example markdownlint config.
- `scripts/check_skill.sh` — validator.
- `agents/openai.yaml` — interface + `allow_implicit_invocation: true`.

## Validation

Each skill ships `scripts/check_skill.sh` following the existing validator
style (`set -euo pipefail`, `fail()` helper, presence checks, `SKILL.md` line
budget ≤ 200, frontmatter `name:` assertion, required routing/guardrail string
greps, `agents/openai.yaml` policy assertion). `feature-docs-write` also
ships `check_docs.sh`. All scripts are executable and pass on a clean checkout.

Manual acceptance: a dry run where the core, given a small synthetic evidence
bundle, produces a feature dossier + domain reference update + an ADR under
`docs/ai/` in a scratch project directory, and the style enforcer normalizes it
both with and without linters installed.

## README updates

- Add the three skills to the `## Skills` list with one-line summaries.
- Extend `## Repository Layout` with the three new folders.
- Add `## Navigation` entries (default prompt + important files) for each.
- Keep the existing Maintenance Notes; the new skills follow them (concise
  `SKILL.md`, project-agnostic, no runtime state committed).

## Risks and mitigations

- **Scope creep into a publishing platform.** Mitigation: repo-first only;
  publishing is an explicit non-goal.
- **Over-coupling the three skills.** Mitigation: each ships its own copy of the
  shared `evidence-schema.md` and is independently installable; the core runs
  standalone without the adapter.
- **AI output polluting human docs.** Mitigation: default everything to
  `docs/ai/`; gate edits to operational `AGENTS.md` behind existing project
  convention.
- **Linter unavailability.** Mitigation: graceful degradation by design.

## Out of scope / follow-ups

- Concrete tracker adapters (Jira/GitHub/Arcanum) as separate installable
  sub-skills.
- An `llms.txt` / MCP search surface for published docs.
- CI wiring to run `feature-docs-style` automatically.
