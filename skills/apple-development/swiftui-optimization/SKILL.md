---
name: swiftui-optimization
description: Use when creating, refactoring, reviewing, or diagnosing SwiftUI views and screens where update frequency, body cost, state ownership, Observation, diffing, identity, lists, layout, animation smoothness, hangs, hitches, or Instruments evidence matter. Applies to new SwiftUI code, performance audits, scrolling or animation regressions, and performance-focused code review across Apple platforms. Do not use for purely visual design work, non-SwiftUI rendering, or unsupported claims about undocumented SwiftUI internals.
---

# Build efficient SwiftUI views

## Outcome

Produce correct, maintainable SwiftUI views whose bodies finish quickly and
update only for relevant changes. Treat correctness and evidence as gates:
never trade current actions, state, accessibility, or identity for a smaller
update count.

## Read references selectively

- Read `references/data-flow-and-diffing.md` before choosing state ownership,
  passing model data, introducing `Equatable`, or reasoning about updates.
- Read `references/observation.md` before introducing `@Observable`, migrating
  from `ObservableObject`, or choosing `@State`, `@Bindable`, or environment
  injection for an observable model.
- Read `references/construction-patterns.md` before changing view boundaries,
  lists, layout readers, tasks, images, or animations.
- Read `references/profiling.md` before diagnosing an existing regression or
  claiming a performance improvement.
- Read `references/source-notes.md` when a recommendation is disputed,
  version-sensitive, or based on undocumented behavior.

Repository instructions, supported deployment targets, and established
architecture override generic examples. They do not override the requirement
to preserve correctness and verify performance claims.

## Establish the task

1. Read the repository's root and nearest local instructions.
2. Inspect the deployment targets, Xcode and Swift versions, target platforms,
   existing state model, navigation architecture, and test commands.
3. Classify the request as:
   - new view or screen;
   - behavior-preserving refactor;
   - measured performance diagnosis;
   - performance-focused code review.
4. For an existing issue, record one reproducible interaction, representative
   data volume, affected device and OS, build configuration, and visible
   symptom before editing.
5. Do not redesign unrelated architecture or add optimization machinery without
   a demonstrated need.

## Use the SwiftUI mental model

- Treat a `View` value as a description, not a persistent widget. SwiftUI may
  create view values and evaluate `body` frequently.
- Distinguish `body` evaluation, graph reconciliation, platform rendering, and
  display presentation. A logged `body` call is not proof of a rendered frame
  or a user-visible regression.
- Treat stored inputs, dynamic properties, environment values, and observable
  properties read by the view as dependencies.
- Preserve structural and explicit identity when the same semantic element
  should retain state and animate continuously.
- Create boundaries around coherent dependency sets, not arbitrary line counts.

## Construct the view

1. Define the smallest render contract. Pass a child the values it displays
   instead of an entire feature state or broad store when practical.
2. Choose each state wrapper by ownership and lifetime using
   `references/data-flow-and-diffing.md` and `references/observation.md`; never
   choose a wrapper because it is rumored to "render less."
3. Keep `init` and `body` deterministic and cheap. Move I/O, decoding, large
   filtering or sorting, expensive formatting, and business logic into a model
   or service. Cache derived results with explicit invalidation.
4. Extract a real `struct: View` when a subtree needs an independent update
   boundary. A computed `some View`, helper function, closure, `Group`, or
   `@ViewBuilder` helper does not create that boundary.
5. Keep event sources and frequently changing dependencies in the smallest
   subtree that needs them.
6. Use stable domain identity in `ForEach`, `List`, and `Table`. Precompute
   filtered data and keep the number of top-level rows produced per element
   constant on performance-sensitive lazy paths.
7. Tie asynchronous work to view lifetime with `.task` or `.task(id:)` when
   appropriate. Make work idempotent and cooperatively cancellable, and keep
   CPU-heavy work off the main actor.
8. Scope geometry observation and animation to the presentation they affect.
   Avoid state-layout feedback loops and broad implicit animation.

## Apply targeted optimizations

Prefer simpler fixes in this order:

1. remove unused or overly broad dependencies;
2. pass narrower render values;
3. move repeated work out of `body` and cache it correctly;
4. isolate the affected subtree in a real child view;
5. stabilize collection identity and row shape;
6. reduce high-frequency event, geometry, or animation updates;
7. adopt custom `Equatable` behavior only when profiling still justifies it.

When relying on custom equality:

- compare every value that affects content, layout, styling, accessibility,
  identity, or action semantics;
- exclude a closure or handler only when its stability is an explicit,
  reviewable invariant;
- ensure equality is cheaper than the skipped body work;
- use `.equatable()` when the implementation relies on the custom equality
  boundary, then verify the behavior on supported OS versions;
- remember that Airbnb's `@Equatable` and `@SkipEquatable` are custom macros,
  not SwiftUI APIs.

## Diagnose instead of guessing

1. Reproduce the symptom with the same workload.
2. Profile a representative device and optimized build using the tools
   available in the installed Xcode version.
3. Separate:
   - a long view-body or platform update;
   - many individually short updates;
   - main-thread or Core Animation commit work;
   - render-server CPU or GPU work;
   - memory or I/O outside SwiftUI.
4. Trace the most frequent or expensive cause to application code.
5. Make one minimal correction and repeat the same capture.
6. Reject the change if the metric does not improve reliably or correctness
   changes.

Use `Self._printChanges()` only as temporary, best-effort debug evidence. It is
an underscored API with runtime cost; remove it before shipping.

## Guard against folklore

- Do not use a fresh `UUID()`, mutable index, or non-unique `\.self` as identity.
- Do not assume `LazyVStack` is always faster than `VStack` or `List`.
- Do not assume `AsyncImage` supplies the cache policy the product needs.
- Do not claim `resizable()` down-samples decoded image memory.
- Do not use `@EnvironmentObject`, `@Binding`, `Group`, `AnyView`, or
  `@ViewBuilder` as a generic performance fix.
- Do not ban `GeometryReader`, action closures, `onAppear`, `dismiss`, or
  animations categorically; constrain expensive effects and verify the case.
- Do not encode a framework workaround as a general rule without an OS and SDK
  matrix, a minimal reproduction, and current profiling evidence.
- Do not describe SwiftUI's undocumented diffing internals as an API contract.

## Verify completion

For changed code, require:

- formatting and static analysis used by the repository;
- a build for affected targets and platforms;
- focused tests for state, actions, identity, navigation, and cancellation;
- a review for accidental broad dependencies, unstable IDs, repeated work,
  stale equality, and debug instrumentation.

For a performance claim, also report:

- device, OS, Xcode, build configuration, data volume, and interaction;
- before and after captures from the same scenario;
- whether the bottleneck was long work, frequent work, commit, or render;
- the metric improved and any remaining bottleneck.

Do not claim completion from fewer `body` logs alone.
