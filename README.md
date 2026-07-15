# awesome-skills

A reusable collection of skills for AI-native engineering workflows ✨

This repository is a portable skill library. Each skill folder under `skills/`,
either directly or one category deep, is installable into a personal or
project-local skills directory.

## Skills

- [`development-plan`](skills/development-plan/) creates executable
  implementation plans for medium and large engineering tasks, including saved
  plans, validation steps, quality gates, and progress tracking.
- [`agent-autonomous-loop`](skills/agent-autonomous-loop/) runs an explicit,
  bounded multi-round handoff loop through fresh worker agents, with a
  review-only completion gate after the latest source changes. It is opt-in
  only and disables implicit invocation in `agents/openai.yaml`.
- [`github-issue-development-plan`](skills/github-issue-development-plan/)
  converts GitHub issues into implementation plans by collecting issue facts,
  inspecting repository context, and then applying `development-plan`.
- [`github-pr-codex-review-monitor`](skills/github-pr-codex-review-monitor/)
  monitors a GitHub PR for ChatGPT Codex Connector review feedback and failing
  PR checks, applies actionable fixes, pushes updates, and requests another
  `@codex review` until the review and checks are clear.
- [`docs-feature-write`](skills/docs-feature-write/) turns a feature
  evidence bundle into durable, domain-structured documentation under `docs/ai/`
  (explanation, reference, how-to, ADRs, changelog) and updates the agent-facing
  surface. It is the self-contained core of the documentation skill pack.
- [`docs-feature-collect`](skills/docs-feature-collect/) collects
  read-only feature evidence from a tracker item, change request, or PR,
  normalizes it, and hands off to `docs-feature-write`.
- [`docs-feature-style`](skills/docs-feature-style/) normalizes documentation
  style and structure with Vale and markdownlint when present, and applies the
  same rules manually when they are absent.
- [`swift6-migration`](skills/apple-development/swift6-migration/) audits,
  plans, executes, and resumes staged migrations of Apple-platform projects to
  Swift 6 language mode and strict concurrency.

## Repository Layout

```text
skills/
  apple-development/
    swift6-migration/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
  development-plan/
    SKILL.md
    agents/openai.yaml
    references/
  agent-autonomous-loop/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  github-issue-development-plan/
    SKILL.md
    agents/openai.yaml
    references/
  github-pr-codex-review-monitor/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  docs-feature-write/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  docs-feature-collect/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  docs-feature-style/
    SKILL.md
    agents/openai.yaml
    references/
    assets/
    scripts/
```

## Installation

Install one skill by copying its folder into your personal skills directory:

```bash
cp -R skills/development-plan "$SKILLS_HOME/development-plan"
```

Categorized skills are installed by their skill name rather than their category
path:

```bash
./install.sh swift6-migration
```

Install into a specific project by copying the folder into that project's local
skills directory:

```bash
cp -R skills/development-plan /path/to/project/.agents/skills/development-plan
```

Repeat for each skill you want to use. Keep the folder name the same as the
`name:` field in `SKILL.md`.

### One-command install (Claude + Codex)

Use `install.sh` to (re)install the `docs-feature-*` documentation pack into your
Claude and Codex skill directories in one step:

```bash
./install.sh                                        # all docs-feature-* skills, both runtimes
./install.sh docs-feature-write docs-feature-style  # only the named skills
./install.sh --all                                  # every skill, including categorized skills
./install.sh --claude                               # Claude only (--codex for Codex only)
```

Destinations default to `~/.claude/skills` and `~/.codex/skills`, honoring
`CLAUDE_CONFIG_DIR` / `CODEX_HOME` when set; the explicit `CLAUDE_SKILLS_DIR` /
`CODEX_SKILLS_DIR` overrides take precedence. A named install automatically pulls in
any required sub-skills (installing `docs-feature-collect` also installs
`docs-feature-write`). Each installed skill is re-validated with its
`check_skill.sh`. Restart your Claude/Codex session afterwards to pick up
changes.

## Navigation

### `development-plan`

Use when a task is large enough that a saved, verifiable plan is safer than
editing immediately.

Default prompt:

```text
Use $development-plan to turn this medium-sized implementation request into a saved, verifiable plan.
```

Important files:

- [`skills/development-plan/SKILL.md`](skills/development-plan/SKILL.md)
- [`skills/development-plan/references/core-planning-rules.md`](skills/development-plan/references/core-planning-rules.md)
- [`skills/development-plan/references/plan-template.md`](skills/development-plan/references/plan-template.md)

### `agent-autonomous-loop`

Use only when you explicitly want a bounded autonomous loop with handoff state
and worker rounds. Completion requires a fresh review-only worker after the
latest source changes. This is not intended to run automatically on every
session.

Default prompt:

```text
Use $agent-autonomous-loop to execute this well-scoped task through an explicit autonomous handoff loop.
```

Important files:

- [`skills/agent-autonomous-loop/SKILL.md`](skills/agent-autonomous-loop/SKILL.md)
- [`skills/agent-autonomous-loop/references/control-protocol.md`](skills/agent-autonomous-loop/references/control-protocol.md)
- [`skills/agent-autonomous-loop/references/worker-rules.md`](skills/agent-autonomous-loop/references/worker-rules.md)
- [`skills/agent-autonomous-loop/scripts/check_skill.sh`](skills/agent-autonomous-loop/scripts/check_skill.sh)

