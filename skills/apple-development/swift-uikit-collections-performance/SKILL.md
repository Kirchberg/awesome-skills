---
name: swift-uikit-collections-performance
description: Use when designing, implementing, reviewing, diagnosing, profiling, or regression-testing performance-sensitive UIKit lists and collections built with UITableView or UICollectionView. Apply to diffable data sources, compositional or custom layouts, cell and supplementary registrations, reuse and configuration state, self-sizing, prefetching, asynchronous images, UIHostingConfiguration cells, batch updates, scrolling hitches, main-thread work, and memory-aware caches. Trigger for requests to fix stuttering scroll, stale reused content, expensive cell preparation or layout, snapshot churn, image-decoding hitches, or collection memory growth. Do not use as the lead for an app-wide unknown performance symptom, a pure Swift algorithm hot path, SwiftUI-native lists, or concurrency correctness without a UIKit collection concern.
---

# Build smooth UIKit lists and collections

## Outcome

Turn a UIKit collection task or performance symptom into a correct data,
reuse, layout, and loading pipeline with evidence proportionate to the claim.
Apply safe source-proven corrections immediately when authorized. Measure
unknown causes, runtime tradeoffs, and performance outcomes before claiming an
improvement.

## Read references selectively

- Read `references/methodology.md` before planning, reviewing, diagnosing, or
  changing collection code.
- Read `references/data-and-updates.md` for collection choice, stable identity,
  diffable snapshots, reconfiguration, batching, and model lookup.
- Read `references/cells-and-layout.md` for registrations, reuse, configuration
  state, self-sizing, compositional layout, custom layout, and hosted SwiftUI.
- Read `references/images-and-prefetching.md` for asynchronous media, image
  preparation, prefetching, cancellation, deduplication, and caches.
- Read `references/profiling-and-testing.md` before profiling, benchmarking,
  adding a regression guard, or reporting a performance result.
- Read `references/sources.md` when guidance is disputed, version-sensitive, or
  needs primary-source support.

Repository instructions, deployment targets, supported toolchains, and the
user's explicit scope override generic examples. They never weaken correctness,
accessibility, lifecycle, or evidence gates.

## Route the request

- Lead with this skill when the named surface is a `UITableView`,
  `UICollectionView`, its cells, data source, layout, or loading pipeline.
- Lead with `$app-performance` when the starting symptom is app-wide or the
  responsible subsystem is unknown. Return here after evidence identifies the
  UIKit collection path.
- Use `$swift-ios-performance` for a distinct model transformation, algorithm,
  allocation, or copy hot path after the collection trace identifies it.
- Use `$swift-concurrency` when actor isolation, task ownership, cancellation,
  or data-race safety is a material part of the correction.
- Use `$swiftui-optimization` when `UIHostingConfiguration` content shows broad
  SwiftUI updates, unstable identity, expensive body work, or layout churn.
- Use `$swift-animation` for intentional transitions, interactive motion, or
  animation interruption beyond ordinary scrolling responsiveness.

## Classify the work

Choose one mode and honor its authority:

- **Design**: select an architecture, API surface, performance contract, and
  validation plan; do not edit unless asked.
- **Review**: report prioritized correctness and performance findings; do not
  implement unless asked.
- **Diagnose**: reproduce and support a root cause; do not fix unless the request
  also asks to resolve it.
- **Improve**: implement the smallest coherent in-scope correction and validate
  behavior proportionately.
- **Prevent**: add a stable performance or correctness regression guard around
  an already-defined collection scenario.

Treat requests to build, implement, optimize, improve, fix, or refactor as
Improve authority inside the named scope.

## Establish the collection contract

Record before editing or measuring:

- the exact gesture or update sequence and its start and end;
- device class, OS, Xcode, SDK, deployment target, build configuration, display
  refresh behavior, data volume, cache state, network state, and thermal state;
- collection type, layout, cell and supplementary kinds, update mechanism,
  pagination behavior, and asynchronous dependencies;
