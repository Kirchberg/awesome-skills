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
