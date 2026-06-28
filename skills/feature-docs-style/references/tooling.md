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

Vale errors if no `.vale.ini` is found; it does not silently use a default.
Pick the first that applies:

- Project has its own `.vale.ini` — use it.
- No project config but you want the shipped starter — point Vale at the asset
  (its `StylesPath`/`Vocab` resolve relative to that file), or copy
  `assets/vale/` into the project first and adapt.
- Neither is acceptable — skip Vale and apply the manual rules from
  `references/style-rules.md`.

```bash
vale --config ./.vale.ini <files>                    # project config
vale --config <skill>/assets/vale/.vale.ini <files>  # shipped starter
```

Do not run `vale --config .vale.ini` assuming a project config exists.

## Running markdownlint

markdownlint runs with built-in defaults even without a config; pass `--config`
only when the file exists.

```bash
markdownlint --config ./.markdownlint.jsonc <files>                            # project config
markdownlint --config <skill>/assets/markdownlint/.markdownlint.jsonc <files>  # shipped starter
markdownlint <files>                                                           # built-in defaults
```

If you do not want to introduce a config, use defaults or skip to the manual
structure rules in `references/style-rules.md`.

## Manual Fallback

When a tool is absent, apply its rules by hand from `references/style-rules.md`:

- markdownlint -> structure rules (single H1, heading increments, spacing,
  trailing whitespace, final newline).
- Vale -> terminology and typography rules from the vocabulary.

Never block on a missing binary. Always report which path was used.
