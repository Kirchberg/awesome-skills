---
name: app-performance
description: Use when measuring, diagnosing, planning, improving, or preventing regressions in the performance of an Apple-platform app with Xcode, Instruments, Xcode Organizer, MetricKit, or XCTest. Applies to launch and resume time, hangs, hitches, SwiftUI updates, CPU use and bottlenecks, memory pressure and terminations, app size, Metal frame time and memory, battery and thermal impact, disk writes and storage, HTTP traffic, and custom Instruments analysis. Trigger for requests such as "profile this iOS app", "why does this screen hang", "reduce launch time", "investigate a memory regression", "build a visionOS performance plan", or "add performance tests". Do not use for a functional bug with no performance symptom, a server-only workload, or speculative micro-optimization without a measurable user or resource outcome.
---

# Diagnose and improve Apple app performance

## Outcome

Turn a performance symptom into a reproducible scenario, supported cause,
narrowly scoped change, and proportionate validation. Use runtime evidence to
locate unknown costs and support performance claims. Do not require Instruments,
charts, Simulator, or a physical device before applying a low-risk,
semantics-preserving correction proved directly by source, control flow,
complexity, dependency scope, or ownership.

## Read references selectively

- Read `references/methodology.md` before planning, profiling, or changing code.
- Read `references/tools-and-evidence.md` before choosing a capture, field metric,
  automated test, signpost, or custom instrument.
- Read `references/responsiveness.md` for launch, resume, hangs, hitches, SwiftUI,
  main-thread work, and termination symptoms.
- Read `references/cpu-memory-size.md` for CPU, Processor Trace, call trees,
  memory, low-memory events, jetsam, leaks, or app-size work.
- Read `references/power-storage-network.md` for battery, thermal pressure,
  background work, rendering efficiency, media capture, location, Bluetooth,
  disk writes, storage footprint, or HTTP traffic.
- Read `references/graphics.md` for Metal frame pacing, CPU/GPU limiting factors,
  and Metal memory.
- Read `references/apple-source-map.md` only when auditing coverage or refreshing
  this skill against Apple documentation.

Repository instructions, supported project commands, and explicit user scope
override generic examples. They do not weaken evidence or correctness gates.

## Classify the request

Choose one operating mode:

- **Plan**: define scenarios, metrics, targets, tools, and gates; do not profile or
  edit unless asked.
- **Diagnose**: gather evidence and identify a root cause; do not implement a fix
  unless the request includes one.
- **Improve**: apply every safe in-scope source-proven correction, diagnose
  measurement-dependent candidates, and validate proportionately.
- **Prevent**: add a stable performance test, baseline, runtime check, or field
  monitoring after defining the behavior it protects.

Clarify the app, feature, platform, and performance symptom. Do not turn a
bounded request into a whole-app optimization campaign.

Treat a request to optimize, improve, fix, refactor, or implement as **Improve**
authority within its named scope. Do not downgrade it to Diagnose because a
profiler, device, baseline, or performance test is unavailable.

## Define the performance contract

Record before measuring:

- the exact user journey or background operation and its start and end;
- device model, OS, Xcode, build configuration, and relevant app version;
- app, install or upgrade, data, account, network, power, and thermal state;
- metric, unit, aggregation, target, and whether lower or higher is better;
- field population or percentile when using Organizer or MetricKit;
- acceptable tradeoffs in latency, throughput, memory, energy, size, fidelity,
  freshness, and implementation complexity;
- baseline procedure, run count, and completion gate.

For visionOS, also record Shared Space versus immersive use, session duration,
rendering workload, and relevant environmental or thermal conditions.

## Select evidence proportionately

1. For a shipped regression, begin with Organizer Insights, metric distributions,
   diagnostic signatures, and MetricKit where available. Filter by app version,
   device, and percentile.
2. For a reproducible local symptom, profile a release-like build on a physical
   affected device with the narrowest relevant Instruments template.
3. For an early runtime risk, use Thread Performance Checker, memory graph, debug
   gauges, or a focused trace to form a hypothesis, then confirm it under
   representative conditions.
4. For regression prevention, use XCTest metrics or replayable Instruments
   interactions around a stable scenario. Add points of interest around
   app-defined intervals when system metrics do not express the whole journey.

Treat Simulator and Debug-build observations as leads, not device performance
proof. Retain the dSYMs for profiled distribution builds.

Use source evidence directly when it proves unnecessary work, worse complexity,
a synchronous constrained-path operation, an invalid dependency scope, or a
broken resource lifetime and the correction preserves behavior. Collect runtime
evidence to locate an unknown bottleneck, quantify impact, resolve a material
tradeoff, or claim an app-level outcome—not to grant permission for that edit.

