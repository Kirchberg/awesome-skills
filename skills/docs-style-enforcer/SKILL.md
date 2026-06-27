---
name: docs-style-enforcer
description: Use when documentation markdown needs style and structure normalization (terminology, typography, heading rules). Runs Vale and markdownlint when installed and applies the same rules manually when they are absent. Usable standalone or as the final step of feature-documentation.
---

# Docs Style Enforcer

## Purpose

Normalize documentation style and structure so authors can choose terminology
and typography without hard-coding rules into every workflow. Works on any
markdown, and is the optional final step of `feature-documentation`.

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
