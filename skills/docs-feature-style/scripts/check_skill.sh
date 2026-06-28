#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "docs-feature-style check failed: $*" >&2
  exit 1
}

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$skill_dir/SKILL.md"
style_ref="$skill_dir/references/style-rules.md"
tooling_ref="$skill_dir/references/tooling.md"
metadata="$skill_dir/agents/openai.yaml"
vale_cfg="$skill_dir/assets/vale/.vale.ini"
mdl_cfg="$skill_dir/assets/markdownlint/.markdownlint.jsonc"

test -f "$skill_file" || fail "SKILL.md is missing"
test -f "$style_ref" || fail "style-rules reference is missing"
test -f "$tooling_ref" || fail "tooling reference is missing"
test -f "$metadata" || fail "agents/openai.yaml is missing"
test -f "$vale_cfg" || fail "example Vale config is missing"
test -f "$mdl_cfg" || fail "example markdownlint config is missing"

lines="$(wc -l < "$skill_file" | tr -d ' ')"
if [[ "$lines" -gt 200 ]]; then
  fail "$skill_file has $lines lines; split details into references/"
fi

grep -q '^name: docs-feature-style$' "$skill_file" || fail "skill name changed"
grep -qi 'graceful degradation' "$skill_file" || fail "graceful degradation mode is missing"
grep -q 'markdownlint' "$skill_file" || fail "markdownlint handling is missing"
grep -qi 'vale' "$skill_file" || fail "vale handling is missing"
grep -q 'references/style-rules.md' "$skill_file" || fail "style-rules routing is missing"
grep -q 'references/tooling.md' "$skill_file" || fail "tooling routing is missing"
grep -q 'self-contained' "$skill_file" || fail "self-contained statement is missing"
grep -q 'allow_implicit_invocation: true' "$metadata" || fail "implicit invocation policy is missing"

echo "docs-feature-style check passed"
