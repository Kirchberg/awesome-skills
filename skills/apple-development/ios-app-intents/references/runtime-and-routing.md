# Runtime modes and UI routing

Make execution location and foreground behavior explicit. A correct intent must
behave predictably when the app is running, suspended, terminated, or invoked
through an extension-capable system surface.

## Contents

- Choose `supportedModes`
- Choose semantic opening behavior
- Centralize the handoff
- Handle lifecycle races
- Preserve background correctness
- Verify routing

## Choose `supportedModes`

Use the selected SDK's current `IntentModes` API:

- `.background` when the action can complete without app UI;
- `.foreground(.immediate)` when app UI is required before work begins;
- `.foreground(.dynamic)` when work can begin in the background and may request
  foreground conditionally;
- `.foreground(.deferred)` when work begins in the background and must enter
  foreground before it completes;
- supported combinations only when both paths are intentionally implemented.

Inspect `systemContext` when runtime behavior legitimately depends on the
current mode. Define the path when foreground continuation is unavailable or
the person declines it.

Use `supportedModes` as the current execution-semantics replacement for
deprecated `openAppWhenRun`. `OpenIntent`, `TargetContentProvidingIntent`, and
schema protocols solve different semantic problems and are not mechanical
replacements for that flag.

When an older deployment target predates `supportedModes`, inspect Apple's
current backward-compatibility guidance. If required, isolate
`openAppWhenRun == true` in the documented explicitly deprecated compatibility
extension, keep it out of an App Intents extension, and verify both old-OS and
current-mode behavior. Do not let that bridge define the new intent design.

## Choose semantic opening behavior

Use a purpose-built opening contract when the action means “open this content”:

- `OpenIntent` for a supported entity or enum destination;
- `URLRepresentableEntity` when one canonical universal link already represents
  the entity and the selected SDK supports the conformance;
- `TargetContentProvidingIntent` or a relevant App Schema only when its current
  stable contract matches the experience;
- a plain intent plus an explicit foreground continuation only when no opening
  protocol fits the action.

`URLRepresentableEntity` uses universal links; do not assume a custom URL scheme
satisfies its contract. Preserve the app's existing universal-link behavior and
security validation.

## Centralize the handoff

Represent a semantic destination independent of a view implementation:

```text
intent input or opened entity
  -> validated semantic destination
  -> app or scene root router
  -> feature-owned route
  -> screen and restored state
```

Reuse this route for App Intents, universal links, Spotlight, notifications, and
ordinary in-app navigation when their semantics match. Validate account scope,
authorization, and object existence at the route boundary.

Avoid:

- global notifications whose consumers depend on launch timing;
- multiple singleton routers mutated by different intents;
- setting a leaf SwiftUI binding before the scene exists;
- parsing the same URL in unrelated layers;
- assuming one active scene on iPadOS, macOS, or visionOS;
- silently falling back to a home screen after promising a precise destination.

## Handle lifecycle races

Define behavior for:

- cold launch versus already-running app;
- no eligible foreground scene;
- multiple windows or scenes;
- route arrival before stores finish restoring;
- entity deletion or account change during transition;
- a second route superseding the first;
- cancellation before and after foreground continuation;
- a background result completing after UI state changed.

Keep a pending semantic destination at one owned boundary when launch ordering
requires it. Consume it exactly once after prerequisites are ready, or return an
explicit failure. Do not encode pending routes as scattered booleans.

## Preserve background correctness

A background intent must not touch APIs that require foreground UI. Keep heavy
work bounded, observe cancellation, and use data stores that are safe in the
actual process. If authentication or permission needs UI, return or request the
designed foreground path rather than presenting from an invalid context.

Do not claim that “the app stays closed” from a unit test. Invoke through the
real system surface with the app not running and record the observed behavior.

## Verify routing

Exercise:

1. app terminated, suspended, backgrounded, and foregrounded;
2. each supported `IntentModes` path;
3. foreground continuation accepted, denied, and unavailable;
4. valid, deleted, unauthorized, and stale entity destinations;
5. universal link and Spotlight opening parity;
6. multiple scenes where the platform supports them;
7. repeated and competing invocations;
8. restoration after app or OS upgrade;
9. old deployment-target fallback;
10. each extension or process that can execute the intent.