- the metric, unit, aggregation, baseline procedure, target, and secondary
  memory, energy, fidelity, or freshness guardrails;
- functional invariants such as item identity, order, selection, focus,
  accessibility, reordering, swipe actions, state restoration, scroll position,
  error states, and cancellation.

Use separate contracts for cold and warm caches, initial load and steady-state
scrolling, or materially different data sizes.

## Trace the complete pipeline

Inspect in this order:

1. Map model ownership and stable item and section identifiers.
2. Follow every snapshot, batch, reload, insert, delete, move, and reconfigure
   into the data source and collection view.
3. Follow identifier lookup through cell or supplementary registration,
   configuration state, sizing, layout attributes, and display.
4. Follow asynchronous data from request creation through deduplication,
   cancellation, preparation, cache insertion, and identifier-based UI update.
5. Follow cells from preparation through possible prefetched waiting, repeated
   display, end display, reuse, and teardown without assuming every phase runs.
6. Locate repeated work, broad invalidation, synchronous I/O, decoding,
   constraint churn, allocation, view-hierarchy mutation, or stale state.

Fix correctness defects before tuning their cost. A fast collection that shows
the wrong item, loses focus, leaks tasks, or breaks selection is not improved.

## Apply hard guardrails

- Keep diffable identifiers stable and independent from mutable display fields.
- Create each cell and supplementary registration once per reusable kind,
  outside provider closures.
- Make every configuration pass idempotent: assign all visible state, reset
  absent state, and avoid accumulating constraints, targets, gestures, layers,
  or subviews.
- Never apply an asynchronous result to a captured cell or persistent index
  path. Resolve the stable item identifier against current state, then request
  a reconfiguration or configure the currently represented item.
- Use `reconfigureItems(_:)` for content changes that can reuse the existing
  cell. Use reload, replacement, or layout invalidation only when their broader
  lifecycle or geometry semantics are required and verified.
- Treat prefetch callbacks as speculative and optional. Keep the normal cell
  path correct when prefetch never occurs, and cancel work that has no remaining
  consumer.
- Perform UI mutation on the main actor, but keep I/O, parsing, image decoding,
  thumbnail preparation, and other substantial non-UI work off the commit path.
- Size image work to rendered pixels, bound prepared-image caches by cost, and
  preserve original compressed assets for disk storage.
- Create constraints and stable subview hierarchies once. Use complete
  self-sizing constraints, realistic estimates, and cache keys that include all
  size-affecting inputs.
- Prefer standard or compositional layouts. Adopt a custom layout only for
  behavior they cannot express, then invalidate and recompute narrowly.
- Do not replace `UITableView` with `UICollectionView`, add caching, disable
  prefetching, flatten views, rasterize layers, or move work across executors as
  a universal performance fix.

## Run the evidence loop

1. Preserve unrelated work and reproduce the smallest representative scenario.
2. Use source and lifecycle evidence for a directly proved unnecessary-work,
   identity, registration, cancellation, or ownership defect.
3. For an unknown stutter, select the exact interval and classify commit versus
   render hitches before ranking symbols.
4. State one falsifiable mechanism linking the collection pipeline to the
   missed contract.
5. In Improve mode, implement one semantically coherent correction while
   preserving the functional invariants.
6. Re-run functional checks and, when the claim depends on runtime behavior,
   compare baseline and candidate under matched conditions.
7. Add a regression guard only when the scenario and metric are stable enough
   to survive device, OS, data, and toolchain changes.

## Verify and report

Run repository formatting, static analysis, focused tests, and a production-like
build for changed targets. Exercise rapid direction changes, item mutation and
deletion during loading, cache misses, Dynamic Type, rotation or resizing, and
memory pressure when they intersect the change.

Report the mode, scope, contract, supported cause, changed files, functional
checks, and unresolved risks. For measured work, also report the device and
build, trace and selected interval, baseline and candidate distributions,
variability, and secondary resource effects. For an unmeasured source-proven
correction, say that implementation is validated but app-level performance is
not measured. Never call a visually smoother Simulator run a verified device
performance improvement.
