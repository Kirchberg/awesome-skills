---
name: ios-liquid-glass
description: Use when designing, auditing, implementing, migrating, reviewing, debugging, profiling, or testing Liquid Glass interfaces for iOS and iPadOS in SwiftUI, UIKit, or hybrid code. Trigger for iOS 26+ design adoption, latest-SDK visual regressions, glassEffect, GlassEffectContainer, glassEffectID, glassEffectUnion, glassEffectTransition, glass or glassProminent button styles, UIGlassEffect, UIGlassContainerEffect, UIBackgroundExtensionView, system bars, sheets, search, custom blur removal, availability fallbacks, accessibility settings, or glass-related hitches. Do not use for visionOS glassBackgroundEffect, artistic glass simulations or backports, app-icon-only work, or broad interface design with no Liquid Glass concern.
---

# Adopt and verify native Liquid Glass

## Define the outcome

Make the interface feel native on the selected SDK by restoring system ownership
of navigation and controls first, adding custom Liquid Glass only where it has a
functional role, preserving earlier-OS behavior, and validating the result across
content, accessibility settings, devices, and performance-sensitive interactions.

Treat Liquid Glass as a system-mediated interface material, not a recipe of blur,
opacity, gradients, and shadows. A compiling modifier is incomplete when it covers
content indiscriminately, duplicates a system surface, loses semantic control
behavior, breaks a fallback, or has only been judged from one screenshot.

## Read references selectively

- Read `references/00-current-platform-state.md` before selecting APIs, SDK behavior,
  deployment targets, availability branches, or prerelease features.
- Read `references/01-design-principles-and-hig.md` before deciding where glass
  belongs, selecting regular or clear glass, tinting, grouping, or reviewing fit.
- Read `references/02-audit-and-migration.md` before changing an existing app,
  removing legacy appearance code, or planning a staged migration.
- Read `references/03-swiftui-system-components.md` for navigation, tabs, sidebars,
  toolbars, search, presentations, background extension, and system-provided glass.
- Read `references/04-swiftui-custom-glass.md` for `glassEffect`, shapes, containers,
  unions, identities, transitions, button styles, modifier order, and fallbacks.
- Read `references/05-uikit-and-hybrid.md` for UIKit bars and presentations,
  `UIGlassEffect`, `UIGlassContainerEffect`, hosting boundaries, or mixed apps.
- Read `references/06-accessibility.md` before approving custom glass, color, motion,
  focus, semantics, or behavior under accessibility display settings.
- Read `references/07-performance.md` before diagnosing a hitch, changing effect
  topology for performance, or making a rendering, memory, or power claim.
- Read `references/08-testing-and-evidence.md` before defining a test matrix,
  reviewing completion evidence, or reporting implementation complete.
- Read `references/09-current-beta.md` only when the user or selected toolchain
  explicitly targets Xcode 27 or the 2027 prerelease OS generation.
- Read `references/sources.md` when a rule is version-sensitive, disputed,
  unfamiliar, or needs a primary source.

Repository instructions, product semantics, supported platforms, selected SDK,
deployment targets, and user scope override generic examples. Never raise a
deployment target, adopt a beta SDK, or change unrelated visual language silently.

## Route the request

Choose one lead mode:

- **Explain or design**: define the functional layer, component hierarchy,
  material policy, availability contract, and validation criteria without editing.
- **Audit or migrate**: inventory system and custom surfaces, identify conflicts,
  propose the staged end state, then edit only when requested.
- **Implement or refactor**: inspect the actual hierarchy and targets, apply the
  smallest complete native change, preserve fallbacks, and run available checks.
- **Review or diagnose**: report prioritized behavioral, design, availability,
  accessibility, and rendering findings without fixing unless requested.
- **Profile or test**: define a reproducible scenario and matched baseline before
  claiming a performance or visual regression is fixed.

In Implement or refactor mode, apply safe source-proven corrections when system
semantics, API usage, modifier order, or effect topology prove the issue. Reserve
device profiling for unknown causes, trade-offs, and quantified performance claims.

Lead with `$ios-liquid-glass` when material adoption is the core problem. Use
`$apple-platform-design` for whole-flow product design, `$swift-animation` for
motion mechanics, `$app-performance` for a wider app investigation,
`$voice-over-accessibility` for a semantic accessibility audit, and
`$swiftui-optimization` for broader invalidation or view-lifetime problems.

