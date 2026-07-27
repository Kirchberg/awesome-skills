# Memory and resource lifetime

## Contents

- Classify the memory symptom
- Capture a repeatable lifecycle
- Choose evidence for the question
- Prove ownership and cancellation
- Bound image and cache memory
- Control persistence-backed screens
- Verify the correction

## Classify the memory symptom

Do not call every high-water mark a leak. Separate:

- **Transient growth**: temporary allocations create an excessive peak and are
  later released.
- **Persistent growth**: live allocations increase across repeated work.
- **Abandoned reachable memory**: an owner or cache can still reach data that
  the product will not use again.
- **Leak**: memory is unreachable or trapped in a reference cycle and cannot be
  reclaimed.
- **Bounded cache or allocator behavior**: process footprint remains above its
  starting value while live objects and resource policy reach a stable bound.

The process footprint, resident memory, heap live bytes, decoded graphics
memory, and count of a model type answer different questions. A process not
returning immediately to its launch footprint after `value = nil` does not
prove that the value is still alive.

## Capture a repeatable lifecycle

Define one scenario with explicit checkpoints, for example:

1. cold launch and settle;
2. open the feature;
3. load and scroll representative data;
4. dismiss or navigate away;
5. wait for documented cancellation and cleanup;
6. repeat the same cycle several times.

Record device, OS, Xcode, configuration, data volume, cache/network state, and
checkpoint timing. Use a physical device for representative footprint and
termination risk. Use a diagnostic build when Memory Graph type information,
malloc stack logging, or another debugging option requires it, then confirm
the user-facing workload with the optimized configuration.

Track both peak and post-cycle behavior. A healthy cache may warm up and
plateau above the first cycle; unbounded growth usually continues as the same
interaction repeats.

## Choose evidence for the question

Use the narrowest tool that answers the current question:

- Use Xcode's memory report for a coarse footprint timeline and checkpoint
  signal.
- Use Allocations and generations to identify which allocation types survive
  a repeated interval and where they were created.
- Use the Memory Graph Debugger to ask why a specific model, coordinator,
  closure context, subscription, or resource is still reachable.
- Use Leaks to investigate detected leaks, while remembering that reachable
  abandoned memory and unbounded caches are not necessarily reported as leaks.
- Use VM Tracker or virtual-memory evidence when heap allocations do not
  explain footprint growth.
- Enable malloc stack logging for a reproducible investigation when allocation
  and retention backtraces justify its overhead.

Start from application-owned types or a resource category that grows with the
scenario. Follow the full retaining path to an expected root. Do not optimize a
large system allocation until the trace connects it to data or behavior the app
controls.

## Prove ownership and cancellation

Write down the intended owner and terminal event for each long-lived resource:

- an `@Observable` or `ObservableObject` model;
- a coordinator, service, or persistence context;
- a timer, notification, Combine subscription, or async sequence;
- an unstructured task or continuation;
- a decoded image, renderer, cache entry, or in-flight request.

Align model ownership with view identity. Use `@State` for an owned
`@Observable` model on supported toolchains and `@StateObject` for an owned
legacy `ObservableObject`; borrow an already stable model in descendants.
Changing a view's identity intentionally ends identity-scoped state.

Prefer structured work tied to a clear owner or `.task` lifetime. Make
cancellation cooperative, cancel stored task handles and subscriptions at the
owner's terminal event, and prevent superseded work from publishing stale
results. An infinite or suspended task can retain its captures for as long as
it remains active.

Inspect the entire closure chain. A `[weak self]` inside an inner `Task` does
not weaken an outer escaping closure that already captured the owner strongly.
Apply `weak` or `unowned` only to the edge that should be non-owning, and choose
between them from the real lifetime contract. Do not add `weak self`
mechanically to normal SwiftUI action closures.

Confirm expected `deinit` events or disappearance of instances in a fresh
memory graph. `onDisappear` is not a universal destructor: it can repeat, and
containers may retain or later recreate identity-scoped state.

## Bound image and cache memory

Estimate decoded image cost from pixel dimensions and pixel format, not the
compressed file size. Scaling an already decoded image in layout does not
recover the full-size backing memory:

- `resizable()` and `scaledToFit()` change presentation, not decode size;
- downsample a source to the required pixel dimensions before or while
  decoding, using current Image I/O or platform thumbnail APIs;
- request thumbnail-sized server assets when possible;
- keep full-resolution data out of collection row render state.

Define an explicit resource policy:

- use stable cache keys;
- bound count and total cost;
- deduplicate in-flight work;
- cancel requests whose result is no longer useful;
- decide whether memory, disk, HTTP, and decoded-image caches are separate;
- respond to memory pressure according to the cache contract;
- measure the CPU and I/O cost of eviction and re-decoding.

`AsyncImage` behavior and HTTP caching support vary by SDK and OS generation.
Even when standard HTTP caching is available, it does not define every
product's retry, prefetch, downsampling, decoded-image, or eviction policy.

Do not clear every cache merely because the process footprint is high. First
show that the cache owns meaningful live bytes, does not reach its intended
bound, or creates unacceptable pressure.

## Control persistence-backed screens

A lazy UI container does not guarantee a lazy or bounded data layer. A screen
can still materialize too many records, relationships, binary values, or
decoded images.

For Core Data, SwiftData, or another store:

- push filtering and sorting into the supported query mechanism;
- fetch or page the amount the interaction needs;
- keep large binary content out of lightweight row models;
- use thumbnails or object identifiers instead of full payloads in list state;
- measure batch, faulting, and relationship-prefetch choices because they trade
  I/O, latency, object count, and memory;
- avoid copying the entire result set into new value arrays during every
  `body` evaluation.

Do not encode a Core Data row-cache observation, a SwiftData release pattern,
or an `onDisappear` faulting trick as a framework guarantee. Reproduce the
target store, schema, OS, and navigation lifetime, then inspect live managed
objects and allocations.

## Verify the correction

Repeat the same lifecycle and report:

- peak footprint and post-cycle footprint across multiple cycles;
- live bytes or surviving allocation counts for the affected types;
- the retaining path before the fix and its absence or intended bound after;
- expected model, coordinator, subscription, task, and closure lifetimes;
- cache entry count and cost at the bound;
- image dimensions and decoded-resource effect when relevant;
- CPU, I/O, scrolling, cancellation, and correctness regressions.

Reject a correction that only hides the symptom, drops required state, reloads
resources excessively, or moves growth into an unmeasured cache. A lower final
process footprint is useful evidence, but it is not a substitute for proving
the ownership or resource-policy change that caused it.
