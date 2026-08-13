# Views, lifecycle, and state

## Construct once

Choose an initializer contract deliberately. For programmatic views, create the
stable hierarchy, constraints, gestures, and targets once from initialization.
For nib or storyboard views, keep setup compatible with `awakeFromNib` and outlet
availability. Implement required coder initializers or make unsupported creation
fail explicitly according to repository convention.

For view controllers, use `loadView()` only when owning programmatic root-view
creation. Do not read `view` from `loadView()` before assigning it. Use
`viewDidLoad()` for one-time wiring after the hierarchy exists, not for work that
must repeat on every appearance or trait change.

Keep `translatesAutoresizingMaskIntoConstraints` intentional. Avoid generating
the same active constraint set, target, gesture recognizer, sublayer, or observer
from `layoutSubviews()`, `updateConfiguration(using:)`, `updateProperties()`, a
cell provider, or another repeatable callback.

## Render state idempotently

Define one state-to-view update path. Assign all relevant visible properties for
every state, including text, image, visibility, enabled state, selection, focus,
accessibility values, background, accessories, and progress. Reset values that
may be absent; do not assume a new instance or a particular prior state.

Use `UIConfigurationState`, `UIViewConfigurationState`, or
`UICellConfigurationState` when appearance depends on traits, highlight,
selection, focus, disabled state, or custom state keys. Override
`updateConfiguration(using:)` or install one configuration update handler and
derive the result from the supplied state. Avoid accumulating side effects in
configuration updates.

Use `UIContentConfiguration` and `UIContentView` for reusable content that needs
configuration semantics. Make `supports(_:)` honest, update compatible content
in place, and replace the content view when the configuration type is incompatible.

## Own actions and callbacks

Use one owner for each action. Prefer `UIAction` where supported and consistent
with the project; otherwise keep target-action wiring one-time and testable.
Avoid registering both a primary action and a duplicate target for the same
intent. Capture owners weakly only when a strong capture would form a cycle;
do not use weak references reflexively when the callback must keep a short-lived
operation alive.

Choose delegates for multi-method behavioral contracts, closures for narrow
events, and the responder chain for commands that should travel through UI
ownership. Document whether a callback is synchronous, repeatable, cancellable,
and main-actor isolated.

## Bound lifetime and reuse

Start observation and work no earlier than its owner can use results. Stop or
supersede it when the component disappears, changes represented identity, is
reused, is removed from its parent, or the owning scene disconnects, according
to the real contract. Remove manual notifications and key-value observations
symmetrically. Invalidate timers and display links.

For reusable views, cancel identity-bound work and clear transient presentation
state during reconfiguration or reuse. Do not rely on `prepareForReuse()` being
the only place that makes configuration correct. Make every configuration pass
stand alone.

Avoid work in `deinit` that must happen deterministically earlier. Verify that
closures, delegates, child controllers, observations, tasks, and presentation
controllers do not create unintended ownership cycles.
