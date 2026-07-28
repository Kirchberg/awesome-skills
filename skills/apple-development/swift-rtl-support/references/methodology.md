# RTL methodology

Use this workflow to turn an RTL request into a bounded semantic contract,
implementation, and evidence set.

## Contents

- Choose the operating mode
- Establish the baseline
- Classify direction before changing code
- Audit one flow end to end
- Prioritize findings
- Define completion honestly

## Choose the operating mode

Keep the requested authority explicit:

- For a plan, map states, risks, semantic categories, changes, and proof without
  editing.
- For an audit or review, inspect and reproduce defects without silently fixing
  them.
- For implementation, establish current LTR and RTL behavior, change the
  smallest complete unit, and verify both directions.
- For diagnosis, preserve the failing content and environment until the root
  mechanism is known.
- For testing, do not alter product behavior merely to make a test pass.

Separate RTL engineering from translation. An agent can prepare localization
infrastructure and identify missing translator context, but production wording
and cultural quality require the user's authorized translation process.

## Establish the baseline

Record facts before recommendations:

1. Read the root and nearest repository instructions.
2. Inspect the working tree and preserve unrelated changes.
3. Identify Xcode, Swift, SDK, deployment targets, and app platforms.
4. Identify SwiftUI, UIKit, TextKit, custom rendering, and third-party UI
   boundaries.
5. List supported languages and regions. Distinguish currently shipped support
   from aspirational support.
6. Reproduce the relevant screens in LTR, an RTL pseudolanguage, and any
   available real RTL localization.
7. Capture affected states: loading, empty, populated, long content, error,
   editing, selection, modal, navigation, and destructive confirmation.
8. Record existing tests, screenshots, translator guidance, String Catalogs,
   asset direction settings, and known exceptions.

Do not infer behavior solely from API names. Linkage against newer SDKs can
change default text-direction and alignment behavior while deployment targets
remain older.

## Classify direction before changing code

Assign each horizontal behavior one primary semantic category.

### Reading-flow

Mirror order, leading and trailing edges, navigation progression, and
directional affordances with the interface reading direction. Ordinary forms,
lists, disclosure, back and forward navigation, and story-like paging usually
belong here.

### Spatial

Keep physical left and right because the control describes a real-world or
screen-space direction. Examples include steering, alignment controls, a body
side, a map compass, and object movement in a fixed coordinate system.

### Playback

Keep the media-time model consistent unless the product domain explicitly
defines another convention. Group transport controls as playback instead of
forcing the whole screen to LTR.

### Time or calendar based

Inspect culture and task. Calendars, schedules, progressions, and temporal
charts can follow reading direction, chronological convention, or a
domain-specific axis. Do not decide from the word “time” alone.

### Content image

Keep photographs, posters, covers, logos, flags, artwork, and screenshots fixed
unless a localized composition is intentionally supplied.

### Directional asset

Mirror a simple reading-flow cue, or provide a purpose-built RTL variant when a
mechanical flip changes text, lighting, perspective, hand use, or cultural
meaning.

When a composite contains multiple categories, split it into smaller semantic
subtrees or assets. Do not force one direction policy across incompatible
children.

## Audit one flow end to end

Walk the user journey rather than searching only for `.left`:

1. Trace entry, navigation, focus, actions, validation, errors, and exit.
2. Inspect source order and visual order for every container.
3. Inspect fixed frames, offsets, transforms, manual paths, gesture signs,
   transition edges, scroll positioning, and custom paging.
4. Trace each user-visible message from source to String Catalog, interpolation,
   formatter, rendering, copying, editing, and accessibility output.
5. Classify each image, symbol, chart, and custom shape.
6. Exercise mixed-direction data and real script shaping.
7. Compare the same task in LTR to catch regressions introduced by the repair.

Searches for `left`, `right`, `offset`, `scaleEffect`, `layoutDirection`,
`semanticContentAttribute`, string concatenation, manual format strings, and
custom layout APIs are discovery aids, not proof of defects.

## Prioritize findings

Treat these as high priority:

- incorrect or destructive text editing and selection;
- navigation or actions whose visual direction contradicts behavior;
- unreadable, clipped, or corrupted user content;
- reversed physical or playback meaning;
- security-sensitive identifier spoofing or misleading bidi display;
- flows that cannot be completed in a supported RTL localization.

Treat cosmetic asymmetry as lower priority when meaning and task completion
remain intact. Report exact screen, state, locale, region, SDK, reproduction,
mechanism, and evidence for every finding.

## Define completion honestly

Require all of the following for an “RTL-ready” claim:

- the in-scope components have explicit semantic classifications;
- the feature works in both interface directions;
- real-language fixtures cover every claimed RTL localization;
- reusable or script-agnostic RTL claims additionally cover Arabic and Hebrew
  fixtures without implying that the product ships either localization;
- mixed-direction text and locale formatting preserve meaning;
- directional interactions and assets match their classifications;
- the supported layout and Dynamic Type matrix has passed;
- a qualified native speaker has reviewed each claimed language and relevant
  region for linguistic and cultural quality;
- remaining exceptions and unsupported configurations are recorded.

If any gate is missing, use a narrower statement such as “code and automated
checks complete; real-device and linguistic verification pending.”