## Route by symptom

- **Slow input or frozen UI**: separate a busy main thread from a blocked main
  thread, then inspect the responsible interval and call path.
- **Jerky motion**: separate commit hitches from render hitches and reason from
  the actual display deadlines, not a hard-coded frame duration.
- **Slow activation**: distinguish launch from resume and cold from warm
  conditions; measure both time to first draw and app-defined readiness.
- **High CPU or latency**: find the expensive scenario with Time Profiler or a
  call tree before using CPU Counters or Processor Trace for microarchitectural
  or instruction-flow questions.
- **Memory growth or termination**: distinguish leaks, reachable unused objects,
  transient peaks, dirty footprint, memory at suspension, and system pressure.
- **Energy or thermal impact**: correlate power with CPU, GPU, networking,
  location, media, timers, and background execution over the complete scenario.
- **Disk or network cost**: measure bytes, frequency, timing, batching, cache
  behavior, and lifecycle rather than optimizing request or write count alone.
- **Metal stutter or memory**: identify the limiting CPU/GPU stage and inspect
  resource lifetime before changing shaders, frame rate, or allocation strategy.

## Run the evidence loop

1. Preserve unrelated work and establish a repeatable baseline when the
   decision or claim depends on runtime behavior.
2. For runtime-dependent work, capture the smallest interval that reproduces
   the symptom. Mark it with a signpost when its boundaries are ambiguous.
3. Inspect the relevant evidence: timeline state and call paths for a capture;
   callers, control/data flow, dependency scope, complexity, and ownership for
   direct source proof.
4. State one falsifiable causal mechanism and the evidence that supports it.
5. In Improve mode, implement one semantically coherent change. Preserve
   cancellation, ordering, actor or thread isolation, priority, data integrity,
   UI correctness, accessibility, and recovery behavior.
6. When measuring, repeat the same scenario on the same class of device and
   build. Compare the candidate with the baseline, including variability and
   relevant resource tradeoffs.
7. Add an appropriate regression guard when the scenario is stable enough, then
   check the nearest functional tests and production configuration.
8. Continue only if the next bottleneck remains in scope.

## Apply hard guardrails

- Fix supported causes, not symbols that merely appear high in a broad trace. A
  supported cause may come from matched runtime evidence or direct source proof.
- Apply a safe source-proven correction without waiting for a profiler. Never
  describe an unmeasured edit as a verified performance gain.
- Fix hangs before hitches when the same main-thread work can cause both.
- Do not move tiny repeated work to another executor without accounting for
  scheduling and synchronization overhead; doing less work may be better.
- Do not infer a leak from memory growth alone or safety from the absence of a
  Leaks report.
- Do not invent a universal memory ceiling, launch-watchdog timeout, power score,
  or frame budget. Use the affected device, platform, API deadlines, and field
  distribution.
- Do not equate high CPU utilization with a CPU bottleneck, or high GPU
  utilization with a defect. Relate utilization to missed goals and limiting
  stages.
- Do not suppress Thread Performance Checker, lower fidelity, discard caches, or
  increase batching unless the measured tradeoff is acceptable.
- Do not claim improvement from one favorable run, unmatched conditions, an
  unsymbolicated trace, or a change that fails functional checks.
- Note tool and API availability explicitly; use a supported fallback rather
  than assuming the newest Instruments feature exists.

## Report completion

Always provide the selected mode, symptom, scope, and performance contract.
When collected or applicable, also provide the test environment, field evidence,
local reproduction status, trace or report and inspected interval, supported
root cause, resource tradeoffs, platform limitations, unresolved risks, and next
bottleneck. In Plan mode, mark those evidence fields as not collected instead of
implying that measurement occurred.

Then complete the selected mode:

- **Plan**: provide proposed scenarios, metrics, tools, baselines, and gates
  without claiming that measurements ran.
- **Diagnose**: provide the supported root cause or bounded hypothesis, rejected
  alternatives, missing evidence, and next discriminating measurement; do not
  report a code change.
- **Improve**: provide changed files, causal mechanism, functional checks, and
  regression guards when the scenario is stable enough. Provide baseline and
  candidate results with units, aggregation, and variability when collected or
  required for the claim.
- **Prevent**: provide the protected scenario, metric and baseline semantics,
  test or monitoring result, functional check, and ownership of future baseline
  changes.

If a required physical device, symbol file, field sample, or supported tool is
unavailable, report the limitation and bound the performance claim. In Improve
mode, still apply safe source-proven corrections and report their functional
validation. Do not label a hypothesis as a fix or an unmeasured correction as a
verified app-level improvement.
