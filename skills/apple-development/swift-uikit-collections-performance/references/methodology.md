# UIKit collection performance methodology

## Contents

- Scope and authority
- Evidence levels
- Performance contract
- Pipeline map
- Diagnosis order
- Change and comparison rules
- Completion record

## Scope and authority

Treat collection performance as a property of a user journey, dataset, device,
build, layout, and resource state. Do not describe a view class or API as fast
or slow in isolation.

Classify the request before acting:

- Design and Review authorize analysis, not source edits.
- Diagnose authorizes reproduction and measurement, not remediation by itself.
- Improve authorizes safe changes inside the named collection surface and the
  validation needed to support them.
- Prevent authorizes the smallest stable test or monitoring surface that guards
  the agreed behavior.

Do not broaden a single feed, picker, grid, or settings list into a whole-app
optimization campaign.

## Evidence levels

Separate evidence that justifies a correction from evidence that supports a
performance claim.

Use direct source and lifecycle evidence when it proves:

- a registration is recreated inside a provider;
- mutable display data participates in diffable identity;
- asynchronous work writes into a reused cell;
- a configuration pass accumulates views, constraints, handlers, or layers;
- prefetch work has no cancellation or fallback path;
- synchronous I/O or decoding runs in cell preparation or layout;
- the same snapshot, formatting, or model scan repeats unnecessarily.

Apply a private, semantics-preserving correction to such a defect in Improve
mode and run functional checks. Runtime measurement is not a permission gate
for a correction whose mechanism is already proved.

Require matched runtime evidence before attributing an unknown hitch, choosing a
material memory/fidelity/freshness tradeoff, changing a public API or executor,
or claiming an end-to-end improvement.

## Performance contract

Define one repeatable scenario. Record:

- entry state, dataset size and distribution, visible cell kinds, image sizes,
  pagination state, cache state, and network conditions;
- the exact interaction, such as a five-second fling through an image grid or
  applying 500 streamed updates while scrolling;
- start and stop boundaries and any points-of-interest interval;
- physical device, OS, Xcode, SDK, revision, scheme, optimization level,
  refresh behavior, power mode, and thermal state;
- primary metric and aggregation, such as hitch rate, late frames, selected
  interval wall time, main-thread active time, peak memory, or allocations;
- secondary constraints for correctness, memory, energy, image fidelity,
  freshness, and network volume;
- baseline procedure, repetition count, comparison rule, and completion gate.

Keep Debug, Simulator, and physical-device results in separate series. Use
Simulator traces to form hypotheses, not to prove device scrolling outcomes.

## Pipeline map

Build a compact map before recommending changes:

```text
model/store -> stable IDs -> snapshot or batch -> data source
            -> registration -> configuration -> sizing/layout -> display
async loader -> decode/prepare -> cache -> ID-based refresh -> cancellation
```

For each arrow, identify the owning object, actor or queue, lifetime, lookup
cost, invalidation trigger, and failure behavior. Include supplementary views,
decoration views, and nested or orthogonal sections when present.

Do not use an index path as durable identity. It describes the current
presentation position and can change whenever a snapshot is applied.

## Diagnosis order

Inspect cost in this order:

1. Correct identity, lifecycle, cancellation, and state-reset defects.
2. Remove unnecessary reloads, snapshots, configuration, layout, decoding, and
   hierarchy mutation.
3. Reduce update frequency, invalidation breadth, data volume, and repeated
   model lookup.
4. Use the UIKit API whose lifecycle matches the operation, such as
   reconfiguration, diffable updates, content configuration, or image
   preparation.
5. Move eligible non-UI work away from the main-thread commit path while
   preserving ordering, priority, ownership, cancellation, and error handling.
6. Optimize algorithms, allocations, ARC, or rendering only after a trace or
   source proof shows they remain material.

Fix hangs before isolated hitches when the same long main-thread work can cause
both. Separate commit hitches from render hitches before editing app code.

## Change and comparison rules

- Change one causal mechanism at a time, or describe a multi-file correction as
  one coherent lifecycle mechanism.
- Preserve item order, selection, focus, accessibility, reuse behavior,
  animation semantics, scroll position, pagination, errors, and restoration.
- Keep setup outside the measured interval unless setup is part of the journey.
- Re-run baseline and candidate with matched builds, data, device, state, and
  instrument set. Record all valid repetitions and rejection rules.
- Do not cherry-pick the best runs or compare Debug against Release.
- Measure memory and freshness when adding caching or prefetching. Measure
  scheduling and copying when moving work to another executor.
- Re-run functional tests because faster incorrect work is a regression.

## Completion record

Report:

1. mode and scope;
2. scenario, environment, metric, and target;
3. reproduction status and baseline distribution when collected;
4. selected trace interval and supported root-cause chain, or direct source
   proof;
5. implemented mechanism and preserved invariants;
6. candidate distribution and secondary guardrails when measured;
7. functional tests, build, and regression protection;
8. tool or device limitations, unresolved hypotheses, and remaining tradeoffs.

Use “implemented from source evidence; app-level performance not measured” when
that is the evidence boundary. Reserve “fixed” for the original contract after
the relevant validation succeeds.
