# App Shortcuts and localization

Use App Shortcuts as a curated, immediately discoverable layer over the app's
most valuable intents. Do not expose the entire action catalog as suggested
shortcuts.

## Curate the provider

Provide one `AppShortcutsProvider` for the app's preconfigured shortcuts. Start
with two to five high-value actions and remain within Apple's current maximum of
10. Recheck limits in the selected SDK and current documentation.

For each `AppShortcut`, define:

- an intent whose standalone behavior is already correct;
- a concise localized `shortTitle`;
- a recognizable SF Symbol available on supported OS versions;
- natural trigger phrases containing the application-name token;
- no more than the currently supported number of intent parameters per phrase;
- a useful action when Siri or Spotlight invokes it with no main UI visible.

Do not create many near-duplicate shortcuts to simulate optional grammar. Let
the intent's parameter resolution and the system's semantic matching do the
work supported by the selected OS.

## Write phrases for people

- Start from phrases people naturally say, not Swift type names.
- Keep the verb and object unambiguous outside the app.
- Use the application-name token exactly as required by `AppShortcutPhrase`.
- Include an intent parameter token only when it creates a useful direct phrase
  and current phrase rules support it.
- Avoid implementation terms, punctuation tricks, redundant filler, and phrases
  that overpromise unsupported variants.
- Add entity and enum synonyms for genuine vocabulary, abbreviations, and
  localized names; do not use synonyms to hide poor primary titles.

Apple's current phrase expansion has app-wide limits. Keep phrase, synonym, and
dynamic option growth bounded, and recheck the current limit before generating
large combinations.

## Localize the complete surface

Localize:

- intent title and description;
- parameter titles, descriptions, defaults, and summaries;
- entity type and display representations;
- enum type, cases, and synonyms;
- dialogs, confirmations, errors, and snippet content;
- App Shortcut phrases and short titles;
- any routing error the person sees after opening the app.

Use the project's String Catalog or localization source of truth. Preserve
interpolation types and application-name or parameter tokens across languages.
Do not translate identifiers, SF Symbol names, localization keys, or required
interpolation syntax.

Test languages with grammatical inflection, gender, plurals, long text,
right-to-left layout, non-Latin search, diacritics, and multiple app-name
variants when the product supports them.

## Build parameter summaries

Write `parameterSummary` as a concise localized sentence that communicates the
action. Include every required parameter without a default where the system
surface requires it, especially for Spotlight action presentation described by
the selected SDK and OS.

Verify optional branches, conditional summaries, and defaults in the Shortcuts
editor. Do not assume a summary that compiles renders correctly in every locale
or surface.

## Refresh dynamic presentation

Call `updateAppShortcutParameters()` at a deterministic lifecycle point after
the app can provide current dynamic display representations and when those
representations materially change. Keep the call bounded and safe during cold
launch.

Do not use refresh as a substitute for stable IDs. Do not repeatedly refresh on
every view update, query, or system invocation.

## Validate App Shortcuts

Use App Shortcuts Preview where the selected Xcode provides it, then verify an
installed build:

1. every shortcut appears with the intended title and symbol;
2. phrases compile and expand within current limits;
3. required parameters appear in the summary and resolve;
4. parameterized and non-parameterized invocation paths behave as designed;
5. dynamic representations refresh after relevant data changes;
6. all supported locales render without broken tokens or stale strings;
7. Siri, Shortcuts, and Spotlight run the same underlying domain action;
8. logged-out, denied, offline, and missing-entity paths remain understandable;
9. existing user-created shortcuts continue to resolve after upgrade;
10. deprecated shortcuts point to deliberate replacements rather than vanish.
