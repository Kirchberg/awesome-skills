---
name: swift-animation
description: Use when designing, implementing, refactoring, reviewing, debugging, profiling, or testing animations and transitions in SwiftUI, UIKit, AppKit, or Core Animation across Apple platforms. Trigger for withAnimation, Animation, Transaction, Animatable, PhaseAnimator, KeyframeAnimator, matchedGeometryEffect, contentTransition, UIView.animate, UIViewPropertyAnimator, NSAnimationContext, view-controller transitions, CALayer or CAAnimation, springs, gesture-driven or interruptible motion, velocity continuity, system-transition coordination, CADisplayLink, UIUpdateLink, TimelineView, Reduce Motion, animation hitches, rendering or power cost, and animation regression tests. Do not use for RealityKit, Metal, SpriteKit, SceneKit, animated media content, or whole-app performance work where motion is only one symptom.
---

# Build fluid, interruptible Apple animations

## Define the outcome

Create motion that explains a state change, preserves direct manipulation,
remains coherent when interrupted, adapts to accessibility settings, respects
the selected SDK and deployment target, and meets a measured frame and power
budget.

Treat animation as a state transition rather than delayed visual side effects.
A compiling effect is incomplete when it snaps during retargeting, ignores
Reduce Motion, runs while hidden, or has not been exercised under interruption.

## Read references selectively

- Read `references/methodology-and-motion-design.md` before choosing whether to
  animate, defining the motion contract, reviewing an implementation, or
  selecting an API family.
- Read `references/interruption-and-velocity.md` for gestures, retargeting,
  reversal, springs, progress mapping, velocity continuity, or rapid input.
- Read `references/swiftui-state-and-transactions.md` for `withAnimation`,
  value-scoped `.animation`, `Transaction`, `Animatable`, completion, identity,
  transitions, and `matchedGeometryEffect`.
- Read `references/swiftui-sequences-and-effects.md` for phase or keyframe
  choreography, content and symbol effects, scroll effects, `Canvas`,
  `TimelineView`, shaders, or `CustomAnimation`.
- Read `references/uikit-property-animations.md` for animation blocks,
  constraints, `UIViewPropertyAnimator`, keyboard coordination, or UIKit
  Dynamics.
- Read `references/navigation-transitions.md` for SwiftUI navigation,
  presentation, UIKit view-controller transitions, transition coordinators, or
  mixed SwiftUI and UIKit flows.
- Read `references/appkit-and-cross-framework.md` for AppKit animation contexts,
  animator proxies, macOS Reduce Motion, or shared SwiftUI animation timing
  across framework boundaries.
- Read `references/core-animation-and-frame-driving.md` for `CALayer`,
  `CAAnimation`, model and presentation layers, timing, `CADisplayLink`,
  `UIUpdateLink`, or manual frame updates.
- Read `references/performance-and-diagnostics.md` before diagnosing a hitch,
  changing rendering groups, optimizing layout or effects, or making a
  performance or power claim.
- Read `references/accessibility-and-availability.md` for Reduce Motion,
  cross-fade alternatives, autoplaying or repeating motion, API availability,
  beta SDKs, and fallbacks.
- Read `references/testing-and-evidence.md` before defining tests, profiling,
  regression gates, production metrics, or completion evidence.
- Read `references/sources.md` when behavior is SDK-sensitive, unfamiliar,
  disputed, or needs a primary Apple source.

Repository instructions, product motion language, supported platforms, selected
SDK, deployment targets, and the user's requested scope override generic
examples. Never raise a deployment target or adopt beta-only behavior silently.

## Route the request

Choose one lead mode:

- **Explain or design**: define purpose, states, interruption, accessibility,
  mechanism, and evidence without editing.
- **Implement or refactor**: inspect the real state and ownership boundaries,
  make the smallest lifecycle-complete change, and validate it.
- **Review**: report prioritized correctness, accessibility, availability, and
  performance findings without fixing unless requested.
- **Diagnose**: reproduce the event sequence and localize the discontinuity or
  missed frame before proposing a repair.
- **Profile**: establish an equivalent scenario, record a baseline, change one
  supported mechanism, and measure again.
- **Test**: exercise final states, interruption paths, accessibility variants,
  device behavior, and performance thresholds.

