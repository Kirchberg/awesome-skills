# Style Rules

These rules are defaults and examples. Adapt per project; do not impose example
terminology on a project that has its own conventions.

## Terminology

- Maintain a project vocabulary of preferred and discouraged terms.
- Replace discouraged terms with preferred ones (configurable; see the Vale
  vocabulary asset for the format).

## Typography (configurable examples)

- Normalize dash usage to the project's convention (for example, avoid stray
  em dashes where the project prefers hyphens).
- Normalize homoglyphs where the project requires it (for example, replacing a
  given letter with its standard counterpart). Treat these as opt-in examples.
- Use straight or curly quotes consistently per project preference.

## Structure

- Exactly one level-1 heading per document.
- Headings increment by one level at a time; no skipped levels.
- Consistent heading style (ATX `#`).
- Unordered list items use a single bullet style, `-` by default
  (configurable; see the `.markdownlint.jsonc` MD004 asset).
- One blank line around headings, lists, and fenced code blocks.
- Trim trailing whitespace; end files with a single newline.

## Application Order

1. Structure fixes first (headings, spacing).
2. Terminology replacements.
3. Typography normalization.

Apply the minimal change that satisfies the rule. Preserve meaning and code
samples exactly.
