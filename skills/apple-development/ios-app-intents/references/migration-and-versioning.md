# Migration and versioning

Treat App Intents as published user workflows. Before changing types, inventory
what the system and people may already have persisted.

## Contents

- Inventory the shipped contract
- Migrate SiriKit deliberately
- Preserve configurable widgets
- Keep entity identity stable
- Evolve intents compatibly
- Gate availability
- Prove upgrade behavior

## Inventory the shipped contract

Record:

- SiriKit `.intentdefinition` files, generated classes, handlers, extensions,
  vocabulary, and donations;
- current App Intent type identity, parameter names, types, defaults,
  optionality, summaries, and results;
- App Entity IDs, persistent type identity, queries, Spotlight identifiers, and
  URL representations;
- App Shortcuts, phrases, synonyms, tiles, and donated interactions;
- widget configuration intent class name and parameter contracts;
- universal links, custom links, scene routes, and restoration behavior;
- minimum OS versions where each published path exists;
- user-created shortcuts, automations, widgets, and upgrade tests.

Do not infer compatibility from source names alone. Inspect generated interfaces,
intent definitions, current SDK migration docs, and an installed previous build.

## Migrate SiriKit deliberately

Use Apple's migration tooling and `CustomIntentMigratedAppIntent` where its
contract applies. Translate the old lifecycle intentionally:

```text
resolve -> non-optional parameter, AppEnum, AppEntity query, or explicit request
confirm -> domain validation and current confirmation API
handle  -> thin perform() calling the existing domain use case
```

Preserve old identifiers and semantics while migrating. Do not duplicate the
same user-visible action in SiriKit and App Intents without a transition plan.
Verify donations and vocabulary do not produce duplicate or stale suggestions.

## Preserve configurable widgets

When migrating a SiriKit-configured widget to `AppIntentConfiguration`, follow
Apple's exact mapping requirements for the selected SDK. In particular, preserve
the legacy intent class identity and the name and type of every mapped parameter
that must carry forward.

Test upgrade with a widget configured by the previous release. A fresh widget
configuration proves only the new path; it does not prove migration.

## Keep entity identity stable

- Never replace a durable entity ID with a title, sort index, transient database
  object ID, or newly generated UUID for existing records.
- Preserve `persistentIdentifier` when a published Swift type is renamed.
- Keep Spotlight, queries, shortcuts, widgets, and deep links on the same
  logical ID contract.
- Define an explicit mapping when backend or persistence IDs must change.
- Do not reuse retired IDs for new logical objects.
- Remove inaccessible or deleted entities instead of resolving them to a nearby
  value.

Test old saved identifiers against the new build and representative migrated
data.

## Evolve intents compatibly

Prefer additive optional parameters with safe defaults over changing the type or
meaning of an existing parameter. Preserve output semantics used by downstream
shortcut actions.

When an action must be replaced, use the current `DeprecatedAppIntent` and
`IntentDeprecation(replacedBy:)` contract where available. Give people a
localized replacement path. Keep the old action functional long enough for the
product's migration policy rather than silently removing it.

Model current execution through `supportedModes` and select a semantic opening
protocol only when the action means to open content. If an older supported OS
still requires `openAppWhenRun`, preserve or add only Apple's documented,
explicitly deprecated compatibility extension in the main app target. Verify
that bridge independently and remove it when the deployment baseline permits.

Review Apple's current deprecated-symbol index. Older samples may also use
obsolete continuation, Live Activity, audio, or Assistant macros whose current
replacement depends on SDK and platform.

## Gate availability

For each API introduced after the deployment target:

- establish compile-time availability;
- define the older-OS implementation or raise the deployment baseline;
- keep metadata discoverable only where the action can execute correctly;
- avoid referencing unavailable types from code that older targets must load;
- build the oldest supported and newest stable paths;
- isolate beta or 2027 APIs according to
  `beta-and-version-boundaries.md`.

Runtime `if #available` does not fix an unavailable protocol conformance or type
that fails compilation for the selected toolchain.

## Prove upgrade behavior

Validate with a previous public or representative release followed by the new
build:

1. saved shortcuts retain action and parameter values;
2. automations still run with the same effect;
3. configured widgets retain selections;
4. old entity IDs restore correctly;
5. Spotlight results open the same content and stale records disappear;
6. universal links and scene routes remain compatible;
7. App Shortcut titles, phrases, and localization do not duplicate unexpectedly;
8. donations do not repeat or leak across accounts;
9. deprecated actions surface their replacement;
10. older supported OS versions use the intended execution compatibility path.
