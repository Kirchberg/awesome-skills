---
name: ios-app-intents
description: Use when designing, implementing, reviewing, debugging, testing, or migrating App Intents integrations for iOS, iPadOS, macOS, watchOS, tvOS, or visionOS, including AppIntent, AppEntity, AppEnum, entity queries, App Shortcuts, Siri, Spotlight, widgets, Live Activities, controls, Action button actions, snippets, deep-link routing, AppDependency, AppIntentsPackage, AppIntentsExtension, SiriKit migration, or availability-gated App Intents APIs. Trigger for requests to expose app actions outside the main UI, fix intent discovery or parameter resolution, model stable system entities, choose foreground or background execution, preserve saved shortcuts or widget configurations, integrate Apple Intelligence schemas, or validate App Intents behavior.
---

# Engineer production-ready App Intents

## Define the outcome

Expose a small set of valuable app actions through one coherent system model.
Keep intents thin, entity identity stable, execution semantics explicit, UI
routing deterministic, localization complete, and verification proportional to
every system surface in scope.

Treat the selected Xcode SDK and deployment targets as the API authority. Keep
shipping defaults separate from beta or future-release APIs, even when current
Apple documentation presents them beside stable APIs.

## Read references selectively

- Read `references/first-pass-audit.md` before changing an existing app or
  deciding which actions deserve intents.
- Read `references/intent-design.md` before choosing intent protocols,
  parameters, results, dialogs, confirmations, or error behavior.
- Read `references/entities-and-queries.md` before adding an `AppEntity`,
  `AppEnum`, query, suggestion source, or Find action.
- Read `references/runtime-and-routing.md` before selecting `supportedModes`,
  opening the app, continuing in foreground, or routing to content.
- Read `references/dependencies-and-modules.md` before injecting services,
  sharing intent code, or adding an App Intents extension.
- Read `references/app-shortcuts-and-localization.md` before adding or changing
  `AppShortcutsProvider`, phrases, summaries, synonyms, titles, or localization.
- Read `references/spotlight-and-donations.md` for Spotlight indexing, search,
  intent donations, entity donations, or discoverability.
- Read `references/surfaces-and-snippets.md` for widgets, Live Activities,
  controls, Action button actions, interactive snippets, or other system UI.
- Read `references/migration-and-versioning.md` before replacing SiriKit,
  changing published intents or entities, or migrating configurable widgets.
- Read `references/testing-and-evidence.md` before validating or claiming an
  integration complete.
- Read `references/code-patterns.md` for implementation shapes; adapt every
  signature to the selected SDK and the app's architecture.
- Read `references/beta-and-version-boundaries.md` only when prerelease SDKs,
  WWDC26 features, 2027 releases, or Apple Intelligence beta work is in scope.
- Read `references/sources.md` for API-sensitive claims, availability checks,
  research, or disputes between examples and the selected SDK.

Repository instructions, user scope, supported platforms, deployment targets,
and existing public behavior override generic examples. They never justify
breaking saved shortcuts, widget configurations, entity identity, privacy, or
execution safety.

## Route the request

Choose one lead mode:

- **Explain or research**: answer from current primary sources; do not edit.
- **Design**: produce an action inventory, system model, execution contract,
  routing contract, compatibility risks, and validation plan before code.
- **Review or diagnose**: inspect discovery, metadata, resolution, execution,
  routing, and surface behavior; report prioritized findings without fixing
  them unless requested.
- **Implement**: make the smallest complete integration and run available
  builds, tests, and system-surface checks.
- **Migrate**: inventory shipped SiriKit intents, shortcuts, widgets, entity
  identifiers, donations, and routes before preserving their contracts in App
  Intents.

Lead with `$swift-concurrency` when the root problem is actor isolation,
`Sendable`, cancellation, or task lifetime inside an otherwise sound intent.
Lead with `$swiftui-optimization` when the issue is SwiftUI rendering or view
identity rather than App Intents semantics. Use this skill to retain the system
integration contract around either specialized fix.

## Establish the integration contract

1. Read repository instructions and inspect version-control status.
2. Record Xcode, Swift, SDK, deployment targets, platforms, build system,
   application and extension targets, and availability policy.
3. Find existing App Intents, SiriKit definitions, App Shortcuts, Spotlight
   indexing, donations, widgets, controls, URL handling, scene routing, shared
   stores, and relevant tests.
4. Identify the requested system surfaces and the observable user outcome on
   each one.
5. Define the focused build, discovery, resolution, execution, routing,
   localization, migration, and device checks needed for completion.

