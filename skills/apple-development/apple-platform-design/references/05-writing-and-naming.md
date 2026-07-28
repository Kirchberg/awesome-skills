# Write interface language that explains the product

Treat interface copy as behavior, not decoration. Make the next action,
consequence, state, and recovery understandable without requiring people to
decode internal product terminology.

## Establish the vocabulary

1. Inventory the nouns and verbs already used by the product, platform, and
   audience.
2. Give one concept one stable name across navigation, headings, buttons,
   search, tips, settings, notifications, and accessibility text.
3. Prefer the person's language over database, implementation, growth, or
   marketing terms.
4. Reuse established Apple terminology when the feature represents a familiar
   platform action. Do not imitate Apple wording for a materially different
   action.
5. Define whether a label names a destination, changes state, performs an
   immediate action, or opens a choice. Do not mix those meanings.

## Name features and destinations

Test each proposed name against four questions:

- **Expectation**: Will the audience predict what this does?
- **Structure**: Does it fit the surrounding information architecture?
- **Reuse**: Does it retain meaning in menus, settings, search, shortcuts,
  notifications, help, and accessibility output?
- **Translation**: Can it remain clear when localized, inflected, or expanded?

Prefer a plain, specific name over a clever brand term. Introduce branded
language only when it describes a real product concept, then pair it with
explanatory language until the meaning is established.

## Write controls and content

- Start action labels with a specific verb. Label the result, not the gesture
  used to trigger it.
- Name navigation destinations with concise nouns or noun phrases.
- Keep headings informative when read out of context.
- Put the essential distinction at the beginning of labels and list rows.
- Use sentence-style capitalization unless the platform, locale, or established
  product convention requires otherwise.
- Avoid redundant instructions such as “Tap to,” repeated control types, or
  placeholder text that acts as the only field label.
- Use symbols alone only when their meaning is unambiguous in context. Add text
  when a symbol could plausibly mean more than one action.
- Keep tone calm and direct. Do not blame, pressure, shame, or manufacture
  urgency.

## Write states and recovery

For an empty state, explain:

1. what the person is seeing;
2. why it is empty when that is useful;
3. the next valuable action, if one exists.

For an error, explain:

1. what failed in language the person can act on;
2. whether their data or work was preserved;
3. what they can do now;
4. how to retry or recover.

Place a field-level error next to its source and preserve valid input. Reserve
alerts for decisions or consequences that genuinely require interruption.
Distinguish loading, no results, no content yet, offline data, permission denial,
and failure; they need different copy and actions.

## Design for localization and accessibility

- Use localization APIs and string catalogs instead of joining translated
  fragments.
- Allow labels, values, buttons, and errors to expand and wrap.
- Verify grammatical variables, plurals, dates, numbers, names, and bidirectional
  text with representative real locales.
- Keep a concise accessible name separate from dynamic value, state, role, and
  optional outcome-oriented hint.
- Check that nearby labels do not become ambiguous when traversed linearly or
  announced without the visual grouping.
- Do not encode meaning through punctuation, capitalization, emoji, or visual
  position alone.

## Review the language

Read the flow once with visuals hidden and once in a different order, as search,
VoiceOver, notifications, and shortcuts may present it. Flag inconsistent
nouns, vague verbs, unexplained brand terms, duplicated explanations, hidden
consequences, and copy that becomes false in another state.

Record unresolved legal, safety, policy, or localization questions instead of
inventing authoritative language.
