# Animation testing and evidence

Use this reference to test state transitions, interruption, accessibility,
availability, rendering behavior, and animation-performance regressions.

## Contents

- Test logic independently of pixels
- Test animation lifecycle
- Exercise interaction and cancellation
- Verify accessibility and availability
- Build UI and visual checks
- Add performance regression metrics
- Run the device matrix
- Report evidence truthfully

## Test logic independently of pixels

Extract deterministic decisions from framework callbacks:

- progress normalization;
- destination selection;
- velocity normalization;
- detent thresholds and hysteresis;
- phase or keyframe configuration;
- generation and cancellation rules;
- state reduction for complete and cancelled transitions;
- Reduce Motion variant selection;
- availability fallback selection where it can be injected.

Test boundary values, zero displacement, negative direction, large velocity,
repeated events, and stale generations.

Do not unit-test a duration by sleeping until it probably elapsed. Test the
state rule synchronously and use framework completion for integration coverage.

## Test animation lifecycle

For each component, verify:

- source state before motion;
- target state after logical completion;
- fully settled state when different from logical completion;
- no-animation state;
- deallocation or teardown before completion;
- a newer target superseding an older target;
- exactly-once finalization;
- animator, task, timer, display-link, and callback cleanup.

For SwiftUI, keep reducer or target-selection logic separate from rendering.
For UIKit, expose narrow animator ownership seams without making the animation
implementation itself a global test object.

For Core Animation, verify the model layer holds the target independent of the
animation object.

## Exercise interaction and cancellation

Exercise the same motion at multiple interruption points:

- immediately after start;
- around 25%, 50%, and 75%;
- just before completion;
- after a high-velocity reversal;
- after repeated taps or target changes;
- during rotation or resize;
- during navigation cancellation;
- during backgrounding and disappearance.

Verify position continuity, direction, final logical state, interaction
availability, and cleanup. Use high-frame-rate screen recording only as
supporting visual evidence.

For view-controller transitions, assert complete and cancelled hierarchy
outcomes. Confirm `completeTransition` follows the actual cancellation result.

## Verify accessibility and availability

Test with:

- Reduce Motion disabled and enabled;
- cross-fade preference where exposed and relevant;
- animated-image playback preference where relevant;
- animations programmatically disabled;
- the oldest supported OS fallback;
- the newest stable OS path;
- prerelease paths separately when the user explicitly includes them.

Ensure every variant reaches the same product state and retains labels, focus,
hit targets, and controls.

Do not claim Reduce Motion support from a shorter duration alone. Do not claim a
fallback compiles merely because the newer branch is guarded at runtime; build
with the project's actual supported toolchain.

## Build UI and visual checks

Use UI tests for user-observable state and interaction:

- trigger through the real control;
- wait on state or accessibility conditions rather than copied durations;
- verify both completion and cancellation;
- repeat input rapidly;
- collect screenshots or video at intentional checkpoints.

Screenshot tests prove stable frames, not interpolation quality. Use them for
source, target, reduced-motion, and fallback states. Keep time-driven content
deterministic by injecting a clock or stable timeline where the architecture
allows it.

Avoid globally disabling animations in every UI test when the test is meant to
cover navigation or animation lifecycle. Disable them only for tests whose
purpose is unrelated deterministic layout.

## Add performance regression metrics

Use `XCTHitchMetric` where the selected SDK supports measuring animation
hitches. Use `XCTOSSignpostMetric` to delimit a custom transition or critical
flow, and the scrolling and deceleration metric for its intended scrolling
scenario.

A signpost duration metric alone does not prove hitch-free rendering. Combine
the metric that answers the performance question with trace evidence during
diagnosis.

Define:

- the optimized build and device class;
- deterministic data and starting state;
- warm-up policy;
- exact input automation;
- signpost boundaries;
- metric and threshold;
- sample count and acceptable variance;
- baseline storage and regression policy.

Keep functional assertions in the performance test. A fast transition that
settles in the wrong state is a failure.

Do not make thresholds so broad that large regressions pass, or so hardware
specific that normal device variance causes noise. Establish them from repeated
representative measurements.

## Run the device matrix

Select the smallest matrix that can support the claim:

- oldest and newest supported OS;
- a slower supported device and a high-refresh device when relevant;
- compact and regular layouts, rotation, resize, and multitasking where
  supported;
- light and dark appearance when compositing differs;
- Reduce Motion variants;
- representative Dynamic Type where geometry changes;
- Release or profiling build for performance;
- a realistic data and visual-effect load.

Test on physical hardware before claiming smoothness, refresh-rate behavior,
power efficiency, or fixed hitches.

For continuous effects, include a sustained run long enough to expose thermal
or power behavior and verify updates stop when hidden.

## Report evidence truthfully

Finish with:

- motion contract and expected outcomes;
- tested framework and API path;
- Xcode, SDK, OS, device, and build configuration;
- interruption and cancellation points;
- accessibility variants;
- availability and fallback builds;
- functional tests and UI checks;
- performance metrics and trace interval;
- resource-lifetime result;
- untested paths and remaining risk.

Use:

- “behavioral tests passed; device motion verification pending” when hardware
  was not exercised;
- “no hitch observed in the measured scenario” for a clean bounded capture;
- “improved measured hitch time from A to B in scenario C” only with equivalent
  before-and-after evidence.

Never generalize one device, one run, or average FPS into a claim that all
animations are smooth.
