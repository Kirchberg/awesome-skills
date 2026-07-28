# Accessibility and platform availability

Use this reference to design Reduce Motion alternatives, handle animated
content preferences, react to settings changes, select deployment-target
fallbacks, and isolate prerelease APIs.

## Contents

- Treat reduced motion as complete behavior
- Read platform preferences
- Select an alternative by motion type
- Preserve meaning and interaction
- React to runtime changes
- Verify stable API generations
- Isolate beta SDK behavior
- Build availability fallbacks
- Review failure modes

## Treat reduced motion as complete behavior

Reduce Motion is not a global request to remove every transition or set every
duration to zero. It is a request to reduce motion that can cause discomfort,
disorientation, or unnecessary attention.

For every prominent, automatic, repeating, parallax, zoom, depth, or large
spatial animation, define:

- the normal behavior;
- the reduced behavior;
- the state and information preserved by both;
- whether a cross-fade, reduced distance, reduced scale, static frame, or
  disabled loop is appropriate;
- how focus, interaction, and completion remain equivalent.

Use no animation when even a fade would delay or distract from the task.

## Read platform preferences

In SwiftUI, read the environment values relevant to the content:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
@Environment(\.accessibilityPrefersCrossFadeTransitions)
private var prefersCrossFade
@Environment(\.accessibilityPlayAnimatedImages)
private var playAnimatedImages
```

Use each preference for its intended behavior. `prefersCrossFade` is not a
replacement for checking Reduce Motion across every kind of motion, and an API
named cross-fade does not imply it automatically consumes the preference.

In UIKit, read `UIAccessibility.isReduceMotionEnabled` and observe
`reduceMotionStatusDidChangeNotification` while the owning UI is alive.

In AppKit, read
`NSWorkspace.shared.accessibilityDisplayShouldReduceMotion` and observe the
current accessibility display-options change notification documented by the
selected SDK.

Remove notification observers or bind their lifetime to a cancellable owner.

## Select an alternative by motion type

For large spatial travel:

- cross-fade source and destination;
- reduce travel distance or scale;
- preserve a short local feedback response;
- avoid moving the full viewport.

For zoom and depth:

- remove scale excursion and parallax;
- use opacity or an immediate hierarchy change;
- preserve source and destination identity.

For gesture-driven components:

- retain one-to-one tracking when it is essential to direct manipulation;
- reduce overshoot, bounce, rubber-banding, or background parallax;
- ensure release still settles predictably.

For automatic or repeating decoration:

- stop the loop;
- use a static representative frame;
- play only after explicit user action;
- honor animated-image playback preference when applicable.

For progress or status:

- preserve functional indication;
- prefer a bounded, calm change or determinate value;
- do not remove the only signal that work is continuing.

## Preserve meaning and interaction

Every accessibility variant must:

- reach the same logical source and target states;
- preserve semantic labels, values, and focus;
- retain hit targets and gesture completion;
- avoid flashing or abrupt replacement that creates a new problem;
- keep navigation and modal completion correct;
- cancel timers, links, and indefinite effects that no longer render.

Do not use a separate reduced-motion product state that can drift from the
normal state. Select a presentation strategy from the same durable state.

## React to runtime changes

Accessibility preferences can change while the app or screen is alive.

On change:

- recompute the selected presentation policy;
- stop obsolete indefinite or frame-driven motion;
- resolve an in-flight transition into a complete state without jumping through
  the full suppressed path;
- avoid replaying decoration merely because the environment updated;
- retain the user's current task and focus.

Test the change while an animation is at several progress points. Do not require
an app restart unless the platform explicitly does.

## Verify stable API generations

As reviewed on 2026-07-28:

- `PhaseAnimator`, `KeyframeAnimator`, `CustomAnimation`,
  `Transaction.tracksVelocity`, transaction animation completion, and the
  completion overload of `withAnimation` are stable from the iOS 17 platform
  generation, with corresponding macOS 14, tvOS 17, watchOS 10, and visionOS 1
  availability where documented.
- SwiftUI zoom navigation and `matchedTransitionSource` are stable from the
  iOS 18 platform generation, with platform-specific availability. Zoom is not
  supported on tvOS even though related symbols are present; the system falls
  back to automatic navigation behavior.
- `UIUpdateLink` is stable from iOS and tvOS 18 and visionOS 2. It is not a
  general Mac Catalyst or watchOS API.

Treat this list as routing guidance, not a substitute for the generated
interface in the project's selected SDK. Platform matrices differ; verify the
exact call site.

`Transaction.tracksVelocity` is a Boolean tracking facility, not a public
velocity value. Apple documents velocity tracking and animation as mutually
exclusive for the same transaction change, while gesture callbacks enable
tracking automatically. Do not claim continuity without testing the actual
update sequence.

## Isolate beta SDK behavior

As reviewed on 2026-07-28:

- `NavigationTransition.crossFade` and
  `CrossFadeNavigationTransition` belong to the beta platform-27 SDK generation
  and are not documented for macOS;
- Xcode 27 Organizer expands Hitches beyond scrolling, but Xcode 27 remains
  beta and Apple does not document a precise minimum runtime OS for incoming
  Organizer data in the cited material;
- the Swift-first MetricKit generation, including `MetricManager` and new
  report types, is beta and has platform-specific availability.

Do not make these APIs the unconditional production path. Keep stable
production navigation, diagnostics, and MetricKit behavior until the project
explicitly adopts the released toolchain and platform baseline.

Do not state that `CrossFadeNavigationTransition` automatically responds to
Reduce Motion; select it or another fallback based on the accessibility
preference and product contract.

## Build availability fallbacks

At each newer API:

1. verify compile-time SDK availability;
2. verify runtime platform and version;
3. preserve a complete fallback with the same product state;
4. keep newer types out of code compiled by older required toolchains when
   necessary;
5. test both branches;
6. document behavioral differences;
7. never raise deployment target silently.

Prefer a simpler system transition or state-driven animation as fallback.
Avoid reimplementing a complex new effect when a calm stable path communicates
the same result.

For archived Apple guides, use the conceptual model only. Verify signatures,
annotations, deprecations, and availability in current DocC and the generated
SDK interface.

## Review failure modes

Look for:

- Reduce Motion handled only by reducing duration;
- large zoom, parallax, or travel preserved in the “reduced” path;
- the only status or feedback signal removed;
- animated images or indefinite loops ignoring their preference;
- settings sampled once and never observed;
- reduced and normal paths ending in different product states;
- `matchedTransitionSource` incorrectly treated as beta generation 27;
- `Transaction.tracksVelocity` described as a readable velocity;
- cross-fade assumed to adapt automatically;
- runtime guards without an older-toolchain compile strategy;
- beta Organizer or MetricKit behavior presented as released production
  infrastructure;
- archived documentation used as current availability authority.
