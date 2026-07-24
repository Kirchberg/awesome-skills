# Observation in SwiftUI

## Contents

- Check availability and architecture
- Define observable model data
- Choose the view relationship
- Share through the environment deliberately
- Migrate incrementally
- Preserve reactive behavior explicitly

## Check availability and architecture

SwiftUI supports Observation starting with iOS 17, iPadOS 17,
Mac Catalyst 17, macOS 14, tvOS 17, watchOS 10, and visionOS 1, using the
Swift 5.9 / Xcode 15 generation of the toolchain or newer. Check the actual
deployment targets before replacing a legacy `ObservableObject` path.

Observation supplies change tracking. It does not provide actor isolation,
thread safety, persistence, request cancellation, or stream operators. Preserve
the model's synchronization and isolation requirements; use `@MainActor` only
when the model semantically belongs to the main actor.

## Define observable model data

Apply `@Observable` to the model class. Do not conform to `Observable` manually;
the protocol alone does not synthesize tracking.

```swift
import Observation

@Observable
@MainActor
final class SearchModel {
    var query = ""
    var results: [SearchResult] = []

    @ObservationIgnored
    let service: SearchService

    init(service: SearchService) {
        self.service = service
    }
}
```

Use `@ObservationIgnored` for accessible stored implementation details that
must not participate in tracking, such as a service, cache, logger, lock, or
separate reactive pipeline. Do not hide data that affects `body` merely to
reduce updates; doing so makes the UI stale unless another correct dependency
drives it.

Computed properties participate through the observable stored properties they
read. Keep an expensive computed property out of a hot `body`, and remember
that reading a broad collection through a computed property still tracks that
collection. Optionals, collections, and nested observable objects are
supported, but only observable properties actually accessed in the execution
scope become dependencies.

## Choose the view relationship

Let the view that creates and owns the model preserve it with `@State`:

```swift
struct SearchRoot: View {
    @State private var model: SearchModel

    init(service: SearchService) {
        _model = State(initialValue: SearchModel(service: service))
    }

    var body: some View {
        SearchScreen(model: model)
    }
}
```

Identity still controls lifetime. Intentionally changing the owner's identity
creates new state and a new model.

Accept a borrowed model without an ownership wrapper when the child only reads
or invokes it:

```swift
struct SearchResults: View {
    let model: SearchModel

    var body: some View {
        ResultsList(items: model.results)
    }
}
```

SwiftUI tracks the observable properties read by `body`; no `@ObservedObject`
wrapper is required.

Use `@Bindable` when a borrowed observable model needs binding projections:

```swift
struct SearchField: View {
    @Bindable var model: SearchModel

    var body: some View {
        TextField("Search", text: $model.query)
    }
}
```

`@Bindable` creates bindings. It does not own, retain across identity changes,
or broaden the model's lifetime.

## Share through the environment deliberately

Inject a genuinely ambient observable model with:

```swift
SearchScreen()
    .environment(model)
```

Read it with:

```swift
@Environment(SearchModel.self) private var model
```

If a binding is needed, create a local bindable projection:

```swift
var body: some View {
    @Bindable var model = model
    TextField("Search", text: $model.query)
}
```

Do not use environment injection as a generic performance optimization. It
hides dependencies at the call site and a missing required object can fail at
runtime. Read an optional environment model when absence is valid, and handle
`nil` explicitly. Prefer an explicit input when only one or two leaves need the
model.

## Migrate incrementally

For each model:

1. Confirm deployment availability and tests.
2. Replace `ObservableObject` conformance with `@Observable`.
3. Remove `@Published` from properties that should be observed.
4. Mark only true implementation details with `@ObservationIgnored`.
5. Replace owned `@StateObject` with `@State`.
6. Replace borrowed `@ObservedObject` with a normal property, or `@Bindable`
   when the view needs `$property`.
7. Replace `.environmentObject(model)` with `.environment(model)`.
8. Replace `@EnvironmentObject` with `@Environment(Model.self)`.
9. Recheck computed properties, optional or nested models, collections,
   bindings, actor isolation, and persistence behavior.
10. Profile the same interaction and verify which property accesses now
    invalidate each view.

Apple supports incremental migration and mixed Observation systems. Do not
rewrite all models atomically or assume behavior is identical:

- `ObservableObject` invalidates a subscribed view when any published property
  emits.
- Observation invalidates a view for observable properties read during its
  `body` evaluation.

This difference can remove unnecessary updates, but it can also expose code
that previously relied on broad incidental invalidation. Add the missing real
dependency instead of forcing a global refresh.

## Preserve reactive behavior explicitly

`@Observable` is not a drop-in replacement for every Combine or asynchronous
observation pipeline. If the model needs debounce, backpressure, transformation,
or a durable sequence of changes, select a current public Observation,
AsyncSequence, or Combine API that matches the supported toolchain. Keep that
pipeline separate from SwiftUI invalidation and avoid publishing the same
change through two mechanisms accidentally. Removing `@Published` also removes
its `$property` publisher; a projection from `@Bindable` is a SwiftUI `Binding`,
not a Combine publisher.
