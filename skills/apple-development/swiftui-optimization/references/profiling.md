# Profile SwiftUI performance

## Contents

- Capture a reproducible workload
- Use the available SwiftUI instrument
- Diagnose long work
- Diagnose frequent work
- Separate commit and render hitches
- Verify the correction

## Capture a reproducible workload

Record:

- the visible symptom and exact interaction;
- device model, OS, refresh rate, Xcode, and build configuration;
- data volume, network/cache state, and animation or scrolling duration;
- at least one baseline capture before editing.

Prefer an optimized build on a physical device. Repeat the same interaction
enough times to distinguish a stable result from warmup, caching, logging, and
sampling noise.

## Use the available SwiftUI instrument

With Instruments 26 and a supported device OS:

1. Choose Xcode **Product → Profile**.
2. Select the **SwiftUI** template.
3. Record the target interaction.
4. Inspect:
   - **Update Groups** for intervals in which SwiftUI performs work;
   - **Long View Body Updates** for expensive body calculations;
   - **Long Platform View Updates** for hosted UIKit or AppKit work;
   - **Other Long Updates** for geometry, text layout, and framework work;
   - **Hitches** for missed frame deadlines.

The SwiftUI instrument marks a body update orange above 500 μs and red above
1000 μs. Treat these as triage thresholds, not per-view budgets or proof of a
hitch.

If the installed toolchain lacks this instrument or a required lane, use Time
Profiler, Hangs, Hitches, Core Animation, signposts, and repository performance
tests as available. State which evidence could not be collected.

## Diagnose long work

1. Select the long SwiftUI event and set the inspection range.
2. Inspect the same interval in Time Profiler.
3. Use the call tree or Flame Graph to locate application code.
4. If one event is too short for useful samples, repeat the action and filter
   all calls made by the affected `View.body`.
5. Check for repeated calculations, synchronous I/O, decoding, allocation,
   formatting, layout, and third-party SDK work.

Do not optimize a highlighted system frame until the trace connects the cost to
inputs or content controlled by the app.

## Diagnose frequent work

A long `Update Group` with no individually long event can still exhaust a frame
deadline.

1. Open **Summary: All Updates** and compare view update counts.
2. Use **Show Causes** and the Cause & Effect Graph.
3. Extend the inspection range earlier when the triggering event precedes the
   update group.
4. Identify the most frequent application-owned cause.
5. Check broad observation, environment changes, geometry feedback, timers,
   transactions, unstable identity, and repeated event sources.
6. Fix one cause and capture again.

The cause graph may show only one changed property per edge, and may duplicate a
logical node for presentation. A second cause can become visible after the
first is removed.

Use `Self._printChanges()` or LLDB `expression Self._printChanges()` only to
supplement the trace. It gives a best-effort reason for `body` evaluation, is
underscored and unsupported, adds runtime work, and must not ship.

## Separate commit and render hitches

A hitch is a frame presented later than its target time. A dropped frame is one
possible recovery behavior, not a synonym.

- A **commit hitch** occurs when app/main-thread UI work and the Core Animation
  commit miss their deadline.
- A **render hitch** occurs when the app commits in time but render-server CPU
  or GPU work misses presentation.

At 60 Hz, one vsync interval is about 16.7 ms; at 120 Hz, about 8.3 ms. This is
not a budget for one `body`: event handling, all UI updates, commit, and other
work share the stage deadline. Displays use variable refresh rates, so prefer
trace timestamps over hard-coded arithmetic.

Use Xcode Organizer to prioritize shipping regressions. Apple's current Hitches
metric uses milliseconds of pause per second of animation:

- at or below 10 ms/s: good;
- above 10 and at or below 25 ms/s: warning;
- above 25 and at or below 50 ms/s: critical;
- above 50 ms/s: immediate attention.

Recheck tool availability for each target platform and Xcode version. Current
Apple documentation excludes the Hitches instrument on visionOS and Organizer
hitch metrics on tvOS and visionOS.

## Verify the correction

Run the same scenario and report:

- before and after distributions or repeated captures, not one favorable run;
- update count and duration for the affected view or group;
- hitch rate, hitch duration, or missed-deadline evidence;
- main-thread, render, memory, and I/O effects as relevant;
- behavior, state, actions, navigation, accessibility, and cancellation tests.

Do not claim an improvement when work merely moved to an unmeasured phase,
resource usage regressed materially, or the UI stopped responding to valid
state changes.
