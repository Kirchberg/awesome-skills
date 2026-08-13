# UIKit component methodology

## Start with repository evidence

Inspect the nearest instructions, deployment target, selected Xcode and SDK,
dependency graph, navigation and presentation owners, design tokens, reusable
views, tests, and supported device matrix. Search all construction and mutation
sites for the component before changing its public contract.

Classify evidence explicitly:

- **Repository fact**: source, configuration, tests, or runtime behavior observed
  in the target project.
- **Platform fact**: current Apple documentation, generated SDK interface, or a
  relevant Apple session with its OS and SDK context.
- **Design judgment**: a reversible recommendation supported by the component's
  user goal and existing product language.
- **Unknown**: a behavior that still requires a product decision, device run,
  trace, or supported-OS check.

Prefer current Apple documentation and generated SDK interfaces. Use archived
Apple guides for durable concepts and history, not current availability. Treat
community examples as leads to verify, not as platform contracts.

## Trace one complete interaction

Follow a representative input from its source through target-action, delegate,
closure, responder chain, or gesture recognizer into state mutation and the next
render. Then trace dismissal, cancellation, reuse, scene transition, and owner
deallocation. Look for duplicated owners, stale callbacks, retain cycles,
unbounded observers, inconsistent error paths, and UI work outside the main actor.

For a visual defect, trace constraints, intrinsic size, priorities, trait reads,
safe-area or keyboard guides, and the layout invalidation path. For stale content,
trace identity and every configuration pass before adding another reload.

## Choose the smallest responsible component

Prefer, in order:

1. Configure an existing system control or container.
2. Compose system views into a small `UIView` or `UIViewController`.
3. Add a custom content configuration or narrowly reusable control.
4. Add custom drawing, layout, container behavior, or gesture semantics only
   when system APIs cannot express the required interaction.

Do not extract a component merely to shorten a file. Extract when it creates a
cohesive responsibility, reusable behavior, independently testable state, or a
clear lifecycle boundary. Keep domain rules outside the view layer.

## Separate fixes from migrations

Fix a local correctness defect without opportunistically migrating the entire
screen. For a migration, define behavior parity, supported-OS fallback, staged
call sites, deletion criteria, and rollback. Preserve restoration, analytics,
deep links, accessibility identifiers, focus, and automation hooks unless their
contract is intentionally changed.

## Guard claims

Use source evidence to prove a deterministic lifecycle, identity, or layout
defect. Measure claims about smoothness, launch time, CPU, memory, power, or
rendering under matched conditions. Label a source-proven correction as such;
do not relabel it a measured performance improvement.
