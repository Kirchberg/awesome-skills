# Migration state

## Contents

- [Location](#location)
- [Write discipline](#write-discipline)
- [Schema](#schema)
- [Statuses](#statuses)
- [Unsafe sites](#unsafe-sites)
- [API changes](#api-changes)
- [Blockers](#blockers)
- [Recovery](#recovery)
- [Final reports](#final-reports)

## Location

Use this default unless repository policy defines another safe location:

```text
<workspace-root>/.swift6-migration/<task-id>/migration-state.json
```

Related artifacts:

```text
MIGRATION_REPORT.md
SWIFT6_FOLLOW_UPS.md
logs/<target-id>/<check-id>.log
```

Do not store source copies, credentials, generated environment files, build output, or IDE user data.

## Write discipline

Use one coordinator as the only state writer. Write atomically:

1. Serialize the complete next state to `migration-state.json.tmp`.
2. Parse and validate the temporary JSON.
3. Rename it over `migration-state.json`.

Do not patch JSON fragments concurrently. Read-only workers may return findings to the coordinator but must not mutate the shared state file.

## Schema

```json
{
  "schema_version": 1,
  "task_id": "MIGRATION-123",
  "workspace_root": "/path/to/project",
  "vcs": {
    "kind": "git",
    "branch": "feature/swift6-migration",
    "starting_revision": "full-revision",
    "dirty_at_start": false
  },
  "toolchain": {
    "xcode": "16.x",
    "swift": "6.x",
    "generator": "tuist",
    "generator_version": "x.y.z"
  },
  "scope": {
    "kind": "project",
    "roots": ["."],
    "excluded": ["Vendor", "Generated"],
    "platforms": ["iOS", "macOS"],
    "configurations": ["Debug", "Release"],
    "variants": []
  },
  "configuration_sources": [
    {
      "id": "library-settings",
      "file": "Build/Settings.swift",
      "symbol": "librarySettings",
      "targets": ["Core", "Networking"]
    }
  ],
  "targets": [
    {
      "id": "Core",
      "product": "framework",
      "manifest": "Core/Project.swift",
      "configuration_source": "library-settings",
      "language_mode_before": "5",
      "language_mode_target": "6",
      "dependencies": [],
      "consumers": ["App"],
      "external_consumers": [],
      "scheme": "Core",
      "tests": ["CoreTests"],
      "platforms": ["iOS", "macOS"],
      "configurations": ["Debug", "Release"],
      "variants": [],
      "status": "baseline_passed",
      "baseline": {
        "checks": ["core-build", "core-tests"],
        "known_failures": []
      },
      "verification": {
        "checks": [],
        "last_success_at": null
      },
      "api_changes": [],
      "unsafe_sites": [],
      "blockers": []
    }
  ],
  "stages": [
    {
      "id": 1,
      "targets": ["Core", "CoreTests"],
      "reason": "production target and tests share configuration",
      "status": "planned",
      "checks": ["core-build", "core-tests", "app-build"]
    }
  ],
  "checks": {
    "core-build": {
      "command": "xcodebuild ...",
      "cwd": "/path/to/project",
      "status": "passed",
      "exit_code": 0,
      "finished_at": "2026-01-01T10:00:00Z",
      "log": "logs/Core/core-build.log"
    }
  },
  "cursor": {
    "phase": "migration",
    "stage": 1,
    "target": "Core",
    "next_action": "enable Swift 6 in library-settings"
  },
  "blockers": [],
  "updated_at": "2026-01-01T10:00:00Z"
}
```

Use paths relative to `workspace_root` wherever practical. Never embed tokens, credentials, or raw logs in state.

## Statuses

Allowed target statuses:

- `discovered`
- `already_swift6`
- `baseline_running`
- `baseline_passed`
- `in_progress`
- `swift6_build_passed`
- `verified`
- `done`
- `blocked`
- `excluded`

Normal transitions:

```text
discovered -> baseline_running -> baseline_passed -> in_progress
in_progress -> swift6_build_passed -> verified -> done
already_swift6 -> verified -> done
any unfinished status -> blocked
blocked -> in_progress after new evidence or input
```

`done` requires every selected integration check, not just a local target build.

Allowed stage statuses:

- `planned`
- `baseline_running`
- `in_progress`
- `verification_running`
- `done`
- `blocked`

Allowed check statuses:

- `planned`
- `running`
- `passed`
- `failed`
- `blocked`
- `not_run`

Never interpret `not_run` as success. Convert interrupted `running` checks to `not_run` or `failed` during recovery after inspecting evidence.

## Unsafe sites

Each `unsafe_sites` entry must include:

```json
{
  "kind": "unchecked-sendable",
  "file": "Sources/Cache.swift",
  "symbol": "Cache",
  "line": 12,
  "reason": "One lock guards all storage access",
  "synchronization": "Cache.lock",
  "verification": "CacheConcurrencyTests",
  "removal_plan": "Replace with an actor after API migration",
  "owner": "issue-or-owner"
}
```

Allowed kinds:

- `unchecked-sendable`
- `nonisolated-unsafe`
- `preconcurrency-import`
- `preconcurrency-api`
- `assume-isolated`

Missing synchronization evidence or removal ownership is a blocker, not a documentation detail.

## API changes

Record every public change to:

- global-actor isolation;
- `Sendable` constraints or conformances;
- `@Sendable` closure parameters;
- `async` or `throws` behavior;
- protocol requirements and conformances;
- existential spelling when it affects supported language modes;
- callback executor, ordering, multiplicity, or cancellation guarantees.

Each entry should identify the symbol, old contract, new contract, known consumers, compatibility assessment, and verification.

## Blockers

Use this shape:

```json
{
  "id": "BLOCK-1",
  "target": "Networking",
  "kind": "external-dependency",
  "summary": "Dependency lacks compatible concurrency annotations",
  "evidence": "logs/Networking/networking-build.log",
  "required_input": "Upgrade decision or compatibility adapter",
  "owner": "issue-or-owner",
  "next_action": "evaluate the latest compatible release"
}
```

Do not mark a target `done` while it has unresolved blockers.

## Recovery

When resuming:

1. Validate JSON and `schema_version`.
2. Confirm workspace root and source paths exist.
3. Confirm branch and starting revision are compatible with the state.
4. Compare the current diff with recorded work.
5. Confirm toolchain versions.
6. Inspect any check left `running`.
7. Re-run the latest narrow passing check if relevant files changed.
8. Continue from `cursor.next_action`.

If state disagrees with source, trust reproducible source and build evidence, repair state explicitly, and record the recovery decision.

## Final reports

`MIGRATION_REPORT.md` should contain:

- scope, exclusions, and toolchain;
- migrated targets and configuration sources;
- baseline and final verification matrices;
- API changes and consumer evidence;
- unsafe sites and their justification;
- blockers and unresolved compatibility decisions;
- generated-file and secret checks.

`SWIFT6_FOLLOW_UPS.md` should contain only remaining work with an owner or issue, reason, affected targets, required validation, and removal condition. Do not use it to hide incomplete in-scope verification.
