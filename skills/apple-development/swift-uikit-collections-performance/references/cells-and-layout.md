# Cells, reuse, sizing, and layout

## Contents

- Respect the cell lifecycle
- Keep registrations stable
- Make configuration idempotent
- Separate setup, content, and state
- Build self-sizing cells deliberately
- Cache sizes with complete keys
- Choose and invalidate layouts narrowly
- Control rendering and hosted SwiftUI cost
- Review supplementary and decoration views

## Respect the cell lifecycle

Reason about preparation and display as separate phases. With modern cell
prefetching, a prepared cell may wait offscreen, may never display, or may
display more than once for the same index path before returning to the reuse
pool.

- Complete data-independent setup and current-item configuration before the cell
  is needed onscreen.
- Do not defer heavy required work to `willDisplay`; that moves work onto the
  frame that needs the cell.
- Do not assume `didEndDisplaying` immediately precedes `prepareForReuse`.
- Do not require either display callback for correctness or request cleanup.
- Treat `prepareForReuse` as a reset and consumer-detachment hook, not as the
  only defense against stale state.

Keep correctness in every configuration pass by associating visible content
with the stable represented item identifier.

## Keep registrations stable

Create each `UICollectionView.CellRegistration` and
`SupplementaryRegistration` once for each reusable kind. Store it on the owning
controller, adapter, or component and reuse it from provider closures.

Never construct a cell registration inside a diffable cell-provider closure.
UIKit maintains reuse per registration instance; recreating registrations
prevents reuse and raises an exception on iOS 15 and later.

```swift
private lazy var cardRegistration =
    UICollectionView.CellRegistration<CardCell, Card.ID> {
        [weak self] cell, _, id in
        guard let model = self?.store[id] else {
            cell.showUnavailableState()
            return
        }
        cell.configure(with: model, representedID: id)
    }
```

Capture owners according to their intended lifetime. Do not mechanically use a
weak capture if losing the owner would leave a stale configured cell.

## Make configuration idempotent

Assume any cell object previously represented unrelated content. Every pass
must assign the complete visible state:

- text, attributed text, images or placeholders, colors, alpha, and visibility;
- selected, highlighted, disabled, editing, expanded, and loading appearance;
- accessories, backgrounds, menus, swipe-related state, and accessibility;
- represented identifier and asynchronous consumer token;
- content mode, transforms, corner or shadow state, and reused animation state.

Reset optional state explicitly. Avoid `if value != nil { set }` code that
leaves an earlier value behind when the new value is absent.

Do not append gesture recognizers, targets, constraints, subviews, arranged
subviews, layers, or subscriptions on every configuration. Install stable
structure once, then change values.

## Separate setup, content, and state

Use initialization for stable hierarchy and constraints. Use a content model or
`UIContentConfiguration` for item data. Use `updateConfiguration(using:)` and
configuration state for selection, highlighting, focus, disabled state, and
other transient UIKit state.

Prefer value-style content and background configurations when they express the
component. For a custom `UIContentView`, make assigning the same configuration
safe and avoid rebuilding its hierarchy.

If state changes need a refresh, call `setNeedsUpdateConfiguration()` rather
than mutating several unrelated visual properties from multiple callbacks.

## Build self-sizing cells deliberately

Self-sizing is correct when constraints and content determine an unambiguous
size for the current width and traits.

- Create and activate stable constraints once.
- Constrain the full vertical and horizontal content chain with intentional
  hugging and compression priorities.
- Set accurate maximum widths for multiline text before measuring when the
  layout requires it.
- In flow layout, use a nonzero `estimatedItemSize` or `.automaticSize` only for
  genuinely self-sized items; use `itemSize` when every item has the same known
  size.
- In compositional layout, use `.estimated` on the unknown axis and ensure item,
  group, and container dimensions do not impose an absolute size that prevents
  the content from growing.
- Let the default `preferredLayoutAttributesFitting(_:)` participate. If an
  override still needs its behavior, call `super` and alter only the justified
  dimensions.
- Choose representative estimates to reduce content-size correction.
- Avoid calling layout recursively, repeatedly remaking constraints, or
  invalidating the whole collection from `layoutSubviews`.
- On iOS 16 and later, account for the enabled-by-default
  `selfSizingInvalidation` policy. `.enabled` responds to intrinsic-size
  invalidation, while `.enabledIncludingConstraints` also tracks relevant Auto
  Layout changes in the cell's `contentView`. Select a supported mode whose
  behavior matches the content changes.

`reconfigureItems(_:)` remeasures a self-sizing cell. When reconfigured content
changes intrinsic size, verify the resulting geometry and animation before
adding any explicit invalidation. Add a narrow invalidation only when the
behavior or trace requires it.

## Cache sizes with complete keys

Cache measured sizes only after proving measurement is material. Include every
input that can affect geometry:

- stable content revision, available width, layout section or cell kind;
- content-size category, language, layout direction, and relevant traits;
- image aspect ratio or loaded-media state;
- editing, expanded, accessory, and configuration state when size-affecting.

Invalidate on every corresponding change and bound the cache. A fast stale size
that clips content or jumps after display is a defect.

## Choose and invalidate layouts narrowly

Prefer the simplest layout that expresses the required behavior:

1. table or collection-view list for one-dimensional content;
2. flow layout for a uniform grid or line-based arrangement;
3. compositional layout for mixed, adaptive, hierarchical, or orthogonal
   sections;
4. custom `UICollectionViewLayout` only for geometry or interaction the standard
   layouts cannot represent.

For compositional layouts, derive adaptive columns from the layout
environment's effective content size rather than fixed device assumptions.
Avoid rebuilding an equivalent layout for every data update.

For custom layouts, cache layout attributes only with explicit invalidation
rules. Recompute the smallest affected region, implement bounds-change
invalidation intentionally, and separate geometry from model access. Profile
large invalidation contexts and decoration or supplementary counts.

## Control rendering and hosted SwiftUI cost

Use standard views and layers where possible. In a measured render hitch,
inspect masks, shadows, blur, transparency, offscreen passes, oversized images,
custom drawing, and layer count. Do not rasterize or flatten the hierarchy by
default; each can trade CPU, GPU, memory, fidelity, and invalidation cost.

`UIHostingConfiguration` can simplify SwiftUI content inside UIKit cells, but
it is not a performance guarantee. Preserve stable item identity, explicit
state, and correct sizing. If the trace shows SwiftUI body, dependency, or
layout churn, use `$swiftui-optimization` for that hosted subtree. Compare a
UIKit rewrite only when the product and maintenance tradeoff justify it.

## Review supplementary and decoration views

Apply the same rules to headers, footers, badges, backgrounds, and other
reusable views:

- keep registrations stable and configuration complete;
- avoid synchronous work and hierarchy mutation in providers;
- use stable section or item identity rather than retaining index paths;
- keep pinning and z-order behavior correct during updates;
- include their sizing and attributes in layout invalidation analysis.
