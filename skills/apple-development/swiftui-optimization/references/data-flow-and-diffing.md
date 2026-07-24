# Data flow, ownership, diffing, and identity

## Contents

- Use the dependency graph
- Choose state by ownership
- Pass render state, not feature state
- Create real update boundaries
- Treat identity as lifetime
- Use custom equality as a measured boundary

## Use the dependency graph

Reason about a SwiftUI update as invalidation in a dependency graph:

1. A parent produces a new child-view value.
2. SwiftUI supplies current dynamic-property values.
3. SwiftUI evaluates the invalidated `body`.
4. The framework reconciles the resulting graph and later renders required
   platform content.

Stored inputs, dynamic properties, environment values, and properties read from
an Observation model can all create dependencies. Narrowing those dependencies
usually gives a larger and safer improvement than adding comparison machinery.

Do not equate these events:

- constructing a `View` value;
- evaluating `body`;
- updating the SwiftUI graph;
- updating UIKit or AppKit views;
- submitting Core Animation content;
- presenting pixels.

Logs in `init` or `body` observe only the first two and distort timing.

## Choose state by ownership

- Use immutable `let` input for render values owned elsewhere.
- Use `@State private` for small local value state owned by the view's identity.
- Use `@Binding` when the child must mutate a value owned by an ancestor.
- On supported systems, own an `@Observable` reference with `@State`; pass a
  borrowed observable reference as a normal property and add `@Bindable` only
  where bindings are required.
- For legacy `ObservableObject`, use `@StateObject` when the view owns the
  object and `@ObservedObject` when it borrows an already-stable object.
- Use `@Environment` for genuine ambient context. Prefer explicit leaf inputs
  when only a small value is needed.

Never construct a reference model in `body`. Do not initialize an owned legacy
model with `@ObservedObject var model = Model()` because new view values can
create unstable instances.

Observation tracks the observable properties read while evaluating `body`.
This narrows invalidation, but reading a broad aggregate, collection, or
computed property still creates a broad dependency. `ObservableObject` emits at
object scope, so split surfaces or pass derived values when update storms are
measured. Read `observation.md` before introducing or migrating an observable
model.

## Pass render state, not feature state

Prefer:

```swift
struct ProductHeader: View {
    let title: String
    let isFavorite: Bool
    let onFavoriteTap: () -> Void

    var body: some View {
        HStack {
            Text(title)
            Button("Favorite", systemImage: isFavorite ? "star.fill" : "star") {
                onFavoriteTap()
            }
        }
    }
}
```

over passing a feature store containing unrelated loading, analytics, routing,
and pagination state. An action closure is normal SwiftUI API; optimize it only
when a capture or unstable handler is proven to invalidate hot children.

## Create real update boundaries

This improves readability but does not create a separate child-view value:

```swift
private var header: some View { /* ... */ }

@ViewBuilder
private func card() -> some View { /* ... */ }
```

Create `Header: View` or `Card: View` and pass narrow inputs when an independent
boundary is useful. Do not extract every expression mechanically; the boundary
should own a coherent dependency set.

## Treat identity as lifetime

Use a unique, stable, cheap domain identifier. A changed identity means a new
semantic view: local state can reset, tasks can restart, transitions can
replace continuity, and list diffing changes.

Avoid:

```swift
var id: UUID { UUID() }
ForEach(items.indices, id: \.self) { index in /* mutable collection */ }
ForEach(items, id: \.self) { item in /* duplicate or mutable values */ }
```

Index and `\.self` are valid only when uniqueness and stability are true for the
entire lifetime and mutation model.

## Use custom equality as a measured boundary

SwiftUI's internal comparison strategy is not a stable public contract.
`Equatable` can provide a deliberate boundary, but incorrect equality creates
stale UI or stale actions.

```swift
struct RowRenderState: Equatable {
    let title: String
    let isEnabled: Bool
}

struct Row: View, Equatable {
    let state: RowRenderState
    let onTap: () -> Void

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state
    }

    var body: some View {
        Button(state.title, action: onTap)
            .disabled(!state.isEnabled)
    }
}
```

The example is safe only if `onTap` remains semantically stable while two rows
compare equal. Document and test that invariant. If the target, routing, or
captured dependencies can change, include an equatable action identity, change
the design, or do not suppress the update.

`@State`, `@Environment`, and other dynamic dependencies can independently
invalidate a view even when its ordinary stored inputs compare equal.
