---
name: ios-accessibility
description: Use when planning, auditing, implementing, fixing, or reviewing VoiceOver accessibility in iOS or iPadOS apps built with SwiftUI, UIKit, or mixed UI. Applies to accessibility trees, labels, values, hints, traits, actions, reading and rotor order, grouping, focus, announcements, text entry, custom controls and gestures, manual device testing, Accessibility Inspector, and UI-test audits. Trigger for requests such as "make this screen work with VoiceOver", "audit this SwiftUI flow for screen-reader users", "fix the accessibility order", or "add accessible actions to this custom control". This first version is VoiceOver-only; do not use for Dynamic Type, contrast, color, motion, captions, Voice Control, Switch Control, macOS VoiceOver, Android TalkBack, or web screen readers unless the request also contains an iOS or iPadOS VoiceOver task.
---

# Build VoiceOver-ready iOS interfaces

## Outcome

Make every in-scope common task understandable and operable with VoiceOver
alone, without sighted assistance. Produce the smallest semantic or interaction
change that restores equivalent information, navigation, actions, and feedback,
then report exactly what was and was not verified.

## Keep the first-version boundary

Cover VoiceOver on iOS and iPadOS in SwiftUI, UIKit, or mixed interfaces. Record
adjacent accessibility defects when they block the VoiceOver task, but do not
expand the work into Dynamic Type, contrast, color, motion, captions, Voice
Control, Switch Control, macOS VoiceOver, TalkBack, or web screen readers unless
the user explicitly adds that scope.

## Read references selectively

- Read `references/methodology.md` before planning an audit, changing code, or
  deciding whether the available evidence proves completion.
- Read `references/semantics-and-navigation.md` before defining labels, roles,
  values, hints, grouping, order, focus, rotors, actions, or announcements.
- Read `references/swiftui-and-uikit.md` before implementing or reviewing
  framework-specific accessibility code.
- Read `references/testing-and-evidence.md` before manual VoiceOver testing,
  Accessibility Inspector work, automated audits, or acceptance reporting.
- Read `references/source-map.md` when a recommendation is disputed,
  version-sensitive, or needs a primary or practical source.

Repository instructions, supported deployment targets, established
architecture, and explicit user scope override generic examples. They do not
weaken the VoiceOver-only common-task completion gate.

## Classify the request

Choose one mode before acting:

- **Plan**: inventory tasks, states, risks, proposed semantics, and validation;
  do not edit or claim that testing ran.
- **Audit**: inspect and reproduce VoiceOver barriers; do not implement fixes
  unless the request includes them.
- **Implement**: establish a baseline, make the smallest in-scope correction,
  and verify it.
- **Review**: inspect the supplied change for VoiceOver regressions and report
  evidence-backed findings without changing code.

Do not infer permission to redesign unrelated UI, publish a build, or certify
App Store accessibility support.

## Establish the VoiceOver contract

1. Read the root and nearest repository instructions and supported commands.
2. Identify the affected target, iOS or iPadOS versions, Xcode and Swift
   versions, SwiftUI/UIKit boundary, devices, locales, and user journey.
3. List the common tasks and relevant states for each in-scope screen, including
   loading, empty, populated, error, modal, refreshed, and destructive states.
4. Define acceptance as completing those tasks on every supported device type
   using only VoiceOver, with all important information spoken or available in
   braille, every action discoverable and operable, and focus remaining logical.
5. Record which evidence already exists. Treat an Inspector screenshot, an
   automated audit, or a visual code review as partial evidence, not a manual
   VoiceOver pass.

## Inspect the semantic interface

For each relevant state, inspect the accessibility tree and walk the experience
without relying on the visual layout:

- map each meaningful element to its name, role, value or state, actions, and
  relationship to surrounding content;
- identify decorative or duplicate stops, missing visible information,
  ambiguous repeated actions, stale state, and inaccessible custom drawing;
- traverse forward and backward for skips, loops, traps, unexpected order, and
  focus entering hidden, offscreen, or background content;
- exercise activation, adjustment, text entry, custom gestures, context menus,
  modal dismissal, refresh, pagination, and error recovery;
- distinguish a missing semantic property from a structural or interaction
  problem before editing labels.

## Implement the smallest complete correction

1. Prefer a native control and its styling APIs over recreating behavior with a
   shape, gesture, or tap handler.
2. Preserve correct automatic semantics. Add or override only information that
   is missing, wrong, ambiguous, or inefficient.
3. Keep a concise localized label separate from role, dynamic value or state,
   and an optional outcome-oriented hint.
4. Group related content to reduce noise without hiding independent actions.
   Keep reading order logical in both directions; use sort priority only inside
   a deliberate container when structure cannot express the order.
5. Make the default activation match the ordinary tap. Expose nonstandard,
   long-press, drag, multidimensional, or secondary behaviors through
   discoverable custom, adjustable, escape, or rotor actions as appropriate.
6. Move focus only for a real context transition or high-priority event.
   Announce important status changes without interrupting current reading or
   flooding speech.
7. Keep modals isolated from background content and preserve focus across
   refresh, insertion, deletion, pagination, and asynchronous updates.
8. Localize user-facing accessibility text and verify that semantics stay
   correct as content and state change.

## Verify proportionally

For changed code, run the repository's formatting, build, and focused tests.
Inspect the resulting accessibility tree and run supported automated
accessibility audits for representative screens and states.

For a completion claim, also use VoiceOver on a physical device:

1. enable hints when the app provides them and turn on Screen Curtain;
2. complete every in-scope common task without looking at the screen;
3. traverse each screen forward and backward, then use touch exploration;
4. exercise headings and actions rotors, activation, adjustable controls, text
   input, destructive actions, custom interactions, and modal escape;
5. repeat on each supported device type whose layout or interaction differs.

If physical-device testing cannot run, report the limitation and stop short of
claiming VoiceOver readiness or App Store support.

## Apply hard guardrails

- Do not use `accessibilityIdentifier` as a user-facing label.
- Do not put control type, selected state, value, or gesture instructions in a
  label when the platform can express them semantically.
- Do not add a hint when the label, role, and context already explain the
  result; users can disable hints.
- Do not hide a meaningful child or gesture without exposing equivalent
  information and actions.
- Do not force focus after every update, reorder an entire screen with numeric
  priorities, or announce every rapidly changing value.
- Do not assume an SF Symbol name, visible text, framework default, or custom
  control is correct without hearing the resulting VoiceOver experience.
- Do not treat zero automated-audit findings as proof that a workflow is usable.
- Do not generalize iOS VoiceOver behavior to TalkBack or another platform.

## Report completion

State the selected mode, scope, common-task contract, inspected states, and
baseline barriers. For implementation, list changed files and explain the
semantic or interaction mechanism. Report build and test results, Inspector or
automated-audit results, manual device and OS, VoiceOver settings, Screen
Curtain status, tasks passed, focus and rotor checks, and remaining risks.

Use “implemented; manual VoiceOver verification pending” when device evidence is
missing. Reserve “VoiceOver-ready for the in-scope tasks” for a successful
physical-device pass, and do not claim broader accessibility certification.
