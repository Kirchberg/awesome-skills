# Responsiveness, launch, and termination

## Contents

- Response-time model
- Hangs
- Hitches
- Instruments hang workflow
- SwiftUI updates
- Launch and resume
- Terminations
- Regression prevention
- Tool and platform caveats

## Response-time model

Separate interaction types:

- A **discrete interaction** is a contained action followed by an update, such
  as tapping a button. A delay below roughly 100 ms is usually difficult to
  notice; longer delays increasingly feel like a hang.
- A **continuous interaction or animation** must deliver each update by a
  display deadline. Missing even one refresh interval can cause a hitch.

These are design guidelines, not universal pass/fail constants:

- Keep discrete-interaction work below 100 ms, and prefer a lower product target
  for latency-sensitive actions.
- At 60 Hz, a refresh interval is about 16.7 ms; at 120 Hz it is about 8.3 ms.
- Apple recommends keeping main-thread screen-update work below roughly 5 ms in
  common conditions so the rest of the rendering pipeline has time to finish.
- Use the actual begin time, commit deadline, presentation time, and refresh
  behavior exposed by the relevant API or trace. Do not assume every display or
  frame uses 16.7 ms.

Fix a shared hang cause before a hitch symptom: long main-thread work can create
both, and removing it may improve both metrics.

## Hangs

A hang is a period in which the main run loop cannot handle interaction. First
classify it:

- **Busy main thread**: the main thread is running too much code.
- **Blocked main thread**: the main thread waits for a lock, synchronous API,
  semaphore, dispatch group, I/O, IPC, another thread, or an executor dependency.

Most Apple tools report main-run-loop unresponsiveness above 250 ms by default.
The Hangs instrument can use lower thresholds. Do not treat 250 ms as an
acceptable UX target; it is a common reporting threshold.

For field data:

1. inspect Hang Rate, measured as seconds of main-thread unresponsiveness per
   hour and counting intervals longer than 250 ms, by app version, device, and
   available median or 90th percentile in Organizer;
2. open a diagnostic signature and symbolicated stack;
3. rank by affected population and duration, not stack novelty;
4. reproduce the same journey locally;
5. mark the report resolved only after a validated release addresses it.

Individual Organizer hang reports require an unresponsive main thread for at
least one second in the captured source set. Keep that report cutoff distinct
from the Hang Rate and user-perception thresholds.

For Thread Performance Checker findings:

- expand the full backtrace;
- remove synchronous networking and file or device I/O from the main thread;
- use the asynchronous API variant when available;
- investigate quality-of-service inversion when a high-priority waiter depends
  on lower-priority work;
- avoid using semaphores or dispatch-group waits to make an asynchronous API
  synchronous;
- make the waiter’s QoS no higher than the signaling work when a synchronous
  boundary is unavoidable.

## Hitches

A hitch is a late animation frame. Distinguish:

- **Commit hitch**: the app misses the deadline for submitting its UI update.
- **Render hitch**: the render server cannot complete the submitted work before
  presentation.

Organizer reports hitch rate in milliseconds of pause per second:

- `<= 10 ms/s`: good;
- `> 10` and `<= 25 ms/s`: warning;
- `> 25` and `<= 50 ms/s`: critical;
- `> 50 ms/s`: immediate attention.

Use those bands to prioritize field regressions, then inspect the affected
interaction locally. They do not replace an app-specific animation target.

In a hitch trace:

1. identify the late presentation and its expected frame lifetime;
2. classify commit versus render;
3. inspect main-thread update work for a commit hitch;
4. inspect effects, compositing, draw calls, shaders, and render-server work for
   a render hitch;
5. check whether variable refresh rate or inconsistent pacing creates the
   symptom;
6. validate consistent delivery, not merely a higher peak frame rate.

A steady 50 fps experience can be healthy when it consistently meets its chosen
20 ms interval. An isolated 50 ms frame among 16.7 ms frames is a stutter. Judge
relative to the intended cadence and actual deadlines.

## Instruments hang workflow

Follow the official Instruments tutorial strategy.

### Locate the interval

1. Record the exact interaction with Time Profiler and Hangs or the closest
   responsiveness template.
2. Select the hang interval and inspect the main-thread state.
3. Correlate CPU usage, thread state, points of interest, and call tree.
4. Decide whether the thread is busy or blocked before proposing a fix.

### Analyze a busy main thread

1. Inspect the selected interval’s call tree or flame graph.
2. Find the dominant app-owned call path.
3. Determine whether the cost is one slow execution or many short executions.
4. Inspect callers when a function executes too often; inspect callees when each
   call is expensive.
5. Prefer eliminating or reducing work.
6. Move work only when it is large enough to justify executor, copying, and
   synchronization overhead.

Apple’s tutorial uses about 1 ms of execution as a rough lower bound for work
worth considering for asynchronous execution. Treat that as a triage heuristic,
not a universal cutoff. Many sub-millisecond calls may still need optimization,
usually by reducing their count or changing the algorithm.

Time Profiler commonly samples near 1 ms, so sample count is not invocation
count and sub-millisecond work may not appear in a sample. Use signposts or a
specialized instrument when count and individual duration matter.

### Analyze a blocked main thread

1. Inspect the main-thread backtrace at the blocked interval.
2. Follow the dependency to the lock holder, awaited operation, queue, actor, or
   I/O provider.
3. Determine whether the dependency is synchronous or asynchronous from the
   main thread’s perspective.
4. Remove unnecessary waiting or redesign the boundary so progress does not
   require the main thread to block.
5. Verify in a new thread-state trace that the work actually runs on the
   intended background executor.

