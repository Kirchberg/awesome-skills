# Swift concurrency primary sources

Last reviewed: 2026-07-27. Stable baseline: Swift 6.3.3. Treat Swift 6.4
previews as non-normative until release.

## Contents

- [Use the source registry](#use-the-source-registry)
- [Required core](#required-core)
- [Swift 6.3 and version-sensitive updates](#swift-63-and-version-sensitive-updates)
- [Tasks, cancellation, and lifetime](#tasks-cancellation-and-lifetime)
- [Isolation, transfer, and actors](#isolation-transfer-and-actors)
- [Performance, memory, and synchronization](#performance-memory-and-synchronization)
- [Continuations, sequences, and Foundation](#continuations-sequences-and-foundation)
- [SwiftUI and Apple-platform integration](#swiftui-and-apple-platform-integration)
- [Migration, diagnostics, and testing](#migration-diagnostics-and-testing)
- [Legacy and advanced references](#legacy-and-advanced-references)

## Use the source registry

Prefer the source matching the detected compiler, SDK, and deployment target.
Use these labels:

- **Normative**: accepted language design or current language/API documentation.
- **Versioned**: release- or feature-specific behavior; verify availability.
- **Apple runtime**: implementation and tooling guidance for Apple platforms,
  not a portable language guarantee.
- **Workflow**: diagnostic, migration, profiling, or testing procedure.
- **Example**: useful teaching code, not the normative definition.
- **Legacy**: use for interoperability or migration, not as the default style.
- **Advanced**: load only for library, runtime, or low-level infrastructure.

Final accepted proposals override vision documents and older teaching syntax.
In particular:

- enablement of `NonisolatedNonsendingByDefault` controls the Swift 6.2
  caller-context behavior for ordinary nonisolated async functions;
- `@concurrent` switches to the generic executor but does not promise another
  thread or simultaneous execution;
- default `MainActor` isolation is opt-in;
- the approachable-concurrency vision is rationale, not a normative source.

## Required core

Use these 15 sources as the initial foundation. Load the task-specific sections
below rather than placing their complete content in `SKILL.md`.

1. **The Swift Programming Language — Concurrency** — Normative language
   overview for async/await, tasks, cancellation, actors, global actors, and
   `Sendable`.
   [Source](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
2. **Migrating to Swift 6** — Normative migration and data-race-safety portal.
   [Source](https://www.swift.org/migration/documentation/migrationguide/)
3. **SE-0304: Structured Concurrency** — Normative task-tree, child lifetime,
   cancellation, priority, and task-group design.
   [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0304-structured-concurrency.md)
4. **SE-0302: Sendable and @Sendable closures** — Normative transfer contract
   and closure-capture model.
   [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md)
5. **SE-0306: Actors** — Normative actor isolation and reentrancy model.
   [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md)
6. **SE-0414: Region-based Isolation** — Normative analysis of disconnected
   regions and safe transfer of some non-`Sendable` values.
   [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0414-region-based-isolation.md)
7. **SE-0430: Transferring parameters and results** — Normative `sending`
   semantics.
   [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0430-transferring-parameters-and-results.md)
8. **SE-0461: Async function isolation** — Normative caller-context and
   `@concurrent` design; inspect feature enablement.
   [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md)
9. **SE-0466: Control default actor isolation** — Normative opt-in module
   isolation behavior.
   [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md)
10. **SE-0470: Global-actor isolated conformances** — Normative protocol
    conformance behavior for global-actor-isolated types.
    [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0470-isolated-conformances.md)
11. **Swift 6.2 Released** — Versioned overview of approachable concurrency,
    task naming, and related toolchain changes.
    [Source](https://www.swift.org/blog/swift-6.2-released/)
12. **WWDC21: Swift concurrency — Behind the scenes** — Apple-runtime mental
    model for executors, continuations, cooperative scheduling, and forward
    progress.
    [Source](https://developer.apple.com/videos/play/wwdc2021/10254/)
13. **WWDC22: Eliminate data races using Swift Concurrency** — Apple teaching
    model for isolation, immutable values, and `Sendable`.
    [Source](https://developer.apple.com/videos/play/wwdc2022/110351/)
14. **WWDC23: Beyond the basics of structured concurrency** — Apple teaching
    model for task trees, cancellation, priorities, task locals, and unstructured
    work.
    [Source](https://developer.apple.com/videos/play/wwdc2023/10170/)
15. **WWDC25: Embracing Swift concurrency** — Modern Apple workflow from
    sequential code through isolation to deliberate concurrency.
    [Source](https://developer.apple.com/videos/play/wwdc2025/268/)

## Swift 6.3 and version-sensitive updates

- **Swift 6.3 Released** — Versioned language, standard-library, package, and
  platform baseline.
  [Source](https://www.swift.org/blog/swift-6.3-released/)
- **Swift 6.3.3 announcement** — Versioned fixes including
  `nonisolated(nonsending)` hop and isolation behavior. Record the exact patch
  because concurrency compiler fixes can affect diagnostics and runtime.
  [Source](https://forums.swift.org/t/announcing-swift-6-3-3/87888)
- **Swift 6.3.1 announcement** — Versioned fixes including async-function and
  `async let` stack-allocation crashes.
  [Source](https://forums.swift.org/t/announcing-swift-6-3-1/86080)
- **Version Compatibility** — Normative mapping between compiler and language
  modes.
  [Source](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/compatibility/)
- **SE-0481: weak let** — Versioned weak immutable storage relevant to
  `Sendable` classes and `@Sendable` captures.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0481-weak-let.md)
- **SE-0473: Clock epochs** — Versioned clock and duration model for timing
  APIs and tests.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0473-clock-epochs.md)
- **SE-0469: Task naming** — Versioned task names for debugging and profiling.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0469-task-names.md)
- **Approachable Concurrency vision** — Rationale only. It contains historical,
  pre-final spelling and must not override accepted proposals.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/visions/approachable-concurrency.md)

## Tasks, cancellation, and lifetime

- **WWDC21: Explore structured concurrency in Swift** — Example introduction to
  child tasks, `async let`, task groups, and cancellation.
  [Source](https://developer.apple.com/videos/play/wwdc2021/10134/)
- **Task** — Normative API reference for task values, priority, cancellation,
  and unstructured tasks.
  [Source](https://developer.apple.com/documentation/swift/task)
- **TaskGroup** — Normative API reference for dynamic structured children.
  [Source](https://developer.apple.com/documentation/swift/taskgroup)
- **withTaskCancellationHandler** — Normative API reference. The handler does
  not cancel legacy work automatically and can race with setup.
  [Source](https://developer.apple.com/documentation/swift/withtaskcancellationhandler%28operation%3Aoncancel%3Aisolation%3A%29)
- **SE-0317: async let** — Normative scoped child-task design for a fixed set.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0317-async-let.md)
- **Task.checkCancellation()** — Normative cooperative polling API for work
  without sufficient cancellation-aware suspension.
  [Source](https://developer.apple.com/documentation/swift/task/checkcancellation%28%29)
- **TaskPriority** — Normative scheduling-hint API; it does not guarantee order.
  [Source](https://developer.apple.com/documentation/swift/taskpriority)
- **SE-0311: Task-local values** — Normative scoped-context propagation.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0311-task-locals.md)
- **Task.detached** — Normative detached-task API and context differences.
  [Source](https://developer.apple.com/documentation/swift/task/detached%28name%3Apriority%3Aoperation%3A%29-795w1)
- **SE-0472: Task starting synchronously in caller context** — Advanced,
  version-sensitive task-start semantics; verify toolchain availability before
  use.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0472-task-start-synchronously-on-caller-context.md)

## Isolation, transfer, and actors

- **SE-0313: Improved control over actor isolation** — Normative `isolated` and
  `nonisolated` design.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0313-actor-isolation-control.md)
- **SE-0316: Global actors** — Normative global-actor and `MainActor` design.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0316-global-actors.md)
- **Sendable** — Current Apple API reference.
  [Source](https://developer.apple.com/documentation/swift/sendable)
- **MainActor** — Current Apple API reference.
  [Source](https://developer.apple.com/documentation/swift/mainactor)
- **Sending a value risks causing data races** — Compiler diagnostic guide for
  region and alias analysis.
  [Source](https://docs.swift.org/compiler/documentation/diagnostics/sending-risks-data-race/)
- **Captures of non-Sendable types in @Sendable closures** — Compiler diagnostic
  guide for closure captures.
  [Source](https://docs.swift.org/compiler/documentation/diagnostics/sendable-closure-captures/)
- **Mutable global variable** — Compiler diagnostic guide for process-wide
  shared mutation.
  [Source](https://docs.swift.org/compiler/documentation/diagnostics/mutable-global-variable/)
- **nonisolated(nonsending) by default** — Compiler diagnostic and feature
  enablement guide.
  [Source](https://docs.swift.org/compiler/documentation/diagnostics/nonisolated-nonsending-by-default/)
- **SE-0423: Dynamic actor isolation enforcement** — Advanced interoperability
  checks where static checking cannot represent the full boundary.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0423-dynamic-actor-isolation.md)
- **SE-0463: Mark Objective-C completion handlers as @Sendable** — Versioned
  imported callback behavior.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0463-sendable-completion-handlers.md)
- **SE-0431: @isolated(any) function types** — Advanced preservation of
  isolation metadata on function values.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0431-isolated-any-functions.md)
- **SE-0449: nonisolated for global-actor inference cutoff** — Versioned
  inference control for declarations and conformances.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0449-nonisolated-for-global-actor-cutoff.md)
- **SE-0371: Isolated synchronous deinit** — Version-sensitive isolated
  teardown semantics.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md)

## Performance, memory, and synchronization

- **WWDC22: Visualize and optimize Swift concurrency** — Apple-runtime
  Instruments workflow for tasks, actors, continuations, and pool behavior.
  [Source](https://developer.apple.com/videos/play/wwdc2022/110350/)
- **WWDC26: Profile, fix, and verify** — Current Apple profiling workflow.
  Treat language previews separately from the Swift 6.3 baseline.
  [Source](https://developer.apple.com/videos/play/wwdc2026/268/)
- **WWDC22: Track down hangs with Xcode and on-device detection** — Apple
  workflow for main-thread stalls, lock contention, and hang reports.
  [Source](https://developer.apple.com/videos/play/wwdc2022/10082/)
- **Diagnosing memory, thread, and crash issues early** — Apple Xcode diagnostic
  tool overview.
  [Source](https://developer.apple.com/documentation/xcode/diagnosing-memory-thread-and-crash-issues-early)
- **Data races** — Apple runtime race-detection guidance.
  [Source](https://developer.apple.com/documentation/xcode/data-races)
- **Synchronization** — Current Swift synchronization module.
  [Source](https://developer.apple.com/documentation/synchronization)
- **Mutex** — Current synchronous mutual-exclusion API.
  [Source](https://developer.apple.com/documentation/synchronization/mutex)
- **Atomic** — Current standard atomic API; prefer it over an external package
  when availability and requirements fit.
  [Source](https://developer.apple.com/documentation/synchronization/atomic)
- **SE-0433: Synchronous Mutual Exclusion Lock** — Normative `Mutex` design and
  actor-versus-lock tradeoff.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0433-mutex.md)
- **WWDC21: ARC in Swift — Basics and beyond** — Apple ownership and lifetime
  model relevant to retained task closures and streams.
  [Source](https://developer.apple.com/videos/play/wwdc2021/10216/)
- **Swift Atomics** — Advanced external package for specialized low-level use;
  not the default replacement for actors or `Mutex`.
  [Source](https://github.com/apple/swift-atomics)

## Continuations, sequences, and Foundation

- **CheckedContinuation** — Normative single-result bridge API.
  [Source](https://developer.apple.com/documentation/swift/checkedcontinuation)
- **SE-0314: AsyncStream and AsyncThrowingStream** — Normative event-stream
  bridge design.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0314-async-stream.md)
- **WWDC21: Meet AsyncSequence** — Example sequence, iteration, and cancellation
  model.
  [Source](https://developer.apple.com/videos/play/wwdc2021/10058/)
- **Swift Async Algorithms** — Official package of sequence operators.
  [Source](https://github.com/apple/swift-async-algorithms)
- **AsyncChannel guide** — Producer-consumer and capacity semantics.
  [Source](https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Channel.md)
- **WWDC21: Use async/await with URLSession** — Apple networking integration
  example.
  [Source](https://developer.apple.com/videos/play/wwdc2021/10095/)
- **URLSession bytes(for:delegate:)** — Streaming response API.
  [Source](https://developer.apple.com/documentation/foundation/urlsession/bytes%28for%3Adelegate%3A%29)
- **WWDC21: Swift concurrency — Update a sample app** — Example migration of an
  existing app.
  [Source](https://developer.apple.com/videos/play/wwdc2021/10194/)
- **Updating an app to use Swift Concurrency** — Apple integration guide.
  [Source](https://developer.apple.com/documentation/swift/updating_an_app_to_use_swift_concurrency)
- **WWDC21: Bring Core Data concurrency to Swift and SwiftUI** — Apple
  framework-specific isolation guidance.
  [Source](https://developer.apple.com/videos/play/wwdc2021/10017/)

## SwiftUI and Apple-platform integration

- **WWDC25: Explore concurrency in SwiftUI** — Current SwiftUI, `MainActor`,
  task, and UI-state guidance.
  [Source](https://developer.apple.com/videos/play/wwdc2025/266/)
- **WWDC25: Code-along — Elevate an app with Swift concurrency** — Example
  application of the modern model.
  [Source](https://developer.apple.com/videos/play/wwdc2025/270/)

These are required when the request involves SwiftUI. They are scoped rather
than universal core because server, command-line, and library Swift do not share
SwiftUI's lifecycle and main-actor contracts.

## Migration, diagnostics, and testing

- **WWDC24: Migrate your app to Swift 6** — Apple staged migration example.
  [Source](https://developer.apple.com/videos/play/wwdc2024/10169/)
- **Migration strategy** — Target and dependency-aware migration workflow.
  [Source](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/migrationstrategy/)
- **Common compiler errors** — Migration diagnostic index.
  [Source](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/commonproblems/)
- **Incremental adoption** — Mixed-mode module guidance.
  [Source](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/incrementaladoption/)
- **Enable data-race safety** — Compiler and build-setting guidance.
  [Source](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/enabledataracesafety/)
- **Runtime behavior** — Distinguish compile-time isolation from scheduling.
  [Source](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/runtimebehavior/)
- **Source compatibility** — Language-mode and compatibility guidance.
  [Source](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/sourcecompatibility/)
- **Add @preconcurrency import** — Compiler diagnostic guide for a temporary
  legacy boundary.
  [Source](https://docs.swift.org/compiler/documentation/diagnostics/add-preconcurrency-import/)
- **Testing asynchronous code** — Current Swift Testing async guidance.
  [Source](https://developer.apple.com/documentation/testing/testing-asynchronous-code)
- **ST-0016: Test cancellation** — Versioned Swift Testing cancellation
  behavior.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/testing/0016-test-cancellation.md)

## Legacy and advanced references

- **DispatchQueue** — Legacy/current queue API for interoperability.
  [Source](https://developer.apple.com/documentation/dispatch/dispatchqueue)
- **OperationQueue** — Legacy/current dependencies, readiness, priority, and
  bounded-operation API.
  [Source](https://developer.apple.com/documentation/foundation/operationqueue)
- **Concurrency Programming Guide** — Legacy conceptual queue guidance. Recheck
  all code recommendations against modern Swift sources.
  [Source](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html)
- **Migrating Away from Threads** — Legacy rationale against manual thread
  management.
  [Source](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/ThreadMigration/ThreadMigration.html)
- **SE-0392: Custom actor executors** — Advanced executor integration.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0392-custom-actor-executors.md)
- **SE-0421: Generalize AsyncSequence** — Advanced generic sequence design.
  [Source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0421-generalize-async-sequence.md)

Do not use legacy or advanced sources to bypass structured lifetime, isolation,
or measurement gates. Load them only when the project contains the corresponding
boundary or infrastructure.
