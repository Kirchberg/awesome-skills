# Issue Context

## Issue Context To Gather

Collect enough issue evidence to plan from the real request, not from the title
alone.

- Issue URL, number, title, state, author, labels, assignees, milestone, created
  and updated dates.
- Full issue body.
- Relevant comments, especially maintainer clarifications, acceptance criteria,
  design decisions, reproduction steps, screenshots, logs, or linked references.
- Linked pull requests, commits, discussions, docs, or related issues when
  visible and relevant.
- Explicit requirements, non-goals, constraints, rollout notes, and acceptance
  criteria.
- Reported symptoms, reproduction steps, expected behavior, actual behavior,
  affected platforms, and environment details for bugs.
- Migration or refactor boundaries, compatibility requirements, and rollback
  expectations.

When issue comments conflict, prefer the newest maintainer-authored
clarification. If authority is unclear, state the conflict as an open question
instead of choosing silently.

## Repository Context To Inspect

After resolving the issue, inspect the repository context needed to turn the
issue into an implementation plan. Stay read-only.

At minimum, inspect:

- `AGENTS.md` and relevant nested `AGENTS.md` or equivalent local instructions.
- `README.md`.
- Relevant docs indexes, architecture notes, contracts, operations docs, ADRs,
  or testing docs.
- Package, build, CI, and test configuration relevant to the issue.
- Source modules, routes, services, models, components, jobs, migrations,
  scripts, or tests named or strongly implied by the issue.

Use repository context to infer likely files, commands, test layers, risks, and
implementation order. If a file or command is unknown, say so instead of
inventing it.

## Normalized Planning Brief

Before using `development-plan`, create a concise internal brief from the issue:

- Source issue: URL, title, state, labels.
- Intent: what should change and why.
- User or system impact.
- Requirements explicitly stated in the issue.
- Acceptance criteria explicitly stated or safely inferred.
- Out-of-scope items and non-goals.
- Relevant repo areas and likely files/modules.
- Verification hints from the issue and repository.
- Parallelizable investigation tracks, if the issue spans independent domains.
- Risks, edge cases, migration concerns, compatibility concerns, or failure
  modes.
- Assumptions and open questions, max 3.

Distinguish issue facts from agent assumptions. Do not present guesses as issue
requirements.

## Subagent Analysis

Use subagents for issue planning only when the issue has two or more independent
read-heavy tracks. Do not use subagents for small issues, single-file fixes, or
tightly coupled contract decisions.

Good issue-planning subagent tracks:

- Issue context reader: summarize the issue body, comments, linked PRs, and
  acceptance criteria.
- Backend mapper: inspect API models, controllers, services, jobs, migrations,
  tests, and backend docs implied by the issue.
- Frontend or client mapper: inspect UI models, services, screens, navigation,
  localization, analytics, and build implications implied by the issue.
- Verification mapper: identify targeted tests, builds, CI checks, smoke checks,
  and manual validation.
- Risk reviewer: identify migration, security, contract, rollout, and
  compatibility risks.

Each subagent should return only a concise summary with evidence, likely files,
commands, risks, and open questions. The parent agent owns the final normalized
brief and the final `development-plan` output.

When preparing the issue brief, include a subagent recommendation:

- `none` for small or tightly coupled issues.
- `read-only exploration` for independent repo areas.
- `parallel verification` when test/build/check discovery can run
  independently.
- `disjoint implementation slices` only as a later implementation
  recommendation, never as part of this read-only planning step.
