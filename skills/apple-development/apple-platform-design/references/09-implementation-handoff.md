# Translate design intent into production constraints

Map an approved design to existing architecture, native components, semantic
tokens, availability, assets, and testable behavior. Preserve intent without
turning a design snapshot into brittle pixel reproduction.

## Contents

- Inspect the implementation environment
- Map intent to native structure
- Define semantic design-system inputs
- Handle evolving appearance
- Work with design tools and production assets
- Define and verify the handoff

## Inspect the implementation environment

Before naming APIs or editing code, identify:

- target platforms, device classes, deployment targets, and selected SDK;
- Swift, Xcode, SwiftUI, UIKit, AppKit, Catalyst, or mixed-framework boundaries;
- navigation and presentation architecture;
- existing design-system components, semantic tokens, assets, localization, and
  accessibility conventions;
- repository build, preview, snapshot, UI-test, and device-test commands.

Do not recommend a release-specific API until its availability and behavior are
checked against the project's SDK and minimum OS. Define a fallback or constrain
the feature to the supported range.

## Map intent to native structure

1. Name the user goal and interaction contract before naming a framework type.
2. Match navigation, presentation, selection, search, menus, controls, and
   feedback to the current native component that owns the expected behavior.
3. Style the component through supported APIs before replacing it.
4. For custom UI, document the missing native capability, product benefit,
   state model, semantics, input behavior, and platform adaptations.
5. Keep persistent navigation, transient presentation, and content actions
   separate in both design and code.
6. Preserve system behaviors for focus, keyboard, pointer, remote, gaze,
   accessibility, localization, state restoration, and scene changes.

In SwiftUI, model UI from state and use the platform's navigation,
presentation, toolbar, search, control, layout, and feedback APIs appropriate
to the selected SDK. Keep availability branches explicit and avoid using view
modifiers as decorative patches for a structurally wrong component.

In UIKit or AppKit, use the relevant controller, bar, presentation, menu,
control, layout, and configuration APIs so system behavior can adapt. Do not
rebuild a navigation or control stack from generic views solely to match a
static comp.

## Define semantic design-system inputs

Specify roles rather than isolated values:

- content and control hierarchy;
- text roles and scaling behavior;
- foreground, background, fill, separator, tint, status, and selection roles;
- spacing, grouping, shape, elevation, and material roles;
- component size, emphasis, state, and input variants;
- motion and feedback semantics;
- platform, appearance, contrast, locale, and content-size adaptations.

Resolve actual values from current system behavior, the target Apple UI kit,
and the product's existing design system. Do not freeze observed system
dimensions into custom tokens without a product need and a version strategy.

## Handle Liquid Glass and evolving appearance

Treat Liquid Glass and later system materials as functional interface layers.
Use current framework APIs so optical behavior, accessibility, and platform
adaptation remain system-owned. Remove obsolete custom bar backgrounds or
borders only after verifying hierarchy and contrast in the supported OS range.

Do not emulate a newer material with static blur, opacity, gradients, or
screenshots on older systems. Design an intentional fallback that preserves
structure and emphasis.

## Work with design tools and production assets

- Start from the project's component library when it represents the shipped
  product.
- Use the current official Apple Design Resources for the target platform and
  release to inspect system anatomy and create platform mockups.
- Link to Apple UI kits, templates, fonts, and resources; do not copy or
  redistribute them in a skill or repository.
- Use SF Symbols through supported variants, rendering, localization, and
  accessibility behavior. Verify the symbol exists in the target OS range.
- Prepare app icons with the current Apple template or Icon Composer workflow
  when supported, then verify all required appearances and export paths.
- Distinguish design assets, in-app assets, and flattened marketing exports.

When using Figma or another design tool, reuse existing variables and
components, represent states and responsive behavior, and annotate platform and
version scope. A screenshot is a reference, not the component source of truth.

## Define the handoff

For every screen or component, include:

- anatomy and ownership;
- inputs, outputs, actions, and state transitions;
- applicable loading, empty, partial, error, offline, restricted, and completed
  states;
- adaptive layout and platform variants;
- copy and localization behavior;
- accessibility semantics, focus, and alternative interactions;
- animation, interruption, feedback, and reduced-motion behavior;
- availability, fallback, assets, analytics, privacy, and acceptance criteria.

Avoid speculative analytics events or data practices. Record product decisions
that require an owner rather than silently encoding them in UI.

## Verify the implementation

Build affected targets and exercise the actual flow with representative data.
Compare structure and intent before pixel detail. Cover supported device and
window classes, appearances, content sizes, contrast and motion settings,
locales, input methods, permissions, network states, and interruption paths.

Use previews and snapshots for breadth, UI tests for stable behavior, and manual
device review for interaction, motion, haptics, assistive technology, and
material appearance. Report measured evidence and remaining gaps; do not claim
design fidelity from a compiling view alone.
