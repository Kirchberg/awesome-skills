# Interruption, interaction, and velocity

Use this reference for gesture-driven motion, repeated input, reversal,
retargeting, springs, progress mapping, and visual continuity.

## Contents

- Model intent and visual state separately
- Map interaction to progress
- Select a destination
- Preserve position continuity
- Preserve velocity continuity
- Drive SwiftUI interaction
- Drive UIKit interaction
- Cancel stale work
- Test interruption paths

## Model intent and visual state separately

Keep three layers distinct:

- **Logical state**: the durable product state, such as collapsed or expanded.
- **Interaction state**: live translation, velocity, predicted end, and whether
  the gesture is active.
- **Presentation state**: the value currently visible during interpolation.

Do not persist every frame of an animation back into the product model. Do not
derive logical state from a transient onscreen sample unless interruption
requires transferring that sample into a new transition.

Represent explicit states and events. A simple sheet might accept:

- `dragBegan`;
- `dragChanged(translation, velocity)`;
- `dragEnded(translation, velocity, projectedEnd)`;
- `targetChanged(detent)`;
- `cancelled`;
- `sceneBecameInactive`.

Define which event wins when two arrive close together.

## Map interaction to progress

Derive normalized progress from geometry:

```swift
let displacement = expandedY - collapsedY
guard abs(displacement) > .ulpOfOne else { return }
let progress = (currentY - collapsedY) / displacement
let boundedProgress = min(max(progress, 0), 1)
```

Use `boundedProgress` for a physically bounded transition. Retain raw progress
or translation separately when applying rubber-banding outside the bounds.

Keep the mapping one-to-one while the gesture is active. Avoid easing the live
finger-to-content mapping; apply timing when completing after release.

Recompute geometry after size, safe-area, or destination changes. Do not retain
a normalized distance calculated for a stale layout.

## Select a destination

Use position and velocity together. A typical policy:

1. Project the released position using the gesture system's predicted end or a
   documented projection.
2. Choose the nearest allowed destination in the direction of meaningful
   momentum.
3. Apply a threshold or hysteresis to avoid noisy toggling near a boundary.
4. Start completion from the current presentation with the released velocity.

Keep target selection separate from animation timing. Product rules decide
where the component settles; the spring decides how it gets there.

Do not invent a velocity threshold without units and geometry. A threshold that
works for a short card may be inappropriate for a full-height sheet.

## Preserve position continuity

When a target changes mid-flight:

- sample or retain the current visual value;
- make it the new transition's starting point;
- update the logical target once;
- let the selected animation mechanism interpolate from that point.

SwiftUI usually preserves presentation continuity when the same animatable
value is retargeted inside a suitable animation context and view identity
remains stable. A changed identity, asymmetric transition, or replacement of
the animating subtree can destroy that continuity.

For Core Animation, use the presentation layer only as a short-lived sample.
Copy the visible value to the model layer before starting the replacement
animation, then remove or replace the old animation deliberately.

## Preserve velocity continuity

Prefer springs for motion that may be redirected. Preserve the component of
velocity relevant to the animated displacement.

UIKit spring timing expects a unitless initial velocity relative to the total
animation distance. Normalize points per second:

```swift
func normalizedVelocity(
    pointsPerSecond: CGFloat,
    displacement: CGFloat
) -> CGFloat {
    guard abs(displacement) > .ulpOfOne else { return 0 }
    return pointsPerSecond / displacement
}
```

Preserve the sign. Clamp only when measured behavior or product policy justifies
it; aggressive clamping produces a visible change in momentum.

For multidimensional motion, normalize each component against its corresponding
displacement. Avoid division by a near-zero component, and do not inject
orthogonal velocity into an axis that is not moving.

Do not transfer raw gesture velocity into APIs whose velocity model is
normalized or otherwise differently defined. Verify the selected SDK
documentation.

## Drive SwiftUI interaction

Keep transient drag state local and durable target state explicit:

```swift
@State private var isExpanded = false
@GestureState private var dragTranslation: CGFloat = 0

var offset: CGFloat {
    targetOffset(isExpanded: isExpanded) + dragTranslation
}
```

During `updating`, map the gesture directly to transient state. On end, choose a
durable target from translation and predicted motion, then change that target
inside a spring animation:

```swift
withAnimation(.spring(duration: 0.45, bounce: 0.18)) {
    isExpanded = shouldExpand(value)
}
```

Check availability for the chosen spring initializer. For older deployment
targets, select an available spring with equivalent product behavior.

Keep view identity stable across retargeting. Scope `.animation(_:value:)` to
the target or use `withAnimation` around the owning state mutation. Avoid
starting a detached delayed task to decide the final state after the visual
motion already began.

When an animation must hand off current velocity across multiple state updates,
inspect the current SDK's transaction facilities and prototype the exact
behavior. Do not assume every `Animation` retains gesture velocity
automatically.

## Drive UIKit interaction

Create and retain one property animator for the current motion. Keep one
interruptible animator for one transition context:

```swift
let displacement = targetCenter.x - view.center.x
let unitVelocity = normalizedVelocity(
    pointsPerSecond: panVelocity.x,
    displacement: displacement
)
let timing = UISpringTimingParameters(
    dampingRatio: 0.82,
    initialVelocity: CGVector(dx: unitVelocity, dy: 0)
)
let animator = UIViewPropertyAnimator(
    duration: 0.45,
    timingParameters: timing
)
animator.addAnimations {
    view.center.x = targetCenter.x
}
```

For direct scrubbing:

1. Create the animator for the complete source-to-target change.
2. Start and immediately pause it when framework behavior requires activation.
3. Set `fractionComplete` from bounded gesture progress.
4. On release, choose completion or reversal.
5. Continue with timing parameters that preserve the released velocity.
6. Resolve final logical state in completion using the actual final position.
7. Clear the retained animator exactly once.

Do not create a replacement animator each time a transition framework asks for
its interruptible animator. Return the same instance for that transition
context.

Treat `fractionComplete` as transition progress, not product state. A reversed
animator and a cancelled transition require deliberate final-state mapping.

## Cancel stale work

Prefer animation completion APIs, transition-coordinator completions, and state
machines over fixed `asyncAfter` delays. If asynchronous work is unavoidable:

- retain a task or generation token;
- cancel or supersede it when intent changes;
- verify ownership before mutating UI;
- keep completion idempotent;
- clean it up on disappearance and deallocation.

Do not let animation completion trigger business work unless the product
contract genuinely requires visual completion. Often business state should
commit immediately while presentation catches up.

## Test interruption paths

Exercise:

- repeated tap before 10%, around 50%, and near completion;
- drag reversal with low and high velocity;
- release on both sides of every detent threshold;
- a new model target during spring settling;
- rotation, resize, and Dynamic Type changes in motion;
- navigation cancellation and interactive pop reversal;
- backgrounding, disappearance, and deallocation;
- Reduce Motion toggled while the component remains visible;
- zero or tiny displacement;
- 60 Hz and higher-refresh hardware when supported.

Record the event sequence and visible discontinuity. A slow-motion recording can
help reveal a jump, but use Instruments and signposts to distinguish a logic
discontinuity from a missed frame.
