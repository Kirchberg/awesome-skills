---
name: apple-platform-design
description: Use when designing, redesigning, planning, implementing, or reviewing product experiences for Apple platforms, including iOS, iPadOS, macOS, watchOS, tvOS, and visionOS. Applies to user goals, information architecture, navigation, layout, system components, design systems, Liquid Glass, typography, color, materials, writing, onboarding, search, motion, haptics, accessibility, inclusion, privacy, app icons, responsive cross-device adaptation, SwiftUI/UIKit/AppKit handoff, and design critiques. Trigger for requests to create an Apple-platform screen or flow, make an interface feel native, choose between system and custom UI, audit a design against Apple HIG, translate a design into implementation guidance, or review visual and interaction quality.
---

# Design native Apple-platform experiences

## Outcome

Turn a user goal into an intentional, familiar, adaptable Apple-platform
experience. Produce the smallest coherent design that solves the task, uses
system behavior where it fits, expresses the product's identity without
breaking platform conventions, and maps honestly to implementation and
validation.

## Read references selectively

- Read `references/00-design-principles.md` before defining the product intent,
  choosing between competing directions, or expressing brand.
- Read `references/01-information-architecture-and-navigation.md` before
  changing hierarchy, navigation, search, modality, or cross-device structure.
- Read `references/02-layout-and-visual-hierarchy.md` before specifying layout,
  adaptivity, content priority, density, or responsive behavior.
- Read `references/03-components-and-patterns.md` before selecting or creating
  controls, bars, menus, sheets, gestures, states, or other interaction patterns.
- Read `references/04-color-typography-and-materials.md` before defining visual
  language, semantic color, type, symbols, imagery, materials, or Liquid Glass.
- Read `references/05-writing-and-naming.md` before writing labels, actions,
  onboarding, errors, empty states, feature names, or localization-sensitive UI.
- Read `references/06-onboarding-and-discoverability.md` before adding
  tutorials, tips, permissions education, contextual help, or empty-state calls
  to action.
- Read `references/07-motion-feedback-and-haptics.md` before specifying
  animation, transitions, sound, haptics, gesture physics, or reduced-motion
  behavior.
- Read `references/08-accessibility-inclusion-and-privacy.md` before approving a
  design, changing interaction semantics, collecting data, or requesting system
  permission.
- Read `references/09-implementation-handoff.md` before mapping a design to
  SwiftUI, UIKit, AppKit, a design system, app icons, or production assets.
- Read `references/10-design-review-checklist.md` before a critique, audit,
  approval, or completion claim.
- Read `references/sources.md` when a recommendation is disputed,
  version-sensitive, availability-sensitive, or needs primary evidence.

## Set authority and scope

1. Read repository instructions and inspect the existing product, design system,
   supported platforms, deployment targets, SDK, frameworks, and test workflow.
2. Treat explicit user and repository requirements as product constraints.
   Reconcile them with current platform behavior; surface conflicts instead of
   silently replacing either side.
3. Prefer current Apple HIG, current SDK documentation, current Apple Design
   Resources, and relevant WWDC sessions over remembered dimensions or old
   screenshots. Verify version-sensitive details at task time.
4. Separate documented platform guidance, observed product evidence, design
   judgment, and unresolved assumptions.
5. Do not infer authority to redesign unrelated flows, change product policy,
   implement code during an audit, or publish artifacts.
6. Use a narrower implementation, accessibility, localization, animation, or
   performance skill when the task needs depth beyond this product-design layer.

## Choose the working mode

- **Design**: define a new feature, flow, screen, component, or design-system
  pattern and its relevant states.
- **Review**: inspect an existing artifact or implementation and report
  evidence-backed findings without editing unless fixes are requested.
- **Redesign**: preserve the product goal and required behavior while correcting
  structure, discoverability, interaction, or visual hierarchy.
- **Implementation handoff**: translate an approved direction into components,
  semantics, availability, assets, and validation criteria; implement only when
  the request includes code changes.

