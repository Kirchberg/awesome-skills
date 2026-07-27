# SwiftUI construction patterns

## Contents

- Keep initialization and body work cheap
- Scope event and observation sources
- Coordinate presentation and navigation state
- Control layout dependencies
- Scope animation work
- Keep version-specific workarounds quarantined

## Keep initialization and body work cheap

Keep `View.init` and `body` limited to inexpensive value construction. Move out:

- synchronous network or disk I/O;
- image decoding and resizing;
- large filtering, sorting, grouping, or aggregation;
- repeated formatter construction or expensive string generation;
- bundle searches and repeated reference allocations;
- business rules and persistence mutations.

Prepare derived state in a model or service. Recompute it when relevant inputs
change, cache it with an explicit invalidation key, and publish only the value
the UI needs. Making a function `async` does not move CPU work off the main
actor by itself.

Treat `onAppear`, `.task`, gesture callbacks, geometry callbacks, and other
event closures as repeatable. Make loads idempotent, coalesce duplicate
requests, and honor cancellation.

Use `.task(id:)` when the input defines the work identity:

```swift
.task(id: productID) {
    await model.loadProduct(id: productID)
}
```

Ensure `loadProduct` checks cancellation and does not publish a stale result for
an old ID. Treat `CancellationError` as expected lifecycle behavior, not as a
user-facing failure. Do not replace a view-scoped task with an untracked
unstructured task merely to keep work alive.

## Scope event and observation sources

Place timers, notifications, scroll geometry, focus, scene values, and
high-frequency observable data in the smallest child that uses them. Remove
unused dynamic-property declarations; legacy environment or observable objects
can invalidate a view even when the displayed content is unrelated.

For static generic child content, evaluate a nonescaping builder during each
container initialization and store the resulting `Content` value instead of
retaining the builder for later invocation. A `View` initializer can still run
many times. This rule does not ban action closures or parameterized collection
closures.

## Coordinate presentation and navigation state

Give each sheet, popover, navigation path, and selection one authoritative
owner. Do not drive the same transition by mutating a path or binding and
calling `dismiss()` independently.

Interactive sheet dismissal and back gestures have updated their associated
state after the visual transition on some framework releases. Do not assume
that presentation, gesture, and bound state become final in the same callback.

- When application state owns the route, mutate that state through its binding
  or path.
- When the presented context owns only the act of dismissal, use the
  environment action and observe the authoritative state transition separately.
- Sequence dependent work from a public completion or an observed state
  transition when the supported OS provides one.
- Test rapid dismiss-then-back, back-while-scrolling, cancellation, and
  interactive gesture paths on the deployment matrix.

Do not repair a race with an arbitrary `asyncAfter`, duplicate path mutation,
or disabled gesture unless a minimal reproduction and OS-specific test justify
that workaround.

## Control layout dependencies

`GeometryReader`, `ScrollViewReader`, custom `Layout`, and geometry callbacks
are tools, not automatic defects. Problems arise when a broad subtree observes
layout or when geometry writes state that triggers another layout.

- Isolate the reader around the smallest affected subtree.
- Transform raw geometry into a small `Equatable` value.
- Update state only for a meaningful change or threshold.
- Keep unrelated state outside the layout-dependent subtree.
- Use a minimal reproduction and the proposal → required size → placement
  model before adding workaround frames.

Apply `geometryGroup()` or a custom layout only for a demonstrated geometry or
animation continuity problem, not as a generic optimization modifier.

## Scope animation work

- Preserve identity for elements that should animate continuously.
- Use `.animation(_:value:)` or a scoped animation declaration near the
  changing presentation.
- Use `withAnimation` when several state changes intentionally share one
  transaction.
- Avoid broad implicit animations that cause unrelated layout or drawing work.
- Keep `Animatable` calculations cheap because interpolation runs repeatedly.
- Diagnose animation smoothness with hitch evidence, not `body` counts.

If the app commits on time but the render server misses presentation, inspect
visual complexity, overdraw, blending, masks, shadows, filters, and image size
as hypotheses. Confirm them with rendering tools before simplifying visuals.

## Keep version-specific workarounds quarantined

Do not generalize a workaround involving `.equatable()` around
`NavigationLink`, artificial `.id` changes, delayed dispatch, empty
`onChange`, custom navigation-controller delegates, or layout wrappers.

Before adopting one:

1. reproduce the exact symptom;
2. record the OS, SDK, device, and container;
3. create a minimal example;
4. verify the workaround and its correctness;
5. retest when the deployment or SDK matrix changes;
6. remove it when the underlying framework issue is fixed.
