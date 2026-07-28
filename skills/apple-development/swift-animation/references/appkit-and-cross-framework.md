# AppKit and cross-framework animation

Use this reference for `NSAnimationContext`, AppKit animator proxies, macOS
accessibility behavior, and animation-context handoff between SwiftUI, UIKit,
and AppKit.

## Contents

- Choose AppKit animation mechanisms
- Use NSAnimationContext
- Animate through proxy objects
- Preserve AppKit state and layout
- Respect macOS Reduce Motion
- Share animation timing across frameworks
- Own completion and interruption
- Review failure modes

## Choose AppKit animation mechanisms

Prefer standard AppKit controls, window behavior, scrolling, and presentation
when they express the required relationship.

Use:

- `NSAnimationContext` for grouped implicit AppKit animations;
- an object's `animator()` proxy for properties supported by AppKit animation;
- Core Animation for explicit layer-level behavior;
- SwiftUI state-driven animation inside SwiftUI hierarchy;
- a current cross-framework SwiftUI `Animation` bridge only when the selected
  SDK provides it and its lifecycle fits the contract.

Do not wrap every property assignment in an animation context. Confirm that the
property participates in AppKit animation and that the source and target
layout remain valid.

## Use NSAnimationContext

Group related changes:

```swift
NSAnimationContext.runAnimationGroup { context in
    context.duration = 0.25
    context.timingFunction = CAMediaTimingFunction(
        name: .easeInEaseOut
    )

    panel.animator().alphaValue = 1
    panel.animator().frame = targetFrame
} completionHandler: {
    finishPresentation()
}
```

Keep the completion idempotent and protect it from a superseding state change.
Do not use context duration as a delay for unrelated business work.

Use `allowsImplicitAnimation` only within a deliberately scoped context. Avoid
enabling implicit animation broadly around unrelated view and constraint
updates.

Verify selected SDK behavior for nested animation contexts and completion order
before relying on them for a state machine.

## Animate through proxy objects

The `animator()` proxy records supported property changes into the current
animation context. Keep the durable target on the real object; do not retain
the proxy as state.

Before using a proxy:

- confirm the property is animatable;
- establish the source layout;
- set one complete target;
- keep identity and hierarchy stable;
- define repeated-input behavior;
- verify whether the update can be interrupted by the selected mechanism.

For interactive or continuously retargeted behavior, a simple AppKit animator
proxy may not provide sufficient lifecycle control. Use a state-driven SwiftUI
boundary, layer-level mechanism, or a purpose-built interaction model instead
of chains of completion handlers.

## Preserve AppKit state and layout

Keep Auto Layout as the durable geometry authority when constraints define the
view. Animate compatible constraint or layout changes through the appropriate
AppKit mechanism and avoid mixing transformed presentation geometry with stale
frame-based decisions.

For window, split-view, scroll-view, or collection behavior, preserve system
interaction and accessibility. Do not replace current AppKit behavior with a
custom timeline merely to control duration.

Keep source and target valid with animation disabled. Restore temporary
snapshots, layer state, and hierarchy after completion or cancellation.

## Respect macOS Reduce Motion

Read `NSWorkspace.shared.accessibilityDisplayShouldReduceMotion` for AppKit
interfaces and respond to the current accessibility display-options change
notification documented by the selected SDK.

For reduced motion:

- retain state and feedback;
- replace large movement, zoom, parallax, and spatial reordering with a calm
  fade, reduced travel, or immediate update;
- stop decorative repetition;
- preserve keyboard, pointer, focus, and VoiceOver behavior;
- test full-screen, window resize, sheets, and spaces where relevant.

Do not assume SwiftUI environment preferences automatically control imperative
AppKit animations outside the SwiftUI hierarchy.

## Share animation timing across frameworks

Current SwiftUI documentation describes APIs in newer SDK generations for using
SwiftUI `Animation` values from UIKit and AppKit. Use that bridge when:

- one perceptual timing model should span framework boundaries;
- the API is available on every intended platform path;
- direct property animation satisfies the lifecycle;
- keyframes or `UIViewPropertyAnimator` control are not required.

Apple documents incompatibilities between that bridge and some imperative
UIKit animation mechanisms. Do not mix a shared SwiftUI animation value with a
property animator or UIKit keyframe block for the same change.

At a representable boundary:

- inspect or carry the incoming SwiftUI transaction;
- choose one animation clock and one owner for timing and completion;
- keep the wrapped view or controller identity stable;
- avoid launching a second default animation;
- preserve an older-system fallback.

## Own completion and interruption

Name the owner of each AppKit animation context and Core Animation object.
Decide what a repeated command does while motion is running.

If the mechanism cannot retarget naturally:

- commit the newer product state;
- cancel or supersede stale completion work;
- establish the current visual state;
- start one replacement transition;
- verify no old completion restores the obsolete state.

Do not block all input to hide an incomplete interruption model. Disable a
specific action only when product semantics require serialization.

## Review failure modes

Look for:

- retained `animator()` proxies;
- nested contexts with competing duration or completion;
- frame changes fighting constraint-owned layout;
- broad implicit animation around unrelated work;
- delayed callbacks that restore stale AppKit state;
- imperative AppKit motion that ignores macOS Reduce Motion;
- two framework clocks targeting the same property;
- a SwiftUI animation bridge mixed with incompatible UIKit mechanisms;
- system window or scrolling behavior replaced without a product requirement;
- no fallback for a newer cross-framework API.