State the mode when it affects what actions are authorized.

## Establish the design contract

Capture or state reasonable assumptions for:

- the primary user, their goal, context, and successful outcome;
- the platform, device classes, window sizes, orientation, and input methods;
- the content model, data density, task frequency, and destructive consequences;
- the supported OS range, implementation framework, existing components, and
  brand constraints;
- accessibility, localization, privacy, offline, permission, and account needs;
- the evidence available and the questions that remain unresolved.

Do not block on every missing preference. Continue with reversible assumptions
when they do not materially change the product direction, and label them.

## Design from purpose to polish

1. **Define purpose and agency.** Write the user problem and the one primary
   outcome before drawing a screen. Preserve choice, undo, recovery, and an
   understandable way out.
2. **Model the flow.** Map entry, decision, completion, cancellation, and
   recovery. Define applicable `initial`, `loading`, `content`, `empty`,
   `partial`, `error`, `offline`, `restricted`, and `completed` states.
3. **Choose structure.** Establish information hierarchy and navigation before
   styling. Keep persistent navigation distinct from contextual actions.
4. **Prefer system patterns.** Check the current HIG and available system
   component before proposing custom UI. Require a user or product benefit for
   every custom behavior.
5. **Compose the interface.** Let content lead. Use layout, grouping, semantic
   type, color, symbols, and materials to express hierarchy across supported
   sizes and appearances.
6. **Specify behavior.** Define copy, search, focus, gestures, feedback,
   interruption, reduced-motion behavior, and recovery together with visuals.
7. **Build responsibility in.** Design accessibility, localization, inclusion,
   privacy, permissions, and data minimization before visual polish is approved.
8. **Map to production.** Name system components and semantic tokens, identify
   availability and fallbacks, and define what must be tested in code and on
   devices.
9. **Review twice.** First review purpose, flow, hierarchy, navigation, and
   discoverability. Then review spacing, typography, color, materials, motion,
   haptics, copy, and craft.

## Apply hard guardrails

- Do not make an interface “Apple-like” by copying decoration while ignoring
  purpose, content, behavior, and platform conventions.
- Do not replace a familiar system component merely to look different.
- Do not use Liquid Glass as a decorative background for all content; treat it
  as a functional interface layer and verify current platform guidance.
- Do not compensate for hidden actions with a mandatory startup tutorial.
  Improve discoverability first, then use contextual progressive disclosure.
- Do not show a tip after the person has learned or used the feature; define
  eligibility, frequency, and invalidation.
- Do not make a hidden gesture, color, motion, sound, or haptic the only way to
  discover information or complete a critical action.
- Make meaningful motion explain state or space, remain interruptible where
  interaction requires it, and provide a Reduce Motion alternative.
- Preserve feedback already supplied by system controls. For app-triggered
  ordinary events, use the appropriate semantic or standard platform feedback;
  reserve custom haptic composition for a justified tactile language.
- Do not hard-code remembered dimensions, appearance details, or API
  availability as timeless Apple rules.
- Do not claim usability, accessibility, localization, or platform conformance
  from a static review alone.

## Deliver an actionable result

For design or redesign work, report:

- goal, assumptions, constraints, and rejected alternatives;
- flow, screen anatomy, primary action, navigation, and applicable state model;
- component choices and the product reason for any custom UI;
- adaptive, writing, accessibility, privacy, motion, and feedback behavior;
- implementation mapping, availability risks, and validation criteria.

For reviews, order findings by user impact. Attach each finding to concrete
evidence, explain the violated goal or platform principle, and recommend the
smallest complete correction. Distinguish blockers, major issues, minor issues,
and optional craft opportunities.

For implementation work, list changed files and report the builds, tests,
runtime states, devices, appearances, content sizes, locales, assistive
settings, and remaining gaps actually verified. Use “implementation complete;
runtime design verification pending” when device or artifact evidence is
missing.