Creating a `Task` or dispatching from a main-isolated context does not by itself
prove that expensive work left the main thread. Inspect the new trace. Preserve
structured cancellation and return only the UI mutation to the main actor.
“Asynchronous” does not mean “background” or “parallel.”

## SwiftUI updates

Profile with the SwiftUI template when the symptom involves body computation,
layout, or invalidation frequency.

The SwiftUI instrument identifies:

- long View Body Updates;
- hosted UIKit or AppKit Platform View Updates;
- layout, text, and other update work;
- Update Groups and their causes;
- hitches correlated with view updates.

In the current instrument, view-body events longer than 500 microseconds appear
orange and those longer than 1,000 microseconds appear red. Use these as
instrument attention markers; prove user impact with the complete update group
and frame deadline.

For a long body update:

1. set the inspection range to the event;
2. correlate it with Time Profiler;
3. repeat the update when a single event yields too few samples;
4. move expensive calculation to the model or an asynchronous operation;
5. cache only when invalidation, memory, and freshness remain correct.

For too many short updates:

1. select the long-running Update Group;
2. inspect Summary: All Updates and update counts;
3. show the cause graph, including events immediately before the group;
4. identify the highest-frequency app-owned cause;
5. reduce observation breadth, event frequency, or hierarchy scope;
6. record again because another property may become the next cause.

Apply SwiftUI design rules:

- Keep `body`, initializers, `onAppear`, gesture updates, and state-mutating
  modifiers free of business logic and long work.
- Use Observation’s fine-grained property tracking where it fits the supported
  deployment targets.
- Isolate views whose state does not affect a parent layout.
- Threshold insignificant geometry changes before writing layout-driving state.
- Avoid storing child-building closures that capture broad parent state; create
  the child value in the initializer when semantics allow it.
- Treat action and parameterized closures separately, then measure their update
  effects rather than applying a mechanical rewrite.

## Launch and resume

Define the activation:

- On iOS, activation can be a process launch or a resume of a living process.
- Warm and cold launch are a spectrum determined by process, dependency, cache,
  memory-pressure, and device state.
- On macOS, normal activation usually does not require process launch, but
  compressor, swap, and redraw state still affect latency.

Use two boundaries:

- **System launch time**: user activation through the first drawn frame, as
  reported by Organizer and MetricKit.
- **User-ready time**: any additional app-defined work before the intended task
  becomes usable, recorded with points of interest.

Measure multiple representative states on physical devices:

- first launch after boot when relevant;
- forced-quit then launch;
- launch after ordinary app switching;
- launch after a memory-intensive workload;
- resume from common suspended states.

Profile with App Launch:

1. inspect process initialization, dynamic loading, UIKit initialization, scene
   and initial-frame rendering;
2. correlate Time Profiler and Thread State;
3. inspect dynamic libraries and static initializers;
4. inspect app- and scene-delegate launch callbacks;
5. inspect initial view complexity and drawing;
6. mark post-first-frame readiness work with signposts.

Optimization order:

- remove unnecessary embedded third-party dynamic libraries;
- consider mergeable libraries in Xcode 15 or later release builds after
  measuring build and launch tradeoffs;
- defer C++ static constructors, Objective-C `+load`, constructor attributes,
  and other pre-main work where semantics permit;
- keep launch delegates limited to work needed for the initial display;
- load only the data and image resolution needed for the first screen;
- use a simple initial hierarchy and avoid unnecessary custom drawing;
- refresh stale data asynchronously when the product can remain usable.

Do not improve the launch metric by drawing an unusable placeholder while
leaving the user blocked. Track and validate user-ready time too.

## Terminations

Treat termination as a lifecycle class, then use the matching evidence:

- **Abort, bad access, illegal instruction**: diagnose as crashes with a
  symbolicated crash report.
- **Memory limit**: inspect peak and sustained footprint, allocation paths, and
  large transitions.
- **App watchdog or launch timeout**: inspect launch progress and main-thread
  state; macOS has no equivalent launch-time limit.
- **Memory pressure**: reduce memory at suspension and provide correct state
  restoration; some background eviction is expected.
- **Background task timeout**: complete or end background tasks within their
  granted time.
- **File lock**: release shared App Group file locks before backgrounding.

Use Organizer termination data or MetricKit foreground and background
termination metrics to prioritize. Do not promise zero terminations; the system
uses eviction to protect foreground experience.

## Regression prevention

- Add an XCTest clock or signpost metric for a stable interaction.
- Use `XCTOSSignpostMetric` when hitch count, hitch ratio, or an app-defined
  points-of-interest interval is the contract.
- Use UI performance tests when the measured boundary crosses input and render.
- Fail tests on applicable runtime main-thread and priority-inversion issues
  when the test plan is ready.
- Keep Organizer or MetricKit monitoring for device-, population-, and
  lifecycle-dependent behavior.
- Validate launch across the states in the contract and responsiveness across
  the affected refresh rates and devices.

## Tool and platform caveats

The captured source describes:

- Hang Rate for iOS, macOS, and visionOS;
- individual Hang Reports for iOS and iPadOS;
- hitch-rate field data for iOS and iPadOS;
- Thread Performance Checker for iOS and macOS;
- Hangs detection on iOS/iPadOS 16, macOS 13, tvOS 16, watchOS 9, or visionOS
  with Instruments 14 or later;
- Animation Hitches outside visionOS, where RealityKit Trace is the relevant
  rendering investigation tool.

The linked Instruments tutorials use Xcode 16 and iOS 18 UI examples. Tool
labels, colors, thresholds, and menus can change. Verify the installed tool
instead of treating tutorial screenshots as an availability contract.
