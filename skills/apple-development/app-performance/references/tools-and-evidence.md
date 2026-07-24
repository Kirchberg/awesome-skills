# Tools and evidence routing

## Contents

- Evidence layers
- Xcode Organizer
- MetricKit
- Instruments routing
- Call-tree interpretation
- Points of interest and logging
- XCTest and runtime checking
- Debug-time tools
- Custom modelers
- Availability and privacy

## Evidence layers

Use the layers together:

- **Field population** reveals which versions, devices, percentiles, and
  signatures affect real users.
- **Representative device profiling** explains a reproducible mechanism.
- **Automated performance tests** prevent a stable mechanism from returning.
- **Functional tests** prove that the optimization preserves behavior.

No layer substitutes for every other layer. A lab trace cannot establish field
prevalence, and a field metric rarely identifies the exact source line.

## Xcode Organizer

Use Organizer for anonymized App Store performance data when enough participating
devices have reported it.

Start in Insights to find:

- regressions and high-impact metrics;
- top or trending diagnostic signatures;
- metrics that exceed an available goal;
- links to the detailed metric and diagnostic panes.

In a detailed pane:

1. select the affected version;
2. filter by device, app or App Clip, and median or high percentile where
   offered;
3. compare the selected version with the latest or prior version;
4. inspect historical and similar-app goals when Xcode provides them;
5. include margin of error in the conclusion;
6. open the diagnostic signature and symbolicated backtrace when available.

“Insufficient usage data” is an evidence limitation, not a zero value.
Organizer’s current high-impact regression notification requires sufficient
data and a regression of at least 75 percent relative to the average of the
previous four available App Store versions. Treat this as Xcode’s notification
rule, not as the product’s acceptable regression budget.

Useful panes and reports include launch and resume-related data, hangs, hitches,
memory, terminations, disk writes and storage, energy or battery, crashes, and
other diagnostics exposed by the installed Xcode version.

## MetricKit

Use MetricKit when the app needs its own pipeline for daily on-device metrics and
diagnostics.

- Preserve histogram buckets, time windows, device metadata, and payload
  version.
- Separate launch, resume, responsiveness, memory, disk, network, energy, and
  custom-signpost semantics.
- De-duplicate payloads before aggregation.
- Remove or minimize user-identifying context.
- Correlate app version and device class before comparing releases.
- Do not report a bucket midpoint as an exact observed duration.

Use Organizer when its aggregation is sufficient. Add MetricKit when the team
needs custom dashboards, custom intervals, retention, alerting, or correlation
with app-controlled release data.

## Instruments routing

Choose the smallest relevant template or instrument set.

### Responsiveness and launch

- Use **App Launch** for launch phases, time profile, thread state, dynamic
  loading, and static initialization.
- Use **Time Profiler** with App Life Cycle to inspect initialization and the
  first frame from another angle.
- Use **Hangs** or a responsiveness-oriented template to find main-run-loop
  unresponsiveness and separate busy from blocked intervals.
- Use the hitch or animation analysis instruments exposed by the installed
  Xcode to separate app commit work from render-server work.
- Use the **SwiftUI** instrument for long view-body work, update causes, and
  excessive update frequency.

### CPU

- Use **Time Profiler** first for broad CPU hot paths and thread attribution.
- Use **CPU Counters** in CPU Bottlenecks mode after higher-level algorithmic
  waste is excluded and a scenario misses its CPU or latency goal.
- Use **Processor Trace** when exact function-call flow, instruction and cycle
  counts, or low-overhead whole-thread history is required and the hardware and
  OS support recording it.

As documented in the source set captured on 2026-07-24, Processor Trace
recording requires Instruments 16.3 or later and supported recent hardware:
iPhone 16 or later, iPad Pro with M4 or later, or Mac with M4 or later, with
iOS/iPadOS 18.4 or macOS 15.4 or later. Any Mac can analyze a saved trace.
Verify this availability against the installed tools because Apple can expand
support.

### Memory and size

- Use Xcode’s memory report and gauge for a quick device-level signal.
- Use **Debug Memory Graph** with allocation stack logging to inspect ownership
  and retain cycles.
- Use **Allocations** and generation marks for allocation categories, peaks, and
  feature-scoped growth.
- Use **Leaks** for allocated memory that has become unreachable.
- Use **Game Memory** for process footprint and Metal resource allocations.
- Use an App Thinning Size Report and exported device variants for install and
  download size; Instruments is not the primary app-size tool.

### Power, storage, and network

- Use Xcode’s running-app energy impact and Organizer energy diagnostics for
  initial signals.
- Use **Power Profiler** on a physical device for subsystem-level power impact
  over a representative scenario.
- Use **File Activity**, disk-write diagnostics, and storage metrics for I/O
  timing, frequency, and volume.
- Use the **Network** instrument for HTTP tasks, transactions, timing, bytes,
  redirects, failures, and request relationships.

### Metal

