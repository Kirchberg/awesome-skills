# Fix, Validate, And Request Review

## Applying Suggestions And Check Fixes

For each unprocessed actionable suggestion:

1. Read the full suggestion.
2. Identify the affected file, function, class, test, behavior, or API.
3. Inspect relevant local code before editing.
4. Determine the minimal correct fix.
5. Apply the fix in the working tree.
6. Prefer robust implementation over mechanical text replacement.
7. Apply exact GitHub suggested-change patches only when still valid and
   contextually correct.
8. If stale, verify whether the issue is already fixed.
9. If already fixed, mark the suggestion processed without an unnecessary
   commit.
10. If invalid or unsafe, document why it was skipped and continue.

Handle all actionable suggestions from the current connector batch before
requesting another review.

For each actionable failing check:

1. Read the failing check summary and logs.
2. Identify whether the failure is caused by branch code, tests, configuration,
   dependencies, or CI workflow changes.
3. Reproduce locally when the command is available and not prohibitively
   expensive.
4. Apply the smallest safe fix.
5. Re-run the relevant local command.
6. Mark the failure processed only after the fix is committed and pushed, or
   after evidence shows it is external, flaky, unrelated, or already fixed.
7. If a check is flaky and GitHub supports rerun, rerun it at most once with
   `gh run rerun <run_id>` after confirming no code fix is indicated.

Handle actionable failing checks in the same batch as connector suggestions. If
both touch the same files, integrate fixes before validation and prefer one
coherent commit.

## Validation

Infer relevant validation from the repository:

- JavaScript/TypeScript: `package.json`, lockfiles, package manager test/lint
  scripts.
- Python: `pyproject.toml`, `requirements.txt`, `tox.ini`, `pytest.ini`,
  `pytest`.
- Ruby: `Gemfile`, `bundle exec rspec`, `bin/rails test`.
- Go: `go.mod`, `go test ./...`.
- Rust: `Cargo.toml`, `cargo test`.
- Java/Kotlin: `pom.xml`, `build.gradle`, `gradlew`.
- Make-based projects: inspect `Makefile`.

Run targeted checks first, then broader checks when practical. Treat failing PR
checks as validation failures for the current branch. If local validation or
current-head PR checks fail because of applied changes, fix them before
requesting another connector review. If failures are pre-existing, external, flaky,
or unrelated, report that clearly and commit only when the applied fix is safe.

## Git Workflow

Before committing:

```bash
git diff
git diff --cached
```

Commit behavior:

- Prefer one clear commit for one coherent connector review batch.
- Use separate commits only when suggestions are unrelated and large.
- Use concise commit messages such as `fix: address connector review suggestions`.

After committing:

```bash
git push
PR_NUMBER="$(gh pr view --json number --jq .number)"
gh pr checks "$PR_NUMBER" --json name,workflow,state,bucket,conclusion,startedAt,completedAt,detailsUrl,link
gh pr comment "$PR_NUMBER" --body "@codex review"
```

Post `@codex review` only after a fix commit has been pushed. If checks are
running, keep monitoring. If checks fail again for a fixable branch reason, fix
them before requesting another review.

## Subagent Strategy

Use subagents when at least two independent read-heavy tracks exist. Keep the
parent focused on state, decisions, edits, validation, commits, pushes, and
review requests.

Recommended read-only roles:

- `pr_explorer`: changed files, ownership, affected code paths, blast radius.
- `review_triage`: group connector comments into actionable, stale, duplicate,
  unsafe, and already-fixed items.
- `ci_investigator`: inspect failing checks, logs, commands, and likely local
  reproduction commands.
- `docs_or_contract_reviewer`: verify framework/API/docs assumptions or
  cross-platform contract implications.
- `verification_reviewer`: recommend smallest local and remote checks.

Use disjoint implementation subagents only when slices are independent, file
scopes do not overlap, the parent can integrate and verify, and no subagent will
push, comment, request review, or resolve GitHub threads.

Subagent outputs must be concise and evidence-backed: affected files, finding
summary, recommended fix/check, confidence, and blockers. Avoid raw logs unless
the parent needs exact error text.

## Iteration Output

For each loop iteration, print a concise status containing timestamp, PR number
and URL, current branch, terminal-success status, new connector suggestions,
failing/pending/passing checks for the current head, failing check names and
commands when known, subagents used, files changed, validation commands, commit
SHA if committed, whether `@codex review` was posted, heartbeat status when
used, and next check time.

Avoid raw API dumps unless debugging requires them.

## Error Handling

- If GitHub authentication fails, report it and stop safely.
- If API rate limits occur, report the reset time, wait when available, then
  continue.
- If the PR cannot be found, report repository, branch, and attempted lookup.
- If merge conflicts, ambiguous suggestions, or failing tests/checks block
  progress, leave the working tree recoverable, report the blocker, and do not
  request another review.
- If one connector suggestion or failing check is unsafe, invalid, external,
  flaky, or unrelated, skip it with a reason, continue processing other valid
  items, and request another review only if at least one fix was committed and
  pushed.

## Invocation Prompts

Current PR:

```text
Monitor the current GitHub Pull Request for ChatGPT Codex Connector review feedback.

Every 10 minutes, check the PR for new automated review suggestions from `chatgpt-codex-connector` and for failing PR checks on the current head commit. Apply all actionable suggestions and immediately fix actionable failing checks, validate the changes, commit and push them to the PR branch, then comment `@codex review` from my GitHub account. Use a current-thread heartbeat automation for the wait cadence when available. Keep the current agent session alive and continue monitoring until the connector reports that it did not find any major issues and required/current PR checks pass.
```

Specific PR:

```text
Use the GitHub PR review monitor skill for this PR:

<PR_URL>

Stay in the current session. Check every 10 minutes. Use a current-thread heartbeat automation for the wait cadence when available. Process every actionable review suggestion from the ChatGPT Codex Connector GitHub App and every actionable failing PR check on the current head commit, commit and push fixes, then comment `@codex review`. Continue until the app posts a terminal success message equivalent to "no major issues found" and required/current PR checks pass.
```
