# Data, identity, and collection updates

## Contents

- Choose the collection surface
- Model identity explicitly
- Keep store and snapshot coherent
- Select the narrowest update
- Control update frequency
- Keep provider lookup predictable
- Review legacy batch updates
- Preserve user-visible state

## Choose the collection surface

Choose from product behavior and layout needs, not from a claim that one UIKit
class is universally faster.

- Keep `UITableView` for a straightforward one-dimensional list when its API,
  team knowledge, deployment support, and existing behavior fit.
- Use a collection-view list for mixed section types, compositional layouts,
  hierarchical section snapshots, collection-specific accessories, or a shared
  list/grid architecture.
- Use a grid or compositional layout for visual collections and mixed list,
  grid, and orthogonal sections.
- Do not migrate a stable table to a collection view as a performance fix
  without a supported bottleneck and a behavior-preserving migration plan.

Record the existing selection, focus, swipe, edit, reorder, drag-and-drop,
accessibility, restoration, and scroll-position behavior before migration.

## Model identity explicitly

Diffable data sources store identifiers. Treat identity as a durable domain
fact, not as the complete mutable display model.

- Use stable section and item identifiers whose equality and hash do not change
  while an item participates in a snapshot.
- Keep titles, counts, progress, image state, download state, and other mutable
  presentation fields in a model store keyed by the identifier.
- Do not use an index path, array offset, freshly generated UUID, or mutable
  model hash as durable identity.
- Preserve the same identifier when only content changes. Use a new identifier
  only when product semantics say it is a new item.
- Assert or test uniqueness before applying a snapshot when the upstream model
  can contain duplicates.

Stable identity keeps diff calculation, selection, focus, animation, and
asynchronous results attached to the intended item.

## Keep store and snapshot coherent

Define one owner for the visible model state and its snapshot. Apply updates in
an order that never leaves a visible identifier unresolvable by the provider.

For insertion or content replacement:

1. Publish the new model value to the keyed store.
2. Build or mutate the snapshot from stable identifiers.
3. Apply the snapshot on the collection's isolation domain.

For deletion:

1. Cancel or detach item-scoped consumers.
2. Remove the identifier from the snapshot.
3. Remove the model and cache entry when no other owner requires them.

Keep UIKit data-source access on the main actor. Perform expensive filtering,
sorting, parsing, or grouping away from it only when the input is immutable or
snapshotted and cancellation and ordering remain correct. Return a compact
result, then build and apply the UI state consistently.

## Select the narrowest update

Use lifecycle semantics, not API fashion:

- Apply an ordinary diffable snapshot for structural insertion, deletion,
  movement, or section changes.
- On iOS 15 and later, use `reconfigureItems(_:)` when an existing item keeps its
  identity and cell type and only needs current content configured again. It
  preserves the existing or prefetched cell, reruns the provider without
  `prepareForReuse`, and remeasures self-sizing content.
- Use `reloadItems(_:)` when the provider may return another cell type, the
  replacement-cell lifecycle is intentionally required, or an older deployment
  target needs the fallback. Validate selection, focus, animation, and layout
  behavior.
- Do not pair every reconfiguration with blanket `invalidateLayout()`. Use
  explicit invalidation only when content changes geometry and automatic
  self-sizing does not produce the required result, then keep its scope narrow.
- Reserve `reloadData()` and `applySnapshotUsingReloadData(_:)` for intentional
  full resets, recovery, or initial compatibility paths whose broader work and
  state effects are acceptable.

Before reconfiguring, confirm that the current data source still contains the
identifier:

```swift
@MainActor
func markItemChanged(_ id: Item.ID) {
    guard dataSource.indexPath(for: id) != nil else { return }

    var snapshot = dataSource.snapshot()
    snapshot.reconfigureItems([id])
    dataSource.apply(snapshot, animatingDifferences: true)
}
```

Do not update a captured cell from an asynchronous completion. The same cell
object may represent another identifier when the completion runs.

## Control update frequency

Snapshot calculation and application are work. Preserve freshness without
applying every upstream micro-event individually.

- Coalesce related model mutations into one semantically atomic snapshot when
  intermediate states are not user-visible requirements.
- Cancel superseded filtering, search, or pagination work and reject results
  older than the currently requested generation.
- Serialize snapshot applications through one owner. Do not let independent
  callbacks race to apply snapshots derived from stale bases.
- Avoid rebuilding an unchanged full snapshot merely to refresh one visible
  value; use identifier-based reconfiguration where its semantics fit.
- Measure batching delay, memory, and freshness before increasing a debounce or
  buffer window.

## Keep provider lookup predictable

The cell provider runs on a constrained UI path. Keep its work bounded and
deterministic.

- Resolve an identifier through a keyed store instead of repeatedly scanning a
  large array when source inspection or a trace proves that scan is material.
- Precompute expensive formatting, parsing, grouping, or image work outside the
  provider. Keep state-dependent UIKit configuration in the provider.
- Avoid hidden I/O, database fetches, synchronous locks, and lazy one-time
  initialization in the provider.
- Do not add a duplicate dictionary or cache for a tiny dataset unless its
  ownership and memory cost are justified.

## Review legacy batch updates

For non-diffable data sources, mutate the backing model and view updates as one
consistent transaction. Verify that counts before and after inserts, deletes,
and moves match UIKit's expectations. Do not mix `reloadData()` into an active
batch or apply overlapping batches from independent callbacks.

When invalid-update crashes, ordering races, or state restoration dominate the
cost of maintaining manual batches, consider a scoped diffable migration for
correctness and maintainability. Do not claim that the migration is a measured
performance improvement without matched evidence.

## Preserve user-visible state

After every update-path change, verify:

- selection, multiselection, keyboard and focus-engine focus;
- VoiceOver focus and announcements;
- swipe actions, editing, reordering, drag and drop;
- scroll position during prepends, pagination, and content-size changes;
- empty, loading, partial, error, and retry states;
- state restoration and deep-link positioning;
- rapid search changes, deletion during loading, and stale completion rejection.