- Use **RealityKit Trace** for visionOS app and shared render-server stalls,
  scene update cost, and RealityKit workload analysis.
- Use **Game Performance** to correlate display delivery, CPU, GPU, thermal,
  frame, and limiter data when the target supports it.
- Add performance-limiter or utilization counters only when they answer the
  current CPU-versus-GPU question.
- Use **Game Memory** to correlate Metal resources with the process memory
  footprint when available for the target.

## Call-tree interpretation

Set an inspection range around the exact scenario before ranking symbols.

- **Self cost** belongs to the function’s own body.
- **Total cost** includes descendants.
- A wide flame-graph node indicates a large share of the selected interval, not
  necessarily a defect.
- Top Functions reveals aggregate contributors; inspect the caller path before
  editing.
- Separate one expensive call from a cheap call repeated many times.
- Use thread state to distinguish CPU work from blocking or waiting.

Use charge, prune, and flatten deliberately:

- **Charge to callers** hides a helper or library while attributing its work to
  the caller that requested it.
- **Prune** removes an irrelevant subtree from the current view.
- **Flatten to boundary frames** hides library internals while retaining
  cross-library boundaries.

Keep an unmodified view available so filtering cannot erase the causal context.

When comparing runs in Instruments, candidate `+` and baseline `−` percentages
describe change between runs, not each node’s share of total samples. A symbol
only in the candidate may appear as positive infinity; investigate the call
path rather than treating infinity as a literal slowdown factor.

## Points of interest and logging

Use `OSSignposter` or an `OSLog` in the points-of-interest category when:

- perceived readiness extends beyond a system launch metric;
- a feature crosses multiple queues, actors, processes, or subsystems;
- repeated events need stable names for XCTest or MetricKit signpost metrics;
- a trace otherwise lacks meaningful scenario boundaries.

Give intervals stable, low-cardinality names. Put variable identifiers in
metadata only when privacy and cardinality are controlled. Balance begin and end
events across cancellation and error paths.

Logging is not a replacement for measurement. Avoid high-volume diagnostic logs
inside the performance-critical interval when comparing production behavior.

## XCTest and runtime checking

Match the metric to the contract:

- `XCTClockMetric` for elapsed time;
- `XCTCPUMetric` for CPU activity;
- `XCTMemoryMetric` for peak and growth behavior;
- storage or signpost metrics when the scenario is defined by those resources
  or app intervals;
- launch and UI performance metrics when a UI test owns the journey.

Keep setup outside the measured block unless setup is the behavior under test.
Use consistent data and iteration semantics. Inspect the distribution before
setting a baseline, then let the test compare future runs with that baseline.

Thread Performance Checker finds priority inversions and non-UI synchronous
work on the main thread without recompilation. It is documented for iOS and
macOS and is enabled by default for app Run schemes. Inspect the full backtrace.
In test plans, configure applicable Runtime API Checking entries as failures
only when the test environment and team are ready to enforce them.

Do not disable or suppress a runtime warning merely to make a test pass. Record
the reason, scope, owner, and removal condition for any temporary suppression.

## Debug-time tools

Use Debug navigator gauges, memory graphs, and runtime checkers to shorten the
feedback loop. Confirm meaningful findings with a physical-device,
production-like measurement.

Simulator can help reveal CPU stalls, call paths, invalidation patterns, or
algorithmic mistakes. It does not reproduce the device rendering, input, media,
memory-pressure, thermal, or power environment closely enough for final claims.

## Custom modelers

Create an intelligent Instruments custom modeler only when repeated analysis
requires deriving stable domain events or engineering tracks from existing
recorded data and built-in instruments cannot express them.

Before adopting one:

- define the input schema, clock, identity, and expected output facts;
- prevent incomplete facts from reaching the recorder;
- define behavior for overlapping, missing, or out-of-order intervals;
- test speculation rules and compression against small known traces;
- validate every derived row and narrative against raw source events;
- version the modeler with the producer schema.

Apple’s sample uses the CLIPS rule language and demonstrates custom engineering
tracks, row and column output actions, signpost compression, speculation, data
transformation, and overlap handling. Treat it as an advanced extension point,
not the default way to profile an app.

The sample’s metadata and body describe different layers of availability:
current sample/project requirements versus the older introduction of modelers
and engineering tracks. Do not collapse them into one deployment target. Verify
the sample with the installed Xcode and intended platform. The captured page
also contains an internally inconsistent helper description; use the working
sample and current tool documentation instead of copying helper signatures from
prose.

## Availability and privacy

Record the Xcode, Instruments, device, and OS version beside every capture.
If a named tool is unavailable, select the nearest supported evidence source and
state the loss of precision.

Do not upload or commit raw Organizer exports, MetricKit payloads, traces,
memory graphs, network captures, dSYMs, or logs without checking repository and
privacy policy. Redact tokens, URLs with personal data, user content, and stable
device identifiers before sharing artifacts.
