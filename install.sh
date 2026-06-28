#!/usr/bin/env bash
set -euo pipefail

# install.sh — (re)install skills into the Claude and Codex skill directories
# in one command. Defaults to the docs-feature-* pack.
#
# Usage:
#   ./install.sh                          all docs-feature-* skills into both runtimes
#   ./install.sh <skill> [<skill>...]     only the named skills
#   ./install.sh --all                    every skill under skills/
#   ./install.sh --claude                 the Claude skills dir only
#   ./install.sh --codex                  the Codex skills dir only
#   ./install.sh -h | --help
#
# Destination dirs (override with env vars):
#   CLAUDE_SKILLS_DIR   (default ~/.claude/skills)
#   CODEX_SKILLS_DIR    (default ~/.codex/skills)

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skills_src="$repo_root/skills"

claude_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
codex_dir="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"

fail() { echo "install failed: $*" >&2; exit 1; }

usage() {
  cat <<'USAGE'
install.sh — (re)install skills into Claude and Codex in one command.

Usage:
  ./install.sh                          all docs-feature-* skills into both runtimes
  ./install.sh <skill> [<skill>...]     only the named skills
  ./install.sh --all                    every skill under skills/
  ./install.sh --claude                 the Claude skills dir only
  ./install.sh --codex                  the Codex skills dir only
  ./install.sh -h | --help

Destinations (override with env vars):
  CLAUDE_SKILLS_DIR   (default ~/.claude/skills)
  CODEX_SKILLS_DIR    (default ~/.codex/skills)
USAGE
}

want_claude=1
want_codex=1
install_all=0
skills=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --claude) want_codex=0 ;;
    --codex)  want_claude=0 ;;
    --all)    install_all=1 ;;
    -h|--help) usage; exit 0 ;;
    --*) fail "unknown option: $1 (try --help)" ;;
    *) skills+=("$1") ;;
  esac
  shift
done

test -d "$skills_src" || fail "skills/ not found at $skills_src"

# Resolve the skill list when none were named.
if [ "${#skills[@]}" -eq 0 ]; then
  if [ "$install_all" -eq 1 ]; then
    for d in "$skills_src"/*/; do
      [ -f "$d/SKILL.md" ] && skills+=("$(basename "$d")")
    done
  else
    for d in "$skills_src"/docs-feature-*/; do
      [ -d "$d" ] && [ -f "$d/SKILL.md" ] && skills+=("$(basename "$d")")
    done
  fi
fi

[ "${#skills[@]}" -gt 0 ] || fail "no skills to install"

# Validate every requested skill exists before touching any destination.
for s in "${skills[@]}"; do
  test -f "$skills_src/$s/SKILL.md" || fail "unknown skill '$s' (no skills/$s/SKILL.md)"
done

dests=()
[ "$want_claude" -eq 1 ] && dests+=("$claude_dir")
[ "$want_codex" -eq 1 ] && dests+=("$codex_dir")
[ "${#dests[@]}" -gt 0 ] || fail "no destination selected"

rc=0
for dest in "${dests[@]}"; do
  mkdir -p "$dest"
  echo "==> $dest"
  for s in "${skills[@]}"; do
    rm -rf "$dest/$s"
    cp -R "$skills_src/$s" "$dest/$s"
    line="    installed $s"
    if [ -f "$dest/$s/scripts/check_skill.sh" ]; then
      if bash "$dest/$s/scripts/check_skill.sh" >/dev/null 2>&1; then
        line="$line  (check_skill: ok)"
      else
        line="$line  (check_skill: FAILED)"
        rc=1
      fi
    fi
    echo "$line"
  done
done

if [ "$rc" -ne 0 ]; then
  echo "One or more skills failed their post-install check." >&2
  exit 1
fi

echo "Done. Restart your Claude/Codex session to pick up changes."
