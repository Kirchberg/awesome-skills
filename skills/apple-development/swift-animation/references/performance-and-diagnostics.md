# Animation performance and diagnostics

Use this reference to reproduce and localize hitches, inspect SwiftUI updates,
separate commit and render cost, evaluate rendering changes, and make bounded
smoothness or power claims.

## Contents

- Define a measurement contract
- Understand frame deadlines
- Separate commit and render phases
- Inspect SwiftUI update work
- Inspect rendering and compositing
- Evaluate frame-driven effects and power
- Measure with Apple tools
- Monitor production behavior
- Report only supported conclusions

## Define a measurement contract

Before profiling, record:

- device model, OS, display refresh behavior, thermal state, and power mode;
- Xcode and selected SDK;
- app version, build configuration, optimization level, and diagnostics;
- exact screen, data set, visual effects, input sequence, and start state;
- cold or warm caches and whether image or shader preparation is included;
- expected animation duration and user-visible acceptance;
- signpost or trace interval boundaries;
- baseline and candidate runs under equivalent conditions.

Profile optimized builds on representative hardware for performance claims.
Use the simulator for quick logic reproduction, not final frame or power
evidence.

## Understand frame deadlines

A hitch occurs when work needed for a frame misses its presentation deadline.
Average FPS can hide a few large stalls and cannot identify the responsible
phase.

Record:

- hitch count and duration in the relevant interval;
- hitch time ratio or the current tool's equivalent;
- longest and representative hitches;
- animation or interaction signpost boundaries;
- main-thread and rendering evidence around each hitch;
- input-to-visual-response latency when direct manipulation is involved.

Do not define success as “looks smooth to me.” Slow-motion video can illustrate
a symptom but does not replace a trace.

## Separate commit and render phases

Investigate commit-side causes when the app cannot prepare and commit state in
time:

- long main-thread work;
- repeated SwiftUI body evaluation and dependency fan-out;
- Auto Layout or custom layout passes;
- large view or layer hierarchy mutation;
- image decoding, text layout, path generation, or synchronous I/O;
- broad observation or model updates;
- allocation, copying, logging, and bridging in the critical interval.

Investigate render-side causes when committed content is expensive to produce
or composite:

- large blended or translucent regions;
- blur, shadow, mask, clipping, and corner treatment;
- offscreen render passes;
- oversized rasterized surfaces;
- high fill rate or overdraw;
- complex paths, filters, shaders, and many animated layers;
- texture upload or frequently changing rendered content.

Do not apply a render optimization to a commit hitch or refactor state
architecture to explain a verified GPU bottleneck.

## Inspect SwiftUI update work

Use the current SwiftUI Instrument and cause-and-effect views available in the
selected Xcode to identify:

- which state change caused the update;
- how often affected bodies evaluate;
- long view updates;
- identity churn;
- main-actor work during the motion;
- broad environment or observable dependencies.

Reduce dependencies and update scope before adding rendering caches. Keep stable
identity and avoid rebuilding large subtrees for every gesture sample.

Use `$swiftui-optimization` when the root cause expands into general
Observation, identity, diffing, scrolling, or resource-lifetime architecture.

## Inspect rendering and compositing

Evaluate `compositingGroup`, `drawingGroup`, and `geometryGroup` by their
semantics:

- grouping can change where an effect applies;
- `drawingGroup` creates an offscreen Metal-rendered surface and consumes
  memory;
- a rasterized result may help expensive content that changes as one unit;
- frequently changing, large, scaled, or high-resolution content may regress.

Capture before and after. Compare hitch behavior, memory, visual fidelity, and
power. Remove the modifier when evidence does not support it.

Prefer precomputed paths, bounded effects, smaller surfaces, fewer overlapping
transparent layers, and system effects when they preserve the design.

Do not assume transforms and opacity are always free. Their backing content,
surface size, blending, and hierarchy still matter.

## Evaluate frame-driven effects and power

For `TimelineView`, display links, update links, particles, equalizers, progress
visualizations, or shaders:

- verify that every update changes visible content;
- select the lowest useful cadence;
- compute from elapsed time;
- stop when offscreen, obscured, inactive, or static;
- bound mark, particle, sample, and layer counts;
- avoid per-frame allocations and synchronous work;
- profile a realistic duration, not only startup.

A device can maintain target frame cadence while spending excessive CPU, GPU,
memory bandwidth, and battery. Measure power and thermal behavior for continuous
or prominent effects.

## Measure with Apple tools

Select tools by question:

- use the Animation Hitches and related Instruments templates to locate missed
  frame deadlines;
- use Time Profiler for CPU stacks in the interval;
- use the SwiftUI Instrument for update causes and long view work;
- use Core Animation or rendering diagnostics available in the selected Xcode
  for compositing clues;
- use Allocations and memory tools for per-frame churn or retained surfaces;
- use Power Profiler and Energy diagnostics for continuous effects;
- use signposts to delimit the exact transition;
- use XCTest metrics for repeatable regression scenarios.

Tool names and metric availability change across Xcode generations. Verify the
current tool rather than copying an older walkthrough literally.

Run enough equivalent samples to distinguish repeatable behavior from noise.
Record median and tail behavior where the metric supports it.

## Monitor production behavior

Use Xcode Organizer and MetricKit capabilities supported by the shipped SDK and
OS to identify regressions that do not reproduce locally.

Keep stable animation or screen identifiers without recording private content.
Correlate:

- app version and OS;
- device class;
- flow or signpost;
- hitch or responsiveness metric;
- scene and application state;
- feature configuration.

Treat Xcode 27 Organizer's expanded Hitches view and the Swift-first MetricKit
generation as prerelease until the selected toolchain and platform release are
stable. Keep existing production collection paths while evaluating a beta
replacement.

Do not promise a minimum runtime for new Organizer aggregation unless Apple
documents it. Do not claim an individual user's exact animation from an
aggregate report.

## Report only supported conclusions

Report:

- reproduction and measurement contract;
- selected interval and metric;
- commit, render, mixed, or unresolved classification;
- baseline and candidate evidence;
- code or configuration change;
- visual, memory, and power tradeoffs;
- device and build limitations;
- remaining uncertainty and production follow-up.

Use “no hitch observed in this measured scenario” instead of “hitch-free.”
Route a broad investigation spanning unrelated subsystems to
`$app-performance`.
