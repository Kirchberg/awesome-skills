# Images, asynchronous content, and prefetching

## Contents

- Separate the two prefetch mechanisms
- Design a fallback-first loader
- Bind results to stable identity
- Build an image pipeline for rendered output
- Deduplicate work and model cancellation
- Bound caches and respond to pressure
- Keep pagination independent
- Validate hostile lifecycle cases

## Separate the two prefetch mechanisms

UIKit collection performance involves two related mechanisms:

- UIKit can prepare upcoming cells during spare commit time. Modern cell
  prefetching changes lifecycle timing but does not move arbitrary app work to a
  background executor.
- `UICollectionViewDataSourcePrefetching` and
  `UITableViewDataSourcePrefetching` notify the app that data may soon be needed.
  Use them to initiate asynchronous, cancellable data or media preparation.

Treat both as opportunities, never guarantees. A data-source prefetch callback
is not necessarily delivered for every item, and a prepared cell may never
display. The ordinary provider path must handle data that is ready, in flight,
or not requested.

`isPrefetchingEnabled` controls both cell and data prefetching for a collection
view and defaults to enabled. Do not disable it as a generic workaround; first
fix lifecycle assumptions and validate the intended SDK behavior. If disabling
is required for correctness or a supported tradeoff, measure its scrolling,
latency, memory, network, and energy effects.

Prefetch callbacks are UIKit callbacks on the main actor. Resolve current index
paths to stable identifiers there, then initiate non-UI work without doing the
download, parsing, decoding, or database read synchronously in the callback.

## Design a fallback-first loader

Give visible configuration a single request API whose semantics do not depend
on prefetch:

1. Return a prepared cached value immediately when present.
2. Join a compatible in-flight request when one exists.
3. Otherwise start the request and return a cheap placeholder state.
4. Publish completion by stable identifier and content revision.
5. Reconfigure the current item if it still exists and still needs that result.

Let prefetch call the same request API earlier. Do not create a separate
prefetch-only cache or state machine that can disagree with visible loading.

Map index paths to identifiers when the callback arrives:

```swift
@MainActor
func collectionView(
    _ collectionView: UICollectionView,
    prefetchItemsAt indexPaths: [IndexPath]
) {
    for id in indexPaths.compactMap({ dataSource.itemIdentifier(for: $0) }) {
        prefetchConsumers[id] = imagePipeline.prefetch(id: id)
    }
}
```

Use a token or consumer handle whose cancellation detaches that consumer. Do
not retain the index path as the request's durable identity.

## Bind results to stable identity

Never update a cell object captured before suspension or a network callback.
Before publishing a result, check:

- the request generation or content revision is still current;
- the item still exists in the model and data source;
- the asset key and requested representation still match;
- the item has not been deleted, replaced, or moved to a state that rejects the
  result.

Store the result in the model or cache, then reconfigure by identifier. If a
component instead updates a currently visible cell directly, verify its
`representedID` immediately before the mutation and still keep the model as the
source of truth.

Use `prepareForReuse` to reset the placeholder, detach observation, stop
cell-local animation, and release that cell's consumer token. Do not cancel a
shared underlying request while another visible or prefetched consumer needs it.

## Build an image pipeline for rendered output

Keep the stages explicit:

```text
request -> compressed bytes or original asset -> downsample/thumbnail
        -> prepare decoded display image -> memory cache -> main-actor publish
```

- Request an appropriately sized server or local representation when possible.
- Downsample or prepare a thumbnail for the rendered dimensions and display
  scale instead of decoding a full-resolution source for a small cell.
- Use synchronous `preparingForDisplay()` only away from the main thread. When
  preparing many images synchronously, prefer bounded serial preparation over
  unbounded concurrent decoding that spikes memory and contention.
- Use asynchronous `prepareForDisplay(completionHandler:)` on supported OS
  versions when its internal preparation queue fits the pipeline. It returns an
  optional image and no cancellation token, so keep a fallback and cancel only
  the surrounding work that actually supports cancellation.
- Use thumbnail preparation when the source is materially larger than the
  rendered result so the pipeline avoids decoding the full-size representation.
- Assign only the prepared result and UI state on the main actor.
- Keep a cheap placeholder available synchronously.
- Preserve the compressed original or an appropriate encoded derivative for
  disk storage. Prepared bitmap-backed images are memory representations, not a
  disk-cache format.

Account for orientation, color space, animated images, wide-gamut content,
display scale, and trait-dependent asset variants when choosing a decoder or
cache key. Prepare a new representation when a relevant trait change selects a
different asset. Do not silently reduce fidelity to claim better scrolling.

## Deduplicate work and model cancellation

Key compatible requests by stable asset identity plus every representation
input, such as target size, scale, content mode or crop policy, and revision.

- Coalesce duplicate consumers onto one underlying download and preparation.
- Track consumer ownership separately from underlying work.
- Cancel speculative work when all consumers leave and cancellation saves
  meaningful resources.
- Allow a visible consumer to raise priority without starting a duplicate
  request when the implementation supports it safely.
- Reject late completions from canceled or superseded generations.
- Bound parallel downloads, decodes, and preparations; unbounded fan-out can
  trade scroll latency for memory pressure, contention, and energy.

Use `$swift-concurrency` when task groups, actor ownership, priority,
continuations, or cancellation correctness materially changes.

## Bound caches and respond to pressure

Prepared images can consume far more memory than their compressed assets.

- Assign cache cost from the decoded representation or a conservative measured
  estimate, not compressed byte count.
- Set a policy for total cost and item count that reflects the scenario and
  device population; do not invent one universal limit.
- Avoid retaining both full-resolution and thumbnail decoded variants without a
  product need.
- Purge or reduce optional prepared content on memory-pressure signals while
  preserving visible correctness.
- Measure hit rate, peak memory, churn, decode count, and placeholder duration
  before enlarging the cache.

Treat `NSCache` eviction as nondeterministic. The visible path must recover from
every miss.

## Keep pagination independent

Do not use cell prefetch or data prefetch as the only pagination trigger. Define
an idempotent page-loading owner with its own cursor, in-flight state,
deduplication, retry, cancellation, and end-of-data semantics.

Prefetch can hint that the threshold is near, but visible scrolling, restoration,
programmatic jumps, accessibility navigation, and small datasets must still
load correctly. Apply the resulting items through the same serialized snapshot
owner used by other updates.

## Validate hostile lifecycle cases

Exercise:

- rapid reversals before prefetched cells display;
- fast scroll through repeated cache misses;
- deletion, replacement, and snapshot reorder while requests are in flight;
- the same asset in multiple visible cells or sizes;
- cancellation followed immediately by a new consumer;
- offline, corrupt, missing, and retrying assets;
- Dynamic Type, rotation, split-screen resizing, and scale changes;
- memory pressure and background or foreground transitions.

Verify correct content first, then compare hitch, memory, network, energy, and
placeholder metrics under the performance contract.
