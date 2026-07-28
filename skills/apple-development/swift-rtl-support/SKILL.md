---
name: swift-rtl-support
description: Use when planning, designing, implementing, debugging, auditing, reviewing, or testing right-to-left support in SwiftUI, UIKit, or mixed iOS and iPadOS apps. Trigger for RTL or right-to-left layout, Arabic, Hebrew, Persian, Urdu, bidirectional or bidi text, layoutDirection, writing direction, semanticContentAttribute, leading and trailing constraints, mirrored navigation or gestures, localized assets and SF Symbols, locale-aware numbers or dates, custom collection layouts, and RTL regression testing. Use for both new features and existing-screen audits; do not treat translation alone or a global horizontal flip as complete RTL support.
---

# Build native RTL support for Swift interfaces

## Define the outcome

Make every in-scope flow feel native in both left-to-right and right-to-left
contexts. Preserve semantic reading order, physical meaning, text integrity,
localized formatting, asset intent, interaction direction, and typography.

Treat a clean build or a mirrored screenshot as partial evidence. Completion
requires representative real-language content and interaction testing.

## Read references selectively

- Read `references/methodology.md` before planning an audit, classifying a
  component, changing code, or deciding whether evidence proves completion.
- Read `references/layout-and-navigation.md` for semantic geometry, custom
  layouts, navigation, paging, gestures, transitions, collections, and charts.
- Read `references/text-and-formatting.md` for String Catalogs, interpolation,
  bidi text, writing direction, formatting, text editing, and identifiers.
- Read `references/swiftui-and-uikit.md` before implementing or reviewing
  framework-specific APIs and availability-sensitive behavior.
- Read `references/assets-and-typography.md` for images, SF Symbols, custom
  shapes, Arabic and Hebrew typography, and directional artwork.
- Read `references/testing-and-evidence.md` before previews, scheme testing,
  UI tests, screenshots, linguistic QA, or completion reporting.
- Read `references/sources.md` when a claim is version-sensitive, disputed, or
  needs a primary Apple, Unicode, or W3C source.

Repository instructions, supported deployment targets, selected SDK behavior,
and explicit user scope override generic examples. They never weaken the
real-language, bidi-integrity, or truthful-evidence gates.

## Route the request

Choose one lead mode:

- **Explain or design**: define semantic direction and tradeoffs; do not edit.
- **Audit or review**: inspect code and behavior, then report prioritized,
  evidence-backed findings without implementing unless requested.
- **Implement or fix**: establish a baseline, make the smallest complete
  correction, and verify it proportionally.
- **Diagnose**: reproduce the RTL-only failure and identify its semantic,
  localization, text-system, asset, or interaction root cause.
- **Test**: build a locale and device matrix, run it, and report exact evidence.

Do not infer permission to translate production copy, redesign unrelated UI,
publish a build, or certify every supported language.

## Establish the RTL contract

1. Read repository instructions and inspect version-control status.
2. Record the Xcode and SDK versions, deployment targets, UI framework
   boundaries, supported languages and regions, devices, size classes, and
   affected user journeys.
3. Inventory user-visible strings, dynamic values, editable or remote text,
   assets, custom drawing, custom layouts, navigation, gestures, paging,
   animations, charts, playback, and spatial controls.
4. Classify each horizontal behavior as **reading-flow**, **spatial**,
   **playback**, **time or calendar based**, **content image**, or
   **directional asset**. Default ordinary interface flow to reading-flow;
   require evidence for an exception.
5. Define acceptance for layout, text, assets, formatting, interactions,
   typography, and testing before editing.

Keep three concepts separate:

- **Interface layout direction** controls semantic leading and trailing order.
- **Paragraph writing direction** controls directional runs and base direction.
- **Text alignment** controls where laid-out lines sit inside their container.

Do not derive all three from the selected app language. Current SDK behavior,
the string's content, explicit paragraph attributes, and component semantics
can resolve them differently.

## Implement semantic layout

