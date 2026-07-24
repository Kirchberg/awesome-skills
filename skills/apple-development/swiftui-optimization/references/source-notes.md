# Evidence and source notes

Last reviewed: 2026-07-24.

## Contents

- Evidence hierarchy
- Primary Apple sources
- Production case study
- Community diagnostic collection
- General best-practices article
- Observation explainers

## Evidence hierarchy

Use current Apple documentation and WWDC material as the normative source for
public behavior and tools. Use production case studies for measured techniques,
and community articles for hypotheses, reproductions, and troubleshooting.

Treat any explanation of reflection, memory comparison, AttributeGraph,
prebuilding, or other SwiftUI internals as an implementation model rather than
an API guarantee.

## Primary Apple sources

- [Understanding and improving SwiftUI performance](https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance)
  defines the current Instruments workflow, long versus frequent updates,
  Cause & Effect analysis, and efficient design patterns.
- [Demystify SwiftUI performance — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10160/)
  explains dependency scoping, cheap bodies, identity, and fast paths for
  `List`, `Table`, and `ForEach`.
- [Migrating from ObservableObject to Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
  defines availability, incremental migration, property-level tracking,
  `@ObservationIgnored`, and wrapper replacements.
- [Discover Observation in SwiftUI — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10149/)
  gives Apple's ownership decision tree for `@State`, `@Environment`, and
  `@Bindable`, plus computed-property and collection behavior.
- [Understanding hitches in your app](https://developer.apple.com/documentation/xcode/understanding-hitches-in-your-app)
  defines the render pipeline, commit versus render hitches, stage deadlines,
  variable refresh behavior, and Organizer hitch-rate thresholds.

Recheck these pages when Xcode, SDK, or deployment targets change. The current
SwiftUI Instrument and Cause & Effect workflow is described for Instruments 26;
do not invent unavailable lanes or minimum OS versions.

## Production case study

- [Airbnb — Understanding and improving SwiftUI performance](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896)
  provides an empirical model of stored-property diffing, real child-view
  boundaries, generated equality, and body-complexity linting. Airbnb measured
  15% fewer scroll hitches on one Search screen; do not treat that number as a
  general forecast.

Airbnb's `@Equatable` and `@SkipEquatable` are custom infrastructure. A macro
can check conformance coverage, but it cannot prove that skipping a field is
semantically correct. Their body-complexity limit of 10 is a team heuristic,
not a SwiftUI limit.

## Community diagnostic collection

- [Fatbobman — Optimization and Debugging](https://fatbobman.com/en/collections/optimization-debugging/)
  is a useful map for update mechanisms, lifecycle, Observation, lists, lazy
  containers, layout, and framework bug analysis.
- [How to Avoid Repeating SwiftUI View Updates](https://fatbobman.com/en/posts/avoid_repeated_calculations_of_swiftui_views/)
  illustrates narrow constructor inputs, real child boundaries, event-source
  scope, closures, and equality.
- [A Deep Dive Into Observation](https://fatbobman.com/en/posts/mastering-observation/)
  explains property-level tracking and ownership. Treat internal registrar
  details as explanatory, not contractual.
- [Demystifying SwiftUI List Responsiveness](https://fatbobman.com/en/posts/optimize_the_response_efficiency_of_list/)
  and [Tips for Lazy Containers](https://fatbobman.com/en/posts/tips-and-considerations-for-using-lazy-containers-in-swiftui/)
  provide large-data reproductions and memory caveats.
- [Using equatable() to Avoid NavigationLink Pre-Build](https://fatbobman.com/en/posts/using-equatable-to-avoid-the-navigationlink-pre-build-pitfall/)
  is a version-sensitive workaround based on undocumented behavior. Use only
  after reproducing and profiling the exact issue.

Do not promote individual navigation, `onChange`, animation, Grid, delayed
state, or `.id` workarounds into project-wide rules. Record their tested OS and
SDK matrix and retest them after upgrades.

## General best-practices article

- [Garejakirit — Optimizing SwiftUI Performance](https://medium.com/@garejakirit/optimizing-swiftui-performance-best-practices-93b9cc91c623)
  is useful as a checklist of hypotheses, but several claims require correction.

Do not encode these claims as rules:

- `@ViewBuilder` prevents recomputation;
- `@EnvironmentObject` or `@Binding` is inherently a performance optimization;
- `LazyVStack` is always preferable;
- per-row `onAppear` is inherently wrong;
- `withAnimation` is inherently faster;
- `resizable()`, `aspectRatio`, or `Image(uiImage:)` down-samples image memory;
- `AsyncImage` guarantees the required cache;
- `GeometryReader`, deep nesting, or action closures are inherently slow;
- `Group` is a performance boundary.

Use Instruments and the target SDK's public behavior to accept or reject each
hypothesis.

## Observation explainers

- [Donny Wals — @Observable in SwiftUI explained](https://www.donnywals.com/observable-in-swiftui-explained/)
  clearly distinguishes an owned `@State` model, a borrowed plain property,
  `@Bindable`, and type-based environment injection.
- [Understanding @Observable in iOS 17](https://medium.com/@sayefeddineh/understanding-observable-in-ios-17-the-future-of-swiftui-state-management-9085fe9c3ed8)
  provides migration and Combine interop examples.

Use these as explanatory material, not authority over Apple documentation.
Do not infer that Observation replaces synchronization or every Combine use
case. Do not apply `@ObservationIgnored` to UI-relevant state, and do not
describe large data, computed properties, or internal publishers as
automatically safe to ignore without verifying the resulting dependency graph.
