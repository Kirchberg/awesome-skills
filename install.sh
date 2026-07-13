#!/usr/bin/env bash
set -euo pipefail

# install.sh — (re)install skills into the Claude and Codex skill directories
# in one command. Defaults to the docs-feature-* pack.
#
# Usage:
#   ./install.sh                          all docs-feature-* skills into both runtimes
#   ./install.sh <skill> [<skill>...]     only the named skills
#   ./install.sh --all                    every skill under skills/, including categories
#   ./install.sh --claude                 the Claude skills dir only
#   ./install.sh --codex                  the Codex skills dir only
#   ./install.sh -h | --help
#
# Destination dirs, resolved in this order:
#   Claude: CLAUDE_SKILLS_DIR, else ${CLAUDE_CONFIG_DIR:-~/.claude}/skills
#   Codex:  CODEX_SKILLS_DIR,  else ${CODEX_HOME:-~/.codex}/skills

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skills_src="$repo_root/skills"

claude_dir="${CLAUDE_SKILLS_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills}"
codex_dir="${CODEX_SKILLS_DIR:-${CODEX_HOME:-$HOME/.codex}/skills}"

fail() { echo "install failed: $*" >&2; exit 1; }

usage() {
  cat <<'USAGE'
install.sh — (re)install skills into Claude and Codex in one command.

Usage:
  ./install.sh                          all docs-feature-* skills into both runtimes
  ./install.sh <skill> [<skill>...]     only the named skills
  ./install.sh --all                    every skill under skills/, including categories
  ./install.sh --claude                 the Claude skills dir only
  ./install.sh --codex                  the Codex skills dir only
  ./install.sh -h | --help

Destinations (resolved in order):
  Claude: CLAUDE_SKILLS_DIR, else ${CLAUDE_CONFIG_DIR:-~/.claude}/skills
  Codex:  CODEX_SKILLS_DIR,  else ${CODEX_HOME:-~/.codex}/skills
USAGE
}

# Absolute, symlink-resolved path of an existing directory (empty if missing).
canonical_dir() {
  [ -d "$1" ] || return 0
  ( cd "$1" && pwd -P )
}

# Required sub-skills a skill declares in its SKILL.md, limited to names that are
# themselves installable skills under skills/. Matches whole tokens so that, for
# example, "docs-feature-write" is not found inside "docs-feature-write-handoff".
deps_of() {
  local sk="$1" reqlines toks name src
  src="$(source_for "$sk")"
  reqlines="$(grep -i 'REQUIRED SUB-SKILL' "$src/SKILL.md" 2>/dev/null || true)"
  [ -n "$reqlines" ] || return 0
  toks=" $(printf '%s' "$reqlines" | tr -c 'A-Za-z0-9-' ' ') "
  for name in "${avail[@]}"; do
    [ "$name" = "$sk" ] && continue
    case "$toks" in
      *" $name "*) echo "$name" ;;
    esac
  done
}

# Add every requested skill's required sub-skills to the install set so an
# adapter is never installed alone and left unable to complete its handoff.
# Runs to a fixpoint so transitive dependencies are covered too.
expand_required() {
  local changed=1 sk dep
  while [ "$changed" -eq 1 ]; do
    changed=0
    for sk in "${skills[@]}"; do
      for dep in $(deps_of "$sk"); do
        case " ${skills[*]} " in
          *" $dep "*) ;;
          *) skills+=("$dep")
             echo "including required sub-skill '$dep' (needed by '$sk')"
             changed=1 ;;
        esac
      done
    done
  done
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

# Installable skills may live directly under skills/ or one category deeper,
# for example skills/apple-development/swift6-migration/. Skill names must be
# unique because installation destinations are intentionally flat.
avail=()
avail_srcs=()
for d in "$skills_src"/*/ "$skills_src"/*/*/; do
  [ -f "$d/SKILL.md" ] || continue
  name="$(basename "$d")"
  if [ "${#avail[@]}" -gt 0 ]; then
    case " ${avail[*]} " in
      *" $name "*) fail "duplicate skill name '$name' under skills/" ;;
    esac
  fi
  avail+=("$name")
  avail_srcs+=("${d%/}")
done

source_for() {
  local requested="$1" i
  for i in "${!avail[@]}"; do
    if [ "${avail[$i]}" = "$requested" ]; then
      printf '%s\n' "${avail_srcs[$i]}"
      return 0
    fi
  done
  return 1
}

# Resolve the skill list when none were named.
if [ "${#skills[@]}" -eq 0 ]; then
  if [ "$install_all" -eq 1 ]; then
    skills=("${avail[@]}")
  else
    for d in "$skills_src"/docs-feature-*/; do
      [ -d "$d" ] && [ -f "$d/SKILL.md" ] && skills+=("$(basename "$d")")
    done
  fi
fi

[ "${#skills[@]}" -gt 0 ] || fail "no skills to install"

# Validate every requested skill exists before touching any destination.
for s in "${skills[@]}"; do
  source_for "$s" >/dev/null || fail "unknown skill '$s'"
done

# Pull in required sub-skills (e.g. an adapter's core) so a named install of an
# adapter stays able to complete its documented handoff workflow.
expand_required

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
    src="$(source_for "$s")"
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
