# Ranked Swift and iOS performance sources

Last reviewed: 2026-07-27.

## Contents

- How to use this ranking
- Start here
- Compiler, ownership, and modern storage
- Collections, algorithms, and text
- Measurement and concurrency
- Adjacent iOS and low-level topics
- Narrow discussion sources
- Refresh rules

## How to use this ranking

These 48 sources are ranked by practical value for source-level Swift
performance work in an iOS app, not by author prestige. Scores combine authority,
iOS applicability, explanatory depth, actionability, and currency as defined in
`methodology.md`.

Use Apple and Swift primary sources for behavior and tools. Use Swift Forums only
for narrow interpretation, then verify the current compiler. An older
foundational source can remain useful while its specific optimization advice is
outdated.

## Start here

- **100/100** — [Improve memory usage and performance with Swift — WWDC25](https://developer.apple.com/videos/play/wwdc2025/312/) — Best single source for algorithms, allocations, exclusivity, stack and heap, ARC, `InlineArray`, and `Span`.
- **99/100** — [Explore Swift performance — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10217/) — Current mental model for calls, allocation, layout, copies, async functions, closures, and generics.
- **98/100** — [Improving your app's performance](https://developer.apple.com/documentation/xcode/improving-your-app-s-performance) — Normative measurement-first framing and device evidence; use `app-performance` for the full app-level workflow.
- **98/100** — [Analyze heap memory — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10173/) — Modern treatment of transient growth, autorelease pools, reachability, closure contexts, weak and unowned references, and ARC overhead.
- **96/100** — [Profile, fix, and verify: Improve app responsiveness with Instruments — WWDC26](https://developer.apple.com/videos/play/wwdc2026/268/) — Excellent Release-profile-compare loop; Instruments 27 features are preview and version-gated as of this review.
- **95/100** — [Optimize CPU performance with Instruments — WWDC25](https://developer.apple.com/videos/play/wwdc2025/308/) — Connects source abstractions to CPU behavior; Processor Trace requires supported recent hardware and is not the primary path for older iPhones.
- **94/100** — [ARC in Swift: Basics and beyond — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10216/) — Strong explanation of object lifetime, observable lifetime, and safe lifetime control.
- **94/100** — [The Swift Programming Language: Automatic Reference Counting](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/) — Normative ownership, cycle, weak, unowned, and closure-capture foundation.
- **93/100** — [The Swift Programming Language: Properties](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/) — Normative source for stored versus computed properties and lazy exactly-once stored type-property initialization.
- **92/100** — [The Swift Programming Language: Memory Safety](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/memorysafety/) — Normative exclusive-access model and the safety boundary around `inout` and mutation.
- **80/100** — [Understanding Swift Performance — WWDC16](https://developer.apple.com/videos/play/wwdc2016/416/) — Foundational allocation, ARC, dispatch, struct/class, protocol, and generic model; refresh concrete advice against WWDC24–26.
- **68/100** — [Writing High-Performance Swift Code](https://github.com/swiftlang/swift/blob/main/docs/OptimizationTips.rst) — Useful advanced hypotheses, but explicitly aimed at compiler and standard-library developers and warns that some tips are temporary or unprincipled.

## Compiler, ownership, and modern storage

- **90/100** — [Swift 6.2 Released](https://www.swift.org/blog/swift-6.2-released/) — Authoritative introduction of `InlineArray`, `Span`, and strict memory-safety tooling; Swift 6.2 is the introduction point, not the latest release.
- **90/100** — [InlineArray](https://developer.apple.com/documentation/swift/inlinearray) — Defines fixed-size inline storage, eager copying, bounds checks, and the fact that class-owned storage remains within the class allocation.
- **90/100** — [Span](https://developer.apple.com/documentation/swift/span) — Defines a non-owning, nonescaping, bounds-checked view into initialized contiguous memory.
- **88/100** — [SE-0453: Vector, a fixed-size array](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0453-vector.md) — Design rationale and tradeoffs behind the type exposed as `InlineArray`.
- **88/100** — [SE-0447: Span](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0447-span-access-shared-contiguous-storage.md) — Design and lifetime model for safe shared contiguous access.
- **87/100** — [Embrace Swift generics — WWDC22](https://developer.apple.com/videos/play/wwdc2022/110352/) — Explains opaque types, existentials, generics, and where specialization can preserve abstraction performance.
- **84/100** — [Consume noncopyable types in Swift — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10170/) — Useful for explicit ownership and avoiding semantically invalid copying under a current compatible toolchain.
- **82/100** — [Library Evolution in Swift](https://www.swift.org/blog/library-evolution/) — Essential context for resilience, public layout, dispatch, and why cross-module optimization is an API tradeoff.
- **82/100** — [Swift 5.10 Released](https://www.swift.org/blog/swift-5.10-released/) — Useful concurrency-safety context for global and static mutable state; `nonisolated(unsafe)` is not a performance fix.
- **78/100** — [Whole-Module Optimization in Swift](https://www.swift.org/blog/whole-module-optimizations/) — Clear specialization and visibility explanation, but the 2016 build defaults and performance figures are historical.

## Collections, algorithms, and text

- **90/100** — [Array](https://developer.apple.com/documentation/swift/array) — Canonical growth, contiguous-storage, bridging, operation, and complexity reference.
- **88/100** — [Array.reserveCapacity](https://developer.apple.com/documentation/swift/array/reservecapacity%28_%3A%29-8lw3t) — Explains avoiding known growth reallocations and warns that repeated small reservations can defeat geometric growth.
- **88/100** — [Meet the Swift Algorithms and Collections packages — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10256/) — Practical selection of lazy chains, subsequences, algorithms, `Deque`, and ordered collections without treating them as universal replacements.
- **87/100** — [Introducing Swift Collections](https://www.swift.org/blog/swift-collections/) — Data-structure rationale and measured `Deque`, `OrderedSet`, and `OrderedDictionary` tradeoffs.
- **86/100** — [UTF-8 String](https://www.swift.org/blog/utf8-string/) — Deep explanation of native string storage, small strings, bridging, and byte-level processing; recheck API details on the current Swift version.
- **85/100** — [Announcing Swift Algorithms](https://www.swift.org/blog/swift-algorithms/) — Good source for replacing custom multi-pass code with tested sequence and collection operations.
- **84/100** — [Array.removeAll(keepingCapacity:)](https://developer.apple.com/documentation/swift/array/removeall%28keepingcapacity%3A%29-6xw8v) — Documents capacity reuse as a request and its intended repeated-growth use case.
- **83/100** — [Swift Collections repository](https://github.com/apple/swift-collections) — Current package documentation, implementations, benchmarks, release notes, and supported toolchains.
- **82/100** — [Swift Algorithms repository](https://github.com/apple/swift-algorithms) — Current algorithms, complexity documentation, examples, and release compatibility.
- **75/100** — [ContiguousArray](https://developer.apple.com/documentation/swift/contiguousarray) — Relevant mainly for class or `@objc` protocol elements without `NSArray` bridging; Apple expects similar efficiency to `Array` for structs and enums.

## Measurement and concurrency

- **94/100** — [Writing and running performance tests](https://developer.apple.com/documentation/xcode/writing-and-running-performance-tests) — Primary Xcode workflow for repeatable iOS performance tests and device-specific baselines.
- **93/100** — [Analyzing CPU profiles with call tree views](https://developer.apple.com/documentation/xcode/analyzing-cpu-profiles-with-call-tree-views) — Current call tree, flame graph, Top Functions, signpost, and matched run-comparison guidance.
- **88/100** — [Swift concurrency: Behind the scenes — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10254/) — Best mental model for cooperative execution, task scheduling, actor work, and avoiding thread-blocking assumptions.
- **87/100** — [Visualize and optimize Swift concurrency — WWDC22](https://developer.apple.com/videos/play/wwdc2022/110350/) — Practical task and actor profiling; tool lanes depend on installed Instruments.
- **87/100** — [The Swift Programming Language: Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/) — Normative structured task, actor, isolation, cancellation, and execution semantics.
- **87/100** — [Preventing memory-use regressions](https://developer.apple.com/documentation/xcode/preventing-memory-use-regressions) — XCTest memory metrics and repeatable memory regression strategy for iOS targets.
- **82/100** — [Analyzing CPU usage with Processor Trace](https://developer.apple.com/documentation/xcode/analyzing-cpu-usage-with-processor-trace) — Exact instruction and call-flow analysis on supported Apple hardware; use Time Profiler on unsupported older devices.
- **82/100** — [Introducing the Benchmark Package](https://www.swift.org/blog/benchmarks/) — Useful community benchmark harness for pure portable algorithms, strongest on its supported macOS and Linux surfaces; not a replacement for iPhone XCTest or Instruments.

## Adjacent iOS and low-level topics

- **91/100** — [Reducing your app's memory use](https://developer.apple.com/documentation/xcode/reducing-your-app-s-memory-use) — Current Apple memory investigation and reduction collection; route whole-app footprint work to `app-performance`.
- **90/100** — [Detect and diagnose memory issues — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10180/) — Strong bridge from footprint symptoms to Xcode and Instruments evidence.
- **89/100** — [Making changes to reduce memory use](https://developer.apple.com/documentation/xcode/making-changes-to-reduce-memory-use) — Practical image, cache, Core Data, and lifecycle remedies after evidence.
- **85/100** — [iOS Memory Deep Dive — WWDC18](https://developer.apple.com/videos/play/wwdc2018/416/) — Still valuable for dirty/compressed memory, decoded image cost, downsampling, and cache tradeoffs; some tools are historical.
- **84/100** — [Safely manage pointers in Swift — WWDC20](https://developer.apple.com/videos/play/wwdc2020/10167/) — Strong pointer lifetime, binding, typed/raw memory, and safety prerequisite for a measured low-level path.
- **83/100** — [Introducing Accelerate for Swift — WWDC19](https://developer.apple.com/videos/play/wwdc2019/718/) — Authoritative accelerated vector, DSP, linear algebra, and image-processing introduction; benchmark current APIs and input sizes.

## Narrow discussion sources

- **76/100** — [Static var vs static let](https://forums.swift.org/t/static-var-vs-static-let/59215) — Concise correction that stored versus computed is the central distinction; TSPL remains normative.
- **70/100** — [Static let vs static computed property optimization differences](https://forums.swift.org/t/static-let-vs-static-computed-property-optimization-differences/32923) — Useful compiler-context discussion, but optimized output is version- and call-site-dependent.

## Refresh rules

- Recheck the Apple performance collection, current Swift release notes, and
  WWDC pages after each major Xcode or Swift release.
- Mark Instruments 27-only features as preview until the matching stable Xcode
  ships.
- Keep `InlineArray` and `Span` described as introduced in Swift 6.2; verify
  compiler, SDK, and deployment availability for each project.
- Re-run current compiler experiments before preserving advice from WWDC16,
  whole-module optimization articles, or `OptimizationTips.rst`.
- Keep forum sources subordinate to the Swift book, accepted proposals, current
  API docs, and measured optimized output.
- Add a source only when it contributes a distinct mechanism, tool, or
  production decision. Do not inflate the list with mirrors or generic tip
  articles.
