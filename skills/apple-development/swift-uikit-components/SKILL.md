---
name: swift-uikit-components
description: Use when designing, implementing, refactoring, reviewing, or diagnosing reusable UIKit views, controls, and view-controller components in Swift. Apply to UIView and UIViewController lifecycle, system controls and configurations, actions, menus, input and focus, Auto Layout, intrinsic sizing, traits, Dynamic Type, adaptivity, containment, navigation, sheets and popovers, table and collection components, UIKit-SwiftUI interoperability, accessibility and localization baselines, testing, and API availability. Trigger for UIKit component requests, programmatic UIKit screens, custom controls, reusable view architecture, layout bugs, stale configuration state, presentation defects, or incremental SwiftUI adoption. Do not use as the lead for a pure SwiftUI screen, an app-wide unknown performance symptom, motion-specific work, or deep concurrency, playback, RTL, accessibility, or Liquid Glass work.
---

# Build robust UIKit components

## Outcome

Turn a UIKit request into a system-first component with explicit ownership,
idempotent state updates, correct containment and presentation, adaptive layout,
bounded lifetime, and verification proportionate to the claim. Preserve the
target project's deployment range and established architecture unless the user
authorizes a broader migration.

## Read references selectively

- Read `references/methodology.md` before planning, reviewing, diagnosing, or
  changing a UIKit component.
- Read `references/views-lifecycle-and-state.md` for view construction,
  configuration state, reuse, event wiring, ownership, and teardown.
- Read `references/layout-and-adaptivity.md` for Auto Layout, intrinsic size,
  safe areas, traits, Dynamic Type, resizing, scenes, and keyboard avoidance.
- Read `references/controls-actions-and-input.md` for system controls, button and
  content configurations, actions, menus, pickers, focus, and unavailable states.
- Read `references/controllers-and-presentation.md` for view-controller
  responsibilities, containment, navigation, sheets, popovers, and restoration.
- Read `references/lists-and-collections.md` for table and collection selection,
  diffable identity, registrations, configuration, layout, reuse, and prefetching.
- Read `references/swiftui-interoperability.md` for `UIHostingController`,
  `UIHostingConfiguration`, state ownership, sizing, and migration boundaries.
- Read `references/testing-and-evidence.md` before approving a component,
  reporting runtime quality, or adding regression coverage.
- Read `references/sources.md` when guidance is disputed, version-sensitive, or
  needs primary-source support.

Repository instructions, the existing design system, deployment targets, and
the user's explicit scope override generic examples. They never weaken lifecycle,
accessibility, localization, data-integrity, or evidence requirements.

## Route the request

- Lead with this skill for a reusable UIKit view, control, cell, header, view
  controller, container, presentation, or programmatic UIKit screen.
- Use `$apple-platform-design` first when the product flow, navigation model,
  information hierarchy, or system-versus-custom component choice is unresolved.
- Use `$app-performance` first for launch, hangs, hitches, CPU, memory, or power
  symptoms whose responsible subsystem is unknown; return here after evidence
  identifies a UIKit component.
- Use `$swift-animation` for transitions, gesture-driven motion, interruption,
  springs, Core Animation, or Reduce Motion behavior beyond ordinary state updates.
- Use `$swift-concurrency` when tasks, cancellation, isolation, `Sendable`, or
  asynchronous ownership materially determine correctness.
- Use `$voice-over-accessibility` or `$swift-rtl-support` for a dedicated audit or
  deep remediation; keep their baseline concerns in every component.
- Use `$ios-liquid-glass` for Liquid Glass adoption, review, or fallbacks.
- Use `$swiftui-optimization` when hosted SwiftUI content has Observation,
  identity, layout, scrolling, or update-cost problems.

## Choose the working mode

- **Design**: define responsibilities, public state and actions, component and
  layout choices, availability, and validation without editing unless requested.
- **Review**: report prioritized correctness, lifecycle, layout, accessibility,
  and maintainability findings without implementing unless requested.
- **Diagnose**: reproduce a named defect and support its cause; fix it only when
  the request also authorizes a correction.
- **Implement**: make the smallest coherent in-scope change and verify it.
- **Migrate**: replace an obsolete or custom path incrementally while preserving
  behavior, deployment compatibility, and a rollback boundary.

