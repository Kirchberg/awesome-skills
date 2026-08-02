# App Intents code patterns

Use these as structural examples, not copy-paste API authority. Confirm every
signature, availability annotation, and protocol requirement in the selected
Xcode SDK. Replace example services and routes with the app's domain interfaces.

## Contents

- Register and inject a domain service
- Define a narrow entity and identifier query
- Provide curated App Shortcuts
- Open a precise entity
- Separate declaration from domain behavior
- Adapt patterns safely

## Register and inject a domain service

Register dependencies before system invocation can occur:

```swift
import AppIntents

@main
struct ExampleApp: App {
    private let catalog: CatalogService

    init() {
        let catalog = CatalogService.live()
        self.catalog = catalog
        AppDependencyManager.shared.add(dependency: catalog)
    }

    var body: some Scene { /* app scenes */ }
}
```

Inject the service rather than constructing a parallel stack in `perform()`:

```swift
struct MarkFavoriteIntent: AppIntent {
    static let title: LocalizedStringResource = "Mark Favorite"
    static let description = IntentDescription("Marks an item as a favorite.")

    @Parameter(title: "Item")
    var item: ItemEntity

    @Dependency
    private var catalog: CatalogService

    static var parameterSummary: some ParameterSummary {
        Summary("Mark \(\.$item) as a favorite")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await catalog.markFavorite(id: item.id)
        return .result(dialog: "Marked \(item.name) as a favorite.")
    }
}
```

Add the current execution contract only in source compiled by an SDK that
declares `IntentModes`, and adjust platform availability to the actual target:

```swift
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
extension MarkFavoriteIntent {
    static var supportedModes: IntentModes { .background }
}
```

An availability annotation does not make an unknown type compile with an older
SDK. Keep this extension out of older-toolchain source membership or behind the
project's compile-time SDK boundary. For older deployed OS versions, preserve
the intended background default or Apple's documented foreground compatibility
bridge and verify both paths.

Keep `CatalogService` safe for the selected Swift concurrency and process
contract. Do not turn a mutable UI object into `@unchecked Sendable` to satisfy
the wrapper.

## Define a narrow entity and identifier query

```swift
struct ItemEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Item"
    static let defaultQuery = ItemEntityQuery()

    let id: String
    @Property var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct ItemEntityQuery: EntityQuery {
    @Dependency
    private var catalog: CatalogService

    func entities(for identifiers: [ItemEntity.ID]) async throws -> [ItemEntity] {
        try await catalog.items(ids: identifiers).map(ItemEntity.init)
    }

    func suggestedEntities() async throws -> [ItemEntity] {
        try await catalog.suggestedItems(limit: 10).map(ItemEntity.init)
    }
}
```

Preserve requested-ID semantics and bounded suggestions in the real mapping.
Use repository-side string or property filtering for larger corpora.

## Provide curated App Shortcuts

```swift
struct ExampleShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: MarkFavoriteIntent(),
            phrases: [
                "Mark \(\.$item) as favorite in \(.applicationName)"
            ],
            shortTitle: "Mark Favorite",
            systemImageName: "star"
        )
    }
}
```

Verify current phrase token rules, expansion limits, localization extraction,
and parameter initialization in the selected SDK. Keep one app provider and a
small curated shortcut set. Refresh dynamic representations through
`updateAppShortcutParameters()` at the app's deterministic lifecycle boundary.

## Open a precise entity

When the selected SDK supports the pattern, pair `OpenIntent` with an entity
whose route is unambiguous:

```swift
struct OpenItemIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Item"

    @Parameter(title: "Item")
    var target: ItemEntity
}
```

Provide the current SDK's opening contract, such as a supported universal-link
representation or app-owned target-content route. Do not use `openAppWhenRun`
as the current routing design; it is deprecated and does not define a precise
destination. Keep it only in Apple's documented compatibility extension when an
older supported OS requires that bridge.

For a universal-link representation, derive the URL from the stable ID and
route it through the same validated app destination as ordinary links. Custom
URL schemes do not satisfy `URLRepresentableEntity`.

## Separate declaration from domain behavior

Prefer this source organization when the app is large:

```text
AppIntents/
  Entities/       narrow snapshots and queries
  Intents/        system adapters
  Shortcuts/      one provider and phrases
  Routing/        semantic destinations and handoff
Domain/
  UseCases/       authorization, idempotency, effects
Infrastructure/
  Repositories/   persistence and API adapters
```

Use `AppIntentsPackage` only when declarations live outside the app bundle and
an `AppIntentsExtension` only when out-of-process execution is a requirement.

## Adapt patterns safely

Before applying any example:

1. inspect deployment targets and the selected SDK interface;
2. choose the semantic protocol and `supportedModes` from behavior;
3. replace sample strings with localized resources;
4. preserve published identifiers and parameter contracts;
5. inject a real domain service and keep `perform()` thin;
6. handle authorization, offline state, cancellation, and duplicate effects;
7. build every target that extracts or executes the intent;
8. verify discovery and execution through each promised system surface.