### `github-issue-development-plan`

Use when a GitHub issue URL or issue number should become an implementation
plan before any code changes.

Default prompt:

```text
Use $github-issue-development-plan to create an implementation plan from this GitHub issue.
```

Important files:

- [`skills/github-issue-development-plan/SKILL.md`](skills/github-issue-development-plan/SKILL.md)
- [`skills/github-issue-development-plan/references/issue-context.md`](skills/github-issue-development-plan/references/issue-context.md)
- [`skills/github-issue-development-plan/references/development-plan-handoff.md`](skills/github-issue-development-plan/references/development-plan-handoff.md)

### `github-pr-codex-review-monitor`

Use when a PR needs a live monitor loop for ChatGPT Codex Connector comments,
failing PR checks, fix commits, and follow-up `@codex review` requests. The loop
stops without claiming approval after 60 minutes of Connector silence.

Default prompt:

```text
Use $github-pr-codex-review-monitor to monitor this PR until Codex review feedback and required checks are clear, or stop after 60 minutes of Connector silence without claiming approval.
```

Important files:

- [`skills/github-pr-codex-review-monitor/SKILL.md`](skills/github-pr-codex-review-monitor/SKILL.md)
- [`skills/github-pr-codex-review-monitor/references/pr-state-and-checks.md`](skills/github-pr-codex-review-monitor/references/pr-state-and-checks.md)
- [`skills/github-pr-codex-review-monitor/references/fix-validate-review.md`](skills/github-pr-codex-review-monitor/references/fix-validate-review.md)
- [`skills/github-pr-codex-review-monitor/scripts/check_skill.sh`](skills/github-pr-codex-review-monitor/scripts/check_skill.sh)

### `docs-feature-write`

Use when a finished or in-progress feature needs durable docs for humans and
agents, routed by domain and written under `docs/ai/`.

Default prompt:

```text
Use $docs-feature-write to write durable, domain-structured docs for this feature under docs/ai/.
```

Important files:

- [`skills/docs-feature-write/SKILL.md`](skills/docs-feature-write/SKILL.md)
- [`skills/docs-feature-write/references/doc-model.md`](skills/docs-feature-write/references/doc-model.md)
- [`skills/docs-feature-write/references/feature-doc-template.md`](skills/docs-feature-write/references/feature-doc-template.md)
- [`skills/docs-feature-write/scripts/check_docs.sh`](skills/docs-feature-write/scripts/check_docs.sh)

### `docs-feature-collect`

Use when documentation should start from a tracker item, change request, or PR,
collecting evidence read-only before handing off to `docs-feature-write`.

Default prompt:

```text
Use $docs-feature-collect to document a shipped feature from its tracker item and change requests.
```

Important files:

- [`skills/docs-feature-collect/SKILL.md`](skills/docs-feature-collect/SKILL.md)
- [`skills/docs-feature-collect/references/evidence-collection.md`](skills/docs-feature-collect/references/evidence-collection.md)
- [`skills/docs-feature-collect/references/docs-feature-write-handoff.md`](skills/docs-feature-collect/references/docs-feature-write-handoff.md)

### `docs-feature-style`

Use when documentation markdown needs style and structure normalization, with or
without Vale and markdownlint installed.

Default prompt:

```text
Use $docs-feature-style to normalize the style and structure of these docs.
```

Important files:

- [`skills/docs-feature-style/SKILL.md`](skills/docs-feature-style/SKILL.md)
- [`skills/docs-feature-style/references/style-rules.md`](skills/docs-feature-style/references/style-rules.md)
- [`skills/docs-feature-style/references/tooling.md`](skills/docs-feature-style/references/tooling.md)

### Apple development / `swift6-migration`

Use when an Xcode, Tuist, XcodeGen, or SwiftPM project needs a target-aware,
dependency-aware migration to Swift 6 language mode and strict concurrency.

Default prompt:

```text
Use $swift6-migration to assess this Apple-platform project and create a staged, verifiable Swift 6 migration plan.
```

Important files:

- [`skills/apple-development/swift6-migration/SKILL.md`](skills/apple-development/swift6-migration/SKILL.md)
- [`skills/apple-development/swift6-migration/references/methodology.md`](skills/apple-development/swift6-migration/references/methodology.md)
- [`skills/apple-development/swift6-migration/references/conversion-guide.md`](skills/apple-development/swift6-migration/references/conversion-guide.md)
- [`skills/apple-development/swift6-migration/references/recipes.md`](skills/apple-development/swift6-migration/references/recipes.md)
- [`skills/apple-development/swift6-migration/scripts/check_skill.sh`](skills/apple-development/swift6-migration/scripts/check_skill.sh)

## Maintenance Notes

- Keep `SKILL.md` concise and move detailed procedures into one-level
  `references/` files.
- Place broad skills directly under `skills/`. Use one category directory for
  domain collections such as `skills/apple-development/`; skill names must stay
  unique because installation destinations are flat.
- Keep skills project-agnostic: avoid hard-coded repository names, app names,
  branch names, and product-specific paths.
- Keep runtime state out of this repository. For example,
  `agent-autonomous-loop` writes handoff state under `.agent-autonomous-loop/`
  in the active project, not in this skill library.
- Validate changed skills with the validator for your agent runtime:

```bash
python3 /path/to/skill-creator/scripts/quick_validate.py skills/development-plan
```

Run the same command for each edited skill folder.
