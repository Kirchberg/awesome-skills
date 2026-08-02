# App Intents beta and version boundaries

Last reviewed: 2026-08-02.

Keep released behavior, deployment-target compatibility, and prerelease
experimentation as separate implementation lanes. A symbol appearing in online
documentation, code completion, or a WWDC sample does not prove that it is
available in the app's selected stable SDK or on every supported OS.

## Contents

- [Stable shipping baseline](#stable-shipping-baseline)
- [WWDC26 capabilities for 2027 releases](#wwdc26-capabilities-for-2027-releases)
- [AppIntentsTesting beta boundary](#appintentstesting-beta-boundary)
- [App Schema boundary](#app-schema-boundary)
- [Required SDK and availability gate](#required-sdk-and-availability-gate)
- [Fallback requirements](#fallback-requirements)
- [Required evidence](#required-evidence)
- [Promotion from prerelease to stable](#promotion-from-prerelease-to-stable)

## Stable shipping baseline

Define the baseline from the project's selected non-beta Xcode, installed SDK,
deployment targets, and released OS versions. Stable App Intents work can
include the following when those exact APIs are present in that baseline:

- `AppIntent`, specialized released intent protocols, parameters, results,
  dialogs, confirmations, and current `supportedModes`;
- `AppEntity`, `AppEnum`, stable identity, display representations, and released
  entity-query protocols;
- `AppShortcutsProvider`, localized App Shortcuts, Siri and Shortcuts actions;
- released Spotlight indexing and donation APIs;
- released WidgetKit configuration, widget interaction, control, Live Activity,
  Action button, and snippet APIs supported by the deployment target;
- `AppDependency`, packages, and extensions supported by the selected SDK;
- released SiriKit migration and intent-deprecation APIs.

Do not use deprecated `openAppWhenRun` as the baseline for new code. Select the
current execution contract from `supportedModes`, and use semantic protocols
such as `OpenIntent` only when they match the action.

“Stable” is not one global framework version. A control, snippet, schema,
specialized intent, or query may require a newer released OS than base
`AppIntent`. Inspect each symbol and every target that compiles it.

## WWDC26 capabilities for 2027 releases

Apple's WWDC26 session explicitly introduces the following capabilities “with
our 2027 releases.” Treat these specific forms as prerelease until a final SDK,
released OS, and final documentation establish otherwise:

- **`ValueRepresentation`** — structured, system-understood representations
  that allow entities to flow between apps without reducing the value to a file
  or data representation;
- **`RelevantEntities`** — registering entities with a context so the system can
  suggest content before interaction history exists;
- **`EntityCollection`** — passing or storing entity identifiers without eagerly
  resolving every entity, especially for large collections;
- **`SyncableEntity` and `SyncableEntityIdentifier`** — declaring or pairing
  stable cross-device identity for entity use across devices;
- **expanded union-value parameters** — using the WWDC26 `@UnionValue` input
  forms and picker support across intents, Shortcuts, and widgets;
- **the WWDC26 `LongRunningIntent` model** — execution beyond the normal intent
  window, progress reporting, Live Activity presentation, and cancellation
  behavior;
- **the WWDC26 `ExecutionTargets` model** — selecting the main app, App Intents
  extension, WidgetKit extension, or an allowed combination as the execution
  process.

Do not generalize this boundary beyond the announced forms. For example, older
union-value or transferable capabilities may already exist in a released SDK;
inspect the exact macro, initializer, conformance, and availability used by the
code.

Primary source:
[Discover new capabilities in the App Intents framework — WWDC26](https://developer.apple.com/videos/play/wwdc2026/345/).

## AppIntentsTesting beta boundary

Apple currently labels the `AppIntentsTesting` documentation Beta Software.
Keep it in an optional prerelease test lane, not in the minimum proof required
for a stable shipping implementation.

The beta framework can exercise the full App Intents stack out of process from
an XCUITest bundle, including intents, returned values, entity queries, chained
actions, Spotlight indexing, and view annotations. Its test target resolves the
app by bundle identifier rather than importing app implementation code.

Until Apple publishes final framework and platform support:

- retain unit tests for domain services, parameter mapping, and query logic;
- retain build checks for every affected app and extension target;
- retain manual Shortcuts, Siri, Spotlight, widget, control, and device checks;
- guard any test target, imports, fixtures, and CI destination that require the
  beta framework;
- keep test-only intents non-discoverable and compile them only into debug or
  dedicated test builds;
- do not require developers on the stable toolchain to compile a beta-only test
  target.

Sources:
[App Intents Testing](https://developer.apple.com/documentation/appintentstesting),
[Testing your App Intents code](https://developer.apple.com/documentation/appintentstesting/testing-your-app-intents-code),
and [Validate your App Intents adoption with AppIntentsTesting — WWDC26](https://developer.apple.com/videos/play/wwdc2026/295/).

## App Schema boundary

Do not state that all App Schemas are beta. App Schema concepts and some schema
APIs predate WWDC26, and their status can differ by domain, schema, platform,
SDK, and OS release.

For schema work:

1. Inspect the exact schema in the selected SDK's generated AppIntents
   interface.
2. Record availability for the schema macro, intent, entity, enum, properties,
   and supporting query types separately.
3. Distinguish an already released schema from new WWDC26 Siri behavior that
   consumes or extends it.
4. Treat WWDC26 code-alongs and Siri demonstrations as prerelease evidence for
   2027 behavior unless final release documentation says otherwise.
5. Fall back to a released custom `AppIntent`, `AppEntity`, or App Shortcut when
   the schema is unavailable and the fallback preserves the user outcome.

Use the current [App schema domains](https://developer.apple.com/documentation/appintents/app-schema-domains)
catalog for discovery, then prove availability in the selected SDK. Use
[Build intelligent Siri experiences with App Schemas — WWDC26](https://developer.apple.com/videos/play/wwdc2026/240/)
and [Code-along: Make your app available to Siri — WWDC26](https://developer.apple.com/videos/play/wwdc2026/344/)
only as dated prerelease guidance for the behavior they demonstrate.

## Required SDK and availability gate

Before introducing any version-sensitive API, record:

- exact Xcode version and build number;
- Swift compiler and language mode;
- SDK name, version, and build;
- minimum deployment target for every app and extension target involved;
- whether the toolchain or operating system is beta, release candidate, or
  final;
- the symbol's declaration and availability copied from the selected SDK;
- the Apple documentation or release-note URL and review date;
- the stable fallback and which users or platforms receive it.

Apply all gates the integration needs:

- use conditional compilation when an older compiler or SDK cannot parse or
  resolve the new symbol;
- use `@available` and runtime availability checks for code that still compiles
  against the selected SDK but cannot execute on an older supported OS;
- isolate prerelease code in a file, target, package, or branch when that is the
  only way to keep the stable build green;
- check target membership and availability independently for the main app,
  widgets, controls, and App Intents extensions;
- never silence Swift 6 isolation failures with an unaudited
  `@unchecked Sendable` merely to compile a beta example.

An `if #available` runtime branch alone cannot make an unknown type compile
with an older SDK. Use a compile-time boundary where necessary.

## Fallback requirements

Every prerelease adoption needs an explicit behavior on the stable path:

- `ValueRepresentation`: keep an existing released `Transferable` file/data
  representation or return another released system value the workflow accepts;
- `RelevantEntities`: retain Spotlight indexing and direct interaction donation
  where they model the product behavior;
- `EntityCollection`: bound the entity set, query at the data source, or split
  the workflow rather than resolving an unbounded array;
- `SyncableEntity`: keep device-local entity restoration correct and do not
  promise cross-device continuation;
- expanded union parameters: use separate intents, a released enum/entity
  wrapper, or another stable parameter model;
- `LongRunningIntent`: hand off to the app or an established released
  background workflow, with honest progress and cancellation behavior;
- `ExecutionTargets`: preserve process-safe target membership, shared storage,
  and single-writer ownership without relying on explicit process selection;
- `AppIntentsTesting`: retain domain tests, build verification, and manual
  installed-system checks.

Do not provide a fallback that silently changes authorization, destructive
effects, entity identity, saved shortcut parameters, widget configuration, or
the promised foreground destination.

## Required evidence

A prerelease result is incomplete without an evidence record containing:

```text
Feature:
Apple source and review date:
Xcode / Swift / SDK build:
OS build and device:
App and extension targets compiled:
SDK declaration and availability:
Compile-time gate:
Runtime gate:
Stable fallback:
Automated checks:
Manual system-surface checks:
Known beta issue or remaining uncertainty:
```

At minimum, build every affected target and invoke the feature through its real
system surface on the named OS build. Compilation alone does not prove Siri,
Shortcuts, Spotlight, control, Action button, widget, snippet, or routing
behavior.

## Promotion from prerelease to stable

Promote a capability into stable defaults only after all applicable conditions
are true:

1. A final Xcode and final platform SDK contain the exact API.
2. Apple no longer labels the relied-on documentation as Beta Software.
3. Final release notes do not remove or materially change the behavior.
4. The project builds every affected target without a beta toolchain.
5. Runtime checks pass on released OS builds and supported hardware.
6. Upgrade, fallback, saved-shortcut, widget-configuration, and entity-identity
   checks pass for older supported versions.
7. Local templates and references are updated to the final signatures.

If any condition is unknown, keep the feature in the prerelease lane and report
the missing evidence rather than presenting it as production-ready.
