# SwiftUI custom Liquid Glass

Add custom Liquid Glass only after system components and styles cannot express an
important functional element. Verify every signature and availability against the
selected SDK before emitting or accepting code.

## Contents

- Apply one effect deliberately
- Select variants, tint, and shape
- Prefer button styles for buttons
- Group related effects
- Distinguish union, identity, and transition
- Bound cost and fallback behavior

## Apply one effect deliberately

Use `glassEffect(_:in:)` on the custom control's semantic visual boundary. The
default effect is regular glass in a capsule. Choose another shape when the
component's geometry requires it.

Place sizing, padding, base foreground, and other appearance that the effect must
capture before `.glassEffect`. Place overlays, accessibility semantics, hit-testing,
and interaction modifiers according to their own behavior; do not turn “after
appearance modifiers” into a mechanical “always last” rule.

```swift
Label("Filters", systemImage: "line.3.horizontal.decrease")
    .font(.headline)
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .glassEffect(.regular, in: .capsule)
```

Use `.regular.interactive()` only when the rendered element itself participates in
touch or pointer interaction. Prefer a semantic `Button` and glass button style for
an action rather than attaching interactivity to a decorative `Text` or `Image`.

## Select variants, tint, and shape

- Default to `.regular`.
- Use `.clear` only over media-rich content that can be dimmed when necessary and
  with bold, bright foreground content that stays readable. Do not mix clear and
  regular glass in one related composition.
- Use `.tint(...)` for meaningful prominence, selection, or a primary action.
  Preserve state through semantics and shape or label, not tint alone.
- Use capsules for compact controls and an intentional rounded or concentric shape
  for larger components. Test the actual bounds after Dynamic Type expansion.
- Use `.identity` only when its no-effect role is deliberately required by an API
  composition; do not use it as an unexplained default.

## Prefer button styles for buttons

Use `.buttonStyle(.glass)` or `.buttonStyle(.glassProminent)` when their availability
matches the target and the element is a button. These preserve native state and
interaction treatment better than a manual effect around a lookalike.

The configurable `GlassButtonStyle` initializer has a later 26.x availability than
the base glass styles. Check the installed SDK before using it; do not assume all
glass button overloads share the same introduction version.

```swift
@ViewBuilder
private var confirmButton: some View {
    if #available(iOS 26.0, *) {
        Button("Confirm", action: confirm)
            .buttonStyle(.glassProminent)
    } else {
        Button("Confirm", action: confirm)
            .buttonStyle(.borderedProminent)
    }
}
```

Keep the action, label, role, disabled state, identifier, and accessibility behavior
common across branches when practical.

## Group related effects

Wrap a set of related, simultaneously visible custom effects in one
`GlassEffectContainer`. Its spacing influences when nearby shapes begin to merge;
it is not generic layout spacing and does not replace the child stack's spacing.

```swift
GlassEffectContainer(spacing: 12) {
    HStack(spacing: 12) {
        Button("Back", systemImage: "chevron.left", action: goBack)
            .buttonStyle(.glass)
        Button("Favorite", systemImage: "heart", action: favorite)
            .buttonStyle(.glass)
    }
}
```

Do not wrap every screen or every unrelated row in a container. Avoid nested or
adjacent containers that describe one visual group.

## Distinguish union, identity, and transition

- Use `glassEffectUnion(id:namespace:)` when multiple compatible view geometries
  should render as one glass shape.
- Use `glassEffectID(_:in:)` to give effects stable identities within a container
  when hierarchy changes should preserve a meaningful relationship.
- Use `glassEffectTransition(_:)` to control how an effect enters or leaves the
  hierarchy.
- Animate the state change that owns the hierarchy mutation. Keep identifiers
  stable and unique in the relevant namespace.

Do not add all three mechanically. A morph is justified only when it communicates
continuity between related controls or states; otherwise use an ordinary insertion,
removal, or no animation.

## Bound cost and fallback behavior

Limit simultaneously visible custom effects, group related effects, avoid per-row
glass in large scrolling collections, and profile a representative interaction when
performance is at risk or claimed. No official fixed maximum view count exists.

When the deployment target predates an API, provide a semantic system control,
standard `Material`, or opaque surface fallback. If the compiler itself predates
the API, `#available` cannot parse an unknown symbol; use a toolchain that knows the
API or a verified compile-time isolation strategy in addition to runtime gating.
