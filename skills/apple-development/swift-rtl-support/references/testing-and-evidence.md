# RTL testing and evidence

Use pseudolocalization for breadth and real languages for bidi, typography,
regional formatting, and cultural behavior.

## Contents

- Establish the test baseline
- Run pseudolanguages
- Run real language and region combinations
- Exercise bidi data
- Cover layout and interaction
- Automate durable regressions
- Complete linguistic QA
- Report only supported claims

## Establish the test baseline

Before changing code:

1. build the affected target with the repository's supported command;
2. capture representative LTR and RTL behavior;
3. record OS, device, SDK, app language, region, content, and state;
4. reproduce each reported defect without adding a global direction override;
5. identify existing unit, snapshot, UI, and localization tests.

After changing code, rerun the same LTR scenario to detect regressions. Compare
equivalent content and state rather than unrelated screenshots.

## Run pseudolanguages

Use the selected Xcode's available schemes, including:

- Right-to-Left Pseudolanguage;
- Right-to-Left Pseudolanguage With Right-to-Left Strings;
- Double-Length and Bounded String pseudolanguages for layout stress;
- Accented Pseudolanguage when vertical glyph bounds are relevant.

Treat RTL pseudolanguages as layout and extraction smoke tests. They do not
prove Arabic shaping, Hebrew punctuation, real plural forms, preferred digits,
translation quality, or cultural navigation expectations.

## Run real language and region combinations

At minimum, exercise:

- the base LTR language and region;
- every RTL language the product claims to support in each relevant region;
- multiple regional or numbering-system configurations where the product's
  locale contract can produce different output;
- real Arabic and real Hebrew developer fixtures for reusable components or a
  general, script-agnostic RTL-support claim; these fixtures do not authorize
  shipping unreviewed translations;
- an RTL app language with a different regional preference;
- an LTR app language with a region commonly associated with an RTL language,
  when the product supports those settings.

Keep language and region controls separate in Xcode schemes or Test Plans.
Verify calendars, digits, decimal and grouping separators, currency, units,
dates, and time independently from interface direction.

## Exercise bidi data

Include deterministic fixtures for:

- pure Arabic, Hebrew, and Latin paragraphs;
- Arabic or Hebrew containing Latin brand and product names;
- an LTR sentence containing an RTL name or quotation;
- strings beginning with a digit, emoji, bracket, quote, or punctuation;
- parentheses, paired punctuation, slash, colon, plus and minus signs;
- integers, decimals, percentages, currency, units, dates, and times;
- plural values relevant to the supported language, including Arabic zero,
  one, two, few, many, and other categories;
- phone numbers, email addresses, URLs, file paths, and version strings;
- user content and security-sensitive identifiers with bidi controls or
  confusable characters;
- multiple paragraphs with different base directions.

For editable text, test keyboard switching, insertion, cursor motion, natural
selection, replacement, deletion, copy and paste, undo, marked text, edit
menus, and find and replace. On iOS 26, include a TextKit 2 case whose visual
selection maps to multiple `selectedRanges`.

## Cover layout and interaction

Run the supported extremes:

- the narrowest supported iPhone width;
- portrait and landscape;
- compact and regular widths;
- iPad split, resizable, or multitasking configurations in scope;
- default and largest supported Accessibility Dynamic Type sizes;
- minimum supported OS and a current OS;
- short, long, multiline, empty, loading, error, and dense-content states.

Exercise:

- push, pop, interactive back, modal presentation, and dismissal;
- horizontal scroll, page controls, carousels, snapping, and scroll restoration;
- custom drag, swipe, drawer, and transition behavior;
- spatial controls and physical left or right actions;
- playback controls and time scrubbers;
- chronological charts, calendars, legends, and selection;
- menus, toolbars, context actions, and keyboard navigation where supported.

Inspect every image as Fixed, Mirrors, Both, or localized. Check SF Symbols,
custom shapes, gradients, shadows, logos, photos, and images containing text.
Verify Arabic and Hebrew line height, diacritics, joining, fallback, truncation,
and emphasis.

When accessibility is in scope, verify semantic reading and focus order after
visual reordering. Do not assume the mirrored visual hierarchy produces the
correct accessibility traversal.

## Automate durable regressions

Use the narrowest useful layer:

- unit-test locale-aware formatting and direction-mapping helpers;
- snapshot representative screens in LTR and real RTL configurations;
- use UI tests for gestures, navigation, paging, selection, and screenshots;
- use Xcode Test Plans to vary language, region, device, orientation, and text
  size without duplicating test logic;
- attach deterministic screenshots for developers, translators, and reviewers.

Keep snapshot hosts honest. Set both locale and layout direction only when the
test intends to control both. A forced direction with English-only data can
hide content-based writing-direction defects.

Avoid asserting raw localized prose when a semantic or structured assertion is
more durable. Preserve a small set of explicit bidi fixtures because generated
random strings are hard to review.

## Complete linguistic QA

Give reviewers:

- production strings and screenshots in context;
- translator comments and interpolation meanings;
- terminology, tone, product names, and nontranslatable terms;
- device and region information;
- a simple path for screenshot-backed feedback, such as TestFlight.

Require a qualified native speaker for each claimed language and relevant
region. Ask reviewers to cover wording, punctuation, plural forms, digits,
typography, icon meaning, navigation expectations, and cultural imagery. Do not
use one Arabic, Hebrew, Persian, or Urdu review as evidence for another.

Machine translation and pseudolocalization do not satisfy this gate.

## Report only supported claims

Report:

- source and test commands with pass or fail results;
- app language, region, OS, device, orientation, size class, and Dynamic Type;
- screens, states, bidi fixtures, interactions, and assets covered;
- intentional spatial, playback, fixed-image, and chart exceptions;
- real-language and native-speaker review status;
- failures, skipped configurations, unsupported targets, and residual risk.

Use “implemented; RTL device verification pending” when only code and static
checks ran. Use “automated RTL matrix passed; linguistic QA pending” when
automation passed without a native speaker. Use “RTL-ready for the in-scope
flows” only after the documented minimum matrix and linguistic gate pass.
