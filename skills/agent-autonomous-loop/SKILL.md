---
name: agent-autonomous-loop
description: Use only when the user explicitly invokes $agent-autonomous-loop or explicitly says to use the agent autonomous loop skill. Runs a bounded multi-round handoff/subagent loop for well-scoped implementation, refactor, documentation, review-fix, or verification tasks. Do not use implicitly, for ordinary tasks, Q&A, brainstorming, or every session.
---

# Agent Autonomous Loop

Use this skill for an explicit, bounded agent autonomous loop execution mode.
It adapts the useful parts of handoff-driven autonomy loops without installing,
vendoring, or automatically running a separate agent framework.

## Scope Gate

Use this skill only when the latest user message explicitly invokes
`$agent-autonomous-loop` or says to use the agent autonomous loop skill.

Do not use this skill for:

- normal implementation requests that do not explicitly ask for this skill;
- Q&A, brainstorming, explanations, or one-off research;
- UI work that needs human visual feedback between iterations;
- deploys, secret handling, production data mutation, or destructive work
  unless the user explicitly authorized that operation;
- vague tasks without a durable target, plan file, issue, spec, or acceptance
  criteria.

If the task is unsuitable, say why and continue in normal agent mode only if the
user's request still has a safe non-autonomous path.

## Required Read Order

1. Read the repository's applicable `AGENTS.md` or equivalent instructions.
2. Read `development-plan` for medium/large work when that skill is installed
   or available.
3. Read `references/control-protocol.md`.
4. Read `references/worker-rules.md` before creating or prompting any worker.

## Operating Defaults

- Default rounds: 4.
- Maximum rounds without a new user instruction: 6.
- Runtime handoff and KB path: `.agent-autonomous-loop/`.
- Runtime files are local state and must not be committed.
- Do not create commits unless the user explicitly asks for commits.
- Keep the parent agent as orchestrator. Worker subagents own implementation
  inside their assigned round.

## Subagent Requirement

Use available multi-agent tooling for clean-room rounds. If the needed subagent
tool is not already available, use `tool_search` to discover
multi-agent/subagent tools when available.

If no supported subagent tooling is available, stop and report the blocker. Do
not pretend that same-thread work is a clean-room autonomy loop unless the user
explicitly approves degraded same-thread execution.

## Safety Rules

- Preserve all user and pre-existing dirty worktree changes.
- Keep repository `AGENTS.md` files, local instructions, and project skills
  authoritative.
- For medium/large execution, ensure a saved plan exists before source edits;
  follow the repository's planning convention, or use `docs/plans/active/` when
  no convention exists.
- Keep any active saved plan current when the task uses one.
- Run the narrowest verification that proves the touched area.
- Final user reports must include rounds run, final state, changed files, checks
  run, and any blockers or follow-ups.

## Validation

When editing this skill, run:

```bash
bash skills/agent-autonomous-loop/scripts/check_skill.sh
```
