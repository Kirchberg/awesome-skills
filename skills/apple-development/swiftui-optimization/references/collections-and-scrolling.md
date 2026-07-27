# Collections, lazy containers, and scrolling

## Contents

- Choose the container from semantics and evidence
- Keep identity and row cardinality stable
- Work with lazy lifetime and prefetching
- Keep scrolling geometry predictable
- Use type erasure deliberately
- Bound high-frequency presentation updates
- Verify the representative workload

## Choose the container from semantics and evidence

Start with the behavior the product needs:

- Prefer `List` or `Table` when their selection, editing, accessibility,
  keyboard, focus, and platform conventions fit.
- Prefer a lazy stack or grid in a `ScrollView` when the screen needs custom
  layout or scrolling behavior that those containers express directly.
- Keep a plain stack for small, bounded content when lazy bookkeeping has no
  demonstrated benefit.

Do not rely on claims that `List` uses a particular platform implementation,
that it always reuses rows, or that a lazy stack always retains them. Those
details and trade-offs have changed across OS releases. Compare the candidate
containers with the same row content, data, device, OS, build configuration,
scroll path, and memory checkpoints.

## Keep identity and row cardinality stable

Give each semantic element one unique, stable, cheap domain identifier. Do not
derive identity from a fresh `UUID()`, a mutable position, or a value that can
collide. Keep that identity stable across filtering, pagination, reordering,
and refreshes.

Prepare filtering, sorting, grouping, and pagination at the data layer. On a
performance-sensitive lazy path, make each `ForEach` element resolve to a
constant number of top-level subviews, ideally one:

```swift
let visibleItems: [Item]

LazyVStack {
    ForEach(visibleItems) { item in
        ItemRow(item: item)
    }
}
```

Avoid using an `if`, optional unwrap, or type erasure inside every row to turn
one data element into zero or a variable number of top-level subviews. SwiftUI
may need to visit more content to determine indices, identifiers, or scroll
targets. Move the condition above the collection or filter the data first.

Use a `RandomAccessCollection` or a prepared array when the container needs
fast counting and indexing. Avoid repeated `Array(...)` conversion in `body`.
Add a row-level `.id` only for a concrete identity or scrolling requirement;
an unnecessary `.id` can reset lifetime and has inhibited lazy behavior in
some framework versions.

## Work with lazy lifetime and prefetching

Treat laziness as deferred view work, not as a cache or persistence policy.
Current lazy stacks can:

- estimate off-screen sizes and refine those estimates while scrolling;
- evaluate and lay out a row during prefetch before `onAppear`;
- retain an off-screen row for some updates;
- later discard that row and its identity-scoped local state.

Do not keep durable selection, download progress, editing state, or other
product data only in a row when it must survive scrolling away. Put it in a
model or outer owner and pass a value or binding to the row.

Give a prefetched row a meaningful, layout-stable initial representation.
Do not postpone all row setup to `onAppear` and then replace its size or
structure. Use `onAppear`, `.task`, and `.task(id:)` for repeatable,
idempotent, cancellable effects, not as proof that `body` was evaluated or
that the row will remain alive.

Do not manually unload every row resource in `onDisappear` without evidence.
Appearance callbacks can repeat, and a resource cache may correctly outlive a
row. Put eviction and cancellation policy in the resource owner.

## Keep scrolling geometry predictable

A lazy stack estimates content outside its loaded region, so absolute content
size and offset can change as the stack learns actual row sizes. Prefer
relative visibility or scroll-target APIs when the supported OS provides them.
Gate newer APIs by deployment availability.

For programmatic scrolling:

- use stable target identifiers;
- keep one predictable top-level subview per element;
- make collection counting and indexing cheap;
- avoid changing row height after placement;
- avoid geometry callbacks that write state and trigger another layout pass.

When rows legitimately have dynamic height, provide stable placeholders or use
layout primitives and a custom `Layout` rather than measuring a child and
feeding the result back into its own frame. Reproduce rotation, Dynamic Type,
content insertion, and animated scrolling on every supported OS.

## Use type erasure deliberately

`AnyView` is a valid type-erasure tool. Its public lifetime rule is that when
the wrapped view type changes, SwiftUI destroys the old hierarchy and creates
a new one.

Avoid blanket bans. A coarse `AnyView` around a small, stable region can be
irrelevant, while per-row type erasure in a very large or frequently changing
collection can hide structural information and force substantially more work.
Prefer a generic `Content`, an enum with a `@ViewBuilder` switch, or concrete
row types when they keep the model clear. Profile before and after when type
erasure remains the simplest design.

`Group` and a `@ViewBuilder` helper can preserve concrete types, but neither
creates an independent update boundary. Extract a real child `View` when the
goal is dependency isolation.

## Bound high-frequency presentation updates

Do not make the UI publish at the transport or sensor event rate by default.
Define the required presentation latency and whether intermediate events may
be coalesced or dropped.

For a feed that can present the latest state:

1. Parse, aggregate, and build a render snapshot away from the main actor.
2. Use bounded buffering and prefer the latest snapshot when stale snapshots
   have no user value.
3. Publish to the main actor at a measured cadence the device can sustain.
4. Keep stable element identity across snapshots.
5. Apply backpressure or reduce cadence when the consumer falls behind.

When every event matters, retain the complete event log outside the view and
publish batches or derived snapshots; do not silently drop domain data.
Observation, Combine, and `AsyncSequence` do not choose the product's rate
policy automatically.

Before adding throttling, confirm that the cost is actually UI publication.
JSON decoding, collection copying, sorting, logging, or main-actor work can
dominate even when the visible view is small.

## Verify the representative workload

Capture at least:

- initial construction and first meaningful content;
- steady scrolling in both directions;
- pagination or high-frequency insertion;
- programmatic scrolling to a distant target;
- rotation, resizing, or Dynamic Type when supported;
- a return pass after all rows have been visited;
- memory after a defined quiescent checkpoint.

Compare update counts and durations, hitches, peak and post-interaction memory,
correct state restoration, request cancellation, accessibility, and scroll
position. Do not choose a container from one synthetic benchmark or an average
FPS number without hitch and workload context.
