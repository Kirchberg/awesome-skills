# Intent design

Design App Intents as durable system contracts. Optimize for clear standalone
actions that compose in Shortcuts and behave predictably with or without a
screen.

## Contents

- Model the action
- Choose parameters deliberately
- Keep execution thin
- Define effect safety
- Design results and errors
- Review the design

## Model the action

Use this sequence:

1. State the user-visible verb and outcome.
2. Identify the smallest required inputs.
3. Decide whether the result is no value, a value, dialog, snippet, an opened
   destination, or a supported combination.
4. Define authorization, confirmation, cancellation, retry, and error behavior.
5. Select execution modes and a specialized protocol only after the behavior is
   explicit.

Prefer a system-defined App Schema when the action and content genuinely match
the schema available in the selected stable SDK. Let Xcode generate or validate
the required shape. Do not force a domain action into a nearby schema merely to
gain discoverability.

Use a specialized protocol when it describes the semantic outcome, such as
opening content or showing in-app search results. Otherwise use `AppIntent`.
Check current SDK conformances instead of maintaining a remembered protocol
list.

## Choose parameters deliberately

- Include only information the action actually needs.
- Prefer framework value types for common concepts when they preserve meaning.
- Use an `AppEntity` for durable app content and an `AppEnum` for a small fixed
  choice set.
- Keep a parameter optional only when the action has a deterministic useful
  default or the system can legitimately ask later.
- Use defaults that remain safe across Siri, Shortcuts, widgets, controls, and
  background execution.
- Include required parameters without defaults in `parameterSummary`, and
  verify Spotlight and Shortcuts presentation on the selected OS.
- Preserve published parameter names, types, optionality, and semantics unless
  a deliberate migration is in scope.

Do not use hidden singleton state as an implicit parameter. A shortcut must not
silently depend on whichever screen happened to be open.

## Keep execution thin

Use this boundary:

```text
resolved intent input
  -> domain use case or application service
  -> repository, persistence, or API
  -> domain result
  -> IntentResult, dialog, snippet, or semantic destination
```

Keep domain validation and authorization in the domain layer. Let the intent
translate system values, request confirmation, select an execution path, and
map errors and results. Do not duplicate business rules in `perform()`.

Register services through App Intents dependency infrastructure. Avoid creating
a second database stack, networking stack, or business workflow inside an
intent solely because the system may launch it out of process.

## Define effect safety

For every write or external effect, decide:

- whether repeated invocation is safe;
- whether a unique operation token or domain idempotency key is needed;
- which state must be re-read before committing;
- whether a retry can duplicate a payment, message, upload, or mutation;
- where cancellation is observed and what cleanup it guarantees;
- what happens if the app transitions to foreground mid-operation;
- whether confirmation is required and what exact effect it describes.

Confirm destructive, expensive, privacy-sensitive, or difficult-to-reverse
actions near the effect. Do not use confirmation as a substitute for clear
parameters or authorization.

## Design results and errors

- Return the value another shortcut can use when composition is valuable.
- Keep dialogs concise and meaningful without visual context.
- Use a snippet only when compact visual or interactive content materially
  improves completion.
- Open the app only when the user outcome requires app UI, not as a generic
  success signal.
- Map domain failures into actionable intent errors or dialogs without leaking
  secrets, internal identifiers, stack traces, or server internals.
- Distinguish missing content, logged-out state, denied permission, offline
  state, invalid input, conflict, cancellation, and transient failure.

Never report success before a committed effect or durable handoff. Never turn
cancellation into an unknown error if the domain can preserve cancellation.

## Review the design

Reject or revise an intent when it:

- mirrors a screen instead of a user outcome;
- exposes a broad mutable model with unclear privacy;
- needs an unbounded catalog fetch for resolution;
- changes meaning depending on incidental app navigation state;
- performs a long or fragile workflow without progress, cancellation, or a
  stable handoff;
- opens the app because execution semantics were not designed;
- duplicates domain logic or bypasses authorization;
- cannot be verified on every promised system surface.
