# Testing matrix and completion evidence

Test Liquid Glass as adaptive system behavior. Combine semantic assertions,
functional flows, representative visual review, accessibility checks, and
proportionate performance evidence instead of relying on pixel snapshots alone.

## Contents

- Define runtime lanes
- Build and functional matrix
- Visual matrix
- Accessibility matrix
- Performance matrix
- Review checklist
- Completion record

## Define runtime lanes

Select only lanes supported by the product and requested toolchain:

1. **Oldest supported OS below iOS 26**: compile and exercise the complete fallback
   without unknown APIs, missing actions, or changed accessibility semantics.
2. **Stable iOS 26 family**: exercise native system adoption and every custom glass
   API used by the change.
3. **Latest supported stable OS**: detect changed system rendering or behavior
   without assuming the iOS 26 screenshot remains normative.
4. **Current prerelease OS**: add only when explicitly requested and a compatible
   beta toolchain is available; label all results with exact seed builds.

Never make a stable implementation incomplete merely because an unrequested beta
runtime is unavailable.

## Build and functional matrix

Use the project's documented commands. Record scheme, destination, build
configuration, Xcode, SDK, deployment target, and result.

Exercise the changed user journey and applicable states:

- initial, loading, content, empty, partial, error, offline, disabled, selected,
  and destructive confirmation;
- navigation push and pop, tab or sidebar switching, toolbar overflow, search focus
  and cancellation, sheet and popover presentation and dismissal;
- scrolling at and away from edges, rotation, compact and regular widths,
  multitasking or resizing, keyboard, pointer, and repeated input;
- appearance and disappearance of dynamic custom controls, interruption of any
  morphing, state restoration, backgrounding, and foregrounding;
- the old-system branch with the same action, state, focus, and semantics.

Prefer semantic UI assertions about labels, values, enabled states, navigation,
and actions. Use screenshot tests as change detectors, not the sole conformance
gate for a material that adapts to content and system settings.

## Visual matrix

Review light and dark appearance over representative bright, dark, quiet, busy,
text-heavy, image-heavy, and moving backgrounds. Include top and bottom scroll-edge
states, long localized labels, largest supported text sizes, selection, disabled
controls, sheets, search, and any edge-to-edge media.

Check hierarchy, legibility, clipping, overlap, safe areas, concentric geometry,
material grouping, tint meaning, and whether content remains primary. Compare
against current system behavior and product intent, not a fixed blur value.

Record device or Simulator, OS build, size or orientation, appearance, content
fixture, and accessibility settings for every captured artifact used as evidence.

## Accessibility matrix

Exercise Reduce Transparency, Increase Contrast, Reduce Motion, Dynamic Type,
VoiceOver, Voice Control, and keyboard or pointer input where supported. Run the
project's automated accessibility audit and inspect focus, labels, values, traits,
actions, hit targets, and reading order.

Treat the automated audit, Accessibility Inspector, Simulator VoiceOver, and
physical-device assistive-technology pass as separate evidence. Require the
physical-device pass before claiming production VoiceOver readiness.

## Performance matrix

Run performance captures only when the change has material rendering risk, a known
regression, or an explicit smoothness, memory, or power claim. Use a matched
baseline and candidate in a Release-like build on relevant hardware. Follow
`07-performance.md`; do not block a low-risk semantic correction on an unrelated
full Instruments campaign.

## Review checklist

Order findings by user impact:

- **Blocker**: action, navigation, fallback, data, accessibility, or supported
  runtime is unusable.
- **Major**: system ownership, hierarchy, legibility, adaptation, availability, or
  rendering behavior is materially wrong.
- **Minor**: a bounded inconsistency or maintainability issue with limited impact.
- **Craft**: optional refinement after the functional and evidence gates pass.

For every finding, name the affected state, concrete evidence, governing product or
platform principle, smallest complete correction, and validation needed.

## Completion record

Report:

- selected mode and in-scope flow;
- Xcode, SDK, deployment targets, frameworks, runtime lanes, device or Simulator,
  and build configuration;
- system roles restored and legacy customizations retained or removed;
- custom effects, variants, containers, identities, and fallbacks introduced;
- build and test commands with results;
- functional, visual, accessibility, and performance states actually exercised;
- trace or screenshot artifacts used as evidence;
- beta assumptions and remaining uncertainty.

Do not claim “native,” “accessible,” “smooth,” or “verified across devices” beyond
the evidence collected. Use “implementation complete; device visual and
performance verification pending” when build and source checks pass but runtime
evidence is unavailable.
