# Navigation and presentation transitions

Use this reference for SwiftUI navigation transitions, UIKit custom
view-controller transitions, interactive navigation, transition coordination,
and mixed-framework handoff.

## Contents

- Prefer system navigation
- Design the transition contract
- Use SwiftUI navigation transitions
- Build UIKit custom transitions
- Make UIKit transitions interactive
- Coordinate alongside system transitions
- Bridge SwiftUI and UIKit
- Handle accessibility and availability
- Review failure modes

## Prefer system navigation

Start with the current platform's standard navigation, sheet, popover, full
screen, and presentation behavior. Preserve system gestures and cancellation.

Use a system customization point when it expresses the intended relationship:

- navigation transition APIs for supported SwiftUI destinations;
- transition coordinators for changes alongside UIKit transitions;
- presentation controllers and their adaptive behavior;
- system zoom or shared-element transitions where available.

Build a custom transition only when the system behavior cannot communicate the
required hierarchy or object continuity. Record responsibility for interactive
pop, cancellation, bars, safe areas, rotation, accessibility focus, and
framework interoperability.

## Design the transition contract

Define:

- source and destination identities;
- source and target frames after layout;
- navigation or presentation owner;
- interactive driver and progress mapping;
- cancellation threshold and velocity policy;
- final hierarchy and state for complete and cancelled outcomes;
- behavior when source or destination disappears;
- system chrome and alongside animations;
- Reduce Motion alternative;
- oldest-OS fallback.

Do not calculate geometry from a stale pre-layout frame. Convert coordinates
through explicit view or window coordinate spaces.

Keep content hierarchy changes owned by the navigation or presentation
framework. The animator controls presentation, not the controller containment
contract.

## Use SwiftUI navigation transitions

Use the current SwiftUI navigation transition APIs only when the selected SDK
and deployment target support them. Keep source identifiers stable and scope
`matchedTransitionSource` to the logical object.

For a system zoom-style transition:

- ensure one visible source corresponds to the destination;
- keep source and destination identity stable;
- verify scroll movement and source reuse;
- test interactive dismissal or back navigation;
- preserve a standard navigation fallback.

Do not combine a system navigation transition with an independent
`matchedGeometryEffect` targeting the same geometry unless the interaction has
one clear owner and has been verified under cancellation.

Treat newer cross-fade or other prerelease navigation APIs as isolated,
availability-checked enhancements. Do not make a beta SDK the baseline. For
Reduce Motion on stable SDKs, a local opacity transition or standard system
navigation may be the appropriate complete fallback, subject to product
requirements.

## Build UIKit custom transitions

Separate responsibilities:

- `UIViewControllerTransitioningDelegate` or navigation-controller delegate
  selects animation and interaction controllers;
- `UIViewControllerAnimatedTransitioning` defines duration and presentation;
- `UIViewControllerInteractiveTransitioning` drives interactive progress;
- the transition context owns container, source, destination, cancellation, and
  completion.

In `animateTransition(using:)`:

1. obtain views and final frames from the transition context;
2. install the destination in the container as required;
3. establish source presentation values;
4. animate to complete target values;
5. restore or remove temporary views and snapshots;
6. call `completeTransition(!transitionWasCancelled)` exactly once.

Use `transitionDuration(using:)` consistently. Avoid treating duration as a
product constant outside the transition.

If implementing `interruptibleAnimator(using:)`, create one property animator
for that transition context and return the same instance on subsequent calls.
Do not call `animateTransition(using:)` in a way that builds a second,
competing animator.

## Make UIKit transitions interactive

Prefer current system continuously interactive transitions where they satisfy
the design. For custom interaction:

- start navigation or presentation when the gesture contract says the
  transition began;
- map gesture translation to normalized transition progress;
- update the interaction controller directly;
- choose finish or cancel from progress and projected velocity;
- preserve visual continuity during the framework's completion;
- reconcile logical state with `transitionWasCancelled`.

`UIPercentDrivenInteractiveTransition` supplies a basic percent-driven model.
Use a property-animator-backed interruptible transition when the selected
architecture and SDK support the required continuity.

Do not mutate the navigation stack independently while the transition context
is resolving. Do not assume cancellation means the same view hierarchy events
as a completed transition.

## Coordinate alongside system transitions

Use `UIViewControllerTransitionCoordinator` to animate changes alongside push,
pop, presentation, dismissal, rotation, and other coordinated system
transitions.

Inside coordinator callbacks:

- use the coordinator's context and cancellation result;
- keep alongside changes reversible;
- avoid a copied duration and curve;
- restore state on cancellation when required;
- keep completion idempotent.

Use keyboard-specific system coordination for keyboard movement. Do not force
unrelated transitions into a guessed global timing curve.

## Bridge SwiftUI and UIKit

For UIKit navigation containing SwiftUI:

- let the navigation transition context own completion;
- update hosted SwiftUI state from one well-defined adapter;
- avoid rebuilding the root view solely to trigger motion;
- preserve hosting-controller and model identity across interruption.

For SwiftUI navigation containing representables:

- inspect the incoming transaction when updating UIKit presentation;
- prevent the wrapped view from launching a competing default animation;
- keep UIKit delegate and animator lifetime bounded by the SwiftUI identity.

When moving between framework boundaries, select one animation clock and one
completion authority.

## Handle accessibility and availability

For Reduce Motion:

- prefer standard system behavior when it already adapts;
- replace large zoom or spatial travel with cross-fade, reduced movement, or
  immediate state change;
- preserve navigation completion, focus, bars, and destination identity;
- test interactive cancellation in the reduced variant.

Check availability at each API boundary. Compile and exercise the fallback on
the oldest supported OS. Keep beta-only transition code behind both compile-time
SDK availability and runtime checks as required by the toolchain.

## Review failure modes

Look for:

- a custom transition replacing a system transition without a product reason;
- multiple animator instances for one transition context;
- `completeTransition` called with a hard-coded success value;
- stale geometry or mixed coordinate spaces;
- snapshots left in the hierarchy after completion or cancellation;
- progress not clamped for a percent-driven controller;
- navigation state mutated while cancellation is resolving;
- a parallel SwiftUI and UIKit animation targeting the same element;
- loss of interactive pop or adaptive presentation;
- large spatial motion with no Reduce Motion alternative;
- a new navigation API with no tested fallback.
