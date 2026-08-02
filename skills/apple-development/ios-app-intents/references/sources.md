# App Intents primary sources

Last reviewed: 2026-08-02.

Use only first-party Apple documentation, release notes, WWDC transcripts, and
sample code for API-sensitive App Intents claims. The selected Xcode SDK and its
generated Swift interfaces remain the authority for exact signatures,
conformances, and availability.

## Contents

- [Use the source registry](#use-the-source-registry)
- [Required stable core](#required-stable-core)
- [Entities and queries](#entities-and-queries)
- [Discovery and system surfaces](#discovery-and-system-surfaces)
- [Migration and testing](#migration-and-testing)
- [Prerelease and version-sensitive sources](#prerelease-and-version-sensitive-sources)
- [Corrected links](#corrected-links)

## Use the source registry

Apply this priority order:

1. Inspect the selected SDK interface and compiler diagnostics for the build.
2. Prefer current Apple API documentation for behavior and requirements.
3. Use Apple release notes to establish whether a change shipped or remains
   prerelease.
4. Use WWDC sessions as dated explanations, not timeless availability claims.
5. Treat Apple sample code as an example that may retain older compatibility
   syntax. Reconcile it with current API documentation before copying it.
6. Keep any page marked Beta Software, and every explicitly future-release
   session, outside the stable implementation default.

Canonical links below intentionally omit locale prefixes, query parameters, and
tracking parameters.

## Required stable core

Load these first for implementation, review, or migration:

1. **Getting started with the App Intents framework** — Current entry point for
   actions, content, parameters, results, and system integration.
   [Source](https://developer.apple.com/documentation/appintents/getting-started-with-the-app-intents-framework)
2. **Creating your first app intent** — Current construction workflow,
   specialized protocols, dependencies, metadata, parameters, and results.
   [Source](https://developer.apple.com/documentation/appintents/creating-your-first-app-intent)
3. **App intents** — Current collection of base and specialized action types.
   [Source](https://developer.apple.com/documentation/appintents/app-intents)
4. **AppIntent** — Protocol contract, including `Sendable`, discovery,
   parameters, execution, results, authentication, and system context.
   [Source](https://developer.apple.com/documentation/appintents/appintent)
5. **supportedModes** — Current foreground and background execution model.
   [Source](https://developer.apple.com/documentation/appintents/appintent/supportedmodes)
6. **openAppWhenRun** — Deprecated compatibility property. Use this page to
   recognize old code, not as a new-code template.
   [Source](https://developer.apple.com/documentation/appintents/appintent/openappwhenrun)
7. **Adding parameters to an app intent** — Supported values, required versus
   optional input, summaries, dynamic options, and resolution.
   [Source](https://developer.apple.com/documentation/appintents/adding-parameters-to-an-app-intent)
8. **IntentParameterContext** — Runtime requests for a value, disambiguation,
   and confirmation.
   [Source](https://developer.apple.com/documentation/appintents/intentparametercontext)
9. **Intent infrastructure** — Dependencies, packages, extensions, system
   context, and deprecation infrastructure.
   [Source](https://developer.apple.com/documentation/appintents/intent-infrastructure)
10. **App extension** — Running and sharing intents outside the main app target.
    [Source](https://developer.apple.com/documentation/appintents/app-extension)
11. **App Intents updates** — Dated Apple change log. Do not infer availability
    for a newer SDK solely from an older entry.
    [Source](https://developer.apple.com/documentation/updates/appintents/)
12. **Get to know App Intents — WWDC25** — Modern overview of intents, enums,
    entities, queries, App Shortcuts, packages, and build-time metadata.
    [Source](https://developer.apple.com/videos/play/wwdc2025/244/)
13. **Design App Intents for system experiences — WWDC24** — Product and
    interaction guidance for selecting useful actions and parameters.
    [Source](https://developer.apple.com/videos/play/wwdc2024/10176/)
14. **Bring your app's core features to users with App Intents — WWDC24** —
    Cross-surface system model for intents, entities, and App Shortcuts.
    [Source](https://developer.apple.com/videos/play/wwdc2024/10210/)
15. **Accelerating app interactions with App Intents** — Broad Apple sample.
    Its older `openAppWhenRun` examples must be normalized to the current SDK.
    [Source](https://developer.apple.com/documentation/appintents/acceleratingappinteractionswithappintents/)
16. **Adopting strict concurrency in Swift 6 apps** — Data-race checking used
    to validate the `Sendable` and isolation boundaries of intent code.
    [Source](https://developer.apple.com/documentation/swift/adoptingswift6)

## Entities and queries

- **App entities** — Current entity API collection and conceptual overview.
  [Source](https://developer.apple.com/documentation/appintents/app-entities)
- **Defining app entities for your custom data types** — Narrow entity shapes,
  IDs, display properties, queries, and Spotlight participation.
  [Source](https://developer.apple.com/documentation/appintents/defining-app-entities-for-your-custom-data-types)
- **AppEntity** — Exact identity, display, property, query, and `Sendable`
  contract.
  [Source](https://developer.apple.com/documentation/appintents/appentity)
- **AppEnum** — Static, finite app-specific values.
  [Source](https://developer.apple.com/documentation/appintents/appenum)
- **Entity queries** — Decision surface for identifier, string, enumerable,
  property, indexed, and unique queries.
  [Source](https://developer.apple.com/documentation/appintents/entity-queries)
- **EntityQuery** — Identifier restoration and bounded suggestions.
  [Source](https://developer.apple.com/documentation/appintents/entityquery)
- **EntityStringQuery** — App-owned free-text entity search.
  [Source](https://developer.apple.com/documentation/appintents/entitystringquery)
- **EnumerableEntityQuery** — Full enumeration for predictably small sets; the
  documentation directs large sets toward property queries.
  [Source](https://developer.apple.com/documentation/appintents/enumerableentityquery)
- **EntityPropertyQuery** — Find actions backed by property comparators,
  filtering, sorting, and result limits.
  [Source](https://developer.apple.com/documentation/appintents/entitypropertyquery)
- **IndexedEntityQuery** — Spotlight reindexing support for indexed entities.
  [Source](https://developer.apple.com/documentation/appintents/indexedentityquery)
- **EntityIdentifier** — Stable per-instance identity across app executions.
  [Source](https://developer.apple.com/documentation/appintents/entityidentifier)
- **PersistentlyIdentifiable** — Stable type identity when Swift type names
  change.
  [Source](https://developer.apple.com/documentation/appintents/persistentlyidentifiable)
- **URLRepresentableEntity** — Universal-link representation for an entity;
  custom URL schemes do not satisfy this protocol's contract.
  [Source](https://developer.apple.com/documentation/appintents/urlrepresentableentity)
- **AppDependency** — Injected dependency values and their `Sendable` boundary.
  [Source](https://developer.apple.com/documentation/appintents/appdependency)
- **AppDependencyManager** — Early registration and test-specific dependency
  management.
  [Source](https://developer.apple.com/documentation/appintents/appdependencymanager)

## Discovery and system surfaces

- **App Shortcuts** — API collection for install-time, curated shortcuts.
  [Source](https://developer.apple.com/documentation/appintents/app-shortcuts)
- **AppShortcutsProvider** — The app-level provider and parameter refresh API.
  [Source](https://developer.apple.com/documentation/appintents/appshortcutsprovider)
- **HIG: App Shortcuts** — Current selection, phrase, result, and platform
  guidance, including the maximum of ten App Shortcuts.
  [Source](https://developer.apple.com/design/human-interface-guidelines/app-shortcuts)
- **Spotlight your app with App Shortcuts — WWDC23** — One-provider rule,
  phrases, localization, synonyms, preview tooling, and phrase limits.
  [Source](https://developer.apple.com/videos/play/wwdc2023/10102/)
- **Develop for Shortcuts and Spotlight with App Intents — WWDC25** — Required
  parameter summaries, suggestions, Find actions, and background/open pairing.
  [Source](https://developer.apple.com/videos/play/wwdc2025/260/)
- **Spotlight integration** — Indexed entities and automated reindexing.
  [Source](https://developer.apple.com/documentation/appintents/spotlight)
- **Making app entities available in Spotlight** — Property indexing, named
  indexes, donation, reindexing, and `OpenIntent` requirements.
  [Source](https://developer.apple.com/documentation/appintents/making-app-entities-available-in-spotlight)
- **Donations and discovery** — Intent donation, entity donation, and onscreen
  context. Do not re-donate interactions initiated by Siri or Shortcuts.
  [Source](https://developer.apple.com/documentation/appintents/donations-and-discovery)
- **Action button on iPhone and Apple Watch** — App Shortcuts on iPhone and
  specialized workout or dive intents on supported Apple Watch models.
  [Source](https://developer.apple.com/documentation/appintents/actionbutton)
- **Responding to the Action button on Apple Watch Ultra** — Workout and dive
  lifecycle, next-action donation, target placement, and debugging.
  [Source](https://developer.apple.com/documentation/appintents/actionbuttonarticle)
- **HIG: Action button** — Current product behavior and interaction guidance.
  [Source](https://developer.apple.com/design/human-interface-guidelines/action-button)
- **Controls** — WidgetKit controls for Control Center, Lock Screen, Action
  button, menu bar, and supported watchOS surfaces.
  [Source](https://developer.apple.com/documentation/widgetkit/controls-collection)
- **Creating controls to perform actions across the system** — Correct use of
  `AppIntent`, `OpenIntent`, and `SetValueIntent`, plus state persistence.
  [Source](https://developer.apple.com/documentation/widgetkit/creating-controls-to-perform-actions-across-the-system)
- **Adding refinements and configuration to controls** — Authentication,
  privacy, configuration, labels, and Action button hints.
  [Source](https://developer.apple.com/documentation/widgetkit/adding-refinements-and-configuration-to-controls)
- **Adding interactivity to widgets and Live Activities** — Intent-driven
  buttons, toggles, state updates, and shared behavior.
  [Source](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)
- **SnippetIntent** — Interactive snippet contract and repeated `perform()`
  behavior.
  [Source](https://developer.apple.com/documentation/appintents/snippetintent)
- **Displaying static and interactive snippets** — Result and confirmation
  snippets, custom views, dialog, and follow-up actions.
  [Source](https://developer.apple.com/documentation/appintents/displaying-static-and-interactive-snippets)
- **Design interactive snippets — WWDC25** — Dated design and implementation
  guidance for compact interactive results.
  [Source](https://developer.apple.com/videos/play/wwdc2025/281/)
- **HIG: Snippets** — Current presentation and accessibility guidance.
  [Source](https://developer.apple.com/design/human-interface-guidelines/snippets)
- **Bring your app to Siri — WWDC24** — Historical App Intent domain and
  Assistant Schema context. Reconcile its APIs with the selected current SDK.
  [Source](https://developer.apple.com/videos/play/wwdc2024/10133/)
- **App schema domains** — Current schema catalog. Availability is per schema
  and symbol; the catalog is not globally beta.
  [Source](https://developer.apple.com/documentation/appintents/app-schema-domains)

## Migration and testing

- **Migrate custom intents to App Intents** — Xcode conversion, automatic
  resolution, and migration from resolve/confirm/handle to `perform()`.
  [Source](https://developer.apple.com/videos/play/tech-talks/10168/)
- **Soup Chef with App Intents: Migrating custom intents** — Complete migration
  sample for entities, enums, transient values, queries, and shared code.
  [Source](https://developer.apple.com/documentation/sirikit/soup-chef-with-app-intents-migrating-custom-intents)
- **Migrating widgets from SiriKit Intents to App Intents** — Backward
  compatibility and the requirement to preserve parameter names and types.
  [Source](https://developer.apple.com/documentation/widgetkit/migrating-from-sirikit-intents-to-app-intents)
- **Deprecated symbols** — Current unsupported App Intents symbols and their
  replacements.
  [Source](https://developer.apple.com/documentation/appintents/deprecated-symbols)
- **DeprecatedAppIntent** — Gracefully retire a published intent.
  [Source](https://developer.apple.com/documentation/appintents/deprecatedappintent)
- **IntentDeprecation** — Localized migration message and optional replacement
  intent surfaced by Shortcuts.
  [Source](https://developer.apple.com/documentation/appintents/intentdeprecation)
- **Testing a beta OS** — Apple procedure for qualifying prerelease platform
  behavior without treating it as final.
  [Source](https://developer.apple.com/documentation/xcode/testing-a-beta-os)

`AppIntentsTesting` remains marked Beta Software at this review date. Use the
prerelease sources below only under the gates in
`beta-and-version-boundaries.md`; retain domain tests and manual Siri,
Shortcuts, Spotlight, widget, control, and device validation.

## Prerelease and version-sensitive sources

- **Discover new capabilities in the App Intents framework — WWDC26** — Apple
  explicitly introduces these capabilities with its 2027 releases.
  [Source](https://developer.apple.com/videos/play/wwdc2026/345/)
- **App Intents Testing** — Beta framework reference.
  [Source](https://developer.apple.com/documentation/appintentstesting)
- **Testing your App Intents code** — Beta testing workflow.
  [Source](https://developer.apple.com/documentation/appintentstesting/testing-your-app-intents-code)
- **Validate your App Intents adoption with AppIntentsTesting — WWDC26** —
  Out-of-process intent, entity, query, Spotlight, and view-annotation tests.
  [Source](https://developer.apple.com/videos/play/wwdc2026/295/)
- **Code-along: Make your app available to Siri — WWDC26** — Prerelease Siri
  integration example; verify every generated schema and symbol.
  [Source](https://developer.apple.com/videos/play/wwdc2026/344/)
- **Build intelligent Siri experiences with App Schemas — WWDC26** — Dated
  2027 Siri and schema guidance, not proof that every App Schema is beta.
  [Source](https://developer.apple.com/videos/play/wwdc2026/240/)
- **Explore advanced App Intents features for Siri and Apple Intelligence —
  WWDC26** — Prerelease dialogue, context, search, and entity workflows.
  [Source](https://developer.apple.com/videos/play/wwdc2026/343/)
- **Adopting App Intents to support system experiences** — Broad Apple sample
  currently marked Beta; use it as prerelease example code.
  [Source](https://developer.apple.com/documentation/appintents/adopting-app-intents-to-support-system-experiences)
- **iOS and iPadOS 27 release notes** — Current platform-specific prerelease
  evidence. Recheck the final notes before promoting any API.
  [Source](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes)

## Corrected links

- The stable-core “Getting started with the App Intents framework” entry above
  replaces the previously cited
  `making-actions-and-content-discoverable-and-widely-available` URL, which did
  not resolve during this review.
- The discovery entry for “Design interactive snippets” uses WWDC25 session
  281, not the generic WWDC25 video index.
- The discovery entry for “Bring your app to Siri” uses WWDC24 session 10133,
  not the Siri HIG page as the session citation.
- Do not include OpenAI Learn, secondary tutorials, locale-specific duplicate
  URLs, or links containing tracking parameters in this Apple-only registry.