Do not infer an API signature or availability from a tutorial. Inspect the
selected SDK interface and current Apple documentation.

## Audit actions before writing types

Select the smallest useful first release, normally one to three actions and no
more than a few App Shortcuts. Prefer actions that can complete briefly outside
the main UI, open a precise object or workflow, find app content, resume a
frequent task, or change a simple state.

Reject screen-by-screen mirroring, internal admin operations, ambiguous
multi-step flows, actions with no meaningful off-app outcome, and broad data
exposure without a clear user benefit.

For every candidate, record:

- user phrase or system entry point and intended result;
- required and optional inputs, output, dialog, snippet, and confirmation;
- background, immediate foreground, dynamic foreground, or deferred foreground
  execution;
- authentication, authorization, privacy, network, and offline behavior;
- cancellation, retry, idempotency, duration, and destructive-effect rules;
- entity lookup, UI destination, and supported system surfaces.

## Model verbs, nouns, and sentences

- Model actions as intents, app content as narrow entities, fixed choices as
  app enums, and common invocations as App Shortcuts.
- Prefer a specialized intent protocol or supported App Schema when its
  semantics match. Use plain `AppIntent` when no specialized contract fits.
- Include only parameters necessary to complete the action. Put every required
  parameter in `parameterSummary`.
- Keep `perform()` as an adapter: validate resolved input, call an existing
  domain use case or application service, and map its result to `IntentResult`.
- Keep persistence models, backend DTOs, navigation state, and system-facing
  entities separate unless their contracts genuinely coincide.
- Return concise, useful results. Confirm destructive or consequential effects
  at the last responsible moment and preserve domain authorization checks.

## Make identity and lookup durable

Use stable, globally unambiguous identifiers that survive launches, sync,
renames, and data reordering. Resolve saved identifiers through the real data
source; omit deleted values rather than substituting a different entity.

Choose the least powerful query that satisfies the corpus: identifier lookup
for restoration, bounded suggestions for configuration, string search for text
matching, enumeration only for genuinely small sets, property queries for
filterable large sets, and Spotlight indexing for system search and scalable
discovery.

Never fetch an unbounded catalog merely to filter it in memory. Never expose an
entire persistence or API model by default.

## Make execution and routing explicit

Use `supportedModes` as the current execution contract. Do not use deprecated
`openAppWhenRun` as the primary design; retain or add it only in the narrow,
explicitly deprecated compatibility form Apple documents when an older deployed
OS requires it, and never for an App Intents extension. Use `OpenIntent`, a
URL-representable entity, a supported schema, or another purpose-built protocol
when the semantic outcome is to open content.

Route every foreground handoff through one app-owned route:

```text
App Intent -> semantic destination -> root router or scene -> screen
```

Do not scatter global notifications, singleton navigation mutations, or
surface-specific deep-link parsers across intents. Re-check state after a
foreground transition and handle missing or deleted content predictably.

## Preserve process and compatibility boundaries

Register dependencies early and inject domain services through App Intents
infrastructure. Treat the main app, widgets, and App Intents extensions as
separate processes with explicit storage, authorization, and write ownership.

Before changing a shipped integration, preserve or deliberately migrate:

- intent and parameter identity, types, defaults, and optionality;
- App Entity identifiers and persistent type identity;
- user-created shortcuts, automations, and donated interactions;
- configurable widget values and interactive surface behavior;
- Spotlight records, universal links, deep links, and scene destinations;
- localization keys, phrases, synonyms, and displayed representations.

Availability-gate newer APIs at compile time and runtime as required. Keep a
stable fallback or raise the deployment baseline explicitly; never let a beta
example silently become the production default.

## Verify the complete path

Build every affected target and run focused tests. Then verify discovery in
Shortcuts, parameter summaries and suggestions, identifier restoration,
background behavior, foreground routing, localization, Spotlight results,
donations, and each widget, control, Live Activity, Action button, or snippet
surface in scope.

Exercise missing data, denied authorization, logged-out state, offline state,
cancellation, retry, duplicate invocation, app-not-running, extension-process,
and upgrade paths as relevant. Use Simulator where Apple supports it and real
devices for claims that depend on Siri, installed system surfaces, device-only
features, or release behavior.

Finish with scope and selected SDK, actions and entities added or reviewed,
execution and routing contracts, compatibility effects, checks run, device and
OS evidence, beta APIs and fallbacks, and remaining uncertainty. Never claim
Siri, Spotlight, Shortcuts, or widget compatibility from compilation alone.
