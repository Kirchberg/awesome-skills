---
name: github-issue-development-plan
description: Use when a user asks to create a development implementation plan from a GitHub issue, issue URL, issue number, or issue discussion before writing code.
---

# GitHub Issue Development Plan

## Purpose

Turn a GitHub issue into a rigorous development implementation plan. This skill
is a read-only issue-context adapter: collect and normalize the issue facts
first, then use `development-plan` to produce the final executable plan.

**REQUIRED SUB-SKILL:** Use `development-plan` after the GitHub issue brief is
prepared.

## Operating Mode

Default to read-only planning mode.

- Use this skill only when the latest request is to plan from a GitHub issue,
  issue URL, issue number, or issue discussion. If the latest request is an
  execution task, local Git conflict, MCP setup, deploy, commit, push, or other
  non-issue action, do not create an issue-derived plan unless the user first
  asks to plan that work from an issue.
- Do not modify source files while creating the plan.
- Do not edit, comment on, label, close, assign, or otherwise mutate the GitHub
  issue.
- Do not produce implementation code unless the user explicitly asks for code.
- Ask follow-up questions only when the repository or issue cannot be resolved,
  or when a missing product or technical decision blocks responsible planning.
- Ask at most 1-3 blocking questions.
- If issue details are incomplete but planning can continue, state the
  assumption and continue.
- Write the final plan in the same language as the user's request.
- Consider subagents only for independent read-heavy issue analysis or
  verification planning; keep this skill read-only.

## Reference Routing

Read these one-level references before producing the final plan:

- `references/issue-context.md`: required after resolving the issue. It defines
  issue facts to collect, repository context to inspect, normalized brief shape,
  and read-only subagent guidance.
- `references/development-plan-handoff.md`: required before invoking
  `development-plan`. It defines how to map issue facts into a plan, common
  issue shapes, and pitfalls to avoid.

## Issue Resolution

Resolve the GitHub issue before planning.

1. If the user provides an issue URL, use that repository and issue number.
2. If the user provides only an issue number, infer the repository from local git
   remotes when possible.
3. If multiple remotes or repositories are plausible, ask for the repository.
4. If the issue cannot be accessed, report the attempted repository/issue lookup
   and ask for the missing access or issue content.

Prefer the GitHub app or connector for issue data when available. Use `gh` only
when the connector does not cover the needed issue fields.

Useful `gh` fallback:

```bash
gh issue view <number> \
  --repo <owner/repo> \
  --json number,title,body,state,author,labels,assignees,milestone,url,createdAt,updatedAt,closedAt,comments
```

## Workflow

1. Resolve the issue source and fetch full issue details.
2. Read `references/issue-context.md`.
3. Inspect the repository context implied by the issue while staying read-only.
4. Normalize the issue into a brief that separates issue facts from agent
   assumptions.
5. Read `references/development-plan-handoff.md`.
6. Read and apply `development-plan`.
7. Produce the final output as an implementation plan, not as an issue summary.

## Avoid

- Do not plan from the issue title alone when the body or comments are
  accessible.
- Do not treat every comment as a requirement; identify the source and authority
  of important decisions.
- Do not invent acceptance criteria, commands, files, or architecture details.
- Do not skip repository inspection when local context is available.
- Do not skip `development-plan`; this skill prepares the input, and
  `development-plan` produces the final plan.
- Do not mutate GitHub issue state during planning.
- Do not generate implementation code during planning unless explicitly
  requested.
- Do not let subagents write files, edit GitHub state, or make final planning
  decisions during issue-context gathering.
