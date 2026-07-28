# Bidi text, localization, and locale formatting

Preserve logical text order and let localization and text systems resolve
language-dependent presentation.

## Contents

- Localize complete messages
- Keep language and locale separate
- Diagnose bidi behavior
- Choose paragraph direction and alignment
- Preserve editable-text semantics
- Handle remote content and identifiers
- Require linguistic review

## Localize complete messages

Use String Catalogs and APIs that expose whole messages to translators:

```swift
let status = String(
    localized: "\(completed) of \(total) items completed",
    comment: "Progress summary shown below the download"
)
```

Define required plural variations in the String Catalog; `String(localized:)`
does not create grammatical categories for an unconfigured message. Let the
translator reorder interpolation arguments and select the correct variants.
Provide a comment that explains the screen, role, grammatical meaning, and
argument units.

Do not:

- concatenate localized prefixes, values, separators, and suffixes;
- build a sentence from several separately localized `Text` values;
- choose singular and plural with `count == 1`;
- reuse one source string across unrelated verb and noun contexts;
- bake a visual left-to-right order into a format string;
- translate user-generated or server-owned content as interface copy.

Use `String(localized:)`, `LocalizedStringResource`, or SwiftUI's localizable
initializers according to the project's deployment targets and API boundary.
Keep dynamic content typed until interpolation or formatting rather than
preformatting it into English text.

## Keep language and locale separate

Treat interface language, content language, region, calendar, numbering system,
currency, time zone, and measurement preferences as separate inputs.

Use Foundation `FormatStyle` or the corresponding formatter for:

- integers, decimals, percentages, and signs;
- currency and accounting values;
- dates, times, intervals, durations, and calendars;
- lists, person names, measurements, and units.

Do not manually append `%`, currency symbols, minus signs, dates, units, or list
separators. Their glyphs, spacing, order, and bidi interaction can vary.

Use the user's locale for presentation unless the product contract names
another locale, such as a server-defined market or document standard. Do not
derive a numbering system from “Arabic” alone; Arabic-speaking regions and
users can prefer different digits and separators.

## Diagnose bidi behavior

The Unicode Bidirectional Algorithm displays directional runs while preserving
logical storage order. Never reverse a Swift `String`, reverse grapheme
clusters, reorder punctuation, or reshape Arabic glyphs manually.

Reproduce difficult cases with:

- Arabic or Hebrew surrounding Latin product names;
- Western and Arabic-Indic digits;
- parentheses, brackets, quotes, colons, and trailing punctuation;
- percentages, currencies, measurements, and negative values;
- file paths, URLs, email addresses, phone numbers, and version strings;
- empty or weak-character prefixes;
- user-provided values whose language differs from the interface;
- multiple paragraphs with different first strong characters.

Identify the paragraph base direction, each inserted value's direction, neutral
characters, and the expected logical order before changing code.

Repair in this order:

1. keep one localizable whole message;
2. use typed interpolation and locale-aware formatting;
3. use a system text component and natural or content-aware behavior;
4. set an explicit paragraph writing direction when the content contract knows
   it;
5. isolate a dynamic field at the model or text-system boundary;
6. use Unicode bidi controls only with a documented invariant and focused
   mixed-direction tests.

Prefer modern isolates (`LRI`, `RLI`, `FSI`, `PDI`) over legacy embeddings when
manual control is unavoidable. Never persist presentation-only controls into
canonical identifiers without a deliberate protocol.

## Choose paragraph direction and alignment

Keep interface `layoutDirection`, paragraph writing direction, and text
alignment independent.

For apps built with the iOS 26 SDK, SwiftUI `Text`, `TextField`, and
`TextEditor` default to content-based paragraph writing direction. Use
`.writingDirection(strategy: .layoutBased)` only when the product requires the
paragraph to follow interface direction. Use `AttributedString.writingDirection`
for known per-paragraph direction.

Where the selected SDK provides `Text.AlignmentStrategy` and
`multilineTextAlignment(strategy:)`, choose between writing-direction-based and
layout-based alignment intentionally. For older SDK behavior, verify the
rendered result rather than assuming “natural” always means content-based or
always means interface-based.

Align long paragraphs to their language or resolved writing direction. Align
short labels and list items consistently with the component's UI design when
that improves scanning. Test multiline wrapping; a container's frame alignment
does not necessarily set alignment for the lines inside it.

For UIKit and TextKit, inspect the selected SDK's natural-alignment resolution
APIs and traits. Do not assume every component or SDK resolves
`NSTextAlignment.natural` by the same rule.

## Preserve editable-text semantics

Use system text input and TextKit 2 for mixed-direction editing. Test insertion,
selection, replacement, deletion, copy and paste, undo, marked text, dictation,
find and replace, and edit menus.

On supported current SDKs, natural bidi selection can produce multiple
discontiguous storage ranges. Use `UITextView.selectedRanges` and the matching
multi-range delegate methods for operations that mutate or inspect the selected
text. A single `selectedRange` can include content that is not visually
selected.

Avoid accessing `UITextView.layoutManager` when Natural Selection is required;
that access can switch the view to TextKit 1. Use `textLayoutManager` and
availability-gated TextKit 2 APIs instead.

Apply mutations in a way that remains correct for multiple nonoverlapping
ranges. Normalize and bounds-check ranges, preserve the system's insertion
decision, and test changes crossing LTR and RTL runs.

## Handle remote content and identifiers

When backend content can differ from the interface language, carry language and
base-direction metadata where the content contract knows it. Do not guess
direction from the first character when a title begins with a number, emoji,
punctuation, or brand name.

Render usernames, domains, links, email addresses, file names, and other
security-sensitive identifiers with explicit boundaries. Preserve a canonical
copy value, make the visible order unambiguous, and apply the product's Unicode
security policy for bidi controls and confusable characters.

Do not “sanitize” ordinary Arabic or Hebrew by stripping meaningful characters,
diacritics, joiners, or all bidi controls indiscriminately. Validate according
to the identifier's protocol and threat model.

## Require linguistic review

Treat machine or developer translation as a draft. Give translators screenshots,
comments, terminology, tone, interpolation meanings, and plural context. Ask
native speakers from supported regions to review natural wording, punctuation,
digits, typography, navigation expectations, and cultural imagery.

Record whether feedback covers Arabic, Hebrew, Persian, Urdu, or another
specific language and region. Do not generalize one review across distinct
scripts and cultures.