Treat requests to build, implement, fix, improve, or refactor as Implement
authority inside the named scope.

## Establish the component contract

Before editing, record or infer from repository evidence:

- the component's responsibility, public inputs, emitted actions, owner, and
  lifetime;
- supported OS versions, device and window classes, orientations, input methods,
  locales, content-size categories, appearances, and accessibility settings;
- visual and interaction states, including initial, loading, content, empty,
  partial, disabled, selected, focused, highlighted, error, and unavailable;
- sizing contract, scroll ownership, safe-area behavior, keyboard behavior, and
  presentation context;
- synchronous and asynchronous dependencies, cancellation points, restoration,
  and test seams;
- acceptance checks and any runtime claim that requires measurement.

Do not block on a reversible detail that repository evidence answers safely.
State consequential assumptions and stop when a missing product decision changes
public behavior or destructive consequences.

## Build from ownership to evidence

1. Inspect callers, containment, data flow, nib or storyboard usage, existing
   components, design tokens, availability helpers, tests, and build settings.
2. Prefer a supported system component and public API that already supplies the
   required semantics. Justify custom drawing, controls, containers, or gestures.
3. Separate one-time hierarchy and constraint construction from repeatable state
   rendering. Make every update assign a complete visible state.
4. Express the sizing contract with anchors, layout guides, intrinsic content
   size, and intentional priorities. Test resizing instead of branching on a
   remembered screen or device class.
5. Model user intent as actions or delegate callbacks with one clear owner.
   Preserve focus, selection, validation, cancellation, and error recovery.
6. Keep view controllers responsible for UI coordination. Move domain policy,
   persistence, networking, and unrelated transformations behind dependencies.
7. Make containment, presentation, dismissal, observation, task, and resource
   lifetimes symmetrical. Do not rely on `deinit` as the only cancellation path.
8. Check API availability at the use site and provide a behaviorally complete
   fallback. Treat prerelease SDK guidance as versioned, opt-in evidence.
9. Run static, focused, build, and runtime checks appropriate to the changed
   states and supported environments before reporting completion.

## Apply hard guardrails

- Mutate UIKit UI on the main actor and keep blocking I/O, decoding, parsing,
  and expensive transformations off the interaction and layout path.
- Do not build subviews, constraints, targets, gestures, or observers repeatedly
  from a state-update callback.
- Do not mix frames and constraints for the same owned geometry without an
  explicit boundary. Set `translatesAutoresizingMaskIntoConstraints` deliberately.
- Do not use screen bounds, idiom checks, or fixed device names as a substitute
  for container size, traits, safe areas, and layout guides.
- Do not use color, motion, a gesture, or sample text as the only carrier
  of meaning or action.
- Do not equate modern UIKit with replacing every `UITableView` by a
  `UICollectionView`. Choose from required behavior and migration cost.
- Keep diffable identifiers stable; never use mutable display data as identity.
- Do not apply asynchronous results to a captured reusable cell or persistent
  index path. Reconcile through stable identity and current state.
- Use the full parent-child view-controller containment sequence and anchor
  popovers to a valid source view, source rect, or bar button item.
- Treat `UIHostingConfiguration` as cell content, not a general replacement for
  `UIHostingController` or a guaranteed performance improvement.
- Never raise the deployment target, replace the app architecture, or introduce
  a new dependency silently.

## Verify and report

Run repository formatting and static checks, focused tests, and a build for the
changed target. Exercise every changed state plus relevant resizing, Dynamic
Type, appearance, localization, keyboard, focus, accessibility, presentation,
repeated configuration, cancellation, and oldest-supported-OS paths. Use a real
device and representative Release build for performance, touch, keyboard,
camera, photo, haptic, or other hardware-dependent claims.

Report the mode, component contract, changed files, chosen system or custom
APIs, ownership and lifetime model, availability and fallback, checks actually
run, environments covered, and remaining uncertainty. Say
`runtime component verification pending` when build or source inspection is the
strongest evidence.
Never infer accessibility, responsiveness, performance, or correct device
behavior from compilation or a single Simulator screenshot.
