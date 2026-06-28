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

# Absolute, symlink-resolved path of an existing directory (empty if missing).
canonical_dir() {
  [ -d "$1" ] || return 0
  ( cd "$1" && pwd -P )
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

src_root="$(canonical_dir "$skills_src")"

# Clean up an in-progress staging dir if the script is interrupted.
staging=""
cleanup() { [ -n "$staging" ] && rm -rf "$staging" 2>/dev/null || true; }
trap cleanup EXIT

rc=0
for dest in "${dests[@]}"; do
  mkdir -p "$dest"
  # Never install onto the repository's own skills/ tree (also catches a
  # destination that is a symlink to it) — that would delete the source.
  if [ "$(canonical_dir "$dest")" = "$src_root" ]; then
    fail "destination '$dest' is this repository's skills/ directory; refusing to install onto the source"
  fi
  echo "==> $dest"

  # Phase 1: swap every requested skill into place BEFORE validating any, so
  # cross-skill checks (e.g. the collect schema compared against the sibling
  # write copy) see the fully refreshed pack, not a half-updated tree.
  installed=()
  for s in "${skills[@]}"; do
    src="$skills_src/$s"
    dst="$dest/$s"
    # If the destination already IS the source (e.g. a symlink back to the
    # repo), leave it untouched instead of deleting the source.
    if [ -e "$dst" ] && [ "$(canonical_dir "$dst")" = "$(canonical_dir "$src")" ]; then
      echo "    skip $s (destination is the source)"
      continue
    fi
    # Copy into a staging dir first, then swap into place. The source is only
    # ever read from; the removal below can only ever target an existing
    # install under $dest, never the repository source.
    staging="$(mktemp -d "$dest/.dfinstall.XXXXXX")"
    cp -R "$src" "$staging/$s"
    rm -rf "$dst"
    mv "$staging/$s" "$dst"
    rm -rf "$staging"; staging=""
    echo "    installed $s"
    installed+=("$s")
  done

  # Phase 2: validate once the whole requested set has been refreshed.
  if [ "${#installed[@]}" -gt 0 ]; then
    for s in "${installed[@]}"; do
      [ -f "$dest/$s/scripts/check_skill.sh" ] || continue
      if bash "$dest/$s/scripts/check_skill.sh" >/dev/null 2>&1; then
        echo "    check $s: ok"
      else
        echo "    check $s: FAILED" >&2
        rc=1
      fi
    done
  fi
done

if [ "$rc" -ne 0 ]; then
  echo "One or more skills failed their post-install check." >&2
  exit 1
fi

echo "Done. Restart your Claude/Codex session to pick up changes."
