# Migration methodology

## Contents

- [Phases](#phases)
- [Target graph](#target-graph)
- [Stage ordering](#stage-ordering)
- [Baseline](#baseline)
- [Stage gate](#stage-gate)
- [Stopping and resuming](#stopping-and-resuming)
- [Failure handling](#failure-handling)

## Phases

Run the migration in five phases:

1. **Discover**: map first-party targets, settings, dependencies, consumers, tests, and variants.
2. **Baseline**: prove that representative builds and tests pass before language-mode changes.
3. **Plan**: partition the graph into reviewable stages with explicit gates.
4. **Migrate**: switch settings and repair diagnostics one stage at a time.
5. **Verify**: run the final matrix, audit escape hatches, and publish reports.

Do not combine discovery and source editing. An incomplete graph makes shared-setting changes unpredictable.

## Target graph

Create a directed graph where each node is a build target and each edge points from a consumer to a dependency.

Record separately:

- generated and third-party targets;
- test bundles and test-support libraries;
- applications and extensions;
- plugins, macros, and executable tools;
- package products that hide multiple targets;
- external consumers not present in the checkout.

Collapse strongly connected components into one planning unit. Targets in a dependency cycle cannot be proven independently.

Configuration inheritance forms a second graph. Two unrelated targets may still need one stage because they inherit the same `SWIFT_VERSION` from a shared helper or `.xcconfig`.

## Stage ordering

Choose the smallest stage that can pass an integration gate. Use these heuristics rather than a universal top-down or bottom-up rule:

1. Migrate isolated targets and low-fan-out implementation libraries first.
2. Keep a production target and its test targets in the same stage when test code imports internal implementation details.
3. Delay high-fan-out public foundations until representative consumers have baselines and API-impact checks.
4. Migrate an application, extension, or executable after its required libraries can be consumed safely in the intended mode.
5. Treat a shared build-setting group as one stage unless the project already supports per-target overrides.
6. Keep cyclic targets together.

Deviate when the build system forces a group switch or when a top-level target is the only reliable integration harness. Record the reason in state.

Recommended stage size:

- one shared-setting group;
- one production target plus its tests;
- one strongly connected component;
- or a small set of independent leaf targets with the same verification matrix.

Do not optimize stage size by line count. Diagnostic volume depends more on isolation boundaries and API shape than source size.

## Baseline

Before switching a stage:

- build every target in the stage;
- run its focused unit tests;
- build at least one representative direct consumer;
- record existing warnings and failures;
- add focused characterization tests only where behavior is concurrency-sensitive.

Useful characterization targets include callback queue guarantees, event ordering, cancellation, actor hops, shared caches, and delegate lifetimes.

Do not classify a pre-existing failure as a migration regression. Record it with evidence and decide whether it blocks the stage.

## Stage gate

A stage passes only when all selected checks are green in the selected matrix:

- every target compiles in Swift 6 mode;
- target tests pass;
- representative consumers build;
- affected integration tests pass;
- public API changes and consumers were reviewed;
- new unsafe sites are documented;
- no unrelated or generated files entered the diff.

If a shared setting affects more targets than planned, restore the setting, expand the stage explicitly, and rerun the baseline. Do not continue with an accidental scope increase.

## Stopping and resuming

Stop at a stable boundary:

- after inventory;
- after a passing baseline;
- after a completed stage gate;
- or after recording a reproducible blocker.

Before stopping:

1. Persist state atomically.
2. Record the exact command and outcome of the last check.
3. Set the cursor to the next action, not the previous action.
4. List dirty files and whether they are intentional.
5. Record any running process or temporary worktree.

When resuming:

1. Validate the state schema.
2. Confirm repository root, branch, starting revision, and current diff.
3. Confirm toolchain versions have not changed unexpectedly.
4. Re-run the most recent successful narrow check if source or configuration changed.
5. Continue from the cursor only after these checks agree.

Never infer success from a stale state entry or an existing build artifact.

## Failure handling

Classify failures as:

- **migration diagnostic**: caused by Swift 6 checking;
- **behavior regression**: tests or runtime behavior changed;
- **configuration scope error**: more targets inherited the setting than planned;
- **baseline failure**: already present before migration;
- **environment blocker**: missing SDK, simulator, credential, generated dependency, or incompatible toolchain;
- **external compatibility blocker**: a dependency or consumer cannot satisfy the required contract.

For each blocker, record the target, command, concise diagnostic, owner, required input, and next safe action. Do not mask environment or compatibility failures with concurrency annotations.
