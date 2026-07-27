# Swift concurrency patterns and anti-patterns

## Contents

- [Use examples as contracts](#use-examples-as-contracts)
- [Transfer immutable values](#transfer-immutable-values)
- [Revalidate actor state](#revalidate-actor-state)
- [Bound a dynamic task group](#bound-a-dynamic-task-group)
- [Own a lifecycle task](#own-a-lifecycle-task)
- [Bridge one callback result](#bridge-one-callback-result)
- [Build a finite async stream](#build-a-finite-async-stream)
- [Protect synchronous state](#protect-synchronous-state)
- [Reject unsafe shortcuts](#reject-unsafe-shortcuts)

## Use examples as contracts

Adapt each example to the selected compiler, SDK, deployment target, and API
semantics. A compiling snippet is not proof that its ownership, cancellation,
ordering, or lifetime matches the project.

For every adopted pattern, state:

- the invariant;
- minimum toolchain or feature;
- cancellation and error behavior;
- public API effect;
- focused test.

## Transfer immutable values

Use a `Sendable` snapshot instead of sharing a mutable reference.

```swift
struct SearchRequest: Sendable {
    let query: String
    let page: Int
}

struct SearchPage: Sendable {
    let ids: [UUID]
}
```

Invariant: every stored value is `Sendable`, and mutation remains local before
or after transfer.

Do not add a mutable reference, lazy cache, delegate, or closure later without
re-evaluating the conformance.

## Revalidate actor state

An actor can prevent stale results from overwriting newer state by recording a
generation before suspension.

```swift
actor SearchStore {
    private var generation = 0
    private var results: [SearchResult] = []

    func beginSearch() -> Int {
        generation += 1
        return generation
    }

    func apply(_ newResults: [SearchResult], for request: Int) {
        guard request == generation else { return }
        results = newResults
    }
}

let request = await store.beginSearch()
let results = try await service.search(query)
try Task.checkCancellation()
await store.apply(results, for: request)
```

Invariant: only the latest generation can commit. Test by suspending the first
request, completing a second request, then resuming the first.

If the complete operation belongs inside one actor method, the same generation
check must occur after its `await`.

## Bound a dynamic task group

Use a sliding window rather than enqueueing an unbounded input all at once.

```swift
try await withThrowingTaskGroup(of: IndexedValue.self) { group in
    var pending = inputs.indices.makeIterator()

    for _ in 0..<min(limit, inputs.count) {
        if let index = pending.next() {
            let input = inputs[index]
            group.addTask {
                IndexedValue(index: index, value: try await transform(input))
            }
        }
    }

    while let result = try await group.next() {
        output[result.index] = result.value
        try Task.checkCancellation()
        if let index = pending.next() {
            let input = inputs[index]
            group.addTask {
                IndexedValue(index: index, value: try await transform(input))
            }
        }
    }
}
```

Treat this as a shape, not drop-in generic code. Inputs, captures, results, and
the `transform` closure must satisfy the selected language mode's transfer
requirements.

Invariant: at most `limit` child operations are pending. Test the maximum active
count, output ordering, first error, and parent cancellation.

## Own a lifecycle task

Store and cancel work that belongs to an object's lifecycle.

```swift
@MainActor
final class SearchModel {
    private var searchTask: Task<Void, Never>?

    func search(for query: String) {
        searchTask?.cancel()
        searchTask = Task {
            do {
                let value = try await service.search(query)
                try Task.checkCancellation()
                apply(value)
            } catch is CancellationError {
                // Replacement and teardown are expected cancellation.
            } catch {
                apply(error)
            }
        }
    }

    func stop() {
        searchTask?.cancel()
        searchTask = nil
    }
}
```

Invariant: one owner controls replacement and calls `stop()` at teardown, and
canceled work cannot apply stale state. Prefer a framework lifecycle API such
as SwiftUI `.task` when it can own cancellation automatically.

If cancellation must occur from deinitialization, check the selected Swift
version's isolated-deinitializer support and prove that the handle and captures
do not form a retained cycle.

## Bridge one callback result

Use a checked continuation only when the legacy API completes exactly once.

```swift
func loadValue() async throws -> Value {
    try await withCheckedThrowingContinuation { continuation in
        legacy.load { result in
            continuation.resume(with: result)
        }
    }
}
```

Invariant: `legacy.load` invokes its callback exactly once on every terminal
path and retains it only until completion.

This simple bridge does not connect task cancellation to legacy work. If the
legacy API returns a cancellation token, implement the synchronized state
machine in `streams-and-bridges.md` rather than adding an unsynchronized local
variable.

## Build a finite async stream

Model a repeated callback source with explicit teardown.

```swift
func values() -> AsyncStream<Value> {
    AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
        let token = source.observe { value in
            continuation.yield(value)
        }

        continuation.onTermination = { @Sendable _ in
            source.removeObserver(token)
        }
    }
}
```

Invariant: observation ends when iteration terminates, and retaining only the
newest value matches the domain.

Adapt the capture contract: `source` and `token` must be safe for the
`@Sendable` termination closure. Add explicit `finish` behavior for finite or
failing sources and synchronize removal if emission can race with termination.

## Protect synchronous state

Use `Mutex` for a small synchronous critical region when supported.

```swift
import Synchronization

final class Counter: Sendable {
    private let value = Mutex(0)

    func increment() {
        value.withLock { $0 += 1 }
    }

    func snapshot() -> Int {
        value.withLock { $0 }
    }
}
```

Invariant: the mutex owns all mutable state, protected storage never escapes,
and no lock scope suspends or invokes unknown code.

Review toolchain and deployment availability. For a legacy lock wrapped in an
`@unchecked Sendable` class, document the same invariant and test every access
path.

## Reject unsafe shortcuts

Reject an unchecked mutable box:

```swift
final class Box<T>: @unchecked Sendable {
    var value: T
}
```

The annotation adds no synchronization.

Reject disabled checking around global mutation:

```swift
nonisolated(unsafe) static var sharedState: [String: Any] = [:]
```

Reject detached work as a background or isolation escape:

```swift
Task.detached {
    self.updateUI()
}
```

Reject a blocking async bridge:

```swift
let semaphore = DispatchSemaphore(value: 0)
Task {
    await operation()
    semaphore.signal()
}
semaphore.wait()
```

Reject broad compatibility suppression:

```swift
@preconcurrency import EveryDependency
```

Also reject:

- adding `@MainActor` to broad APIs without auditing synchronous work and
  consumers;
- holding any lock across `await`;
- starting one task per element of unbounded input;
- ignoring task handles and throwing task results;
- swallowing cancellation in a generic catch;
- resuming a continuation from multiple callback paths;
- using an unbounded stream buffer without a proven finite producer;
- claiming performance improvement without a repeated equivalent trace or
  benchmark.
