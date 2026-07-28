# Animation methodology and motion design

Use this reference to decide whether motion belongs in the interface, define its
contract before selecting APIs, and review an animation as product behavior
rather than isolated polish.

## Contents

- Start from purpose
- Classify the behavior
- Write a motion contract
- Prefer system behavior
- Choose a mechanism
- Design for interruption first
- Review common failure modes
- Define honest completion evidence

## Start from purpose

Require every animation to serve at least one concrete role:

- communicate that state changed;
- preserve the identity or location of an object;
- explain hierarchy or navigation;
- connect an action with its result;
- provide immediate interaction feedback;
- visualize time-dependent data;
- create decoration that does not compete with the task.

Remove or simplify motion that obscures the result, delays input, moves focus
unexpectedly, or exists only because an API is available. Motion should make the
interface easier to predict after one viewing.

Describe the purpose in one sentence:

> Move the selected card into its detail destination so the user keeps spatial
> context while navigation completes.

Reject descriptions such as “make it feel premium” until they identify the
state change, relationship, or feedback the motion communicates.

## Classify the behavior

Keep these concepts distinct:

- **Noninteractive**: start the motion and let it finish without further input.
- **Interruptible**: allow pause, reversal, cancellation, or retargeting after
  the motion starts.
- **Interactive**: derive progress directly from a gesture or another input.
- **Continuous**: preserve visual position and, where appropriate, velocity
  when the target changes.
- **Time-driven**: recompute content from elapsed time or simulation state.
- **Choreographed**: coordinate predetermined phases or tracks on a timeline.

An interactive animation must also define interruption and completion. A
choreographed animation is not automatically suitable for direct manipulation.
Do not call a series of delayed, fire-and-forget animations interactive merely
because a gesture triggered the series.

## Write a motion contract

Record:

1. **Purpose**: the state, relationship, or feedback being communicated.
2. **Source and target**: complete stable UI states before and after motion.
3. **Inputs**: tap, drag, scroll, model update, navigation, resize, scene
   lifecycle, or accessibility-setting change.
4. **Interruption policy**: what repeated, reversed, or competing input does at
   every point.
5. **Progress model**: discrete state, normalized gesture progress, projected
   destination, elapsed time, or simulation step.
6. **Continuity policy**: position, velocity, focus, content identity, and
   system-bar behavior during retargeting.
7. **Ownership**: owner and end condition for animator, task, timer, display
   link, transition context, and completion callback.
8. **Accessibility alternative**: reduced, cross-faded, static, or disabled
   behavior with equivalent meaning.
9. **Availability**: selected SDK, minimum OS, fallback, and whether any path is
   prerelease.
10. **Evidence**: functional tests, interruption cases, hardware profile,
    performance threshold, and production signal when required.

For review-only work, reconstruct this contract from the implementation and
report missing decisions as findings. Do not silently invent product policy.

## Prefer system behavior

Choose system-provided components and transitions first when they express the
required relationship:

- standard navigation and presentation;
- content transitions for changing a value in an existing view;
- SF Symbol effects for semantic icon feedback;
- scroll transitions for effects tied to scroll position;
- transition coordinators for changes accompanying UIKit navigation,
  presentation, rotation, or keyboard movement;
- current platform navigation transitions with explicit availability fallback.

System behavior usually carries established interaction, interruption,
accessibility, and platform conventions. Keep custom motion when the system API
cannot express the product relationship, not merely because custom code offers
more timing controls.

Do not hard-code the duration or curve of a system-owned transition. Join its
coordinator or use the framework's supported customization point.

## Choose a mechanism

Use the lowest-level mechanism that still satisfies the contract:

- Use no animation for an instantaneous result whose relationship is already
  obvious.
- Use state-driven SwiftUI animation or a UIKit animation block for a simple
  transition between stable values.
- Use a spring when a target can move or input supplies velocity.
- Use `UIViewPropertyAnimator` when UIKit motion needs lifecycle control,
  interactive progress, reversal, or timing continuation.
- Use `PhaseAnimator` for a small sequence of discrete phases.
- Use `KeyframeAnimator` or UIKit keyframes when exact tracks and relative
  timing matter more than arbitrary retargeting.
- Use `Animatable` or a custom effect when a domain value must interpolate and
  standard properties cannot express it.
- Use Core Animation when the problem is explicitly about layer properties,
  paths, timing hierarchies, animation groups, or presentation-layer state.
- Use a display-synchronized update API only for genuinely time-driven content.

Escalating to a lower-level API increases responsibility for state, lifecycle,
interruption, accessibility, and testing. Record why the higher-level option
was insufficient.

## Design for interruption first

Ask these questions before tuning duration or easing:

- What happens on a second tap?
- Can a drag reverse without a jump?
- What happens when new model state arrives?
- Does resize or rotation preserve the logical destination?
- Does navigation cancellation restore a complete source state?
- Can the view disappear while completion work is pending?
- Does the spring inherit velocity from the gesture or prior animation?
- Does Reduce Motion change while the screen is visible?

Model a newer user intent as superseding stale intent. Keep completion
idempotent and generation-aware when asynchronous work can outlive one motion.
Never use interaction blocking as the default way to make an animation “safe.”

## Review common failure modes

Report these patterns with the concrete user-visible consequence:

- broad `.animation` scope animates unrelated state;
- delayed callbacks mutate stale state after reversal or navigation;
- gesture progress drives multiple independent timelines instead of one source
  of truth;
- a new animation restarts from an old model endpoint and visibly jumps;
- raw points-per-second are passed as normalized spring velocity;
- `UIViewPropertyAnimator` is recreated during repeated transition callbacks;
- explicit `CAAnimation` leaves the model layer at its old value;
- manual frame logic assumes 60 Hz or advances by “units per frame”;
- an indefinite animation or display link remains active while hidden;
- Reduce Motion only shortens duration but preserves disorienting travel;
- a beta API becomes the unconditional production path;
- average FPS is presented as proof that no hitches occur.

Avoid blanket rules such as “only animate transforms” or “always add
`drawingGroup`.” Select and measure the property or rendering strategy in the
actual hierarchy.

## Define honest completion evidence

At minimum, verify:

- correct source and target states with animations enabled and disabled;
- rapid repeated and reversed input;
- cancellation, disappearance, and competing state changes;
- Reduce Motion and any animated-image preference that applies;
- fallback behavior on the oldest supported OS;
- representative Release behavior on hardware;
- absence of unbounded timers, display updates, animators, or retained
  transition contexts.

Claim “implemented; device profiling pending” when only code and automated
checks are available. Claim a hitch or power improvement only when comparable
before-and-after measurements support it.