## Establish the adoption contract

Before editing, record or infer safely:

1. Identify the selected Xcode and SDK, deployment targets, supported devices,
   frameworks, and whether prerelease behavior is explicitly in scope.
2. Name the user-facing hierarchy: content, persistent navigation, contextual
   controls, primary action, presentations, and custom components.
3. Capture representative states and backgrounds, including scrolling edges,
   sheets, search, selection, loading, empty, error, and disabled states.
4. Inventory custom bars, blur or material stacks, borders, shadows, appearance
   overrides, visual-effect views, safe-area workarounds, and hosting boundaries.
5. Define the fallback behavior below iOS 26 and the evidence required for the
   latest supported release and any opted-in beta release.

Do not assume every existing translucent surface should become Liquid Glass.

## Follow the system-first migration sequence

1. Build with the selected current SDK and observe what standard components adopt
   automatically before changing code.
2. Restore semantic app structure with system navigation, tabs, sidebars, search,
   toolbars, controls, sheets, menus, and popovers wherever they express the role.
3. Remove only the legacy backgrounds, blur layers, borders, shadows, and
   appearance overrides that conflict with system rendering; preserve intentional
   brand and pre-iOS 26 fallback behavior.
4. Recheck layout, safe areas, scroll edges, toolbar grouping, presentations,
   search placement, and adaptive sizes before adding custom effects.
5. Add custom glass only to important functional elements that no system component
   expresses. Prefer a system button style over a manual effect on a button.
6. Group related effects in one container, keep identity stable, and add morphing
   only when it communicates a real hierarchy change.
7. Gate new APIs at the use site and provide a behaviorally complete fallback with
   standard components or `Material`; do not imitate Liquid Glass on old systems.
8. Build, exercise interactions, run accessibility checks, compare representative
   visual states, and profile only the scenarios whose claims require measurement.

## Use the component decision ladder

Choose the first option that expresses the product role:

1. A standard navigation, presentation, search, toolbar, tab, menu, or control.
2. A semantic system style such as `.buttonStyle(.glass)` or
   `.buttonStyle(.glassProminent)` when available.
3. A custom Liquid Glass control or control group using native effects.
4. A standard content material or opaque surface when the element belongs to the
   content layer.
5. No material when hierarchy, spacing, and typography already communicate enough.

Require a functional reason to move down the ladder.

## Apply hard guardrails

- Keep Liquid Glass primarily in the navigation and control layer. Do not turn
  every card, row, section, and background into glass.
- Prefer regular glass. Use clear glass sparingly over controlled, media-rich
  content; do not mix regular and clear variants in one related group.
- Avoid glass-on-glass. Put related effects in one `GlassEffectContainer` or
  `UIGlassContainerEffect` instead of creating many adjacent containers.
- Apply `.interactive()` or `isInteractive` only to an element that actually
  responds to touch, pointer, or focus.
- Use tint to communicate prominence, state, or a primary action. Never make tint
  the only carrier of state, and do not use it as ambient decoration.
- Apply `.glassEffect` after modifiers that establish the view's layout and base
  appearance so the effect follows the intended bounds and shape.
- Keep `glassEffectID`, unions, and transitions scoped to meaningful identities.
  Do not add them mechanically to every effect.
- Do not reproduce a remembered release with fixed opacity, blur radius,
  refraction, gradients, private layers, or screenshot-derived constants.
- Do not invent a universal maximum number of effects. Limit simultaneously
  visible effects, simplify topology, and measure the actual target scenario.
- Keep prerelease APIs isolated and replace beta assumptions with current SDK
  interface evidence whenever the toolchain changes.

## Verify and report honestly

Exercise the functional flow, old-system fallback, light and dark appearance,
representative quiet and busy backgrounds, text scaling, Reduce Transparency,
Increase Contrast, Reduce Motion, VoiceOver semantics, rotation or resizing, and
the slowest relevant device class available.

Do not use Simulator appearance, one screenshot, or average FPS as sole evidence.
Finish with the selected mode, SDK and deployment targets, hierarchy restored,
custom effects added or removed, fallback behavior, accessibility states checked,
builds and tests run, device or Simulator context, measurements collected, and
remaining runtime verification. Say “implementation complete; device visual and
performance verification pending” when those checks were not actually performed.
