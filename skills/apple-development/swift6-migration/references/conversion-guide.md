# Swift 6 conversion guide

## Contents

- [Root-cause workflow](#root-cause-workflow)
- [Sendable value types](#sendable-value-types)
- [Reference types](#reference-types)
- [Global actor isolation](#global-actor-isolation)
- [Closures and captured state](#closures-and-captured-state)
- [Protocols and public API](#protocols-and-public-api)
- [Static and global state](#static-and-global-state)
- [Legacy dependencies](#legacy-dependencies)
- [Tests](#tests)

## Root-cause workflow

Express what is already true in the program. Do not redesign architecture merely to suppress a diagnostic, and do not promise thread safety that the implementation does not provide.

For each diagnostic:

1. Identify the value crossing an isolation boundary.
2. Identify the owner of mutable state.
3. Identify the actual executor or synchronization mechanism.
4. Fix the contract where that invariant is known.
5. Inspect public consumers and conformances.
6. Use a temporary compatibility escape hatch only after safer representations are ruled out.

Prefer one root-cause fix over many call-site assertions.

## Sendable value types

Add `Sendable` to a `struct` or `enum` when every stored value is `Sendable` and all operations preserve the invariant.

```swift
struct RequestID: Sendable {
    let rawValue: String
}
```

For a public type, `Sendable` becomes part of the API contract. Record it and inspect downstream generic constraints and conformances.

Do not add `Sendable` when the value wraps unprotected reference mutation.

## Reference types

A class can safely conform to `Sendable` when it is `final`, immutable after initialization, and stores only `Sendable` values.

```swift
final class Endpoint: Sendable {
    let url: URL

    init(url: URL) {
        self.url = url
    }
}
```

For mutable reference state, choose one real ownership model:

- move the state into an `actor`;
- isolate the type to a global actor;
- protect every access with one synchronization primitive;
- keep the value inside its existing isolated owner instead of sending it.

`@unchecked Sendable` is appropriate only when the compiler cannot see a real, complete synchronization invariant. Audit initializers, deinitialization, lazy properties, callbacks, observers, subclassing, and every read/write path before using it.

## Global actor isolation

Use `@MainActor` for state that is semantically owned by the main actor, not merely because the current call happens on the main thread.

```swift
@MainActor
final class ProfileViewModel {
    private(set) var name = ""

    func update(name: String) {
        self.name = name
    }
}
```

At call sites, propagate actor context through `async` APIs or perform an explicit hop:

```swift
await MainActor.run {
    viewModel.update(name: value)
}
```

Do not apply `@MainActor` to an entire protocol, base class, or module without reviewing all conformers and consumers. Isolation changes are API changes.

Use `nonisolated` only for members that do not access isolated mutable state. Use `nonisolated(unsafe)` only with documented external synchronization.

## Closures and captured state

When an API accepts concurrent work, model the closure as `@Sendable` when the API contract allows it.

```swift
func schedule(_ operation: @escaping @Sendable () -> Void) {
    queue.async(execute: operation)
}
```

Then inspect every capture:

- immutable `Sendable` values are usually safe;
- mutable local variables need isolated ownership, not a capture-list trick;
- weak captures do not make a non-`Sendable` object safe;
- callback queue guarantees must be represented explicitly or documented at the boundary.

Do not replace a mutable capture with a mutable `@unchecked Sendable` box. Use an actor, synchronization primitive, task result, async sequence, or a narrower API.

Preserve cancellation, ordering, and callback semantics when adapting completion handlers to async code.

## Protocols and public API

Determine whether isolation is part of the protocol's semantics.

- If every conformer is main-actor-owned, isolate the protocol deliberately and update all consumers.
- If only one conformer is isolated, do not force all conformers onto that actor merely to satisfy the compiler.
- If a synchronous nonisolated requirement must call isolated state, redesign the boundary or provide an explicitly safe snapshot.

Review:

- protocol requirements and extensions;
- generic constraints;
- existential uses;
- Objective-C exposed members;
- delegate and data-source methods;
- generated interfaces and external consumers.

Do not add `any` globally. Existential spelling is separate from concurrency correctness and should follow actual compiler diagnostics and the project's enabled language features.

## Static and global state

Classify each mutable static or global value:

- immutable constant;
- actor-owned state;
- global-actor-owned state;
- synchronized shared state;
- unsafe process-global mutation.

Prefer immutable values, actors, dependency injection, or explicit locking. `nonisolated(unsafe)` only suppresses checking; it does not add synchronization.

Singletons require the same review as any other shared mutable reference. A `static let` singleton does not make its mutable properties safe.

## Legacy dependencies

Use `@preconcurrency import` only when a dependency lacks usable concurrency annotations and cannot be upgraded or wrapped within the stage.

Before adding it:

1. Check for a newer compatible dependency version.
2. Inspect the dependency's documented threading contract.
3. Minimize the boundary to one adapter or import site.
4. Add tests for the assumed queue or executor behavior.
5. Record an owner and removal condition.

For callbacks documented to execute synchronously on the main thread, `MainActor.assumeIsolated` may bridge a legacy boundary. It traps when the assumption is false and must not wrap arbitrary asynchronous callbacks.

Do not edit third-party or generated source code unless the dependency is intentionally vendored and owned by the project.

## Tests

Migrate test targets with production targets when they use internal implementation details or shared settings.

Review:

- test-case isolation and lifecycle methods;
- shared mutable fixtures;
- expectations fulfilled from concurrent callbacks;
- fake clocks, schedulers, and executors;
- `@testable import` boundaries;
- callback ordering and cancellation assertions.

Prefer async test APIs and actor-owned fixtures where supported. Do not annotate an entire test suite `@MainActor` unless its subject and setup are genuinely main-actor-bound.

For every fix, record changed isolation, public API impact, compatibility escape hatches, focused tests, and remaining follow-ups.
