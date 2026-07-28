# Design motion, feedback, and haptics with purpose

Use feedback to explain cause, state, hierarchy, and spatial continuity. Treat
motion, sound, and haptics as coordinated channels, never as decoration or the
sole carrier of essential information.

## Define the feedback contract

For each meaningful event, specify:

- the user action or system event that causes it;
- the state before and after the event;
- what the person must understand;
- the visual, auditory, and tactile channels available;
- interruption, cancellation, repetition, and failure behavior;
- the reduced-motion, silent, unsupported-device, or disabled-haptics fallback.

Apply three tests:

- **Causality**: Does the feedback have an obvious trigger?
- **Harmony**: Do motion, sound, and touch describe the same event?
- **Utility**: Does the feedback improve understanding, control, or confidence?

Remove feedback that fails these tests.

## Specify meaningful motion

- Use transitions to preserve the relationship between source and destination.
- Make state changes move in the direction implied by the interaction and
  information architecture.
- Keep gesture-driven motion attached to the gesture, preserve relevant
  velocity, and support reversal or interruption.
- Let spring or timing behavior communicate physical relationship, not a brand
  mood chosen independently of the interaction.
- Animate the smallest layer that explains the change. Avoid moving stable
  context when only one value or control changed.
- Keep repeated, ambient, and autoplay motion bounded and pausable when it can
  distract or cause discomfort.
- Define behavior when data arrives late, a transition is cancelled, the app
  backgrounds, or the destination disappears.

Do not prescribe remembered durations or spring constants as universal rules.
Use current system behavior where available and tune custom motion in the real
layout on representative hardware.

## Respect Reduce Motion

Design the reduced-motion alternative at the same time as the primary
transition. Preserve hierarchy, completion, and spatial meaning with opacity,
highlight, instant replacement, or a simpler transition as appropriate.

Do not merely shorten a disorienting zoom, depth, parallax, rotation, or
continuous movement. Remove or replace the problematic spatial effect. Verify
the actual runtime environment setting rather than assuming framework defaults
cover custom animation.

## Choose haptics proportionally

Preserve feedback already supplied by standard controls. When the app must
trigger an ordinary selection, impact, success, warning, or error event, choose
the semantic `SensoryFeedback` or standard feedback API appropriate to the
framework, platform, hardware, and deployment target. Use Core Haptics only when
the product needs a justified custom or continuous tactile language that
standard feedback cannot express.

- Pair the haptic with the exact visual state change.
- Avoid feedback on every tap, scroll tick, or repeated event.
- Do not fire success feedback before an asynchronous operation succeeds.
- Avoid conflicting or overlapping patterns during rapid interaction.
- Respect device support and user settings; never require haptics to complete a
  task or distinguish a critical state.

## Specify implementation-ready behavior

Record the trigger, source and destination, animated properties, continuity
anchor, timing model, interruptibility, gesture relationship, haptic semantic,
sound relationship, accessibility alternative, and availability fallback.

Prefer system transitions and feedback when they express the intended
relationship. If custom behavior is necessary, explain the product benefit and
define how it remains consistent across refresh rates, input methods, window
sizes, and platform variants.

## Validate on hardware

Exercise start, completion, cancellation, reversal, rapid repetition,
backgrounding, slow data, and concurrent feedback. Test with Reduce Motion,
sound off, haptics unavailable, and accessibility settings used by the product.
Use performance tools when motion hitches or misses frames; a video or design
prototype alone cannot prove runtime fluidity or tactile quality.
