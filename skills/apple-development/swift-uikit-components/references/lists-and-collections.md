# Lists and collections

## Choose from behavior

Keep an existing `UITableView` when it already expresses the required linear
list, migration has no user or engineering benefit, or the deployment and code
constraints favor it. Prefer `UICollectionView` when the screen needs multiple
layout families, compositional sections, grid or orthogonal content, modern list
features, or one adaptable collection model. Do not make framework novelty the
decision criterion.

Use standard or compositional layout before a custom collection layout. Use
`UICollectionLayoutListConfiguration` for table-like collection sections when
its appearance and behavior fit. Build custom layout only for geometry or
interaction the standard layouts cannot express.

## Model identity and updates

Use stable, unique section and item identifiers independent of mutable display
fields. Make snapshots describe intended ordering and membership. Apply them
from one serialized UI owner and reconcile asynchronous results against current
state.

Prefer diffable data sources for new collection code when their identity and
snapshot model fits. Do not layer manual inserts, deletes, moves, or reloads over
the same update without an explicit coordination boundary. Use
`reconfigureItems(_:)` for content-only changes when keeping the existing cell
lifecycle and geometry is correct; use reload, replacement, or layout
invalidation when their broader semantics are required.

For legacy data sources, preserve valid index paths and batch-update invariants.
Do not migrate only to hide an unproven consistency bug.

## Configure reusable content completely

Create cell and supplementary registrations once for each reusable kind, not
inside provider callbacks. In every configuration pass, set all visible state
and reset absent state. Avoid accumulating constraints, targets, gestures,
subviews, layers, hosted controllers, or observations.

Use `UIContentConfiguration`, `UIBackgroundConfiguration`, list configurations,
and cell configuration state where they fit. Keep model lookup by stable item
identifier rather than by a captured index path.

For self-sizing, constrain the content hierarchy completely and use estimates
that are representative enough to avoid large scroll corrections. Cache sizes
only with keys that include every size-affecting input, including width, content,
traits, and typography.

## Bound asynchronous media and prefetching

Treat prefetch callbacks as optional speculation. Keep the normal cell path
correct when prefetch never happens, deduplicate shared requests, track consumers,
and cancel work only when no consumer remains.

Never apply a result directly to a captured cell or persistent index path.
Resolve the represented stable identifier in current data, then reconfigure the
current item or update a cell only after confirming its identity.

Move I/O, parsing, and image decode or preparation off the main actor. Size image
work for rendered pixels, preserve compressed originals for storage, and bound
memory caches by cost. Respond to memory pressure according to project policy.

## Verify behavior before performance

Exercise insertion, deletion, moves, reordering, rapid scrolling, direction
changes, selection, focus, swipe actions, context menus, pagination, restoration,
empty and error states, Dynamic Type, rotation, and cancellation during reuse.

Use `$app-performance` when smoothness, hangs, CPU, memory, or power is the goal.
Measure representative Release builds and selected trace intervals before
claiming an improvement; Simulator appearance or average FPS is insufficient.
