# awesome-skills

A reusable collection skills for AI-native engineering workflows ✨

This repository is a portable skill library. Each folder under `skills/` is an
installable agent skill that can be copied into a personal or project-local
skills directory.

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

## Repository Layout

```text
skills/
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
```

## Installation

Install one skill by copying its folder into your personal skills directory:

```bash
cp -R skills/development-plan "$SKILLS_HOME/development-plan"
```

Install into a specific project by copying the folder into that project's local
skills directory:

```bash
cp -R skills/development-plan /path/to/project/.agents/skills/development-plan
```

Repeat for each skill you want to use. Keep the folder name the same as the
`name:` field in `SKILL.md`.

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
failing PR checks, fix commits, and follow-up `@codex review` requests.

Default prompt:

```text
Use $github-pr-codex-review-monitor to monitor this PR until connector review feedback and required checks are clear.
```

Important files:

- [`skills/github-pr-codex-review-monitor/SKILL.md`](skills/github-pr-codex-review-monitor/SKILL.md)
- [`skills/github-pr-codex-review-monitor/references/pr-state-and-checks.md`](skills/github-pr-codex-review-monitor/references/pr-state-and-checks.md)
- [`skills/github-pr-codex-review-monitor/references/fix-validate-review.md`](skills/github-pr-codex-review-monitor/references/fix-validate-review.md)
- [`skills/github-pr-codex-review-monitor/scripts/check_skill.sh`](skills/github-pr-codex-review-monitor/scripts/check_skill.sh)

## Maintenance Notes

- Keep `SKILL.md` concise and move detailed procedures into one-level
  `references/` files.
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
