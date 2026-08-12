# Profiling, testing, and evidence

## Contents

- Start from the affected population
- Reproduce a narrow local scenario
- Classify the hitch
- Inspect collection-specific work
- Instrument only useful boundaries
- Compare baseline and candidate
- Add proportionate regression guards
- Preserve functional behavior

## Start from the affected population

For a shipped regression, begin with Xcode Organizer hitch and hang data or a
MetricKit pipeline when available. Filter by app version, device family, and
available percentile. Keep field prevalence separate from a local causal trace.

Organizer currently reports hitch rate in milliseconds of pause per second:

- at or below 10 ms/s: good;
- above 10 through 25 ms/s: warning;
- above 25 through 50 ms/s: critical;
- above 50 ms/s: immediate attention.

Use these as Xcode prioritization bands, not as the product's universal pass
criteria. Record the installed Xcode version because tools, goals, labels, and
availability change.

## Reproduce a narrow local scenario

Profile a production-like optimized build on a physical affected device,
preferably including an older supported device. Match data size, image state,
network behavior, content-size category, cache state, and scroll gesture.

Reproduce once without profiling. Then select the narrowest instrument set that
can answer the question:

- responsiveness or hitch analysis plus Time Profiler for late cell work;
- Hangs and thread state for long or blocked main-run-loop intervals;
- Allocations or a memory graph for churn, retained cells, tasks, or caches;
- Core Animation or rendering-oriented tracks for render-server complexity;
- Network and points of interest for request timing and placeholder duration;
- SwiftUI instrumentation when a hosted SwiftUI subtree dominates updates.

Treat a Debug or Simulator symptom as a lead. Do not use it as final device
performance proof.

## Classify the hitch

Find the late presentation and expected frame lifetime, then distinguish:

- **Commit hitch**: app-side event handling, cell configuration, Auto Layout,
  layout invalidation, display preparation, image decode, or layer-tree commit
  misses the app deadline.
- **Render hitch**: render-server CPU or GPU work for effects, blending, masks,
  shadows, blur, drawing, or oversized content misses presentation.

Use the actual begin time, commit deadline, presentation time, and refresh
behavior in the trace. Do not hard-code 16.7 ms; supported devices can use 120
Hz or variable refresh behavior.

Do not use FPS alone. Apple notes that a hitch does not always cause a frame
drop, so late-frame duration and the causal render-loop interval remain the
relevant evidence.

Fix a shared hang cause first when the same long main-thread work can produce
both hangs and hitches.

## Inspect collection-specific work

Set the inspection range to the exact scroll or update interval. Correlate late
frames with:

- cell and supplementary initialization, registration, configuration, and
  `prepareForReuse` frequency;
- provider model lookup, formatting, locks, I/O, decoding, and allocation;
- preferred layout attributes, Auto Layout solving, self-sizing passes,
  estimated-size corrections, and invalidation contexts;
- snapshot creation and apply frequency, item count, reloads, reconfigures, and
  overlapping upstream events;
- image download completion, downsampling, preparation, cache hits and misses;
- view, constraint, gesture, target, subscription, and layer accumulation;
- offscreen rendering, blending, custom drawing, and hosted SwiftUI updates.

Inspect caller paths and self versus descendant cost. A symbol near the top of
Time Profiler is not a root cause without the triggering collection path and a
mechanism that explains the missed deadline.

## Instrument only useful boundaries

Use `OSSignposter` or a points-of-interest log when system tracks do not express
the complete user journey. Give intervals stable, low-cardinality names such as
`FeedInitialApply`, `SearchSnapshot`, or `ImagePrepare`. Balance begin and end
events across success, failure, and cancellation.

Add debug-only counters when they answer a current question:

- configurations per identifier and per visible appearance;
- cell initializations versus dequeues;
- snapshot applications and reconfigured item counts;
- layout invalidations and measured-size cache hits;
- image requests, deduplicated joins, decodes, cache hits, and cancellations.

Remove or disable noisy logging before comparing production-like performance.
Do not turn counters into permanent high-cardinality telemetry without privacy,
retention, and ownership review.

## Compare baseline and candidate

1. Build once per revision when practical.
2. Keep setup outside the interval unless setup is part of the contract.
3. Use the same device, build mode, dataset, cache state, gesture automation,
   network conditioning, and instrument set.
4. Run enough repetitions to expose normal spread and record every valid run.
5. Compare the primary distribution and secondary memory, CPU, energy, network,
   fidelity, and freshness guardrails.
6. Re-run the baseline after the candidate when thermal or environmental drift
   is plausible.

Do not claim success from one favorable run, unmatched conditions, visual
inspection alone, average FPS without late-frame evidence, or an
unsymbolicated trace.

## Add proportionate regression guards

Choose the smallest stable guard:

- unit-test stable identity, snapshot construction, ordering, duplicate
  rejection, generation checks, and cache keys;
- integration-test rapid updates, deletion during loading, stale completion
  rejection, cancellation, and shared-request ownership;
- snapshot or view tests for complete reused state across content variants;
- XCTest clock, signpost, CPU, memory, or UI metrics for a deterministic
  collection journey using APIs supported by the installed SDK;
- `XCTOSSignpostMetric.scrollingAndDecelerationMetric` for a supported iOS 15+
  scroll interaction, or `XCTHitchMetric` for a supported iOS 26+ hitch
  interval; verify exact availability in the active SDK;
- Organizer or MetricKit monitoring for device-, population-, network-, and
  long-lived-state-dependent behavior.

Set performance baselines only after inspecting variability. Scope them by
device class, configuration, dataset, and scenario. Do not measure test setup,
a mocked no-op, or a different user outcome.

## Preserve functional behavior

After a performance correction, verify:

- identifiers, order, selection, focus, accessibility, editing, and reordering;
- cell and supplementary appearance through repeated reuse;
- self-sizing under Dynamic Type, localization, RTL, resizing, and rotation;
- placeholders, errors, retry, pagination, and offline behavior;
- cancellation and task lifetime during rapid scroll and dismissal;
- memory-pressure recovery and cache misses;
- production-configuration build and focused repository tests.

Report a source-proven correction as implemented and functionally validated when
no matched capture ran. Report a measured improvement only for the recorded
scenario, environment, distribution, and guardrails.
