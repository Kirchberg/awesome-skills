# SwiftUI system components

Let SwiftUI own the navigation and control layer before adding custom effects.
Standard components receive platform-coordinated appearance, accessibility,
interaction, safe-area, and future design updates.

## Restore semantic structure

- Use `NavigationStack` for hierarchical navigation and
  `NavigationSplitView` for adaptive multicolumn structure.
- Use `TabView` and semantic tab roles for persistent peer destinations. Do not
  rebuild a tab bar as a floating `HStack` merely to obtain a glass appearance.
- Use `.toolbar` with correct `ToolbarItem` or `ToolbarItemGroup` placements for
  screen actions. Let the system group and move items across sizes.
- Use `.searchable` and its supported placement or role instead of a custom search
  field embedded in a simulated navigation bar.
- Use `sheet`, popover, confirmation, menu, and form APIs for their semantic
  presentations. Avoid adding another material background inside a presentation
  that already supplies one.
- Use `Button`, `Menu`, `Toggle`, `Picker`, and other controls so disabled, focus,
  pointer, keyboard, accessibility, and role behavior remain intact.

Observe the app on the selected current SDK before applying `.glassEffect` to any
of these components. System-provided glass usually requires no manual effect.

## Audit bars and scroll edges

Trace `.toolbarBackground`, `.toolbarColorScheme`, safe-area insets, overlays,
custom separators, scroll-content backgrounds, title placement, and fixed offsets.
Remove a customization only when it conflicts with the intended system result.
Preserve semantic brand color or old-system behavior that still has a product role.

Test bars while content is at the top, scrolling under an edge, scrolled away from
the edge, loading, empty, and displaying long titles or many actions. Verify
overflow rather than shrinking labels or moving actions into an unlabelled custom
surface.

Use `tabBarMinimizeBehavior` only when the selected stable SDK declares it and the
content benefits from reclaiming space while scrolling. Treat minimization as
system behavior, not a custom tab-bar animation.

For a justified custom edge control, prefer the selected stable SDK's
`safeAreaBar` behavior over a fixed overlay so scrolling and safe-area relationships
remain system-coordinated. Use `ToolbarSpacer` where the current SDK provides it to
express intentional toolbar grouping instead of inserting decorative empty views.

## Extend content intentionally

Use `backgroundExtensionEffect` for supported edge-to-edge media whose visual
background should extend beyond its layout bounds under adjacent system areas.
Verify its declaration in the selected SDK and gate it when required.

Do not substitute blanket `ignoresSafeArea()` or a stretched screenshot. Keep
interactive content, text, and essential imagery inside appropriate safe areas and
check cropping across sizes, orientation, Split View, and resizing.

## Compose toolbars by meaning

- Put navigation actions in navigation placements and primary screen actions in
  the appropriate top or bottom bar placement.
- Group related actions; separate destructive or unrelated actions semantically.
- Prefer a `Menu` or system overflow for secondary actions rather than squeezing
  every control into one row.
- Keep labels and symbols meaningful without relying on material or tint.
- Preserve keyboard shortcuts, roles, accessibility labels, and stable identifiers
  when migrating a custom toolbar.

Do not use prerelease toolbar priority, pinned placement, or minimization APIs in
stable examples. Route an explicit Xcode 27 request to `09-current-beta.md`.

## Validate presentations and search

For sheets and popovers, exercise compact and regular presentations, detents,
keyboard appearance, scrolling, nested navigation, forms, dismissal, and the old-
system fallback. Remove custom visual-effect backgrounds only after verifying the
system presentation supplies the intended separation and legibility.

For search, exercise inactive, focused, typing, suggestions, results, empty, and
cancellation states. Let the system coordinate search placement with navigation
and tabs; do not paint glass behind a duplicate field.

## Review checklist

- Does one system component own each navigation, tab, search, toolbar, and
  presentation role?
- Did the unchanged component already receive system Liquid Glass on the selected
  SDK?
- Are custom backgrounds and borders still justified rather than inherited debt?
- Do safe areas, scroll edges, overflow, focus, and adaptive sizes work?
- Is custom glass absent unless the system component cannot express the role?
- Is every newer API tied to its actual SDK and runtime availability?
