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