Lead with `$swift-animation` when motion behavior is the core problem. Use
`$swiftui-optimization` for broader invalidation or view-update architecture,
`$app-performance` for a whole-app investigation, `$swift-concurrency` for task
lifetime or cancellation, `$voice-over-accessibility` for semantic
accessibility, and `$swift-rtl-support` for directional layout or gestures.

## Establish the motion contract

Before choosing an API:

1. Name the functional purpose: status, spatial relationship, hierarchy,
   continuity, feedback, or justified decoration.
2. Define stable source and target states independently of the animation.
3. Record every input that can arrive mid-flight: repeated tap, reverse drag,
   new model state, navigation, resize, backgrounding, or disappearance.
4. Decide whether the motion is noninteractive, interruptible, interactive, or
   continuously retargetable.
5. Define progress, completion and cancellation semantics, including the owner
   and end condition of every animator, task, timer, and display update.
6. Define position and velocity behavior when the target changes.
7. Specify Reduce Motion and no-animation outcomes as complete UI states.
8. Record platform, SDK, deployment target, refresh-rate assumptions, and the
   evidence that will prove correctness and smoothness.

If motion has no user-facing purpose, prefer no animation.

## Choose the lowest sufficient mechanism

Use this order:

1. Prefer a system component, navigation transition, content transition, or
   symbol effect when it expresses the intended relationship.
2. Use state-driven SwiftUI animation or `UIView.animate` for short,
   fire-and-forget changes with stable endpoints.
3. Use a spring and explicit state or `UIViewPropertyAnimator` when input can
   interrupt, reverse, scrub, or retarget the motion.
4. Use phase or keyframe APIs for predetermined choreography whose timeline is
   more important than arbitrary interruption.
5. Use Core Animation for layer-specific timing, paths, groups, or compositing
   behavior that higher-level APIs cannot express cleanly.
6. Use `TimelineView`, `CADisplayLink`, or `UIUpdateLink` only when content
   genuinely depends on time or per-frame simulation.

Do not imitate interaction with a chain of delayed animations. Map gesture
progress directly to visual progress, then complete from the released position
and velocity.

## Preserve continuity and ownership

- Keep one authoritative logical state; derive visual targets from it.
- Retarget from the current visual state rather than replaying from the old
  endpoint.
- Preserve velocity for gesture-driven springs and normalize UIKit velocity
  against the remaining displacement.
- Clamp progress only at intentional physical boundaries; keep raw gesture
  translation available for rubber-banding or projected completion decisions.
- Cancel or supersede stale completion work when a newer transition wins.
- Scope SwiftUI animation to the state change that owns it. Do not attach a
  broad `.animation` high in the hierarchy.
- Reuse one interruptible animator for one UIKit transition context. Do not
  manufacture a different animator on repeated framework callbacks.
- Update a Core Animation model layer to the final value when adding an
  explicit animation; the animation object alone is not persistent state.
- Stop timers, display links, timeline schedules, and indefinite effects when
  their content is static, hidden, backgrounded, or deallocated.

## Build accessibility and availability in

Read Reduce Motion from the environment or accessibility API and react when it
changes. Replace large spatial movement, zoom, parallax, and indefinite motion
with a calmer transition, reduced amplitude, or no motion while preserving
state, focus, and task completion.

Check availability at the use site and provide a behaviorally complete
fallback. Treat APIs from prerelease SDKs as opt-in, isolated paths; verify
generated SDK interfaces and release notes rather than inferring availability
from a WWDC session or web page.

## Diagnose and verify

Separate commit-phase work from render-phase work. Inspect state churn, layout,
main-thread work, decoding, and hierarchy mutation for commit hitches; inspect
offscreen passes, masks, blur, shadows, blending, rasterized surfaces, and
fill cost for render hitches.

Do not use average FPS or simulator appearance as sole evidence. Exercise rapid
reversal, repeated input, cancellation, Reduce Motion, background and
foreground, relevant refresh rates, and the slowest supported device class.
Profile representative Release builds on hardware when claiming smoothness,
power efficiency, or a fixed hitch.

Finish with the chosen mode, motion contract, framework and API, ownership and
interruption model, accessibility alternative, availability fallback, checks
and measurements run, device and build context, and remaining uncertainty.
