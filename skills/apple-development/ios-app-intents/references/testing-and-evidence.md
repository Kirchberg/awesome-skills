# Testing and evidence

Validate the full system path: metadata extraction, discovery, parameter
resolution, domain execution, foreground handoff, and the visible result on each
promised surface.

## Contents

- Establish the test baseline
- Test below the framework boundary
- Build every integration target
- Verify Shortcuts and Siri
- Verify routing and discovery surfaces
- Verify migration
- Handle App Intents Testing separately
- Report completion truthfully

## Establish the test baseline

Record:

- source revision, Xcode, Swift, SDK, OS, and deployment target;
- app and extension targets plus build configuration;
- device or Simulator, locale, account, permissions, and data state;
- system entry point and app lifecycle state;
- stable or prerelease API path;
- expected observable result and retained evidence.

Use release-like builds for claims affected by metadata extraction, extension
packaging, launch behavior, or performance.

## Test below the framework boundary

Unit-test domain services independently from App Intents:

- authorization and validation;
- idempotency and duplicate invocation;
- transactions and effect completion;
- retry, offline, timeout, and cancellation;
- repository filtering and stable identifier lookup;
- routing destination construction;
- migration mappings and deprecated-action replacements.

Test query adapters with representative volume, missing IDs, partial batches,
account scoping, locale-aware search, supported comparators, deterministic sort,
and bounded suggestions.

Compilation and unit tests do not prove system discovery.

## Build every integration target

Run repository formatting, static analysis, focused tests, and builds for the
app plus every widget, Live Activity, control, or App Intents extension that
contains or executes the declarations.

Inspect warnings and generated metadata diagnostics. Verify release target
membership, linked App Intents packages, localization resources, entitlements,
App Groups, and strict-concurrency diagnostics.

Do not invoke private metadata tools manually as a substitute for the supported
Xcode build unless Apple documents that workflow for the selected toolchain.

## Verify Shortcuts and Siri

With the app installed and launched as required:

1. find the app in the Shortcuts action library;
2. inspect title, description, parameter summary, defaults, and suggestions;
3. build and run a shortcut through the real action;
4. restore an entity saved before relaunch;
5. run with the app terminated and already running;
6. exercise background and every foreground continuation path;
7. verify current execution modes and any older-OS compatibility bridge;
8. verify App Shortcut phrases and supported Siri invocation;
9. repeat in representative locales;
10. test logged-out, denied, offline, stale, cancelled, and duplicate paths;
11. confirm downstream actions receive the intended output type and value.

Use breakpoints or structured privacy-safe logs to locate execution, but retain
user-observable evidence for behavior claims.

## Verify routing and discovery surfaces

- For Spotlight, prove indexing or donation, search using recorded terms, open
  the exact entity, update it, delete it, and exercise reindexing.
- For widgets and Live Activities, invoke the real Button or Toggle, confirm the
  durable state commit, and observe the supported reload path.
- For controls and Action buttons, use eligible physical hardware when the
  surface is device-only.
- For snippets, verify repeated execution, committed-state rendering,
  localization, accessibility, compact layout, and failure recovery.
- For universal links, compare ordinary link routing with the intent-open path.

Do not transfer a passing result from one surface to another without executing
the second surface.

## Verify migration

Install or preserve a representative previous build, create shortcuts,
automations, indexed entities, donations, and configured widgets, then upgrade.
Verify values, identifiers, results, routes, and replacements remain correct.

A fresh install cannot prove backward compatibility.

## Handle App Intents Testing separately

Apple marks `AppIntentsTesting` beta as of the source review date. Use it only
when the user includes the prerelease SDK path and after reading
`beta-and-version-boundaries.md`. Keep stable unit, build, and manual
system-surface checks even when beta out-of-process tests pass.

## Report completion truthfully

Use evidence levels precisely:

- **Built**: affected targets compiled; discovery is not implied.
- **Unit-tested**: domain and adapter tests passed; system execution is not
  implied.
- **Discovered**: the installed action or entity appeared on the named surface.
- **Executed**: the named invocation completed with the recorded result.
- **Surface-verified**: execution and visible behavior passed on the recorded OS,
  device, locale, lifecycle, and state.
- **Migration-verified**: representative persisted workflows survived an actual
  previous-build upgrade.

Finish with commands and results, manual steps, device matrix, tested failure
paths, beta usage, untested surfaces, and remaining risk. Never claim universal
Siri, Shortcuts, Spotlight, or device compatibility from one simulator run.
