# SwiftUI sequences, content, and visual effects

Use this reference for predetermined choreography, content changes, symbol and
scroll effects, time-driven drawing, shaders, and custom animation models.

## Contents

- Choose phases, keyframes, or state
- Build phase sequences
- Build keyframe tracks
- Animate content and symbols
- Tie effects to scrolling
- Use Canvas and TimelineView
- Isolate custom animations and shaders
- Bound lifecycle and rendering cost
- Review failure modes

## Choose phases, keyframes, or state

Use ordinary state-driven animation when the interface moves between stable
states and may be retargeted.

Use `PhaseAnimator` when:

- a small ordered set of semantic phases is sufficient;
- each phase defines a complete group of visual values;
- exact independent timing tracks are unnecessary;
- restart or trigger behavior is explicit.

Use `KeyframeAnimator` when:

- several values require independent tracks;
- exact relative timing, overshoot, hold, or sequencing matters;
- the choreography has a clear start and end;
- arbitrary gesture interruption is not the primary interaction.

Do not translate every design timeline directly into delayed state mutations.
Keep one animation mechanism responsible for the sequence.

Check the APIs against the selected SDK and provide an older-system fallback.
Do not raise the deployment target merely to avoid writing a simpler fallback.

## Build phase sequences

Name phases by meaning rather than timestamps:

```swift
enum FeedbackPhase: CaseIterable {
    case resting
    case acknowledged
    case settled
}
```

Map each phase to a complete visual state, then select timing between phases.
Keep business state outside the phase enum; phase progression is presentation,
not a substitute for the product state machine.

For trigger-based feedback:

- make the trigger change only for a new semantic event;
- decide what repeated events do while the sequence is active;
- keep the resting state correct without animation;
- stop or simplify the sequence for Reduce Motion;
- avoid indefinite phase loops without a functional reason.

If repeated input must redirect the object from its current position and
velocity, prefer explicit retargetable state and springs.

## Build keyframe tracks

Define a small value type containing only the properties that need coordinated
interpolation:

```swift
struct EffectValues {
    var scale = 1.0
    var verticalOffset = 0.0
    var opacity = 1.0
}
```

Use a track per independently timed property. Choose linear, cubic, spring, or
move keyframes based on the intended continuity:

- use a move or hold to establish an immediate value without interpolation;
- use linear timing for constant-rate changes;
- use cubic timing for predetermined easing;
- use spring timing for physically settling segments.

Keep track durations auditable and ensure the combined end state matches the
stable view state. Avoid a keyframe timeline that ends at a value different
from the model, causing a snap when the animator leaves the hierarchy.

Treat keyframe restart semantics as part of the contract. Test a new trigger
during each segment, view disappearance, and Reduce Motion.

## Animate content and symbols

Use `ContentTransition` when content within an existing view changes. Prefer it
over replacing two unrelated views solely to animate a value.

For numeric text:

- provide the semantic numeric value where the API accepts it;
- format the displayed text with the product's locale rules;
- verify increasing and decreasing values;
- keep the final accessibility value immediate and correct;
- use a calm fallback for Reduce Motion.

Use SF Symbol effects for semantic icon feedback when a system effect expresses
the state. Bind discrete effects to a changing value or trigger. Bound
indefinite effects and stop them when the state no longer requires attention.

Do not animate an icon continuously merely to imply interactivity. Preserve
button labels, selection traits, and other semantic accessibility separately.

## Tie effects to scrolling

Prefer `scrollTransition` for effects derived from the framework's scroll
transition phase. Keep transforms modest and the source content legible.

Do not read offsets through a broad preference and invalidate a large subtree
when a current system scroll API expresses the same relationship.

For every scroll effect:

- define the neutral identity state;
- cap scale, rotation, blur, and opacity;
- verify many simultaneous cells on the slowest supported device;
- avoid expensive offscreen effects on every row;
- preserve hit targets and semantic reading order;
- reduce or remove spatial effects for Reduce Motion.

Keep scrolling behavior, snapping, and selection correct with the effect
disabled.

## Use Canvas and TimelineView

Use `Canvas` for immediate-mode drawing when many marks or custom drawing are
more efficient and clearer than a large view hierarchy.

Use `TimelineView` only when output genuinely depends on time. Select the
coarsest schedule that preserves the behavior. A clock that changes each minute
does not need display-rate updates.

Derive movement from elapsed time:

```swift
let elapsed = context.date.timeIntervalSince(startDate)
let position = velocity * elapsed
```

Do not advance by a fixed amount per callback or assume 60 callbacks per
second. Handle pauses, backgrounding, clock origin, and restart deliberately.

Pause or replace the schedule when content is static, offscreen, or covered.
Avoid using `TimelineView` as a workaround for state-model bugs.

## Isolate custom animations and shaders

Use `CustomAnimation` only when built-in timing curves and springs cannot
express a documented requirement. Define:

- the animatable value and time model;
- retargeting and velocity behavior;
- logical and fully settled completion;
- cancellation;
- Reduce Motion behavior;
- deterministic tests.

Keep custom time functions pure and finite. Verify behavior for zero duration,
large elapsed time, and a new target while running.

Treat SwiftUI shader and visual-effect APIs as rendering mechanisms, not an
animation architecture. Keep state, lifecycle, and interruption outside the
shader. Bound sample area, blur radius, layer count, and animated parameters.

Prefer a cheaper opacity, transform, content transition, or system material
when it communicates the same relationship.

## Bound lifecycle and rendering cost

For repeating, timeline, particle, or shader effects:

- name the state that starts and stops updates;
- stop when the view disappears or the scene becomes inactive;
- avoid retaining an update task beyond view ownership;
- cap particle or mark counts;
- avoid per-frame allocation and synchronous decoding;
- profile a Release build on hardware;
- inspect power as well as hitch behavior.

Do not assume `drawingGroup` makes complex animation faster. It creates a
rasterized surface with memory and composition costs. Measure it against the
same scenario and remove it when it does not help.

## Review failure modes

Look for:

- keyframes used for a gesture that must reverse naturally;
- delayed booleans duplicating a phase or keyframe timeline;
- a timeline whose final value differs from durable state;
- a trigger that changes on unrelated view updates;
- indefinite effects with no stop state;
- large blur, mask, distortion, or shader work repeated for every list cell;
- `TimelineView(.animation)` used for content that is not time-dependent;
- a custom animation without interruption or completion semantics;
- newer APIs with no availability fallback;
- Reduce Motion implemented only by multiplying all durations by zero.
