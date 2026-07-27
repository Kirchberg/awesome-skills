# Evidence and source notes

Last reviewed: 2026-07-27.

## Contents

- Use the evidence hierarchy
- Start with primary SwiftUI sources
- Check scrolling, memory, and responsiveness sources
- Learn from production case studies
- Use focused community reproductions carefully
- Reject folklore and stale conclusions

## Use the evidence hierarchy

Use current Apple documentation and WWDC material as the normative source for
public behavior, availability, and tool interfaces. Use production case studies
for measured techniques, focused community reproductions for hypotheses, and
synthetic benchmarks only for the exact workload they measured.

Treat explanations of reflection, memory comparison, AttributeGraph, row reuse,
prebuilding, or other SwiftUI internals as implementation models rather than
API guarantees. Recheck version-sensitive guidance whenever Xcode, SDK,
deployment targets, or container behavior changes.

Do not add a rule merely because several articles repeat it. Prefer one source
with a reproducible scenario and clear limitations over a long undifferentiated
reading list.

## Start with primary SwiftUI sources

- [Understanding and improving SwiftUI performance](https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance)
  defines the current SwiftUI instrument, long versus frequent updates,
  Cause & Effect analysis, triage thresholds, dependency scoping, and efficient
  design patterns.
- [Optimize SwiftUI performance with Instruments — WWDC25](https://developer.apple.com/videos/play/wwdc2025/306/)
  demonstrates the Instruments 26 workflow, correlating a selected SwiftUI
  update with Time Profiler and narrowing a broad Observation dependency.
  The video says *Representable Updates* where current documentation says
  *Platform View Updates*.
- [Demystify SwiftUI performance — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10160/)
  explains narrow dependencies, cheap bodies, stable identity, real child-view
  boundaries, and fast identification paths for `List`, `Table`, and
  `ForEach`.
- [Demystify SwiftUI — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10022/)
  provides the foundation for identity, lifetime, structural identity, and
  dependencies.
- [Discover Observation in SwiftUI — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10149/)
  and [Migrating from ObservableObject to Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
  define property-access tracking, incremental migration, and the ownership
  roles of `@State`, `@Environment`, and `@Bindable`.
- [TN3211: Resolving SwiftUI source incompatibilities for State and ContentBuilder](https://developer.apple.com/documentation/technotes/tn3211-resolving-swiftui-source-incompatibilities-for-state-and-contentbuilder)
  and [What's new in SwiftUI — WWDC26](https://developer.apple.com/videos/play/wwdc2026/269/)
  document the Xcode 27 `@State` macro, lazy class-value initialization,
  back-deployment, and source-compatibility constraints.
- [AnyView](https://developer.apple.com/documentation/swiftui/anyview)
  provides the narrow public guarantee: changing the wrapped view type destroys
  the old hierarchy and creates a new one. It does not justify a categorical
  ban or a universal performance forecast.

## Check scrolling, memory, and responsiveness sources

- [Dive into lazy stacks and scrolling with SwiftUI — WWDC26](https://developer.apple.com/videos/play/wwdc2026/321/)
  is the primary source for estimated off-screen geometry, stable subview
  cardinality, prefetch before `onAppear`, eventual deletion of off-screen
  state, and programmatic scrolling.
- [Creating performant scrollable stacks](https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks)
  supplements the session. Use the modern performance documentation for the
  current Instruments interface when older screenshots or labels differ.
- [Analyze heap memory — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10173/)
  distinguishes transient growth, persistent growth, abandoned reachable
  memory, and leaks; it demonstrates Allocations, Memory Graph, malloc stack
  logging, closure contexts, and retaining paths.
- [Gathering information about memory use](https://developer.apple.com/documentation/xcode/gathering-information-about-memory-use)
  and [Making changes to reduce memory use](https://developer.apple.com/documentation/xcode/making-changes-to-reduce-memory-use)
  route footprint, heap, graphics, image, and persistence investigations.
- [iOS Memory Deep Dive — WWDC18](https://developer.apple.com/videos/play/wwdc2018/416/)
  remains the primary conceptual source for decoded image cost and Image I/O
  downsampling. Recheck API choices against the current SDK.
- [Understanding hitches in your app](https://developer.apple.com/documentation/xcode/understanding-hitches-in-your-app)
  defines the render loop, commit versus render hitches, variable refresh
  behavior, and current Organizer hitch-rate thresholds.
- [Profile, fix, and verify — WWDC26](https://developer.apple.com/videos/play/wwdc2026/268/)
  introduces useful Instruments 27 additions such as Top Functions, Run
  Comparisons, Swift Executors, and System Trace. Gate them by installed
  toolchain and recording support.

## Learn from production case studies

- [Airbnb — Understanding and improving SwiftUI performance](https://airbnb.tech/web/understanding-and-improving-swiftui-performance/)
  provides a measured production case for stored-input diffing, real child
  boundaries, generated equality, and body-complexity linting. Airbnb measured
  15% fewer scroll hitches on one Search screen; never use that number as a
  general forecast.
- [Emerge Tools — The Memory Leak: An Xcode Detective Story](https://www.emergetools.com/blog/posts/the-memory-leak-an-xcode-detective-story)
  demonstrates a retain-chain investigation through coordinators, Combine,
  nested closures, task capture, `deinit`, and Memory Graph evidence.

Airbnb's `@Equatable` and `@SkipEquatable` are custom macros, not SwiftUI APIs.
A macro can check conformance coverage but cannot prove that skipping a handler
is semantically correct. Emerge's case does not imply that every closure should
capture `self` weakly; it shows why the actual outer retaining edge matters.

## Use focused community reproductions carefully

- [objc.io — Thinking in SwiftUI](https://www.objc.io/books/thinking-in-swiftui/)
  and the [SwiftUI Field Guide](https://www.swiftuifieldguide.com/) provide
  strong mental models for state, identity, view trees, and proposal-response
  layout. The Field Guide's interactive model is explanatory, not the SwiftUI
  implementation.
- [Donny Wals — Using Instruments to profile a SwiftUI app](https://www.donnywals.com/using-instruments-to-profile-a-swiftui-app/)
  is useful for the Profile → physical device → inspection range → Time
  Profiler workflow. It predates the Instruments 26 lanes, so use Apple
  documentation for current labels.
- [Understanding how and when SwiftUI decides to redraw views](https://www.donnywals.com/understanding-how-and-when-swiftui-decides-to-redraw-views/)
  supplies useful experiments, but do not collapse body evaluation, graph
  reconciliation, and presented pixels into the word “redraw.”
- [Phil Zakharchenko — Closures in SwiftUI Environment are Killing Your App's Performance](https://philz.blog/closures-in-swiftui-environment-are-killing-your-apps-performance/)
  is a focused reproduction of environment-action invalidation. Do not copy a
  handler into `@State` without proving that routes and captures cannot become
  stale.
- [Fatbobman — Optimization and Debugging](https://fatbobman.com/en/collections/optimization-debugging/)
  maps update mechanisms, lifecycle, Observation, lists, lazy containers,
  layout, and framework bug investigations.
- [Memory Optimization Journey for a SwiftUI + Core Data App](https://fatbobman.com/en/posts/memory-usage-optimization/)
  is a useful image-and-persistence case study. Do not infer live-object
  retention from process footprint alone or promote its holder and
  `onDisappear` techniques into general rules.
- [Common Pitfalls Caused by Delayed State Updates](https://fatbobman.com/en/posts/serious-issues-caused-by-delayed-state-updates-in-swiftui/)
  supplies reproducible sheet and navigation races. Treat the failure and
  workaround as an OS-specific hypothesis.
- [How to update SwiftUI many times a second while being performant?](https://forums.swift.org/t/how-to-update-swiftui-many-times-a-second-while-being-performant/71249)
  motivates stable identity, batching, latest-value buffering, and
  backpressure. The proposed cadences are workload-specific.
- [SwiftUI and AnyView: Performance benchmarks](https://forums.swift.org/t/swiftui-and-anyview-performance-benchmarks/65717)
  demonstrates that type-erasure cost depends strongly on placement and scale.
- [SwiftLee — Memory consumption when loading UIImage from disk](https://www.avanderlee.com/swiftui/memory-consumption-loading-uiimage-from-disk/)
  is a practical system-cache case; prefer Apple image and memory sources for
  normative behavior.
- [STRV — SwiftUI: List vs LazyVStack](https://www.strv.com/blog/swiftui-list-vs-lazyvstack)
  is a scoped iPhone 15 Pro / iOS 17.5.1 synthetic experiment with
  image-intensive rows. It supports measuring the target workload, not
  declaring one container universally faster or relying on its implementation
  explanation.

## Reject folklore and stale conclusions

Do not encode these claims as rules:

- `@ViewBuilder` or `Group` creates an update boundary;
- `@EnvironmentObject` or `@Binding` is inherently a performance optimization;
- `LazyVStack` or `List` is always faster or has a permanent reuse contract;
- lazy construction guarantees immediate resource eviction or durable row
  state;
- per-row `onAppear`, `GeometryReader`, `AnyView`, or an action closure is
  inherently wrong;
- `withAnimation` is inherently faster;
- `resizable()`, `aspectRatio`, or `Image(uiImage:)` down-samples image memory;
- `AsyncImage` defines the product's complete cache and downsampling policy;
- `[weak self]` anywhere in a nested closure chain breaks the retaining edge;
- fewer `body` evaluations prove faster frames or lower memory.

Do not promote a navigation, `.id`, `.equatable()`, geometry, delayed dispatch,
or state-lifetime workaround into a project-wide pattern. Record the minimal
reproduction, OS and SDK matrix, correctness invariant, and before-and-after
evidence, then remove the workaround when the underlying behavior changes.