- Prefer standard SwiftUI and UIKit components and let them adapt naturally.
- Use `leading` and `trailing` for reading-flow geometry. Keep `left` and
  `right` only for intentionally physical sides.
- Scope any `layoutDirection` override or `semanticContentAttribute` to the
  smallest spatial or playback component that requires it.
- Inspect custom `Layout`, manual coordinates, offsets, Canvas drawing,
  collection layouts, snapping, page indicators, drag thresholds, transition
  edges, and animation signs explicitly.
- Preserve the system behavior of navigation controllers, lists, collections,
  page controllers, and standard controls unless a reproduced defect proves an
  override is necessary.

Never mirror a complete screen with `scaleEffect(x: -1)` or an equivalent view
transform. It reverses text, artwork, physical symbols, and input behavior.

## Preserve text and locale semantics

- Keep text in logical storage order; never reverse strings or reorder scalars.
- Use localizable whole messages and translator-controlled placeholders. Do
  not concatenate localized fragments or manually pluralize.
- Use Foundation formatters and `FormatStyle` for numbers, percentages,
  currency, dates, times, lists, names, and measurements. Do not append symbols
  or units manually.
- Prefer system text layout and natural or content-aware direction. Add
  paragraph direction or Unicode isolation only after diagnosing a concrete
  mixed-direction case.
- Treat locale and language as separate inputs. Test regional preferences for
  digits, calendars, separators, currencies, and units.
- Preserve TextKit 2 and multi-range selection for editable bidi text where the
  selected SDK supports Natural Selection.

## Decide every asset deliberately

For each image or symbol, first choose exactly one direction policy:

- **Fixed** because it is content, a logo, or a physical direction;
- **Mirrors** because a mechanical flip safely follows reading flow;
- **Both** because purpose-built LTR and RTL renditions are required.

Then decide independently whether the asset also needs language- or
region-localized variants.

Use semantic SF Symbol names such as `forward` and `backward` for reading flow,
and physical `left` or `right` names only for absolute direction. Verify Arabic
joining, diacritics, line height, tracking, fallback fonts, emphasis, and
localized symbol variants; verify Hebrew independently rather than treating all
RTL scripts as Arabic.

## Verify the minimum matrix

Run both Right-to-Left Pseudolanguage modes available in the selected Xcode, then
test every supported RTL localization with representative real-language
content. For a reusable component or general RTL-readiness claim, also include
real Arabic and real Hebrew developer fixtures even when the product does not
ship full localizations for both. Cross each claimed language with relevant
regional preferences.

Include mixed RTL and LTR text, digits, punctuation, parentheses, user names,
URLs, empty and error states, long strings, Dynamic Type, portrait and
landscape, compact and regular widths, and every directional gesture,
transition, carousel, pager, image, symbol, chart, and playback control.

Use previews and static screenshots for breadth, UI tests for interaction
regressions, and simulated or physical devices for final behavior. Require a
qualified native-speaker review for every claimed language and relevant region.

## Apply hard guardrails

- Do not globally force `.rightToLeft` or `.leftToRight` to patch one component.
- Do not replace semantic anchors mechanically without checking physical intent.
- Do not assume all images, charts, arrows, timelines, or numbers share one
  mirroring policy.
- Do not hard-code Arabic-Indic or Western digits from the UI language.
- Do not use legacy bidi embeddings or marks as the first repair.
- Do not claim RTL readiness from pseudolocalization alone.
- Do not claim linguistic correctness without qualified human review.

## Report completion

State the selected mode, SDK and deployment baseline, locales and regions,
component classifications, changed or reviewed files, validation commands,
devices and configurations, real-language and bidi cases, interaction checks,
linguistic review, and remaining risks.

Use “implemented; RTL device verification pending” when device evidence is
missing. Reserve “RTL-ready for the in-scope flows” for a successful minimum
matrix across every claimed RTL localization. Require Arabic and Hebrew
fixtures as an additional gate only for reusable or general RTL-support claims,
and scope every claim to what was actually tested.
