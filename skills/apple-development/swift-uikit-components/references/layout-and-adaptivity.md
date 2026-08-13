# Layout and adaptivity

## Define the sizing contract

State whether the component has intrinsic size, accepts an external size,
self-sizes within a scroll container, or owns a scroll view. Specify minimum and
maximum behavior, aspect-ratio policy, compression and hugging priorities, and
which content changes invalidate intrinsic size or layout.

Constrain a complete path from each self-sizing view's leading to trailing and
top to bottom edges. Use safe-area, readable-content, layout-margin, content,
frame, and keyboard layout guides for their actual semantics. Avoid redundant
constraints and arbitrary priority changes that only silence a warning.

Use stack views for linear distribution when their arranged-subview semantics
fit. Do not hide layout ambiguity behind spacer views or deeply nested stacks.
For manual layout, derive frames from `bounds`, respect transforms and scale,
and keep the manual subtree behind an explicit boundary from Auto Layout.

## Update layout safely

Change only the constraints required by new state. Prefer updating constants or
activating small mutually exclusive groups over rebuilding the entire graph.
Use `setNeedsUpdateConstraints()` and `setNeedsLayout()` to schedule work; force
`layoutIfNeeded()` only when synchronous geometry or an intentional animation
requires it.

Never call layout invalidation in a cycle from `layoutSubviews()` or
`updateConstraints()`. Do not perform networking, file I/O, decoding, parsing,
or expensive model transformation during update, layout, or display passes.

Diagnose unsatisfiable constraints from the first broken requirement, symbolic
identifiers, and a reduced hierarchy. Diagnose ambiguity separately. Treat a
console free of warnings as necessary but insufficient evidence for correct
layout across content and sizes.

## Adapt to the container

Use the actual container bounds, safe areas, traits, and scene geometry. Avoid
branching on `UIScreen.main.bounds`, remembered hardware sizes, or idiom alone.
Support rotation, split view, Stage Manager, external displays, iPhone Mirroring,
and resizable windows only to the extent required by the target platform matrix,
but do not bake assumptions that prevent them.

Use automatic trait tracking only in methods and closures documented to support
it, and gate behavior by the actual SDK and OS. Otherwise register for the
specific traits the component consumes. Do not keep `traitCollectionDidChange(_:)`
as a universal default when narrower supported mechanisms exist.

Treat scenes as independent UI instances. Resolve windows, screens, geometry,
and presentation context from the relevant scene instead of global application
state. Preserve per-scene navigation and restoration where the product supports
multiple scenes.

## Support content variation

Use preferred text styles and `UIFontMetrics` for custom fonts. Allow labels and
controls to grow, wrap, truncate, or scroll according to product intent. Test
accessibility content sizes, longer localized strings, bidirectional text, large
numbers, empty content, and image aspect-ratio variation.

Use semantic colors and images that adapt to appearance and increased contrast.
Resolve traits at the point UIKit owns them; do not freeze dynamic colors into
stale values without a deliberate redraw path.

Use `UIKeyboardLayoutGuide` or the project's established keyboard coordination
instead of hard-coded keyboard heights. Test docked, undocked, split, hardware,
and interactive keyboard changes when relevant.
