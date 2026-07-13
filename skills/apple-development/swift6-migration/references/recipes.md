# Swift 6 migration recipes

## Contents

- [Immutable reference](#immutable-reference)
- [Actor-owned mutable state](#actor-owned-mutable-state)
- [Main-actor UI state](#main-actor-ui-state)
- [Lock-protected legacy type](#lock-protected-legacy-type)
- [Sendable callback](#sendable-callback)
- [Legacy main-thread callback](#legacy-main-thread-callback)
- [Preconcurrency import](#preconcurrency-import)
- [Static mutable state](#static-mutable-state)
- [Unsafe patterns](#unsafe-patterns)
- [Review checklist](#review-checklist)

Use these recipes only after identifying the actual ownership and execution model. A compiling example is not proof that it matches the project.

## Immutable reference

Use a `final` immutable class when identity matters and every stored value is `Sendable`.

```swift
final class RequestContext: Sendable {
    let requestID: UUID
    let createdAt: Date

    init(requestID: UUID, createdAt: Date) {
        self.requestID = requestID
        self.createdAt = createdAt
    }
}
```

Do not add mutable lazy storage, unsynchronized caches, or non-`Sendable` delegates later without revisiting the conformance.

## Actor-owned mutable state

Use an actor for state accessed from independent tasks.

```swift
actor TokenStore {
    private var token: String?

    func read() -> String? {
        token
    }

    func replace(with token: String?) {
        self.token = token
    }
}
```

Review reentrancy across every `await`. Capture required state before suspension or revalidate it afterward.

## Main-actor UI state

```swift
@MainActor
final class SearchViewModel {
    private(set) var results: [SearchResult] = []

    func apply(_ results: [SearchResult]) {
        self.results = results
    }
}
```

Call from asynchronous work with an explicit actor hop:

```swift
let results = try await service.search(query)
await MainActor.run {
    viewModel.apply(results)
}
```

Do not use `DispatchQueue.main.async` as a mechanical replacement when structured actor isolation can express the contract.

## Lock-protected legacy type

Use `@unchecked Sendable` only when a legacy synchronous API cannot become an actor and one lock protects every mutable access.

```swift
import Foundation

final class Counter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0

    func increment() {
        lock.lock()
        defer { lock.unlock() }
        value += 1
    }

    func snapshot() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}
```

Required evidence:

- the class is `final` or subclassing is controlled;
- no mutable reference escapes the lock;
- callbacks do not run while the lock is held unless reentrancy is designed;
- deinitialization and observers follow the same invariant;
- focused concurrent tests exist;
- the report records the invariant and owner.

Prefer the platform's modern synchronization primitives when availability and repository conventions support them.

## Sendable callback

```swift
func load(
    completion: @escaping @Sendable (Result<Data, Error>) -> Void
) {
    workerQueue.async {
        completion(.success(Data()))
    }
}
```

Adding `@Sendable` is an API change. Inspect callers for captured mutable state and non-`Sendable` references.

If the callback always runs on a global actor, model that contract instead:

```swift
func load(
    completion: @escaping @MainActor @Sendable (Result<Data, Error>) -> Void
) {
    Task { @MainActor in
        completion(.success(Data()))
    }
}
```

Preserve ordering, multiplicity, and cancellation guarantees from the original API.

## Legacy main-thread callback

Use a dynamic assertion only when an external synchronous API guarantees main-thread execution but cannot express it in its type system.

```swift
legacyObject.performSynchronously {
    MainActor.assumeIsolated {
        viewModel.refresh()
    }
}
```

Before using this pattern:

- cite the callback guarantee in code or migration state;
- verify the callback is synchronous;
- add a focused boundary test where practical;
- prefer a typed `@MainActor` adapter when the API is under project control.

Never use `assumeIsolated` to silence an arbitrary callback, notification, delegate method, or delayed closure.

## Preconcurrency import

```swift
@preconcurrency import LegacyNetworking
```

Keep it near a narrow compatibility adapter. Record:

- dependency and version;
- missing or incorrect annotations;
- threading assumptions;
- tests covering the boundary;
- upgrade or removal condition.

Do not spread the import across the codebase or treat it as a permanent migration result.

## Static mutable state

Replace shared mutation with an actor:

```swift
actor ImageCache {
    static let shared = ImageCache()

    private var values: [URL: Data] = [:]

    func value(for url: URL) -> Data? {
        values[url]
    }

    func insert(_ data: Data, for url: URL) {
        values[url] = data
    }
}
```

Or isolate UI-only global state:

```swift
@MainActor
final class AppearanceStore {
    static let shared = AppearanceStore()
    private(set) var style: Style = .system
}
```

Do not replace a static `var` with `nonisolated(unsafe)` unless an existing external synchronization mechanism is named and audited.

## Unsafe patterns

Reject these mechanical fixes:

```swift
final class Box<T>: @unchecked Sendable {
    var value: T
}
```

The annotation adds no synchronization.

```swift
nonisolated(unsafe) static var sharedState: [String: Any] = [:]
```

The declaration disables checking while retaining a data race.

```swift
Task.detached {
    self.updateUI()
}
```

Detached tasks do not inherit actor context.

```swift
@preconcurrency import EveryDependency
```

Broad compatibility suppression hides which boundary is actually unsafe.

Also reject:

- adding `@MainActor` to broad APIs without reviewing conformers;
- wrapping mutable captures in unchecked boxes;
- deleting tests that expose ordering or isolation regressions;
- changing callback delivery queues silently;
- adding `any` to all protocol uses as a concurrency fix;
- treating a successful module build as proof that applications and extensions still integrate.

## Review checklist

For every concurrency-related change, ask:

1. Who owns the mutable state?
2. Which executor or lock enforces that ownership?
3. Can a value escape the protected region?
4. Does an `await` introduce reentrancy?
5. Did public isolation, `Sendable`, or callback annotations change?
6. Which consumers were inspected?
7. Which focused test proves the intended behavior?
8. Is any escape hatch temporary, owned, and removable?
