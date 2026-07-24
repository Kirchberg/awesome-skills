# SwiftUI construction patterns

## Contents

- Keep initialization and body work cheap
- Scope event and observation sources
- Build scalable collections
- Control layout dependencies
- Scope animation work
- Handle images explicitly
- Keep version-specific workarounds quarantined

## Keep initialization and body work cheap

Keep `View.init` and `body` limited to inexpensive value construction. Move out:

- synchronous network or disk I/O;
- image decoding and resizing;
- large filtering, sorting, grouping, or aggregation;
- repeated formatter construction or expensive string generation;
- bundle searches and repeated reference allocations;
- business rules and persistence mutations.

Prepare derived state in a model or service. Recompute it when relevant inputs
change, cache it with an explicit invalidation key, and publish only the value
the UI needs. Making a function `async` does not move CPU work off the main
actor by itself.

Treat `onAppear`, `.task`, gesture callbacks, geometry callbacks, and other
event closures as repeatable. Make loads idempotent, coalesce duplicate
requests, and honor cancellation.

Use `.task(id:)` when the input defines the work identity:

```swift
.task(id: productID) {
    await model.loadProduct(id: productID)
}
```

Ensure `loadProduct` checks cancellation and does not publish a stale result for
an old ID.

## Scope event and observation sources

Place timers, notifications, scroll geometry, focus, scene values, and
high-frequency observable data in the smallest child that uses them. Remove
unused dynamic-property declarations; legacy environment or observable objects
can invalidate a view even when the displayed content is unrelated.

Do not store an escaping closure that builds static child content when the
content can be produced once in the container initializer and stored as a
generic `Content`. This rule does not ban action closures or parameterized
collection closures.

## Build scalable collections

- Prefer `List` when its interaction, reuse, accessibility, and platform
  behavior match the product.
- Use lazy stacks or grids when off-screen construction is a measured problem
  and their layout semantics fit.
- Supply a `RandomAccessCollection` or a precomputed array for large data when
  repeated conversion or traversal is measurable.
- Precompute filtered and sorted collections outside the hot `body` path.
- Keep identifiers cheap; `List` and `Table` collect row identities eagerly
  even though row content is generally built lazily.
- Keep a constant number of top-level rows per `ForEach` element on a
  performance-sensitive lazy path.

Prefer:

```swift
let visibleItems: [Item]

List(visibleItems) { item in
    ItemRow(item: item)
}
```

over filtering with a conditional inside `ForEach`. When a condition must stay
inside an element, a stable outer row container can preserve one row per
element; verify the semantics and profile the supported OS versions.

Avoid redundant `.id` modifiers on large list rows. They can reset lifetime and
have inhibited lazy behavior in observed framework versions. Add one only for a
specific identity or scrolling requirement and profile that configuration.

Do not treat a lazy container as a memory-eviction guarantee. Off-screen state
or decoded resources may remain alive.

## Control layout dependencies

`GeometryReader`, `ScrollViewReader`, custom `Layout`, and geometry callbacks
are tools, not automatic defects. Problems arise when a broad subtree observes
layout or when geometry writes state that triggers another layout.

- Isolate the reader around the smallest affected subtree.
- Transform raw geometry into a small `Equatable` value.
- Update state only for a meaningful change or threshold.
- Keep unrelated state outside the layout-dependent subtree.
- Use a minimal reproduction and the proposal → required size → placement
  model before adding workaround frames.

Apply `geometryGroup()` or a custom layout only for a demonstrated geometry or
animation continuity problem, not as a generic optimization modifier.

## Scope animation work

- Preserve identity for elements that should animate continuously.
- Use `.animation(_:value:)` or a scoped animation declaration near the
  changing presentation.
- Use `withAnimation` when several state changes intentionally share one
  transaction.
- Avoid broad implicit animations that cause unrelated layout or drawing work.
- Keep `Animatable` calculations cheap because interpolation runs repeatedly.
- Diagnose animation smoothness with hitch evidence, not `body` counts.

If the app commits on time but the render server misses presentation, inspect
visual complexity, overdraw, blending, masks, shadows, filters, and image size
as hypotheses. Confirm them with rendering tools before simplifying visuals.

## Handle images explicitly

`resizable()` changes layout behavior; it does not reduce the decoded backing
image. `AsyncImage` loads an image but does not define every product's cache,
retry, prefetch, or downsampling policy.

For image-heavy screens:

- request an appropriately sized source when possible;
- downsample before creating the full display image;
- define memory and disk cache limits;
- cancel off-screen requests and deduplicate in-flight work;
- measure decoding, memory pressure, scrolling, and network behavior together.

## Keep version-specific workarounds quarantined

Do not generalize a workaround involving `.equatable()` around
`NavigationLink`, artificial `.id` changes, delayed dispatch, empty
`onChange`, custom navigation-controller delegates, or layout wrappers.

Before adopting one:

1. reproduce the exact symptom;
2. record the OS, SDK, device, and container;
3. create a minimal example;
4. verify the workaround and its correctness;
5. retest when the deployment or SDK matrix changes;
6. remove it when the underlying framework issue is fixed.
