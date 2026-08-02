# Widgets, controls, Action buttons, and snippets

Reuse domain actions across system surfaces while respecting each surface's
process, presentation, and latency contract. An intent that works in Shortcuts
is not automatically correct in a widget, control, Live Activity, Action
button, or snippet.

## Contents

- Share the domain action, not UI state
- Widgets and Live Activities
- WidgetKit controls and Action buttons
- Static and interactive snippets
- Preserve concurrency and process safety
- Validate each promised surface

## Share the domain action, not UI state

Keep the surface adapter thin:

```text
system surface -> App Intent -> domain service -> durable state -> refreshed UI
```

Persist the authoritative state before `perform()` reports success. Let WidgetKit
or the surface's supported reload mechanism observe that state. Do not make a
view-model singleton the source of truth across processes.

## Widgets and Live Activities

For `Button(intent:)`, `Toggle(intent:)`, and interactive configuration:

- verify the intent is available to the widget or Live Activity target;
- define shared-container and write ownership explicitly;
- keep the action brief and cancellation-aware;
- make repeated taps, delayed refresh, and retry safe;
- preserve old widget parameter names and types during SiriKit migration;
- handle optimistic presentation and rollback only through supported state
  contracts;
- test when the main app has never launched after install and when it is not
  running.

Do not mutate a timeline entry in memory and assume the durable model changed.

## WidgetKit controls and Action buttons

Treat Control Center, Lock Screen, menu bar, and Action button controls as
WidgetKit surfaces with their own configuration and value contracts. Use the
intent protocol the selected SDK requires, including value-setting semantics
for toggles.

Verify availability, device eligibility, authorization, locked-device behavior,
and target membership. Do not conflate an App Shortcut selectable by an Action
button with a custom WidgetKit control.

Apple Watch Ultra workout and dive actions have specialized intent protocols
and execution restrictions. Inspect the current SDK and device documentation;
do not place a specialized action in an App Intents extension when Apple
forbids that placement.

## Static and interactive snippets

Use a snippet when a compact visual result, confirmation, or supported
interaction improves the outcome beyond dialog alone. Keep it readable without
the full app context, localized, accessible, and within current HIG sizing.

Assume `SnippetIntent.perform()` may run repeatedly as the person interacts:

- re-read authoritative state on each execution;
- make mutations idempotent or otherwise duplicate-safe;
- return a view that reflects committed state;
- keep Button and Toggle follow-up intents thin;
- handle stale entities, authorization changes, and failed writes;
- avoid long work, unbounded lists, app navigation chrome, and dense screens;
- provide a precise app route when more content is necessary.

Treat the 400-point HIG maximum and smaller design recommendations as different
constraints: remain under the hard maximum and prefer a compact layout that
does not need scrolling.

## Preserve concurrency and process safety

- Do not assume execution occurs on the main actor or main queue.
- Isolate actual UI mutation to the appropriate actor and route boundary.
- Pass stable IDs and `Sendable` values between isolation domains.
- Keep database contexts, observable UI objects, and mutable caches owned by
  their valid process and actor.
- Bound duplicate invocations and rapid taps at the domain effect, not only in
  the visual control.
- Use `$swift-concurrency` for task lifetime, actor isolation, or cancellation
  defects while preserving this surface contract.

## Validate each promised surface

For every surface in scope, verify:

1. discovery and configuration;
2. target and extension execution;
3. app-running and app-terminated behavior;
4. locked, logged-out, denied, offline, and stale-data states;
5. rapid repeat, cancellation, retry, and duplicate safety;
6. durable state before success presentation;
7. correct reload or refresh;
8. localization, Dynamic Type, VoiceOver semantics, contrast, and Reduce Motion
   where the surface displays custom UI;
9. oldest supported OS fallback and newest stable OS path;
10. physical-device behavior for device-only surfaces.

Do not generalize evidence from Shortcuts to a widget or from Simulator to an
Action button available only on physical hardware.
