# First-pass App Intents audit

Use this audit before proposing or changing types. Produce a short evidence
bundle that explains the app, its current integration surface, and the smallest
valuable App Intents release.

## Contents

- Respect the requested mode
- Record the build and release baseline
- Map the existing integration
- Inventory candidate actions
- Define the evidence gate
- Produce the audit result

## Respect the requested mode

- For explanation, design, review, diagnosis, or research, inspect read-only and
  do not edit unless the user also requests implementation.
- For implementation or migration, inspect before editing and preserve unrelated
  work in a dirty tree.
- Keep the audit within the named feature, app, targets, and system surfaces.

## Record the build and release baseline

Find the source of truth for:

- Xcode, Swift, and SDK versions;
- deployment targets and supported Apple platforms;
- Swift language mode, default isolation, and strict-concurrency settings;
- app, widget, Live Activity, control, and App Intents extension targets;
- SwiftPM packages, frameworks, target membership, App Groups, and entitlements;
- build, test, lint, formatting, localization, and code-generation commands;
- stable-versus-beta SDK policy.

Prefer generated SDK interfaces and compiler diagnostics over remembered API
signatures. Record unavailable tooling instead of guessing its output.

## Map the existing integration

Search for these symbols and artifacts as applicable:

```text
import AppIntents
AppIntent AppEntity AppEnum EntityQuery IndexedEntity
AppShortcutsProvider AppShortcut IntentDonationManager
AppDependency AppDependencyManager AppIntentsPackage AppIntentsExtension
supportedModes openAppWhenRun OpenIntent URLRepresentableEntity
INIntent IntentDefinition.intentdefinition CustomIntentMigratedAppIntent
AppIntentConfiguration Button(intent:) Toggle(intent:)
CoreSpotlight CSSearchableItem NSUserActivity onOpenURL handlesExternalEvents
```

Then trace:

- current domain use cases, repositories, persistence, authentication, and
  network clients;
- root router, scene ownership, universal links, custom links, and restoration;
- current Spotlight records and deletion or reindexing lifecycle;
- SiriKit handling, donations, vocabulary, and published shortcut behavior;
- configurable widgets and the parameter names and types users have saved;
- localization resources, String Catalogs, app name variants, and synonyms;
- tests that cover the action, identifier lookup, routing, or migration.

Do not assume the absence of `AppIntent` means the app has no system contract.
Widgets, SiriKit, deep links, Spotlight, and donated activities may already be
user-visible compatibility surfaces.

## Inventory candidate actions

Describe each candidate as a user outcome rather than a screen or method name:

- perform a short operation without opening the main UI;
- open a specific entity or workflow;
- find app content;
- resume a frequent task;
- change a simple, understandable state;
- return a reusable value to another shortcut action.

For each candidate, record:

1. who uses it and from which system surface;
2. the value over opening the app normally;
3. required input and the smallest useful result;
4. whether it is safe and useful with no screen;
5. authentication, authorization, privacy, and destructive impact;
6. data lookup, network, duration, cancellation, and offline behavior;
7. foreground destination if the action must open the app;
8. existing user-visible contract it could change.

Rank actions by user frequency, clarity, standalone value, implementation risk,
and compatibility cost. Normally select one to three for the first release.
Do not expose every tab, CRUD method, or internal model operation.

## Define the evidence gate

Before implementation, name the proof required for:

- all affected targets compiling against the selected SDK;
- intent metadata discovery in Shortcuts;
- required parameter presentation and resolution;
- entity restoration from stable identifiers;
- background execution and foreground routing;
- localization and spoken or displayed representation;
- Spotlight indexing, opening, and deletion;
- widget, control, Live Activity, Action button, or snippet behavior;
- migration of saved shortcuts or widget configuration;
- logged-out, denied, offline, missing-data, duplicate, and cancellation paths.

Separate checks that can run locally from checks requiring an installed app,
Simulator, real device, account, locale, or prerelease OS.

## Produce the audit result

Return:

- build and availability baseline;
- existing system-integration map;
- selected actions and deferred candidates;
- proposed intents, entities, enums, and queries;
- execution and routing contract for each action;
- compatibility and privacy risks;
- implementation seams and affected targets;
- validation matrix and unresolved dependencies.
