# SwiftUI, MainActor, and UI task lifetime

## Contents

- [Model UI ownership](#model-ui-ownership)
- [Keep expensive work out of UI isolation](#keep-expensive-work-out-of-ui-isolation)
- [Tie tasks to view lifetime](#tie-tasks-to-view-lifetime)
- [Update observable state safely](#update-observable-state-safely)
- [Review streams and resources](#review-streams-and-resources)
- [Coordinate with SwiftUI performance work](#coordinate-with-swiftui-performance-work)

## Model UI ownership

Isolate UI-owned mutable state to `MainActor`. This commonly includes view
models, navigation state, presentation state, and adapters that synchronously
touch UIKit or AppKit.

Inspect the selected SwiftUI SDK and module default isolation. Do not assume
that declarations have the same inferred isolation across every supported Xcode
version.

Use actor annotations to express ownership, not as dispatch instructions. Avoid:

- wrapping every mutation in `DispatchQueue.main.async`;
- marking an entire service `@MainActor` because one consumer is a view;
- assuming a value is safe to transfer because it originated on the main
  thread;
- using `Task.detached` as the standard way to leave UI isolation.

## Keep expensive work out of UI isolation

Native asynchronous I/O can start from `MainActor` and suspend without blocking
it. CPU-heavy synchronous work cannot.

Separate:

- UI orchestration and state application on `MainActor`;
- asynchronous I/O behind a `Sendable` service contract;
- deliberate CPU parallelism in a non-UI function or `@concurrent` function
  where the supported toolchain and measured workload justify it.

Pass immutable `Sendable` inputs to independent work and return a compact
`Sendable` result. Do not send mutable UI models to background work.

Audit module-wide default `MainActor` isolation for parsing, image processing,
sorting, compression, database transforms, and other synchronous work that may
accidentally inherit the UI executor.

## Tie tasks to view lifetime

Prefer SwiftUI lifecycle-aware async APIs such as `.task` and
`.task(id:)` when work belongs to a presented view identity. SwiftUI can cancel
those tasks when the view disappears or the identity changes, but the called
operation must still cooperate with cancellation.

Use an unstructured task stored by an observable owner when work belongs to that
owner rather than one transient view presentation. Define:

- whether starting new work cancels previous work;
- who cancels during teardown;
- whether results from stale requests are ignored;
- how errors and cancellation become UI state;
- whether task handles are cleared after completion.

Do not start long-lived tasks from a view initializer or `body`. Repeated view
construction can create duplicate work.

## Update observable state safely

Use a request ID, generation, or explicit state machine for search, refresh, and
navigation-driven loads:

1. record the current request on `MainActor`;
2. await the service;
3. check cancellation;
4. confirm that the request is still current;
5. apply the result as one coherent UI-state transition.

This prevents an older response from overwriting a newer one even though all UI
mutation is actor-safe.

Keep UI state transitions small. Batch related property changes when the
observation model and behavior allow it, but do not conflate concurrency
correctness with view invalidation optimization.

## Review streams and resources

For notifications, location, media, sockets, and other ongoing sources:

- start observation once per intended owner;
- store the task or subscription handle;
- use a bounded or coalescing buffer appropriate for UI freshness;
- cancel and detach observers on termination;
- avoid strengthening `self` across an indefinite `for await` loop;
- confirm that a hidden or replaced screen stops consuming resources.

An infinite sequence can retain its view model even after the UI disappears if
the task and model own each other.

## Coordinate with SwiftUI performance work

Use `$swift-concurrency` to determine actor ownership, task lifetime,
cancellation, streams, and executor use.

Use `$swiftui-optimization` to determine dependency breadth, Observation
registrars, stable identity, body updates, list behavior, layout, animation, and
rendering hitches.

Use `$app-performance` first when the only starting evidence is a user-visible
hang or hitch. Use Instruments to identify whether the cause is main-actor work,
actor contention, a blocked cooperative pool, view updates, layout, rendering,
I/O, or another subsystem before choosing a skill-specific fix.
