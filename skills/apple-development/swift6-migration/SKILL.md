---
name: swift6-migration
description: Use when auditing, planning, executing, or resuming a staged migration of an Apple-platform Swift project, workspace, package, subsystem, or set of build targets to Swift 6 language mode and strict concurrency. Applies to Xcode, Tuist, XcodeGen, and SwiftPM projects. Trigger for requests such as "migrate this project to Swift 6", "enable Swift 6 for these targets", "continue the concurrency migration", or "assess Swift 6 readiness". Do not use for an isolated compiler diagnostic that does not require target inventory, dependency ordering, staged verification, or migration state.
---

# Migrate a Swift project to Swift 6

## Outcome

Move the selected build targets to Swift 6 without hiding concurrency defects or changing behavior unintentionally.

Treat a **build target** as the unit of migration. A project or package may contain applications, extensions, libraries, executables, test bundles, macros, and plugins with different language modes.

A target is complete only when it:

- compiles in Swift 6 language mode;
- passes its assigned tests and consumer checks;
- has no unexplained `@unchecked Sendable`, `nonisolated(unsafe)`, `@preconcurrency`, or dynamic isolation escape hatches;
- is recorded in the migration state and final report.

## Read references selectively

- Read `references/methodology.md` before inventorying or planning stages.
- Read `references/tooling.md` before changing manifests, build settings, or verification commands.
- Read `references/conversion-guide.md` before changing Swift source code.
- Read `references/recipes.md` before adding an unsafe annotation, compatibility boundary, or dynamic isolation assertion.
- Read `references/state-schema.md` before creating or resuming migration state.

Repository instructions and supported project commands override generic command examples, but they must not weaken correctness evidence or concurrency-safety requirements.

## Establish scope

Classify the request as one of:

- **Entire project**: all first-party Swift targets in the selected repository or workspace.
- **Area**: a product, subsystem, directory, package, or workspace.
- **Explicit targets**: targets or manifests named by the user.
- **Readiness audit**: inventory and plan only; do not edit source files.

Do not include neighboring repositories, third-party SDK sources, package-manager caches, generated code, generated projects, secrets, IDE user data, or build artifacts unless the task explicitly requires them.

Record:

- supported platforms, configurations, and product variants;
- Xcode, Swift, generator, and package-tools versions;
- compatibility requirements for older Swift toolchains;
- whether public API changes are allowed;
- which version-control actions the user authorized.

A migration request does not imply permission to commit, push, or open a pull request.

## Start safely

1. Read the repository's root and nearest local agent instructions.
2. Inspect version-control status. A clean default-branch checkout is allowed for a read-only readiness audit; require a non-default branch before source edits or version-control actions. Stop on an unrelated dirty worktree.
3. Resume from existing state only after validating it against `references/state-schema.md`.
4. Inventory targets, language modes, configuration sources, dependencies, consumers, schemes, test plans, platforms, and variants without editing files.
5. Identify settings shared by multiple targets before changing any shared helper or configuration file.
6. Run representative baseline builds and tests.
7. Present a staged plan and obtain confirmation before source changes.

## Inventory each target

For every target, record:

- target name, product type, manifest, and source root;
- current language mode and intended target mode;
- the authoritative build-setting source;
- dependencies, direct consumers, and external consumers;
- scheme, tests, platforms, configurations, and variants;
- public API exposure;
- current migration status and blockers.

Find the real source of `SWIFT_VERSION` or the SwiftPM language mode. Do not edit generated `.xcodeproj` files when a manifest, `.xcconfig`, generator helper, or package manifest owns the setting.

Never change a shared setting for one target until all inheriting targets are known. Switch a shared setting only when the entire affected group belongs to the current stage and has a passing baseline.

## Present the plan

Include:

- scope and exclusions;
- toolchain versions;
- counts of migrated, pending, excluded, and blocked targets;
- groups that share a configuration source;
- dependency-aware stages and the reason for their order;
- baseline and final verification matrices;
- configuration files expected to change;
- public API and compatibility constraints;
- migration-state path;
- separately listed version-control actions, if requested.

Prefer the smallest semantically correct change. Treat architectural redesign as a separate decision, not an automatic part of compiler migration.

## Execute one stage at a time

1. Read the current migration state.
2. Run the stage baseline build and tests.
3. Enable the intended language mode through the authoritative setting.
4. Group diagnostics by root cause and fix them using `references/conversion-guide.md`.
5. Build the target, then its nearest representative consumer.
6. Run target tests and affected contract or integration tests.
7. Inspect public API changes and all known consumers structurally.
8. Record checks, API changes, unsafe sites, and blockers.
9. Continue only after the stage integration gate passes.

Make source edits sequentially in one worktree by default. Parallelize read-only inventory where useful. Parallel source edits require isolated worktrees, non-overlapping ownership, and an agreed integration strategy.

## Configure the compiler correctly

- In Swift 5 mode, use `SWIFT_STRICT_CONCURRENCY = complete` or `-strict-concurrency=complete` as a diagnostic preparation step.
- In Xcode projects, use `SWIFT_VERSION = 6` for Swift 6 language mode.
- In SwiftPM, use APIs supported by the manifest's `swift-tools-version`; tools version 6.0 defaults targets to Swift 6 unless overridden.
- Record default actor isolation and enabled upcoming features separately from the language mode. Do not enable them as an unreviewed side effect of migration.
- Do not invent `.enableExperimentalFeature("StrictConcurrency=complete")`.
- Do not raise `swift-tools-version` without treating the dropped toolchain support as an explicit compatibility change.

Swift 6 language mode already enables complete concurrency checking. A retained strict-concurrency setting may document intent, but it is not separate completion evidence.

## Apply safety rules

- Model actual isolation: UI state usually belongs to `MainActor`; shared mutable state belongs to an actor or a documented synchronization primitive.
- Add `Sendable` only when stored state and public operations satisfy it.
- Use `@unchecked Sendable` only with a reviewable synchronization invariant, focused tests, an owner, and a removal plan.
- Use `nonisolated(unsafe)` only when named external synchronization protects the access.
- Treat `@preconcurrency` as a temporary compatibility boundary, not proof of thread safety.
- Use `MainActor.assumeIsolated` only at a synchronous boundary whose executor guarantee is externally proven and documented.
- Do not add or remove `@MainActor` merely to silence diagnostics.
- Do not convert callback APIs to `async` unless the migration requires a deliberate API change.
- Do not add `any` to every protocol mechanically; respond only to an actual existential requirement or enabled language feature.
- Never mark a class with unprotected mutable state as `@unchecked Sendable`.

## Verify completion

For each target, require:

- repository formatting and static analysis for changed Swift files;
- a Swift 6 build;
- target unit tests;
- a build of the nearest application or top-level consumer;
- public API and downstream consumer checks when applicable.

For an area or whole project, also exercise supported platforms, production configurations, extensions, integration schemes, and product variants selected in the plan.

Finish only when:

- every in-scope target has a terminal status;
- baseline and final checks are recorded;
- public API changes are listed;
- every unsafe escape hatch has a reason, evidence, owner, and removal plan;
- `MIGRATION_REPORT.md` and `SWIFT6_FOLLOW_UPS.md` exist;
- generated files, secrets, caches, and unrelated changes are absent from the diff;
- commit, push, and pull-request actions occur only after explicit authorization.
