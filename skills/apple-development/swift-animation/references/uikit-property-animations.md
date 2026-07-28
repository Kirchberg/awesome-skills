# UIKit property animations

Use this reference for UIKit animation blocks, constraints,
`UIViewPropertyAnimator`, springs, keyboard coordination, and UIKit Dynamics.

## Contents

- Choose blocks or property animators
- Animate view properties and constraints
- Build a property animator
- Scrub, reverse, and continue
- Coordinate keyboard movement
- Use UIKit Dynamics narrowly
- Own lifecycle and completion
- Review failure modes

## Choose blocks or property animators

Use `UIView.animate` for a short, one-directional transition when:

- source and target values are stable;
- no interactive progress is required;
- interruption can follow the documented animation-option behavior;
- one completion is sufficient;
- framework-owned transition coordination is not required.

Use `UIViewPropertyAnimator` when the motion needs:

- pause and resume;
- direct `fractionComplete` control;
- reversal;
- continuation with new timing parameters;
- multiple animation or completion blocks;
- an interruptible view-controller transition;
- explicit lifecycle state.

Animation options such as `.beginFromCurrentState` can improve handoff for
simple block animations, but they do not replace an explicit interaction and
ownership model.

## Animate view properties and constraints

Prefer animatable view properties such as transform, center, bounds, alpha, and
supported layer-backed values when they express the behavior.

For Auto Layout:

1. Change the constraints or their constants.
2. Establish the source layout before starting if needed.
3. Call `layoutIfNeeded()` on the nearest common ancestor inside the animation.
4. Keep unrelated constraint and hierarchy work outside the critical interval.

```swift
container.layoutIfNeeded()
heightConstraint.constant = expandedHeight

UIView.animate(
    withDuration: 0.3,
    delay: 0,
    options: [.curveEaseInOut, .allowUserInteraction]
) {
    container.layoutIfNeeded()
}
```

Do not call layout on an arbitrary ancestor that causes the whole window to
recompute. Do not perform decoding, database access, or complex view
construction inside the animation block.

Treat transform and constraints as different geometry authorities. Reset or
reconcile transforms before reading frames for constraint decisions.

## Build a property animator

Create the animator from a complete source and target contract:

```swift
let timing = UISpringTimingParameters(dampingRatio: 0.84)
let animator = UIViewPropertyAnimator(
    duration: 0.45,
    timingParameters: timing
)

animator.addAnimations {
    card.transform = targetTransform
    card.alpha = targetAlpha
    container.layoutIfNeeded()
}

animator.addCompletion { position in
    finishTransition(at: position)
}

animator.startAnimation()
```

Retain the animator for exactly the lifetime of the motion. Keep finalization
idempotent, because cancellation and interruption paths may converge.

Understand animator states before invoking lifecycle methods. Do not call
`finishAnimation(at:)` without first moving the animator to a state where the
operation is valid. Verify exact lifecycle requirements in the selected SDK.

Use `stopAnimation(_:)` and `finishAnimation(at:)` deliberately:

- decide whether stopping should preserve the current presentation;
- decide which logical state becomes durable;
- avoid leaving model and visual properties inconsistent;
- clear the retained animator after finalization.

## Scrub, reverse, and continue

For a pan-driven animator:

- create animations for the complete transition;
- pause the animator;
- map translation to `fractionComplete`;
- retain unbounded translation separately for rubber-banding;
- choose completion or reversal from position and velocity;
- continue with timing parameters based on remaining displacement;
- resolve logical state from actual completion position.

Normalize `UISpringTimingParameters` initial velocity against displacement; do
not pass gesture points per second directly.

When reversing:

- define whether progress remains source-to-target or follows the current
  animator direction;
- avoid double-inverting progress and `isReversed`;
- compute remaining displacement from the current visual state;
- test reversal more than once before completion.

Do not create a new animator on every gesture update. Change progress on the
current animator.

## Coordinate keyboard movement

Prefer `UIKeyboardLayoutGuide` and current system layout mechanisms when they
express the product behavior without manual animation.

When using keyboard notifications:

- read the final keyboard frame in the correct coordinate space;
- use the system duration and animation curve values;
- convert the curve value as required by the UIKit animation API;
- update constraints and call `layoutIfNeeded()` in the coordinated animation;
- handle interactive dismissal, hardware keyboards, split or floating
  keyboards, rotation, and scene changes.

Never hard-code `0.25` seconds for movement intended to track the keyboard.
Avoid assuming the keyboard enters only from the bottom.

For view-controller transitions, use the transition coordinator when available
instead of launching an independent keyboard-like timing block.

## Use UIKit Dynamics narrowly

Use UIKit Dynamics for behavior that genuinely needs gravity, collisions,
attachments, or dynamic-item simulation.

For ordinary snapping or spring completion, prefer
`UIViewPropertyAnimator` with spring timing. It offers a smaller state and
lifecycle surface.

If Dynamics is justified:

- keep one clear `UIDynamicAnimator` owner;
- remove obsolete behaviors;
- define rest and cancellation;
- map the final simulated position into durable layout state;
- stop updates when the component is inactive;
- test accessibility alternatives and power behavior.

## Own lifecycle and completion

Name the owner of every animator. In reusable views and controllers:

- cancel or finish obsolete animation before starting a conflicting one;
- avoid completion closures that retain the owner indefinitely;
- clear animation references on teardown;
- make repeated input deterministic;
- keep the stable end state correct when animations are disabled;
- do not use `isUserInteractionEnabled = false` as the default lifecycle model.

Use completion to finalize presentation state, not to hide missing business
state ownership.

## Review failure modes

Look for:

- `UIView.animate` chosen despite required scrubbing or reversal;
- raw gesture velocity passed to spring timing;
- a property animator created on every pan update;
- constraints changed without laying out the correct common ancestor;
- layout, decoding, or hierarchy construction inside the animation interval;
- transform and frame calculations mixed without reconciliation;
- fixed keyboard duration or coordinate assumptions;
- completion that runs after the view controller is no longer current;
- a stopped animator whose final logical state remains undefined;
- interaction disabled to conceal interruption bugs.
